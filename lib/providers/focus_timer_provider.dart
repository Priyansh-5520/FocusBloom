import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/focus_session_model.dart';
import '../models/plant_model.dart';
import '../models/user_model.dart';
import '../constants/plant_data.dart';
import '../services/reward_service.dart';
import '../services/level_service.dart';
import '../services/streak_service.dart';
import '../services/achievement_service.dart';
import '../repositories/user_repository.dart';
import '../providers/auth_provider.dart' show UserPlantFactory;
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum TimerState { idle, running, paused, completed, abandoned }

/// Manages the entire focus session lifecycle.
/// Uses timestamp-based timer to survive app backgrounding.
class FocusTimerProvider extends ChangeNotifier {
  final UserRepository _repository;

  TimerState _state = TimerState.idle;
  int _plannedMinutes = 25;
  String _category = 'Work';
  String _plantTypeId = 'focus_fern';

  DateTime? _sessionStart;
  DateTime? _pauseStart;
  Duration _totalPausedDuration = Duration.zero;
  Timer? _ticker;

  // Tracks remaining seconds (recalculated from timestamps)
  int _remainingSeconds = 0;

  // Session data after completion
  FocusSessionModel? _lastCompletedSession;
  RewardResult? _lastReward;
  List<String> _lastNewAchievements = [];

  // Getters
  TimerState get state => _state;
  int get plannedMinutes => _plannedMinutes;
  String get category => _category;
  String get plantTypeId => _plantTypeId;
  int get remainingSeconds => _remainingSeconds;
  FocusSessionModel? get lastCompletedSession => _lastCompletedSession;
  RewardResult? get lastReward => _lastReward;
  List<String> get lastNewAchievements => List.unmodifiable(_lastNewAchievements);

  /// Session progress as 0.0–1.0
  double get progress {
    final total = _plannedMinutes * 60;
    if (total <= 0) return 0;
    final elapsed = total - _remainingSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  /// Current growth stage index from the plant type
  int get currentGrowthStageIndex {
    final plantType = PlantData.getById(_plantTypeId);
    if (plantType == null) return 0;
    return plantType.getGrowthStageIndex(progress);
  }

  PlantType? get selectedPlantType => PlantData.getById(_plantTypeId);

  FocusTimerProvider(this._repository);

  void setup({
    required int plannedMinutes,
    required String category,
    required String plantTypeId,
  }) {
    _plannedMinutes = plannedMinutes;
    _category = category;
    _plantTypeId = plantTypeId;
    _remainingSeconds = plannedMinutes * 60;
    _state = TimerState.idle;
    notifyListeners();
  }

  void start() {
    if (_state == TimerState.running) return;
    _sessionStart ??= DateTime.now();
    _totalPausedDuration = Duration.zero;
    _state = TimerState.running;
    _startTicker();
    notifyListeners();
  }

  void pause() {
    if (_state != TimerState.running) return;
    _pauseStart = DateTime.now();
    _state = TimerState.paused;
    _ticker?.cancel();
    notifyListeners();
  }

  void resume() {
    if (_state != TimerState.paused) return;
    if (_pauseStart != null) {
      _totalPausedDuration += DateTime.now().difference(_pauseStart!);
      _pauseStart = null;
    }
    _state = TimerState.running;
    _startTicker();
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (_state != TimerState.running) return;

    final elapsed = _elapsed();
    final total = _plannedMinutes * 60;
    final remaining = total - elapsed.inSeconds;

    if (remaining <= 0) {
      _remainingSeconds = 0;
      _ticker?.cancel();
      notifyListeners();
      // Session auto-completion is triggered externally via completeSession()
    } else {
      _remainingSeconds = remaining;
      notifyListeners();
    }
  }

  Duration _elapsed() {
    if (_sessionStart == null) return Duration.zero;
    final now = DateTime.now();
    final rawElapsed = now.difference(_sessionStart!);
    return rawElapsed - _totalPausedDuration;
  }

  int get elapsedSeconds => _elapsed().inSeconds;

  /// Call when timer reaches 0 or user explicitly completes.
  Future<void> completeSession(UserModel user) async {
    _ticker?.cancel();
    final actualSeconds = elapsedSeconds;
    final reward = RewardService.calculateReward(
      plannedMinutes: _plannedMinutes,
      actualSeconds: actualSeconds,
      currentStreak: user.currentStreak,
    );

    await _finalizeSession(user, actualSeconds, reward);
  }

  /// Call when user explicitly abandons early.
  Future<void> abandonSession(UserModel user) async {
    _ticker?.cancel();
    final actualSeconds = elapsedSeconds;
    final reward = RewardService.calculateReward(
      plannedMinutes: _plannedMinutes,
      actualSeconds: actualSeconds,
      currentStreak: user.currentStreak,
    );
    _state = TimerState.abandoned;
    await _finalizeSession(user, actualSeconds, reward);
  }

  Future<void> _finalizeSession(UserModel user, int actualSeconds, RewardResult reward) async {
    final now = DateTime.now();
    final sessionId = const Uuid().v4();

    // Determine if truly completed
    final plannedSeconds = _plannedMinutes * 60;
    final completionPct = actualSeconds / plannedSeconds;
    final isCompleted = completionPct >= 1.0;

    final session = FocusSessionModel(
      id: sessionId,
      duration: _plannedMinutes,
      actualDuration: actualSeconds,
      category: _category,
      plantId: _plantTypeId,
      completed: reward.completed,
      xpEarned: reward.xp,
      coinsEarned: reward.coins,
      startedAt: _sessionStart ?? now.subtract(Duration(seconds: actualSeconds)),
      completedAt: now,
    );

    // Update plant
    final hasPrevPlant = await _repository.hasPlant(user.uid, _plantTypeId);
    final existingPlants = await _repository.getUserPlants(user.uid);

    UserPlant updatedPlant;
    if (hasPrevPlant) {
      final existing = existingPlants.firstWhere(
        (p) => p.plantTypeId == _plantTypeId,
        orElse: () => UserPlantFactory.create(_plantTypeId),
      );
      final plantType = PlantData.getById(_plantTypeId);
      final newXP = existing.growthXP + reward.xp;
      final newStage = plantType?.getGrowthStageIndex(isCompleted ? 1.0 : completionPct) ?? 0;
      updatedPlant = existing.copyWith(
        growthXP: newXP,
        growthStage: newStage,
        lastUpdated: now,
        sessionCount: existing.sessionCount + 1,
      );
    } else {
      updatedPlant = UserPlantFactory.create(_plantTypeId);
    }

    // Update streak
    final newStreak = StreakService.calculateNewStreak(
      currentStreak: user.currentStreak,
      lastFocusDate: user.lastFocusDate,
    );
    final newLongestStreak = newStreak > user.longestStreak ? newStreak : user.longestStreak;

    // Update user stats
    final updatedTotalXP = user.totalXP + reward.xp;
    final newLevel = LevelService.getLevelForXP(updatedTotalXP);

    final updatedUser = user.copyWith(
      totalXP: updatedTotalXP,
      level: newLevel,
      totalFocusMinutes: user.totalFocusMinutes + (actualSeconds ~/ 60),
      totalSessions: user.totalSessions + 1,
      coins: user.coins + reward.coins,
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      lastFocusDate: StreakService.todayString(),
      updatedAt: now,
    );

    // Check achievements
    final existingAchievementIds = (await _repository.getUserAchievements(user.uid))
        .map((a) => a.achievementId)
        .toList();

    final newAchievements = AchievementService.checkNewAchievements(
      user: updatedUser,
      session: session,
      alreadyUnlockedIds: existingAchievementIds,
      totalPlants: existingPlants.length,
    );

    // Commit to local repository and Firestore
    await _repository.completeSession(
      uid: user.uid,
      session: session,
      updatedUser: updatedUser,
      plant: updatedPlant,
      newAchievementIds: newAchievements,
    );

    _lastCompletedSession = session;
    _lastReward = reward;
    _lastNewAchievements = newAchievements;
    _state = isCompleted ? TimerState.completed : TimerState.abandoned;
    notifyListeners();
  }

  void reset() {
    _ticker?.cancel();
    _state = TimerState.idle;
    _sessionStart = null;
    _pauseStart = null;
    _totalPausedDuration = Duration.zero;
    _remainingSeconds = _plannedMinutes * 60;
    _lastCompletedSession = null;
    _lastReward = null;
    _lastNewAchievements = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

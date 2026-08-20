import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/plant_model.dart';
import '../models/achievement_model.dart';
import '../models/focus_session_model.dart';
import '../models/store_item_model.dart';
import '../repositories/user_repository.dart';

/// Provides user data (plants, achievements, sessions, inventory)
/// after the user is authenticated.
class UserDataProvider extends ChangeNotifier {
  final UserRepository _repository;

  UserModel? _user;
  List<UserPlant> _plants = [];
  List<UserAchievement> _achievements = [];
  List<FocusSessionModel> _sessions = [];
  List<InventoryItem> _inventory = [];
  bool _isLoading = false;
  String? _error;

  UserDataProvider(this._repository);

  UserModel? get user => _user;
  List<UserPlant> get plants => List.unmodifiable(_plants);
  List<UserAchievement> get achievements => List.unmodifiable(_achievements);
  List<FocusSessionModel> get sessions => List.unmodifiable(_sessions);
  List<InventoryItem> get inventory => List.unmodifiable(_inventory);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all data for a user (called after login).
  Future<void> loadUserData(String uid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.getUserProfile(uid),
        _repository.getUserPlants(uid),
        _repository.getUserAchievements(uid),
        _repository.getSessions(uid, limit: 100),
        _repository.getInventory(uid),
      ]);

      _user = results[0] as UserModel?;
      _plants = results[1] as List<UserPlant>;
      _achievements = results[2] as List<UserAchievement>;
      _sessions = results[3] as List<FocusSessionModel>;
      _inventory = results[4] as List<InventoryItem>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh all data.
  Future<void> refresh(String uid) => loadUserData(uid);

  /// Update local user model (e.g. after session completion).
  void updateUser(UserModel updated) {
    _user = updated;
    notifyListeners();
  }

  /// Add a newly completed session to local list.
  void addSession(FocusSessionModel session) {
    _sessions.insert(0, session);
    notifyListeners();
  }

  /// Update or add a plant in local list.
  void upsertPlant(UserPlant plant) {
    final idx = _plants.indexWhere((p) => p.plantTypeId == plant.plantTypeId);
    if (idx >= 0) {
      _plants[idx] = plant;
    } else {
      _plants.add(plant);
    }
    notifyListeners();
  }

  /// Add a newly unlocked achievement.
  void addAchievement(UserAchievement achievement) {
    _achievements.add(achievement);
    notifyListeners();
  }

  /// Add inventory item.
  void addInventoryItem(InventoryItem item) {
    _inventory.add(item);
    notifyListeners();
  }

  /// Check if user owns an item.
  bool ownsItem(String itemId) => _inventory.any((i) => i.itemId == itemId);

  /// Check if user owns a plant type.
  bool hasPlant(String plantTypeId) => _plants.any((p) => p.plantTypeId == plantTypeId);

  /// Get today's total focused minutes.
  int get todayFocusMinutes {
    final today = DateTime.now();
    return _sessions
        .where((s) =>
            s.startedAt.year == today.year &&
            s.startedAt.month == today.month &&
            s.startedAt.day == today.day)
        .fold(0, (sum, s) => sum + (s.actualDuration ~/ 60));
  }

  /// Get today's completed session count.
  int get todayCompletedSessions {
    final today = DateTime.now();
    return _sessions.where((s) =>
        s.completed &&
        s.startedAt.year == today.year &&
        s.startedAt.month == today.month &&
        s.startedAt.day == today.day).length;
  }

  /// Clear all data (on logout).
  void clear() {
    _user = null;
    _plants = [];
    _achievements = [];
    _sessions = [];
    _inventory = [];
    notifyListeners();
  }
}

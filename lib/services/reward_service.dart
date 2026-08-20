import '../constants/app_constants.dart';

/// Calculates XP and Bloom Coin rewards for focus sessions.
/// All reward logic lives here — never hardcode rewards in UI widgets.
class RewardService {
  RewardService._();

  /// Calculate rewards based on planned duration and actual completion.
  /// Returns a [RewardResult] with xp and coins.
  static RewardResult calculateReward({
    required int plannedMinutes,
    required int actualSeconds,
    required int currentStreak,
  }) {
    final plannedSeconds = plannedMinutes * 60;
    if (plannedSeconds <= 0) return const RewardResult(xp: 0, coins: 0, completed: false);

    final completionPercent = actualSeconds / plannedSeconds;
    final bool completed = completionPercent >= 1.0;

    double multiplier;
    if (completionPercent < AppConstants.kNoRewardThreshold) {
      // Less than 25% — no reward
      return const RewardResult(xp: 0, coins: 0, completed: false);
    } else if (completionPercent < AppConstants.kPartialRewardThreshold) {
      // 25–74% — partial reward
      multiplier = AppConstants.kPartialRewardMultiplier;
    } else if (completionPercent < AppConstants.kReducedRewardThreshold) {
      // 75–99% — reduced reward
      multiplier = AppConstants.kReducedRewardMultiplier;
    } else {
      // 100% — full reward
      multiplier = 1.0;
    }

    // Base XP and coins from actual time focused
    final actualMinutes = actualSeconds / 60.0;
    int baseXP = (actualMinutes * AppConstants.kXpPerMinute * multiplier).round();
    int baseCoins = (actualMinutes * AppConstants.kCoinsPerMinute * multiplier).round();

    // Streak bonus: +10% for every 7-day streak milestone
    final streakBonus = _streakMultiplier(currentStreak);
    baseXP = (baseXP * streakBonus).round();
    baseCoins = (baseCoins * streakBonus).round();

    return RewardResult(xp: baseXP, coins: baseCoins, completed: completed);
  }

  static double _streakMultiplier(int streak) {
    if (streak <= 0) return 1.0;
    final milestones = streak ~/ AppConstants.kStreakBonusThreshold;
    return 1.0 + (milestones * (AppConstants.kStreakBonusMultiplier - 1));
  }
}

class RewardResult {
  final int xp;
  final int coins;
  final bool completed;

  const RewardResult({
    required this.xp,
    required this.coins,
    required this.completed,
  });
}

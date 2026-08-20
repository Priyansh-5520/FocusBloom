import '../constants/app_constants.dart';

/// Manages XP → Level progression.
class LevelService {
  LevelService._();

  /// Returns the level for a given total XP amount.
  static int getLevelForXP(int totalXP) {
    final thresholds = AppConstants.kLevelXpThresholds;
    int level = 1;
    for (int i = thresholds.length - 1; i >= 0; i--) {
      if (totalXP >= thresholds[i]) {
        level = i + 1;
        break;
      }
    }
    return level;
  }

  /// Returns total XP required to reach the next level.
  static int xpForNextLevel(int currentLevel) {
    final thresholds = AppConstants.kLevelXpThresholds;
    if (currentLevel >= thresholds.length) {
      // Beyond max defined level — extrapolate
      return thresholds.last + (currentLevel - thresholds.length + 1) * 5000;
    }
    return thresholds[currentLevel]; // index = level (1-indexed offset by 1)
  }

  /// Returns XP required for the current level's start.
  static int xpForCurrentLevel(int currentLevel) {
    final thresholds = AppConstants.kLevelXpThresholds;
    if (currentLevel <= 1) return 0;
    final idx = currentLevel - 1;
    if (idx >= thresholds.length) return thresholds.last;
    return thresholds[idx];
  }

  /// Returns 0.0–1.0 progress within the current level.
  static double levelProgress(int totalXP) {
    final level = getLevelForXP(totalXP);
    final current = xpForCurrentLevel(level);
    final next = xpForNextLevel(level);
    if (next <= current) return 1.0;
    return ((totalXP - current) / (next - current)).clamp(0.0, 1.0);
  }

  /// Returns how many XP the user has within the current level.
  static int currentLevelXP(int totalXP) {
    final level = getLevelForXP(totalXP);
    return totalXP - xpForCurrentLevel(level);
  }

  /// Returns how many XP needed to reach next level.
  static int xpNeededForNextLevel(int totalXP) {
    final level = getLevelForXP(totalXP);
    return xpForNextLevel(level) - xpForCurrentLevel(level);
  }
}

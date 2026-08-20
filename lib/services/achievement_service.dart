import '../constants/achievement_data.dart';
import '../models/achievement_model.dart';
import '../models/user_model.dart';
import '../models/focus_session_model.dart';

/// Checks and returns which achievements are newly unlocked for a user.
class AchievementService {
  AchievementService._();

  /// Returns a list of achievement IDs that are newly unlocked
  /// based on user state after a session.
  static List<String> checkNewAchievements({
    required UserModel user,
    required FocusSessionModel session,
    required List<String> alreadyUnlockedIds,
    required int totalPlants,
  }) {
    final newlyUnlocked = <String>[];

    for (final def in AchievementData.all) {
      if (alreadyUnlockedIds.contains(def.id)) continue;

      if (_isUnlocked(def, user, session, totalPlants)) {
        newlyUnlocked.add(def.id);
      }
    }

    return newlyUnlocked;
  }

  static bool _isUnlocked(
    AchievementDefinition def,
    UserModel user,
    FocusSessionModel session,
    int totalPlants,
  ) {
    switch (def.type) {
      case AchievementType.firstSession:
        return user.totalSessions >= 1;

      case AchievementType.sessionCount:
        return user.totalSessions >= def.targetValue;

      case AchievementType.deepFocus:
        // Single session >= 120 minutes
        return session.completed && session.duration >= def.targetValue;

      case AchievementType.streak:
        return user.currentStreak >= def.targetValue;

      case AchievementType.totalHours:
        return (user.totalFocusMinutes / 60) >= def.targetValue;

      case AchievementType.plantCount:
        return totalPlants >= def.targetValue;

      case AchievementType.levelReached:
        return user.level >= def.targetValue;

      case AchievementType.coinsEarned:
        // Check if user has earned at least targetValue coins total
        // (approximated by total coins currently held + historical earnings)
        // We use coins as a rough proxy; a more precise tracker could be added
        return user.coins >= def.targetValue;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

/// Achievement definition — static data, not stored in Firestore per user.
class AchievementDefinition {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final AchievementType type;
  final int targetValue; // e.g. 5 sessions, 7 day streak
  final int xpReward;
  final int coinReward;

  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.type,
    required this.targetValue,
    this.xpReward = 50,
    this.coinReward = 25,
  });
}

enum AchievementType {
  firstSession,
  sessionCount,
  deepFocus,      // single 120min session
  streak,
  totalHours,
  plantCount,
  levelReached,
  coinsEarned,
}

/// A user-unlocked achievement stored in Firestore.
class UserAchievement {
  final String achievementId;
  final DateTime unlockedAt;

  const UserAchievement({
    required this.achievementId,
    required this.unlockedAt,
  });

  factory UserAchievement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserAchievement(
      achievementId: doc.id,
      unlockedAt: (data['unlockedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'achievementId': achievementId,
      'unlockedAt': Timestamp.fromDate(unlockedAt),
    };
  }
}

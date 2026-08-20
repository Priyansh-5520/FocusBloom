import '../models/achievement_model.dart';

/// All achievement definitions for FocusBloom.
class AchievementData {
  AchievementData._();

  static const List<AchievementDefinition> all = [
    AchievementDefinition(
      id: 'first_focus',
      title: 'First Focus',
      description: 'Complete your very first focus session.',
      emoji: '🌱',
      type: AchievementType.firstSession,
      targetValue: 1,
      xpReward: 50,
      coinReward: 20,
    ),
    AchievementDefinition(
      id: 'getting_started',
      title: 'Getting Started',
      description: 'Complete 5 focus sessions.',
      emoji: '🌿',
      type: AchievementType.sessionCount,
      targetValue: 5,
      xpReward: 100,
      coinReward: 40,
    ),
    AchievementDefinition(
      id: 'focused_mind',
      title: 'Focused Mind',
      description: 'Complete 25 focus sessions.',
      emoji: '🍃',
      type: AchievementType.sessionCount,
      targetValue: 25,
      xpReward: 250,
      coinReward: 100,
    ),
    AchievementDefinition(
      id: 'century_sessioner',
      title: 'Century Sessioner',
      description: 'Complete 100 focus sessions.',
      emoji: '🏆',
      type: AchievementType.sessionCount,
      targetValue: 100,
      xpReward: 1000,
      coinReward: 500,
    ),
    AchievementDefinition(
      id: 'deep_focus',
      title: 'Deep Focus',
      description: 'Complete a single 2-hour focus session.',
      emoji: '🌳',
      type: AchievementType.deepFocus,
      targetValue: 120,
      xpReward: 150,
      coinReward: 75,
    ),
    AchievementDefinition(
      id: 'week_warrior',
      title: 'Week Warrior',
      description: 'Maintain a 7-day focus streak.',
      emoji: '🔥',
      type: AchievementType.streak,
      targetValue: 7,
      xpReward: 200,
      coinReward: 100,
    ),
    AchievementDefinition(
      id: 'month_master',
      title: 'Month Master',
      description: 'Maintain a 30-day focus streak.',
      emoji: '💫',
      type: AchievementType.streak,
      targetValue: 30,
      xpReward: 1000,
      coinReward: 500,
    ),
    AchievementDefinition(
      id: 'ten_hours',
      title: '10 Hour Milestone',
      description: 'Reach 10 total hours of focused work.',
      emoji: '⏰',
      type: AchievementType.totalHours,
      targetValue: 10,
      xpReward: 100,
      coinReward: 50,
    ),
    AchievementDefinition(
      id: 'fifty_hours',
      title: '50 Hour Legend',
      description: 'Reach 50 total hours of focused work.',
      emoji: '💎',
      type: AchievementType.totalHours,
      targetValue: 50,
      xpReward: 500,
      coinReward: 250,
    ),
    AchievementDefinition(
      id: 'bloom_master',
      title: 'Bloom Master',
      description: 'Grow 5 different plants in your garden.',
      emoji: '🌸',
      type: AchievementType.plantCount,
      targetValue: 5,
      xpReward: 150,
      coinReward: 75,
    ),
    AchievementDefinition(
      id: 'garden_guardian',
      title: 'Garden Guardian',
      description: 'Grow all 12 plant types.',
      emoji: '🌻',
      type: AchievementType.plantCount,
      targetValue: 12,
      xpReward: 500,
      coinReward: 250,
    ),
    AchievementDefinition(
      id: 'level_five',
      title: 'Level 5 Achieved',
      description: 'Reach Level 5.',
      emoji: '⭐',
      type: AchievementType.levelReached,
      targetValue: 5,
      xpReward: 100,
      coinReward: 50,
    ),
    AchievementDefinition(
      id: 'level_ten',
      title: 'Level 10 Master',
      description: 'Reach Level 10.',
      emoji: '🌟',
      type: AchievementType.levelReached,
      targetValue: 10,
      xpReward: 500,
      coinReward: 250,
    ),
    AchievementDefinition(
      id: 'coin_collector',
      title: 'Coin Collector',
      description: 'Earn 500 total Bloom Coins.',
      emoji: '🪙',
      type: AchievementType.coinsEarned,
      targetValue: 500,
      xpReward: 100,
      coinReward: 0,
    ),
  ];

  static AchievementDefinition? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}

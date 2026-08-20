// App-wide constants for FocusBloom

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'FocusBloom';
  static const String appVersion = '1.0.0';

  // SharedPreferences Keys
  static const String kOnboardingComplete = 'onboarding_complete';
  static const String kDailyGoalMinutes = 'daily_goal_minutes';
  static const String kThemeMode = 'theme_mode';
  static const String kSelectedPlantId = 'selected_plant_id';
  static const String kFavoriteCategories = 'favorite_categories';
  static const String kNotificationsEnabled = 'notifications_enabled';
  static const String kDailyReminderTime = 'daily_reminder_time';

  // Default Values
  static const int kDefaultDailyGoalMinutes = 60;
  static const String kDefaultPlantId = 'focus_fern';

  // Focus Session Durations (in minutes)
  static const List<int> kFocusDurations = [10, 25, 30, 45, 60, 90, 120, 180];

  // Reward configuration
  static const double kXpPerMinute = 1.0;
  static const double kCoinsPerMinute = 0.5;
  static const double kStreakBonusMultiplier = 1.1; // +10% per streak milestone
  static const int kStreakBonusThreshold = 7; // bonus every 7 days

  // Partial reward thresholds
  static const double kNoRewardThreshold = 0.25;   // <25% → no XP
  static const double kPartialRewardThreshold = 0.75; // 25–74% → partial
  static const double kReducedRewardThreshold = 1.0;  // 75–99% → reduced
  static const double kPartialRewardMultiplier = 0.5;
  static const double kReducedRewardMultiplier = 0.8;

  // Level XP thresholds
  static const List<int> kLevelXpThresholds = [
    0,    // Level 1
    100,  // Level 2
    250,  // Level 3
    500,  // Level 4
    1000, // Level 5
    1750, // Level 6
    2750, // Level 7
    4000, // Level 8
    5500, // Level 9
    7500, // Level 10
    10000,// Level 11
    13000,// Level 12
    16500,// Level 13
    20500,// Level 14
    25000,// Level 15
  ];

  // Focus categories
  static const List<String> kFocusCategories = [
    'Work',
    'Study',
    'Coding',
    'Writing',
    'Reading',
    'Exercise',
    'Creative',
    'Social',
    'Rest',
    'Entertainment',
    'Other',
  ];

  // Firestore collections
  static const String kUsersCollection = 'users';
  static const String kSessionsCollection = 'sessions';
  static const String kPlantsCollection = 'plants';
  static const String kInventoryCollection = 'inventory';
  static const String kAchievementsCollection = 'achievements';
}

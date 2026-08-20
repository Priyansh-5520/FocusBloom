import 'package:intl/intl.dart';

/// Manages daily focus streak logic.
/// Streak is tracked by calendar date strings ('yyyy-MM-dd').
class StreakService {
  StreakService._();

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  static String todayString() => _dateFormat.format(DateTime.now());

  static String yesterdayString() =>
      _dateFormat.format(DateTime.now().subtract(const Duration(days: 1)));

  /// Calculates the updated streak after a completed session today.
  /// Returns the new streak value.
  static int calculateNewStreak({
    required int currentStreak,
    required String? lastFocusDate,
  }) {
    final today = todayString();
    final yesterday = yesterdayString();

    if (lastFocusDate == null) {
      // First ever session
      return 1;
    }

    if (lastFocusDate == today) {
      // Already focused today — streak unchanged
      return currentStreak;
    }

    if (lastFocusDate == yesterday) {
      // Focused yesterday — continue streak
      return currentStreak + 1;
    }

    // Missed at least one day — reset
    return 1;
  }

  /// Check if the user's streak should be reset (they didn't focus yesterday or haven't yet focused today).
  /// Call this on app launch to see if a streak has been broken.
  static bool isStreakBroken({required String? lastFocusDate}) {
    if (lastFocusDate == null) return false;

    final today = todayString();
    final yesterday = yesterdayString();

    return lastFocusDate != today && lastFocusDate != yesterday;
  }

  /// Returns whether the user has already focused today.
  static bool hasFocusedToday({required String? lastFocusDate}) {
    if (lastFocusDate == null) return false;
    return lastFocusDate == todayString();
  }
}

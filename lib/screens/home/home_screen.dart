import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_data_provider.dart';
import '../../services/level_service.dart';
import '../../models/plant_model.dart';
import '../../constants/plant_data.dart';
import '../../widgets/plant/plant_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userData = context.watch<UserDataProvider>();
    final user = auth.userModel ?? userData.user;

    if (user == null) {
      if (!auth.isLoading && !auth.isAuthenticated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        });
      } else if (auth.isAuthenticated && !userData.isLoading) {
        final uid = auth.firebaseUser?.uid ?? auth.userModel?.uid;
        if (uid != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.read<UserDataProvider>().loadUserData(uid);
            }
          });
        }
      }
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.primaryLight),
          ),
        ),
      );
    }

    final totalXP = user.totalXP;
    final level = user.level;
    final levelProgress = LevelService.levelProgress(totalXP);
    final currentLevelXP = LevelService.currentLevelXP(totalXP);
    final nextLevelXP = LevelService.xpNeededForNextLevel(totalXP);
    final todayMinutes = userData.todayFocusMinutes;
    final todaySessions = userData.todayCompletedSessions;
    final dailyGoal = user.dailyGoalMinutes;
    final goalProgress = dailyGoal > 0 ? (todayMinutes / dailyGoal).clamp(0.0, 1.0) : 0.0;

    // Pick the main tree to display
    final plants = userData.plants;
    final mainPlantTypeId = plants.isNotEmpty ? plants.first.plantTypeId : 'oak';
    final mainPlantType = PlantData.getById(mainPlantTypeId);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App bar
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              expandedHeight: 70,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_greeting()}, ${user.name.split(' ').first} 👋',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    todaySessions > 0
                        ? '$todaySessions session${todaySessions == 1 ? '' : 's'} grown today'
                        : 'Ready to grow your forest?',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondary.withValues(alpha: 0.15),
                        AppColors.secondary.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 5),
                      Text(
                        '${user.coins}',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),

                  // Level + XP card with gradient accent
                  _LevelCard(
                    level: level,
                    levelProgress: levelProgress,
                    currentLevelXP: currentLevelXP,
                    nextLevelXP: nextLevelXP,
                  ),

                  const SizedBox(height: 16),

                  // Stats row — enhanced with icons and colors
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Today',
                          value: _formatMinutes(todayMinutes),
                          emoji: '⏱',
                          color: AppColors.primary,
                          bgColor: AppColors.primary.withValues(alpha: 0.12),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          label: 'Sessions',
                          value: '$todaySessions',
                          emoji: '✅',
                          color: AppColors.success,
                          bgColor: AppColors.success.withValues(alpha: 0.12),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          label: 'Streak',
                          value: '${user.currentStreak}',
                          emoji: '🔥',
                          color: AppColors.accent,
                          bgColor: AppColors.accent.withValues(alpha: 0.12),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Daily goal card — circular progress
                  if (dailyGoal > 0) ...[
                    _DailyGoalCard(
                      todayMinutes: todayMinutes,
                      dailyGoal: dailyGoal,
                      goalProgress: goalProgress,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Current tree — forest sanctuary preview
                  _ForestPreviewCard(
                    plants: plants,
                    mainPlantType: mainPlantType,
                  ),

                  const SizedBox(height: 24),

                  // Start focus button — glowing CTA
                  _StartFocusButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/focus');
                    },
                  ),

                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${minutes}m';
  }
}

// ============================================================================
// LEVEL CARD
// ============================================================================
class _LevelCard extends StatelessWidget {
  final int level;
  final double levelProgress;
  final int currentLevelXP;
  final int nextLevelXP;

  const _LevelCard({
    required this.level,
    required this.levelProgress,
    required this.currentLevelXP,
    required this.nextLevelXP,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.primaryContainer.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Level badge
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$level',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Level $level',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '$currentLevelXP / $nextLevelXP XP',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Fancy XP bar
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: AppColors.surfaceVariant,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Stack(
                      children: [
                        FractionallySizedBox(
                          widthFactor: levelProgress,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primaryLight,
                                  AppColors.primary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// STAT CARD
// ============================================================================
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.emoji,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DAILY GOAL CARD with circular progress
// ============================================================================
class _DailyGoalCard extends StatelessWidget {
  final int todayMinutes;
  final int dailyGoal;
  final double goalProgress;

  const _DailyGoalCard({
    required this.todayMinutes,
    required this.dailyGoal,
    required this.goalProgress,
  });

  String _formatMinutes(int minutes) {
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = goalProgress >= 1.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isComplete
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.surfaceBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular progress
          SizedBox(
            width: 64,
            height: 64,
            child: CustomPaint(
              painter: _CircularGoalPainter(
                progress: goalProgress,
                isComplete: isComplete,
              ),
              child: Center(
                child: Text(
                  '${(goalProgress * 100).toInt()}%',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isComplete ? AppColors.success : AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Daily Goal',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (isComplete) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '🎉 Done!',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatMinutes(todayMinutes)} of ${_formatMinutes(dailyGoal)} focused',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: goalProgress,
                    minHeight: 6,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation(
                      isComplete ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularGoalPainter extends CustomPainter {
  final double progress;
  final bool isComplete;

  _CircularGoalPainter({required this.progress, required this.isComplete});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 8) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = AppColors.surfaceVariant
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = isComplete ? AppColors.success : AppColors.primary
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularGoalPainter old) =>
      old.progress != progress || old.isComplete != isComplete;
}

// ============================================================================
// FOREST PREVIEW CARD
// ============================================================================
class _ForestPreviewCard extends StatelessWidget {
  final List plants;
  final PlantType? mainPlantType;

  const _ForestPreviewCard({
    required this.plants,
    required this.mainPlantType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surface,
            const Color(0xFF2D5016).withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🌳', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  const Text(
                    'My Forest',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${plants.length} species',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: mainPlantType != null
                ? Column(
                    children: [
                      PlantWidget(
                        plantType: mainPlantType!,
                        progress: 1.0,
                        size: 130,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        mainPlantType!.name,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mainPlantType!.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                          height: 1.4,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      const Text('🌱', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 8),
                      Text(
                        'No trees yet — start a focus session!',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// START FOCUS BUTTON with glow
// ============================================================================
class _StartFocusButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _StartFocusButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.play_arrow_rounded, size: 28),
        label: const Text(
          'Start Focus Session',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(58),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

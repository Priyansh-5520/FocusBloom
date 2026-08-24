import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_data_provider.dart';
import '../../providers/focus_timer_provider.dart';
import '../../constants/plant_data.dart';
import '../../widgets/plant/plant_widget.dart';
import '../../constants/achievement_data.dart';

class FocusResultScreen extends StatelessWidget {
  const FocusResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timer = context.read<FocusTimerProvider>();
    final session = timer.lastCompletedSession;
    final reward = timer.lastReward;
    final newAchievements = timer.lastNewAchievements;
    final plantType = PlantData.getById(timer.plantTypeId);

    final isCompleted = timer.state == TimerState.completed;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Header
              Text(
                isCompleted ? '🎉 Tree Grown!' : 'Session Ended',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isCompleted
                    ? 'Your magnificent tree has flourished in your forest!'
                    : 'You ended early. Partial rewards earned.',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Tree display
              if (plantType != null)
                PlantWidget(
                  plantType: plantType,
                  progress: isCompleted ? 1.0 : (session?.completionPercent ?? 0),
                  size: 140,
                ),

              const SizedBox(height: 32),

              // Stats card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _StatRow(
                      icon: Icons.timer_outlined,
                      label: 'Focus Time',
                      value: _formatSeconds(session?.actualDuration ?? 0),
                      color: AppColors.primary,
                    ),
                    const Divider(height: 24),
                    _StatRow(
                      icon: Icons.star_outline_rounded,
                      label: 'XP Earned',
                      value: '+${reward?.xp ?? 0} XP',
                      color: AppColors.secondary,
                    ),
                    const Divider(height: 24),
                    _StatRow(
                      icon: Icons.monetization_on_outlined,
                      label: 'Bloom Coins',
                      value: '+${reward?.coins ?? 0} 🪙',
                      color: AppColors.secondary,
                    ),
                    if (session != null && session.completionPercent < 1.0) ...[
                      const Divider(height: 24),
                      _StatRow(
                        icon: Icons.pie_chart_outline,
                        label: 'Completion',
                        value: '${(session.completionPercent * 100).toInt()}%',
                        color: AppColors.accent,
                      ),
                    ],
                  ],
                ),
              ),

              // New achievements
              if (newAchievements.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          const Text(
                            'Achievements Unlocked!',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...newAchievements.map((id) {
                        final def = AchievementData.getById(id);
                        if (def == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Text(def.emoji, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      def.title,
                                      style: const TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      def.description,
                                      style: const TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Action buttons
              ElevatedButton.icon(
                onPressed: () async {
                  final auth = context.read<AuthProvider>();
                  final userData = context.read<UserDataProvider>();
                  final uid = auth.firebaseUser?.uid ?? auth.userModel?.uid;
                  if (uid != null) {
                    await auth.refreshUserModel();
                    await userData.refresh(uid);
                  }
                  timer.reset();
                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                icon: const Icon(Icons.check_rounded),
                label: const Text('Done', style: TextStyle(fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final auth = context.read<AuthProvider>();
                  final userData = context.read<UserDataProvider>();
                  final uid = auth.firebaseUser?.uid ?? auth.userModel?.uid;
                  if (uid != null) {
                    await auth.refreshUserModel();
                    await userData.refresh(uid);
                  }
                  timer.reset();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Grow Another Tree', style: TextStyle(fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSeconds(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m >= 60) {
      final h = m ~/ 60;
      final rem = m % 60;
      return rem > 0 ? '${h}h ${rem}m' : '${h}h';
    }
    return s > 0 ? '${m}m ${s}s' : '${m}m';
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.18),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

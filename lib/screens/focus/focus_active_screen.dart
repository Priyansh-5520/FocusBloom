import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_data_provider.dart';
import '../../providers/focus_timer_provider.dart';
import '../../widgets/plant/plant_widget.dart';
import 'focus_result_screen.dart';

class FocusActiveScreen extends StatelessWidget {
  const FocusActiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _FocusActiveView();
  }
}

class _FocusActiveView extends StatefulWidget {
  @override
  State<_FocusActiveView> createState() => _FocusActiveViewState();
}

class _FocusActiveViewState extends State<_FocusActiveView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timer = context.read<FocusTimerProvider>();
      if (timer.state == TimerState.idle) {
        timer.start();
      }
    });
  }

  Future<bool?> _showEndSessionDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Leave Focus Session?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Leaving now will give you partial rewards, and your tree will stop growing for this session.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep Focusing'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleEnd() async {
    final confirm = await _showEndSessionDialog();
    if (confirm == true && mounted) {
      final timer = context.read<FocusTimerProvider>();
      final auth = context.read<AuthProvider>();
      final userData = context.read<UserDataProvider>();
      final user = auth.userModel ?? userData.user;
      if (user != null) {
        await timer.abandonSession(user);
        if (mounted) {
          await auth.refreshUserModel();
          await userData.refresh(user.uid);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const FocusResultScreen()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<FocusTimerProvider>();
    final auth = context.watch<AuthProvider>();
    final userData = context.watch<UserDataProvider>();
    final user = auth.userModel ?? userData.user;

    // Auto-complete when timer reaches 0
    if (timer.remainingSeconds == 0 && timer.state == TimerState.running) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (user != null) {
          await timer.completeSession(user);
          if (mounted) {
            await auth.refreshUserModel();
            await userData.refresh(user.uid);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const FocusResultScreen()),
            );
          }
        }
      });
    }

    final plantType = timer.selectedPlantType;
    final progress = timer.progress;
    final remaining = timer.remainingSeconds;
    final isPaused = timer.state == TimerState.paused;
    final catColor = AppColors.categoryColors[timer.category] ?? AppColors.primary;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showEndSessionDialog() ?? false;
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        timer.category,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: catColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Progress label
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.primary,
                          ),
                    ),
                  ],
                ),
              ),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.primaryContainer,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Plant visualization
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (plantType != null)
                        PlantWidget(
                          plantType: plantType,
                          progress: progress,
                          size: 160,
                        ),
                      const SizedBox(height: 32),

                      // Timer countdown
                      Text(
                        _formatTime(remaining),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 64,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -2,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Status message
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          isPaused
                              ? '⏸ Session paused'
                              : _getMotivationalMessage(progress),
                          key: ValueKey(isPaused ? 'paused' : progress.toStringAsFixed(1)),
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  children: [
                    // Pause/Resume button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (isPaused) {
                            timer.resume();
                          } else {
                            timer.pause();
                          }
                        },
                        icon: Icon(
                          isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                          size: 24,
                        ),
                        label: Text(isPaused ? 'Resume' : 'Pause'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPaused ? AppColors.primary : AppColors.surfaceVariant,
                          foregroundColor: isPaused ? Colors.white : AppColors.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // End session
                    TextButton(
                      onPressed: _handleEnd,
                      child: const Text(
                        'End Session',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _getMotivationalMessage(double progress) {
    if (progress < 0.2) return 'Stay focused. Your seed is taking root... 🌱';
    if (progress < 0.4) return 'A sturdy sapling emerges! Keep going 🌿';
    if (progress < 0.6) return "Branches are spreading wide! Halfway there!";
    if (progress < 0.8) return 'Rich foliage is filling the canopy 🌳';
    if (progress < 1.0) return "Almost fully grown! Keep your focus strong!";
    return '🎉 Grand Tree fully grown!';
  }
}

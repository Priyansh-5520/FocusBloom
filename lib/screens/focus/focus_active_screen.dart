import 'dart:math' as math;
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
    return const _FocusActiveView();
  }
}

class _FocusActiveView extends StatefulWidget {
  const _FocusActiveView();

  @override
  State<_FocusActiveView> createState() => _FocusActiveViewState();
}

class _FocusActiveViewState extends State<_FocusActiveView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timer = context.read<FocusTimerProvider>();
      if (timer.state == TimerState.idle) {
        timer.start();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<bool?> _showEndSessionDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            SizedBox(width: 8),
            Text(
              'Leave Focus Session?',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: const Text(
          'Leaving now will give you partial rewards, and your tree will stop growing for this session.',
          style: TextStyle(
            fontFamily: 'Nunito',
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep Focusing', style: TextStyle(color: AppColors.primary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
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
        if (!mounted) return;
        final nav = Navigator.of(context);
        await auth.refreshUserModel();
        await userData.refresh(user.uid);
        nav.pushReplacement(
          MaterialPageRoute(builder: (_) => const FocusResultScreen()),
        );
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
          if (!mounted) return;
          final nav = Navigator.of(context);
          await auth.refreshUserModel();
          await userData.refresh(user.uid);
          nav.pushReplacement(
            MaterialPageRoute(builder: (_) => const FocusResultScreen()),
          );
        }
      });
    }

    final plantType = timer.selectedPlantType;
    final progress = timer.progress.clamp(0.0, 1.0);
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
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: catColor.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: catColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timer.category,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: catColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Session Coins preview
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🪙', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            '+${((timer.plannedMinutes * 2) * progress).toInt()} Bloom Coins',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Center Circular Plant Stage with Breathing Halo
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = math.min(constraints.maxWidth * 0.78, constraints.maxHeight * 0.58).clamp(240.0, 320.0);
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Circular Ring with Growing Tree inside
                        SizedBox(
                          width: size,
                          height: size,
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final pulse = isPaused ? 0.0 : _pulseController.value;
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Ambient Glow
                                  Container(
                                    width: size * 0.88,
                                    height: size * 0.88,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          catColor.withValues(alpha: 0.12 + pulse * 0.08),
                                          AppColors.primary.withValues(alpha: 0.05 + pulse * 0.05),
                                          Colors.transparent,
                                        ],
                                        stops: const [0.3, 0.7, 1.0],
                                      ),
                                    ),
                                  ),

                                  // Glowing Circular Progress Arc
                                  CustomPaint(
                                    size: Size(size, size),
                                    painter: _FocusProgressPainter(
                                      progress: progress,
                                      color: catColor,
                                      pulse: pulse,
                                    ),
                                  ),

                                  // Plant Widget in Center
                                  if (plantType != null)
                                    Padding(
                                      padding: const EdgeInsets.all(28.0),
                                      child: PlantWidget(
                                        plantType: plantType,
                                        progress: progress,
                                        size: size * 0.55,
                                      ),
                                    ),

                                  // Paused overlay badge
                                  if (isPaused)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.75),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: AppColors.warning),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.pause, color: AppColors.warning, size: 16),
                                          SizedBox(width: 6),
                                          Text(
                                            'PAUSED',
                                            style: TextStyle(
                                              fontFamily: 'Nunito',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.warning,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Timer Countdown
                        Text(
                          _formatTime(remaining),
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 60,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -1.5,
                            height: 1.0,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Progress percentage badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${(progress * 100).toInt()}% Grown',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Motivational Message
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: Text(
                              isPaused
                                  ? 'Take a breath. Press resume when you are ready!'
                                  : _getMotivationalMessage(progress),
                              key: ValueKey(isPaused ? 'paused' : progress.toStringAsFixed(1)),
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Bottom Control Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    // Pause/Resume Button
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
                        label: Text(
                          isPaused ? 'Resume Focus' : 'Pause Focus',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPaused ? AppColors.primary : AppColors.surfaceVariant,
                          foregroundColor: isPaused ? Colors.white : AppColors.textPrimary,
                          elevation: isPaused ? 4 : 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                              color: isPaused
                                  ? AppColors.primaryLight.withValues(alpha: 0.5)
                                  : AppColors.surfaceBorder,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Give Up / End Session
                    TextButton(
                      onPressed: _handleEnd,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.close_rounded, size: 16, color: AppColors.error.withValues(alpha: 0.8)),
                          const SizedBox(width: 6),
                          Text(
                            'End Session Early',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
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
    if (progress < 0.2) return '🌱 Stay focused. Your seed is taking deep root...';
    if (progress < 0.4) return '🌿 A fresh green sapling emerges into the sunlight!';
    if (progress < 0.6) return '🌳 Branches are reaching high! You are halfway there!';
    if (progress < 0.8) return '🍃 Vibrant leaves are flourishing across the canopy!';
    if (progress < 1.0) return '✨ Almost fully grown! Hold onto your focus for the final stretch!';
    return '🎉 Masterpiece! Your majestic tree is fully grown!';
  }
}

/// Custom painter for glowing circular timer progress
class _FocusProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double pulse;

  const _FocusProgressPainter({
    required this.progress,
    required this.color,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;

    // Track circle
    final trackPaint = Paint()
      ..color = AppColors.surfaceVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      // Glow under arc
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.25 + pulse * 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        glowPaint,
      );

      // Active arc gradient
      final sweepGradient = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [
          color.withValues(alpha: 0.7),
          color,
          AppColors.primaryLight,
        ],
        stops: const [0.0, 0.6, 1.0],
      );

      final arcPaint = Paint()
        ..shader = sweepGradient.createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FocusProgressPainter old) =>
      old.progress != progress || old.color != color || old.pulse != pulse;
}

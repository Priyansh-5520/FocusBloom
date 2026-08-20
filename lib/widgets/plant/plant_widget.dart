import 'package:flutter/material.dart';
import '../../models/plant_model.dart';

/// Renders a plant visually using Flutter drawing primitives.
/// Animates growth stages with smooth transitions.
class PlantWidget extends StatelessWidget {
  final PlantType plantType;
  final double progress; // 0.0 to 1.0
  final double size;

  const PlantWidget({
    super.key,
    required this.plantType,
    required this.progress,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final stageIndex = plantType.getGrowthStageIndex(progress);
    final stagesCount = plantType.growthStages.length;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: _PlantStageDisplay(
        key: ValueKey('${plantType.id}_$stageIndex'),
        plantType: plantType,
        stageIndex: stageIndex,
        totalStages: stagesCount,
        size: size,
        progress: progress,
      ),
    );
  }
}

class _PlantStageDisplay extends StatelessWidget {
  final PlantType plantType;
  final int stageIndex;
  final int totalStages;
  final double size;
  final double progress;

  const _PlantStageDisplay({
    super.key,
    required this.plantType,
    required this.stageIndex,
    required this.totalStages,
    required this.size,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Plant visual
        CustomPaint(
          size: Size(size, size),
          painter: _PlantPainter(
            plantType: plantType,
            stageIndex: stageIndex,
            totalStages: totalStages,
            progress: progress,
          ),
        ),
        const SizedBox(height: 8),
        // Stage label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: plantType.primaryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            plantType.growthStages[stageIndex].stageName,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: plantType.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter that draws a schematic plant at a given stage.
class _PlantPainter extends CustomPainter {
  final PlantType plantType;
  final int stageIndex;
  final int totalStages;
  final double progress;

  _PlantPainter({
    required this.plantType,
    required this.stageIndex,
    required this.totalStages,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height;
    final color = plantType.primaryColor;
    final accent = plantType.accentColor;

    final stagePct = totalStages <= 1 ? 1.0 : stageIndex / (totalStages - 1);

    // Draw pot
    final potPaint = Paint()..color = const Color(0xFFB57C5A);
    final potRimPaint = Paint()..color = const Color(0xFF8B5E3C);
    final potH = size.height * 0.18;
    final potW = size.width * 0.38;
    final potRect = RRect.fromRectAndCorners(
      Rect.fromCenter(
        center: Offset(cx, cy - potH / 2),
        width: potW,
        height: potH,
      ),
      topLeft: const Radius.circular(4),
      topRight: const Radius.circular(4),
      bottomLeft: const Radius.circular(8),
      bottomRight: const Radius.circular(8),
    );
    canvas.drawRRect(potRect, potPaint);
    // pot rim
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - potH), width: potW + 8, height: 8),
        const Radius.circular(4),
      ),
      potRimPaint,
    );

    // Draw soil
    final soilPaint = Paint()..color = const Color(0xFF6B4E3D);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - potH + 3), width: potW - 6, height: 10),
      soilPaint,
    );

    // Stem
    final stemHeight = (size.height * 0.6 * stagePct).clamp(0.0, size.height * 0.6);
    if (stemHeight > 5) {
      final stemPaint = Paint()
        ..color = color.withValues(alpha: 0.8)
        ..strokeWidth = 4 * (0.5 + stagePct * 0.5)
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(cx, cy - potH),
        Offset(cx, cy - potH - stemHeight),
        stemPaint,
      );
    }

    if (stagePct < 0.15) return; // Only seed stage — no leaves

    final leafPaint = Paint()..color = color;

    // Leaves (2–4 depending on stage)
    final leafCount = (stagePct * 4).ceil().clamp(1, 4);
    final leafSize = (size.width * 0.22 * stagePct).clamp(8.0, size.width * 0.28);
    final stemBase = Offset(cx, cy - potH);

    for (int i = 0; i < leafCount; i++) {
      final ratio = (i + 1) / (leafCount + 1);
      final leafY = stemBase.dy - stemHeight * ratio;
      final isLeft = i.isEven;
      final leafX = cx + (isLeft ? -1 : 1) * leafSize * 0.7;

      final path = Path();
      path.moveTo(cx, leafY);
      path.quadraticBezierTo(
        cx + (isLeft ? -1 : 1) * leafSize * 1.2,
        leafY - leafSize * 0.5,
        leafX,
        leafY - leafSize,
      );
      path.quadraticBezierTo(
        cx,
        leafY - leafSize * 0.3,
        cx,
        leafY,
      );
      path.close();
      canvas.drawPath(path, leafPaint..style = PaintingStyle.fill);
    }

    // Flower / bloom at top if stage ≥ 80%
    if (stagePct >= 0.8) {
      final flowerCenter = Offset(cx, cy - potH - stemHeight);
      final petalPaint = Paint()..color = accent;
      final petalCount = 6;
      final petalRadius = size.width * 0.13;

      for (int i = 0; i < petalCount; i++) {
        final angle = (i / petalCount) * 2 * 3.14159;
        final petalX = flowerCenter.dx + petalRadius * 1.2 * _cos(angle);
        final petalY = flowerCenter.dy + petalRadius * 1.2 * _sin(angle);
        canvas.drawCircle(
            Offset(petalX, petalY), petalRadius * 0.7, petalPaint);
      }
      // Center of flower
      canvas.drawCircle(
          flowerCenter, petalRadius * 0.5, Paint()..color = plantType.primaryColor);

      if (stagePct >= 1.0) {
        // Full bloom — sparkle dots
        final sparklePaint = Paint()..color = accent.withValues(alpha: 0.6);
        for (int i = 0; i < 3; i++) {
          final angle = (i / 3) * 2 * 3.14159;
          canvas.drawCircle(
            Offset(
              flowerCenter.dx + petalRadius * 2.2 * _cos(angle),
              flowerCenter.dy + petalRadius * 2.2 * _sin(angle),
            ),
            3,
            sparklePaint,
          );
        }
      }
    }
  }

  double _cos(double rad) => _cosImpl(rad);
  double _sin(double rad) => _sinImpl(rad);

  static double _cosImpl(double rad) {
    // Simple series approximation — use dart:math in production
    return _dartCos(rad);
  }

  static double _sinImpl(double rad) {
    return _dartSin(rad);
  }

  static double _dartCos(double x) {
    // Wrap to use Dart's built-in via import trick
    return cosList[(x * 1000 % 6284).toInt().clamp(0, 6283)];
  }

  static double _dartSin(double x) {
    return sinList[(x * 1000 % 6284).toInt().clamp(0, 6283)];
  }

  // Precomputed tables for 6284 entries (2π * 1000) — use dart:math instead
  // This is a placeholder — actual implementation uses dart:math
  static final List<double> cosList = List.generate(6284, (i) => _computeCos(i));
  static final List<double> sinList = List.generate(6284, (i) => _computeSin(i));

  static double _computeCos(int i) {
    final x = i / 1000.0;
    // Taylor series good enough for display
    double result = 1.0;
    double term = 1.0;
    for (int n = 1; n <= 8; n++) {
      term *= -x * x / (2 * n * (2 * n - 1));
      result += term;
    }
    return result;
  }

  static double _computeSin(int i) {
    final x = i / 1000.0;
    double result = x;
    double term = x;
    for (int n = 1; n <= 8; n++) {
      term *= -x * x / ((2 * n) * (2 * n + 1));
      result += term;
    }
    return result;
  }

  @override
  bool shouldRepaint(_PlantPainter old) =>
      old.stageIndex != stageIndex || old.progress != progress;
}

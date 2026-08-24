import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/plant_model.dart';

/// Renders a tree visually with authentic species styling, organic branching,
/// lush foliage, and smooth animated growth stages.
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
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: _TreeStageDisplay(
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

class _TreeStageDisplay extends StatelessWidget {
  final PlantType plantType;
  final int stageIndex;
  final int totalStages;
  final double size;
  final double progress;

  const _TreeStageDisplay({
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
        CustomPaint(
          size: Size(size, size),
          painter: _TreePainter(
            plantType: plantType,
            stageIndex: stageIndex,
            totalStages: totalStages,
            progress: progress,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Text(
            plantType.growthStages[stageIndex].stageName,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter that draws authentic trees with rich species details.
class _TreePainter extends CustomPainter {
  final PlantType plantType;
  final int stageIndex;
  final int totalStages;
  final double progress;

  _TreePainter({
    required this.plantType,
    required this.stageIndex,
    required this.totalStages,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final w = size.width;
    final h = size.height;
    final cy = h * 0.92; // ground line

    final stagePct = totalStages <= 1 ? 1.0 : stageIndex / (totalStages - 1);

    // 1. Draw grassy ground mound & soft shadow
    _drawGround(canvas, cx, cy, w, h);

    // 2. Growth stage rendering
    if (stagePct < 0.15) {
      // Seed / Sprout stage in soil
      _drawSeedStage(canvas, cx, cy, w, h);
      return;
    }

    if (stagePct < 0.35) {
      // Small sprouting sapling
      _drawSproutStage(canvas, cx, cy, w, h, stagePct);
      return;
    }

    // Full tree drawing based on tree species
    final species = plantType.id.toLowerCase();

    if (species.contains('palm')) {
      _drawPalmTree(canvas, cx, cy, w, h, stagePct);
    } else if (species.contains('cherry') || species.contains('blossom') || species.contains('sakura')) {
      _drawCherryBlossom(canvas, cx, cy, w, h, stagePct);
    } else if (species.contains('pine') || species.contains('fir') || species.contains('spruce')) {
      _drawConiferTree(canvas, cx, cy, w, h, stagePct, species);
    } else if (species.contains('willow')) {
      _drawWillowTree(canvas, cx, cy, w, h, stagePct);
    } else if (species.contains('birch')) {
      _drawBirchTree(canvas, cx, cy, w, h, stagePct);
    } else if (species.contains('maple')) {
      _drawMapleTree(canvas, cx, cy, w, h, stagePct);
    } else if (species.contains('apple')) {
      _drawAppleTree(canvas, cx, cy, w, h, stagePct);
    } else if (species.contains('redwood')) {
      _drawRedwoodTree(canvas, cx, cy, w, h, stagePct);
    } else if (species.contains('cedar')) {
      _drawCedarTree(canvas, cx, cy, w, h, stagePct);
    } else if (species.contains('elm')) {
      _drawElmTree(canvas, cx, cy, w, h, stagePct);
    } else {
      // Default: Majestic Oak Tree
      _drawOakTree(canvas, cx, cy, w, h, stagePct);
    }
  }

  // =========================================================================
  // GROUND & SEED STAGES
  // =========================================================================

  void _drawGround(Canvas canvas, double cx, double cy, double w, double h) {
    // Soft shadow underneath
    final shadowPaint = Paint()..color = Colors.black.withOpacity(0.18);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 4), width: w * 0.72, height: h * 0.12),
      shadowPaint,
    );

    // Fertile grassy mound
    final moundPaint = Paint()..color = const Color(0xFF4C7B38);
    final moundRect = Rect.fromCenter(center: Offset(cx, cy), width: w * 0.64, height: h * 0.14);
    canvas.drawOval(moundRect, moundPaint);

    // Soil base trim
    final soilPaint = Paint()..color = const Color(0xFF5D4037);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 3), width: w * 0.52, height: h * 0.08),
      soilPaint,
    );

    // Subtle grass blades
    final grassPaint = Paint()
      ..color = const Color(0xFF7CB342)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(cx - w * 0.18, cy - 2), Offset(cx - w * 0.22, cy - 8), grassPaint);
    canvas.drawLine(Offset(cx - w * 0.14, cy - 1), Offset(cx - w * 0.15, cy - 9), grassPaint);
    canvas.drawLine(Offset(cx + w * 0.16, cy - 2), Offset(cx + w * 0.20, cy - 8), grassPaint);
    canvas.drawLine(Offset(cx + w * 0.12, cy - 1), Offset(cx + w * 0.13, cy - 9), grassPaint);
  }

  void _drawSeedStage(Canvas canvas, double cx, double cy, double w, double h) {
    // Soil mound center
    final seedPaint = Paint()..color = const Color(0xFF8D6E63);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 2), width: 14, height: 10),
      seedPaint,
    );

    // Tiny green sprout shoot
    final shootPaint = Paint()
      ..color = const Color(0xFF66BB6A)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final shootPath = Path();
    shootPath.moveTo(cx, cy - 2);
    shootPath.quadraticBezierTo(cx + 4, cy - 12, cx + 2, cy - 18);
    canvas.drawPath(shootPath, shootPaint);

    // Baby leaves
    final leafPaint = Paint()..color = const Color(0xFF81C784);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 2, cy - 18), width: 8, height: 5),
      leafPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 6, cy - 17), width: 8, height: 5),
      leafPaint,
    );
  }

  void _drawSproutStage(Canvas canvas, double cx, double cy, double w, double h, double stagePct) {
    final stemH = h * 0.32 * (stagePct / 0.35);

    // Young wooden stem
    final stemPaint = Paint()
      ..color = const Color(0xFF6D4C41)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy), Offset(cx, cy - stemH), stemPaint);

    // Branchlets and leaves
    final leafPaint = Paint()..color = plantType.primaryColor;
    final highlightPaint = Paint()..color = plantType.accentColor;

    canvas.drawCircle(Offset(cx - 10, cy - stemH * 0.7), 9, leafPaint);
    canvas.drawCircle(Offset(cx + 10, cy - stemH * 0.8), 9, leafPaint);
    canvas.drawCircle(Offset(cx, cy - stemH - 4), 13, leafPaint);
    canvas.drawCircle(Offset(cx, cy - stemH - 6), 9, highlightPaint);
  }

  // =========================================================================
  // 1. OAK TREE (🌳 Lush Cloud Foliage, Sturdy Trunk)
  // =========================================================================
  void _drawOakTree(Canvas canvas, double cx, double cy, double w, double h, double stagePct) {
    final scale = 0.55 + (stagePct * 0.45);
    final trunkH = h * 0.46 * scale;
    final trunkW = w * 0.15 * scale;

    // Trunk
    final trunkPath = Path();
    trunkPath.moveTo(cx - trunkW * 0.9, cy);
    trunkPath.quadraticBezierTo(cx - trunkW * 0.4, cy - trunkH * 0.5, cx - trunkW * 0.5, cy - trunkH);
    // Left branch
    trunkPath.lineTo(cx - trunkW * 1.5, cy - trunkH * 1.25);
    trunkPath.lineTo(cx - trunkW * 0.7, cy - trunkH * 1.15);
    // Center-top
    trunkPath.lineTo(cx, cy - trunkH * 1.1);
    // Right branch
    trunkPath.lineTo(cx + trunkW * 1.4, cy - trunkH * 1.25);
    trunkPath.lineTo(cx + trunkW * 0.6, cy - trunkH);
    trunkPath.quadraticBezierTo(cx + trunkW * 0.4, cy - trunkH * 0.5, cx + trunkW * 0.9, cy);
    trunkPath.close();

    final trunkPaint = Paint()..color = const Color(0xFF5C3A21);
    canvas.drawPath(trunkPath, trunkPaint);

    // Trunk bark highlights
    final barkPaint = Paint()
      ..color = const Color(0xFF3E2723)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - 2, cy - 4), Offset(cx - 4, cy - trunkH * 0.8), barkPaint);
    canvas.drawLine(Offset(cx + 3, cy - 6), Offset(cx + 2, cy - trunkH * 0.7), barkPaint);

    // Canopy cloud layers
    final crownCenter = Offset(cx, cy - trunkH * 1.15);
    final baseRadius = w * 0.36 * scale;

    final shadowCanopy = Paint()..color = const Color(0xFF1E4620);
    final mainCanopy = Paint()..color = const Color(0xFF2E6B30);
    final highlightCanopy = Paint()..color = const Color(0xFF4CAF50);
    final brightCanopy = Paint()..color = const Color(0xFF81C784);

    // Darker under-layers
    canvas.drawCircle(crownCenter + Offset(-baseRadius * 0.5, baseRadius * 0.1), baseRadius * 0.55, shadowCanopy);
    canvas.drawCircle(crownCenter + Offset(baseRadius * 0.5, baseRadius * 0.1), baseRadius * 0.55, shadowCanopy);
    canvas.drawCircle(crownCenter + Offset(0, baseRadius * 0.2), baseRadius * 0.65, shadowCanopy);

    // Mid layer clouds
    canvas.drawCircle(crownCenter + Offset(-baseRadius * 0.6, -baseRadius * 0.1), baseRadius * 0.5, mainCanopy);
    canvas.drawCircle(crownCenter + Offset(baseRadius * 0.6, -baseRadius * 0.1), baseRadius * 0.5, mainCanopy);
    canvas.drawCircle(crownCenter + Offset(-baseRadius * 0.3, -baseRadius * 0.5), baseRadius * 0.55, mainCanopy);
    canvas.drawCircle(crownCenter + Offset(baseRadius * 0.3, -baseRadius * 0.5), baseRadius * 0.55, mainCanopy);
    canvas.drawCircle(crownCenter + Offset(0, -baseRadius * 0.6), baseRadius * 0.58, mainCanopy);

    // Sunlit highlights (top & left)
    canvas.drawCircle(crownCenter + Offset(-baseRadius * 0.35, -baseRadius * 0.45), baseRadius * 0.38, highlightCanopy);
    canvas.drawCircle(crownCenter + Offset(baseRadius * 0.25, -baseRadius * 0.55), baseRadius * 0.35, highlightCanopy);
    canvas.drawCircle(crownCenter + Offset(-baseRadius * 0.1, -baseRadius * 0.7), baseRadius * 0.32, brightCanopy);
  }

  // =========================================================================
  // CHERRY BLOSSOM (🌸 Pink Japanese Sakura Canopy & Drifting Petals)
  // =========================================================================
  void _drawCherryBlossom(Canvas canvas, double cx, double cy, double w, double h, double stagePct) {
    final scale = 0.55 + (stagePct * 0.45);
    final trunkH = h * 0.46 * scale;
    final trunkW = w * 0.14 * scale;

    // Dark espresso curved branches
    final trunkPath = Path();
    trunkPath.moveTo(cx - trunkW * 0.8, cy);
    trunkPath.quadraticBezierTo(cx - trunkW * 0.2, cy - trunkH * 0.45, cx - trunkW * 0.3, cy - trunkH * 0.8);
    // Left branch
    trunkPath.lineTo(cx - trunkW * 1.5, cy - trunkH * 1.2);
    trunkPath.lineTo(cx - trunkW * 0.7, cy - trunkH * 1.1);
    // Top center
    trunkPath.lineTo(cx, cy - trunkH * 0.95);
    // Right branch
    trunkPath.lineTo(cx + trunkW * 1.4, cy - trunkH * 1.2);
    trunkPath.lineTo(cx + trunkW * 0.5, cy - trunkH * 0.85);
    trunkPath.quadraticBezierTo(cx + trunkW * 0.3, cy - trunkH * 0.45, cx + trunkW * 0.8, cy);
    trunkPath.close();

    final trunkPaint = Paint()..color = const Color(0xFF3E2723);
    canvas.drawPath(trunkPath, trunkPaint);

    final crownCenter = Offset(cx, cy - trunkH * 1.15);
    final r = w * 0.36 * scale;

    final shadowPink = Paint()..color = const Color(0xFFC2185B);
    final deepPink = Paint()..color = const Color(0xFFE91E63);
    final brightPink = Paint()..color = const Color(0xFFF06292);
    final softBlossom = Paint()..color = const Color(0xFFF8BBD0);
    final petalWhite = Paint()..color = const Color(0xFFFFFFFF);

    // Deep under-blossoms
    canvas.drawCircle(crownCenter + Offset(-r * 0.5, r * 0.05), r * 0.52, shadowPink);
    canvas.drawCircle(crownCenter + Offset(r * 0.5, r * 0.05), r * 0.52, shadowPink);
    canvas.drawCircle(crownCenter + Offset(0, r * 0.1), r * 0.6, shadowPink);

    // Lush pink blossom clouds
    canvas.drawCircle(crownCenter + Offset(-r * 0.6, -r * 0.15), r * 0.48, deepPink);
    canvas.drawCircle(crownCenter + Offset(r * 0.6, -r * 0.15), r * 0.48, deepPink);
    canvas.drawCircle(crownCenter + Offset(0, -r * 0.35), r * 0.58, brightPink);
    canvas.drawCircle(crownCenter + Offset(-r * 0.3, -r * 0.5), r * 0.45, brightPink);
    canvas.drawCircle(crownCenter + Offset(r * 0.3, -r * 0.5), r * 0.45, brightPink);

    // Light sakura highlights
    canvas.drawCircle(crownCenter + Offset(-r * 0.15, -r * 0.6), r * 0.35, softBlossom);
    canvas.drawCircle(crownCenter + Offset(r * 0.2, -r * 0.55), r * 0.32, softBlossom);

    // Delicate flowers & floating petals
    if (stagePct >= 0.6) {
      final flowerOffsets = [
        crownCenter + Offset(-r * 0.35, -r * 0.1),
        crownCenter + Offset(r * 0.3, -r * 0.25),
        crownCenter + Offset(0, -r * 0.5),
        crownCenter + Offset(-r * 0.15, 0),
        crownCenter + Offset(r * 0.35, -r * 0.45),
      ];

      for (final pos in flowerOffsets) {
        canvas.drawCircle(pos, 4.5, softBlossom);
        canvas.drawCircle(pos, 2.0, shadowPink);
        canvas.drawCircle(pos + const Offset(-1, -1), 1.0, petalWhite);
      }

      // Drifting floating petals
      final driftPetal = Paint()..color = const Color(0xFFFF80AB);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx - r * 0.85, cy - trunkH * 0.5), width: 7, height: 4), driftPetal);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx + r * 0.9, cy - trunkH * 0.7), width: 6, height: 3.5), driftPetal);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx + r * 0.75, cy - trunkH * 0.3), width: 6.5, height: 4), softBlossom);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx - r * 0.5, cy - 6), width: 6, height: 3.5), driftPetal);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx + r * 0.4, cy - 4), width: 6.5, height: 4), softBlossom);
    }
  }

  // =========================================================================
  // 2. MAPLE TREE (🍁 Fiery Autumn Gold & Crimson)
  // =========================================================================
  void _drawMapleTree(Canvas canvas, double cx, double cy, double w, double h, double stagePct) {
    final scale = 0.55 + (stagePct * 0.45);
    final trunkH = h * 0.44 * scale;
    final trunkW = w * 0.13 * scale;

    // Dark rustic trunk
    final trunkPaint = Paint()..color = const Color(0xFF4E342E);
    final trunkPath = Path();
    trunkPath.moveTo(cx - trunkW * 0.8, cy);
    trunkPath.quadraticBezierTo(cx - trunkW * 0.3, cy - trunkH * 0.5, cx - trunkW * 0.4, cy - trunkH);
    trunkPath.lineTo(cx - trunkW * 1.3, cy - trunkH * 1.2);
    trunkPath.lineTo(cx, cy - trunkH * 1.05);
    trunkPath.lineTo(cx + trunkW * 1.3, cy - trunkH * 1.2);
    trunkPath.lineTo(cx + trunkW * 0.4, cy - trunkH);
    trunkPath.quadraticBezierTo(cx + trunkW * 0.3, cy - trunkH * 0.5, cx + trunkW * 0.8, cy);
    trunkPath.close();
    canvas.drawPath(trunkPath, trunkPaint);

    final crownCenter = Offset(cx, cy - trunkH * 1.15);
    final r = w * 0.35 * scale;

    final deepCrimson = Paint()..color = const Color(0xFF9E1B1B);
    final fieryRed = Paint()..color = const Color(0xFFD32F2F);
    final orangeAmber = Paint()..color = const Color(0xFFF57C00);
    final goldenYellow = Paint()..color = const Color(0xFFFFB300);

    // Deep under-leaves
    canvas.drawCircle(crownCenter + Offset(-r * 0.5, r * 0.1), r * 0.52, deepCrimson);
    canvas.drawCircle(crownCenter + Offset(r * 0.5, r * 0.1), r * 0.52, deepCrimson);
    canvas.drawCircle(crownCenter + Offset(0, r * 0.15), r * 0.6, deepCrimson);

    // Fiery mid body
    canvas.drawCircle(crownCenter + Offset(-r * 0.6, -r * 0.15), r * 0.48, fieryRed);
    canvas.drawCircle(crownCenter + Offset(r * 0.6, -r * 0.15), r * 0.48, fieryRed);
    canvas.drawCircle(crownCenter + Offset(0, -r * 0.4), r * 0.56, orangeAmber);

    // Golden highlights
    canvas.drawCircle(crownCenter + Offset(-r * 0.3, -r * 0.5), r * 0.38, goldenYellow);
    canvas.drawCircle(crownCenter + Offset(r * 0.3, -r * 0.5), r * 0.35, goldenYellow);
    canvas.drawCircle(crownCenter + Offset(0, -r * 0.65), r * 0.3, goldenYellow);

    // Drifting autumn leaves
    if (stagePct >= 0.8) {
      final leafDot = Paint()..color = const Color(0xFFFF7043);
      canvas.drawCircle(Offset(cx - r * 0.9, cy - trunkH * 0.4), 3.5, leafDot);
      canvas.drawCircle(Offset(cx + r * 0.85, cy - trunkH * 0.6), 3.0, leafDot);
      canvas.drawCircle(Offset(cx + r * 0.7, cy - trunkH * 0.2), 3.0, goldenYellow);
    }
  }

  // =========================================================================
  // 3. CONIFER: PINE / FIR / SPRUCE (🌲 Conical Evergreen Tiers)
  // =========================================================================
  void _drawConiferTree(Canvas canvas, double cx, double cy, double w, double h, double stagePct, String species) {
    final scale = 0.55 + (stagePct * 0.45);
    final treeH = h * 0.78 * scale;
    final treeTop = cy - treeH;

    // Straight pine trunk
    final trunkW = w * 0.09 * scale;
    final trunkPaint = Paint()..color = const Color(0xFF4E342E);
    canvas.drawRect(
      Rect.fromPoints(Offset(cx - trunkW / 2, treeTop + treeH * 0.4), Offset(cx + trunkW / 2, cy)),
      trunkPaint,
    );

    Color darkC, midC, lightC;
    if (species.contains('spruce')) {
      darkC = const Color(0xFF0F3040);
      midC = const Color(0xFF1B4965);
      lightC = const Color(0xFF62B6CB);
    } else if (species.contains('fir')) {
      darkC = const Color(0xFF163824);
      midC = const Color(0xFF2D5A40);
      lightC = const Color(0xFF4E9F70);
    } else {
      // Pine
      darkC = const Color(0xFF1B4332);
      midC = const Color(0xFF2D6A4F);
      lightC = const Color(0xFF52B788);
    }

    final darkPaint = Paint()..color = darkC;
    final midPaint = Paint()..color = midC;
    final lightPaint = Paint()..color = lightC;

    // 4 Conical Tiers from bottom to top
    const tiers = 4;
    for (int i = 0; i < tiers; i++) {
      final tierRatio = i / (tiers - 1); // 0.0 (bottom) to 1.0 (top)
      final tierBaseY = cy - treeH * (0.22 + (1.0 - tierRatio) * 0.58);
      final tierTopY = tierBaseY - treeH * 0.28;
      final tierWidth = w * (0.62 - tierRatio * 0.38) * scale;

      final path = Path();
      path.moveTo(cx, tierTopY);
      path.lineTo(cx - tierWidth / 2, tierBaseY);
      // Serrated / curved bottom edge
      path.quadraticBezierTo(cx - tierWidth * 0.25, tierBaseY - 4, cx, tierBaseY);
      path.quadraticBezierTo(cx + tierWidth * 0.25, tierBaseY - 4, cx + tierWidth / 2, tierBaseY);
      path.close();

      // Base shadow side & light side
      canvas.drawPath(path, darkPaint);

      // Mid body
      final midPath = Path();
      midPath.moveTo(cx, tierTopY);
      midPath.lineTo(cx - tierWidth * 0.45, tierBaseY);
      midPath.quadraticBezierTo(cx - tierWidth * 0.15, tierBaseY - 3, cx + tierWidth * 0.2, tierBaseY);
      midPath.lineTo(cx, tierTopY);
      midPath.close();
      canvas.drawPath(midPath, midPaint);

      // Left sunlit half
      final leftPath = Path();
      leftPath.moveTo(cx, tierTopY);
      leftPath.lineTo(cx - tierWidth / 2, tierBaseY);
      leftPath.quadraticBezierTo(cx - tierWidth * 0.25, tierBaseY - 4, cx, tierBaseY);
      leftPath.lineTo(cx, tierTopY);
      leftPath.close();
      canvas.drawPath(leftPath, lightPaint);
    }
  }

  // =========================================================================
  // 4. BIRCH TREE (🌿 White Bark with Dark Markings, Fluttering Canopy)
  // =========================================================================
  void _drawBirchTree(Canvas canvas, double cx, double cy, double w, double h, double stagePct) {
    final scale = 0.55 + (stagePct * 0.45);
    final trunkH = h * 0.58 * scale;
    final trunkW = w * 0.09 * scale;

    // Birch White Trunk
    final trunkPaint = Paint()..color = const Color(0xFFF5F5F0);
    final trunkPath = Path();
    trunkPath.moveTo(cx - trunkW * 0.7, cy);
    trunkPath.lineTo(cx - trunkW * 0.4, cy - trunkH);
    trunkPath.lineTo(cx + trunkW * 0.4, cy - trunkH);
    trunkPath.lineTo(cx + trunkW * 0.7, cy);
    trunkPath.close();
    canvas.drawPath(trunkPath, trunkPaint);

    // Dark bark notches
    final notchPaint = Paint()
      ..color = const Color(0xFF212121)
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(cx - trunkW * 0.6, cy - trunkH * 0.2), Offset(cx - trunkW * 0.1, cy - trunkH * 0.2), notchPaint);
    canvas.drawLine(Offset(cx + trunkW * 0.1, cy - trunkH * 0.35), Offset(cx + trunkW * 0.5, cy - trunkH * 0.35), notchPaint);
    canvas.drawLine(Offset(cx - trunkW * 0.5, cy - trunkH * 0.5), Offset(cx + trunkW * 0.1, cy - trunkH * 0.5), notchPaint);
    canvas.drawLine(Offset(cx, cy - trunkH * 0.7), Offset(cx + trunkW * 0.4, cy - trunkH * 0.7), notchPaint);

    // Light, airy fluttering canopy
    final crownCenter = Offset(cx, cy - trunkH * 0.95);
    final r = w * 0.32 * scale;

    final darkGreen = Paint()..color = const Color(0xFF33691E);
    final midGreen = Paint()..color = const Color(0xFF689F38);
    final lightGreen = Paint()..color = const Color(0xFF9CCC65);

    canvas.drawOval(Rect.fromCenter(center: crownCenter + Offset(0, r * 0.2), width: r * 1.5, height: r * 1.8), darkGreen);
    canvas.drawOval(Rect.fromCenter(center: crownCenter + Offset(-r * 0.3, -r * 0.2), width: r * 1.2, height: r * 1.4), midGreen);
    canvas.drawOval(Rect.fromCenter(center: crownCenter + Offset(r * 0.3, -r * 0.2), width: r * 1.2, height: r * 1.4), midGreen);
    canvas.drawOval(Rect.fromCenter(center: crownCenter + Offset(0, -r * 0.4), width: r * 1.1, height: r * 1.3), lightGreen);
  }

  // =========================================================================
  // 5. WEEPING WILLOW (🍃 Graceful Cascading Hanging Tendrils)
  // =========================================================================
  void _drawWillowTree(Canvas canvas, double cx, double cy, double w, double h, double stagePct) {
    final scale = 0.55 + (stagePct * 0.45);
    final trunkH = h * 0.45 * scale;
    final trunkW = w * 0.16 * scale;

    // Organic curving trunk
    final trunkPaint = Paint()..color = const Color(0xFF4A3525);
    final trunkPath = Path();
    trunkPath.moveTo(cx - trunkW * 0.8, cy);
    trunkPath.quadraticBezierTo(cx - trunkW * 0.2, cy - trunkH * 0.6, cx, cy - trunkH);
    trunkPath.lineTo(cx + trunkW * 0.3, cy - trunkH);
    trunkPath.quadraticBezierTo(cx + trunkW * 0.5, cy - trunkH * 0.6, cx + trunkW * 0.8, cy);
    trunkPath.close();
    canvas.drawPath(trunkPath, trunkPaint);

    final crownCenter = Offset(cx, cy - trunkH);
    final r = w * 0.38 * scale;

    // Main dome
    final domePaint = Paint()..color = const Color(0xFF33691E);
    canvas.drawOval(
      Rect.fromCenter(center: crownCenter - Offset(0, r * 0.2), width: r * 1.7, height: r * 1.2),
      domePaint,
    );

    // Cascading weeping tendril lines
    final tendrilDark = Paint()
      ..color = const Color(0xFF558B2F)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final tendrilLight = Paint()
      ..color = const Color(0xFF8BC34A)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final tendrils = 9;
    for (int i = 0; i < tendrils; i++) {
      final tX = (cx - r * 0.75) + (i / (tendrils - 1)) * (r * 1.5);
      final hangH = h * (0.35 + (math.sin(i * 1.2).abs() * 0.22)) * scale;
      final startY = crownCenter.dy - r * 0.2;

      final path = Path();
      path.moveTo(tX, startY);
      path.quadraticBezierTo(
        tX + (i.isEven ? 6 : -6),
        startY + hangH * 0.5,
        tX + (i.isEven ? 3 : -3),
        startY + hangH,
      );
      canvas.drawPath(path, i.isEven ? tendrilLight : tendrilDark);
    }
  }

  // =========================================================================
  // 6. APPLE TREE (🍎 Lush Canopy with Ruby Red Apples)
  // =========================================================================
  void _drawAppleTree(Canvas canvas, double cx, double cy, double w, double h, double stagePct) {
    final scale = 0.55 + (stagePct * 0.45);
    final trunkH = h * 0.42 * scale;
    final trunkW = w * 0.14 * scale;

    // Trunk
    final trunkPaint = Paint()..color = const Color(0xFF5D4037);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy - trunkH / 2), width: trunkW, height: trunkH),
      trunkPaint,
    );

    // Canopy
    final crownCenter = Offset(cx, cy - trunkH * 1.1);
    final r = w * 0.34 * scale;

    final darkLeaf = Paint()..color = const Color(0xFF1B5E20);
    final midLeaf = Paint()..color = const Color(0xFF2E7D32);
    final lightLeaf = Paint()..color = const Color(0xFF4CAF50);

    canvas.drawCircle(crownCenter + Offset(-r * 0.4, 0), r * 0.55, darkLeaf);
    canvas.drawCircle(crownCenter + Offset(r * 0.4, 0), r * 0.55, darkLeaf);
    canvas.drawCircle(crownCenter + Offset(0, -r * 0.3), r * 0.65, midLeaf);
    canvas.drawCircle(crownCenter + Offset(-r * 0.2, -r * 0.45), r * 0.4, lightLeaf);

    // Red Apples
    if (stagePct >= 0.6) {
      final applePaint = Paint()..color = const Color(0xFFD32F2F);
      final shinePaint = Paint()..color = Colors.white.withOpacity(0.8);

      final appleOffsets = [
        crownCenter + Offset(-r * 0.35, -r * 0.1),
        crownCenter + Offset(r * 0.3, -r * 0.2),
        crownCenter + Offset(-r * 0.1, -r * 0.45),
        crownCenter + Offset(r * 0.15, 0),
        crownCenter + Offset(-r * 0.3, -r * 0.6),
        crownCenter + Offset(r * 0.35, -r * 0.5),
      ];

      for (final pos in appleOffsets) {
        canvas.drawCircle(pos, 5.0, applePaint);
        canvas.drawCircle(pos + const Offset(-1.5, -1.5), 1.2, shinePaint);
      }
    }
  }

  // =========================================================================
  // 7. TROPICAL PALM (🌴 Segmented Curved Trunk & Breezy Palm Fronds)
  // =========================================================================
  void _drawPalmTree(Canvas canvas, double cx, double cy, double w, double h, double stagePct) {
    final scale = 0.55 + (stagePct * 0.45);
    final trunkH = h * 0.62 * scale;

    // Curved palm trunk
    final trunkPaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..strokeWidth = w * 0.08 * scale
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final trunkPath = Path();
    trunkPath.moveTo(cx, cy);
    trunkPath.quadraticBezierTo(cx + w * 0.08, cy - trunkH * 0.5, cx - w * 0.04, cy - trunkH);
    canvas.drawPath(trunkPath, trunkPaint);

    final topOffset = Offset(cx - w * 0.04, cy - trunkH);

    // Palm fronds (archs radiating out)
    final frondPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final frondLight = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final angles = [-160, -125, -90, -55, -20, 15];
    final frondLen = w * 0.38 * scale;

    for (final deg in angles) {
      final rad = deg * math.pi / 180;
      final dest = topOffset + Offset(math.cos(rad) * frondLen, math.sin(rad) * frondLen + 10);

      final fPath = Path();
      fPath.moveTo(topOffset.dx, topOffset.dy);
      fPath.quadraticBezierTo(
        topOffset.dx + math.cos(rad) * frondLen * 0.6,
        topOffset.dy + math.sin(rad) * frondLen * 0.4 - 10,
        dest.dx,
        dest.dy,
      );
      canvas.drawPath(fPath, deg.abs() > 90 ? frondLight : frondPaint);
    }

    // Coconuts
    final coconutPaint = Paint()..color = const Color(0xFF5D4037);
    canvas.drawCircle(topOffset + const Offset(-4, 4), 5.5, coconutPaint);
    canvas.drawCircle(topOffset + const Offset(4, 5), 5.0, coconutPaint);
  }

  // =========================================================================
  // 8. REDWOOD TREE (🌲 Towering Titan, Stately High Crown)
  // =========================================================================
  void _drawRedwoodTree(Canvas canvas, double cx, double cy, double w, double h, double stagePct) {
    final scale = 0.55 + (stagePct * 0.45);
    final trunkH = h * 0.72 * scale;
    final trunkW = w * 0.16 * scale;

    // Rich Cinnamon-Red Trunk
    final trunkPaint = Paint()..color = const Color(0xFF8D4004);
    final trunkPath = Path();
    trunkPath.moveTo(cx - trunkW * 0.9, cy);
    trunkPath.lineTo(cx - trunkW * 0.3, cy - trunkH);
    trunkPath.lineTo(cx + trunkW * 0.3, cy - trunkH);
    trunkPath.lineTo(cx + trunkW * 0.9, cy);
    trunkPath.close();
    canvas.drawPath(trunkPath, trunkPaint);

    // Deep high-elevation canopy
    final topCenter = Offset(cx, cy - trunkH);
    final r = w * 0.28 * scale;

    final leafPaint = Paint()..color = const Color(0xFF1B4332);
    final highlight = Paint()..color = const Color(0xFF2D6A4F);

    canvas.drawOval(Rect.fromCenter(center: topCenter, width: r * 1.5, height: r * 1.8), leafPaint);
    canvas.drawOval(Rect.fromCenter(center: topCenter - Offset(0, r * 0.3), width: r * 1.2, height: r * 1.4), highlight);
  }

  // =========================================================================
  // 9. CEDAR & ELM TREES
  // =========================================================================
  void _drawCedarTree(Canvas canvas, double cx, double cy, double w, double h, double stagePct) {
    final scale = 0.55 + (stagePct * 0.45);
    final trunkH = h * 0.5 * scale;
    final trunkW = w * 0.12 * scale;

    final trunkPaint = Paint()..color = const Color(0xFF4E342E);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy - trunkH / 2), width: trunkW, height: trunkH),
      trunkPaint,
    );

    final crownCenter = Offset(cx, cy - trunkH);
    final r = w * 0.36 * scale;

    // Stepped horizontal evergreen plates
    final cedarPaint = Paint()..color = const Color(0xFF2E5A44);
    final lightPaint = Paint()..color = const Color(0xFF52B788);

    canvas.drawOval(Rect.fromCenter(center: crownCenter + Offset(0, r * 0.2), width: r * 1.8, height: r * 0.5), cedarPaint);
    canvas.drawOval(Rect.fromCenter(center: crownCenter - Offset(0, r * 0.1), width: r * 1.5, height: r * 0.45), lightPaint);
    canvas.drawOval(Rect.fromCenter(center: crownCenter - Offset(0, r * 0.4), width: r * 1.1, height: r * 0.4), lightPaint);
  }

  void _drawElmTree(Canvas canvas, double cx, double cy, double w, double h, double stagePct) {
    final scale = 0.55 + (stagePct * 0.45);
    final trunkH = h * 0.45 * scale;
    final trunkW = w * 0.13 * scale;

    final trunkPaint = Paint()..color = const Color(0xFF543D2B);
    final trunkPath = Path();
    trunkPath.moveTo(cx - trunkW * 0.7, cy);
    trunkPath.quadraticBezierTo(cx - trunkW * 0.2, cy - trunkH * 0.5, cx - trunkW * 1.2, cy - trunkH * 1.1);
    trunkPath.lineTo(cx, cy - trunkH * 0.85);
    trunkPath.lineTo(cx + trunkW * 1.2, cy - trunkH * 1.1);
    trunkPath.quadraticBezierTo(cx + trunkW * 0.2, cy - trunkH * 0.5, cx + trunkW * 0.7, cy);
    trunkPath.close();
    canvas.drawPath(trunkPath, trunkPaint);

    final crownCenter = Offset(cx, cy - trunkH * 1.05);
    final r = w * 0.35 * scale;

    final elmDark = Paint()..color = const Color(0xFF2E6B30);
    final elmLight = Paint()..color = const Color(0xFF66BB6A);

    canvas.drawCircle(crownCenter + Offset(-r * 0.5, -r * 0.1), r * 0.45, elmDark);
    canvas.drawCircle(crownCenter + Offset(r * 0.5, -r * 0.1), r * 0.45, elmDark);
    canvas.drawCircle(crownCenter + Offset(0, -r * 0.4), r * 0.55, elmLight);
  }

  @override
  bool shouldRepaint(_TreePainter old) =>
      old.stageIndex != stageIndex ||
      old.progress != progress ||
      old.plantType.id != plantType.id;
}

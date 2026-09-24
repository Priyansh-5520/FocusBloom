import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/user_data_provider.dart';
import '../../constants/plant_data.dart';
import '../../models/plant_model.dart';
import '../../models/focus_session_model.dart';
import '../../widgets/plant/plant_widget.dart';

class GardenScreen extends StatefulWidget {
  const GardenScreen({super.key});

  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen>
    with TickerProviderStateMixin {
  late AnimationController _ambientController;
  late AnimationController _entryController;
  bool _showForestView = true;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = context.watch<UserDataProvider>();
    final plants = userData.plants;
    final sessions = userData.sessions;

    // Build list of trees that have sessions (actually grown)
    final grownPlants = plants.where((p) => p.sessionCount > 0).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF2D5016),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _ForestHeader(
              treeCount: grownPlants.length,
              totalSessions: sessions.length,
              showForest: _showForestView,
              onToggle: () =>
                  setState(() => _showForestView = !_showForestView),
            ),
            // Body
            Expanded(
              child: grownPlants.isEmpty
                  ? _EmptyForestView(entryAnimation: _entryController)
                  : _showForestView
                      ? _ForestSceneView(
                          grownPlants: grownPlants,
                          sessions: sessions,
                          ambientController: _ambientController,
                          entryController: _entryController,
                        )
                      : _GridCollectionView(
                          grownPlants: grownPlants,
                          sessions: sessions,
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// HEADER
// ============================================================================
class _ForestHeader extends StatelessWidget {
  final int treeCount;
  final int totalSessions;
  final bool showForest;
  final VoidCallback onToggle;

  const _ForestHeader({
    required this.treeCount,
    required this.totalSessions,
    required this.showForest,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1B3A0A), Color(0xFF2D5016)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Forest',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      treeCount == 0
                          ? 'Plant your first tree to begin'
                          : '$treeCount tree${treeCount == 1 ? '' : ' species'} · $totalSessions session${totalSessions == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // View toggle
              if (treeCount > 0)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.15), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ToggleButton(
                        icon: Icons.park_rounded,
                        isActive: showForest,
                        onTap: showForest ? null : onToggle,
                      ),
                      _ToggleButton(
                        icon: Icons.grid_view_rounded,
                        isActive: !showForest,
                        onTap: showForest ? onToggle : null,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback? onTap;

  const _ToggleButton({
    required this.icon,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.6)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
        ),
      ),
    );
  }
}

// ============================================================================
// EMPTY FOREST
// ============================================================================
class _EmptyForestView extends StatelessWidget {
  final AnimationController entryAnimation;

  const _EmptyForestView({required this.entryAnimation});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: entryAnimation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Decorative illustration area
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: const Center(
                  child: Text('🌱', style: TextStyle(fontSize: 72)),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Your forest awaits',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Complete focus sessions to grow trees\nand watch your personal forest flourish.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.55),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/focus');
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text(
                  'Plant Your First Tree',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// FOREST SCENE VIEW (Immersive forest landscape)
// ============================================================================
class _ForestSceneView extends StatelessWidget {
  final List<UserPlant> grownPlants;
  final List<FocusSessionModel> sessions;
  final AnimationController ambientController;
  final AnimationController entryController;

  const _ForestSceneView({
    required this.grownPlants,
    required this.sessions,
    required this.ambientController,
    required this.entryController,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        // Generate tree positions that don't overlap
        final positions = _generateTreePositions(
          grownPlants.length,
          width,
          height,
        );

        return FadeTransition(
          opacity: entryController,
          child: Stack(
            children: [
              // Background sky gradient
              Positioned.fill(
                child: CustomPaint(
                  painter: _ForestBackgroundPainter(),
                ),
              ),

              // Ambient floating leaves
              ...List.generate(6, (i) {
                return AnimatedBuilder(
                  animation: ambientController,
                  builder: (context, _) {
                    final t = (ambientController.value + i * 0.166) % 1.0;
                    final x = width * (0.1 + (i * 0.15 % 0.8)) +
                        math.sin(t * math.pi * 2) * 20;
                    final y = -20 + t * (height + 40);
                    final rot = t * math.pi * 4 + i;
                    return Positioned(
                      left: x,
                      top: y,
                      child: Transform.rotate(
                        angle: rot,
                        child: Opacity(
                          opacity: (0.3 + 0.3 * math.sin(t * math.pi)),
                          child: Text(
                            i.isEven ? '🍃' : '🍂',
                            style: TextStyle(fontSize: 14 + (i % 3) * 4.0),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),

              // Ground decorations (grass, rocks, flowers)
              ..._buildGroundDecorations(width, height),

              // Trees placed in the scene
              ...List.generate(grownPlants.length, (i) {
                final plant = grownPlants[i];
                final plantType = PlantData.getById(plant.plantTypeId);
                if (plantType == null) return const SizedBox.shrink();

                final pos = positions[i];
                // Trees further back (higher on screen) are smaller
                final depthScale = 0.6 + (pos.dy / height) * 0.4;
                final treeSize = (70 + depthScale * 50).clamp(70.0, 130.0);

                // Staggered entry animation
                final delay = i / grownPlants.length;
                return Positioned(
                  left: pos.dx - treeSize / 2,
                  top: pos.dy - treeSize * 0.8,
                  child: _AnimatedTreeEntry(
                    delay: delay,
                    entryController: entryController,
                    child: GestureDetector(
                      onTap: () => _showTreeDetails(
                        context,
                        plant,
                        plantType,
                        sessions,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PlantWidget(
                            plantType: plantType,
                            progress: 1.0,
                            size: treeSize,
                          ),
                          // Small shadow
                          Container(
                            width: treeSize * 0.5,
                            height: 6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: Colors.black.withOpacity(0.15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // "Tap a tree" hint if there are trees
              if (grownPlants.isNotEmpty)
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '🌳 Tap a tree to see session details',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  List<Offset> _generateTreePositions(int count, double w, double h) {
    final positions = <Offset>[];
    final rng = math.Random(42); // deterministic seed for consistent layout
    final minDist = w * 0.15;

    for (int i = 0; i < count; i++) {
      Offset pos;
      int attempts = 0;
      do {
        final x = 40.0 + rng.nextDouble() * (w - 80);
        final y = h * 0.2 + rng.nextDouble() * (h * 0.65);
        pos = Offset(x, y);
        attempts++;
      } while (attempts < 50 &&
          positions.any(
              (p) => (p - pos).distance < minDist * (1 - i * 0.02).clamp(0.5, 1)));
      positions.add(pos);
    }

    // Sort by Y so trees in front overlap those in back
    final indexed = List.generate(count, (i) => i);
    indexed.sort((a, b) => positions[a].dy.compareTo(positions[b].dy));

    final sorted = List<Offset>.filled(count, Offset.zero);
    for (int i = 0; i < count; i++) {
      sorted[indexed[i]] = positions[indexed[i]];
    }
    return sorted;
  }

  List<Widget> _buildGroundDecorations(double w, double h) {
    final rng = math.Random(123);
    final decorations = <Widget>[];
    final items = ['🌿', '🪨', '🌻', '🌾', '🍄', '🌼', '🪻'];

    for (int i = 0; i < 15; i++) {
      final x = rng.nextDouble() * w;
      final y = h * 0.3 + rng.nextDouble() * (h * 0.65);
      final item = items[rng.nextInt(items.length)];
      final size = 14.0 + rng.nextDouble() * 10;

      decorations.add(
        Positioned(
          left: x,
          top: y,
          child: Opacity(
            opacity: 0.5 + rng.nextDouble() * 0.3,
            child: Text(item, style: TextStyle(fontSize: size)),
          ),
        ),
      );
    }
    return decorations;
  }

  void _showTreeDetails(
    BuildContext context,
    UserPlant plant,
    PlantType plantType,
    List<FocusSessionModel> sessions,
  ) {
    // Find sessions for this plant type
    final plantSessions = sessions
        .where((s) => s.plantId == plant.plantTypeId)
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _TreeDetailSheet(
        plant: plant,
        plantType: plantType,
        sessions: plantSessions,
      ),
    );
  }
}

// ============================================================================
// ANIMATED TREE ENTRY
// ============================================================================
class _AnimatedTreeEntry extends StatelessWidget {
  final double delay;
  final AnimationController entryController;
  final Widget child;

  const _AnimatedTreeEntry({
    required this.delay,
    required this.entryController,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: entryController,
      builder: (context, _) {
        final progress =
            ((entryController.value - delay) / (1.0 - delay)).clamp(0.0, 1.0);
        final curve = Curves.easeOutBack.transform(progress);
        return Transform.scale(
          scale: curve,
          alignment: Alignment.bottomCenter,
          child: Opacity(
            opacity: progress.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
    );
  }
}

// ============================================================================
// FOREST BACKGROUND PAINTER
// ============================================================================
class _ForestBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Sky gradient
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF87CEEB).withOpacity(0.3),
          const Color(0xFF4A8C3F).withOpacity(0.15),
          const Color(0xFF2D5016),
        ],
        stops: const [0.0, 0.35, 0.6],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // Rolling hills in background
    final hill1 = Paint()..color = const Color(0xFF1E4010).withOpacity(0.5);
    final hill2 = Paint()..color = const Color(0xFF2B5518).withOpacity(0.4);

    final hillPath1 = Path();
    hillPath1.moveTo(0, size.height * 0.35);
    hillPath1.quadraticBezierTo(
      size.width * 0.25, size.height * 0.2,
      size.width * 0.5, size.height * 0.3,
    );
    hillPath1.quadraticBezierTo(
      size.width * 0.75, size.height * 0.4,
      size.width, size.height * 0.28,
    );
    hillPath1.lineTo(size.width, size.height);
    hillPath1.lineTo(0, size.height);
    hillPath1.close();
    canvas.drawPath(hillPath1, hill1);

    final hillPath2 = Path();
    hillPath2.moveTo(0, size.height * 0.45);
    hillPath2.quadraticBezierTo(
      size.width * 0.3, size.height * 0.38,
      size.width * 0.6, size.height * 0.42,
    );
    hillPath2.quadraticBezierTo(
      size.width * 0.85, size.height * 0.46,
      size.width, size.height * 0.4,
    );
    hillPath2.lineTo(size.width, size.height);
    hillPath2.lineTo(0, size.height);
    hillPath2.close();
    canvas.drawPath(hillPath2, hill2);

    // Ground plane
    final groundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF3D6B22),
          const Color(0xFF2D5016),
          const Color(0xFF234012),
        ],
      ).createShader(
          Rect.fromLTWH(0, size.height * 0.5, size.width, size.height * 0.5));
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.5, size.width, size.height * 0.5),
      groundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// GRID COLLECTION VIEW
// ============================================================================
class _GridCollectionView extends StatelessWidget {
  final List<UserPlant> grownPlants;
  final List<FocusSessionModel> sessions;

  const _GridCollectionView({
    required this.grownPlants,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: grownPlants.length,
      itemBuilder: (context, index) {
        final plant = grownPlants[index];
        final plantType = PlantData.getById(plant.plantTypeId);
        if (plantType == null) return const SizedBox.shrink();

        final plantSessions = sessions
            .where((s) => s.plantId == plant.plantTypeId)
            .toList();

        return GestureDetector(
          onTap: () => showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (_) => _TreeDetailSheet(
              plant: plant,
              plantType: plantType,
              sessions: plantSessions,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF3D6B22),
                  const Color(0xFF2D5016),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PlantWidget(
                  plantType: plantType,
                  progress: 1.0,
                  size: 88,
                ),
                const SizedBox(height: 10),
                Text(
                  plantType.name,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: plantType.rarityColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        plantType.rarityLabel,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: plantType.rarityColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '×${plant.sessionCount}',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// TREE DETAIL BOTTOM SHEET
// ============================================================================
class _TreeDetailSheet extends StatelessWidget {
  final UserPlant plant;
  final PlantType plantType;
  final List<FocusSessionModel> sessions;

  const _TreeDetailSheet({
    required this.plant,
    required this.plantType,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    final totalMinutes = sessions.fold<int>(
        0, (sum, s) => sum + (s.actualDuration ~/ 60));
    final totalXP =
        sessions.fold<int>(0, (sum, s) => sum + s.xpEarned);
    final completedCount =
        sessions.where((s) => s.completed).length;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      maxChildSize: 0.85,
      minChildSize: 0.35,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF3D6B22), Color(0xFF1B3A0A)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  children: [
                    // Tree display
                    Center(
                      child: PlantWidget(
                        plantType: plantType,
                        progress: 1.0,
                        size: 120,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        plantType.name,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: plantType.rarityColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: plantType.rarityColor.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          plantType.rarityLabel,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: plantType.rarityColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        plantType.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.6),
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Stats row
                    Row(
                      children: [
                        _DetailStat(
                          emoji: '⏱',
                          value: _formatMinutes(totalMinutes),
                          label: 'Total Focus',
                        ),
                        _DetailStat(
                          emoji: '✅',
                          value: '$completedCount',
                          label: 'Completed',
                        ),
                        _DetailStat(
                          emoji: '⭐',
                          value: '$totalXP',
                          label: 'XP Earned',
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Recent sessions
                    if (sessions.isNotEmpty) ...[
                      Text(
                        'Recent Sessions',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...sessions.take(5).map((s) => _SessionTile(session: s)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
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

class _DetailStat extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _DetailStat({
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final FocusSessionModel session;

  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final minutes = session.actualDuration ~/ 60;
    final date = session.startedAt;
    final dateStr =
        '${date.day}/${date.month}/${date.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: session.completed
                  ? AppColors.success.withValues(alpha: 0.2)
                  : AppColors.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                session.completed
                    ? Icons.check_circle_rounded
                    : Icons.remove_circle_outline,
                color: session.completed ? AppColors.success : AppColors.accent,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.category,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${minutes}m',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                '+${session.xpEarned} XP',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

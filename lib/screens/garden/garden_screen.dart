import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/user_data_provider.dart';
import '../../constants/plant_data.dart';
import '../../widgets/plant/plant_widget.dart';

class GardenScreen extends StatefulWidget {
  const GardenScreen({super.key});

  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = context.watch<UserDataProvider>();
    final plants = userData.plants;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Garden'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Plants'),
            Tab(text: 'Progress'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Plants tab
          plants.isEmpty
              ? _EmptyGarden()
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: plants.length,
                  itemBuilder: (context, index) {
                    final plant = plants[index];
                    final plantType = PlantData.getById(plant.plantTypeId);
                    if (plantType == null) return const SizedBox.shrink();

                    return _PlantCard(
                      plantType: plantType,
                      plant: plant,
                    );
                  },
                ),

          // Progress tab
          _ProductivityProgressView(),
        ],
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  final plantType;
  final plant;

  const _PlantCard({required this.plantType, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEBE5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PlantWidget(
            plantType: plantType,
            progress: 1.0,
            size: 90,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              plantType.name,
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${plant.sessionCount} session${plant.sessionCount == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: plantType.rarityColor.withOpacity(0.1),
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
        ],
      ),
    );
  }
}

class _EmptyGarden extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🌱', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('Your garden is empty', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Complete a focus session to grow your first plant!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProductivityProgressView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userData = context.watch<UserDataProvider>();
    final sessions = userData.sessions;

    // Group sessions by week day
    final Map<String, int> dayMap = {
      'Mon': 0, 'Tue': 0, 'Wed': 0, 'Thu': 0, 'Fri': 0, 'Sat': 0, 'Sun': 0,
    };
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    for (final s in sessions) {
      if (s.startedAt.isAfter(weekStart.subtract(const Duration(days: 1)))) {
        final dayIdx = s.startedAt.weekday - 1;
        final dayName = dayNames[dayIdx];
        dayMap[dayName] = (dayMap[dayName] ?? 0) + (s.actualDuration ~/ 60);
      }
    }

    final maxMinutes = dayMap.values.fold(0, (a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This Week', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),

          // Bar chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: const Border.fromBorderSide(BorderSide(color: Color(0xFFEEEBE5))),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 120,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: dayNames.map((day) {
                      final minutes = dayMap[day] ?? 0;
                      final barHeight = maxMinutes > 0 ? (minutes / maxMinutes) * 100 : 0.0;
                      final isToday = day == dayNames[(now.weekday - 1).clamp(0, 6)];

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (minutes > 0)
                            Text(
                              '${minutes}m',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          const SizedBox(height: 4),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            width: 28,
                            height: barHeight + 4,
                            decoration: BoxDecoration(
                              color: isToday
                                  ? AppColors.primary
                                  : AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: dayNames.map((day) {
                    final isToday = day == dayNames[(now.weekday - 1).clamp(0, 6)];
                    return Text(
                      day,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                        color: isToday ? AppColors.primary : AppColors.textSecondary,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Text('Recent Sessions Garden', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),

          // Simple session grid — last 30 sessions as plant emojis
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sessions.take(30).map((s) {
              final pt = PlantData.getById(s.plantId);
              return Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (s.completed ? AppColors.primaryContainer : AppColors.surfaceVariant),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: s.completed ? AppColors.primary.withOpacity(0.3) : Colors.transparent,
                  ),
                ),
                child: Center(
                  child: Text(
                    pt?.emoji ?? '🌱',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

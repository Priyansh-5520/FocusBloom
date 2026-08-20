import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/user_data_provider.dart';
import '../../models/focus_session_model.dart';
import '../../constants/plant_data.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filterCategory = 'All';
  String _filterStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final userData = context.watch<UserDataProvider>();
    var sessions = userData.sessions;

    // Apply filters
    if (_filterCategory != 'All') {
      sessions = sessions.where((s) => s.category == _filterCategory).toList();
    }
    if (_filterStatus == 'Completed') {
      sessions = sessions.where((s) => s.completed).toList();
    } else if (_filterStatus == 'Abandoned') {
      sessions = sessions.where((s) => !s.completed).toList();
    }

    // Group by date
    final Map<String, List<FocusSessionModel>> grouped = {};
    for (final session in sessions) {
      final dateKey = _dateLabel(session.startedAt);
      grouped.putIfAbsent(dateKey, () => []).add(session);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Focus History'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Status filter
                ...[('All', 'All'), ('Done', 'Completed'), ('Quit', 'Abandoned')].map(
                  (pair) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(pair.$1),
                      selected: _filterStatus == pair.$2,
                      onSelected: (_) => setState(() => _filterStatus = pair.$2),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const VerticalDivider(width: 1),
                const SizedBox(width: 8),
                // Category filter
                ...['All', 'Study', 'Coding', 'Work', 'Reading'].map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: _filterCategory == cat,
                      onSelected: (_) => setState(() => _filterCategory = cat),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: sessions.isEmpty
          ? const _EmptyHistory()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: grouped.keys.length,
              itemBuilder: (context, index) {
                final dateKey = grouped.keys.elementAt(index);
                final daySessions = grouped[dateKey]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        dateKey,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                    ...daySessions.map((s) => _SessionCard(session: s)),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
    );
  }

  String _dateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dt.year, dt.month, dt.day);

    if (date == today) return 'Today';
    if (date == yesterday) return 'Yesterday';
    return DateFormat('MMMM d, yyyy').format(dt);
  }
}

class _SessionCard extends StatelessWidget {
  final FocusSessionModel session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final plantType = PlantData.getById(session.plantId);
    final catColor = AppColors.categoryColors[session.category] ?? AppColors.primary;
    final timeStr = DateFormat('h:mm a').format(session.startedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEBE5)),
      ),
      child: Row(
        children: [
          // Plant emoji
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: catColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                plantType?.emoji ?? '🌱',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(session.category, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: session.completed
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        session.completed ? 'Done' : 'Quit',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: session.completed ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${plantType?.name ?? "Plant"} · ${session.duration}m planned · $timeStr',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${session.xpEarned} XP',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '+${session.coinsEarned} 🪙',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📋', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('No sessions yet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Complete a focus session to see your history.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

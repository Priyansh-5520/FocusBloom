import 'package:cloud_firestore/cloud_firestore.dart';

/// A single focus session record stored in Firestore.
class FocusSessionModel {
  final String id;
  final int duration; // planned duration in minutes
  final int actualDuration; // actual seconds focused
  final String category;
  final String plantId;
  final bool completed;
  final int xpEarned;
  final int coinsEarned;
  final DateTime startedAt;
  final DateTime? completedAt;

  const FocusSessionModel({
    required this.id,
    required this.duration,
    required this.actualDuration,
    required this.category,
    required this.plantId,
    required this.completed,
    required this.xpEarned,
    required this.coinsEarned,
    required this.startedAt,
    this.completedAt,
  });

  /// Completion percentage (0.0 – 1.0)
  double get completionPercent {
    if (duration <= 0) return 0;
    return (actualDuration / 60) / duration;
  }

  factory FocusSessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FocusSessionModel(
      id: doc.id,
      duration: data['duration'] ?? 0,
      actualDuration: data['actualDuration'] ?? 0,
      category: data['category'] ?? '',
      plantId: data['plantId'] ?? '',
      completed: data['completed'] ?? false,
      xpEarned: data['xpEarned'] ?? 0,
      coinsEarned: data['coinsEarned'] ?? 0,
      startedAt: (data['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'duration': duration,
      'actualDuration': actualDuration,
      'category': category,
      'plantId': plantId,
      'completed': completed,
      'xpEarned': xpEarned,
      'coinsEarned': coinsEarned,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
}

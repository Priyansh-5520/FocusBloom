import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a FocusBloom user profile stored in Firestore.
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final int totalXP;
  final int level;
  final int totalFocusMinutes;
  final int totalSessions;
  final int currentStreak;
  final int longestStreak;
  final int coins;
  final int dailyGoalMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastFocusDate; // 'yyyy-MM-dd' for streak tracking

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.totalXP = 0,
    this.level = 1,
    this.totalFocusMinutes = 0,
    this.totalSessions = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.coins = 0,
    this.dailyGoalMinutes = 60,
    required this.createdAt,
    required this.updatedAt,
    this.lastFocusDate,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      totalXP: data['totalXP'] ?? 0,
      level: data['level'] ?? 1,
      totalFocusMinutes: data['totalFocusMinutes'] ?? 0,
      totalSessions: data['totalSessions'] ?? 0,
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      coins: data['coins'] ?? 0,
      dailyGoalMinutes: data['dailyGoalMinutes'] ?? 60,
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? DateTime.tryParse(data['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      lastFocusDate: data['lastFocusDate'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'totalXP': totalXP,
      'level': level,
      'totalFocusMinutes': totalFocusMinutes,
      'totalSessions': totalSessions,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'coins': coins,
      'dailyGoalMinutes': dailyGoalMinutes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastFocusDate': lastFocusDate,
    };
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      totalXP: data['totalXP'] ?? 0,
      level: data['level'] ?? 1,
      totalFocusMinutes: data['totalFocusMinutes'] ?? 0,
      totalSessions: data['totalSessions'] ?? 0,
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      coins: data['coins'] ?? 0,
      dailyGoalMinutes: data['dailyGoalMinutes'] ?? 60,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastFocusDate: data['lastFocusDate'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'totalXP': totalXP,
      'level': level,
      'totalFocusMinutes': totalFocusMinutes,
      'totalSessions': totalSessions,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'coins': coins,
      'dailyGoalMinutes': dailyGoalMinutes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastFocusDate': lastFocusDate,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? photoUrl,
    int? totalXP,
    int? level,
    int? totalFocusMinutes,
    int? totalSessions,
    int? currentStreak,
    int? longestStreak,
    int? coins,
    int? dailyGoalMinutes,
    DateTime? updatedAt,
    String? lastFocusDate,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      totalXP: totalXP ?? this.totalXP,
      level: level ?? this.level,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
      totalSessions: totalSessions ?? this.totalSessions,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      coins: coins ?? this.coins,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastFocusDate: lastFocusDate ?? this.lastFocusDate,
    );
  }
}

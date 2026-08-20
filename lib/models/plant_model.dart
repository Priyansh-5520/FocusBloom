import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Plant rarity levels
enum PlantRarity { common, uncommon, rare, epic, legendary }

/// A type definition for all plant templates — does NOT live in Firestore.
class PlantType {
  final String id;
  final String name;
  final String description;
  final PlantRarity rarity;
  final int price; // Bloom Coins to unlock
  final int requiredLevel; // minimum level to purchase
  final List<String> categories; // suggested focus categories
  final List<PlantGrowthStage> growthStages;
  final Color primaryColor;
  final Color accentColor;
  final String emoji; // fallback visual

  const PlantType({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.price,
    required this.requiredLevel,
    required this.categories,
    required this.growthStages,
    required this.primaryColor,
    required this.accentColor,
    required this.emoji,
  });

  Color get rarityColor {
    switch (rarity) {
      case PlantRarity.common:
        return AppColors.rarityCommon;
      case PlantRarity.uncommon:
        return AppColors.rarityUncommon;
      case PlantRarity.rare:
        return AppColors.rarityRare;
      case PlantRarity.epic:
        return AppColors.rarityEpic;
      case PlantRarity.legendary:
        return AppColors.rarityLegendary;
    }
  }

  String get rarityLabel {
    switch (rarity) {
      case PlantRarity.common: return 'Common';
      case PlantRarity.uncommon: return 'Uncommon';
      case PlantRarity.rare: return 'Rare';
      case PlantRarity.epic: return 'Epic';
      case PlantRarity.legendary: return 'Legendary';
    }
  }

  /// Get the growth stage index based on session completion progress (0.0-1.0)
  int getGrowthStageIndex(double progress) {
    if (growthStages.isEmpty) return 0;
    final idx = (progress * growthStages.length).floor();
    return idx.clamp(0, growthStages.length - 1);
  }
}

/// A single visual growth stage for a plant
class PlantGrowthStage {
  final String stageName;
  final String description;
  final double minProgress; // 0.0 to 1.0

  const PlantGrowthStage({
    required this.stageName,
    required this.description,
    required this.minProgress,
  });
}

/// A user-owned plant instance stored in Firestore (users/{uid}/plants/{plantId})
class UserPlant {
  final String id; // Firestore doc ID = plantTypeId
  final String plantTypeId;
  final int growthXP;
  final int growthStage;
  final DateTime unlockedAt;
  final DateTime lastUpdated;
  final int sessionCount; // how many sessions contributed

  const UserPlant({
    required this.id,
    required this.plantTypeId,
    this.growthXP = 0,
    this.growthStage = 0,
    required this.unlockedAt,
    required this.lastUpdated,
    this.sessionCount = 0,
  });

  factory UserPlant.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserPlant(
      id: doc.id,
      plantTypeId: data['plantTypeId'] ?? doc.id,
      growthXP: data['growthXP'] ?? 0,
      growthStage: data['growthStage'] ?? 0,
      unlockedAt: (data['unlockedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sessionCount: data['sessionCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'plantTypeId': plantTypeId,
      'growthXP': growthXP,
      'growthStage': growthStage,
      'unlockedAt': Timestamp.fromDate(unlockedAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'sessionCount': sessionCount,
    };
  }

  UserPlant copyWith({
    int? growthXP,
    int? growthStage,
    DateTime? lastUpdated,
    int? sessionCount,
  }) {
    return UserPlant(
      id: id,
      plantTypeId: plantTypeId,
      growthXP: growthXP ?? this.growthXP,
      growthStage: growthStage ?? this.growthStage,
      unlockedAt: unlockedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      sessionCount: sessionCount ?? this.sessionCount,
    );
  }
}

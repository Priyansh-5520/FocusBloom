import 'package:flutter/material.dart';
import '../models/plant_model.dart';

/// Static definitions for all 12 plant types available in FocusBloom.
class PlantData {
  PlantData._();

  static const List<PlantGrowthStage> _standardStages = [
    PlantGrowthStage(stageName: 'Seed', description: 'Just getting started...', minProgress: 0.0),
    PlantGrowthStage(stageName: 'Sprout', description: 'Something is growing!', minProgress: 0.2),
    PlantGrowthStage(stageName: 'Seedling', description: 'Looking good, keep going!', minProgress: 0.4),
    PlantGrowthStage(stageName: 'Young Plant', description: 'Halfway there!', minProgress: 0.6),
    PlantGrowthStage(stageName: 'Blooming', description: 'Almost there!', minProgress: 0.8),
    PlantGrowthStage(stageName: 'Full Bloom', description: 'Beautiful!', minProgress: 1.0),
  ];

  static final List<PlantType> allPlants = [
    PlantType(
      id: 'focus_fern',
      name: 'Focus Fern',
      description: 'A resilient fern that thrives with consistent attention. Perfect for any focus session.',
      rarity: PlantRarity.common,
      price: 0,
      requiredLevel: 1,
      categories: ['Work', 'Study', 'Other'],
      growthStages: _standardStages,
      primaryColor: const Color(0xFF4A8C6F),
      accentColor: const Color(0xFF6DB490),
      emoji: '🌿',
    ),
    PlantType(
      id: 'study_sakura',
      name: 'Study Sakura',
      description: 'A delicate cherry blossom that blooms with the dedication of a diligent learner.',
      rarity: PlantRarity.uncommon,
      price: 60,
      requiredLevel: 2,
      categories: ['Study', 'Reading'],
      growthStages: _standardStages,
      primaryColor: const Color(0xFFE8A0BF),
      accentColor: const Color(0xFFF7C5DD),
      emoji: '🌸',
    ),
    PlantType(
      id: 'code_cactus',
      name: 'Code Cactus',
      description: 'Tough, low maintenance, and endures long focused coding sessions without complaint.',
      rarity: PlantRarity.uncommon,
      price: 80,
      requiredLevel: 2,
      categories: ['Coding', 'Work'],
      growthStages: _standardStages,
      primaryColor: const Color(0xFF00BFA5),
      accentColor: const Color(0xFF64FFDA),
      emoji: '🌵',
    ),
    PlantType(
      id: 'writers_willow',
      name: "Writer's Willow",
      description: 'A graceful willow whose flowing branches mirror the flow of creative writing.',
      rarity: PlantRarity.rare,
      price: 120,
      requiredLevel: 3,
      categories: ['Writing', 'Creative'],
      growthStages: _standardStages,
      primaryColor: const Color(0xFF8BC34A),
      accentColor: const Color(0xFFCCFF90),
      emoji: '🌳',
    ),
    PlantType(
      id: 'readers_rose',
      name: "Reader's Rose",
      description: 'A timeless rose that blossoms with every page turned in quiet contemplation.',
      rarity: PlantRarity.rare,
      price: 150,
      requiredLevel: 4,
      categories: ['Reading', 'Study'],
      growthStages: _standardStages,
      primaryColor: const Color(0xFFE53935),
      accentColor: const Color(0xFFFF8A80),
      emoji: '🌹',
    ),
    PlantType(
      id: 'energy_palm',
      name: 'Energy Palm',
      description: 'A vibrant tropical palm that surges with the energy of physical activity.',
      rarity: PlantRarity.uncommon,
      price: 100,
      requiredLevel: 3,
      categories: ['Exercise', 'Social'],
      growthStages: _standardStages,
      primaryColor: const Color(0xFFFF6B35),
      accentColor: const Color(0xFFFFD180),
      emoji: '🌴',
    ),
    PlantType(
      id: 'creative_bloom',
      name: 'Creative Bloom',
      description: 'A vivid wildflower that unfurls its petals with every burst of creative inspiration.',
      rarity: PlantRarity.epic,
      price: 200,
      requiredLevel: 5,
      categories: ['Creative', 'Writing', 'Entertainment'],
      growthStages: _standardStages,
      primaryColor: const Color(0xFFE91E8C),
      accentColor: const Color(0xFFF48FB1),
      emoji: '🌺',
    ),
    PlantType(
      id: 'calm_bamboo',
      name: 'Calm Bamboo',
      description: 'Steady, flexible, and enduring. Grows tall with mindful rest and peaceful focus.',
      rarity: PlantRarity.common,
      price: 40,
      requiredLevel: 1,
      categories: ['Rest', 'Social'],
      growthStages: _standardStages,
      primaryColor: const Color(0xFF8BC34A),
      accentColor: const Color(0xFFC5E1A5),
      emoji: '🎋',
    ),
    PlantType(
      id: 'productivity_tree',
      name: 'Productivity Tree',
      description: 'An ancient oak that grows mightier with every completed work session.',
      rarity: PlantRarity.epic,
      price: 300,
      requiredLevel: 7,
      categories: ['Work', 'Coding', 'Study'],
      growthStages: _standardStages,
      primaryColor: const Color(0xFF4E342E),
      accentColor: const Color(0xFF6D4C41),
      emoji: '🌲',
    ),
    PlantType(
      id: 'night_flower',
      name: 'Night Flower',
      description: 'A mysterious blossom that thrives in the late hours of deep concentration.',
      rarity: PlantRarity.legendary,
      price: 500,
      requiredLevel: 10,
      categories: ['Study', 'Creative', 'Writing'],
      growthStages: _standardStages,
      primaryColor: const Color(0xFF7C4DFF),
      accentColor: const Color(0xFFB39DDB),
      emoji: '🌙',
    ),
    PlantType(
      id: 'sunshine_sunflower',
      name: 'Sunshine Sunflower',
      description: 'Always faces the light. A cheerful companion for morning focus sessions.',
      rarity: PlantRarity.common,
      price: 50,
      requiredLevel: 1,
      categories: ['Work', 'Exercise', 'Other'],
      growthStages: _standardStages,
      primaryColor: const Color(0xFFFFB300),
      accentColor: const Color(0xFFFFE082),
      emoji: '🌻',
    ),
    PlantType(
      id: 'zen_lotus',
      name: 'Zen Lotus',
      description: 'A sacred lotus that rises immaculate from the mud. Patience is its superpower.',
      rarity: PlantRarity.legendary,
      price: 600,
      requiredLevel: 12,
      categories: ['Rest', 'Reading', 'Study'],
      growthStages: _standardStages,
      primaryColor: const Color(0xFFE040FB),
      accentColor: const Color(0xFFEA80FC),
      emoji: '🪷',
    ),
  ];

  static PlantType? getById(String id) {
    try {
      return allPlants.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Plants unlocked by default (no purchase required)
  static List<PlantType> get defaultUnlocked =>
      allPlants.where((p) => p.price == 0).toList();
}

import 'package:flutter/material.dart';
import '../models/plant_model.dart';

/// Static definitions for all tree types available in FocusBloom.
class PlantData {
  PlantData._();

  static const List<PlantGrowthStage> standardStages = [
    PlantGrowthStage(stageName: 'Seed', description: 'Just planted in fertile soil...', minProgress: 0.0),
    PlantGrowthStage(stageName: 'Sprout', description: 'A tender sprout emerges!', minProgress: 0.2),
    PlantGrowthStage(stageName: 'Sapling', description: 'Growing sturdy branches...', minProgress: 0.4),
    PlantGrowthStage(stageName: 'Young Tree', description: 'Branches spreading wide!', minProgress: 0.6),
    PlantGrowthStage(stageName: 'Flourishing', description: 'Rich foliage filling out!', minProgress: 0.8),
    PlantGrowthStage(stageName: 'Grand Tree', description: 'Majestic and fully grown!', minProgress: 1.0),
  ];

  static final List<PlantType> allPlants = [
    PlantType(
      id: 'oak',
      name: 'Oak',
      description: 'A symbol of strength and wisdom. The mighty oak flourishes with steady, deep concentration.',
      rarity: PlantRarity.common,
      price: 0,
      requiredLevel: 1,
      categories: ['Work', 'Study', 'Coding', 'Other'],
      growthStages: standardStages,
      primaryColor: const Color(0xFF438945),
      accentColor: const Color(0xFF2E6330),
      emoji: '🌳',
    ),
    PlantType(
      id: 'cherry_blossom',
      name: 'Cherry Blossom',
      description: 'A breathtaking Japanese Sakura tree with delicate, blooming pink petals that drift gracefully.',
      rarity: PlantRarity.rare,
      price: 0,
      requiredLevel: 1,
      categories: ['Creative', 'Study', 'Reading', 'Writing'],
      growthStages: standardStages,
      primaryColor: const Color(0xFFF48FB1),
      accentColor: const Color(0xFFEC407A),
      emoji: '🌸',
    ),
    PlantType(
      id: 'maple',
      name: 'Maple',
      description: 'Radiant with warm gold and fiery crimson leaves. Inspires passion and creative energy.',
      rarity: PlantRarity.uncommon,
      price: 0,
      requiredLevel: 1,
      categories: ['Creative', 'Writing', 'Study'],
      growthStages: standardStages,
      primaryColor: const Color(0xFFE25822),
      accentColor: const Color(0xFFF39C12),
      emoji: '🍁',
    ),
    PlantType(
      id: 'pine',
      name: 'Pine',
      description: 'A crisp evergreen standing tall through any season. Endures long focused sessions.',
      rarity: PlantRarity.common,
      price: 0,
      requiredLevel: 1,
      categories: ['Coding', 'Work'],
      growthStages: standardStages,
      primaryColor: const Color(0xFF2D6A4F),
      accentColor: const Color(0xFF52B788),
      emoji: '🌲',
    ),
    PlantType(
      id: 'birch',
      name: 'Birch',
      description: 'Graceful with distinctive white bark and dancing light leaves. Brings clarity and calm.',
      rarity: PlantRarity.uncommon,
      price: 0,
      requiredLevel: 1,
      categories: ['Reading', 'Writing'],
      growthStages: standardStages,
      primaryColor: const Color(0xFF7CB342),
      accentColor: const Color(0xFFAED581),
      emoji: '🌿',
    ),
    PlantType(
      id: 'willow',
      name: 'Willow',
      description: 'Cascading emerald tendrils that flow like pure creative thought in deep stillness.',
      rarity: PlantRarity.rare,
      price: 0,
      requiredLevel: 1,
      categories: ['Creative', 'Rest', 'Writing'],
      growthStages: standardStages,
      primaryColor: const Color(0xFF558B2F),
      accentColor: const Color(0xFF9CCC65),
      emoji: '🍃',
    ),
    PlantType(
      id: 'spruce',
      name: 'Spruce',
      description: 'Majestic mountain conifer with cool, silver-tinted evergreen needles.',
      rarity: PlantRarity.rare,
      price: 0,
      requiredLevel: 1,
      categories: ['Coding', 'Study'],
      growthStages: standardStages,
      primaryColor: const Color(0xFF1B4965),
      accentColor: const Color(0xFF62B6CB),
      emoji: '🎄',
    ),
    PlantType(
      id: 'apple',
      name: 'Apple',
      description: 'A bountiful orchard tree bearing bright, delicious red apples as the fruits of your focus.',
      rarity: PlantRarity.uncommon,
      price: 0,
      requiredLevel: 1,
      categories: ['Study', 'Work', 'Reading'],
      growthStages: standardStages,
      primaryColor: const Color(0xFF388E3C),
      accentColor: const Color(0xFFE53935),
      emoji: '🍎',
    ),
    PlantType(
      id: 'palm',
      name: 'Palm',
      description: 'Vibrant tropical palm with graceful curved trunk and breezy fronds for refreshing sessions.',
      rarity: PlantRarity.uncommon,
      price: 0,
      requiredLevel: 1,
      categories: ['Exercise', 'Social', 'Rest'],
      growthStages: standardStages,
      primaryColor: const Color(0xFF2E7D32),
      accentColor: const Color(0xFFFFB74D),
      emoji: '🌴',
    ),
    PlantType(
      id: 'elm',
      name: 'Elm',
      description: 'A grand vase-shaped spreading canopy providing shelter and deep serene focus.',
      rarity: PlantRarity.rare,
      price: 0,
      requiredLevel: 1,
      categories: ['Work', 'Reading'],
      growthStages: standardStages,
      primaryColor: const Color(0xFF4E8752),
      accentColor: const Color(0xFF81C784),
      emoji: '🌳',
    ),
    PlantType(
      id: 'fir',
      name: 'Fir',
      description: 'Towering symmetrical pyramid conifer with dense, aromatic needles.',
      rarity: PlantRarity.rare,
      price: 0,
      requiredLevel: 1,
      categories: ['Coding', 'Study'],
      growthStages: standardStages,
      primaryColor: const Color(0xFF2E5A44),
      accentColor: const Color(0xFF4E9F70),
      emoji: '🌲',
    ),
    PlantType(
      id: 'redwood',
      name: 'Redwood',
      description: 'An ancient, towering titan of the forest. The ultimate testament to relentless perseverance.',
      rarity: PlantRarity.legendary,
      price: 0,
      requiredLevel: 1,
      categories: ['Work', 'Coding', 'Study'],
      growthStages: standardStages,
      primaryColor: const Color(0xFF8D4004),
      accentColor: const Color(0xFF2D5A27),
      emoji: '🌲',
    ),
    PlantType(
      id: 'cedar',
      name: 'Cedar',
      description: 'Stately horizontal spreading branches with aromatic silver-green foliage.',
      rarity: PlantRarity.epic,
      price: 0,
      requiredLevel: 1,
      categories: ['Work', 'Creative', 'Study'],
      growthStages: standardStages,
      primaryColor: const Color(0xFF3B7A57),
      accentColor: const Color(0xFF66BB6A),
      emoji: '🌲',
    ),
  ];

  static PlantType? getById(String id) {
    try {
      return allPlants.firstWhere((p) => p.id == id);
    } catch (_) {
      // Fallback aliases
      if (id == 'focus_fern') return getById('oak');
      if (id == 'study_sakura') return getById('cherry_blossom');
      if (id == 'code_cactus') return getById('pine');
      if (id == 'writers_willow') return getById('willow');
      if (id == 'energy_palm') return getById('palm');
      if (id == 'productivity_tree') return getById('oak');
      return allPlants.first;
    }
  }

  /// All tree species available by default
  static List<PlantType> get defaultUnlocked => allPlants;
}

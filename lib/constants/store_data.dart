import '../models/store_item_model.dart';

/// All store items available in FocusBloom.
class StoreData {
  StoreData._();

  static const List<StoreItem> allItems = [
    // --- POTS ---
    StoreItem(
      id: 'pot_clay',
      name: 'Clay Pot',
      description: 'A classic terracotta clay pot. The perfect home for any plant.',
      type: StoreItemType.pot,
      price: 0,
      emoji: '🪴',
      isDefault: true,
    ),
    StoreItem(
      id: 'pot_ceramic',
      name: 'Ceramic Pot',
      description: 'A smooth white ceramic pot with a minimalist finish.',
      type: StoreItemType.pot,
      price: 80,
      emoji: '⬜',
    ),
    StoreItem(
      id: 'pot_wooden',
      name: 'Wooden Planter',
      description: 'A rustic wooden planter with natural warmth.',
      type: StoreItemType.pot,
      price: 120,
      requiredLevel: 3,
      emoji: '🪵',
    ),
    StoreItem(
      id: 'pot_golden',
      name: 'Golden Pot',
      description: 'A luxurious golden pot for plants that deserve the best.',
      type: StoreItemType.pot,
      price: 500,
      requiredLevel: 8,
      emoji: '✨',
    ),

    // --- DECORATIONS ---
    StoreItem(
      id: 'deco_rock',
      name: 'Garden Rock',
      description: 'A smooth zen stone for your garden.',
      type: StoreItemType.decoration,
      price: 30,
      emoji: '🪨',
    ),
    StoreItem(
      id: 'deco_mushroom',
      name: 'Mushroom',
      description: 'A cheerful red mushroom for your garden.',
      type: StoreItemType.decoration,
      price: 40,
      emoji: '🍄',
    ),
    StoreItem(
      id: 'deco_butterfly',
      name: 'Butterfly',
      description: 'A colorful butterfly resting in your garden.',
      type: StoreItemType.decoration,
      price: 60,
      requiredLevel: 2,
      emoji: '🦋',
    ),
    StoreItem(
      id: 'deco_lantern',
      name: 'Garden Lantern',
      description: 'A warm lantern that lights your garden softly.',
      type: StoreItemType.decoration,
      price: 80,
      requiredLevel: 3,
      emoji: '🏮',
    ),
    StoreItem(
      id: 'deco_bench',
      name: 'Garden Bench',
      description: 'A cozy bench to rest between focus sessions.',
      type: StoreItemType.decoration,
      price: 150,
      requiredLevel: 4,
      emoji: '🪑',
    ),
    StoreItem(
      id: 'deco_fountain',
      name: 'Stone Fountain',
      description: 'A peaceful fountain that brings tranquility to your garden.',
      type: StoreItemType.decoration,
      price: 250,
      requiredLevel: 6,
      emoji: '⛲',
    ),

    // --- THEMES ---
    StoreItem(
      id: 'theme_forest',
      name: 'Forest Theme',
      description: 'A lush forest backdrop for your garden.',
      type: StoreItemType.theme,
      price: 0,
      emoji: '🌲',
      isDefault: true,
    ),
    StoreItem(
      id: 'theme_japanese',
      name: 'Japanese Garden',
      description: 'A serene Japanese garden with bamboo and koi.',
      type: StoreItemType.theme,
      price: 300,
      requiredLevel: 5,
      emoji: '⛩️',
    ),
    StoreItem(
      id: 'theme_minimal',
      name: 'Minimal White',
      description: 'A clean, distraction-free minimal garden.',
      type: StoreItemType.theme,
      price: 200,
      requiredLevel: 4,
      emoji: '🤍',
    ),
    StoreItem(
      id: 'theme_night',
      name: 'Night Garden',
      description: 'A mystical garden under the stars.',
      type: StoreItemType.theme,
      price: 400,
      requiredLevel: 7,
      emoji: '🌙',
    ),
    StoreItem(
      id: 'theme_autumn',
      name: 'Autumn Garden',
      description: 'A warm autumn garden with falling leaves.',
      type: StoreItemType.theme,
      price: 350,
      requiredLevel: 6,
      emoji: '🍂',
    ),

    // --- EFFECTS ---
    StoreItem(
      id: 'effect_fireflies',
      name: 'Fireflies',
      description: 'Magical fireflies dancing in your garden.',
      type: StoreItemType.effect,
      price: 200,
      requiredLevel: 5,
      emoji: '✨',
    ),
    StoreItem(
      id: 'effect_leaves',
      name: 'Falling Leaves',
      description: 'Gentle leaves falling in your garden.',
      type: StoreItemType.effect,
      price: 150,
      requiredLevel: 4,
      emoji: '🍃',
    ),
  ];

  static StoreItem? getById(String id) {
    try {
      return allItems.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<StoreItem> getByType(StoreItemType type) =>
      allItems.where((i) => i.type == type).toList();
}

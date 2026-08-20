import 'package:cloud_firestore/cloud_firestore.dart';

enum StoreItemType { plant, pot, decoration, theme, effect }

/// A store item available for purchase with Bloom Coins.
class StoreItem {
  final String id;
  final String name;
  final String description;
  final StoreItemType type;
  final int price;
  final int requiredLevel;
  final String emoji;
  final bool isDefault; // available from start without purchase

  const StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.price,
    this.requiredLevel = 1,
    required this.emoji,
    this.isDefault = false,
  });
}

/// A user-owned inventory item stored in Firestore.
class InventoryItem {
  final String id; // Firestore doc ID
  final String itemId; // StoreItem ID
  final StoreItemType type;
  final DateTime purchasedAt;
  final bool isEquipped;

  const InventoryItem({
    required this.id,
    required this.itemId,
    required this.type,
    required this.purchasedAt,
    this.isEquipped = false,
  });

  factory InventoryItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InventoryItem(
      id: doc.id,
      itemId: data['itemId'] ?? doc.id,
      type: StoreItemType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => StoreItemType.decoration,
      ),
      purchasedAt: (data['purchasedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isEquipped: data['isEquipped'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'itemId': itemId,
      'type': type.name,
      'purchasedAt': Timestamp.fromDate(purchasedAt),
      'isEquipped': isEquipped,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/focus_session_model.dart';
import '../models/plant_model.dart';
import '../models/achievement_model.dart';
import '../models/store_item_model.dart';

/// Repository for all Firestore operations on a user's data.
/// This is the single source of truth for Firestore reads/writes.
class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference _userDoc(String uid) =>
      _db.collection(AppConstants.kUsersCollection).doc(uid);

  CollectionReference _sessionsCol(String uid) =>
      _userDoc(uid).collection(AppConstants.kSessionsCollection);

  CollectionReference _plantsCol(String uid) =>
      _userDoc(uid).collection(AppConstants.kPlantsCollection);

  CollectionReference _achievementsCol(String uid) =>
      _userDoc(uid).collection(AppConstants.kAchievementsCollection);

  CollectionReference _inventoryCol(String uid) =>
      _userDoc(uid).collection(AppConstants.kInventoryCollection);

  // =========================================================================
  // USER PROFILE
  // =========================================================================

  /// Create a new user profile document in Firestore after registration.
  Future<void> createUserProfile(UserModel user) async {
    await _userDoc(user.uid).set(user.toFirestore());
  }

  /// Fetch the user profile once.
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _userDoc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Stream the user profile for real-time updates.
  Stream<UserModel?> streamUserProfile(String uid) {
    return _userDoc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  /// Update specific fields of the user profile.
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _userDoc(uid).update(data);
  }

  // =========================================================================
  // FOCUS SESSIONS
  // =========================================================================

  /// Save a completed or abandoned focus session.
  Future<String> saveSession(String uid, FocusSessionModel session) async {
    final docRef = _sessionsCol(uid).doc(session.id);
    await docRef.set(session.toFirestore());
    return docRef.id;
  }

  /// Fetch all sessions, ordered by start time descending.
  Future<List<FocusSessionModel>> getSessions(String uid, {int limit = 50}) async {
    final query = await _sessionsCol(uid)
        .orderBy('startedAt', descending: true)
        .limit(limit)
        .get();
    return query.docs.map((d) => FocusSessionModel.fromFirestore(d)).toList();
  }

  /// Stream of sessions for real-time history.
  Stream<List<FocusSessionModel>> streamSessions(String uid, {int limit = 100}) {
    return _sessionsCol(uid)
        .orderBy('startedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((q) => q.docs.map((d) => FocusSessionModel.fromFirestore(d)).toList());
  }

  /// Get sessions for today.
  Future<List<FocusSessionModel>> getTodaySessions(String uid) async {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 1));

    final query = await _sessionsCol(uid)
        .where('startedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startedAt', isLessThan: Timestamp.fromDate(end))
        .get();
    return query.docs.map((d) => FocusSessionModel.fromFirestore(d)).toList();
  }

  // =========================================================================
  // PLANTS
  // =========================================================================

  /// Get all user plants.
  Future<List<UserPlant>> getUserPlants(String uid) async {
    final query = await _plantsCol(uid).get();
    return query.docs.map((d) => UserPlant.fromFirestore(d)).toList();
  }

  /// Stream user plants.
  Stream<List<UserPlant>> streamUserPlants(String uid) {
    return _plantsCol(uid)
        .snapshots()
        .map((q) => q.docs.map((d) => UserPlant.fromFirestore(d)).toList());
  }

  /// Add or update a plant in the user's collection.
  Future<void> saveUserPlant(String uid, UserPlant plant) async {
    await _plantsCol(uid).doc(plant.plantTypeId).set(plant.toFirestore(), SetOptions(merge: true));
  }

  /// Check if user has a plant.
  Future<bool> hasPlant(String uid, String plantTypeId) async {
    final doc = await _plantsCol(uid).doc(plantTypeId).get();
    return doc.exists;
  }

  // =========================================================================
  // ACHIEVEMENTS
  // =========================================================================

  /// Get all unlocked achievements.
  Future<List<UserAchievement>> getUserAchievements(String uid) async {
    final query = await _achievementsCol(uid).get();
    return query.docs.map((d) => UserAchievement.fromFirestore(d)).toList();
  }

  /// Stream user achievements.
  Stream<List<UserAchievement>> streamUserAchievements(String uid) {
    return _achievementsCol(uid)
        .snapshots()
        .map((q) => q.docs.map((d) => UserAchievement.fromFirestore(d)).toList());
  }

  /// Unlock an achievement.
  Future<void> unlockAchievement(String uid, String achievementId) async {
    await _achievementsCol(uid).doc(achievementId).set({
      'achievementId': achievementId,
      'unlockedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Check if an achievement is already unlocked.
  Future<bool> isAchievementUnlocked(String uid, String achievementId) async {
    final doc = await _achievementsCol(uid).doc(achievementId).get();
    return doc.exists;
  }

  // =========================================================================
  // INVENTORY
  // =========================================================================

  /// Get all inventory items.
  Future<List<InventoryItem>> getInventory(String uid) async {
    final query = await _inventoryCol(uid).get();
    return query.docs.map((d) => InventoryItem.fromFirestore(d)).toList();
  }

  /// Stream inventory.
  Stream<List<InventoryItem>> streamInventory(String uid) {
    return _inventoryCol(uid)
        .snapshots()
        .map((q) => q.docs.map((d) => InventoryItem.fromFirestore(d)).toList());
  }

  /// Add an item to inventory.
  Future<void> addInventoryItem(String uid, InventoryItem item) async {
    await _inventoryCol(uid).doc(item.itemId).set(item.toFirestore());
  }

  /// Check if an item is owned.
  Future<bool> ownsItem(String uid, String itemId) async {
    final doc = await _inventoryCol(uid).doc(itemId).get();
    return doc.exists;
  }

  // =========================================================================
  // BATCH: Session complete update
  // Atomically updates user profile stats + saves session + saves plant
  // =========================================================================
  Future<void> completeSession({
    required String uid,
    required FocusSessionModel session,
    required Map<String, dynamic> profileUpdates,
    required UserPlant plant,
    required List<String> newAchievementIds,
  }) async {
    final batch = _db.batch();

    // Save session
    batch.set(_sessionsCol(uid).doc(session.id), session.toFirestore());

    // Update profile
    final profileUpdatesWithTimestamp = {
      ...profileUpdates,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    batch.update(_userDoc(uid), profileUpdatesWithTimestamp);

    // Save plant
    batch.set(_plantsCol(uid).doc(plant.plantTypeId), plant.toFirestore(), SetOptions(merge: true));

    // Unlock achievements
    for (final achievementId in newAchievementIds) {
      batch.set(_achievementsCol(uid).doc(achievementId), {
        'achievementId': achievementId,
        'unlockedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }
}

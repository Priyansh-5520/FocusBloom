import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/focus_session_model.dart';
import '../models/plant_model.dart';
import '../models/achievement_model.dart';
import '../models/store_item_model.dart';

/// Repository for all user data operations.
/// Provides offline-first persistence with SharedPreferences and automatic
/// Firestore sync when Firebase is available.
class UserRepository {
  FirebaseFirestore? get _db {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  DocumentReference? _userDoc(String uid) =>
      _db?.collection(AppConstants.kUsersCollection).doc(uid);

  CollectionReference? _sessionsCol(String uid) =>
      _userDoc(uid)?.collection(AppConstants.kSessionsCollection);

  CollectionReference? _plantsCol(String uid) =>
      _userDoc(uid)?.collection(AppConstants.kPlantsCollection);

  CollectionReference? _achievementsCol(String uid) =>
      _userDoc(uid)?.collection(AppConstants.kAchievementsCollection);

  CollectionReference? _inventoryCol(String uid) =>
      _userDoc(uid)?.collection(AppConstants.kInventoryCollection);

  // Local storage keys helper
  String _profileKey(String uid) => 'user_profile_$uid';
  String _sessionsKey(String uid) => 'user_sessions_$uid';
  String _plantsKey(String uid) => 'user_plants_$uid';
  String _achievementsKey(String uid) => 'user_achievements_$uid';
  String _inventoryKey(String uid) => 'user_inventory_$uid';

  // =========================================================================
  // USER PROFILE
  // =========================================================================

  /// Create or overwrite a user profile document.
  Future<void> createUserProfile(UserModel user) async {
    // 1. Save locally
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileKey(user.uid), jsonEncode(user.toMap()));
    } catch (e) {
      debugPrint('Local profile save error: $e');
    }

    // 2. Sync with Firestore if available (merge to never overwrite existing data)
    try {
      await _userDoc(user.uid)?.set(user.toFirestore(), SetOptions(merge: true));
    } catch (_) {}
  }

  /// Fetch the user profile.
  Future<UserModel?> getUserProfile(String uid) async {
    // Try Firestore first if available
    try {
      final doc = await _userDoc(uid)?.get();
      if (doc != null && doc.exists) {
        final user = UserModel.fromFirestore(doc);
        // Cache locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_profileKey(uid), jsonEncode(user.toMap()));
        return user;
      }
    } catch (_) {}

    // Fallback to local storage
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_profileKey(uid));
      if (raw != null && raw.isNotEmpty) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        return UserModel.fromMap(map);
      }
    } catch (e) {
      debugPrint('Local profile load error: $e');
    }
    return null;
  }

  /// Stream the user profile for real-time updates.
  Stream<UserModel?> streamUserProfile(String uid) {
    try {
      final doc = _userDoc(uid);
      if (doc != null) {
        return doc.snapshots().map((d) {
          if (!d.exists) return null;
          return UserModel.fromFirestore(d);
        });
      }
    } catch (_) {}
    return Stream.fromFuture(getUserProfile(uid));
  }

  /// Update specific fields of the user profile.
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    // 1. Update local cache safely (strip non-JSON objects if any)
    try {
      final existing = await getUserProfile(uid);
      if (existing != null) {
        final map = existing.toMap();
        data.forEach((key, value) {
          if (value is! FieldValue) {
            map[key] = value;
          }
        });
        map['updatedAt'] = DateTime.now().toIso8601String();
        final updated = UserModel.fromMap(map);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_profileKey(uid), jsonEncode(updated.toMap()));
      }
    } catch (e) {
      debugPrint('Local updateUserProfile error: $e');
    }

    // 2. Update Firestore
    try {
      final firestoreData = Map<String, dynamic>.from(data);
      firestoreData['updatedAt'] = FieldValue.serverTimestamp();
      await _userDoc(uid)?.update(firestoreData);
    } catch (e) {
      debugPrint('Firestore updateUserProfile error: $e');
    }
  }

  // =========================================================================
  // FOCUS SESSIONS
  // =========================================================================

  /// Save a completed or abandoned focus session.
  Future<String> saveSession(String uid, FocusSessionModel session) async {
    // 1. Save locally
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = await getSessions(uid);
      list.removeWhere((s) => s.id == session.id);
      list.insert(0, session);
      final jsonList = list.map((s) => s.toMap()).toList();
      await prefs.setString(_sessionsKey(uid), jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Local session save error: $e');
    }

    // 2. Save to Firestore
    try {
      final docRef = _sessionsCol(uid)?.doc(session.id);
      if (docRef != null) {
        await docRef.set(session.toFirestore());
        return docRef.id;
      }
    } catch (_) {}

    return session.id;
  }

  /// Fetch all sessions, ordered by start time descending.
  Future<List<FocusSessionModel>> getSessions(String uid, {int limit = 50}) async {
    // Try Firestore
    try {
      final query = await _sessionsCol(uid)
          ?.orderBy('startedAt', descending: true)
          .limit(limit)
          .get();
      if (query != null && query.docs.isNotEmpty) {
        return query.docs.map((d) => FocusSessionModel.fromFirestore(d)).toList();
      }
    } catch (_) {}

    // Fallback to local
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_sessionsKey(uid));
      if (raw != null && raw.isNotEmpty) {
        final list = jsonDecode(raw) as List<dynamic>;
        final sessions = list
            .map((item) => FocusSessionModel.fromMap(item as Map<String, dynamic>))
            .toList();
        sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
        return sessions.take(limit).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Stream of sessions for real-time history.
  Stream<List<FocusSessionModel>> streamSessions(String uid, {int limit = 100}) {
    try {
      final col = _sessionsCol(uid);
      if (col != null) {
        return col
            .orderBy('startedAt', descending: true)
            .limit(limit)
            .snapshots()
            .map((q) => q.docs.map((d) => FocusSessionModel.fromFirestore(d)).toList());
      }
    } catch (_) {}
    return Stream.fromFuture(getSessions(uid, limit: limit));
  }

  /// Get sessions for today.
  Future<List<FocusSessionModel>> getTodaySessions(String uid) async {
    final allSessions = await getSessions(uid, limit: 100);
    final now = DateTime.now();
    return allSessions.where((s) {
      return s.startedAt.year == now.year &&
          s.startedAt.month == now.month &&
          s.startedAt.day == now.day;
    }).toList();
  }

  // =========================================================================
  // PLANTS / TREES
  // =========================================================================

  /// Get all user plants.
  Future<List<UserPlant>> getUserPlants(String uid) async {
    // Try Firestore
    try {
      final query = await _plantsCol(uid)?.get();
      if (query != null && query.docs.isNotEmpty) {
        return query.docs.map((d) => UserPlant.fromFirestore(d)).toList();
      }
    } catch (_) {}

    // Fallback to local
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_plantsKey(uid));
      if (raw != null && raw.isNotEmpty) {
        final list = jsonDecode(raw) as List<dynamic>;
        return list
            .map((item) => UserPlant.fromMap(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// Stream user plants.
  Stream<List<UserPlant>> streamUserPlants(String uid) {
    try {
      final col = _plantsCol(uid);
      if (col != null) {
        return col
            .snapshots()
            .map((q) => q.docs.map((d) => UserPlant.fromFirestore(d)).toList());
      }
    } catch (_) {}
    return Stream.fromFuture(getUserPlants(uid));
  }

  /// Add or update a plant/tree in the user's collection.
  Future<void> saveUserPlant(String uid, UserPlant plant) async {
    // 1. Save locally
    try {
      final prefs = await SharedPreferences.getInstance();
      final plants = await getUserPlants(uid);
      final index = plants.indexWhere((p) => p.plantTypeId == plant.plantTypeId);
      if (index >= 0) {
        plants[index] = plant;
      } else {
        plants.add(plant);
      }
      final jsonList = plants.map((p) => p.toMap()).toList();
      await prefs.setString(_plantsKey(uid), jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Local plant save error: $e');
    }

    // 2. Save to Firestore
    try {
      await _plantsCol(uid)
          ?.doc(plant.plantTypeId)
          .set(plant.toFirestore(), SetOptions(merge: true));
    } catch (_) {}
  }

  /// Check if user has a plant.
  Future<bool> hasPlant(String uid, String plantTypeId) async {
    final plants = await getUserPlants(uid);
    return plants.any((p) => p.plantTypeId == plantTypeId);
  }

  // =========================================================================
  // ACHIEVEMENTS
  // =========================================================================

  /// Get all unlocked achievements.
  Future<List<UserAchievement>> getUserAchievements(String uid) async {
    // Try Firestore
    try {
      final query = await _achievementsCol(uid)?.get();
      if (query != null && query.docs.isNotEmpty) {
        return query.docs.map((d) => UserAchievement.fromFirestore(d)).toList();
      }
    } catch (_) {}

    // Fallback to local
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_achievementsKey(uid));
      if (raw != null && raw.isNotEmpty) {
        final list = jsonDecode(raw) as List<dynamic>;
        return list
            .map((item) => UserAchievement.fromMap(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// Stream user achievements.
  Stream<List<UserAchievement>> streamUserAchievements(String uid) {
    try {
      final col = _achievementsCol(uid);
      if (col != null) {
        return col
            .snapshots()
            .map((q) => q.docs.map((d) => UserAchievement.fromFirestore(d)).toList());
      }
    } catch (_) {}
    return Stream.fromFuture(getUserAchievements(uid));
  }

  /// Unlock an achievement.
  Future<void> unlockAchievement(String uid, String achievementId) async {
    final achievement = UserAchievement(
      achievementId: achievementId,
      unlockedAt: DateTime.now(),
    );

    // Save locally
    try {
      final prefs = await SharedPreferences.getInstance();
      final achievements = await getUserAchievements(uid);
      if (!achievements.any((a) => a.achievementId == achievementId)) {
        achievements.add(achievement);
        final jsonList = achievements.map((a) => a.toMap()).toList();
        await prefs.setString(_achievementsKey(uid), jsonEncode(jsonList));
      }
    } catch (_) {}

    // Save Firestore
    try {
      await _achievementsCol(uid)?.doc(achievementId).set({
        'achievementId': achievementId,
        'unlockedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  /// Check if an achievement is already unlocked.
  Future<bool> isAchievementUnlocked(String uid, String achievementId) async {
    final achievements = await getUserAchievements(uid);
    return achievements.any((a) => a.achievementId == achievementId);
  }

  // =========================================================================
  // INVENTORY
  // =========================================================================

  /// Get all inventory items.
  Future<List<InventoryItem>> getInventory(String uid) async {
    // Try Firestore
    try {
      final query = await _inventoryCol(uid)?.get();
      if (query != null && query.docs.isNotEmpty) {
        return query.docs.map((d) => InventoryItem.fromFirestore(d)).toList();
      }
    } catch (_) {}

    // Fallback to local
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_inventoryKey(uid));
      if (raw != null && raw.isNotEmpty) {
        final list = jsonDecode(raw) as List<dynamic>;
        return list
            .map((item) => InventoryItem.fromMap(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// Stream inventory.
  Stream<List<InventoryItem>> streamInventory(String uid) {
    try {
      final col = _inventoryCol(uid);
      if (col != null) {
        return col
            .snapshots()
            .map((q) => q.docs.map((d) => InventoryItem.fromFirestore(d)).toList());
      }
    } catch (_) {}
    return Stream.fromFuture(getInventory(uid));
  }

  /// Add an item to inventory.
  Future<void> addInventoryItem(String uid, InventoryItem item) async {
    // Save locally
    try {
      final prefs = await SharedPreferences.getInstance();
      final items = await getInventory(uid);
      final idx = items.indexWhere((i) => i.itemId == item.itemId);
      if (idx >= 0) {
        items[idx] = item;
      } else {
        items.add(item);
      }
      final jsonList = items.map((i) => i.toMap()).toList();
      await prefs.setString(_inventoryKey(uid), jsonEncode(jsonList));
    } catch (_) {}

    // Save Firestore
    try {
      await _inventoryCol(uid)?.doc(item.itemId).set(item.toFirestore());
    } catch (_) {}
  }

  /// Check if an item is owned.
  Future<bool> ownsItem(String uid, String itemId) async {
    final items = await getInventory(uid);
    return items.any((i) => i.itemId == itemId);
  }

  Future<void> completeSession({
    required String uid,
    required FocusSessionModel session,
    required UserModel updatedUser,
    required UserPlant plant,
    required List<String> newAchievementIds,
  }) async {
    // 1. Save session locally
    await saveSession(uid, session);

    // 2. Save plant locally
    await saveUserPlant(uid, plant);

    // 3. Save profile locally
    await createUserProfile(updatedUser);

    // 4. Save achievements locally
    for (final id in newAchievementIds) {
      await unlockAchievement(uid, id);
    }

    // 5. If Firestore available, run atomic batch
    final db = _db;
    if (db == null) return;
    try {
      final batch = db.batch();
      final userDoc = _userDoc(uid);
      final sessionsCol = _sessionsCol(uid);
      final plantsCol = _plantsCol(uid);
      final achievementsCol = _achievementsCol(uid);

      if (userDoc == null || sessionsCol == null || plantsCol == null || achievementsCol == null) return;

      batch.set(sessionsCol.doc(session.id), session.toFirestore());
      batch.set(userDoc, updatedUser.toFirestore(), SetOptions(merge: true));
      batch.set(plantsCol.doc(plant.plantTypeId), plant.toFirestore(), SetOptions(merge: true));

      for (final achievementId in newAchievementIds) {
        batch.set(achievementsCol.doc(achievementId), {
          'achievementId': achievementId,
          'unlockedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Firestore batch commit notice: $e');
    }
  }
}

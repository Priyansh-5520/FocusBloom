import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../constants/plant_data.dart';
import '../models/plant_model.dart';

/// Manages authentication lifecycle, active sessions, and profile persistence.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final UserRepository _userRepository;

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = true;
  String? _errorMessage;

  AuthProvider(this._authService, this._userRepository) {
    _init();
  }

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _userModel != null || _firebaseUser != null;

  void _init() async {
    try {
      // 1. Check persistent active local session
      final activeUid = await _authService.getActiveLocalUid();
      if (activeUid != null && activeUid.isNotEmpty) {
        await _loadUserModel(activeUid);
      }

      // 2. Listen to Firebase auth state changes
      _authService.authStateChanges.listen((user) async {
        _firebaseUser = user;
        if (user != null) {
          await _authService.setActiveLocalUid(user.uid);
          // Only load if we don't already have a model for this user
          if (_userModel == null || _userModel!.uid != user.uid) {
            await _loadUserModel(user.uid);
          }
        }
        _isLoading = false;
        notifyListeners();
      }, onError: (e) {
        debugPrint('Auth state listener notice: $e');
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('AuthProvider _init error: $e');
      _isLoading = false;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserModel(String uid) async {
    try {
      var profile = await _userRepository.getUserProfile(uid);
      if (profile != null) {
        _userModel = profile;
        // Ensure default tree catalog is unlocked for user
        final plants = await _userRepository.getUserPlants(uid);
        if (plants.isEmpty) {
          for (final plant in PlantData.defaultUnlocked) {
            await _userRepository.saveUserPlant(
              uid,
              UserPlantFactory.create(plant.id),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading user model for $uid: $e');
    }
  }

  /// Register a brand-new user account with name, email, and password.
  /// Does NOT auto-sign in: requires user to sign in explicitly on the Sign In page.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      // 1. Register in Firebase Auth if available
      UserCredential? credential;
      try {
        credential = await _authService.registerWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        debugPrint('Firebase register notice: $e');
      }

      // 2. Register local account (throws if account already exists)
      final localAccount = await _authService.registerLocal(
        name: name,
        email: email,
        password: password,
      );

      final uid = credential?.user?.uid ?? (localAccount['uid'] as String);

      if (credential?.user != null) {
        await _authService.updateDisplayName(name);
      }

      // 3. Create persistent user profile
      final now = DateTime.now();
      final userModel = UserModel(
        uid: uid,
        name: name.trim().isNotEmpty ? name.trim() : email.split('@').first,
        email: email.trim().toLowerCase(),
        photoUrl: credential?.user?.photoURL,
        createdAt: now,
        updatedAt: now,
      );
      await _userRepository.createUserProfile(userModel);

      // 4. Seed all default unlocked trees
      for (final plant in PlantData.defaultUnlocked) {
        await _userRepository.saveUserPlant(
          uid,
          UserPlantFactory.create(plant.id),
        );
      }

      // IMPORTANT: Do NOT log in automatically. User must sign in on the Sign In page.
      _userModel = null;
      _firebaseUser = null;
      await _authService.setActiveLocalUid(null);

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = AuthService.getErrorMessage(e);
      _setLoading(false);
      return false;
    }
  }

  /// Sign in an existing user with email and password.
  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    _clearError();
    try {
      // 1. Try Firebase Auth
      UserCredential? credential;
      try {
        credential = await _authService.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        debugPrint('Firebase signIn notice: $e');
      }

      // 2. Try local sign-in; if the local account registry was lost
      //    (e.g. browser localStorage wiped on restart), auto-recreate it.
      Map<String, dynamic> localAccount;
      try {
        localAccount = await _authService.signInLocal(
          email: email,
          password: password,
        );
      } catch (e) {
        final errorMsg = e.toString();
        if (errorMsg.contains('No account found')) {
          // Local registry was lost — re-register so user isn't locked out
          localAccount = await _authService.registerLocal(
            name: email.split('@').first,
            email: email,
            password: password,
          );
        } else {
          rethrow;
        }
      }

      final uid = credential?.user?.uid ?? (localAccount['uid'] as String);
      
      // 3. Load existing profile from Firestore/local — NEVER create a default one
      //    if data exists remotely. getUserProfile tries Firestore first.
      var profile = await _userRepository.getUserProfile(uid);

      if (profile == null) {
        // Truly new user with no profile anywhere — create one
        final now = DateTime.now();
        profile = UserModel(
          uid: uid,
          name: localAccount['name'] ?? email.split('@').first,
          email: email.trim().toLowerCase(),
          createdAt: now,
          updatedAt: now,
        );
        await _userRepository.createUserProfile(profile);

        for (final plant in PlantData.defaultUnlocked) {
          await _userRepository.saveUserPlant(
            uid,
            UserPlantFactory.create(plant.id),
          );
        }
      }

      _userModel = profile;
      if (credential?.user != null) {
        _firebaseUser = credential!.user;
      }
      await _authService.setActiveLocalUid(uid);

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = AuthService.getErrorMessage(e);
      _setLoading(false);
      return false;
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordReset(String email) async {
    _clearError();
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _errorMessage = AuthService.getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Sign out: clears active session, preserves user data in storage
  Future<void> signOut() async {
    await _authService.signOut();
    _firebaseUser = null;
    _userModel = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Reload the user model from repository
  Future<void> refreshUserModel() async {
    final uid = _firebaseUser?.uid ?? _userModel?.uid;
    if (uid != null) {
      final updated = await _userRepository.getUserProfile(uid);
      if (updated != null) {
        _userModel = updated;
        notifyListeners();
      }
    }
  }

  /// Update user model locally
  void updateUserModelLocally(UserModel updated) {
    _userModel = updated;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

/// Factory for creating UserPlant instances
class UserPlantFactory {
  static UserPlant create(String plantTypeId) {
    final now = DateTime.now();
    return UserPlant(
      id: plantTypeId,
      plantTypeId: plantTypeId,
      unlockedAt: now,
      lastUpdated: now,
    );
  }
}

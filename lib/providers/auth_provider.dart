import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../constants/plant_data.dart';
import '../models/plant_model.dart';

/// Manages authentication state and exposes the current Firebase user.
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
  bool get isAuthenticated => _firebaseUser != null;

  void _init() {
    _authService.authStateChanges.listen((user) async {
      _firebaseUser = user;
      if (user != null) {
        await _loadUserModel(user.uid);
      } else {
        _userModel = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _loadUserModel(String uid) async {
    _userModel = await _userRepository.getUserProfile(uid);
  }

  /// Register a new user with email and password.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final credential = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;
      await user.updateDisplayName(name);

      // Create Firestore profile
      final now = DateTime.now();
      final userModel = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        photoUrl: user.photoURL,
        createdAt: now,
        updatedAt: now,
      );
      await _userRepository.createUserProfile(userModel);

      // Give the default plant (Focus Fern) to new users
      for (final plant in PlantData.defaultUnlocked) {
        await _userRepository.saveUserPlant(
          user.uid,
          UserPlantFactory.create(plant.id),
        );
      }

      _userModel = userModel;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = AuthService.getErrorMessage(e);
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Sign in with email and password.
  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = AuthService.getErrorMessage(e);
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Sign in with Google.
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential == null) {
        _setLoading(false);
        return false;
      }

      final user = credential.user!;
      final existingProfile = await _userRepository.getUserProfile(user.uid);

      if (existingProfile == null) {
        // New Google user — create profile
        final now = DateTime.now();
        final userModel = UserModel(
          uid: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
          photoUrl: user.photoURL,
          createdAt: now,
          updatedAt: now,
        );
        await _userRepository.createUserProfile(userModel);
        for (final plant in PlantData.defaultUnlocked) {
          await _userRepository.saveUserPlant(
            user.uid,
            UserPlantFactory.create(plant.id),
          );
        }
        _userModel = userModel;
      } else {
        _userModel = existingProfile;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = AuthService.getErrorMessage(e);
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Send password reset email.
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

  /// Sign out.
  Future<void> signOut() async {
    await _authService.signOut();
    _userModel = null;
    notifyListeners();
  }

  /// Refresh the user model from Firestore.
  Future<void> refreshUserModel() async {
    if (_firebaseUser == null) return;
    _userModel = await _userRepository.getUserProfile(_firebaseUser!.uid);
    notifyListeners();
  }

  /// Update user model locally (after session completion).
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

/// Factory for creating UserPlant instances.
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

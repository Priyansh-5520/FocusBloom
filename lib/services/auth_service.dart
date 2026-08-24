import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Production-ready AuthService that coordinates Firebase Authentication
/// with a deterministic, persistent local account registry for offline resilience.
class AuthService {
  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  static const String _kAccountsKey = 'focusbloom_auth_accounts_v2';
  static const String _kActiveUidKey = 'focusbloom_active_uid_v2';

  /// Current Firebase user (null if not signed in via Firebase)
  User? get currentUser {
    try {
      return _auth?.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Stream of Firebase auth state changes
  Stream<User?> get authStateChanges {
    try {
      return _auth?.authStateChanges() ?? Stream.value(null);
    } catch (_) {
      return Stream.value(null);
    }
  }

  /// Generate a deterministic, stable UID from an email address
  static String generateDeterministicUid(String email) {
    final clean = email.trim().toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    return 'user_$clean';
  }

  /// Get currently active authenticated UID from persistent storage
  Future<String?> getActiveLocalUid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kActiveUidKey);
    } catch (e) {
      debugPrint('Error getting active UID: $e');
      return null;
    }
  }

  /// Set or clear the active authenticated UID in persistent storage
  Future<void> setActiveLocalUid(String? uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (uid != null && uid.isNotEmpty) {
        await prefs.setString(_kActiveUidKey, uid);
      } else {
        await prefs.remove(_kActiveUidKey);
      }
    } catch (e) {
      debugPrint('Error setting active UID: $e');
    }
  }

  /// Retrieve all registered local accounts
  Future<Map<String, dynamic>> _getAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kAccountsKey);
      if (raw != null && raw.isNotEmpty) {
        return jsonDecode(raw) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error loading accounts: $e');
    }
    return {};
  }

  /// Save account registry to persistent storage
  Future<void> _saveAccounts(Map<String, dynamic> accounts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kAccountsKey, jsonEncode(accounts));
    } catch (e) {
      debugPrint('Error saving accounts: $e');
    }
  }

  /// Register a brand-new user account.
  /// Throws an exception if an account with this email already exists.
  Future<Map<String, dynamic>> registerLocal({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw Exception('Please enter a valid email address.');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }

    final accounts = await _getAccounts();
    if (accounts.containsKey(normalizedEmail)) {
      throw Exception('An account with this email already exists. Please sign in instead.');
    }

    final uid = generateDeterministicUid(normalizedEmail);
    final accountData = {
      'uid': uid,
      'name': name.trim().isNotEmpty ? name.trim() : normalizedEmail.split('@').first,
      'email': normalizedEmail,
      'password': password,
      'createdAt': DateTime.now().toIso8601String(),
    };

    accounts[normalizedEmail] = accountData;
    await _saveAccounts(accounts);
    await setActiveLocalUid(uid);

    return accountData;
  }

  /// Sign in an existing user account.
  /// Throws an exception if the account does not exist or password is wrong.
  Future<Map<String, dynamic>> signInLocal({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw Exception('Please enter a valid email address.');
    }

    final accounts = await _getAccounts();
    if (!accounts.containsKey(normalizedEmail)) {
      throw Exception('No account found with this email. Please create an account first.');
    }

    final account = accounts[normalizedEmail] as Map<String, dynamic>;
    if (account['password'] != password) {
      throw Exception('Incorrect password. Please try again.');
    }

    final uid = account['uid'] as String;
    await setActiveLocalUid(uid);
    return account;
  }

  /// Register in Firebase Authentication (when configured)
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) return null;
    return await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Sign in via Firebase Authentication (when configured)
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) return null;
    return await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Sign in with Google (Web Popup + Mobile Native)
  Future<UserCredential?> signInWithGoogle() async {
    final auth = _auth;
    if (auth == null) return null;

    if (kIsWeb) {
      try {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        return await auth.signInWithPopup(googleProvider);
      } catch (e) {
        debugPrint('Web Google Sign-In notice: $e');
        rethrow;
      }
    } else {
      try {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null; // Cancelled

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await auth.signInWithCredential(credential);
      } catch (e) {
        debugPrint('Mobile Google Sign-In notice: $e');
        rethrow;
      }
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    final auth = _auth;
    if (auth != null) {
      await auth.sendPasswordResetEmail(email: email.trim());
    }
  }

  /// Sign out: clears active session without deleting saved user data
  Future<void> signOut() async {
    try {
      await setActiveLocalUid(null);
      if (_auth != null) {
        await _auth!.signOut();
      }
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    } catch (e) {
      debugPrint('Sign out notice: $e');
    }
  }

  /// Update display name
  Future<void> updateDisplayName(String name) async {
    try {
      await _auth?.currentUser?.updateDisplayName(name);
    } catch (_) {}
  }

  /// Convert error into user-friendly message
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No account found with this email. Please sign up first.';
        case 'wrong-password':
          return 'Incorrect password. Please check and try again.';
        case 'email-already-in-use':
          return 'An account with this email already exists. Please sign in.';
        case 'weak-password':
          return 'Password is too weak. Please use at least 6 characters.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait a moment and try again.';
        case 'network-request-failed':
          return 'Network connection error. Please check your internet.';
        case 'invalid-credential':
          return 'Invalid credentials. Please verify your email and password.';
        case 'popup-closed-by-user':
          return 'Google Sign-In window was closed.';
        default:
          return error.message ?? 'Authentication failed.';
      }
    }
    final msg = error.toString().replaceAll('Exception: ', '').trim();
    return msg.isNotEmpty ? msg : 'An error occurred during authentication.';
  }
}

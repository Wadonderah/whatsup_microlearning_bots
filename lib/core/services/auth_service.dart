import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_result.dart';
import '../models/user_model.dart';
import '../utils/environment_config.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();

  AuthService._() {
    _initializeGoogleSignIn();
  }

  /// Get Firebase Auth instance with initialization check
  FirebaseAuth get _firebaseAuth {
    if (Firebase.apps.isEmpty) {
      throw Exception(
          "Firebase not initialized! Please ensure Firebase.initializeApp() is called before using AuthService.");
    }
    return FirebaseAuth.instance;
  }

  GoogleSignIn? _googleSignIn;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _userDataKey = 'user_data';
  static const String _userPreferencesKey = 'user_preferences';

  /// Initialize Google Sign-In with proper configuration
  void _initializeGoogleSignIn() {
    try {
      // Google Sign-In is not supported on Windows desktop, but works on web
      if (!kIsWeb && Platform.isWindows) {
        debugPrint('Google Sign-In not supported on Windows desktop platform');
        _googleSignIn = null;
        return;
      }

      if (kIsWeb) {
        // For web, use the client ID from environment or meta tag
        _googleSignIn = GoogleSignIn(
          clientId: EnvironmentConfig.googleWebClientId.isNotEmpty
              ? EnvironmentConfig.googleWebClientId
              : null, // Will use meta tag if null
          scopes: ['email', 'profile'],
        );
        debugPrint('Google Sign-In initialized for web platform');
      } else {
        // For mobile platforms
        _googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
        );
        debugPrint('Google Sign-In initialized for mobile platform');
      }
    } catch (e) {
      debugPrint('Error initializing Google Sign-In: $e');
      _googleSignIn = null;
    }
  }

  /// Get current user stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Get current user
  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  /// Get current app user
  AppUser? get currentUser {
    final firebaseUser = currentFirebaseUser;
    if (firebaseUser != null) {
      return AppUser.fromFirebaseUser(firebaseUser);
    }
    return null;
  }

  /// Check if user is authenticated
  bool get isAuthenticated => currentFirebaseUser != null;

  /// Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        final appUser = AppUser.fromFirebaseUser(credential.user!);
        await _saveUserData(appUser);

        return AuthResult.success(
          user: appUser,
          type: AuthResultType.signIn,
        );
      } else {
        return AuthResult.error(
          error: 'Sign in failed. Please try again.',
          type: AuthResultType.signIn,
        );
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(
        error: _getErrorMessage(e),
        type: AuthResultType.signIn,
      );
    } catch (e) {
      return AuthResult.error(
        error: 'An unexpected error occurred. Please try again.',
        type: AuthResultType.signIn,
      );
    }
  }

  /// Create account with email and password
  Future<AuthResult> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      debugPrint('Creating account for email: ${email.trim()}');

      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      debugPrint('Account creation successful, user: ${credential.user?.uid}');

      if (credential.user != null) {
        // Update display name if provided
        if (displayName != null && displayName.isNotEmpty) {
          debugPrint('Updating display name: $displayName');
          await credential.user!.updateDisplayName(displayName.trim());
          await credential.user!.reload();
        }

        // Send email verification (optional, don't fail if this fails)
        try {
          await credential.user!.sendEmailVerification();
          debugPrint('Email verification sent');
        } catch (e) {
          debugPrint('Email verification failed (non-critical): $e');
        }

        final appUser = AppUser.fromFirebaseUser(credential.user!);
        await _saveUserData(appUser);

        debugPrint('User data saved successfully');

        return AuthResult.success(
          user: appUser,
          type: AuthResultType.signUp,
        );
      } else {
        debugPrint('Account creation failed: credential.user is null');
        return AuthResult.error(
          error: 'Account creation failed. Please try again.',
          type: AuthResultType.signUp,
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Exception: ${e.code} - ${e.message}');
      return AuthResult.error(
        error: _getErrorMessage(e),
        type: AuthResultType.signUp,
      );
    } catch (e) {
      debugPrint('Unexpected error during account creation: $e');
      return AuthResult.error(
        error: 'An unexpected error occurred: ${e.toString()}',
        type: AuthResultType.signUp,
      );
    }
  }

  /// Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Check if Google Sign-In is available
      if (_googleSignIn == null) {
        return AuthResult.error(
          error: 'Google Sign-In is not available on this platform.',
          type: AuthResultType.signIn,
        );
      }

      GoogleSignInAccount? googleUser;

      if (kIsWeb) {
        // For web, try silent sign-in first (recommended approach)
        try {
          googleUser = await _googleSignIn!.signInSilently();
        } catch (e) {
          // If silent sign-in fails, fall back to regular sign-in
          debugPrint('Silent sign-in failed, trying regular sign-in: $e');
        }

        // If silent sign-in didn't work, try regular sign-in
        googleUser ??= await _googleSignIn!.signIn();
      } else {
        // For mobile platforms, use regular sign-in
        googleUser = await _googleSignIn!.signIn();
      }

      if (googleUser == null) {
        return AuthResult.error(
          error: 'Google sign in was cancelled.',
          type: AuthResultType.signIn,
        );
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final appUser = AppUser.fromFirebaseUser(userCredential.user!);
        await _saveUserData(appUser);

        return AuthResult.success(
          user: appUser,
          type: AuthResultType.signIn,
        );
      } else {
        return AuthResult.error(
          error: 'Google sign in failed. Please try again.',
          type: AuthResultType.signIn,
        );
      }
    } catch (e) {
      debugPrint('Google sign in error: $e');
      return AuthResult.error(
        error: 'Google sign in failed. Please try again.',
        type: AuthResultType.signIn,
      );
    }
  }

  /// Sign out
  Future<AuthResult> signOut() async {
    try {
      // Sign out from Google if signed in and available
      if (_googleSignIn != null && await _googleSignIn!.isSignedIn()) {
        await _googleSignIn!.signOut();
      }

      // Sign out from Firebase
      await _firebaseAuth.signOut();

      // Clear stored user data
      await _clearUserData();

      return AuthResult.success(
        type: AuthResultType.signOut,
      );
    } catch (e) {
      return AuthResult.error(
        error: 'Sign out failed. Please try again.',
        type: AuthResultType.signOut,
      );
    }
  }

  /// Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());

      return AuthResult.success(
        type: AuthResultType.passwordReset,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(
        error: _getErrorMessage(e),
        type: AuthResultType.passwordReset,
      );
    } catch (e) {
      return AuthResult.error(
        error: 'Failed to send password reset email. Please try again.',
        type: AuthResultType.passwordReset,
      );
    }
  }

  /// Send email verification
  Future<AuthResult> sendEmailVerification() async {
    try {
      final user = currentFirebaseUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();

        return AuthResult.success(
          type: AuthResultType.emailVerification,
        );
      } else {
        return AuthResult.error(
          error: 'No user found or email already verified.',
          type: AuthResultType.emailVerification,
        );
      }
    } catch (e) {
      return AuthResult.error(
        error: 'Failed to send verification email. Please try again.',
        type: AuthResultType.emailVerification,
      );
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = currentFirebaseUser;
      if (user != null) {
        if (displayName != null) {
          await user.updateDisplayName(displayName);
        }
        if (photoURL != null) {
          await user.updatePhotoURL(photoURL);
        }
        await user.reload();

        // Update stored user data
        final updatedUser = AppUser.fromFirebaseUser(user);
        await _saveUserData(updatedUser);

        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Update profile error: $e');
      return false;
    }
  }

  /// Save user data to secure storage
  Future<void> _saveUserData(AppUser user) async {
    try {
      final userData = jsonEncode(user.toJson());
      await _secureStorage.write(key: _userDataKey, value: userData);
    } catch (e) {
      debugPrint('Save user data error: $e');
    }
  }

  /// Load user data from secure storage
  Future<AppUser?> loadUserData() async {
    try {
      final userData = await _secureStorage.read(key: _userDataKey);
      if (userData != null) {
        final userMap = jsonDecode(userData) as Map<String, dynamic>;
        return AppUser.fromJson(userMap);
      }
    } catch (e) {
      debugPrint('Load user data error: $e');
    }
    return null;
  }

  /// Clear user data from storage
  Future<void> _clearUserData() async {
    try {
      await _secureStorage.delete(key: _userDataKey);
      await _secureStorage.delete(key: _userPreferencesKey);
    } catch (e) {
      debugPrint('Clear user data error: $e');
    }
  }

  /// Save user preferences
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsData = jsonEncode(preferences.toJson());
      await prefs.setString(_userPreferencesKey, prefsData);
    } catch (e) {
      debugPrint('Save preferences error: $e');
    }
  }

  /// Load user preferences
  Future<UserPreferences> loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsData = prefs.getString(_userPreferencesKey);
      if (prefsData != null) {
        final prefsMap = jsonDecode(prefsData) as Map<String, dynamic>;
        return UserPreferences.fromJson(prefsMap);
      }
    } catch (e) {
      debugPrint('Load preferences error: $e');
    }
    return const UserPreferences();
  }

  /// Get user-friendly error message
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      case 'invalid-api-key':
        return 'Firebase configuration error. Please check your API key.';
      case 'app-not-authorized':
        return 'App not authorized. Please check your Firebase configuration.';
      case 'invalid-user-token':
        return 'Authentication token is invalid. Please try signing in again.';
      default:
        // Show more detailed error in development
        if (kDebugMode) {
          return 'Firebase Error (${e.code}): ${e.message ?? 'Unknown error'}';
        }
        return e.message ?? 'An error occurred. Please try again.';
    }
  }

  /// Delete user account
  Future<AuthResult> deleteAccount() async {
    try {
      final user = currentFirebaseUser;
      if (user != null) {
        await user.delete();
        await _clearUserData();

        return AuthResult.success(
          type: AuthResultType.signOut,
        );
      } else {
        return AuthResult.error(
          error: 'No user found to delete.',
          type: AuthResultType.signOut,
        );
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(
        error: _getErrorMessage(e),
        type: AuthResultType.signOut,
      );
    } catch (e) {
      return AuthResult.error(
        error: 'Failed to delete account. Please try again.',
        type: AuthResultType.signOut,
      );
    }
  }
}

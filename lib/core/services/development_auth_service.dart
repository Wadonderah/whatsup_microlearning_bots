import 'dart:async';

import '../config/development_config.dart';
import '../models/auth_result.dart';
import '../models/user_model.dart';

/// Development authentication service that works without Firebase
class DevelopmentAuthService {
  static DevelopmentAuthService? _instance;
  static DevelopmentAuthService get instance =>
      _instance ??= DevelopmentAuthService._();

  DevelopmentAuthService._();

  AppUser? _currentUser;
  final StreamController<AppUser?> _authStateController =
      StreamController<AppUser?>.broadcast();

  /// Stream of authentication state changes
  Stream<AppUser?> get authStateChanges => _authStateController.stream;

  /// Current authenticated user
  AppUser? get currentUser => _currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUser != null;

  /// Initialize the development auth service
  Future<void> initialize() async {
    DevelopmentConfig.devLog('Initializing Development Auth Service');
    DevelopmentConfig.showDevWarning();

    // Simulate checking for persisted auth state
    await Future.delayed(const Duration(milliseconds: 100));

    DevelopmentConfig.devLog('Development Auth Service initialized');
  }

  /// Sign in with email and password (mock)
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      DevelopmentConfig.devLog('Development sign in attempt: $email');

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Validate credentials against mock users
      if (!DevelopmentConfig.validateMockCredentials(email, password)) {
        return AuthResult.error(error: 'Invalid email or password');
      }

      // Create mock user
      final user = AppUser(
        uid: DevelopmentConfig.generateMockUserId(email),
        email: email,
        displayName: email.split('@')[0],
        photoURL: null,
        emailVerified: true,
        createdAt: DateTime.now(),
        lastSignInAt: DateTime.now(),
        preferences: const UserPreferences(),
      );

      _currentUser = user;
      _authStateController.add(user);

      DevelopmentConfig.devLog('Development sign in successful: ${user.uid}');
      return AuthResult.success(user: user);
    } catch (e) {
      DevelopmentConfig.devLog('Development sign in error: $e');
      return AuthResult.error(error: 'Sign in failed: $e');
    }
  }

  /// Create account with email and password (mock)
  Future<AuthResult> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      DevelopmentConfig.devLog('Development account creation attempt: $email');

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // In development mode, allow any email/password combination
      // Create new mock user
      final user = AppUser(
        uid: DevelopmentConfig.generateMockUserId(email),
        email: email,
        displayName: displayName ?? email.split('@')[0],
        photoURL: null,
        emailVerified: false, // New accounts start unverified
        createdAt: DateTime.now(),
        lastSignInAt: DateTime.now(),
        preferences: const UserPreferences(),
      );

      _currentUser = user;
      _authStateController.add(user);

      DevelopmentConfig.devLog(
          'Development account created successfully: ${user.uid}');
      return AuthResult.success(user: user);
    } catch (e) {
      DevelopmentConfig.devLog('Development account creation error: $e');
      return AuthResult.error(error: 'Account creation failed: $e');
    }
  }

  /// Sign in with Google (mock - works on all platforms in development)
  Future<AuthResult> signInWithGoogle() async {
    try {
      DevelopmentConfig.devLog('Development Google sign in attempt');

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 600));

      // In development mode, Google Sign-In works on all platforms
      DevelopmentConfig.devLog('Creating mock Google user for development');

      // Create mock Google user with realistic data
      final mockUsers = [
        {
          'email': 'dev.google.user@gmail.com',
          'name': 'Development Google User',
          'photo': 'https://lh3.googleusercontent.com/a/default-user=s96-c',
        },
        {
          'email': 'demo.learner@gmail.com',
          'name': 'Demo Learner',
          'photo': 'https://lh3.googleusercontent.com/a/demo-learner=s96-c',
        },
        {
          'email': 'test.student@gmail.com',
          'name': 'Test Student',
          'photo': 'https://lh3.googleusercontent.com/a/test-student=s96-c',
        },
      ];

      // Randomly select a mock user for variety
      final selectedUser =
          mockUsers[DateTime.now().millisecond % mockUsers.length];

      final user = AppUser(
        uid: 'google_dev_user_${DateTime.now().millisecondsSinceEpoch}',
        email: selectedUser['email']!,
        displayName: selectedUser['name']!,
        photoURL: selectedUser['photo']!,
        emailVerified: true,
        createdAt: DateTime.now(),
        lastSignInAt: DateTime.now(),
        signInMethods: ['google.com'],
        preferences: const UserPreferences(),
      );

      _currentUser = user;
      _authStateController.add(user);

      DevelopmentConfig.devLog('Development Google sign in successful');
      return AuthResult.success(user: user);
    } catch (e) {
      DevelopmentConfig.devLog('Development Google sign in error: $e');
      return AuthResult.error(error: 'Google sign in failed: $e');
    }
  }

  /// Sign out (mock)
  Future<AuthResult> signOut() async {
    try {
      DevelopmentConfig.devLog('Development sign out');

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));

      _currentUser = null;
      _authStateController.add(null);

      DevelopmentConfig.devLog('Development sign out successful');
      return AuthResult.success();
    } catch (e) {
      DevelopmentConfig.devLog('Development sign out error: $e');
      return AuthResult.error(error: 'Sign out failed: $e');
    }
  }

  /// Send password reset email (mock)
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      DevelopmentConfig.devLog('Development password reset for: $email');

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 600));

      // In development, always succeed
      DevelopmentConfig.devLog('Development password reset email sent');
      return AuthResult.success();
    } catch (e) {
      DevelopmentConfig.devLog('Development password reset error: $e');
      return AuthResult.error(error: 'Password reset failed: $e');
    }
  }

  /// Send email verification (mock)
  Future<AuthResult> sendEmailVerification() async {
    try {
      DevelopmentConfig.devLog('Development email verification');

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 400));

      DevelopmentConfig.devLog('Development email verification sent');
      return AuthResult.success();
    } catch (e) {
      DevelopmentConfig.devLog('Development email verification error: $e');
      return AuthResult.error(error: 'Email verification failed: $e');
    }
  }

  /// Update user profile (mock)
  Future<bool> updateUserProfile(
      {String? displayName, String? photoURL}) async {
    try {
      if (_currentUser == null) return false;

      DevelopmentConfig.devLog('Development profile update');

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 400));

      // Update current user
      _currentUser = _currentUser!.copyWith(
        displayName: displayName ?? _currentUser!.displayName,
        photoURL: photoURL ?? _currentUser!.photoURL,
      );

      _authStateController.add(_currentUser);

      DevelopmentConfig.devLog('Development profile updated successfully');
      return true;
    } catch (e) {
      DevelopmentConfig.devLog('Development profile update error: $e');
      return false;
    }
  }

  /// Delete account (mock)
  Future<AuthResult> deleteAccount() async {
    try {
      DevelopmentConfig.devLog('Development account deletion');

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      _currentUser = null;
      _authStateController.add(null);

      DevelopmentConfig.devLog('Development account deleted successfully');
      return AuthResult.success();
    } catch (e) {
      DevelopmentConfig.devLog('Development account deletion error: $e');
      return AuthResult.error(error: 'Account deletion failed: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _authStateController.close();
  }
}

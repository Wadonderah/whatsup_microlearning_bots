import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_result.dart';
import '../models/user_model.dart';

/// Mock authentication service for testing without Firebase
class MockAuthService {
  static final MockAuthService _instance = MockAuthService._();
  static MockAuthService get instance => _instance;
  MockAuthService._();

  final StreamController<AppUser?> _userController =
      StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;

  /// Stream of authentication state changes
  Stream<AppUser?> get userStream => _userController.stream;

  /// Current authenticated user
  AppUser? get currentUser => _currentUser;

  /// Initialize mock auth service
  Future<void> initialize() async {
    debugPrint('MockAuthService: Initializing...');
    await _loadStoredUser();
  }

  /// Create account with email and password (mock)
  Future<AuthResult> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      debugPrint('MockAuthService: Creating account for $email');

      // Simulate network delay
      await Future.delayed(Duration(milliseconds: 500));

      // Check if user already exists
      final prefs = await SharedPreferences.getInstance();
      final existingUsers = prefs.getStringList('mock_users') ?? [];

      if (existingUsers.any((userJson) {
        final userData = jsonDecode(userJson);
        return userData['email'] == email;
      })) {
        return AuthResult.error(
          error: 'An account already exists with this email address.',
          type: AuthResultType.signUp,
        );
      }

      // Create new user
      final user = AppUser(
        uid: 'mock_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: displayName ?? email.split('@')[0],
        emailVerified: false,
        createdAt: DateTime.now(),
        lastSignInAt: DateTime.now(),
        preferences: const UserPreferences(),
      );

      // Store user
      existingUsers.add(jsonEncode(user.toJson()));
      await prefs.setStringList('mock_users', existingUsers);
      await prefs.setString('mock_current_user', jsonEncode(user.toJson()));

      _currentUser = user;
      _userController.add(user);

      debugPrint('MockAuthService: Account created successfully');

      return AuthResult.success(
        user: user,
        type: AuthResultType.signUp,
      );
    } catch (e) {
      debugPrint('MockAuthService: Error creating account: $e');
      return AuthResult.error(
        error: 'Failed to create account: ${e.toString()}',
        type: AuthResultType.signUp,
      );
    }
  }

  /// Sign in with email and password (mock)
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('MockAuthService: Signing in $email');

      // Simulate network delay
      await Future.delayed(Duration(milliseconds: 500));

      // Find user
      final prefs = await SharedPreferences.getInstance();
      final existingUsers = prefs.getStringList('mock_users') ?? [];

      for (final userJson in existingUsers) {
        final userData = jsonDecode(userJson);
        if (userData['email'] == email) {
          final user = AppUser.fromJson(userData);

          // Update last sign in
          final updatedUser = user.copyWith(lastSignInAt: DateTime.now());
          await prefs.setString(
              'mock_current_user', jsonEncode(updatedUser.toJson()));

          _currentUser = updatedUser;
          _userController.add(updatedUser);

          debugPrint('MockAuthService: Sign in successful');

          return AuthResult.success(
            user: updatedUser,
            type: AuthResultType.signIn,
          );
        }
      }

      return AuthResult.error(
        error: 'No user found with this email address.',
        type: AuthResultType.signIn,
      );
    } catch (e) {
      debugPrint('MockAuthService: Error signing in: $e');
      return AuthResult.error(
        error: 'Failed to sign in: ${e.toString()}',
        type: AuthResultType.signIn,
      );
    }
  }

  /// Sign out (mock)
  Future<AuthResult> signOut() async {
    try {
      debugPrint('MockAuthService: Signing out');

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('mock_current_user');

      _currentUser = null;
      _userController.add(null);

      return AuthResult.success(type: AuthResultType.signOut);
    } catch (e) {
      return AuthResult.error(
        error: 'Failed to sign out: ${e.toString()}',
        type: AuthResultType.signOut,
      );
    }
  }

  /// Google Sign-In (mock)
  Future<AuthResult> signInWithGoogle() async {
    return AuthResult.error(
      error:
          'Google Sign-In not available in mock mode. Please set up Firebase.',
      type: AuthResultType.signIn,
    );
  }

  /// Load stored user
  Future<void> _loadStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('mock_current_user');

      if (userJson != null) {
        final userData = jsonDecode(userJson);
        _currentUser = AppUser.fromJson(userData);
        _userController.add(_currentUser);
        debugPrint(
            'MockAuthService: Loaded stored user: ${_currentUser?.email}');
      }
    } catch (e) {
      debugPrint('MockAuthService: Error loading stored user: $e');
    }
  }

  /// Dispose
  void dispose() {
    _userController.close();
  }
}

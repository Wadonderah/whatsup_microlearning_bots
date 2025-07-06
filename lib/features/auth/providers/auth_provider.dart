import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/auth_result.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/auth_service.dart';

// Auth state class
class AuthProviderState {
  final AppUser? user;
  final AuthState authState;
  final String? error;
  final bool isLoading;

  const AuthProviderState({
    this.user,
    this.authState = AuthState.initial,
    this.error,
    this.isLoading = false,
  });

  AuthProviderState copyWith({
    AppUser? user,
    AuthState? authState,
    String? error,
    bool? isLoading,
  }) {
    return AuthProviderState(
      user: user ?? this.user,
      authState: authState ?? this.authState,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isAuthenticated =>
      authState == AuthState.authenticated && user != null;
  bool get hasError => error != null;
}

// Auth provider notifier
class AuthNotifier extends StateNotifier<AuthProviderState> {
  AuthNotifier() : super(const AuthProviderState()) {
    _initialize();
  }

  final AuthService _authService = AuthService.instance;

  void _initialize() {
    // Check if Firebase is initialized before proceeding
    if (Firebase.apps.isEmpty) {
      state = state.copyWith(
        authState: AuthState.error,
        error: 'Firebase not initialized',
        isLoading: false,
      );
      return;
    }

    try {
      // Listen to auth state changes
      _authService.authStateChanges.listen((User? firebaseUser) {
        if (firebaseUser != null) {
          final appUser = AppUser.fromFirebaseUser(firebaseUser);
          state = state.copyWith(
            user: appUser,
            authState: AuthState.authenticated,
            error: null,
          );
        } else {
          state = state.copyWith(
            user: null,
            authState: AuthState.unauthenticated,
            error: null,
          );
        }
      });

      // Check initial auth state
      _checkInitialAuthState();
    } catch (e) {
      state = state.copyWith(
        authState: AuthState.error,
        error: 'Failed to initialize auth: $e',
        isLoading: false,
      );
    }
  }

  Future<void> _checkInitialAuthState() async {
    state = state.copyWith(isLoading: true);

    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        state = state.copyWith(
          user: currentUser,
          authState: AuthState.authenticated,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          authState: AuthState.unauthenticated,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        authState: AuthState.error,
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.isSuccess) {
        state = state.copyWith(
          user: result.user,
          authState: AuthState.authenticated,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          authState: AuthState.error,
          error: result.error,
          isLoading: false,
        );
      }

      return result;
    } catch (e) {
      state = state.copyWith(
        authState: AuthState.error,
        error: e.toString(),
        isLoading: false,
      );
      return AuthResult.error(error: e.toString());
    }
  }

  /// Create user with email and password
  Future<AuthResult> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (result.isSuccess) {
        state = state.copyWith(
          user: result.user,
          authState: AuthState.authenticated,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          authState: AuthState.error,
          error: result.error,
          isLoading: false,
        );
      }

      return result;
    } catch (e) {
      state = state.copyWith(
        authState: AuthState.error,
        error: e.toString(),
        isLoading: false,
      );
      return AuthResult.error(error: e.toString());
    }
  }

  /// Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.signInWithGoogle();

      if (result.isSuccess) {
        state = state.copyWith(
          user: result.user,
          authState: AuthState.authenticated,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          authState: AuthState.error,
          error: result.error,
          isLoading: false,
        );
      }

      return result;
    } catch (e) {
      state = state.copyWith(
        authState: AuthState.error,
        error: e.toString(),
        isLoading: false,
      );
      return AuthResult.error(error: e.toString());
    }
  }

  /// Sign out
  Future<AuthResult> signOut() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.signOut();

      if (result.isSuccess) {
        state = state.copyWith(
          user: null,
          authState: AuthState.unauthenticated,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: result.error,
          isLoading: false,
        );
      }

      return result;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return AuthResult.error(error: e.toString());
    }
  }

  /// Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.sendPasswordResetEmail(email);

      state = state.copyWith(
        error: result.isSuccess ? null : result.error,
        isLoading: false,
      );

      return result;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return AuthResult.error(error: e.toString());
    }
  }

  /// Send email verification
  Future<AuthResult> sendEmailVerification() async {
    try {
      final result = await _authService.sendEmailVerification();

      if (!result.isSuccess) {
        state = state.copyWith(error: result.error);
      }

      return result;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return AuthResult.error(error: e.toString());
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final success = await _authService.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      if (success && state.user != null) {
        final updatedUser = state.user!.copyWith(
          displayName: displayName ?? state.user!.displayName,
          photoURL: photoURL ?? state.user!.photoURL,
        );

        state = state.copyWith(user: updatedUser);
      }

      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Delete account
  Future<AuthResult> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.deleteAccount();

      if (result.isSuccess) {
        state = state.copyWith(
          user: null,
          authState: AuthState.unauthenticated,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: result.error,
          isLoading: false,
        );
      }

      return result;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return AuthResult.error(error: e.toString());
    }
  }
}

// Provider definition
final authProvider =
    StateNotifierProvider<AuthNotifier, AuthProviderState>((ref) {
  return AuthNotifier();
});

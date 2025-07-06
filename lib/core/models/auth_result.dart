import 'package:json_annotation/json_annotation.dart';

import 'user_model.dart';

part 'auth_result.g.dart';

@JsonSerializable()
class AuthResult {
  final AppUser? user;
  final String? error;
  final bool isSuccess;
  final AuthResultType type;

  const AuthResult({
    this.user,
    this.error,
    required this.isSuccess,
    required this.type,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) =>
      _$AuthResultFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResultToJson(this);

  /// Success result
  factory AuthResult.success({
    AppUser? user,
    AuthResultType type = AuthResultType.signIn,
  }) {
    return AuthResult(
      user: user,
      isSuccess: true,
      type: type,
    );
  }

  /// Error result
  factory AuthResult.error({
    required String error,
    AuthResultType type = AuthResultType.signIn,
  }) {
    return AuthResult(
      error: error,
      isSuccess: false,
      type: type,
    );
  }
}

enum AuthResultType {
  @JsonValue('sign_in')
  signIn,
  @JsonValue('sign_up')
  signUp,
  @JsonValue('sign_out')
  signOut,
  @JsonValue('password_reset')
  passwordReset,
  @JsonValue('email_verification')
  emailVerification,
}

/// Authentication state for the app
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Sign-in method types
enum SignInMethod {
  email,
  google,
  apple,
  anonymous,
}

extension SignInMethodExtension on SignInMethod {
  String get displayName {
    switch (this) {
      case SignInMethod.email:
        return 'Email';
      case SignInMethod.google:
        return 'Google';
      case SignInMethod.apple:
        return 'Apple';
      case SignInMethod.anonymous:
        return 'Anonymous';
    }
  }

  String get providerId {
    switch (this) {
      case SignInMethod.email:
        return 'password';
      case SignInMethod.google:
        return 'google.com';
      case SignInMethod.apple:
        return 'apple.com';
      case SignInMethod.anonymous:
        return 'anonymous';
    }
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:whatsup_microlearning_bots/core/models/auth_result.dart';
import 'package:whatsup_microlearning_bots/core/models/user_model.dart';

void main() {
  group('Authentication System Tests', () {
    group('AppUser Model', () {
      test('should create user with required fields', () {
        final user = AppUser(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          emailVerified: true,
        );

        expect(user.uid, equals('test-uid'));
        expect(user.email, equals('test@example.com'));
        expect(user.displayName, equals('Test User'));
        expect(user.emailVerified, isTrue);
        expect(user.signInMethods, isEmpty);
        expect(user.preferences, isA<UserPreferences>());
      });

      test('should generate correct initials', () {
        final userWithFullName = AppUser(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'John Doe',
        );

        final userWithSingleName = AppUser(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'John',
        );

        final userWithoutName = AppUser(
          uid: 'test-uid',
          email: 'test@example.com',
        );

        expect(userWithFullName.initials, equals('JD'));
        expect(userWithSingleName.initials, equals('J'));
        expect(userWithoutName.initials, equals('T'));
      });

      test('should identify sign-in methods correctly', () {
        final googleUser = AppUser(
          uid: 'test-uid',
          email: 'test@example.com',
          signInMethods: ['google.com'],
        );

        final emailUser = AppUser(
          uid: 'test-uid',
          email: 'test@example.com',
          signInMethods: ['password'],
        );

        expect(googleUser.isGoogleUser, isTrue);
        expect(googleUser.isEmailUser, isFalse);
        expect(emailUser.isGoogleUser, isFalse);
        expect(emailUser.isEmailUser, isTrue);
      });

      test('should return display name or email', () {
        final userWithName = AppUser(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'John Doe',
        );

        final userWithoutName = AppUser(
          uid: 'test-uid',
          email: 'test@example.com',
        );

        expect(userWithName.displayNameOrEmail, equals('John Doe'));
        expect(userWithoutName.displayNameOrEmail, equals('test@example.com'));
      });

      test('should copy user with new values', () {
        final original = AppUser(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'John Doe',
          emailVerified: false,
        );

        final updated = original.copyWith(
          displayName: 'Jane Doe',
          emailVerified: true,
        );

        expect(updated.uid, equals(original.uid));
        expect(updated.email, equals(original.email));
        expect(updated.displayName, equals('Jane Doe'));
        expect(updated.emailVerified, isTrue);
      });

      test('should serialize to and from JSON', () {
        final user = AppUser(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'John Doe',
          photoURL: 'https://example.com/photo.jpg',
          emailVerified: true,
          signInMethods: ['google.com'],
          preferences: const UserPreferences(
            theme: 'dark',
            language: 'es',
          ),
        );

        final json = user.toJson();
        final fromJson = AppUser.fromJson(json);

        expect(fromJson.uid, equals(user.uid));
        expect(fromJson.email, equals(user.email));
        expect(fromJson.displayName, equals(user.displayName));
        expect(fromJson.photoURL, equals(user.photoURL));
        expect(fromJson.emailVerified, equals(user.emailVerified));
        expect(fromJson.signInMethods, equals(user.signInMethods));
        expect(fromJson.preferences.theme, equals(user.preferences.theme));
        expect(
            fromJson.preferences.language, equals(user.preferences.language));
      });
    });

    group('UserPreferences Model', () {
      test('should create preferences with default values', () {
        const preferences = UserPreferences();

        expect(preferences.theme, equals('system'));
        expect(preferences.language, equals('en'));
        expect(preferences.notificationsEnabled, isTrue);
        expect(preferences.soundEnabled, isTrue);
        expect(preferences.learningGoal, equals('beginner'));
        expect(preferences.interests, isEmpty);
        expect(preferences.dailyLearningMinutes, equals(15));
      });

      test('should copy preferences with new values', () {
        const original = UserPreferences();

        final updated = original.copyWith(
          theme: 'dark',
          language: 'es',
          dailyLearningMinutes: 30,
          interests: ['programming', 'design'],
        );

        expect(updated.theme, equals('dark'));
        expect(updated.language, equals('es'));
        expect(updated.dailyLearningMinutes, equals(30));
        expect(updated.interests, equals(['programming', 'design']));
        expect(updated.notificationsEnabled,
            equals(original.notificationsEnabled));
      });

      test('should serialize to and from JSON', () {
        const preferences = UserPreferences(
          theme: 'dark',
          language: 'fr',
          notificationsEnabled: false,
          learningGoal: 'advanced',
          interests: ['science', 'technology'],
          dailyLearningMinutes: 45,
        );

        final json = preferences.toJson();
        final fromJson = UserPreferences.fromJson(json);

        expect(fromJson.theme, equals(preferences.theme));
        expect(fromJson.language, equals(preferences.language));
        expect(fromJson.notificationsEnabled,
            equals(preferences.notificationsEnabled));
        expect(fromJson.learningGoal, equals(preferences.learningGoal));
        expect(fromJson.interests, equals(preferences.interests));
        expect(fromJson.dailyLearningMinutes,
            equals(preferences.dailyLearningMinutes));
      });
    });

    group('AuthResult Model', () {
      test('should create success result', () {
        final user = AppUser(
          uid: 'test-uid',
          email: 'test@example.com',
        );

        final result = AuthResult.success(
          user: user,
          type: AuthResultType.signIn,
        );

        expect(result.isSuccess, isTrue);
        expect(result.user, equals(user));
        expect(result.error, isNull);
        expect(result.type, equals(AuthResultType.signIn));
      });

      test('should create error result', () {
        final result = AuthResult.error(
          error: 'Invalid credentials',
          type: AuthResultType.signIn,
        );

        expect(result.isSuccess, isFalse);
        expect(result.user, isNull);
        expect(result.error, equals('Invalid credentials'));
        expect(result.type, equals(AuthResultType.signIn));
      });

      test('should serialize to and from JSON', () {
        final user = AppUser(
          uid: 'test-uid',
          email: 'test@example.com',
        );

        final result = AuthResult.success(
          user: user,
          type: AuthResultType.signUp,
        );

        final json = result.toJson();
        final fromJson = AuthResult.fromJson(json);

        expect(fromJson.isSuccess, equals(result.isSuccess));
        expect(fromJson.user?.uid, equals(result.user?.uid));
        expect(fromJson.error, equals(result.error));
        expect(fromJson.type, equals(result.type));
      });
    });

    group('SignInMethod Extension', () {
      test('should return correct display names', () {
        expect(SignInMethod.email.displayName, equals('Email'));
        expect(SignInMethod.google.displayName, equals('Google'));
        expect(SignInMethod.apple.displayName, equals('Apple'));
        expect(SignInMethod.anonymous.displayName, equals('Anonymous'));
      });

      test('should return correct provider IDs', () {
        expect(SignInMethod.email.providerId, equals('password'));
        expect(SignInMethod.google.providerId, equals('google.com'));
        expect(SignInMethod.apple.providerId, equals('apple.com'));
        expect(SignInMethod.anonymous.providerId, equals('anonymous'));
      });
    });

    group('AuthState Enum', () {
      test('should have all required states', () {
        expect(AuthState.values, contains(AuthState.initial));
        expect(AuthState.values, contains(AuthState.loading));
        expect(AuthState.values, contains(AuthState.authenticated));
        expect(AuthState.values, contains(AuthState.unauthenticated));
        expect(AuthState.values, contains(AuthState.error));
      });
    });

    group('AuthResultType Enum', () {
      test('should have all required types', () {
        expect(AuthResultType.values, contains(AuthResultType.signIn));
        expect(AuthResultType.values, contains(AuthResultType.signUp));
        expect(AuthResultType.values, contains(AuthResultType.signOut));
        expect(AuthResultType.values, contains(AuthResultType.passwordReset));
        expect(
            AuthResultType.values, contains(AuthResultType.emailVerification));
      });
    });
  });
}

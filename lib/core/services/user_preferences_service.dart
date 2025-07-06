import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  static const String _firstTimeUserKey = 'is_first_time_user';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  static UserPreferencesService? _instance;
  static SharedPreferences? _preferences;

  UserPreferencesService._();

  static Future<UserPreferencesService> getInstance() async {
    _instance ??= UserPreferencesService._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  /// Check if this is the first time the user is opening the app
  Future<bool> isFirstTimeUser() async {
    return _preferences?.getBool(_firstTimeUserKey) ?? true;
  }

  /// Mark that the user has opened the app before
  Future<void> setFirstTimeUserComplete() async {
    await _preferences?.setBool(_firstTimeUserKey, false);
  }

  /// Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding() async {
    return _preferences?.getBool(_onboardingCompletedKey) ?? false;
  }

  /// Mark onboarding as completed
  Future<void> setOnboardingCompleted() async {
    await _preferences?.setBool(_onboardingCompletedKey, true);
  }

  /// Reset all preferences (useful for testing)
  Future<void> resetPreferences() async {
    await _preferences?.clear();
  }
}

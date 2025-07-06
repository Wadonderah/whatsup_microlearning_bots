import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

class SettingsService {
  static SettingsService? _instance;
  static SettingsService get instance => _instance ??= SettingsService._();

  SettingsService._();

  static const String _settingsKey = 'app_settings';
  static const String _secureSettingsKey = 'secure_app_settings';

  late SharedPreferences _prefs;
  late FlutterSecureStorage _secureStorage;

  AppSettings _currentSettings = const AppSettings();
  final StreamController<AppSettings> _settingsController =
      StreamController<AppSettings>.broadcast();

  /// Initialize the settings service
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _secureStorage = const FlutterSecureStorage();

      await _loadSettings();
      log('Settings service initialized successfully');
    } catch (e) {
      log('Error initializing settings service: $e');
      rethrow;
    }
  }

  /// Get current settings
  AppSettings get currentSettings => _currentSettings;

  /// Stream of settings changes
  Stream<AppSettings> get settingsStream => _settingsController.stream;

  /// Load settings from storage
  Future<void> _loadSettings() async {
    try {
      // Load non-sensitive settings from SharedPreferences
      final settingsJson = _prefs.getString(_settingsKey);

      if (settingsJson != null) {
        final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;

        // Load sensitive settings from secure storage
        final secureSettingsJson =
            await _secureStorage.read(key: _secureSettingsKey);
        if (secureSettingsJson != null) {
          final secureSettingsMap =
              jsonDecode(secureSettingsJson) as Map<String, dynamic>;
          settingsMap.addAll(secureSettingsMap);
        }

        _currentSettings = AppSettings.fromJson(settingsMap);
      } else {
        // First time - create default settings
        _currentSettings = const AppSettings();
        await _saveSettings();
      }

      _settingsController.add(_currentSettings);
    } catch (e) {
      log('Error loading settings: $e');
      _currentSettings = const AppSettings();
    }
  }

  /// Save settings to storage
  Future<void> _saveSettings() async {
    try {
      final settingsMap = _currentSettings.toJson();

      // Separate sensitive and non-sensitive settings
      final sensitiveKeys = [
        'analyticsEnabled',
        'crashReportingEnabled',
        'personalizedAdsEnabled',
        'dataSharingEnabled',
        'preferredAIModel',
        'aiPersonalityTraits',
      ];

      final secureSettings = <String, dynamic>{};
      final regularSettings = <String, dynamic>{};

      settingsMap.forEach((key, value) {
        if (sensitiveKeys.contains(key)) {
          secureSettings[key] = value;
        } else {
          regularSettings[key] = value;
        }
      });

      // Save regular settings to SharedPreferences
      await _prefs.setString(_settingsKey, jsonEncode(regularSettings));

      // Save sensitive settings to secure storage
      if (secureSettings.isNotEmpty) {
        await _secureStorage.write(
          key: _secureSettingsKey,
          value: jsonEncode(secureSettings),
        );
      }

      _settingsController.add(_currentSettings);
    } catch (e) {
      log('Error saving settings: $e');
      rethrow;
    }
  }

  /// Update settings
  Future<void> updateSettings(AppSettings newSettings) async {
    _currentSettings = newSettings;
    await _saveSettings();
  }

  /// Update specific setting
  Future<void> updateSetting<T>(String key, T value) async {
    final settingsMap = _currentSettings.toJson();
    settingsMap[key] = value;

    try {
      final newSettings = AppSettings.fromJson(settingsMap);
      await updateSettings(newSettings);
    } catch (e) {
      log('Error updating setting $key: $e');
      rethrow;
    }
  }

  // Convenience methods for common settings

  /// Update theme mode
  Future<void> updateThemeMode(ThemeMode themeMode) async {
    await updateSettings(_currentSettings.copyWith(themeMode: themeMode));
  }

  /// Update language
  Future<void> updateLanguage(String language) async {
    await updateSettings(_currentSettings.copyWith(language: language));
  }

  /// Update notification settings
  Future<void> updateNotificationSettings({
    bool? pushNotificationsEnabled,
    bool? learningRemindersEnabled,
    bool? achievementNotificationsEnabled,
    bool? streakRemindersEnabled,
  }) async {
    await updateSettings(_currentSettings.copyWith(
      pushNotificationsEnabled: pushNotificationsEnabled,
      learningRemindersEnabled: learningRemindersEnabled,
      achievementNotificationsEnabled: achievementNotificationsEnabled,
      streakRemindersEnabled: streakRemindersEnabled,
    ));
  }

  /// Update learning settings
  Future<void> updateLearningSettings({
    int? dailyLearningGoalMinutes,
    String? preferredLearningStyle,
    List<String>? interestedTopics,
    DifficultyLevel? defaultDifficulty,
  }) async {
    await updateSettings(_currentSettings.copyWith(
      dailyLearningGoalMinutes: dailyLearningGoalMinutes,
      preferredLearningStyle: preferredLearningStyle,
      interestedTopics: interestedTopics,
      defaultDifficulty: defaultDifficulty,
    ));
  }

  /// Update accessibility settings
  Future<void> updateAccessibilitySettings({
    double? fontSize,
    bool? highContrastMode,
    bool? reduceAnimations,
    bool? screenReaderSupport,
  }) async {
    await updateSettings(_currentSettings.copyWith(
      fontSize: fontSize,
      highContrastMode: highContrastMode,
      reduceAnimations: reduceAnimations,
      screenReaderSupport: screenReaderSupport,
    ));
  }

  /// Update AI settings
  Future<void> updateAISettings({
    String? preferredAIModel,
    double? aiResponseSpeed,
    bool? enableAIPersonalization,
    List<String>? aiPersonalityTraits,
  }) async {
    await updateSettings(_currentSettings.copyWith(
      preferredAIModel: preferredAIModel,
      aiResponseSpeed: aiResponseSpeed,
      enableAIPersonalization: enableAIPersonalization,
      aiPersonalityTraits: aiPersonalityTraits,
    ));
  }

  /// Update privacy settings
  Future<void> updatePrivacySettings({
    bool? analyticsEnabled,
    bool? crashReportingEnabled,
    bool? personalizedAdsEnabled,
    bool? dataSharingEnabled,
  }) async {
    await updateSettings(_currentSettings.copyWith(
      analyticsEnabled: analyticsEnabled,
      crashReportingEnabled: crashReportingEnabled,
      personalizedAdsEnabled: personalizedAdsEnabled,
      dataSharingEnabled: dataSharingEnabled,
    ));
  }

  /// Reset settings to defaults
  Future<void> resetToDefaults() async {
    await updateSettings(const AppSettings());
  }

  /// Export settings as JSON
  Map<String, dynamic> exportSettings() {
    return _currentSettings.toJson();
  }

  /// Import settings from JSON
  Future<void> importSettings(Map<String, dynamic> settingsJson) async {
    try {
      final newSettings = AppSettings.fromJson(settingsJson);
      await updateSettings(newSettings);
    } catch (e) {
      log('Error importing settings: $e');
      rethrow;
    }
  }

  /// Get theme data based on current settings
  ThemeData getThemeData(BuildContext context) {
    final brightness = _getThemeBrightness(context);
    final colorScheme = _getColorScheme(brightness);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: 'Roboto',
      textTheme: _getTextTheme(brightness),
      appBarTheme: _getAppBarTheme(colorScheme),
      elevatedButtonTheme: _getElevatedButtonTheme(colorScheme),
      inputDecorationTheme: _getInputDecorationTheme(colorScheme),
      cardTheme: _getCardTheme(colorScheme),
    );
  }

  Brightness _getThemeBrightness(BuildContext context) {
    switch (_currentSettings.themeMode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness;
    }
  }

  ColorScheme _getColorScheme(Brightness brightness) {
    final seedColor = _getAccentColor();

    return ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
  }

  Color _getAccentColor() {
    switch (_currentSettings.accentColor) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      case 'teal':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  TextTheme _getTextTheme(Brightness brightness) {
    final baseSize = _currentSettings.fontSize;
    final color =
        brightness == Brightness.light ? Colors.black87 : Colors.white;

    return TextTheme(
      displayLarge: TextStyle(
          fontSize: baseSize + 16, color: color, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(
          fontSize: baseSize + 12, color: color, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(
          fontSize: baseSize + 8, color: color, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(
          fontSize: baseSize + 6, color: color, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(
          fontSize: baseSize + 4, color: color, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(
          fontSize: baseSize + 2, color: color, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(
          fontSize: baseSize + 2, color: color, fontWeight: FontWeight.w500),
      titleMedium: TextStyle(
          fontSize: baseSize, color: color, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(
          fontSize: baseSize - 2, color: color, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontSize: baseSize, color: color),
      bodyMedium: TextStyle(fontSize: baseSize - 2, color: color),
      bodySmall: TextStyle(fontSize: baseSize - 4, color: color),
      labelLarge: TextStyle(
          fontSize: baseSize - 2, color: color, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(
          fontSize: baseSize - 4, color: color, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(
          fontSize: baseSize - 6, color: color, fontWeight: FontWeight.w500),
    );
  }

  AppBarTheme _getAppBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
    );
  }

  ElevatedButtonThemeData _getElevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  InputDecorationTheme _getInputDecorationTheme(ColorScheme colorScheme) {
    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
    );
  }

  CardTheme _getCardTheme(ColorScheme colorScheme) {
    return CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  /// Check if a feature is enabled
  bool isFeatureEnabled(String feature) {
    switch (feature) {
      case 'voice_input':
        return _currentSettings.enableVoiceInput;
      case 'text_to_speech':
        return _currentSettings.enableTextToSpeech;
      case 'analytics':
        return _currentSettings.analyticsEnabled;
      case 'crash_reporting':
        return _currentSettings.crashReportingEnabled;
      case 'auto_backup':
        return _currentSettings.autoBackupEnabled;
      case 'ai_personalization':
        return _currentSettings.enableAIPersonalization;
      default:
        return false;
    }
  }

  /// Get available languages
  List<Map<String, String>> getAvailableLanguages() {
    return [
      {'code': 'en', 'name': 'English', 'nativeName': 'English'},
      {'code': 'es', 'name': 'Spanish', 'nativeName': 'Español'},
      {'code': 'fr', 'name': 'French', 'nativeName': 'Français'},
      {'code': 'de', 'name': 'German', 'nativeName': 'Deutsch'},
      {'code': 'it', 'name': 'Italian', 'nativeName': 'Italiano'},
      {'code': 'pt', 'name': 'Portuguese', 'nativeName': 'Português'},
      {'code': 'ru', 'name': 'Russian', 'nativeName': 'Русский'},
      {'code': 'ja', 'name': 'Japanese', 'nativeName': '日本語'},
      {'code': 'ko', 'name': 'Korean', 'nativeName': '한국어'},
      {'code': 'zh', 'name': 'Chinese', 'nativeName': '中文'},
      {'code': 'ar', 'name': 'Arabic', 'nativeName': 'العربية'},
      {'code': 'hi', 'name': 'Hindi', 'nativeName': 'हिन्दी'},
    ];
  }

  /// Get available accent colors
  List<Map<String, dynamic>> getAvailableAccentColors() {
    return [
      {'code': 'blue', 'name': 'Blue', 'color': Colors.blue},
      {'code': 'green', 'name': 'Green', 'color': Colors.green},
      {'code': 'purple', 'name': 'Purple', 'color': Colors.purple},
      {'code': 'orange', 'name': 'Orange', 'color': Colors.orange},
      {'code': 'red', 'name': 'Red', 'color': Colors.red},
      {'code': 'teal', 'name': 'Teal', 'color': Colors.teal},
      {'code': 'indigo', 'name': 'Indigo', 'color': Colors.indigo},
      {'code': 'pink', 'name': 'Pink', 'color': Colors.pink},
    ];
  }

  /// Dispose resources
  void dispose() {
    _settingsController.close();
  }
}

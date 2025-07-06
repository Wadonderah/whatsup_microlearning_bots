import 'package:flutter/foundation.dart';

/// Application configuration
class AppConfig {
  /// Whether to use mock services for development
  /// Set to true when Firebase is not configured
  static const bool useMockServices = kDebugMode;
  
  /// Whether Firebase is properly configured
  /// This should be set to true once you have a real Firebase project
  static const bool isFirebaseConfigured = false;
  
  /// Whether to show detailed error messages
  static const bool showDetailedErrors = kDebugMode;
  
  /// App version
  static const String appVersion = '1.0.0';
  
  /// App name
  static const String appName = 'WhatsApp MicroLearning Bot';
  
  /// Whether to enable analytics
  static const bool enableAnalytics = !kDebugMode;
  
  /// Whether to enable crash reporting
  static const bool enableCrashReporting = !kDebugMode;
  
  /// Default language
  static const String defaultLanguage = 'en';
  
  /// Supported languages
  static const List<String> supportedLanguages = ['en', 'es', 'fr', 'de'];
  
  /// API endpoints
  static const String baseApiUrl = kDebugMode 
      ? 'https://api-dev.example.com' 
      : 'https://api.example.com';
  
  /// Feature flags
  static const bool enableVoiceFeatures = true;
  static const bool enableOfflineMode = true;
  static const bool enableSocialFeatures = true;
  static const bool enableExportFeatures = true;
  
  /// Development helpers
  static const bool showDebugInfo = kDebugMode;
  static const bool enableTestMode = kDebugMode;
}

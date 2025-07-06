import 'package:flutter/foundation.dart';

/// Development configuration for testing without Firebase
class DevelopmentConfig {
  static const bool enableFirebase = false; // Set to false for local testing
  static const bool enableGoogleSignIn = false; // Set to false for Windows testing
  static const bool enableLocalAuth = true; // Enable local authentication simulation
  static const bool enableOfflineMode = true; // Enable offline mode for testing
  
  // Mock user data for testing
  static const Map<String, String> mockUsers = {
    'test@example.com': 'password123',
    'demo@test.com': 'demo123',
    'wadondera@gmail.com': 'test123',
  };
  
  // Development Firebase configuration (safe placeholders)
  static const String devProjectId = 'whatsup-microlearning-dev';
  static const String devApiKey = 'dev-api-key-placeholder';
  static const String devAppId = 'dev-app-id-placeholder';
  static const String devMessagingSenderId = 'dev-sender-id';
  
  /// Check if we're in development mode
  static bool get isDevelopmentMode {
    return kDebugMode && !enableFirebase;
  }
  
  /// Get development user for testing
  static String? getMockUser(String email) {
    return mockUsers[email];
  }
  
  /// Validate mock credentials
  static bool validateMockCredentials(String email, String password) {
    return mockUsers.containsKey(email) && mockUsers[email] == password;
  }
  
  /// Generate mock user ID
  static String generateMockUserId(String email) {
    return 'mock_${email.replaceAll('@', '_').replaceAll('.', '_')}';
  }
  
  /// Development logging
  static void devLog(String message) {
    if (kDebugMode) {
      print('[DEV] $message');
    }
  }
  
  /// Show development warnings
  static void showDevWarning() {
    if (isDevelopmentMode) {
      devLog('⚠️ Running in DEVELOPMENT MODE - Firebase disabled');
      devLog('📝 Using mock authentication for testing');
      devLog('🔧 To enable Firebase: Set enableFirebase = true in development_config.dart');
    }
  }
}

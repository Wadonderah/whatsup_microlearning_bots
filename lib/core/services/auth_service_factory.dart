import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import 'auth_service.dart';
import 'development_auth_service.dart';

/// Factory to determine which auth service to use based on Firebase configuration
class AuthServiceFactory {
  static bool? _isFirebaseConfigured;

  /// Check if Firebase is properly configured
  static bool get isFirebaseConfigured {
    if (_isFirebaseConfigured != null) return _isFirebaseConfigured!;

    _isFirebaseConfigured = _checkFirebaseConfiguration();
    return _isFirebaseConfigured!;
  }

  /// Get the appropriate auth service
  static dynamic getAuthService() {
    if (isFirebaseConfigured) {
      debugPrint('🔥 Using Firebase AuthService');
      return AuthService.instance;
    } else {
      debugPrint('🧪 Using Development AuthService (Firebase not configured)');
      return DevelopmentAuthService.instance;
    }
  }

  /// Check if Firebase configuration is valid
  static bool _checkFirebaseConfiguration() {
    try {
      // Get the current platform's Firebase options
      final options = DefaultFirebaseOptions.currentPlatform;
      final apiKey = options.apiKey;
      final projectId = options.projectId;

      // Check for demo/placeholder values
      final isDemoApiKey = apiKey.isEmpty ||
          apiKey.contains('Demo') ||
          apiKey.contains('Replace') ||
          apiKey.contains('demo') ||
          apiKey.contains('replace');

      final isDemoProjectId = projectId.isEmpty ||
          projectId.contains('demo') ||
          projectId.contains('Demo') ||
          projectId == 'whatsup-microlearning-demo';

      if (isDemoApiKey || isDemoProjectId) {
        debugPrint(
            '⚠️ Firebase not configured - detected demo/placeholder values');
        debugPrint(
            '   API Key: ${apiKey.length > 20 ? '${apiKey.substring(0, 20)}...' : apiKey}');
        debugPrint('   Project ID: $projectId');
        debugPrint('💡 To use real Firebase:');
        debugPrint(
            '   1. Create a Firebase project at https://console.firebase.google.com');
        debugPrint('   2. Run: flutterfire configure');
        debugPrint('   3. Update lib/firebase_options.dart with real values');
        debugPrint('🔧 Using development auth service instead');
        return false;
      }

      debugPrint('✅ Firebase configuration appears valid');
      return true;
    } catch (e) {
      debugPrint('❌ Error checking Firebase configuration: $e');
      debugPrint('🔧 Using development auth service instead');
      return false;
    }
  }

  /// Force refresh of Firebase configuration check
  static void refreshConfiguration() {
    _isFirebaseConfigured = null;
  }
}

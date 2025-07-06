import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration utility class
/// Provides type-safe access to environment variables
class EnvironmentConfig {
  // Private constructor to prevent instantiation
  EnvironmentConfig._();

  /// Initialize environment configuration
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
  }

  // OpenRouter API Configuration
  static String get openRouterApiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';
  static String get openRouterBaseUrl => dotenv.env['OPENROUTER_BASE_URL'] ?? 'https://openrouter.ai/api/v1';

  // AI Model Configuration
  static String get defaultAiModel => dotenv.env['DEFAULT_AI_MODEL'] ?? 'openai/gpt-3.5-turbo';
  static int get maxTokens => int.tryParse(dotenv.env['MAX_TOKENS'] ?? '1000') ?? 1000;
  static double get temperature => double.tryParse(dotenv.env['TEMPERATURE'] ?? '0.7') ?? 0.7;
  static int get maxChatHistory => int.tryParse(dotenv.env['MAX_CHAT_HISTORY'] ?? '50') ?? 50;

  // Learning Configuration
  static int get defaultSessionDuration => int.tryParse(dotenv.env['DEFAULT_SESSION_DURATION'] ?? '15') ?? 15;
  static int get maxDailyLearningMinutes => int.tryParse(dotenv.env['MAX_DAILY_LEARNING_MINUTES'] ?? '120') ?? 120;
  static int get streakResetHours => int.tryParse(dotenv.env['STREAK_RESET_HOURS'] ?? '24') ?? 24;

  // Notification Configuration
  static bool get enablePushNotifications => _parseBool(dotenv.env['ENABLE_PUSH_NOTIFICATIONS'] ?? 'true');
  static bool get enableLocalNotifications => _parseBool(dotenv.env['ENABLE_LOCAL_NOTIFICATIONS'] ?? 'true');
  static String get defaultNotificationChannel => dotenv.env['DEFAULT_NOTIFICATION_CHANNEL'] ?? 'microlearning_channel';

  // Authentication Configuration
  static bool get enableEmailAuth => _parseBool(dotenv.env['ENABLE_EMAIL_AUTH'] ?? 'true');
  static bool get enableGoogleSignin => _parseBool(dotenv.env['ENABLE_GOOGLE_SIGNIN'] ?? 'true');
  static bool get enableAppleSignin => _parseBool(dotenv.env['ENABLE_APPLE_SIGNIN'] ?? 'true');
  static String get googleWebClientId => dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
  static int get minPasswordLength => int.tryParse(dotenv.env['MIN_PASSWORD_LENGTH'] ?? '6') ?? 6;

  // Firestore Configuration
  static bool get enableFirestoreOffline => _parseBool(dotenv.env['ENABLE_FIRESTORE_OFFLINE'] ?? 'true');
  static String get firestoreCacheSize => dotenv.env['FIRESTORE_CACHE_SIZE'] ?? '40MB';
  static bool get enableFirestoreLogging => _parseBool(dotenv.env['ENABLE_FIRESTORE_LOGGING'] ?? 'true');
  static int get maxChatHistoryDays => int.tryParse(dotenv.env['MAX_CHAT_HISTORY_DAYS'] ?? '30') ?? 30;
  static int get maxLearningSessionsStored => int.tryParse(dotenv.env['MAX_LEARNING_SESSIONS_STORED'] ?? '100') ?? 100;

  // App Configuration
  static String get appName => dotenv.env['APP_NAME'] ?? 'WhatsApp MicroLearning Bot';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static bool get enableAnalytics => _parseBool(dotenv.env['ENABLE_ANALYTICS'] ?? 'true');
  static bool get enableCrashReporting => _parseBool(dotenv.env['ENABLE_CRASH_REPORTING'] ?? 'true');

  // Development Configuration
  static bool get isDebugMode => _parseBool(dotenv.env['DEBUG_MODE'] ?? 'false');
  static bool get enableLogging => _parseBool(dotenv.env['ENABLE_LOGGING'] ?? 'true');
  static String get logLevel => dotenv.env['LOG_LEVEL'] ?? 'info';

  // Security Configuration
  static bool get enableBiometricAuth => _parseBool(dotenv.env['ENABLE_BIOMETRIC_AUTH'] ?? 'false');
  static int get sessionTimeoutMinutes => int.tryParse(dotenv.env['SESSION_TIMEOUT_MINUTES'] ?? '30') ?? 30;
  static bool get enableSecureStorage => _parseBool(dotenv.env['ENABLE_SECURE_STORAGE'] ?? 'true');

  // Performance Configuration
  static int get imageCompressionQuality => int.tryParse(dotenv.env['IMAGE_COMPRESSION_QUALITY'] ?? '80') ?? 80;
  static int get maxImageSizeMB => int.tryParse(dotenv.env['MAX_IMAGE_SIZE_MB'] ?? '5') ?? 5;
  static int get networkTimeoutSeconds => int.tryParse(dotenv.env['NETWORK_TIMEOUT_SECONDS'] ?? '30') ?? 30;

  // Feature Flags
  static bool get enableOfflineMode => _parseBool(dotenv.env['ENABLE_OFFLINE_MODE'] ?? 'true');
  static bool get enableDarkMode => _parseBool(dotenv.env['ENABLE_DARK_MODE'] ?? 'true');
  static bool get enableVoiceInput => _parseBool(dotenv.env['ENABLE_VOICE_INPUT'] ?? 'false');
  static bool get enableImageGeneration => _parseBool(dotenv.env['ENABLE_IMAGE_GENERATION'] ?? 'false');

  // Utility Methods
  
  /// Parse boolean from string
  static bool _parseBool(String value) {
    return value.toLowerCase() == 'true' || value == '1';
  }

  /// Get environment variable with fallback
  static String getEnv(String key, [String fallback = '']) {
    return dotenv.env[key] ?? fallback;
  }

  /// Get integer environment variable with fallback
  static int getEnvInt(String key, [int fallback = 0]) {
    return int.tryParse(dotenv.env[key] ?? '') ?? fallback;
  }

  /// Get double environment variable with fallback
  static double getEnvDouble(String key, [double fallback = 0.0]) {
    return double.tryParse(dotenv.env[key] ?? '') ?? fallback;
  }

  /// Get boolean environment variable with fallback
  static bool getEnvBool(String key, [bool fallback = false]) {
    return _parseBool(dotenv.env[key] ?? fallback.toString());
  }

  /// Check if environment variable exists
  static bool hasEnv(String key) {
    return dotenv.env.containsKey(key);
  }

  /// Get all environment variables (for debugging)
  static Map<String, String> getAllEnv() {
    return Map<String, String>.from(dotenv.env);
  }

  /// Validate required environment variables
  static List<String> validateRequiredEnv() {
    final required = <String>[
      'OPENROUTER_API_KEY',
      'GOOGLE_WEB_CLIENT_ID',
    ];

    final missing = <String>[];
    for (final key in required) {
      if (!hasEnv(key) || getEnv(key).isEmpty) {
        missing.add(key);
      }
    }

    return missing;
  }

  /// Get configuration summary for debugging
  static Map<String, dynamic> getConfigSummary() {
    return {
      'app': {
        'name': appName,
        'version': appVersion,
        'debug': isDebugMode,
      },
      'ai': {
        'model': defaultAiModel,
        'maxTokens': maxTokens,
        'temperature': temperature,
      },
      'auth': {
        'emailAuth': enableEmailAuth,
        'googleSignin': enableGoogleSignin,
        'appleSignin': enableAppleSignin,
      },
      'firestore': {
        'offline': enableFirestoreOffline,
        'cacheSize': firestoreCacheSize,
        'logging': enableFirestoreLogging,
      },
      'notifications': {
        'push': enablePushNotifications,
        'local': enableLocalNotifications,
      },
      'features': {
        'offlineMode': enableOfflineMode,
        'darkMode': enableDarkMode,
        'voiceInput': enableVoiceInput,
        'imageGeneration': enableImageGeneration,
      },
    };
  }
}

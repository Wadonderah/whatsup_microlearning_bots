import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../models/firestore_models.dart';
import '../models/learning_category.dart';
import '../models/study_plan.dart';

class OfflineService {
  static OfflineService? _instance;
  static OfflineService get instance => _instance ??= OfflineService._();

  OfflineService._();

  // Hive boxes
  late Box<Map<dynamic, dynamic>> _conversationsBox;
  late Box<Map<dynamic, dynamic>> _categoriesBox;
  late Box<Map<dynamic, dynamic>> _topicsBox;
  late Box<Map<dynamic, dynamic>> _studyPlansBox;
  late Box<Map<dynamic, dynamic>> _progressBox;
  late Box<Map<dynamic, dynamic>> _settingsBox;
  late Box<String> _cacheBox;

  // Connectivity
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isOnline = true;
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  // Cache settings
  static const int maxCachedConversations = 50;
  static const int maxCachedTopics = 100;
  static const Duration cacheExpiry = Duration(days: 7);

  /// Initialize offline service
  Future<void> initialize() async {
    try {
      // Initialize Hive
      final appDocumentDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocumentDir.path);

      // Open boxes
      _conversationsBox =
          await Hive.openBox<Map<dynamic, dynamic>>('conversations');
      _categoriesBox = await Hive.openBox<Map<dynamic, dynamic>>('categories');
      _topicsBox = await Hive.openBox<Map<dynamic, dynamic>>('topics');
      _studyPlansBox = await Hive.openBox<Map<dynamic, dynamic>>('study_plans');
      _progressBox = await Hive.openBox<Map<dynamic, dynamic>>('progress');
      _settingsBox = await Hive.openBox<Map<dynamic, dynamic>>('settings');
      _cacheBox = await Hive.openBox<String>('cache');

      // Initialize connectivity monitoring
      await _initializeConnectivity();

      log('Offline service initialized successfully');
    } catch (e) {
      log('Error initializing offline service: $e');
      rethrow;
    }
  }

  /// Initialize connectivity monitoring
  Future<void> _initializeConnectivity() async {
    try {
      final connectivity = Connectivity();

      // Check initial connectivity
      final result = await connectivity.checkConnectivity();
      _isOnline = !result.contains(ConnectivityResult.none);
      _connectivityController.add(_isOnline);

      // Listen for connectivity changes
      _connectivitySubscription =
          connectivity.onConnectivityChanged.listen((results) {
        final wasOnline = _isOnline;
        _isOnline = !results.contains(ConnectivityResult.none);

        if (wasOnline != _isOnline) {
          _connectivityController.add(_isOnline);
          log('Connectivity changed: ${_isOnline ? 'Online' : 'Offline'}');
        }
      });
    } catch (e) {
      log('Error initializing connectivity: $e');
    }
  }

  /// Get connectivity status
  bool get isOnline => _isOnline;

  /// Stream of connectivity changes
  Stream<bool> get connectivityStream => _connectivityController.stream;

  // Chat session caching
  /// Cache a chat session
  Future<void> cacheChatSession(ChatSession chatSession) async {
    try {
      final sessionData = chatSession.toJson();
      sessionData['cachedAt'] = DateTime.now().toIso8601String();

      await _conversationsBox.put(chatSession.id, sessionData);

      // Cleanup old conversations if needed
      await _cleanupOldConversations();

      log('Chat session cached: ${chatSession.id}');
    } catch (e) {
      log('Error caching chat session: $e');
    }
  }

  /// Get cached chat sessions
  Future<List<ChatSession>> getCachedChatSessions(String userId) async {
    try {
      final sessions = <ChatSession>[];

      for (final entry in _conversationsBox.toMap().entries) {
        final data = Map<String, dynamic>.from(entry.value);

        // Check if session belongs to user
        if (data['userId'] == userId) {
          // Check if cache is still valid
          final cachedAt = DateTime.parse(data['cachedAt']);
          if (DateTime.now().difference(cachedAt) < cacheExpiry) {
            data.remove('cachedAt');
            sessions.add(ChatSession.fromJson(data));
          }
        }
      }

      // Sort by updated time
      sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      return sessions;
    } catch (e) {
      log('Error getting cached chat sessions: $e');
      return [];
    }
  }

  /// Get a specific cached chat session
  Future<ChatSession?> getCachedChatSession(String sessionId) async {
    try {
      final data = _conversationsBox.get(sessionId);
      if (data != null) {
        final sessionData = Map<String, dynamic>.from(data);

        // Check if cache is still valid
        final cachedAt = DateTime.parse(sessionData['cachedAt']);
        if (DateTime.now().difference(cachedAt) < cacheExpiry) {
          sessionData.remove('cachedAt');
          return ChatSession.fromJson(sessionData);
        } else {
          // Remove expired cache
          await _conversationsBox.delete(sessionId);
        }
      }
      return null;
    } catch (e) {
      log('Error getting cached chat session: $e');
      return null;
    }
  }

  /// Remove cached chat session
  Future<void> removeCachedChatSession(String sessionId) async {
    try {
      await _conversationsBox.delete(sessionId);
      log('Chat session removed from cache: $sessionId');
    } catch (e) {
      log('Error removing cached chat session: $e');
    }
  }

  /// Cleanup old chat sessions
  Future<void> _cleanupOldConversations() async {
    try {
      final entries = _conversationsBox.toMap().entries.toList();

      // Sort by cached time
      entries.sort((a, b) {
        final aTime = DateTime.parse(a.value['cachedAt']);
        final bTime = DateTime.parse(b.value['cachedAt']);
        return bTime.compareTo(aTime);
      });

      // Remove excess chat sessions
      if (entries.length > maxCachedConversations) {
        for (int i = maxCachedConversations; i < entries.length; i++) {
          await _conversationsBox.delete(entries[i].key);
        }
      }

      // Remove expired chat sessions
      final now = DateTime.now();
      for (final entry in entries) {
        final cachedAt = DateTime.parse(entry.value['cachedAt']);
        if (now.difference(cachedAt) > cacheExpiry) {
          await _conversationsBox.delete(entry.key);
        }
      }
    } catch (e) {
      log('Error cleaning up chat sessions: $e');
    }
  }

  // Learning content caching
  /// Cache learning categories
  Future<void> cacheLearningCategories(
      List<LearningCategory> categories) async {
    try {
      for (final category in categories) {
        final categoryData = category.toJson();
        categoryData['cachedAt'] = DateTime.now().toIso8601String();
        await _categoriesBox.put(category.id, categoryData);
      }
      log('${categories.length} categories cached');
    } catch (e) {
      log('Error caching categories: $e');
    }
  }

  /// Get cached learning categories
  Future<List<LearningCategory>> getCachedLearningCategories() async {
    try {
      final categories = <LearningCategory>[];

      for (final entry in _categoriesBox.toMap().entries) {
        final data = Map<String, dynamic>.from(entry.value);

        // Check if cache is still valid
        final cachedAt = DateTime.parse(data['cachedAt']);
        if (DateTime.now().difference(cachedAt) < cacheExpiry) {
          data.remove('cachedAt');
          categories.add(LearningCategory.fromJson(data));
        }
      }

      return categories;
    } catch (e) {
      log('Error getting cached categories: $e');
      return [];
    }
  }

  /// Cache learning topics
  Future<void> cacheLearningTopics(
      String categoryId, List<LearningTopic> topics) async {
    try {
      final topicsData = {
        'categoryId': categoryId,
        'topics': topics.map((t) => t.toJson()).toList(),
        'cachedAt': DateTime.now().toIso8601String(),
      };

      await _topicsBox.put(categoryId, topicsData);
      log('${topics.length} topics cached for category: $categoryId');
    } catch (e) {
      log('Error caching topics: $e');
    }
  }

  /// Get cached learning topics
  Future<List<LearningTopic>> getCachedLearningTopics(String categoryId) async {
    try {
      final data = _topicsBox.get(categoryId);
      if (data != null) {
        final topicsData = Map<String, dynamic>.from(data);

        // Check if cache is still valid
        final cachedAt = DateTime.parse(topicsData['cachedAt']);
        if (DateTime.now().difference(cachedAt) < cacheExpiry) {
          final topicsList = topicsData['topics'] as List;
          return topicsList
              .map((t) => LearningTopic.fromJson(Map<String, dynamic>.from(t)))
              .toList();
        } else {
          // Remove expired cache
          await _topicsBox.delete(categoryId);
        }
      }
      return [];
    } catch (e) {
      log('Error getting cached topics: $e');
      return [];
    }
  }

  // Study plans caching
  /// Cache study plans
  Future<void> cacheStudyPlans(
      String userId, List<StudyPlan> studyPlans) async {
    try {
      final plansData = {
        'userId': userId,
        'plans': studyPlans.map((p) => p.toJson()).toList(),
        'cachedAt': DateTime.now().toIso8601String(),
      };

      await _studyPlansBox.put(userId, plansData);
      log('${studyPlans.length} study plans cached for user: $userId');
    } catch (e) {
      log('Error caching study plans: $e');
    }
  }

  /// Get cached study plans
  Future<List<StudyPlan>> getCachedStudyPlans(String userId) async {
    try {
      final data = _studyPlansBox.get(userId);
      if (data != null) {
        final plansData = Map<String, dynamic>.from(data);

        // Check if cache is still valid
        final cachedAt = DateTime.parse(plansData['cachedAt']);
        if (DateTime.now().difference(cachedAt) < cacheExpiry) {
          final plansList = plansData['plans'] as List;
          return plansList
              .map((p) => StudyPlan.fromJson(Map<String, dynamic>.from(p)))
              .toList();
        } else {
          // Remove expired cache
          await _studyPlansBox.delete(userId);
        }
      }
      return [];
    } catch (e) {
      log('Error getting cached study plans: $e');
      return [];
    }
  }

  // Progress caching
  /// Cache user progress
  Future<void> cacheUserProgress(
      String userId, List<UserTopicProgress> progress) async {
    try {
      final progressData = {
        'userId': userId,
        'progress': progress.map((p) => p.toJson()).toList(),
        'cachedAt': DateTime.now().toIso8601String(),
      };

      await _progressBox.put(userId, progressData);
      log('${progress.length} progress entries cached for user: $userId');
    } catch (e) {
      log('Error caching user progress: $e');
    }
  }

  /// Get cached user progress
  Future<List<UserTopicProgress>> getCachedUserProgress(String userId) async {
    try {
      final data = _progressBox.get(userId);
      if (data != null) {
        final progressData = Map<String, dynamic>.from(data);

        // Check if cache is still valid
        final cachedAt = DateTime.parse(progressData['cachedAt']);
        if (DateTime.now().difference(cachedAt) < cacheExpiry) {
          final progressList = progressData['progress'] as List;
          return progressList
              .map((p) =>
                  UserTopicProgress.fromJson(Map<String, dynamic>.from(p)))
              .toList();
        } else {
          // Remove expired cache
          await _progressBox.delete(userId);
        }
      }
      return [];
    } catch (e) {
      log('Error getting cached user progress: $e');
      return [];
    }
  }

  // Settings caching
  /// Cache app settings
  Future<void> cacheAppSettings(
      String key, Map<String, dynamic> settings) async {
    try {
      final settingsData = {
        ...settings,
        'cachedAt': DateTime.now().toIso8601String(),
      };

      await _settingsBox.put(key, settingsData);
      log('Settings cached: $key');
    } catch (e) {
      log('Error caching settings: $e');
    }
  }

  /// Get cached app settings
  Future<Map<String, dynamic>?> getCachedAppSettings(String key) async {
    try {
      final data = _settingsBox.get(key);
      if (data != null) {
        final settingsData = Map<String, dynamic>.from(data);

        // Check if cache is still valid
        final cachedAt = DateTime.parse(settingsData['cachedAt']);
        if (DateTime.now().difference(cachedAt) < cacheExpiry) {
          settingsData.remove('cachedAt');
          return settingsData;
        } else {
          // Remove expired cache
          await _settingsBox.delete(key);
        }
      }
      return null;
    } catch (e) {
      log('Error getting cached settings: $e');
      return null;
    }
  }

  // Generic cache methods
  /// Cache any data with a key
  Future<void> cacheData(String key, dynamic data) async {
    try {
      final cacheData = {
        'data': data,
        'cachedAt': DateTime.now().toIso8601String(),
      };

      await _cacheBox.put(key, jsonEncode(cacheData));
      log('Data cached: $key');
    } catch (e) {
      log('Error caching data: $e');
    }
  }

  /// Get cached data
  Future<T?> getCachedData<T>(
      String key, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final cachedJson = _cacheBox.get(key);
      if (cachedJson != null) {
        final cacheData = jsonDecode(cachedJson) as Map<String, dynamic>;

        // Check if cache is still valid
        final cachedAt = DateTime.parse(cacheData['cachedAt']);
        if (DateTime.now().difference(cachedAt) < cacheExpiry) {
          return fromJson(cacheData['data']);
        } else {
          // Remove expired cache
          await _cacheBox.delete(key);
        }
      }
      return null;
    } catch (e) {
      log('Error getting cached data: $e');
      return null;
    }
  }

  /// Clear all cached data
  Future<void> clearAllCache() async {
    try {
      await _conversationsBox.clear();
      await _categoriesBox.clear();
      await _topicsBox.clear();
      await _studyPlansBox.clear();
      await _progressBox.clear();
      await _settingsBox.clear();
      await _cacheBox.clear();

      log('All cache cleared');
    } catch (e) {
      log('Error clearing cache: $e');
    }
  }

  /// Clear expired cache entries
  Future<void> clearExpiredCache() async {
    try {
      final now = DateTime.now();

      // Clear expired chat sessions
      final conversationKeys = _conversationsBox.keys.toList();
      for (final key in conversationKeys) {
        final data = _conversationsBox.get(key);
        if (data != null) {
          final cachedAt = DateTime.parse(data['cachedAt']);
          if (now.difference(cachedAt) > cacheExpiry) {
            await _conversationsBox.delete(key);
          }
        }
      }

      // Clear expired categories
      final categoryKeys = _categoriesBox.keys.toList();
      for (final key in categoryKeys) {
        final data = _categoriesBox.get(key);
        if (data != null) {
          final cachedAt = DateTime.parse(data['cachedAt']);
          if (now.difference(cachedAt) > cacheExpiry) {
            await _categoriesBox.delete(key);
          }
        }
      }

      // Clear expired topics
      final topicKeys = _topicsBox.keys.toList();
      for (final key in topicKeys) {
        final data = _topicsBox.get(key);
        if (data != null) {
          final cachedAt = DateTime.parse(data['cachedAt']);
          if (now.difference(cachedAt) > cacheExpiry) {
            await _topicsBox.delete(key);
          }
        }
      }

      // Clear expired study plans
      final planKeys = _studyPlansBox.keys.toList();
      for (final key in planKeys) {
        final data = _studyPlansBox.get(key);
        if (data != null) {
          final cachedAt = DateTime.parse(data['cachedAt']);
          if (now.difference(cachedAt) > cacheExpiry) {
            await _studyPlansBox.delete(key);
          }
        }
      }

      // Clear expired progress
      final progressKeys = _progressBox.keys.toList();
      for (final key in progressKeys) {
        final data = _progressBox.get(key);
        if (data != null) {
          final cachedAt = DateTime.parse(data['cachedAt']);
          if (now.difference(cachedAt) > cacheExpiry) {
            await _progressBox.delete(key);
          }
        }
      }

      // Clear expired settings
      final settingsKeys = _settingsBox.keys.toList();
      for (final key in settingsKeys) {
        final data = _settingsBox.get(key);
        if (data != null) {
          final cachedAt = DateTime.parse(data['cachedAt']);
          if (now.difference(cachedAt) > cacheExpiry) {
            await _settingsBox.delete(key);
          }
        }
      }

      // Clear expired generic cache
      final cacheKeys = _cacheBox.keys.toList();
      for (final key in cacheKeys) {
        final cachedJson = _cacheBox.get(key);
        if (cachedJson != null) {
          final cacheData = jsonDecode(cachedJson) as Map<String, dynamic>;
          final cachedAt = DateTime.parse(cacheData['cachedAt']);
          if (now.difference(cachedAt) > cacheExpiry) {
            await _cacheBox.delete(key);
          }
        }
      }

      log('Expired cache cleared');
    } catch (e) {
      log('Error clearing expired cache: $e');
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      return {
        'chatSessions': _conversationsBox.length,
        'categories': _categoriesBox.length,
        'topics': _topicsBox.length,
        'studyPlans': _studyPlansBox.length,
        'progress': _progressBox.length,
        'settings': _settingsBox.length,
        'genericCache': _cacheBox.length,
        'isOnline': _isOnline,
      };
    } catch (e) {
      log('Error getting cache stats: $e');
      return {};
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription.cancel();
    _connectivityController.close();
  }
}

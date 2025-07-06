import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/firestore_models.dart';
import '../utils/environment_config.dart';

class FirestoreService {
  static FirestoreService? _instance;
  static FirestoreService get instance => _instance ??= FirestoreService._();

  FirestoreService._();

  late final FirebaseFirestore _firestore;
  bool _isInitialized = false;

  /// Initialize Firestore with configuration
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _firestore = FirebaseFirestore.instance;

      // Configure Firestore settings
      final settings = Settings(
        persistenceEnabled: EnvironmentConfig.enableFirestoreOffline,
        cacheSizeBytes: _parseCacheSize(EnvironmentConfig.firestoreCacheSize),
      );

      _firestore.settings = settings;

      // Enable logging in debug mode
      if (kDebugMode && EnvironmentConfig.enableFirestoreLogging) {
        FirebaseFirestore.setLoggingEnabled(true);
      }

      _isInitialized = true;
      log('Firestore service initialized successfully');
    } catch (e) {
      log('Error initializing Firestore service: $e');
      rethrow;
    }
  }

  /// Parse cache size from string (e.g., "40MB" -> bytes)
  int _parseCacheSize(String cacheSize) {
    final regex = RegExp(r'(\d+)(MB|GB|KB)?');
    final match = regex.firstMatch(cacheSize.toUpperCase());

    if (match == null) return Settings.CACHE_SIZE_UNLIMITED;

    final number = int.parse(match.group(1)!);
    final unit = match.group(2) ?? 'MB';

    switch (unit) {
      case 'KB':
        return number * 1024;
      case 'MB':
        return number * 1024 * 1024;
      case 'GB':
        return number * 1024 * 1024 * 1024;
      default:
        return number * 1024 * 1024; // Default to MB
    }
  }

  /// Get collection reference with type safety
  CollectionReference<T> collection<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic> Function(T) toJson,
  ) {
    return _firestore.collection(path).withConverter<T>(
          fromFirestore: (snapshot, _) => fromJson(snapshot.data()!),
          toFirestore: (value, _) => toJson(value),
        );
  }

  /// Get document reference with type safety
  DocumentReference<T> document<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic> Function(T) toJson,
  ) {
    return _firestore.doc(path).withConverter<T>(
          fromFirestore: (snapshot, _) => fromJson(snapshot.data()!),
          toFirestore: (value, _) => toJson(value),
        );
  }

  // User Management
  CollectionReference<FirestoreUser> get users => collection<FirestoreUser>(
        'users',
        FirestoreUser.fromJson,
        (user) => user.toJson(),
      );

  DocumentReference<FirestoreUser> userDoc(String userId) =>
      document<FirestoreUser>(
        'users/$userId',
        FirestoreUser.fromJson,
        (user) => user.toJson(),
      );

  // Chat Sessions
  CollectionReference<ChatSession> chatSessions(String userId) =>
      collection<ChatSession>(
        'chat_history/$userId/sessions',
        ChatSession.fromJson,
        (session) => session.toJson(),
      );

  DocumentReference<ChatSession> chatSessionDoc(
          String userId, String sessionId) =>
      document<ChatSession>(
        'chat_history/$userId/sessions/$sessionId',
        ChatSession.fromJson,
        (session) => session.toJson(),
      );

  // Chat Messages
  CollectionReference<ChatMessage> chatMessages(
          String userId, String sessionId) =>
      collection<ChatMessage>(
        'chat_history/$userId/sessions/$sessionId/messages',
        ChatMessage.fromJson,
        (message) => message.toJson(),
      );

  DocumentReference<ChatMessage> chatMessageDoc(
    String userId,
    String sessionId,
    String messageId,
  ) =>
      document<ChatMessage>(
        'chat_history/$userId/sessions/$sessionId/messages/$messageId',
        ChatMessage.fromJson,
        (message) => message.toJson(),
      );

  // Learning Sessions
  CollectionReference<LearningSession> learningSessions(String userId) =>
      collection<LearningSession>(
        'learning_sessions/$userId/sessions',
        LearningSession.fromJson,
        (session) => session.toJson(),
      );

  DocumentReference<LearningSession> learningSessionDoc(
    String userId,
    String sessionId,
  ) =>
      document<LearningSession>(
        'learning_sessions/$userId/sessions/$sessionId',
        LearningSession.fromJson,
        (session) => session.toJson(),
      );

  // User Progress
  CollectionReference<UserProgress> userProgress(String userId) =>
      collection<UserProgress>(
        'user_progress/$userId/entries',
        UserProgress.fromJson,
        (progress) => progress.toJson(),
      );

  DocumentReference<UserProgress> userProgressDoc(
    String userId,
    String progressId,
  ) =>
      document<UserProgress>(
        'user_progress/$userId/entries/$progressId',
        UserProgress.fromJson,
        (progress) => progress.toJson(),
      );

  // Achievements
  CollectionReference<Achievement> achievements(String userId) =>
      collection<Achievement>(
        'user_progress/$userId/achievements',
        Achievement.fromJson,
        (achievement) => achievement.toJson(),
      );

  DocumentReference<Achievement> achievementDoc(
    String userId,
    String achievementId,
  ) =>
      document<Achievement>(
        'user_progress/$userId/achievements/$achievementId',
        Achievement.fromJson,
        (achievement) => achievement.toJson(),
      );

  /// Generic CRUD operations with error handling
  Future<T?> get<T>(DocumentReference<T> docRef) async {
    try {
      final snapshot = await docRef.get();
      return snapshot.exists ? snapshot.data() : null;
    } catch (e) {
      log('Error getting document: $e');
      return null;
    }
  }

  Future<bool> set<T>(DocumentReference<T> docRef, T data) async {
    try {
      await docRef.set(data);
      return true;
    } catch (e) {
      log('Error setting document: $e');
      return false;
    }
  }

  Future<bool> update<T>(
      DocumentReference<T> docRef, Map<String, dynamic> data) async {
    try {
      await docRef.update(data);
      return true;
    } catch (e) {
      log('Error updating document: $e');
      return false;
    }
  }

  Future<bool> delete<T>(DocumentReference<T> docRef) async {
    try {
      await docRef.delete();
      return true;
    } catch (e) {
      log('Error deleting document: $e');
      return false;
    }
  }

  Future<String?> add<T>(CollectionReference<T> collectionRef, T data) async {
    try {
      final docRef = await collectionRef.add(data);
      return docRef.id;
    } catch (e) {
      log('Error adding document: $e');
      return null;
    }
  }

  /// Stream operations for real-time updates
  Stream<T?> streamDocument<T>(DocumentReference<T> docRef) {
    return docRef.snapshots().map((snapshot) {
      return snapshot.exists ? snapshot.data() : null;
    }).handleError((error) {
      log('Error streaming document: $error');
      return null;
    });
  }

  Stream<List<T>> streamCollection<T>(
    CollectionReference<T> collectionRef, {
    Query<T> Function(CollectionReference<T>)? queryBuilder,
  }) {
    final query = queryBuilder?.call(collectionRef) ?? collectionRef;

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    }).handleError((error) {
      log('Error streaming collection: $error');
      return <T>[];
    });
  }

  /// Batch operations
  WriteBatch batch() => _firestore.batch();

  Future<bool> commitBatch(WriteBatch batch) async {
    try {
      await batch.commit();
      return true;
    } catch (e) {
      log('Error committing batch: $e');
      return false;
    }
  }

  /// Transaction operations
  Future<T?> runTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) async {
    try {
      return await _firestore.runTransaction(updateFunction);
    } catch (e) {
      log('Error running transaction: $e');
      return null;
    }
  }

  /// Utility methods
  Future<bool> documentExists(DocumentReference docRef) async {
    try {
      final snapshot = await docRef.get();
      return snapshot.exists;
    } catch (e) {
      log('Error checking document existence: $e');
      return false;
    }
  }

  Future<int> getCollectionSize(CollectionReference collectionRef) async {
    try {
      final snapshot = await collectionRef.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      log('Error getting collection size: $e');
      return 0;
    }
  }

  /// Cleanup old data based on configuration
  Future<void> cleanupOldData(String userId) async {
    try {
      final cutoffDate = DateTime.now().subtract(
        Duration(days: EnvironmentConfig.maxChatHistoryDays),
      );

      // Clean up old chat sessions
      final oldSessions = await chatSessions(userId)
          .where('createdAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final batch = this.batch();
      for (final doc in oldSessions.docs) {
        batch.delete(doc.reference);
      }

      await commitBatch(batch);
      log('Cleaned up ${oldSessions.docs.length} old chat sessions for user $userId');
    } catch (e) {
      log('Error cleaning up old data: $e');
    }
  }

  /// Enable offline persistence
  Future<void> enableOfflinePersistence() async {
    try {
      // Use the new Settings.persistenceEnabled approach
      _firestore.settings = const Settings(persistenceEnabled: true);
      log('Firestore offline persistence enabled');
    } catch (e) {
      log('Error enabling offline persistence: $e');
    }
  }

  /// Disable network (for testing offline functionality)
  Future<void> disableNetwork() async {
    try {
      await _firestore.disableNetwork();
      log('Firestore network disabled');
    } catch (e) {
      log('Error disabling network: $e');
    }
  }

  /// Enable network
  Future<void> enableNetwork() async {
    try {
      await _firestore.enableNetwork();
      log('Firestore network enabled');
    } catch (e) {
      log('Error enabling network: $e');
    }
  }

  /// Clear offline cache
  Future<void> clearPersistence() async {
    try {
      await _firestore.clearPersistence();
      log('Firestore persistence cleared');
    } catch (e) {
      log('Error clearing persistence: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    // Firestore doesn't require explicit disposal
    _isInitialized = false;
  }
}

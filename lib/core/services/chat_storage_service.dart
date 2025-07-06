import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/ai_models.dart';
import '../models/firestore_models.dart';
import '../utils/environment_config.dart';
import 'firestore_service.dart';

class ChatStorageService {
  static ChatStorageService? _instance;
  static ChatStorageService get instance =>
      _instance ??= ChatStorageService._();

  ChatStorageService._();

  final FirestoreService _firestore = FirestoreService.instance;
  final Uuid _uuid = const Uuid();

  /// Create a new chat session
  Future<String?> createChatSession({
    required String userId,
    required String title,
    String? topic,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final sessionId = _uuid.v4();
      final session = ChatSession(
        id: sessionId,
        userId: userId,
        title: title,
        topic: topic,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: metadata ?? {},
      );

      final success = await _firestore.set(
        _firestore.chatSessionDoc(userId, sessionId),
        session,
      );

      if (success) {
        log('Chat session created: $sessionId');
        return sessionId;
      }

      return null;
    } catch (e) {
      log('Error creating chat session: $e');
      return null;
    }
  }

  /// Get chat session by ID
  Future<ChatSession?> getChatSession(String userId, String sessionId) async {
    try {
      return await _firestore.get(_firestore.chatSessionDoc(userId, sessionId));
    } catch (e) {
      log('Error getting chat session: $e');
      return null;
    }
  }

  /// Get all chat sessions for a user
  Future<List<ChatSession>> getChatSessions(
    String userId, {
    int? limit,
    bool activeOnly = false,
  }) async {
    try {
      var query = _firestore
          .chatSessions(userId)
          .orderBy('updatedAt', descending: true);

      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      log('Error getting chat sessions: $e');
      return [];
    }
  }

  /// Stream chat sessions for real-time updates
  Stream<List<ChatSession>> streamChatSessions(
    String userId, {
    int? limit,
    bool activeOnly = false,
  }) {
    var query =
        _firestore.chatSessions(userId).orderBy('updatedAt', descending: true);

    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return _firestore.streamCollection(
      _firestore.chatSessions(userId),
      queryBuilder: (_) => query,
    );
  }

  /// Update chat session
  Future<bool> updateChatSession(
    String userId,
    String sessionId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();

      return await _firestore.update(
        _firestore.chatSessionDoc(userId, sessionId),
        updates,
      );
    } catch (e) {
      log('Error updating chat session: $e');
      return false;
    }
  }

  /// Archive chat session (set inactive)
  Future<bool> archiveChatSession(String userId, String sessionId) async {
    return await updateChatSession(userId, sessionId, {'isActive': false});
  }

  /// Delete chat session and all its messages
  Future<bool> deleteChatSession(String userId, String sessionId) async {
    try {
      final batch = _firestore.batch();

      // Delete all messages in the session
      final messages = await _firestore.chatMessages(userId, sessionId).get();
      for (final message in messages.docs) {
        batch.delete(message.reference);
      }

      // Delete the session
      batch.delete(_firestore.chatSessionDoc(userId, sessionId));

      return await _firestore.commitBatch(batch);
    } catch (e) {
      log('Error deleting chat session: $e');
      return false;
    }
  }

  /// Save a chat message
  Future<String?> saveChatMessage({
    required String userId,
    required String sessionId,
    required String content,
    required String role,
    String? templateId,
    Map<String, dynamic>? templateData,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final messageId = _uuid.v4();
      final message = ChatMessage(
        id: messageId,
        sessionId: sessionId,
        userId: userId,
        content: content,
        role: role,
        timestamp: DateTime.now(),
        templateId: templateId,
        templateData: templateData,
        metadata: metadata ?? {},
      );

      final success = await _firestore.set(
        _firestore.chatMessageDoc(userId, sessionId, messageId),
        message,
      );

      if (success) {
        // Update session message count and timestamp
        await updateChatSession(userId, sessionId, {
          'messageCount': FieldValue.increment(1),
        });

        log('Chat message saved: $messageId');
        return messageId;
      }

      return null;
    } catch (e) {
      log('Error saving chat message: $e');
      return null;
    }
  }

  /// Save AI message from AIMessage model
  Future<String?> saveAIMessage({
    required String userId,
    required String sessionId,
    required AIMessage aiMessage,
  }) async {
    return await saveChatMessage(
      userId: userId,
      sessionId: sessionId,
      content: aiMessage.content,
      role: aiMessage.role,
      templateId: null, // AIMessage doesn't support templates
      templateData: null, // AIMessage doesn't support templates
      metadata: {
        'timestamp': aiMessage.timestamp.toIso8601String(),
        // Include additional AIMessage properties in metadata
        if (aiMessage.model != null) 'model': aiMessage.model,
        if (aiMessage.tokenCount != null) 'tokenCount': aiMessage.tokenCount,
        if (aiMessage.confidence != null) 'confidence': aiMessage.confidence,
        if (aiMessage.metadata != null) ...aiMessage.metadata!,
      },
    );
  }

  /// Get chat messages for a session
  Future<List<ChatMessage>> getChatMessages(
    String userId,
    String sessionId, {
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      var query = _firestore
          .chatMessages(userId, sessionId)
          .orderBy('timestamp', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      log('Error getting chat messages: $e');
      return [];
    }
  }

  /// Stream chat messages for real-time updates
  Stream<List<ChatMessage>> streamChatMessages(
    String userId,
    String sessionId, {
    int? limit,
  }) {
    var query = _firestore
        .chatMessages(userId, sessionId)
        .orderBy('timestamp', descending: false);

    if (limit != null) {
      query = query.limit(limit);
    }

    return _firestore.streamCollection(
      _firestore.chatMessages(userId, sessionId),
      queryBuilder: (_) => query,
    );
  }

  /// Update chat message
  Future<bool> updateChatMessage(
    String userId,
    String sessionId,
    String messageId,
    Map<String, dynamic> updates,
  ) async {
    try {
      return await _firestore.update(
        _firestore.chatMessageDoc(userId, sessionId, messageId),
        updates,
      );
    } catch (e) {
      log('Error updating chat message: $e');
      return false;
    }
  }

  /// Delete chat message
  Future<bool> deleteChatMessage(
    String userId,
    String sessionId,
    String messageId,
  ) async {
    try {
      final success = await _firestore.delete(
        _firestore.chatMessageDoc(userId, sessionId, messageId),
      );

      if (success) {
        // Decrement session message count
        await updateChatSession(userId, sessionId, {
          'messageCount': FieldValue.increment(-1),
        });
      }

      return success;
    } catch (e) {
      log('Error deleting chat message: $e');
      return false;
    }
  }

  /// Search chat messages
  Future<List<ChatMessage>> searchChatMessages(
    String userId, {
    String? query,
    String? sessionId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a basic implementation that can be enhanced with Algolia or similar

      Query<ChatMessage> firestoreQuery;

      if (sessionId != null) {
        firestoreQuery = _firestore.chatMessages(userId, sessionId);
      } else {
        // This would require a different collection structure for cross-session search
        // For now, we'll search within the most recent session
        final sessions = await getChatSessions(userId, limit: 1);
        if (sessions.isEmpty) return [];

        firestoreQuery = _firestore.chatMessages(userId, sessions.first.id);
      }

      if (startDate != null) {
        firestoreQuery = firestoreQuery.where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        firestoreQuery = firestoreQuery.where(
          'timestamp',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      firestoreQuery = firestoreQuery.orderBy('timestamp', descending: true);

      if (limit != null) {
        firestoreQuery = firestoreQuery.limit(limit);
      }

      final snapshot = await firestoreQuery.get();
      var messages = snapshot.docs.map((doc) => doc.data()).toList();

      // Client-side filtering for text search (not ideal for large datasets)
      if (query != null && query.isNotEmpty) {
        messages = messages
            .where((message) =>
                message.content.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }

      return messages;
    } catch (e) {
      log('Error searching chat messages: $e');
      return [];
    }
  }

  /// Get chat statistics for a user
  Future<Map<String, dynamic>> getChatStatistics(String userId) async {
    try {
      final sessions = await getChatSessions(userId);
      final totalSessions = sessions.length;
      final activeSessions = sessions.where((s) => s.isActive).length;

      int totalMessages = 0;
      DateTime? lastMessageTime;

      for (final session in sessions) {
        totalMessages += session.messageCount;
        if (lastMessageTime == null ||
            session.updatedAt.isAfter(lastMessageTime)) {
          lastMessageTime = session.updatedAt;
        }
      }

      return {
        'totalSessions': totalSessions,
        'activeSessions': activeSessions,
        'totalMessages': totalMessages,
        'lastMessageTime': lastMessageTime?.toIso8601String(),
        'averageMessagesPerSession':
            totalSessions > 0 ? totalMessages / totalSessions : 0,
      };
    } catch (e) {
      log('Error getting chat statistics: $e');
      return {};
    }
  }

  /// Clean up old chat data based on configuration
  Future<void> cleanupOldChatData(String userId) async {
    try {
      final cutoffDate = DateTime.now().subtract(
        Duration(days: EnvironmentConfig.maxChatHistoryDays),
      );

      final oldSessions = await _firestore
          .chatSessions(userId)
          .where('createdAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final batch = _firestore.batch();

      for (final sessionDoc in oldSessions.docs) {
        // Delete all messages in the session
        final messages =
            await _firestore.chatMessages(userId, sessionDoc.id).get();
        for (final messageDoc in messages.docs) {
          batch.delete(messageDoc.reference);
        }

        // Delete the session
        batch.delete(sessionDoc.reference);
      }

      await _firestore.commitBatch(batch);
      log('Cleaned up ${oldSessions.docs.length} old chat sessions for user $userId');
    } catch (e) {
      log('Error cleaning up old chat data: $e');
    }
  }

  /// Export chat data for a user
  Future<Map<String, dynamic>?> exportChatData(String userId) async {
    try {
      final sessions = await getChatSessions(userId);
      final exportData = <String, dynamic>{
        'userId': userId,
        'exportedAt': DateTime.now().toIso8601String(),
        'sessions': [],
      };

      for (final session in sessions) {
        final messages = await getChatMessages(userId, session.id);
        exportData['sessions'].add({
          'session': session.toJson(),
          'messages': messages.map((m) => m.toJson()).toList(),
        });
      }

      return exportData;
    } catch (e) {
      log('Error exporting chat data: $e');
      return null;
    }
  }
}

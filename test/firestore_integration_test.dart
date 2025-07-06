import 'package:flutter_test/flutter_test.dart';
import 'package:whatsup_microlearning_bots/core/models/firestore_models.dart';

void main() {
  group('Firestore Models Tests', () {
    group('FirestoreUser Model', () {
      test('should create FirestoreUser with required fields', () {
        final user = FirestoreUser(
          uid: 'test-uid',
          email: 'test@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(user.uid, equals('test-uid'));
        expect(user.email, equals('test@example.com'));
        expect(user.emailVerified, isFalse);
        expect(user.signInMethods, isEmpty);
        expect(user.preferences, isEmpty);
        expect(user.stats, isA<UserStats>());
      });

      test('should serialize to and from JSON', () {
        final now = DateTime.now();
        final user = FirestoreUser(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          emailVerified: true,
          createdAt: now,
          updatedAt: now,
          signInMethods: ['google.com'],
          preferences: {'theme': 'dark'},
          stats: const UserStats(totalSessions: 5),
        );

        final json = user.toJson();
        final fromJson = FirestoreUser.fromJson(json);

        expect(fromJson.uid, equals(user.uid));
        expect(fromJson.email, equals(user.email));
        expect(fromJson.displayName, equals(user.displayName));
        expect(fromJson.emailVerified, equals(user.emailVerified));
        expect(fromJson.signInMethods, equals(user.signInMethods));
        expect(fromJson.preferences, equals(user.preferences));
        expect(fromJson.stats.totalSessions, equals(user.stats.totalSessions));
      });

      test('should copy with new values', () {
        final original = FirestoreUser(
          uid: 'test-uid',
          email: 'test@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          emailVerified: false,
        );

        final updated = original.copyWith(
          displayName: 'Updated Name',
          emailVerified: true,
        );

        expect(updated.uid, equals(original.uid));
        expect(updated.email, equals(original.email));
        expect(updated.displayName, equals('Updated Name'));
        expect(updated.emailVerified, isTrue);
      });
    });

    group('UserStats Model', () {
      test('should create UserStats with default values', () {
        const stats = UserStats();

        expect(stats.totalSessions, equals(0));
        expect(stats.totalMessages, equals(0));
        expect(stats.totalLearningMinutes, equals(0));
        expect(stats.streakDays, equals(0));
        expect(stats.level, equals(1));
        expect(stats.experiencePoints, equals(0));
        expect(stats.lastActiveDate, isNull);
      });

      test('should serialize to and from JSON', () {
        final now = DateTime.now();
        final stats = UserStats(
          totalSessions: 10,
          totalMessages: 50,
          totalLearningMinutes: 120,
          streakDays: 7,
          level: 3,
          experiencePoints: 500,
          lastActiveDate: now,
        );

        final json = stats.toJson();
        final fromJson = UserStats.fromJson(json);

        expect(fromJson.totalSessions, equals(stats.totalSessions));
        expect(fromJson.totalMessages, equals(stats.totalMessages));
        expect(fromJson.totalLearningMinutes, equals(stats.totalLearningMinutes));
        expect(fromJson.streakDays, equals(stats.streakDays));
        expect(fromJson.level, equals(stats.level));
        expect(fromJson.experiencePoints, equals(stats.experiencePoints));
      });
    });

    group('ChatSession Model', () {
      test('should create ChatSession with required fields', () {
        final now = DateTime.now();
        final session = ChatSession(
          id: 'session-1',
          userId: 'user-1',
          title: 'Test Session',
          createdAt: now,
          updatedAt: now,
        );

        expect(session.id, equals('session-1'));
        expect(session.userId, equals('user-1'));
        expect(session.title, equals('Test Session'));
        expect(session.messageCount, equals(0));
        expect(session.isActive, isTrue);
        expect(session.metadata, isEmpty);
      });

      test('should serialize to and from JSON', () {
        final now = DateTime.now();
        final session = ChatSession(
          id: 'session-1',
          userId: 'user-1',
          title: 'Test Session',
          topic: 'Programming',
          createdAt: now,
          updatedAt: now,
          messageCount: 5,
          isActive: false,
          metadata: {'category': 'learning'},
        );

        final json = session.toJson();
        final fromJson = ChatSession.fromJson(json);

        expect(fromJson.id, equals(session.id));
        expect(fromJson.userId, equals(session.userId));
        expect(fromJson.title, equals(session.title));
        expect(fromJson.topic, equals(session.topic));
        expect(fromJson.messageCount, equals(session.messageCount));
        expect(fromJson.isActive, equals(session.isActive));
        expect(fromJson.metadata, equals(session.metadata));
      });
    });

    group('ChatMessage Model', () {
      test('should create ChatMessage with required fields', () {
        final now = DateTime.now();
        final message = ChatMessage(
          id: 'message-1',
          sessionId: 'session-1',
          userId: 'user-1',
          content: 'Hello, world!',
          role: 'user',
          timestamp: now,
        );

        expect(message.id, equals('message-1'));
        expect(message.sessionId, equals('session-1'));
        expect(message.userId, equals('user-1'));
        expect(message.content, equals('Hello, world!'));
        expect(message.role, equals('user'));
        expect(message.isLoading, isFalse);
        expect(message.error, isNull);
        expect(message.metadata, isEmpty);
      });

      test('should identify message roles correctly', () {
        final now = DateTime.now();
        
        final userMessage = ChatMessage(
          id: 'msg-1',
          sessionId: 'session-1',
          userId: 'user-1',
          content: 'User message',
          role: 'user',
          timestamp: now,
        );

        final assistantMessage = ChatMessage(
          id: 'msg-2',
          sessionId: 'session-1',
          userId: 'user-1',
          content: 'Assistant message',
          role: 'assistant',
          timestamp: now,
        );

        final systemMessage = ChatMessage(
          id: 'msg-3',
          sessionId: 'session-1',
          userId: 'user-1',
          content: 'System message',
          role: 'system',
          timestamp: now,
        );

        expect(userMessage.isUser, isTrue);
        expect(userMessage.isAssistant, isFalse);
        expect(userMessage.isSystem, isFalse);

        expect(assistantMessage.isUser, isFalse);
        expect(assistantMessage.isAssistant, isTrue);
        expect(assistantMessage.isSystem, isFalse);

        expect(systemMessage.isUser, isFalse);
        expect(systemMessage.isAssistant, isFalse);
        expect(systemMessage.isSystem, isTrue);
      });

      test('should detect error state', () {
        final now = DateTime.now();
        
        final normalMessage = ChatMessage(
          id: 'msg-1',
          sessionId: 'session-1',
          userId: 'user-1',
          content: 'Normal message',
          role: 'user',
          timestamp: now,
        );

        final errorMessage = ChatMessage(
          id: 'msg-2',
          sessionId: 'session-1',
          userId: 'user-1',
          content: 'Error message',
          role: 'assistant',
          timestamp: now,
          error: 'Something went wrong',
        );

        expect(normalMessage.hasError, isFalse);
        expect(errorMessage.hasError, isTrue);
      });
    });

    group('LearningSession Model', () {
      test('should create LearningSession with required fields', () {
        final now = DateTime.now();
        final session = LearningSession(
          id: 'learning-1',
          userId: 'user-1',
          topic: 'Flutter Development',
          startTime: now,
        );

        expect(session.id, equals('learning-1'));
        expect(session.userId, equals('user-1'));
        expect(session.topic, equals('Flutter Development'));
        expect(session.durationMinutes, equals(0));
        expect(session.messageCount, equals(0));
        expect(session.topicsDiscussed, isEmpty);
        expect(session.experienceGained, equals(0));
        expect(session.type, equals(LearningSessionType.general));
        expect(session.isActive, isTrue);
      });

      test('should calculate duration correctly', () {
        final startTime = DateTime.now();
        final endTime = startTime.add(const Duration(minutes: 30));
        
        final session = LearningSession(
          id: 'learning-1',
          userId: 'user-1',
          topic: 'Flutter Development',
          startTime: startTime,
          endTime: endTime,
        );

        expect(session.isActive, isFalse);
        expect(session.duration.inMinutes, equals(30));
      });

      test('should serialize learning session types correctly', () {
        final now = DateTime.now();
        
        for (final type in LearningSessionType.values) {
          final session = LearningSession(
            id: 'learning-1',
            userId: 'user-1',
            topic: 'Test Topic',
            startTime: now,
            type: type,
          );

          final json = session.toJson();
          final fromJson = LearningSession.fromJson(json);

          expect(fromJson.type, equals(type));
        }
      });
    });

    group('UserProgress Model', () {
      test('should create UserProgress with required fields', () {
        final now = DateTime.now();
        final progress = UserProgress(
          id: 'progress-1',
          userId: 'user-1',
          topic: 'Dart Programming',
          lastStudied: now,
          createdAt: now,
        );

        expect(progress.id, equals('progress-1'));
        expect(progress.userId, equals('user-1'));
        expect(progress.topic, equals('Dart Programming'));
        expect(progress.completionPercentage, equals(0.0));
        expect(progress.currentLevel, equals(1));
        expect(progress.totalSessions, equals(0));
        expect(progress.completedSubtopics, isEmpty);
        expect(progress.progressData, isEmpty);
        expect(progress.isCompleted, isFalse);
      });

      test('should detect completion correctly', () {
        final now = DateTime.now();
        
        final incompleteProgress = UserProgress(
          id: 'progress-1',
          userId: 'user-1',
          topic: 'Dart Programming',
          completionPercentage: 75.0,
          lastStudied: now,
          createdAt: now,
        );

        final completeProgress = UserProgress(
          id: 'progress-2',
          userId: 'user-1',
          topic: 'Flutter Basics',
          completionPercentage: 100.0,
          lastStudied: now,
          createdAt: now,
        );

        expect(incompleteProgress.isCompleted, isFalse);
        expect(completeProgress.isCompleted, isTrue);
      });
    });

    group('Achievement Model', () {
      test('should create Achievement with required fields', () {
        final now = DateTime.now();
        final achievement = Achievement(
          id: 'achievement-1',
          userId: 'user-1',
          title: 'First Steps',
          description: 'Completed your first learning session',
          icon: '🎯',
          type: AchievementType.sessions,
          unlockedAt: now,
        );

        expect(achievement.id, equals('achievement-1'));
        expect(achievement.userId, equals('user-1'));
        expect(achievement.title, equals('First Steps'));
        expect(achievement.description, equals('Completed your first learning session'));
        expect(achievement.icon, equals('🎯'));
        expect(achievement.type, equals(AchievementType.sessions));
        expect(achievement.pointsAwarded, equals(0));
        expect(achievement.criteria, isEmpty);
        expect(achievement.isVisible, isTrue);
      });

      test('should serialize achievement types correctly', () {
        final now = DateTime.now();
        
        for (final type in AchievementType.values) {
          final achievement = Achievement(
            id: 'achievement-1',
            userId: 'user-1',
            title: 'Test Achievement',
            description: 'Test Description',
            icon: '🏆',
            type: type,
            unlockedAt: now,
          );

          final json = achievement.toJson();
          final fromJson = Achievement.fromJson(json);

          expect(fromJson.type, equals(type));
        }
      });
    });

    group('TimestampConverter', () {
      test('should convert DateTime to Timestamp and back', () {
        const converter = TimestampConverter();
        final originalDate = DateTime.now();

        // Convert to Timestamp (for Firestore)
        final timestamp = converter.toJson(originalDate);
        
        // Convert back to DateTime
        final convertedDate = converter.fromJson(timestamp);

        // Should be approximately equal (within a few milliseconds)
        expect(
          convertedDate.difference(originalDate).inMilliseconds.abs(),
          lessThan(1000),
        );
      });

      test('should handle string dates', () {
        const converter = TimestampConverter();
        final originalDate = DateTime.now();
        final dateString = originalDate.toIso8601String();

        final convertedDate = converter.fromJson(dateString);

        expect(convertedDate.toIso8601String(), equals(dateString));
      });

      test('should handle integer timestamps', () {
        const converter = TimestampConverter();
        final originalDate = DateTime.now();
        final timestamp = originalDate.millisecondsSinceEpoch;

        final convertedDate = converter.fromJson(timestamp);

        expect(convertedDate.millisecondsSinceEpoch, equals(timestamp));
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:whatsup_microlearning_bots/core/models/firestore_models.dart';
import 'package:whatsup_microlearning_bots/core/models/learning_category.dart';
import 'package:whatsup_microlearning_bots/core/models/study_plan.dart'
    as study;
import 'package:whatsup_microlearning_bots/core/services/offline_service.dart';

void main() {
  group('OfflineService Tests', () {
    late OfflineService offlineService;

    setUpAll(() async {
      // Get offline service instance
      offlineService = OfflineService.instance;
    });

    group('Service Instance', () {
      test('should return singleton instance', () {
        // Act
        final instance1 = OfflineService.instance;
        final instance2 = OfflineService.instance;

        // Assert
        expect(instance1, equals(instance2));
        expect(instance1, isA<OfflineService>());
      });

      test('should have connectivity status', () {
        // Act
        final isOnline = offlineService.isOnline;

        // Assert
        expect(isOnline, isA<bool>());
      });

      test('should provide connectivity stream', () {
        // Act
        final stream = offlineService.connectivityStream;

        // Assert
        expect(stream, isA<Stream<bool>>());
      });
    });

    group('Model Tests', () {
      test('should create ChatSession with required fields', () {
        // Arrange & Act
        final chatSession = ChatSession(
          id: 'session-123',
          userId: 'user-123',
          title: 'Test Chat Session',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          messageCount: 1,
          isActive: true,
        );

        // Assert
        expect(chatSession.id, equals('session-123'));
        expect(chatSession.userId, equals('user-123'));
        expect(chatSession.title, equals('Test Chat Session'));
        expect(chatSession.messageCount, equals(1));
        expect(chatSession.isActive, isTrue);
      });

      test('should create ChatMessage with required fields', () {
        // Arrange & Act
        final chatMessage = ChatMessage(
          id: 'msg-123',
          sessionId: 'session-123',
          userId: 'user-123',
          content: 'Hello, world!',
          role: 'user',
          timestamp: DateTime.now(),
        );

        // Assert
        expect(chatMessage.id, equals('msg-123'));
        expect(chatMessage.sessionId, equals('session-123'));
        expect(chatMessage.userId, equals('user-123'));
        expect(chatMessage.content, equals('Hello, world!'));
        expect(chatMessage.role, equals('user'));
        expect(chatMessage.isLoading, isFalse);
      });
    });

    group('Learning Models', () {
      test('should create LearningCategory with required fields', () {
        // Arrange & Act
        final category = LearningCategory(
          id: 'cat-1',
          name: 'Programming',
          description: 'Learn programming',
          iconName: 'code',
          colorCode: '#2196F3',
          tags: ['programming', 'coding'],
          topicCount: 10,
          userCount: 100,
          difficulty: DifficultyLevel.intermediate,
          isPopular: true,
          isFeatured: true,
          averageRating: 4.5,
          estimatedHours: 40,
          prerequisites: [],
          metadata: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert
        expect(category.id, equals('cat-1'));
        expect(category.name, equals('Programming'));
        expect(category.description, equals('Learn programming'));
        expect(category.isPopular, isTrue);
        expect(category.isFeatured, isTrue);
        expect(category.averageRating, equals(4.5));
      });

      test('should create LearningTopic with required fields', () {
        // Arrange & Act
        final topic = LearningTopic(
          id: 'topic-1',
          categoryId: 'programming',
          name: 'Flutter Basics',
          description: 'Learn Flutter basics',
          content: 'Flutter content',
          keywords: ['flutter', 'basics'],
          difficulty: DifficultyLevel.beginner,
          estimatedMinutes: 60,
          orderIndex: 0,
          prerequisites: [],
          learningObjectives: [],
          resources: [],
          type: TopicType.lesson,
          isInteractive: false,
          hasQuiz: false,
          averageRating: 4.0,
          completionCount: 0,
          metadata: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert
        expect(topic.id, equals('topic-1'));
        expect(topic.categoryId, equals('programming'));
        expect(topic.name, equals('Flutter Basics'));
        expect(topic.difficulty, equals(DifficultyLevel.beginner));
        expect(topic.estimatedMinutes, equals(60));
        expect(topic.type, equals(TopicType.lesson));
      });
    });

    group('Study Plans Caching', () {
      test('should cache and retrieve study plans', () async {
        // Arrange
        const userId = 'user-123';
        final studyPlans = [
          study.StudyPlan(
            id: 'plan-1',
            userId: userId,
            title: 'Flutter Learning Plan',
            description: 'Complete Flutter course',
            category: 'Programming',
            type: study.StudyPlanType.structured,
            difficulty: study.DifficultyLevel.intermediate,
            estimatedDurationDays: 30,
            dailyTimeMinutes: 60,
            topics: ['Flutter Basics', 'State Management'],
            milestones: [],
            status: study.StudyPlanStatus.draft,
            startDate: DateTime.now(),
            progressPercentage: 0.0,
            completedSessions: 0,
            totalSessions: 30,
            metadata: {},
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        // Act
        await offlineService.cacheStudyPlans(userId, studyPlans);
        final cachedPlans = await offlineService.getCachedStudyPlans(userId);

        // Assert
        expect(cachedPlans, hasLength(1));
        expect(cachedPlans.first.title, equals('Flutter Learning Plan'));
        expect(cachedPlans.first.userId, equals(userId));
      });
    });

    group('User Progress Caching', () {
      test('should cache and retrieve user progress', () async {
        // Arrange
        const userId = 'user-123';
        final progress = [
          UserTopicProgress(
            id: 'progress-1',
            userId: userId,
            topicId: 'topic-1',
            categoryId: 'programming',
            status: ProgressStatus.completed,
            completionPercentage: 100.0,
            timeSpentMinutes: 90,
            attempts: 1,
            quizScore: 85.0,
            completedObjectives: ['Objective 1'],
            bookmarkedResources: [],
            notes: {'note': 'Great topic'},
            startedAt: DateTime.now().subtract(const Duration(hours: 2)),
            lastAccessedAt: DateTime.now(),
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        // Act
        await offlineService.cacheUserProgress(userId, progress);
        final cachedProgress =
            await offlineService.getCachedUserProgress(userId);

        // Assert
        expect(cachedProgress, hasLength(1));
        expect(cachedProgress.first.status, equals(ProgressStatus.completed));
        expect(cachedProgress.first.completionPercentage, equals(100.0));
      });
    });

    group('Settings Caching', () {
      test('should cache and retrieve app settings', () async {
        // Arrange
        const settingsKey = 'user-preferences';
        final settings = {
          'theme': 'dark',
          'language': 'en',
          'notifications': true,
          'autoBackup': false,
        };

        // Act
        await offlineService.cacheAppSettings(settingsKey, settings);
        final cachedSettings =
            await offlineService.getCachedAppSettings(settingsKey);

        // Assert
        expect(cachedSettings, isNotNull);
        expect(cachedSettings!['theme'], equals('dark'));
        expect(cachedSettings['notifications'], isTrue);
        expect(cachedSettings['autoBackup'], isFalse);
      });
    });

    group('Generic Data Caching', () {
      test('should cache and retrieve generic data', () async {
        // Arrange
        const key = 'test-data';
        final data = {
          'name': 'Test User',
          'age': 25,
          'preferences': ['coding', 'reading'],
        };

        // Act
        await offlineService.cacheData(key, data);
        final cachedData =
            await offlineService.getCachedData<Map<String, dynamic>>(
          key,
          (json) => json,
        );

        // Assert
        expect(cachedData, isNotNull);
        expect(cachedData!['name'], equals('Test User'));
        expect(cachedData['age'], equals(25));
        expect(cachedData['preferences'], hasLength(2));
      });
    });

    group('Cache Management', () {
      test('should clear all cache', () async {
        // Arrange
        await offlineService.cacheData('test1', {'data': 'value1'});
        await offlineService.cacheData('test2', {'data': 'value2'});
        await offlineService.cacheAppSettings('settings', {'theme': 'light'});

        // Act
        await offlineService.clearAllCache();

        // Assert
        final data1 = await offlineService.getCachedData<Map<String, dynamic>>(
          'test1',
          (json) => json,
        );
        final data2 = await offlineService.getCachedData<Map<String, dynamic>>(
          'test2',
          (json) => json,
        );
        final settings = await offlineService.getCachedAppSettings('settings');

        expect(data1, isNull);
        expect(data2, isNull);
        expect(settings, isNull);
      });

      test('should get cache statistics', () async {
        // Arrange
        await offlineService.cacheData('test', {'data': 'value'});
        await offlineService.cacheAppSettings('settings', {'theme': 'dark'});

        // Act
        final stats = await offlineService.getCacheStats();

        // Assert
        expect(stats, isNotEmpty);
        expect(stats.containsKey('genericCache'), isTrue);
        expect(stats.containsKey('settings'), isTrue);
        expect(stats.containsKey('isOnline'), isTrue);
      });
    });

    group('Connectivity', () {
      test('should provide connectivity status', () {
        // Act
        final isOnline = offlineService.isOnline;

        // Assert
        expect(isOnline, isA<bool>());
      });

      test('should provide connectivity stream', () {
        // Act
        final stream = offlineService.connectivityStream;

        // Assert
        expect(stream, isA<Stream<bool>>());
      });
    });
  });
}

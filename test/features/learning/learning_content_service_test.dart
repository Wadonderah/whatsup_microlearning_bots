import 'package:flutter_test/flutter_test.dart';
import 'package:whatsup_microlearning_bots/core/models/learning_category.dart';
import 'package:whatsup_microlearning_bots/core/services/learning_content_service.dart';

void main() {
  group('LearningContentService Tests', () {
    late LearningContentService learningService;

    setUp(() {
      learningService = LearningContentService.instance;
    });

    group('Categories Management', () {
      test('should initialize default categories', () async {
        // Act
        await learningService.initializeDefaultCategories();

        // Assert
        final categories = await learningService.getCategories();
        expect(categories, isNotEmpty);
        expect(categories.length, equals(5)); // Default categories count

        final programmingCategory = categories.firstWhere(
          (c) => c.name == 'Programming',
          orElse: () => throw Exception('Programming category not found'),
        );
        expect(programmingCategory.isPopular, isTrue);
        expect(programmingCategory.isFeatured, isTrue);
      });

      test('should get featured categories', () async {
        // Arrange
        await learningService.initializeDefaultCategories();

        // Act
        final featuredCategories =
            await learningService.getFeaturedCategories();

        // Assert
        expect(featuredCategories, isNotEmpty);
        expect(featuredCategories.every((c) => c.isFeatured), isTrue);
      });

      test('should get popular categories', () async {
        // Arrange
        await learningService.initializeDefaultCategories();

        // Act
        final popularCategories = await learningService.getPopularCategories();

        // Assert
        expect(popularCategories, isNotEmpty);
        expect(popularCategories.every((c) => c.isPopular), isTrue);
      });

      test('should get specific category by ID', () async {
        // Arrange
        await learningService.initializeDefaultCategories();

        // Act
        final category = await learningService.getCategory('programming');

        // Assert
        expect(category, isNotNull);
        expect(category!.name, equals('Programming'));
        expect(category.id, equals('programming'));
      });

      test('should return null for non-existent category', () async {
        // Act
        final category = await learningService.getCategory('non-existent');

        // Assert
        expect(category, isNull);
      });

      test('should search categories by name', () async {
        // Arrange
        await learningService.initializeDefaultCategories();

        // Act
        final searchResults = await learningService.searchCategories('Program');

        // Assert
        expect(searchResults, isNotEmpty);
        expect(
            searchResults.any((c) => c.name.contains('Programming')), isTrue);
      });
    });

    group('Topics Management', () {
      test('should get topics for category', () async {
        // Arrange
        const categoryId = 'programming';

        // Act
        final topics = await learningService.getTopicsForCategory(categoryId);

        // Assert
        // Since we don't have default topics, this should return empty
        expect(topics, isEmpty);
      });

      test('should get specific topic by ID', () async {
        // Act
        final topic = await learningService.getTopic('non-existent-topic');

        // Assert
        expect(topic, isNull);
      });

      test('should search topics', () async {
        // Act
        final topics = await learningService.searchTopics('Flutter');

        // Assert
        expect(topics, isEmpty); // No topics created yet
      });

      test('should search topics within category', () async {
        // Act
        final topics = await learningService.searchTopics(
          'Flutter',
          categoryId: 'programming',
        );

        // Assert
        expect(topics, isEmpty); // No topics created yet
      });
    });

    group('User Progress Management', () {
      const userId = 'test-user-123';
      const topicId = 'test-topic-456';
      const categoryId = 'programming';

      test('should start a topic', () async {
        // Act
        final progressId =
            await learningService.startTopic(userId, topicId, categoryId);

        // Assert
        expect(progressId, isNotNull);
        expect(progressId, isNotEmpty);

        // Verify progress was created
        final progress =
            await learningService.getUserTopicProgress(userId, topicId);
        expect(progress, isNotNull);
        expect(progress!.status, equals(ProgressStatus.inProgress));
        expect(progress.completionPercentage, equals(0.0));
        expect(progress.attempts, equals(1));
      });

      test('should update topic progress', () async {
        // Arrange
        await learningService.startTopic(userId, topicId, categoryId);

        // Act
        final success = await learningService.updateTopicProgress(
          userId: userId,
          topicId: topicId,
          completionPercentage: 50.0,
          additionalTimeMinutes: 30,
          completedObjectives: ['Objective 1', 'Objective 2'],
        );

        // Assert
        expect(success, isTrue);

        final progress =
            await learningService.getUserTopicProgress(userId, topicId);
        expect(progress!.completionPercentage, equals(50.0));
        expect(progress.timeSpentMinutes, equals(30));
        expect(progress.completedObjectives, contains('Objective 1'));
        expect(progress.status, equals(ProgressStatus.inProgress));
      });

      test('should complete a topic', () async {
        // Arrange
        await learningService.startTopic(userId, topicId, categoryId);

        // Act
        final success = await learningService.completeTopic(
          userId,
          topicId,
          quizScore: 85.5,
        );

        // Assert
        expect(success, isTrue);

        final progress =
            await learningService.getUserTopicProgress(userId, topicId);
        expect(progress!.status, equals(ProgressStatus.completed));
        expect(progress.completionPercentage, equals(100.0));
        expect(progress.quizScore, equals(85.5));
        expect(progress.completedAt, isNotNull);
      });

      test('should bookmark a topic', () async {
        // Act
        final success =
            await learningService.bookmarkTopic(userId, topicId, categoryId);

        // Assert
        expect(success, isTrue);

        final progress =
            await learningService.getUserTopicProgress(userId, topicId);
        expect(progress!.status, equals(ProgressStatus.bookmarked));
      });

      test('should get user bookmarks', () async {
        // Arrange
        await learningService.bookmarkTopic(userId, 'topic1', categoryId);
        await learningService.bookmarkTopic(userId, 'topic2', categoryId);

        // Act
        final bookmarks = await learningService.getUserBookmarks(userId);

        // Assert
        expect(bookmarks, hasLength(2));
        expect(bookmarks.every((b) => b.status == ProgressStatus.bookmarked),
            isTrue);
      });

      test('should get completed topics', () async {
        // Arrange
        await learningService.startTopic(userId, 'topic1', categoryId);
        await learningService.completeTopic(userId, 'topic1');
        await learningService.startTopic(userId, 'topic2', categoryId);
        await learningService.completeTopic(userId, 'topic2');

        // Act
        final completedTopics =
            await learningService.getUserCompletedTopics(userId);

        // Assert
        expect(completedTopics, hasLength(2));
        expect(completedTopics.every((t) => t.isCompleted), isTrue);
      });

      test('should get in-progress topics', () async {
        // Arrange
        await learningService.startTopic(userId, 'topic1', categoryId);
        await learningService.updateTopicProgress(
          userId: userId,
          topicId: 'topic1',
          completionPercentage: 30.0,
        );

        // Act
        final inProgressTopics =
            await learningService.getUserInProgressTopics(userId);

        // Assert
        expect(inProgressTopics, hasLength(1));
        expect(inProgressTopics.first.isInProgress, isTrue);
      });

      test('should get category progress', () async {
        // Arrange
        await learningService.startTopic(userId, 'topic1', categoryId);
        await learningService.startTopic(userId, 'topic2', categoryId);
        await learningService.completeTopic(userId, 'topic1');

        // Act
        final categoryProgress =
            await learningService.getUserCategoryProgress(userId, categoryId);

        // Assert
        expect(categoryProgress, hasLength(2));
        expect(categoryProgress.any((p) => p.isCompleted), isTrue);
        expect(categoryProgress.any((p) => p.isInProgress), isTrue);
      });
    });

    group('Learning Statistics', () {
      const userId = 'stats-user-123';
      const categoryId = 'programming';

      test('should calculate user learning stats', () async {
        // Arrange
        await learningService.startTopic(userId, 'topic1', categoryId);
        await learningService.completeTopic(userId, 'topic1');
        await learningService.updateTopicProgress(
          userId: userId,
          topicId: 'topic1',
          additionalTimeMinutes: 60,
        );

        await learningService.startTopic(userId, 'topic2', categoryId);
        await learningService.updateTopicProgress(
          userId: userId,
          topicId: 'topic2',
          completionPercentage: 50.0,
          additionalTimeMinutes: 30,
        );

        await learningService.bookmarkTopic(userId, 'topic3', 'design');

        // Act
        final stats = await learningService.getUserLearningStats(userId);

        // Assert
        expect(stats['totalTopics'], equals(3));
        expect(stats['completedTopics'], equals(1));
        expect(stats['inProgressTopics'], equals(1));
        expect(stats['bookmarkedTopics'], equals(1));
        expect(stats['totalTimeMinutes'], equals(90));
        expect(stats['categoriesExplored'], equals(2));
        expect(stats['completionRate'], closeTo(33.33, 0.1));
      });

      test('should return empty stats for new user', () async {
        // Act
        final stats = await learningService.getUserLearningStats('new-user');

        // Assert
        expect(stats['totalTopics'], equals(0));
        expect(stats['completedTopics'], equals(0));
        expect(stats['totalTimeMinutes'], equals(0));
        expect(stats['averageCompletion'], equals(0.0));
      });
    });

    group('Error Handling', () {
      test('should handle updating progress for non-existent topic', () async {
        // Act
        final success = await learningService.updateTopicProgress(
          userId: 'user',
          topicId: 'non-existent',
          completionPercentage: 50.0,
        );

        // Assert
        expect(success, isFalse);
      });

      test('should handle getting progress for non-existent topic', () async {
        // Act
        final progress = await learningService.getUserTopicProgress(
          'user',
          'non-existent-topic',
        );

        // Assert
        expect(progress, isNull);
      });

      test('should return empty list for non-existent user progress', () async {
        // Act
        final progress = await learningService.getUserCategoryProgress(
          'non-existent-user',
          'category',
        );

        // Assert
        expect(progress, isEmpty);
      });
    });
  });
}

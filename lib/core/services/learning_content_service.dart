import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/learning_category.dart';

class LearningContentService {
  static LearningContentService? _instance;
  static LearningContentService get instance =>
      _instance ??= LearningContentService._();

  LearningContentService._();

  final Uuid _uuid = const Uuid();

  // Collection references
  CollectionReference<LearningCategory> get _categoriesCollection =>
      FirebaseFirestore.instance
          .collection('learning_categories')
          .withConverter<LearningCategory>(
            fromFirestore: (snapshot, _) =>
                LearningCategory.fromFirestore(snapshot),
            toFirestore: (category, _) => category.toFirestore(),
          );

  CollectionReference<LearningTopic> get _topicsCollection => FirebaseFirestore
      .instance
      .collection('learning_topics')
      .withConverter<LearningTopic>(
        fromFirestore: (snapshot, _) => LearningTopic.fromFirestore(snapshot),
        toFirestore: (topic, _) => topic.toFirestore(),
      );

  CollectionReference<UserTopicProgress> get _progressCollection =>
      FirebaseFirestore.instance
          .collection('user_topic_progress')
          .withConverter<UserTopicProgress>(
            fromFirestore: (snapshot, _) =>
                UserTopicProgress.fromFirestore(snapshot),
            toFirestore: (progress, _) => progress.toFirestore(),
          );

  /// Get all learning categories
  Future<List<LearningCategory>> getCategories({
    bool? isFeatured,
    bool? isPopular,
    DifficultyLevel? difficulty,
  }) async {
    try {
      Query<LearningCategory> query = _categoriesCollection;

      if (isFeatured != null) {
        query = query.where('isFeatured', isEqualTo: isFeatured);
      }
      if (isPopular != null) {
        query = query.where('isPopular', isEqualTo: isPopular);
      }
      if (difficulty != null) {
        query = query.where('difficulty', isEqualTo: difficulty.name);
      }

      final snapshot = await query.orderBy('name').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      log('Error getting categories: $e');
      return [];
    }
  }

  /// Get featured categories
  Future<List<LearningCategory>> getFeaturedCategories() async {
    return getCategories(isFeatured: true);
  }

  /// Get popular categories
  Future<List<LearningCategory>> getPopularCategories() async {
    return getCategories(isPopular: true);
  }

  /// Get a specific category
  Future<LearningCategory?> getCategory(String categoryId) async {
    try {
      final doc = await _categoriesCollection.doc(categoryId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      log('Error getting category: $e');
      return null;
    }
  }

  /// Search categories
  Future<List<LearningCategory>> searchCategories(String query) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a simple implementation that searches by name
      final snapshot = await _categoriesCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      log('Error searching categories: $e');
      return [];
    }
  }

  /// Get topics for a category
  Future<List<LearningTopic>> getTopicsForCategory(String categoryId) async {
    try {
      final snapshot = await _topicsCollection
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('orderIndex')
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      log('Error getting topics for category: $e');
      return [];
    }
  }

  /// Get a specific topic
  Future<LearningTopic?> getTopic(String topicId) async {
    try {
      final doc = await _topicsCollection.doc(topicId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      log('Error getting topic: $e');
      return null;
    }
  }

  /// Search topics
  Future<List<LearningTopic>> searchTopics(String query,
      {String? categoryId}) async {
    try {
      Query<LearningTopic> firestoreQuery = _topicsCollection;

      if (categoryId != null) {
        firestoreQuery =
            firestoreQuery.where('categoryId', isEqualTo: categoryId);
      }

      // Simple name-based search
      firestoreQuery = firestoreQuery
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff');

      final snapshot = await firestoreQuery.get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      log('Error searching topics: $e');
      return [];
    }
  }

  /// Get user's topic progress
  Future<UserTopicProgress?> getUserTopicProgress(
      String userId, String topicId) async {
    try {
      final snapshot = await _progressCollection
          .where('userId', isEqualTo: userId)
          .where('topicId', isEqualTo: topicId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty ? snapshot.docs.first.data() : null;
    } catch (e) {
      log('Error getting user topic progress: $e');
      return null;
    }
  }

  /// Get all user progress for a category
  Future<List<UserTopicProgress>> getUserCategoryProgress(
      String userId, String categoryId) async {
    try {
      final snapshot = await _progressCollection
          .where('userId', isEqualTo: userId)
          .where('categoryId', isEqualTo: categoryId)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      log('Error getting user category progress: $e');
      return [];
    }
  }

  /// Start a topic (create initial progress)
  Future<String> startTopic(
      String userId, String topicId, String categoryId) async {
    try {
      final progressId = _uuid.v4();
      final now = DateTime.now();

      final progress = UserTopicProgress(
        id: progressId,
        userId: userId,
        topicId: topicId,
        categoryId: categoryId,
        status: ProgressStatus.inProgress,
        completionPercentage: 0.0,
        timeSpentMinutes: 0,
        attempts: 1,
        completedObjectives: [],
        bookmarkedResources: [],
        notes: {},
        startedAt: now,
        lastAccessedAt: now,
        createdAt: now,
        updatedAt: now,
      );

      await _progressCollection.doc(progressId).set(progress);
      log('Topic started: $topicId for user: $userId');
      return progressId;
    } catch (e) {
      log('Error starting topic: $e');
      rethrow;
    }
  }

  /// Update topic progress
  Future<bool> updateTopicProgress({
    required String userId,
    required String topicId,
    double? completionPercentage,
    int? additionalTimeMinutes,
    List<String>? completedObjectives,
    double? quizScore,
    Map<String, dynamic>? notes,
  }) async {
    try {
      final existingProgress = await getUserTopicProgress(userId, topicId);
      if (existingProgress == null) {
        log('No existing progress found for topic: $topicId');
        return false;
      }

      final now = DateTime.now();
      var status = existingProgress.status;

      // Update status based on completion percentage
      if (completionPercentage != null && completionPercentage >= 100.0) {
        status = ProgressStatus.completed;
      } else if (completionPercentage != null && completionPercentage > 0.0) {
        status = ProgressStatus.inProgress;
      }

      final updatedProgress = existingProgress.copyWith(
        status: status,
        completionPercentage: completionPercentage,
        timeSpentMinutes: additionalTimeMinutes != null
            ? existingProgress.timeSpentMinutes + additionalTimeMinutes
            : existingProgress.timeSpentMinutes,
        completedObjectives: completedObjectives,
        quizScore: quizScore,
        notes: notes != null
            ? {...existingProgress.notes, ...notes}
            : existingProgress.notes,
        completedAt: status == ProgressStatus.completed
            ? now
            : existingProgress.completedAt,
        lastAccessedAt: now,
        updatedAt: now,
      );

      await _progressCollection.doc(existingProgress.id).set(updatedProgress);
      return true;
    } catch (e) {
      log('Error updating topic progress: $e');
      return false;
    }
  }

  /// Complete a topic
  Future<bool> completeTopic(String userId, String topicId,
      {double? quizScore}) async {
    return updateTopicProgress(
      userId: userId,
      topicId: topicId,
      completionPercentage: 100.0,
      quizScore: quizScore,
    );
  }

  /// Bookmark a topic
  Future<bool> bookmarkTopic(
      String userId, String topicId, String categoryId) async {
    try {
      final existingProgress = await getUserTopicProgress(userId, topicId);

      if (existingProgress != null) {
        final updatedProgress = existingProgress.copyWith(
          status: ProgressStatus.bookmarked,
          lastAccessedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _progressCollection.doc(existingProgress.id).set(updatedProgress);
      } else {
        // Create new progress entry for bookmark
        await startTopic(userId, topicId, categoryId);
        final newProgress = await getUserTopicProgress(userId, topicId);
        if (newProgress != null) {
          final bookmarkedProgress = newProgress.copyWith(
            status: ProgressStatus.bookmarked,
            updatedAt: DateTime.now(),
          );
          await _progressCollection.doc(newProgress.id).set(bookmarkedProgress);
        }
      }

      return true;
    } catch (e) {
      log('Error bookmarking topic: $e');
      return false;
    }
  }

  /// Get user's bookmarked topics
  Future<List<UserTopicProgress>> getUserBookmarks(String userId) async {
    try {
      final snapshot = await _progressCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'bookmarked')
          .orderBy('updatedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      log('Error getting user bookmarks: $e');
      return [];
    }
  }

  /// Get user's completed topics
  Future<List<UserTopicProgress>> getUserCompletedTopics(String userId) async {
    try {
      final snapshot = await _progressCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .orderBy('completedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      log('Error getting user completed topics: $e');
      return [];
    }
  }

  /// Get user's in-progress topics
  Future<List<UserTopicProgress>> getUserInProgressTopics(String userId) async {
    try {
      final snapshot = await _progressCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'in_progress')
          .orderBy('lastAccessedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      log('Error getting user in-progress topics: $e');
      return [];
    }
  }

  /// Get learning statistics for a user
  Future<Map<String, dynamic>> getUserLearningStats(String userId) async {
    try {
      final allProgress =
          await _progressCollection.where('userId', isEqualTo: userId).get();

      final progressList = allProgress.docs.map((doc) => doc.data()).toList();

      final completedCount = progressList.where((p) => p.isCompleted).length;
      final inProgressCount = progressList.where((p) => p.isInProgress).length;
      final bookmarkedCount = progressList
          .where((p) => p.status == ProgressStatus.bookmarked)
          .length;
      final totalTimeMinutes =
          progressList.fold<int>(0, (total, p) => total + p.timeSpentMinutes);

      // Calculate average completion percentage
      final avgCompletion = progressList.isNotEmpty
          ? progressList.fold<double>(
                  0, (total, p) => total + p.completionPercentage) /
              progressList.length
          : 0.0;

      // Get unique categories
      final uniqueCategories =
          progressList.map((p) => p.categoryId).toSet().length;

      return {
        'totalTopics': progressList.length,
        'completedTopics': completedCount,
        'inProgressTopics': inProgressCount,
        'bookmarkedTopics': bookmarkedCount,
        'totalTimeMinutes': totalTimeMinutes,
        'averageCompletion': avgCompletion,
        'categoriesExplored': uniqueCategories,
        'completionRate': progressList.isNotEmpty
            ? (completedCount / progressList.length) * 100
            : 0.0,
      };
    } catch (e) {
      log('Error getting user learning stats: $e');
      return {};
    }
  }

  /// Stream categories for real-time updates
  Stream<List<LearningCategory>> streamCategories() {
    return _categoriesCollection
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Stream topics for a category
  Stream<List<LearningTopic>> streamTopicsForCategory(String categoryId) {
    return _topicsCollection
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('orderIndex')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Stream user progress for real-time updates
  Stream<List<UserTopicProgress>> streamUserProgress(String userId) {
    return _progressCollection
        .where('userId', isEqualTo: userId)
        .orderBy('lastAccessedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Initialize default categories (for development/testing)
  Future<void> initializeDefaultCategories() async {
    try {
      final existingCategories = await getCategories();
      if (existingCategories.isNotEmpty) {
        log('Categories already exist, skipping initialization');
        return;
      }

      final defaultCategories = _getDefaultCategories();

      for (final category in defaultCategories) {
        await _categoriesCollection.doc(category.id).set(category);
      }

      log('Default categories initialized');
    } catch (e) {
      log('Error initializing default categories: $e');
    }
  }

  List<LearningCategory> _getDefaultCategories() {
    final now = DateTime.now();

    return [
      LearningCategory(
        id: 'programming',
        name: 'Programming',
        description: 'Learn programming languages and software development',
        iconName: 'code',
        colorCode: '#2196F3',
        tags: ['coding', 'development', 'software'],
        topicCount: 25,
        userCount: 1500,
        difficulty: DifficultyLevel.intermediate,
        isPopular: true,
        isFeatured: true,
        averageRating: 4.5,
        estimatedHours: 40,
        prerequisites: [],
        metadata: {},
        createdAt: now,
        updatedAt: now,
      ),
      LearningCategory(
        id: 'data_science',
        name: 'Data Science',
        description: 'Master data analysis, machine learning, and statistics',
        iconName: 'analytics',
        colorCode: '#4CAF50',
        tags: ['data', 'analytics', 'ml', 'statistics'],
        topicCount: 20,
        userCount: 800,
        difficulty: DifficultyLevel.advanced,
        isPopular: true,
        isFeatured: true,
        averageRating: 4.3,
        estimatedHours: 60,
        prerequisites: ['basic_math', 'programming'],
        metadata: {},
        createdAt: now,
        updatedAt: now,
      ),
      LearningCategory(
        id: 'design',
        name: 'Design',
        description: 'UI/UX design, graphic design, and creative skills',
        iconName: 'palette',
        colorCode: '#FF9800',
        tags: ['ui', 'ux', 'graphics', 'creative'],
        topicCount: 15,
        userCount: 600,
        difficulty: DifficultyLevel.beginner,
        isPopular: false,
        isFeatured: true,
        averageRating: 4.2,
        estimatedHours: 30,
        prerequisites: [],
        metadata: {},
        createdAt: now,
        updatedAt: now,
      ),
      LearningCategory(
        id: 'business',
        name: 'Business',
        description: 'Business strategy, entrepreneurship, and management',
        iconName: 'business',
        colorCode: '#9C27B0',
        tags: ['strategy', 'management', 'entrepreneurship'],
        topicCount: 18,
        userCount: 900,
        difficulty: DifficultyLevel.intermediate,
        isPopular: true,
        isFeatured: false,
        averageRating: 4.1,
        estimatedHours: 35,
        prerequisites: [],
        metadata: {},
        createdAt: now,
        updatedAt: now,
      ),
      LearningCategory(
        id: 'languages',
        name: 'Languages',
        description: 'Learn new languages and improve communication skills',
        iconName: 'language',
        colorCode: '#F44336',
        tags: ['language', 'communication', 'culture'],
        topicCount: 30,
        userCount: 2000,
        difficulty: DifficultyLevel.beginner,
        isPopular: true,
        isFeatured: true,
        averageRating: 4.4,
        estimatedHours: 50,
        prerequisites: [],
        metadata: {},
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}

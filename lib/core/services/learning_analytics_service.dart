import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/firestore_models.dart';
import '../utils/environment_config.dart';
import 'firestore_service.dart';
import 'user_data_service.dart';

class LearningAnalyticsService {
  static LearningAnalyticsService? _instance;
  static LearningAnalyticsService get instance =>
      _instance ??= LearningAnalyticsService._();

  LearningAnalyticsService._();

  final FirestoreService _firestore = FirestoreService.instance;
  final UserDataService _userDataService = UserDataService.instance;
  final Uuid _uuid = const Uuid();

  /// Start a new learning session
  Future<String?> startLearningSession({
    required String userId,
    required String topic,
    String? category,
    LearningSessionType type = LearningSessionType.general,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final sessionId = _uuid.v4();
      final session = LearningSession(
        id: sessionId,
        userId: userId,
        topic: topic,
        category: category,
        startTime: DateTime.now(),
        type: type,
        metadata: metadata ?? {},
      );

      final success = await _firestore.set(
        _firestore.learningSessionDoc(userId, sessionId),
        session,
      );

      if (success) {
        log('Learning session started: $sessionId');
        return sessionId;
      }

      return null;
    } catch (e) {
      log('Error starting learning session: $e');
      return null;
    }
  }

  /// End a learning session
  Future<bool> endLearningSession(
    String userId,
    String sessionId, {
    List<String>? topicsDiscussed,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final session = await _firestore.get(
        _firestore.learningSessionDoc(userId, sessionId),
      );

      if (session == null) return false;

      final endTime = DateTime.now();
      final duration = endTime.difference(session.startTime);
      final durationMinutes = duration.inMinutes;

      // Calculate experience points based on session duration and type
      final experienceGained = _calculateExperiencePoints(
        durationMinutes,
        session.type,
        topicsDiscussed?.length ?? 0,
      );

      final updates = {
        'endTime': Timestamp.fromDate(endTime),
        'durationMinutes': durationMinutes,
        'experienceGained': experienceGained,
        'topicsDiscussed': topicsDiscussed ?? [],
        'metadata': {...session.metadata, ...?metadata},
      };

      final success = await _firestore.update(
        _firestore.learningSessionDoc(userId, sessionId),
        updates,
      );

      if (success) {
        // Update user stats
        await _userDataService.incrementUserStats(
          userId,
          sessions: 1,
          learningMinutes: durationMinutes,
          experiencePoints: experienceGained,
        );

        // Update user streak
        await _userDataService.updateUserStreak(userId);

        // Update user level
        await _userDataService.updateUserLevel(userId);

        // Update topic progress
        await _updateTopicProgress(userId, session.topic, durationMinutes);

        // Check for achievements
        await _checkAndAwardAchievements(userId);

        log('Learning session ended: $sessionId, Duration: ${durationMinutes}min, XP: $experienceGained');
      }

      return success;
    } catch (e) {
      log('Error ending learning session: $e');
      return false;
    }
  }

  /// Calculate experience points based on session parameters
  int _calculateExperiencePoints(
    int durationMinutes,
    LearningSessionType type,
    int topicsCount,
  ) {
    int baseXP = durationMinutes * 2; // 2 XP per minute

    // Type multipliers
    switch (type) {
      case LearningSessionType.quiz:
        baseXP = (baseXP * 1.5).round();
        break;
      case LearningSessionType.practice:
        baseXP = (baseXP * 1.3).round();
        break;
      case LearningSessionType.explanation:
        baseXP = (baseXP * 1.2).round();
        break;
      case LearningSessionType.summary:
        baseXP = (baseXP * 1.1).round();
        break;
      case LearningSessionType.general:
        // No multiplier
        break;
    }

    // Bonus for covering multiple topics
    if (topicsCount > 1) {
      baseXP += (topicsCount - 1) * 5;
    }

    // Cap minimum and maximum XP
    return math.max(1, math.min(baseXP, 100));
  }

  /// Update topic progress
  Future<bool> _updateTopicProgress(
    String userId,
    String topic,
    int durationMinutes,
  ) async {
    try {
      final progressId = topic.toLowerCase().replaceAll(' ', '_');
      final progressDoc = _firestore.userProgressDoc(userId, progressId);

      final existingProgress = await _firestore.get(progressDoc);

      if (existingProgress == null) {
        // Create new progress entry
        final newProgress = UserProgress(
          id: progressId,
          userId: userId,
          topic: topic,
          completionPercentage: _calculateCompletionPercentage(durationMinutes),
          totalSessions: 1,
          lastStudied: DateTime.now(),
          createdAt: DateTime.now(),
        );

        return await _firestore.set(progressDoc, newProgress);
      } else {
        // Update existing progress
        final newCompletionPercentage = math.min(
          100.0,
          existingProgress.completionPercentage +
              _calculateCompletionPercentage(durationMinutes),
        );

        final updates = {
          'completionPercentage': newCompletionPercentage,
          'totalSessions': existingProgress.totalSessions + 1,
          'lastStudied': Timestamp.fromDate(DateTime.now()),
        };

        return await _firestore.update(progressDoc, updates);
      }
    } catch (e) {
      log('Error updating topic progress: $e');
      return false;
    }
  }

  /// Calculate completion percentage based on session duration
  double _calculateCompletionPercentage(int durationMinutes) {
    // Each minute contributes to completion (adjust as needed)
    return math.min(10.0, durationMinutes * 0.5);
  }

  /// Check and award achievements
  Future<void> _checkAndAwardAchievements(String userId) async {
    try {
      final user = await _userDataService.getUser(userId);
      if (user == null) return;

      final stats = user.stats;
      final achievements = <Achievement>[];

      // Streak achievements
      if (stats.streakDays >= 7 && !await _hasAchievement(userId, 'streak_7')) {
        achievements.add(_createAchievement(
          userId,
          'streak_7',
          '7-Day Streak',
          'Completed 7 consecutive days of learning',
          '🔥',
          AchievementType.streak,
          50,
        ));
      }

      if (stats.streakDays >= 30 &&
          !await _hasAchievement(userId, 'streak_30')) {
        achievements.add(_createAchievement(
          userId,
          'streak_30',
          '30-Day Streak',
          'Completed 30 consecutive days of learning',
          '🏆',
          AchievementType.streak,
          200,
        ));
      }

      // Session achievements
      if (stats.totalSessions >= 10 &&
          !await _hasAchievement(userId, 'sessions_10')) {
        achievements.add(_createAchievement(
          userId,
          'sessions_10',
          'Getting Started',
          'Completed 10 learning sessions',
          '🎯',
          AchievementType.sessions,
          25,
        ));
      }

      if (stats.totalSessions >= 100 &&
          !await _hasAchievement(userId, 'sessions_100')) {
        achievements.add(_createAchievement(
          userId,
          'sessions_100',
          'Dedicated Learner',
          'Completed 100 learning sessions',
          '📚',
          AchievementType.sessions,
          100,
        ));
      }

      // Time achievements
      if (stats.totalLearningMinutes >= 60 &&
          !await _hasAchievement(userId, 'time_1h')) {
        achievements.add(_createAchievement(
          userId,
          'time_1h',
          'First Hour',
          'Spent 1 hour learning',
          '⏰',
          AchievementType.time,
          30,
        ));
      }

      if (stats.totalLearningMinutes >= 600 &&
          !await _hasAchievement(userId, 'time_10h')) {
        achievements.add(_createAchievement(
          userId,
          'time_10h',
          'Time Investment',
          'Spent 10 hours learning',
          '⌚',
          AchievementType.time,
          150,
        ));
      }

      // Level achievements
      if (stats.level >= 5 && !await _hasAchievement(userId, 'level_5')) {
        achievements.add(_createAchievement(
          userId,
          'level_5',
          'Rising Star',
          'Reached level 5',
          '⭐',
          AchievementType.special,
          75,
        ));
      }

      // Save achievements
      for (final achievement in achievements) {
        await _firestore.set(
          _firestore.achievementDoc(userId, achievement.id),
          achievement,
        );

        // Award experience points for achievement
        await _userDataService.incrementUserStats(
          userId,
          experiencePoints: achievement.pointsAwarded,
        );

        log('Achievement unlocked: ${achievement.title} for user $userId');
      }
    } catch (e) {
      log('Error checking achievements: $e');
    }
  }

  /// Check if user has a specific achievement
  Future<bool> _hasAchievement(String userId, String achievementId) async {
    try {
      final achievement = await _firestore.get(
        _firestore.achievementDoc(userId, achievementId),
      );
      return achievement != null;
    } catch (e) {
      return false;
    }
  }

  /// Create achievement object
  Achievement _createAchievement(
    String userId,
    String id,
    String title,
    String description,
    String icon,
    AchievementType type,
    int points,
  ) {
    return Achievement(
      id: id,
      userId: userId,
      title: title,
      description: description,
      icon: icon,
      type: type,
      pointsAwarded: points,
      unlockedAt: DateTime.now(),
    );
  }

  /// Get learning sessions for a user
  Future<List<LearningSession>> getLearningSessions(
    String userId, {
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _firestore
          .learningSessions(userId)
          .orderBy('startTime', descending: true);

      if (startDate != null) {
        query = query.where(
          'startTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'startTime',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      log('Error getting learning sessions: $e');
      return [];
    }
  }

  /// Get user progress for all topics
  Future<List<UserProgress>> getUserProgress(String userId) async {
    try {
      final snapshot = await _firestore
          .userProgress(userId)
          .orderBy('lastStudied', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      log('Error getting user progress: $e');
      return [];
    }
  }

  /// Get user achievements
  Future<List<Achievement>> getUserAchievements(
    String userId, {
    bool visibleOnly = true,
  }) async {
    try {
      var query = _firestore
          .achievements(userId)
          .orderBy('unlockedAt', descending: true);

      if (visibleOnly) {
        query = query.where('isVisible', isEqualTo: true);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      log('Error getting user achievements: $e');
      return [];
    }
  }

  /// Get learning analytics summary
  Future<Map<String, dynamic>?> getLearningAnalytics(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final sessions = await getLearningSessions(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      final progress = await getUserProgress(userId);
      final achievements = await getUserAchievements(userId);

      final totalSessions = sessions.length;
      final totalMinutes = sessions.fold<int>(
        0,
        (total, session) => total + session.durationMinutes,
      );

      final averageSessionLength =
          totalSessions > 0 ? totalMinutes / totalSessions : 0.0;

      final topicCounts = <String, int>{};
      for (final session in sessions) {
        topicCounts[session.topic] = (topicCounts[session.topic] ?? 0) + 1;
      }

      final mostStudiedTopic = topicCounts.isNotEmpty
          ? topicCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
          : null;

      return {
        'totalSessions': totalSessions,
        'totalMinutes': totalMinutes,
        'averageSessionLength': averageSessionLength,
        'topicsStudied': topicCounts.length,
        'mostStudiedTopic': mostStudiedTopic,
        'completedTopics': progress.where((p) => p.isCompleted).length,
        'totalAchievements': achievements.length,
        'topicProgress': progress
            .map((p) => {
                  'topic': p.topic,
                  'completion': p.completionPercentage,
                  'sessions': p.totalSessions,
                  'lastStudied': p.lastStudied.toIso8601String(),
                })
            .toList(),
        'recentAchievements': achievements
            .take(5)
            .map((a) => {
                  'title': a.title,
                  'description': a.description,
                  'icon': a.icon,
                  'unlockedAt': a.unlockedAt.toIso8601String(),
                })
            .toList(),
      };
    } catch (e) {
      log('Error getting learning analytics: $e');
      return null;
    }
  }

  /// Clean up old learning data
  Future<void> cleanupOldLearningData(String userId) async {
    try {
      final maxSessions = EnvironmentConfig.maxLearningSessionsStored;

      final sessions = await _firestore
          .learningSessions(userId)
          .orderBy('startTime', descending: true)
          .get();

      if (sessions.docs.length > maxSessions) {
        final sessionsToDelete = sessions.docs.skip(maxSessions);

        final batch = _firestore.batch();
        for (final session in sessionsToDelete) {
          batch.delete(session.reference);
        }

        await _firestore.commitBatch(batch);
        log('Cleaned up ${sessionsToDelete.length} old learning sessions for user $userId');
      }
    } catch (e) {
      log('Error cleaning up old learning data: $e');
    }
  }
}

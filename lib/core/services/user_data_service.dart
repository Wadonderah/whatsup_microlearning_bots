import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math' show sqrt;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/firestore_models.dart' as firestore_models;
import '../models/user_model.dart';
import 'firestore_service.dart';

class UserDataService {
  static UserDataService? _instance;
  static UserDataService get instance => _instance ??= UserDataService._();

  UserDataService._();

  final FirestoreService _firestore = FirestoreService.instance;

  /// Create or update user profile in Firestore
  Future<bool> createOrUpdateUser(AppUser user) async {
    try {
      final firestoreUser = firestore_models.FirestoreUser(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoURL: user.photoURL,
        emailVerified: user.emailVerified,
        createdAt: user.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        lastSignInAt: user.lastSignInAt,
        signInMethods: user.signInMethods,
        preferences: user.preferences.toJson(),
        stats: const firestore_models.UserStats(),
      );

      final success = await _firestore.set(
        _firestore.userDoc(user.uid),
        firestoreUser,
      );

      if (success) {
        dev.log('User profile created/updated successfully: ${user.uid}');
      }

      return success;
    } catch (e) {
      dev.log('Error creating/updating user: $e');
      return false;
    }
  }

  /// Get user profile from Firestore
  Future<firestore_models.FirestoreUser?> getUser(String userId) async {
    try {
      return await _firestore.get(_firestore.userDoc(userId));
    } catch (e) {
      dev.log('Error getting user: $e');
      return null;
    }
  }

  /// Stream user profile for real-time updates
  Stream<firestore_models.FirestoreUser?> streamUser(String userId) {
    return _firestore.streamDocument(_firestore.userDoc(userId));
  }

  /// Update user preferences
  Future<bool> updateUserPreferences(
    String userId,
    Map<String, dynamic> preferences,
  ) async {
    try {
      return await _firestore.update(
        _firestore.userDoc(userId),
        {
          'preferences': preferences,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      dev.log('Error updating user preferences: $e');
      return false;
    }
  }

  /// Update user stats
  Future<bool> updateUserStats(
      String userId, firestore_models.UserStats stats) async {
    try {
      return await _firestore.update(
        _firestore.userDoc(userId),
        {
          'stats': stats.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      dev.log('Error updating user stats: $e');
      return false;
    }
  }

  /// Increment user stats atomically
  Future<bool> incrementUserStats(
    String userId, {
    int? sessions,
    int? messages,
    int? learningMinutes,
    int? experiencePoints,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (sessions != null) {
        updates['stats.totalSessions'] = FieldValue.increment(sessions);
      }
      if (messages != null) {
        updates['stats.totalMessages'] = FieldValue.increment(messages);
      }
      if (learningMinutes != null) {
        updates['stats.totalLearningMinutes'] =
            FieldValue.increment(learningMinutes);
      }
      if (experiencePoints != null) {
        updates['stats.experiencePoints'] =
            FieldValue.increment(experiencePoints);
      }

      return await _firestore.update(_firestore.userDoc(userId), updates);
    } catch (e) {
      dev.log('Error incrementing user stats: $e');
      return false;
    }
  }

  /// Update user streak
  Future<bool> updateUserStreak(String userId) async {
    try {
      final user = await getUser(userId);
      if (user == null) return false;

      final now = DateTime.now();
      final lastActive = user.stats.lastActiveDate;

      int newStreak = user.stats.streakDays;

      if (lastActive == null) {
        // First time user
        newStreak = 1;
      } else {
        final daysSinceLastActive = now.difference(lastActive).inDays;

        if (daysSinceLastActive == 1) {
          // Consecutive day
          newStreak += 1;
        } else if (daysSinceLastActive > 1) {
          // Streak broken
          newStreak = 1;
        }
        // Same day, no change to streak
      }

      final updatedStats = user.stats.copyWith(
        streakDays: newStreak,
        lastActiveDate: now,
      );

      return await updateUserStats(userId, updatedStats);
    } catch (e) {
      dev.log('Error updating user streak: $e');
      return false;
    }
  }

  /// Calculate and update user level based on experience points
  Future<bool> updateUserLevel(String userId) async {
    try {
      final user = await getUser(userId);
      if (user == null) return false;

      final currentXP = user.stats.experiencePoints;
      final newLevel = _calculateLevel(currentXP);

      if (newLevel != user.stats.level) {
        final updatedStats = user.stats.copyWith(level: newLevel);
        return await updateUserStats(userId, updatedStats);
      }

      return true;
    } catch (e) {
      dev.log('Error updating user level: $e');
      return false;
    }
  }

  /// Calculate level based on experience points
  int _calculateLevel(int experiencePoints) {
    // Level formula: level = floor(sqrt(XP / 100)) + 1
    // This means: Level 1: 0-99 XP, Level 2: 100-399 XP, Level 3: 400-899 XP, etc.
    if (experiencePoints < 0) return 1;
    return sqrt(experiencePoints / 100).floor() + 1;
  }

  /// Get experience points needed for next level
  int getXPForNextLevel(int currentLevel) {
    // XP needed for level n: (n-1)^2 * 100
    return (currentLevel * currentLevel) * 100;
  }

  /// Get progress to next level (0.0 to 1.0)
  double getLevelProgress(int experiencePoints, int currentLevel) {
    final currentLevelXP = getXPForNextLevel(currentLevel - 1);
    final nextLevelXP = getXPForNextLevel(currentLevel);
    final progressXP = experiencePoints - currentLevelXP;
    final totalXPNeeded = nextLevelXP - currentLevelXP;

    return (progressXP / totalXPNeeded).clamp(0.0, 1.0);
  }

  /// Delete user data (GDPR compliance)
  Future<bool> deleteUserData(String userId) async {
    try {
      final batch = _firestore.batch();

      // Delete user document
      batch.delete(_firestore.userDoc(userId));

      // Delete chat sessions and messages
      final chatSessions = await _firestore.chatSessions(userId).get();
      for (final session in chatSessions.docs) {
        batch.delete(session.reference);

        // Delete messages in this session
        final messages =
            await _firestore.chatMessages(userId, session.id).get();
        for (final message in messages.docs) {
          batch.delete(message.reference);
        }
      }

      // Delete learning sessions
      final learningSessions = await _firestore.learningSessions(userId).get();
      for (final session in learningSessions.docs) {
        batch.delete(session.reference);
      }

      // Delete user progress
      final progressEntries = await _firestore.userProgress(userId).get();
      for (final progress in progressEntries.docs) {
        batch.delete(progress.reference);
      }

      // Delete achievements
      final achievements = await _firestore.achievements(userId).get();
      for (final achievement in achievements.docs) {
        batch.delete(achievement.reference);
      }

      final success = await _firestore.commitBatch(batch);

      if (success) {
        dev.log('User data deleted successfully: $userId');
      }

      return success;
    } catch (e) {
      dev.log('Error deleting user data: $e');
      return false;
    }
  }

  /// Export user data (GDPR compliance)
  Future<Map<String, dynamic>?> exportUserData(String userId) async {
    try {
      final userData = <String, dynamic>{};

      // Get user profile
      final user = await getUser(userId);
      if (user != null) {
        userData['profile'] = user.toJson();
      }

      // Get chat sessions
      final chatSessions = await _firestore.chatSessions(userId).get();
      userData['chatSessions'] =
          chatSessions.docs.map((doc) => doc.data().toJson()).toList();

      // Get learning sessions
      final learningSessions = await _firestore.learningSessions(userId).get();
      userData['learningSessions'] =
          learningSessions.docs.map((doc) => doc.data().toJson()).toList();

      // Get user progress
      final progressEntries = await _firestore.userProgress(userId).get();
      userData['progress'] =
          progressEntries.docs.map((doc) => doc.data().toJson()).toList();

      // Get achievements
      final achievements = await _firestore.achievements(userId).get();
      userData['achievements'] =
          achievements.docs.map((doc) => doc.data().toJson()).toList();

      userData['exportedAt'] = DateTime.now().toIso8601String();
      userData['userId'] = userId;

      return userData;
    } catch (e) {
      dev.log('Error exporting user data: $e');
      return null;
    }
  }

  /// Check if user exists
  Future<bool> userExists(String userId) async {
    return await _firestore.documentExists(_firestore.userDoc(userId));
  }

  /// Get user statistics summary
  Future<Map<String, dynamic>?> getUserStatsSummary(String userId) async {
    try {
      final user = await getUser(userId);
      if (user == null) return null;

      final stats = user.stats;
      final currentLevel = stats.level;
      final nextLevelXP = getXPForNextLevel(currentLevel);
      final levelProgress =
          getLevelProgress(stats.experiencePoints, currentLevel);

      return {
        'totalSessions': stats.totalSessions,
        'totalMessages': stats.totalMessages,
        'totalLearningMinutes': stats.totalLearningMinutes,
        'streakDays': stats.streakDays,
        'level': currentLevel,
        'experiencePoints': stats.experiencePoints,
        'nextLevelXP': nextLevelXP,
        'levelProgress': levelProgress,
        'lastActiveDate': stats.lastActiveDate?.toIso8601String(),
      };
    } catch (e) {
      dev.log('Error getting user stats summary: $e');
      return null;
    }
  }
}

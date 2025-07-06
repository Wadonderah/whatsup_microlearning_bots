import 'package:firebase_auth/firebase_auth.dart';
import 'package:json_annotation/json_annotation.dart';

import 'auth_result.dart';

part 'user_model.g.dart';

@JsonSerializable()
class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final bool emailVerified;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;
  final List<String> signInMethods;
  final UserPreferences preferences;
  final UserStats stats;

  const AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.emailVerified = false,
    this.createdAt,
    this.lastSignInAt,
    this.signInMethods = const [],
    this.preferences = const UserPreferences(),
    this.stats = const UserStats(),
  });

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
  Map<String, dynamic> toJson() => _$AppUserToJson(this);

  /// Create AppUser from Firebase User
  factory AppUser.fromFirebaseUser(User firebaseUser) {
    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      emailVerified: firebaseUser.emailVerified,
      createdAt: firebaseUser.metadata.creationTime,
      lastSignInAt: firebaseUser.metadata.lastSignInTime,
      signInMethods:
          firebaseUser.providerData.map((info) => info.providerId).toList(),
    );
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? lastSignInAt,
    List<String>? signInMethods,
    UserPreferences? preferences,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      signInMethods: signInMethods ?? this.signInMethods,
      preferences: preferences ?? this.preferences,
    );
  }

  /// Get user's initials for avatar
  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final names = displayName!.split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      } else {
        return names[0][0].toUpperCase();
      }
    } else if (email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return 'U';
  }

  /// Check if user signed in with Google
  bool get isGoogleUser => signInMethods.contains('google.com');

  /// Check if user signed in with email/password
  bool get isEmailUser => signInMethods.contains('password');

  /// Get display name or fallback to email
  String get displayNameOrEmail => displayName ?? email;
}

@JsonSerializable()
class UserPreferences {
  final String theme; // 'light', 'dark', 'system'
  final String language; // 'en', 'es', 'fr', etc.
  final bool notificationsEnabled;
  final bool soundEnabled;
  final String learningGoal; // 'beginner', 'intermediate', 'advanced'
  final List<String> interests;
  final int dailyLearningMinutes;

  const UserPreferences({
    this.theme = 'system',
    this.language = 'en',
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.learningGoal = 'beginner',
    this.interests = const [],
    this.dailyLearningMinutes = 15,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);

  UserPreferences copyWith({
    String? theme,
    String? language,
    bool? notificationsEnabled,
    bool? soundEnabled,
    String? learningGoal,
    List<String>? interests,
    int? dailyLearningMinutes,
  }) {
    return UserPreferences(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      learningGoal: learningGoal ?? this.learningGoal,
      interests: interests ?? this.interests,
      dailyLearningMinutes: dailyLearningMinutes ?? this.dailyLearningMinutes,
    );
  }
}

/// User statistics model
@JsonSerializable()
class UserStats {
  final int experiencePoints;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final int totalLessons;
  final int completedLessons;
  final int totalStudyMinutes;
  final int totalSessions;
  final int totalMessages;
  final DateTime? lastActivityDate;
  final DateTime? streakStartDate;
  final List<String> achievements;
  final Map<String, int> categoryProgress;
  final Map<String, dynamic> weeklyStats;
  final Map<String, dynamic> monthlyStats;

  const UserStats({
    this.experiencePoints = 0,
    this.level = 1,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalLessons = 0,
    this.completedLessons = 0,
    this.totalStudyMinutes = 0,
    this.totalSessions = 0,
    this.totalMessages = 0,
    this.lastActivityDate,
    this.streakStartDate,
    this.achievements = const [],
    this.categoryProgress = const {},
    this.weeklyStats = const {},
    this.monthlyStats = const {},
  });

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);
  Map<String, dynamic> toJson() => _$UserStatsToJson(this);

  /// Calculate level from experience points
  int get calculatedLevel => (experiencePoints / 100).floor() + 1;

  /// Get progress to next level (0.0 to 1.0)
  double get levelProgress {
    final currentLevelXP = (level - 1) * 100;
    final nextLevelXP = level * 100;
    final progressXP = experiencePoints - currentLevelXP;
    return (progressXP / (nextLevelXP - currentLevelXP)).clamp(0.0, 1.0);
  }

  /// Get XP needed for next level
  int get xpToNextLevel {
    final nextLevelXP = level * 100;
    return (nextLevelXP - experiencePoints).clamp(0, nextLevelXP);
  }

  /// Check if user is active today
  bool get isActiveToday {
    if (lastActivityDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActivity = DateTime(
      lastActivityDate!.year,
      lastActivityDate!.month,
      lastActivityDate!.day,
    );
    return lastActivity.isAtSameMomentAs(today);
  }

  /// Get completion rate (0.0 to 1.0)
  double get completionRate {
    if (totalLessons == 0) return 0.0;
    return (completedLessons / totalLessons).clamp(0.0, 1.0);
  }

  /// Copy with new values
  UserStats copyWith({
    int? experiencePoints,
    int? level,
    int? currentStreak,
    int? longestStreak,
    int? totalLessons,
    int? completedLessons,
    int? totalStudyMinutes,
    int? totalSessions,
    int? totalMessages,
    DateTime? lastActivityDate,
    DateTime? streakStartDate,
    List<String>? achievements,
    Map<String, int>? categoryProgress,
    Map<String, dynamic>? weeklyStats,
    Map<String, dynamic>? monthlyStats,
  }) {
    return UserStats(
      experiencePoints: experiencePoints ?? this.experiencePoints,
      level: level ?? this.level,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalLessons: totalLessons ?? this.totalLessons,
      completedLessons: completedLessons ?? this.completedLessons,
      totalStudyMinutes: totalStudyMinutes ?? this.totalStudyMinutes,
      totalSessions: totalSessions ?? this.totalSessions,
      totalMessages: totalMessages ?? this.totalMessages,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      streakStartDate: streakStartDate ?? this.streakStartDate,
      achievements: achievements ?? this.achievements,
      categoryProgress: categoryProgress ?? this.categoryProgress,
      weeklyStats: weeklyStats ?? this.weeklyStats,
      monthlyStats: monthlyStats ?? this.monthlyStats,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserStats &&
        other.experiencePoints == experiencePoints &&
        other.level == level &&
        other.currentStreak == currentStreak &&
        other.totalLessons == totalLessons &&
        other.completedLessons == completedLessons;
  }

  @override
  int get hashCode {
    return experiencePoints.hashCode ^
        level.hashCode ^
        currentStreak.hashCode ^
        totalLessons.hashCode ^
        completedLessons.hashCode;
  }

  @override
  String toString() {
    return 'UserStats(level: $level, xp: $experiencePoints, streak: $currentStreak, completion: ${(completionRate * 100).toStringAsFixed(1)}%)';
  }
}

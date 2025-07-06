// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppUser _$AppUserFromJson(Map<String, dynamic> json) => AppUser(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoURL: json['photoURL'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      lastSignInAt: json['lastSignInAt'] == null
          ? null
          : DateTime.parse(json['lastSignInAt'] as String),
      signInMethods: (json['signInMethods'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      preferences: json['preferences'] == null
          ? const UserPreferences()
          : UserPreferences.fromJson(
              json['preferences'] as Map<String, dynamic>),
      stats: json['stats'] == null
          ? const UserStats()
          : UserStats.fromJson(json['stats'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AppUserToJson(AppUser instance) => <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'displayName': instance.displayName,
      'photoURL': instance.photoURL,
      'emailVerified': instance.emailVerified,
      'createdAt': instance.createdAt?.toIso8601String(),
      'lastSignInAt': instance.lastSignInAt?.toIso8601String(),
      'signInMethods': instance.signInMethods,
      'preferences': instance.preferences,
      'stats': instance.stats,
    };

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) =>
    UserPreferences(
      theme: json['theme'] as String? ?? 'system',
      language: json['language'] as String? ?? 'en',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      learningGoal: json['learningGoal'] as String? ?? 'beginner',
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      dailyLearningMinutes:
          (json['dailyLearningMinutes'] as num?)?.toInt() ?? 15,
    );

Map<String, dynamic> _$UserPreferencesToJson(UserPreferences instance) =>
    <String, dynamic>{
      'theme': instance.theme,
      'language': instance.language,
      'notificationsEnabled': instance.notificationsEnabled,
      'soundEnabled': instance.soundEnabled,
      'learningGoal': instance.learningGoal,
      'interests': instance.interests,
      'dailyLearningMinutes': instance.dailyLearningMinutes,
    };

UserStats _$UserStatsFromJson(Map<String, dynamic> json) => UserStats(
      experiencePoints: (json['experiencePoints'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      totalLessons: (json['totalLessons'] as num?)?.toInt() ?? 0,
      completedLessons: (json['completedLessons'] as num?)?.toInt() ?? 0,
      totalStudyMinutes: (json['totalStudyMinutes'] as num?)?.toInt() ?? 0,
      totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
      totalMessages: (json['totalMessages'] as num?)?.toInt() ?? 0,
      lastActivityDate: json['lastActivityDate'] == null
          ? null
          : DateTime.parse(json['lastActivityDate'] as String),
      streakStartDate: json['streakStartDate'] == null
          ? null
          : DateTime.parse(json['streakStartDate'] as String),
      achievements: (json['achievements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      categoryProgress:
          (json['categoryProgress'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, (e as num).toInt()),
              ) ??
              const {},
      weeklyStats: json['weeklyStats'] as Map<String, dynamic>? ?? const {},
      monthlyStats: json['monthlyStats'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$UserStatsToJson(UserStats instance) => <String, dynamic>{
      'experiencePoints': instance.experiencePoints,
      'level': instance.level,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'totalLessons': instance.totalLessons,
      'completedLessons': instance.completedLessons,
      'totalStudyMinutes': instance.totalStudyMinutes,
      'totalSessions': instance.totalSessions,
      'totalMessages': instance.totalMessages,
      'lastActivityDate': instance.lastActivityDate?.toIso8601String(),
      'streakStartDate': instance.streakStartDate?.toIso8601String(),
      'achievements': instance.achievements,
      'categoryProgress': instance.categoryProgress,
      'weeklyStats': instance.weeklyStats,
      'monthlyStats': instance.monthlyStats,
    };

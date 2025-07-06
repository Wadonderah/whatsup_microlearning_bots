// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firestore_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FirestoreUser _$FirestoreUserFromJson(Map<String, dynamic> json) =>
    FirestoreUser(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoURL: json['photoURL'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
      lastSignInAt: const TimestampConverter().fromJson(json['lastSignInAt']),
      signInMethods: (json['signInMethods'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      preferences: json['preferences'] as Map<String, dynamic>? ?? const {},
      stats: json['stats'] == null
          ? const UserStats()
          : UserStats.fromJson(json['stats'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FirestoreUserToJson(FirestoreUser instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'displayName': instance.displayName,
      'photoURL': instance.photoURL,
      'emailVerified': instance.emailVerified,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'lastSignInAt': _$JsonConverterToJson<dynamic, DateTime>(
          instance.lastSignInAt, const TimestampConverter().toJson),
      'signInMethods': instance.signInMethods,
      'preferences': instance.preferences,
      'stats': instance.stats,
    };

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);

UserStats _$UserStatsFromJson(Map<String, dynamic> json) => UserStats(
      totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
      totalMessages: (json['totalMessages'] as num?)?.toInt() ?? 0,
      totalLearningMinutes:
          (json['totalLearningMinutes'] as num?)?.toInt() ?? 0,
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      experiencePoints: (json['experiencePoints'] as num?)?.toInt() ?? 0,
      lastActiveDate:
          const TimestampConverter().fromJson(json['lastActiveDate']),
    );

Map<String, dynamic> _$UserStatsToJson(UserStats instance) => <String, dynamic>{
      'totalSessions': instance.totalSessions,
      'totalMessages': instance.totalMessages,
      'totalLearningMinutes': instance.totalLearningMinutes,
      'streakDays': instance.streakDays,
      'level': instance.level,
      'experiencePoints': instance.experiencePoints,
      'lastActiveDate': _$JsonConverterToJson<dynamic, DateTime>(
          instance.lastActiveDate, const TimestampConverter().toJson),
    };

ChatSession _$ChatSessionFromJson(Map<String, dynamic> json) => ChatSession(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      topic: json['topic'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
      messageCount: (json['messageCount'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$ChatSessionToJson(ChatSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'topic': instance.topic,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'messageCount': instance.messageCount,
      'isActive': instance.isActive,
      'metadata': instance.metadata,
    };

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      role: json['role'] as String,
      timestamp: const TimestampConverter().fromJson(json['timestamp']),
      templateId: json['templateId'] as String?,
      templateData: json['templateData'] as Map<String, dynamic>?,
      isLoading: json['isLoading'] as bool? ?? false,
      error: json['error'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'userId': instance.userId,
      'content': instance.content,
      'role': instance.role,
      'timestamp': const TimestampConverter().toJson(instance.timestamp),
      'templateId': instance.templateId,
      'templateData': instance.templateData,
      'isLoading': instance.isLoading,
      'error': instance.error,
      'metadata': instance.metadata,
    };

LearningSession _$LearningSessionFromJson(Map<String, dynamic> json) =>
    LearningSession(
      id: json['id'] as String,
      userId: json['userId'] as String,
      topic: json['topic'] as String,
      category: json['category'] as String?,
      startTime: const TimestampConverter().fromJson(json['startTime']),
      endTime: const TimestampConverter().fromJson(json['endTime']),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      messageCount: (json['messageCount'] as num?)?.toInt() ?? 0,
      topicsDiscussed: (json['topicsDiscussed'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      experienceGained: (json['experienceGained'] as num?)?.toInt() ?? 0,
      type: $enumDecodeNullable(_$LearningSessionTypeEnumMap, json['type']) ??
          LearningSessionType.general,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$LearningSessionToJson(LearningSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'topic': instance.topic,
      'category': instance.category,
      'startTime': const TimestampConverter().toJson(instance.startTime),
      'endTime': _$JsonConverterToJson<dynamic, DateTime>(
          instance.endTime, const TimestampConverter().toJson),
      'durationMinutes': instance.durationMinutes,
      'messageCount': instance.messageCount,
      'topicsDiscussed': instance.topicsDiscussed,
      'experienceGained': instance.experienceGained,
      'type': _$LearningSessionTypeEnumMap[instance.type]!,
      'metadata': instance.metadata,
    };

const _$LearningSessionTypeEnumMap = {
  LearningSessionType.general: 'general',
  LearningSessionType.quiz: 'quiz',
  LearningSessionType.explanation: 'explanation',
  LearningSessionType.practice: 'practice',
  LearningSessionType.summary: 'summary',
};

UserProgress _$UserProgressFromJson(Map<String, dynamic> json) => UserProgress(
      id: json['id'] as String,
      userId: json['userId'] as String,
      topic: json['topic'] as String,
      completionPercentage:
          (json['completionPercentage'] as num?)?.toDouble() ?? 0.0,
      currentLevel: (json['currentLevel'] as num?)?.toInt() ?? 1,
      totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
      lastStudied: const TimestampConverter().fromJson(json['lastStudied']),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      completedSubtopics: (json['completedSubtopics'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      progressData: json['progressData'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$UserProgressToJson(UserProgress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'topic': instance.topic,
      'completionPercentage': instance.completionPercentage,
      'currentLevel': instance.currentLevel,
      'totalSessions': instance.totalSessions,
      'lastStudied': const TimestampConverter().toJson(instance.lastStudied),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'completedSubtopics': instance.completedSubtopics,
      'progressData': instance.progressData,
    };

Achievement _$AchievementFromJson(Map<String, dynamic> json) => Achievement(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      type: $enumDecode(_$AchievementTypeEnumMap, json['type']),
      pointsAwarded: (json['pointsAwarded'] as num?)?.toInt() ?? 0,
      unlockedAt: const TimestampConverter().fromJson(json['unlockedAt']),
      criteria: json['criteria'] as Map<String, dynamic>? ?? const {},
      isVisible: json['isVisible'] as bool? ?? true,
    );

Map<String, dynamic> _$AchievementToJson(Achievement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'description': instance.description,
      'icon': instance.icon,
      'type': _$AchievementTypeEnumMap[instance.type]!,
      'pointsAwarded': instance.pointsAwarded,
      'unlockedAt': const TimestampConverter().toJson(instance.unlockedAt),
      'criteria': instance.criteria,
      'isVisible': instance.isVisible,
    };

const _$AchievementTypeEnumMap = {
  AchievementType.streak: 'streak',
  AchievementType.sessions: 'sessions',
  AchievementType.topics: 'topics',
  AchievementType.time: 'time',
  AchievementType.special: 'special',
};

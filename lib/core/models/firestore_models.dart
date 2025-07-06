import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'firestore_models.g.dart';

// Firestore document converter for Timestamp
class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json is Timestamp) {
      return json.toDate();
    } else if (json is String) {
      return DateTime.parse(json);
    } else if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    }
    return DateTime.now();
  }

  @override
  dynamic toJson(DateTime object) {
    return Timestamp.fromDate(object);
  }
}

@JsonSerializable()
class FirestoreUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final bool emailVerified;
  
  @TimestampConverter()
  final DateTime createdAt;
  
  @TimestampConverter()
  final DateTime updatedAt;
  
  @TimestampConverter()
  final DateTime? lastSignInAt;
  
  final List<String> signInMethods;
  final Map<String, dynamic> preferences;
  final UserStats stats;

  const FirestoreUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.emailVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.lastSignInAt,
    this.signInMethods = const [],
    this.preferences = const {},
    this.stats = const UserStats(),
  });

  factory FirestoreUser.fromJson(Map<String, dynamic> json) => _$FirestoreUserFromJson(json);
  Map<String, dynamic> toJson() => _$FirestoreUserToJson(this);

  FirestoreUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSignInAt,
    List<String>? signInMethods,
    Map<String, dynamic>? preferences,
    UserStats? stats,
  }) {
    return FirestoreUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      signInMethods: signInMethods ?? this.signInMethods,
      preferences: preferences ?? this.preferences,
      stats: stats ?? this.stats,
    );
  }
}

@JsonSerializable()
class UserStats {
  final int totalSessions;
  final int totalMessages;
  final int totalLearningMinutes;
  final int streakDays;
  final int level;
  final int experiencePoints;
  
  @TimestampConverter()
  final DateTime? lastActiveDate;

  const UserStats({
    this.totalSessions = 0,
    this.totalMessages = 0,
    this.totalLearningMinutes = 0,
    this.streakDays = 0,
    this.level = 1,
    this.experiencePoints = 0,
    this.lastActiveDate,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) => _$UserStatsFromJson(json);
  Map<String, dynamic> toJson() => _$UserStatsToJson(this);

  UserStats copyWith({
    int? totalSessions,
    int? totalMessages,
    int? totalLearningMinutes,
    int? streakDays,
    int? level,
    int? experiencePoints,
    DateTime? lastActiveDate,
  }) {
    return UserStats(
      totalSessions: totalSessions ?? this.totalSessions,
      totalMessages: totalMessages ?? this.totalMessages,
      totalLearningMinutes: totalLearningMinutes ?? this.totalLearningMinutes,
      streakDays: streakDays ?? this.streakDays,
      level: level ?? this.level,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }
}

@JsonSerializable()
class ChatSession {
  final String id;
  final String userId;
  final String title;
  final String? topic;
  
  @TimestampConverter()
  final DateTime createdAt;
  
  @TimestampConverter()
  final DateTime updatedAt;
  
  final int messageCount;
  final bool isActive;
  final Map<String, dynamic> metadata;

  const ChatSession({
    required this.id,
    required this.userId,
    required this.title,
    this.topic,
    required this.createdAt,
    required this.updatedAt,
    this.messageCount = 0,
    this.isActive = true,
    this.metadata = const {},
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) => _$ChatSessionFromJson(json);
  Map<String, dynamic> toJson() => _$ChatSessionToJson(this);

  ChatSession copyWith({
    String? id,
    String? userId,
    String? title,
    String? topic,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? messageCount,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return ChatSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      topic: topic ?? this.topic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messageCount: messageCount ?? this.messageCount,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }
}

@JsonSerializable()
class ChatMessage {
  final String id;
  final String sessionId;
  final String userId;
  final String content;
  final String role; // 'user', 'assistant', 'system'
  
  @TimestampConverter()
  final DateTime timestamp;
  
  final String? templateId;
  final Map<String, dynamic>? templateData;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> metadata;

  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.content,
    required this.role,
    required this.timestamp,
    this.templateId,
    this.templateData,
    this.isLoading = false,
    this.error,
    this.metadata = const {},
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  ChatMessage copyWith({
    String? id,
    String? sessionId,
    String? userId,
    String? content,
    String? role,
    DateTime? timestamp,
    String? templateId,
    Map<String, dynamic>? templateData,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      templateId: templateId ?? this.templateId,
      templateData: templateData ?? this.templateData,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
  bool get isSystem => role == 'system';
  bool get hasError => error != null;
}

@JsonSerializable()
class LearningSession {
  final String id;
  final String userId;
  final String topic;
  final String? category;
  
  @TimestampConverter()
  final DateTime startTime;
  
  @TimestampConverter()
  final DateTime? endTime;
  
  final int durationMinutes;
  final int messageCount;
  final List<String> topicsDiscussed;
  final int experienceGained;
  final LearningSessionType type;
  final Map<String, dynamic> metadata;

  const LearningSession({
    required this.id,
    required this.userId,
    required this.topic,
    this.category,
    required this.startTime,
    this.endTime,
    this.durationMinutes = 0,
    this.messageCount = 0,
    this.topicsDiscussed = const [],
    this.experienceGained = 0,
    this.type = LearningSessionType.general,
    this.metadata = const {},
  });

  factory LearningSession.fromJson(Map<String, dynamic> json) => _$LearningSessionFromJson(json);
  Map<String, dynamic> toJson() => _$LearningSessionToJson(this);

  LearningSession copyWith({
    String? id,
    String? userId,
    String? topic,
    String? category,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    int? messageCount,
    List<String>? topicsDiscussed,
    int? experienceGained,
    LearningSessionType? type,
    Map<String, dynamic>? metadata,
  }) {
    return LearningSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      topic: topic ?? this.topic,
      category: category ?? this.category,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      messageCount: messageCount ?? this.messageCount,
      topicsDiscussed: topicsDiscussed ?? this.topicsDiscussed,
      experienceGained: experienceGained ?? this.experienceGained,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isActive => endTime == null;
  Duration get duration => endTime?.difference(startTime) ?? Duration.zero;
}

enum LearningSessionType {
  @JsonValue('general')
  general,
  @JsonValue('quiz')
  quiz,
  @JsonValue('explanation')
  explanation,
  @JsonValue('practice')
  practice,
  @JsonValue('summary')
  summary,
}

@JsonSerializable()
class UserProgress {
  final String id;
  final String userId;
  final String topic;
  final double completionPercentage;
  final int currentLevel;
  final int totalSessions;
  
  @TimestampConverter()
  final DateTime lastStudied;
  
  @TimestampConverter()
  final DateTime createdAt;
  
  final List<String> completedSubtopics;
  final Map<String, dynamic> progressData;

  const UserProgress({
    required this.id,
    required this.userId,
    required this.topic,
    this.completionPercentage = 0.0,
    this.currentLevel = 1,
    this.totalSessions = 0,
    required this.lastStudied,
    required this.createdAt,
    this.completedSubtopics = const [],
    this.progressData = const {},
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) => _$UserProgressFromJson(json);
  Map<String, dynamic> toJson() => _$UserProgressToJson(this);

  UserProgress copyWith({
    String? id,
    String? userId,
    String? topic,
    double? completionPercentage,
    int? currentLevel,
    int? totalSessions,
    DateTime? lastStudied,
    DateTime? createdAt,
    List<String>? completedSubtopics,
    Map<String, dynamic>? progressData,
  }) {
    return UserProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      topic: topic ?? this.topic,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      currentLevel: currentLevel ?? this.currentLevel,
      totalSessions: totalSessions ?? this.totalSessions,
      lastStudied: lastStudied ?? this.lastStudied,
      createdAt: createdAt ?? this.createdAt,
      completedSubtopics: completedSubtopics ?? this.completedSubtopics,
      progressData: progressData ?? this.progressData,
    );
  }

  bool get isCompleted => completionPercentage >= 100.0;
}

@JsonSerializable()
class Achievement {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String icon;
  final AchievementType type;
  final int pointsAwarded;
  
  @TimestampConverter()
  final DateTime unlockedAt;
  
  final Map<String, dynamic> criteria;
  final bool isVisible;

  const Achievement({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    this.pointsAwarded = 0,
    required this.unlockedAt,
    this.criteria = const {},
    this.isVisible = true,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) => _$AchievementFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementToJson(this);
}

enum AchievementType {
  @JsonValue('streak')
  streak,
  @JsonValue('sessions')
  sessions,
  @JsonValue('topics')
  topics,
  @JsonValue('time')
  time,
  @JsonValue('special')
  special,
}

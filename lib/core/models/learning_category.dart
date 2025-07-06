import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'learning_category.g.dart';

@JsonSerializable()
class LearningCategory {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final String colorCode;
  final List<String> tags;
  final int topicCount;
  final int userCount;
  final DifficultyLevel difficulty;
  final bool isPopular;
  final bool isFeatured;
  final double averageRating;
  final int estimatedHours;
  final List<String> prerequisites;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LearningCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.colorCode,
    required this.tags,
    required this.topicCount,
    required this.userCount,
    required this.difficulty,
    required this.isPopular,
    required this.isFeatured,
    required this.averageRating,
    required this.estimatedHours,
    required this.prerequisites,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LearningCategory.fromJson(Map<String, dynamic> json) => _$LearningCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$LearningCategoryToJson(this);

  factory LearningCategory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LearningCategory.fromJson({
      'id': doc.id,
      ...data,
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      'updatedAt': (data['updatedAt'] as Timestamp).toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    return {
      ...json,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    }..remove('id');
  }

  LearningCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    String? colorCode,
    List<String>? tags,
    int? topicCount,
    int? userCount,
    DifficultyLevel? difficulty,
    bool? isPopular,
    bool? isFeatured,
    double? averageRating,
    int? estimatedHours,
    List<String>? prerequisites,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LearningCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      colorCode: colorCode ?? this.colorCode,
      tags: tags ?? this.tags,
      topicCount: topicCount ?? this.topicCount,
      userCount: userCount ?? this.userCount,
      difficulty: difficulty ?? this.difficulty,
      isPopular: isPopular ?? this.isPopular,
      isFeatured: isFeatured ?? this.isFeatured,
      averageRating: averageRating ?? this.averageRating,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      prerequisites: prerequisites ?? this.prerequisites,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class LearningTopic {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final String content;
  final List<String> keywords;
  final DifficultyLevel difficulty;
  final int estimatedMinutes;
  final int orderIndex;
  final List<String> prerequisites;
  final List<String> learningObjectives;
  final List<TopicResource> resources;
  final TopicType type;
  final bool isInteractive;
  final bool hasQuiz;
  final double averageRating;
  final int completionCount;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LearningTopic({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.content,
    required this.keywords,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.orderIndex,
    required this.prerequisites,
    required this.learningObjectives,
    required this.resources,
    required this.type,
    required this.isInteractive,
    required this.hasQuiz,
    required this.averageRating,
    required this.completionCount,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LearningTopic.fromJson(Map<String, dynamic> json) => _$LearningTopicFromJson(json);
  Map<String, dynamic> toJson() => _$LearningTopicToJson(this);

  factory LearningTopic.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LearningTopic.fromJson({
      'id': doc.id,
      ...data,
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      'updatedAt': (data['updatedAt'] as Timestamp).toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    return {
      ...json,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    }..remove('id');
  }

  LearningTopic copyWith({
    String? id,
    String? categoryId,
    String? name,
    String? description,
    String? content,
    List<String>? keywords,
    DifficultyLevel? difficulty,
    int? estimatedMinutes,
    int? orderIndex,
    List<String>? prerequisites,
    List<String>? learningObjectives,
    List<TopicResource>? resources,
    TopicType? type,
    bool? isInteractive,
    bool? hasQuiz,
    double? averageRating,
    int? completionCount,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LearningTopic(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      content: content ?? this.content,
      keywords: keywords ?? this.keywords,
      difficulty: difficulty ?? this.difficulty,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      orderIndex: orderIndex ?? this.orderIndex,
      prerequisites: prerequisites ?? this.prerequisites,
      learningObjectives: learningObjectives ?? this.learningObjectives,
      resources: resources ?? this.resources,
      type: type ?? this.type,
      isInteractive: isInteractive ?? this.isInteractive,
      hasQuiz: hasQuiz ?? this.hasQuiz,
      averageRating: averageRating ?? this.averageRating,
      completionCount: completionCount ?? this.completionCount,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class TopicResource {
  final String id;
  final String title;
  final String description;
  final ResourceType type;
  final String url;
  final bool isExternal;
  final int estimatedMinutes;
  final Map<String, dynamic> metadata;

  const TopicResource({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.url,
    required this.isExternal,
    required this.estimatedMinutes,
    required this.metadata,
  });

  factory TopicResource.fromJson(Map<String, dynamic> json) => _$TopicResourceFromJson(json);
  Map<String, dynamic> toJson() => _$TopicResourceToJson(this);
}

@JsonSerializable()
class UserTopicProgress {
  final String id;
  final String userId;
  final String topicId;
  final String categoryId;
  final ProgressStatus status;
  final double completionPercentage;
  final int timeSpentMinutes;
  final int attempts;
  final double? quizScore;
  final List<String> completedObjectives;
  final List<String> bookmarkedResources;
  final Map<String, dynamic> notes;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime lastAccessedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserTopicProgress({
    required this.id,
    required this.userId,
    required this.topicId,
    required this.categoryId,
    required this.status,
    required this.completionPercentage,
    required this.timeSpentMinutes,
    required this.attempts,
    this.quizScore,
    required this.completedObjectives,
    required this.bookmarkedResources,
    required this.notes,
    this.startedAt,
    this.completedAt,
    required this.lastAccessedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserTopicProgress.fromJson(Map<String, dynamic> json) => _$UserTopicProgressFromJson(json);
  Map<String, dynamic> toJson() => _$UserTopicProgressToJson(this);

  factory UserTopicProgress.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserTopicProgress.fromJson({
      'id': doc.id,
      ...data,
      'startedAt': data['startedAt'] != null 
          ? (data['startedAt'] as Timestamp).toDate().toIso8601String()
          : null,
      'completedAt': data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate().toIso8601String()
          : null,
      'lastAccessedAt': (data['lastAccessedAt'] as Timestamp).toDate().toIso8601String(),
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      'updatedAt': (data['updatedAt'] as Timestamp).toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    return {
      ...json,
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'lastAccessedAt': Timestamp.fromDate(lastAccessedAt),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    }..remove('id');
  }

  UserTopicProgress copyWith({
    String? id,
    String? userId,
    String? topicId,
    String? categoryId,
    ProgressStatus? status,
    double? completionPercentage,
    int? timeSpentMinutes,
    int? attempts,
    double? quizScore,
    List<String>? completedObjectives,
    List<String>? bookmarkedResources,
    Map<String, dynamic>? notes,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? lastAccessedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserTopicProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      topicId: topicId ?? this.topicId,
      categoryId: categoryId ?? this.categoryId,
      status: status ?? this.status,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      timeSpentMinutes: timeSpentMinutes ?? this.timeSpentMinutes,
      attempts: attempts ?? this.attempts,
      quizScore: quizScore ?? this.quizScore,
      completedObjectives: completedObjectives ?? this.completedObjectives,
      bookmarkedResources: bookmarkedResources ?? this.bookmarkedResources,
      notes: notes ?? this.notes,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isCompleted => status == ProgressStatus.completed;
  bool get isInProgress => status == ProgressStatus.inProgress;
  bool get isNotStarted => status == ProgressStatus.notStarted;
}

// Enums
enum DifficultyLevel {
  @JsonValue('beginner')
  beginner,
  @JsonValue('intermediate')
  intermediate,
  @JsonValue('advanced')
  advanced,
  @JsonValue('expert')
  expert,
}

enum TopicType {
  @JsonValue('lesson')
  lesson,
  @JsonValue('tutorial')
  tutorial,
  @JsonValue('exercise')
  exercise,
  @JsonValue('project')
  project,
  @JsonValue('assessment')
  assessment,
}

enum ResourceType {
  @JsonValue('article')
  article,
  @JsonValue('video')
  video,
  @JsonValue('interactive')
  interactive,
  @JsonValue('document')
  document,
  @JsonValue('link')
  link,
  @JsonValue('code')
  code,
}

enum ProgressStatus {
  @JsonValue('not_started')
  notStarted,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('bookmarked')
  bookmarked,
}

// Extension methods
extension DifficultyLevelExtension on DifficultyLevel {
  String get displayName {
    switch (this) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.intermediate:
        return 'Intermediate';
      case DifficultyLevel.advanced:
        return 'Advanced';
      case DifficultyLevel.expert:
        return 'Expert';
    }
  }

  String get description {
    switch (this) {
      case DifficultyLevel.beginner:
        return 'Perfect for newcomers';
      case DifficultyLevel.intermediate:
        return 'Some experience required';
      case DifficultyLevel.advanced:
        return 'For experienced learners';
      case DifficultyLevel.expert:
        return 'Highly specialized content';
    }
  }
}

extension TopicTypeExtension on TopicType {
  String get displayName {
    switch (this) {
      case TopicType.lesson:
        return 'Lesson';
      case TopicType.tutorial:
        return 'Tutorial';
      case TopicType.exercise:
        return 'Exercise';
      case TopicType.project:
        return 'Project';
      case TopicType.assessment:
        return 'Assessment';
    }
  }
}

extension ResourceTypeExtension on ResourceType {
  String get displayName {
    switch (this) {
      case ResourceType.article:
        return 'Article';
      case ResourceType.video:
        return 'Video';
      case ResourceType.interactive:
        return 'Interactive';
      case ResourceType.document:
        return 'Document';
      case ResourceType.link:
        return 'Link';
      case ResourceType.code:
        return 'Code';
    }
  }
}

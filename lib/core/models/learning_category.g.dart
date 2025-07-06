// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LearningCategory _$LearningCategoryFromJson(Map<String, dynamic> json) =>
    LearningCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconName: json['iconName'] as String,
      colorCode: json['colorCode'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      topicCount: (json['topicCount'] as num).toInt(),
      userCount: (json['userCount'] as num).toInt(),
      difficulty: $enumDecode(_$DifficultyLevelEnumMap, json['difficulty']),
      isPopular: json['isPopular'] as bool,
      isFeatured: json['isFeatured'] as bool,
      averageRating: (json['averageRating'] as num).toDouble(),
      estimatedHours: (json['estimatedHours'] as num).toInt(),
      prerequisites: (json['prerequisites'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LearningCategoryToJson(LearningCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'iconName': instance.iconName,
      'colorCode': instance.colorCode,
      'tags': instance.tags,
      'topicCount': instance.topicCount,
      'userCount': instance.userCount,
      'difficulty': _$DifficultyLevelEnumMap[instance.difficulty]!,
      'isPopular': instance.isPopular,
      'isFeatured': instance.isFeatured,
      'averageRating': instance.averageRating,
      'estimatedHours': instance.estimatedHours,
      'prerequisites': instance.prerequisites,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$DifficultyLevelEnumMap = {
  DifficultyLevel.beginner: 'beginner',
  DifficultyLevel.intermediate: 'intermediate',
  DifficultyLevel.advanced: 'advanced',
  DifficultyLevel.expert: 'expert',
};

LearningTopic _$LearningTopicFromJson(Map<String, dynamic> json) =>
    LearningTopic(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      content: json['content'] as String,
      keywords:
          (json['keywords'] as List<dynamic>).map((e) => e as String).toList(),
      difficulty: $enumDecode(_$DifficultyLevelEnumMap, json['difficulty']),
      estimatedMinutes: (json['estimatedMinutes'] as num).toInt(),
      orderIndex: (json['orderIndex'] as num).toInt(),
      prerequisites: (json['prerequisites'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      learningObjectives: (json['learningObjectives'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      resources: (json['resources'] as List<dynamic>)
          .map((e) => TopicResource.fromJson(e as Map<String, dynamic>))
          .toList(),
      type: $enumDecode(_$TopicTypeEnumMap, json['type']),
      isInteractive: json['isInteractive'] as bool,
      hasQuiz: json['hasQuiz'] as bool,
      averageRating: (json['averageRating'] as num).toDouble(),
      completionCount: (json['completionCount'] as num).toInt(),
      metadata: json['metadata'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LearningTopicToJson(LearningTopic instance) =>
    <String, dynamic>{
      'id': instance.id,
      'categoryId': instance.categoryId,
      'name': instance.name,
      'description': instance.description,
      'content': instance.content,
      'keywords': instance.keywords,
      'difficulty': _$DifficultyLevelEnumMap[instance.difficulty]!,
      'estimatedMinutes': instance.estimatedMinutes,
      'orderIndex': instance.orderIndex,
      'prerequisites': instance.prerequisites,
      'learningObjectives': instance.learningObjectives,
      'resources': instance.resources,
      'type': _$TopicTypeEnumMap[instance.type]!,
      'isInteractive': instance.isInteractive,
      'hasQuiz': instance.hasQuiz,
      'averageRating': instance.averageRating,
      'completionCount': instance.completionCount,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$TopicTypeEnumMap = {
  TopicType.lesson: 'lesson',
  TopicType.tutorial: 'tutorial',
  TopicType.exercise: 'exercise',
  TopicType.project: 'project',
  TopicType.assessment: 'assessment',
};

TopicResource _$TopicResourceFromJson(Map<String, dynamic> json) =>
    TopicResource(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$ResourceTypeEnumMap, json['type']),
      url: json['url'] as String,
      isExternal: json['isExternal'] as bool,
      estimatedMinutes: (json['estimatedMinutes'] as num).toInt(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$TopicResourceToJson(TopicResource instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$ResourceTypeEnumMap[instance.type]!,
      'url': instance.url,
      'isExternal': instance.isExternal,
      'estimatedMinutes': instance.estimatedMinutes,
      'metadata': instance.metadata,
    };

const _$ResourceTypeEnumMap = {
  ResourceType.article: 'article',
  ResourceType.video: 'video',
  ResourceType.interactive: 'interactive',
  ResourceType.document: 'document',
  ResourceType.link: 'link',
  ResourceType.code: 'code',
};

UserTopicProgress _$UserTopicProgressFromJson(Map<String, dynamic> json) =>
    UserTopicProgress(
      id: json['id'] as String,
      userId: json['userId'] as String,
      topicId: json['topicId'] as String,
      categoryId: json['categoryId'] as String,
      status: $enumDecode(_$ProgressStatusEnumMap, json['status']),
      completionPercentage: (json['completionPercentage'] as num).toDouble(),
      timeSpentMinutes: (json['timeSpentMinutes'] as num).toInt(),
      attempts: (json['attempts'] as num).toInt(),
      quizScore: (json['quizScore'] as num?)?.toDouble(),
      completedObjectives: (json['completedObjectives'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      bookmarkedResources: (json['bookmarkedResources'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      notes: json['notes'] as Map<String, dynamic>,
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      lastAccessedAt: DateTime.parse(json['lastAccessedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserTopicProgressToJson(UserTopicProgress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'topicId': instance.topicId,
      'categoryId': instance.categoryId,
      'status': _$ProgressStatusEnumMap[instance.status]!,
      'completionPercentage': instance.completionPercentage,
      'timeSpentMinutes': instance.timeSpentMinutes,
      'attempts': instance.attempts,
      'quizScore': instance.quizScore,
      'completedObjectives': instance.completedObjectives,
      'bookmarkedResources': instance.bookmarkedResources,
      'notes': instance.notes,
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'lastAccessedAt': instance.lastAccessedAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ProgressStatusEnumMap = {
  ProgressStatus.notStarted: 'not_started',
  ProgressStatus.inProgress: 'in_progress',
  ProgressStatus.completed: 'completed',
  ProgressStatus.bookmarked: 'bookmarked',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_content_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LearningContentCategory _$LearningContentCategoryFromJson(
        Map<String, dynamic> json) =>
    LearningContentCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconName: json['iconName'] as String? ?? 'school',
      colorCode: json['colorCode'] as String? ?? '#2196F3',
      questionCount: (json['questionCount'] as num?)?.toInt() ?? 0,
      difficulty:
          $enumDecodeNullable(_$DifficultyLevelEnumMap, json['difficulty']) ??
              DifficultyLevel.beginner,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LearningContentCategoryToJson(
        LearningContentCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'iconName': instance.iconName,
      'colorCode': instance.colorCode,
      'questionCount': instance.questionCount,
      'difficulty': _$DifficultyLevelEnumMap[instance.difficulty]!,
      'tags': instance.tags,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$DifficultyLevelEnumMap = {
  DifficultyLevel.beginner: 'beginner',
  DifficultyLevel.intermediate: 'intermediate',
  DifficultyLevel.advanced: 'advanced',
  DifficultyLevel.expert: 'expert',
};

LearningQuestion _$LearningQuestionFromJson(Map<String, dynamic> json) =>
    LearningQuestion(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      difficulty:
          $enumDecodeNullable(_$DifficultyLevelEnumMap, json['difficulty']) ??
              DifficultyLevel.beginner,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      relatedTopics: (json['relatedTopics'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      multipleChoiceOptions: (json['multipleChoiceOptions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      correctAnswerIndex: (json['correctAnswerIndex'] as num?)?.toInt(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$LearningQuestionToJson(LearningQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'categoryId': instance.categoryId,
      'question': instance.question,
      'answer': instance.answer,
      'difficulty': _$DifficultyLevelEnumMap[instance.difficulty]!,
      'tags': instance.tags,
      'relatedTopics': instance.relatedTopics,
      'orderIndex': instance.orderIndex,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'multipleChoiceOptions': instance.multipleChoiceOptions,
      'correctAnswerIndex': instance.correctAnswerIndex,
      'metadata': instance.metadata,
    };

QuestionProgress _$QuestionProgressFromJson(Map<String, dynamic> json) =>
    QuestionProgress(
      id: json['id'] as String,
      userId: json['userId'] as String,
      questionId: json['questionId'] as String,
      categoryId: json['categoryId'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isCorrect: json['isCorrect'] as bool? ?? false,
      attemptCount: (json['attemptCount'] as num?)?.toInt() ?? 0,
      lastAttemptDate: json['lastAttemptDate'] == null
          ? null
          : DateTime.parse(json['lastAttemptDate'] as String),
      completedDate: json['completedDate'] == null
          ? null
          : DateTime.parse(json['completedDate'] as String),
      userAnswer: json['userAnswer'] as String?,
      timeSpentSeconds: (json['timeSpentSeconds'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$QuestionProgressToJson(QuestionProgress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'questionId': instance.questionId,
      'categoryId': instance.categoryId,
      'isCompleted': instance.isCompleted,
      'isCorrect': instance.isCorrect,
      'attemptCount': instance.attemptCount,
      'lastAttemptDate': instance.lastAttemptDate?.toIso8601String(),
      'completedDate': instance.completedDate?.toIso8601String(),
      'userAnswer': instance.userAnswer,
      'timeSpentSeconds': instance.timeSpentSeconds,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

QuizSession _$QuizSessionFromJson(Map<String, dynamic> json) => QuizSession(
      id: json['id'] as String,
      userId: json['userId'] as String,
      categoryId: json['categoryId'] as String,
      questionIds: (json['questionIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      totalQuestions: (json['totalQuestions'] as num).toInt(),
      correctAnswers: (json['correctAnswers'] as num?)?.toInt() ?? 0,
      timeSpentSeconds: (json['timeSpentSeconds'] as num?)?.toInt() ?? 0,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      scorePercentage: (json['scorePercentage'] as num?)?.toDouble() ?? 0.0,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$QuizSessionToJson(QuizSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'categoryId': instance.categoryId,
      'questionIds': instance.questionIds,
      'totalQuestions': instance.totalQuestions,
      'correctAnswers': instance.correctAnswers,
      'timeSpentSeconds': instance.timeSpentSeconds,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'isCompleted': instance.isCompleted,
      'scorePercentage': instance.scorePercentage,
      'metadata': instance.metadata,
    };

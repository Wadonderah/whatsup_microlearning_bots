import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'learning_content_models.g.dart';

/// Learning content category (AWS Cloud Engineer, Flutter Developer, etc.)
@JsonSerializable()
class LearningContentCategory {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final String colorCode;
  final int questionCount;
  final DifficultyLevel difficulty;
  final List<String> tags;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LearningContentCategory({
    required this.id,
    required this.name,
    required this.description,
    this.iconName = 'school',
    this.colorCode = '#2196F3',
    this.questionCount = 0,
    this.difficulty = DifficultyLevel.beginner,
    this.tags = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LearningContentCategory.fromJson(Map<String, dynamic> json) =>
      _$LearningContentCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$LearningContentCategoryToJson(this);

  LearningContentCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    String? colorCode,
    int? questionCount,
    DifficultyLevel? difficulty,
    List<String>? tags,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LearningContentCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      colorCode: colorCode ?? this.colorCode,
      questionCount: questionCount ?? this.questionCount,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Individual learning question/answer pair
@JsonSerializable()
class LearningQuestion {
  final String id;
  final String categoryId;
  final String question;
  final String answer;
  final DifficultyLevel difficulty;
  final List<String> tags;
  final List<String> relatedTopics;
  final int orderIndex;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Optional multiple choice options
  final List<String>? multipleChoiceOptions;
  final int? correctAnswerIndex;
  
  // Metadata
  final Map<String, dynamic> metadata;

  const LearningQuestion({
    required this.id,
    required this.categoryId,
    required this.question,
    required this.answer,
    this.difficulty = DifficultyLevel.beginner,
    this.tags = const [],
    this.relatedTopics = const [],
    this.orderIndex = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.multipleChoiceOptions,
    this.correctAnswerIndex,
    this.metadata = const {},
  });

  factory LearningQuestion.fromJson(Map<String, dynamic> json) =>
      _$LearningQuestionFromJson(json);
  Map<String, dynamic> toJson() => _$LearningQuestionToJson(this);

  /// Check if this is a multiple choice question
  bool get isMultipleChoice => multipleChoiceOptions != null && multipleChoiceOptions!.isNotEmpty;

  LearningQuestion copyWith({
    String? id,
    String? categoryId,
    String? question,
    String? answer,
    DifficultyLevel? difficulty,
    List<String>? tags,
    List<String>? relatedTopics,
    int? orderIndex,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? multipleChoiceOptions,
    int? correctAnswerIndex,
    Map<String, dynamic>? metadata,
  }) {
    return LearningQuestion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      relatedTopics: relatedTopics ?? this.relatedTopics,
      orderIndex: orderIndex ?? this.orderIndex,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      multipleChoiceOptions: multipleChoiceOptions ?? this.multipleChoiceOptions,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// User's progress on a specific question
@JsonSerializable()
class QuestionProgress {
  final String id;
  final String userId;
  final String questionId;
  final String categoryId;
  final bool isCompleted;
  final bool isCorrect;
  final int attemptCount;
  final DateTime? lastAttemptDate;
  final DateTime? completedDate;
  final String? userAnswer;
  final int timeSpentSeconds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const QuestionProgress({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.categoryId,
    this.isCompleted = false,
    this.isCorrect = false,
    this.attemptCount = 0,
    this.lastAttemptDate,
    this.completedDate,
    this.userAnswer,
    this.timeSpentSeconds = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuestionProgress.fromJson(Map<String, dynamic> json) =>
      _$QuestionProgressFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionProgressToJson(this);

  QuestionProgress copyWith({
    String? id,
    String? userId,
    String? questionId,
    String? categoryId,
    bool? isCompleted,
    bool? isCorrect,
    int? attemptCount,
    DateTime? lastAttemptDate,
    DateTime? completedDate,
    String? userAnswer,
    int? timeSpentSeconds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuestionProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      questionId: questionId ?? this.questionId,
      categoryId: categoryId ?? this.categoryId,
      isCompleted: isCompleted ?? this.isCompleted,
      isCorrect: isCorrect ?? this.isCorrect,
      attemptCount: attemptCount ?? this.attemptCount,
      lastAttemptDate: lastAttemptDate ?? this.lastAttemptDate,
      completedDate: completedDate ?? this.completedDate,
      userAnswer: userAnswer ?? this.userAnswer,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Difficulty levels for content
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

/// Quiz session for tracking user quiz attempts
@JsonSerializable()
class QuizSession {
  final String id;
  final String userId;
  final String categoryId;
  final List<String> questionIds;
  final int totalQuestions;
  final int correctAnswers;
  final int timeSpentSeconds;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isCompleted;
  final double scorePercentage;
  final Map<String, dynamic> metadata;

  const QuizSession({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.questionIds,
    required this.totalQuestions,
    this.correctAnswers = 0,
    this.timeSpentSeconds = 0,
    required this.startTime,
    this.endTime,
    this.isCompleted = false,
    this.scorePercentage = 0.0,
    this.metadata = const {},
  });

  factory QuizSession.fromJson(Map<String, dynamic> json) =>
      _$QuizSessionFromJson(json);
  Map<String, dynamic> toJson() => _$QuizSessionToJson(this);

  /// Calculate score percentage
  double get calculatedScore => totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0.0;

  /// Check if quiz is in progress
  bool get isInProgress => !isCompleted && endTime == null;

  QuizSession copyWith({
    String? id,
    String? userId,
    String? categoryId,
    List<String>? questionIds,
    int? totalQuestions,
    int? correctAnswers,
    int? timeSpentSeconds,
    DateTime? startTime,
    DateTime? endTime,
    bool? isCompleted,
    double? scorePercentage,
    Map<String, dynamic>? metadata,
  }) {
    return QuizSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      questionIds: questionIds ?? this.questionIds,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      scorePercentage: scorePercentage ?? this.scorePercentage,
      metadata: metadata ?? this.metadata,
    );
  }
}

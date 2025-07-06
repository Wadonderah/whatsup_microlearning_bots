import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'study_plan.g.dart';

@JsonSerializable(explicitToJson: true)
class StudyPlan {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final StudyPlanType type;
  final DifficultyLevel difficulty;
  final int estimatedDurationDays;
  final int dailyTimeMinutes;
  final List<String> topics;
  final List<StudyPlanMilestone> milestones;
  final StudyPlanStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? completedAt;
  final double progressPercentage;
  final int completedSessions;
  final int totalSessions;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StudyPlan({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.difficulty,
    required this.estimatedDurationDays,
    required this.dailyTimeMinutes,
    required this.topics,
    required this.milestones,
    required this.status,
    required this.startDate,
    this.endDate,
    this.completedAt,
    required this.progressPercentage,
    required this.completedSessions,
    required this.totalSessions,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudyPlan.fromJson(Map<String, dynamic> json) =>
      _$StudyPlanFromJson(json);
  Map<String, dynamic> toJson() => _$StudyPlanToJson(this);

  factory StudyPlan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudyPlan.fromJson({
      'id': doc.id,
      ...data,
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      'updatedAt': (data['updatedAt'] as Timestamp).toDate().toIso8601String(),
      'startDate': (data['startDate'] as Timestamp).toDate().toIso8601String(),
      'endDate': data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate().toIso8601String()
          : null,
      'completedAt': data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate().toIso8601String()
          : null,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    return {
      ...json,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    }..remove('id');
  }

  StudyPlan copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    StudyPlanType? type,
    DifficultyLevel? difficulty,
    int? estimatedDurationDays,
    int? dailyTimeMinutes,
    List<String>? topics,
    List<StudyPlanMilestone>? milestones,
    StudyPlanStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? completedAt,
    double? progressPercentage,
    int? completedSessions,
    int? totalSessions,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudyPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      estimatedDurationDays:
          estimatedDurationDays ?? this.estimatedDurationDays,
      dailyTimeMinutes: dailyTimeMinutes ?? this.dailyTimeMinutes,
      topics: topics ?? this.topics,
      milestones: milestones ?? this.milestones,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      completedAt: completedAt ?? this.completedAt,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      completedSessions: completedSessions ?? this.completedSessions,
      totalSessions: totalSessions ?? this.totalSessions,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isActive => status == StudyPlanStatus.active;
  bool get isCompleted => status == StudyPlanStatus.completed;
  bool get isPaused => status == StudyPlanStatus.paused;
  bool get isDraft => status == StudyPlanStatus.draft;
  bool get isOverdue =>
      endDate != null && DateTime.now().isAfter(endDate!) && !isCompleted;

  int get remainingDays {
    if (endDate == null) return estimatedDurationDays;
    final remaining = endDate!.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  double get dailyProgressTarget => 100.0 / estimatedDurationDays;

  StudyPlanMilestone? get nextMilestone {
    return milestones.where((m) => !m.isCompleted).isNotEmpty
        ? milestones.where((m) => !m.isCompleted).first
        : null;
  }

  int get completedMilestones => milestones.where((m) => m.isCompleted).length;
}

@JsonSerializable()
class StudyPlanMilestone {
  final String id;
  final String title;
  final String description;
  final int orderIndex;
  final List<String> requiredTopics;
  final int estimatedDurationDays;
  final bool isCompleted;
  final DateTime? completedAt;
  final double progressPercentage;
  final Map<String, dynamic> metadata;

  const StudyPlanMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.orderIndex,
    required this.requiredTopics,
    required this.estimatedDurationDays,
    required this.isCompleted,
    this.completedAt,
    required this.progressPercentage,
    required this.metadata,
  });

  factory StudyPlanMilestone.fromJson(Map<String, dynamic> json) =>
      _$StudyPlanMilestoneFromJson(json);
  Map<String, dynamic> toJson() => _$StudyPlanMilestoneToJson(this);

  StudyPlanMilestone copyWith({
    String? id,
    String? title,
    String? description,
    int? orderIndex,
    List<String>? requiredTopics,
    int? estimatedDurationDays,
    bool? isCompleted,
    DateTime? completedAt,
    double? progressPercentage,
    Map<String, dynamic>? metadata,
  }) {
    return StudyPlanMilestone(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      orderIndex: orderIndex ?? this.orderIndex,
      requiredTopics: requiredTopics ?? this.requiredTopics,
      estimatedDurationDays:
          estimatedDurationDays ?? this.estimatedDurationDays,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      metadata: metadata ?? this.metadata,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class StudySchedule {
  final String id;
  final String userId;
  final String studyPlanId;
  final String title;
  final DateTime scheduledDate;
  final TimeOfDay scheduledTime;
  final int durationMinutes;
  final List<String> topics;
  final StudySessionType sessionType;
  final ScheduleStatus status;
  final bool isRecurring;
  final RecurrencePattern? recurrencePattern;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StudySchedule({
    required this.id,
    required this.userId,
    required this.studyPlanId,
    required this.title,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.durationMinutes,
    required this.topics,
    required this.sessionType,
    required this.status,
    required this.isRecurring,
    this.recurrencePattern,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudySchedule.fromJson(Map<String, dynamic> json) =>
      _$StudyScheduleFromJson(json);
  Map<String, dynamic> toJson() => _$StudyScheduleToJson(this);

  factory StudySchedule.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudySchedule.fromJson({
      'id': doc.id,
      ...data,
      'scheduledDate':
          (data['scheduledDate'] as Timestamp).toDate().toIso8601String(),
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      'updatedAt': (data['updatedAt'] as Timestamp).toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    return {
      ...json,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    }..remove('id');
  }

  StudySchedule copyWith({
    String? id,
    String? userId,
    String? studyPlanId,
    String? title,
    DateTime? scheduledDate,
    TimeOfDay? scheduledTime,
    int? durationMinutes,
    List<String>? topics,
    StudySessionType? sessionType,
    ScheduleStatus? status,
    bool? isRecurring,
    RecurrencePattern? recurrencePattern,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudySchedule(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      studyPlanId: studyPlanId ?? this.studyPlanId,
      title: title ?? this.title,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      topics: topics ?? this.topics,
      sessionType: sessionType ?? this.sessionType,
      status: status ?? this.status,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  DateTime get scheduledDateTime {
    return DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );
  }

  bool get isToday {
    final now = DateTime.now();
    return scheduledDate.year == now.year &&
        scheduledDate.month == now.month &&
        scheduledDate.day == now.day;
  }

  bool get isPast => scheduledDateTime.isBefore(DateTime.now());
  bool get isUpcoming => scheduledDateTime.isAfter(DateTime.now());
}

// Enums
enum StudyPlanType {
  @JsonValue('structured')
  structured,
  @JsonValue('flexible')
  flexible,
  @JsonValue('intensive')
  intensive,
  @JsonValue('casual')
  casual,
}

enum StudyPlanStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('active')
  active,
  @JsonValue('paused')
  paused,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

enum StudySessionType {
  @JsonValue('learning')
  learning,
  @JsonValue('review')
  review,
  @JsonValue('practice')
  practice,
  @JsonValue('assessment')
  assessment,
}

enum ScheduleStatus {
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('completed')
  completed,
  @JsonValue('missed')
  missed,
  @JsonValue('cancelled')
  cancelled,
}

enum RecurrenceType {
  @JsonValue('daily')
  daily,
  @JsonValue('weekly')
  weekly,
  @JsonValue('monthly')
  monthly,
}

@JsonSerializable()
class RecurrencePattern {
  final RecurrenceType type;
  final int interval;
  final List<int>? daysOfWeek; // 1-7 for Monday-Sunday
  final int? dayOfMonth;
  final DateTime? endDate;
  final int? maxOccurrences;

  const RecurrencePattern({
    required this.type,
    required this.interval,
    this.daysOfWeek,
    this.dayOfMonth,
    this.endDate,
    this.maxOccurrences,
  });

  factory RecurrencePattern.fromJson(Map<String, dynamic> json) =>
      _$RecurrencePatternFromJson(json);
  Map<String, dynamic> toJson() => _$RecurrencePatternToJson(this);
}

@JsonSerializable()
class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  factory TimeOfDay.fromJson(Map<String, dynamic> json) =>
      _$TimeOfDayFromJson(json);
  Map<String, dynamic> toJson() => _$TimeOfDayToJson(this);

  @override
  String toString() {
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }

  String toDisplayString() {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$displayHour:$minuteStr $period';
  }
}

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

// Extension methods
extension StudyPlanTypeExtension on StudyPlanType {
  String get displayName {
    switch (this) {
      case StudyPlanType.structured:
        return 'Structured';
      case StudyPlanType.flexible:
        return 'Flexible';
      case StudyPlanType.intensive:
        return 'Intensive';
      case StudyPlanType.casual:
        return 'Casual';
    }
  }

  String get description {
    switch (this) {
      case StudyPlanType.structured:
        return 'Fixed schedule with specific milestones';
      case StudyPlanType.flexible:
        return 'Adaptable schedule based on your pace';
      case StudyPlanType.intensive:
        return 'Fast-paced learning with daily sessions';
      case StudyPlanType.casual:
        return 'Relaxed learning at your own pace';
    }
  }
}

extension StudySessionTypeExtension on StudySessionType {
  String get displayName {
    switch (this) {
      case StudySessionType.learning:
        return 'Learning';
      case StudySessionType.review:
        return 'Review';
      case StudySessionType.practice:
        return 'Practice';
      case StudySessionType.assessment:
        return 'Assessment';
    }
  }
}

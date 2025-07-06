// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudyPlan _$StudyPlanFromJson(Map<String, dynamic> json) => StudyPlan(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      type: $enumDecode(_$StudyPlanTypeEnumMap, json['type']),
      difficulty: $enumDecode(_$DifficultyLevelEnumMap, json['difficulty']),
      estimatedDurationDays: (json['estimatedDurationDays'] as num).toInt(),
      dailyTimeMinutes: (json['dailyTimeMinutes'] as num).toInt(),
      topics:
          (json['topics'] as List<dynamic>).map((e) => e as String).toList(),
      milestones: (json['milestones'] as List<dynamic>)
          .map((e) => StudyPlanMilestone.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: $enumDecode(_$StudyPlanStatusEnumMap, json['status']),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
      completedSessions: (json['completedSessions'] as num).toInt(),
      totalSessions: (json['totalSessions'] as num).toInt(),
      metadata: json['metadata'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$StudyPlanToJson(StudyPlan instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'type': _$StudyPlanTypeEnumMap[instance.type]!,
      'difficulty': _$DifficultyLevelEnumMap[instance.difficulty]!,
      'estimatedDurationDays': instance.estimatedDurationDays,
      'dailyTimeMinutes': instance.dailyTimeMinutes,
      'topics': instance.topics,
      'milestones': instance.milestones.map((e) => e.toJson()).toList(),
      'status': _$StudyPlanStatusEnumMap[instance.status]!,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'progressPercentage': instance.progressPercentage,
      'completedSessions': instance.completedSessions,
      'totalSessions': instance.totalSessions,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$StudyPlanTypeEnumMap = {
  StudyPlanType.structured: 'structured',
  StudyPlanType.flexible: 'flexible',
  StudyPlanType.intensive: 'intensive',
  StudyPlanType.casual: 'casual',
};

const _$DifficultyLevelEnumMap = {
  DifficultyLevel.beginner: 'beginner',
  DifficultyLevel.intermediate: 'intermediate',
  DifficultyLevel.advanced: 'advanced',
  DifficultyLevel.expert: 'expert',
};

const _$StudyPlanStatusEnumMap = {
  StudyPlanStatus.draft: 'draft',
  StudyPlanStatus.active: 'active',
  StudyPlanStatus.paused: 'paused',
  StudyPlanStatus.completed: 'completed',
  StudyPlanStatus.cancelled: 'cancelled',
};

StudyPlanMilestone _$StudyPlanMilestoneFromJson(Map<String, dynamic> json) =>
    StudyPlanMilestone(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      orderIndex: (json['orderIndex'] as num).toInt(),
      requiredTopics: (json['requiredTopics'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      estimatedDurationDays: (json['estimatedDurationDays'] as num).toInt(),
      isCompleted: json['isCompleted'] as bool,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$StudyPlanMilestoneToJson(StudyPlanMilestone instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'orderIndex': instance.orderIndex,
      'requiredTopics': instance.requiredTopics,
      'estimatedDurationDays': instance.estimatedDurationDays,
      'isCompleted': instance.isCompleted,
      'completedAt': instance.completedAt?.toIso8601String(),
      'progressPercentage': instance.progressPercentage,
      'metadata': instance.metadata,
    };

StudySchedule _$StudyScheduleFromJson(Map<String, dynamic> json) =>
    StudySchedule(
      id: json['id'] as String,
      userId: json['userId'] as String,
      studyPlanId: json['studyPlanId'] as String,
      title: json['title'] as String,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      scheduledTime:
          TimeOfDay.fromJson(json['scheduledTime'] as Map<String, dynamic>),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      topics:
          (json['topics'] as List<dynamic>).map((e) => e as String).toList(),
      sessionType: $enumDecode(_$StudySessionTypeEnumMap, json['sessionType']),
      status: $enumDecode(_$ScheduleStatusEnumMap, json['status']),
      isRecurring: json['isRecurring'] as bool,
      recurrencePattern: json['recurrencePattern'] == null
          ? null
          : RecurrencePattern.fromJson(
              json['recurrencePattern'] as Map<String, dynamic>),
      metadata: json['metadata'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$StudyScheduleToJson(StudySchedule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'studyPlanId': instance.studyPlanId,
      'title': instance.title,
      'scheduledDate': instance.scheduledDate.toIso8601String(),
      'scheduledTime': instance.scheduledTime.toJson(),
      'durationMinutes': instance.durationMinutes,
      'topics': instance.topics,
      'sessionType': _$StudySessionTypeEnumMap[instance.sessionType]!,
      'status': _$ScheduleStatusEnumMap[instance.status]!,
      'isRecurring': instance.isRecurring,
      'recurrencePattern': instance.recurrencePattern?.toJson(),
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$StudySessionTypeEnumMap = {
  StudySessionType.learning: 'learning',
  StudySessionType.review: 'review',
  StudySessionType.practice: 'practice',
  StudySessionType.assessment: 'assessment',
};

const _$ScheduleStatusEnumMap = {
  ScheduleStatus.scheduled: 'scheduled',
  ScheduleStatus.completed: 'completed',
  ScheduleStatus.missed: 'missed',
  ScheduleStatus.cancelled: 'cancelled',
};

RecurrencePattern _$RecurrencePatternFromJson(Map<String, dynamic> json) =>
    RecurrencePattern(
      type: $enumDecode(_$RecurrenceTypeEnumMap, json['type']),
      interval: (json['interval'] as num).toInt(),
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      dayOfMonth: (json['dayOfMonth'] as num?)?.toInt(),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      maxOccurrences: (json['maxOccurrences'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RecurrencePatternToJson(RecurrencePattern instance) =>
    <String, dynamic>{
      'type': _$RecurrenceTypeEnumMap[instance.type]!,
      'interval': instance.interval,
      'daysOfWeek': instance.daysOfWeek,
      'dayOfMonth': instance.dayOfMonth,
      'endDate': instance.endDate?.toIso8601String(),
      'maxOccurrences': instance.maxOccurrences,
    };

const _$RecurrenceTypeEnumMap = {
  RecurrenceType.daily: 'daily',
  RecurrenceType.weekly: 'weekly',
  RecurrenceType.monthly: 'monthly',
};

TimeOfDay _$TimeOfDayFromJson(Map<String, dynamic> json) => TimeOfDay(
      hour: (json['hour'] as num).toInt(),
      minute: (json['minute'] as num).toInt(),
    );

Map<String, dynamic> _$TimeOfDayToJson(TimeOfDay instance) => <String, dynamic>{
      'hour': instance.hour,
      'minute': instance.minute,
    };

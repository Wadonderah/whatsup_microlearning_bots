import 'package:flutter_test/flutter_test.dart';
import 'package:whatsup_microlearning_bots/core/models/study_plan.dart';

void main() {
  group('StudyPlan Model Tests', () {
    test('should create a StudyPlan with all required fields', () {
      // Arrange
      final now = DateTime.now();
      final studyPlan = StudyPlan(
        id: 'test-id',
        userId: 'user-123',
        title: 'Flutter Development',
        description: 'Learn Flutter from basics to advanced',
        category: 'Programming',
        type: StudyPlanType.structured,
        difficulty: DifficultyLevel.intermediate,
        estimatedDurationDays: 30,
        dailyTimeMinutes: 60,
        topics: ['Dart', 'Widgets', 'State Management'],
        milestones: [],
        status: StudyPlanStatus.draft,
        progressPercentage: 0.0,
        startDate: now,
        completedAt: null,
        completedSessions: 0,
        totalSessions: 10,
        metadata: {},
        createdAt: now,
        updatedAt: now,
      );

      // Assert
      expect(studyPlan.id, equals('test-id'));
      expect(studyPlan.userId, equals('user-123'));
      expect(studyPlan.title, equals('Flutter Development'));
      expect(studyPlan.type, equals(StudyPlanType.structured));
      expect(studyPlan.difficulty, equals(DifficultyLevel.intermediate));
      expect(studyPlan.status, equals(StudyPlanStatus.draft));
      expect(studyPlan.progressPercentage, equals(0.0));
      expect(studyPlan.topics, hasLength(3));
      expect(studyPlan.topics, contains('Dart'));
    });

    test('should create StudyPlan with milestones', () {
      // Arrange
      final milestone = StudyPlanMilestone(
        id: 'milestone-1',
        title: 'Complete Dart Basics',
        description: 'Learn Dart fundamentals',
        orderIndex: 0,
        requiredTopics: ['Dart Syntax', 'Variables'],
        isCompleted: false,
        completedAt: null,
        estimatedDurationDays: 10,
        progressPercentage: 0.0,
        metadata: {},
      );

      final studyPlan = StudyPlan(
        id: 'test-id',
        userId: 'user-123',
        title: 'Flutter Development',
        description: 'Learn Flutter',
        category: 'Programming',
        type: StudyPlanType.structured,
        difficulty: DifficultyLevel.beginner,
        estimatedDurationDays: 20,
        dailyTimeMinutes: 45,
        topics: ['Dart'],
        milestones: [milestone],
        status: StudyPlanStatus.draft,
        progressPercentage: 0.0,
        startDate: DateTime.now(),
        completedAt: null,
        completedSessions: 0,
        totalSessions: 5,
        metadata: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Assert
      expect(studyPlan.milestones, hasLength(1));
      expect(studyPlan.milestones.first.title, equals('Complete Dart Basics'));
      expect(studyPlan.milestones.first.isCompleted, isFalse);
    });

    test('should support copyWith method', () {
      // Arrange
      final originalPlan = StudyPlan(
        id: 'test-id',
        userId: 'user-123',
        title: 'Original Title',
        description: 'Original Description',
        category: 'Programming',
        type: StudyPlanType.flexible,
        difficulty: DifficultyLevel.beginner,
        estimatedDurationDays: 15,
        dailyTimeMinutes: 30,
        topics: ['Topic 1'],
        milestones: [],
        status: StudyPlanStatus.draft,
        progressPercentage: 0.0,
        startDate: DateTime.now(),
        completedAt: null,
        completedSessions: 0,
        totalSessions: 3,
        metadata: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final updatedPlan = originalPlan.copyWith(
        title: 'Updated Title',
        status: StudyPlanStatus.active,
        progressPercentage: 25.0,
      );

      // Assert
      expect(updatedPlan.title, equals('Updated Title'));
      expect(updatedPlan.status, equals(StudyPlanStatus.active));
      expect(updatedPlan.progressPercentage, equals(25.0));
      expect(updatedPlan.id, equals(originalPlan.id)); // Unchanged
      expect(updatedPlan.userId, equals(originalPlan.userId)); // Unchanged
    });

    test('should calculate completion correctly', () {
      // Arrange
      final studyPlan = StudyPlan(
        id: 'test-id',
        userId: 'user-123',
        title: 'Test Plan',
        description: 'Test',
        category: 'Test',
        type: StudyPlanType.structured,
        difficulty: DifficultyLevel.intermediate,
        estimatedDurationDays: 10,
        dailyTimeMinutes: 60,
        topics: ['Topic 1', 'Topic 2'],
        milestones: [],
        status: StudyPlanStatus.completed,
        progressPercentage: 100.0,
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        completedAt: DateTime.now(),
        completedSessions: 10,
        totalSessions: 10,
        metadata: {},
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      );

      // Assert
      expect(studyPlan.isCompleted, isTrue);
      expect(studyPlan.isActive, isFalse);
      expect(studyPlan.isDraft, isFalse);
      expect(studyPlan.progressPercentage, equals(100.0));
    });

    test('should handle different statuses correctly', () {
      final basePlan = StudyPlan(
        id: 'test-id',
        userId: 'user-123',
        title: 'Test Plan',
        description: 'Test',
        category: 'Test',
        type: StudyPlanType.structured,
        difficulty: DifficultyLevel.beginner,
        estimatedDurationDays: 10,
        dailyTimeMinutes: 30,
        topics: ['Topic 1'],
        milestones: [],
        status: StudyPlanStatus.draft,
        progressPercentage: 0.0,
        startDate: DateTime.now(),
        completedAt: null,
        completedSessions: 0,
        totalSessions: 5,
        metadata: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Test draft status
      expect(basePlan.isDraft, isTrue);
      expect(basePlan.isActive, isFalse);
      expect(basePlan.isCompleted, isFalse);

      // Test active status
      final activePlan = basePlan.copyWith(status: StudyPlanStatus.active);
      expect(activePlan.isDraft, isFalse);
      expect(activePlan.isActive, isTrue);
      expect(activePlan.isCompleted, isFalse);

      // Test paused status
      final pausedPlan = basePlan.copyWith(status: StudyPlanStatus.paused);
      expect(pausedPlan.isDraft, isFalse);
      expect(pausedPlan.isActive, isFalse);
      expect(pausedPlan.isCompleted, isFalse);

      // Test completed status
      final completedPlan =
          basePlan.copyWith(status: StudyPlanStatus.completed);
      expect(completedPlan.isDraft, isFalse);
      expect(completedPlan.isActive, isFalse);
      expect(completedPlan.isCompleted, isTrue);
    });
  });

  group('StudyPlanMilestone Model Tests', () {
    test('should create a milestone with all required fields', () {
      // Arrange
      final milestone = StudyPlanMilestone(
        id: 'milestone-1',
        title: 'Learn Dart Basics',
        description: 'Complete Dart fundamentals',
        orderIndex: 0,
        requiredTopics: ['Variables', 'Functions', 'Classes'],
        isCompleted: false,
        completedAt: null,
        estimatedDurationDays: 15,
        progressPercentage: 0.0,
        metadata: {},
      );

      // Assert
      expect(milestone.id, equals('milestone-1'));
      expect(milestone.title, equals('Learn Dart Basics'));
      expect(milestone.orderIndex, equals(0));
      expect(milestone.requiredTopics, hasLength(3));
      expect(milestone.isCompleted, isFalse);
      expect(milestone.completedAt, isNull);
      expect(milestone.estimatedDurationDays, equals(15));
    });

    test('should support copyWith method', () {
      // Arrange
      final originalMilestone = StudyPlanMilestone(
        id: 'milestone-1',
        title: 'Original Title',
        description: 'Original Description',
        orderIndex: 0,
        requiredTopics: ['Topic 1'],
        isCompleted: false,
        completedAt: null,
        estimatedDurationDays: 10,
        progressPercentage: 0.0,
        metadata: {},
      );

      // Act
      final completedMilestone = originalMilestone.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
        progressPercentage: 100.0,
      );

      // Assert
      expect(completedMilestone.isCompleted, isTrue);
      expect(completedMilestone.completedAt, isNotNull);
      expect(completedMilestone.progressPercentage, equals(100.0));
      expect(completedMilestone.id, equals(originalMilestone.id)); // Unchanged
      expect(completedMilestone.title,
          equals(originalMilestone.title)); // Unchanged
    });
  });

  group('StudySchedule Model Tests', () {
    test('should create a schedule with all required fields', () {
      // Arrange
      final now = DateTime.now();
      final schedule = StudySchedule(
        id: 'schedule-1',
        userId: 'user-123',
        studyPlanId: 'plan-123',
        title: 'Daily Flutter Study',
        scheduledDate: now.add(const Duration(days: 1)),
        scheduledTime: const TimeOfDay(hour: 19, minute: 0),
        durationMinutes: 60,
        topics: ['Widgets', 'State Management'],
        sessionType: StudySessionType.learning,
        status: ScheduleStatus.scheduled,
        isRecurring: false,
        metadata: {},
        createdAt: now,
        updatedAt: now,
      );

      // Assert
      expect(schedule.id, equals('schedule-1'));
      expect(schedule.title, equals('Daily Flutter Study'));
      expect(schedule.durationMinutes, equals(60));
      expect(schedule.topics, hasLength(2));
      expect(schedule.sessionType, equals(StudySessionType.learning));
      expect(schedule.status, equals(ScheduleStatus.scheduled));
    });

    test('should support copyWith method', () {
      // Arrange
      final originalSchedule = StudySchedule(
        id: 'schedule-1',
        userId: 'user-123',
        studyPlanId: 'plan-123',
        title: 'Study Session',
        scheduledDate: DateTime.now(),
        scheduledTime: const TimeOfDay(hour: 10, minute: 0),
        durationMinutes: 45,
        topics: ['Topic 1'],
        sessionType: StudySessionType.practice,
        status: ScheduleStatus.scheduled,
        isRecurring: false,
        metadata: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final completedSchedule = originalSchedule.copyWith(
        status: ScheduleStatus.completed,
        title: 'Completed Study Session',
      );

      // Assert
      expect(completedSchedule.status, equals(ScheduleStatus.completed));
      expect(completedSchedule.title, equals('Completed Study Session'));
      expect(completedSchedule.id, equals(originalSchedule.id)); // Unchanged
    });
  });

  group('Enum Tests', () {
    test('StudyPlanType should have correct values', () {
      expect(StudyPlanType.values, hasLength(4));
      expect(StudyPlanType.values, contains(StudyPlanType.structured));
      expect(StudyPlanType.values, contains(StudyPlanType.flexible));
      expect(StudyPlanType.values, contains(StudyPlanType.intensive));
      expect(StudyPlanType.values, contains(StudyPlanType.casual));
    });

    test('StudyPlanStatus should have correct values', () {
      expect(StudyPlanStatus.values, hasLength(5));
      expect(StudyPlanStatus.values, contains(StudyPlanStatus.draft));
      expect(StudyPlanStatus.values, contains(StudyPlanStatus.active));
      expect(StudyPlanStatus.values, contains(StudyPlanStatus.paused));
      expect(StudyPlanStatus.values, contains(StudyPlanStatus.completed));
      expect(StudyPlanStatus.values, contains(StudyPlanStatus.cancelled));
    });

    test('DifficultyLevel should have correct values', () {
      expect(DifficultyLevel.values, hasLength(4));
      expect(DifficultyLevel.values, contains(DifficultyLevel.beginner));
      expect(DifficultyLevel.values, contains(DifficultyLevel.intermediate));
      expect(DifficultyLevel.values, contains(DifficultyLevel.advanced));
      expect(DifficultyLevel.values, contains(DifficultyLevel.expert));
    });

    test('StudySessionType should have correct values', () {
      expect(StudySessionType.values, hasLength(4));
      expect(StudySessionType.values, contains(StudySessionType.learning));
      expect(StudySessionType.values, contains(StudySessionType.practice));
      expect(StudySessionType.values, contains(StudySessionType.review));
      expect(StudySessionType.values, contains(StudySessionType.assessment));
    });
  });
}

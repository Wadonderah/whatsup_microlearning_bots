import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsup_microlearning_bots/core/models/study_plan.dart';
import 'package:whatsup_microlearning_bots/core/services/study_plan_service.dart';

void main() {
  group('StudyPlanService Tests', () {
    late StudyPlanService studyPlanService;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      studyPlanService = StudyPlanService.withFirestore(fakeFirestore);
    });

    group('Study Plan Creation', () {
      test('should create a study plan successfully', () async {
        // Arrange
        const userId = 'test-user-123';
        const title = 'Learn Flutter Development';
        const description = 'Complete Flutter course with hands-on projects';
        const category = 'Programming';
        const type = StudyPlanType.structured;
        const difficulty = DifficultyLevel.intermediate;
        const estimatedDurationDays = 30;
        const dailyTimeMinutes = 60;
        final topics = [
          'Dart Basics',
          'Widgets',
          'State Management',
          'Navigation'
        ];

        // Act
        final planId = await studyPlanService.createStudyPlan(
          userId: userId,
          title: title,
          description: description,
          category: category,
          type: type,
          difficulty: difficulty,
          estimatedDurationDays: estimatedDurationDays,
          dailyTimeMinutes: dailyTimeMinutes,
          topics: topics,
        );

        // Assert
        expect(planId, isNotNull);
        expect(planId, isNotEmpty);

        // Verify the plan was created
        final createdPlan = await studyPlanService.getStudyPlan(planId);
        expect(createdPlan, isNotNull);
        expect(createdPlan!.title, equals(title));
        expect(createdPlan.userId, equals(userId));
        expect(createdPlan.topics, equals(topics));
        expect(createdPlan.status, equals(StudyPlanStatus.draft));
        expect(createdPlan.progressPercentage, equals(0.0));
      });

      test('should generate default milestones when none provided', () async {
        // Arrange
        const userId = 'test-user-123';
        final topics = ['Topic 1', 'Topic 2', 'Topic 3', 'Topic 4', 'Topic 5'];

        // Act
        final planId = await studyPlanService.createStudyPlan(
          userId: userId,
          title: 'Test Plan',
          description: 'Test Description',
          category: 'Test',
          type: StudyPlanType.flexible,
          difficulty: DifficultyLevel.beginner,
          estimatedDurationDays: 20,
          dailyTimeMinutes: 30,
          topics: topics,
        );

        // Assert
        final plan = await studyPlanService.getStudyPlan(planId);
        expect(plan!.milestones, isNotEmpty);
        expect(plan.milestones.length, equals(4)); // Default 4 milestones
        expect(plan.milestones.first.orderIndex, equals(0));
        expect(plan.milestones.last.orderIndex, equals(3));
      });
    });

    group('Study Plan Management', () {
      late String testPlanId;

      setUp(() async {
        testPlanId = await studyPlanService.createStudyPlan(
          userId: 'test-user-123',
          title: 'Test Plan',
          description: 'Test Description',
          category: 'Test',
          type: StudyPlanType.structured,
          difficulty: DifficultyLevel.intermediate,
          estimatedDurationDays: 15,
          dailyTimeMinutes: 45,
          topics: ['Topic 1', 'Topic 2'],
        );
      });

      test('should start a study plan', () async {
        // Act
        final success = await studyPlanService.startStudyPlan(testPlanId);

        // Assert
        expect(success, isTrue);

        final plan = await studyPlanService.getStudyPlan(testPlanId);
        expect(plan!.status, equals(StudyPlanStatus.active));
        expect(plan.startDate, isNotNull);
      });

      test('should pause a study plan', () async {
        // Arrange
        await studyPlanService.startStudyPlan(testPlanId);

        // Act
        final success = await studyPlanService.pauseStudyPlan(testPlanId);

        // Assert
        expect(success, isTrue);

        final plan = await studyPlanService.getStudyPlan(testPlanId);
        expect(plan!.status, equals(StudyPlanStatus.paused));
      });

      test('should complete a study plan', () async {
        // Arrange
        await studyPlanService.startStudyPlan(testPlanId);

        // Act
        final success = await studyPlanService.completeStudyPlan(testPlanId);

        // Assert
        expect(success, isTrue);

        final plan = await studyPlanService.getStudyPlan(testPlanId);
        expect(plan!.status, equals(StudyPlanStatus.completed));
        expect(plan.progressPercentage, equals(100.0));
        expect(plan.completedAt, isNotNull);
      });

      test('should update study plan progress', () async {
        // Arrange
        await studyPlanService.startStudyPlan(testPlanId);

        // Act
        final success =
            await studyPlanService.updateStudyPlanProgress(testPlanId, 50.0);

        // Assert
        expect(success, isTrue);

        final plan = await studyPlanService.getStudyPlan(testPlanId);
        expect(plan!.progressPercentage, equals(50.0));
      });

      test('should complete a milestone', () async {
        // Arrange
        await studyPlanService.startStudyPlan(testPlanId);
        final plan = await studyPlanService.getStudyPlan(testPlanId);
        final milestoneId = plan!.milestones.first.id;

        // Act
        final success =
            await studyPlanService.completeMilestone(testPlanId, milestoneId);

        // Assert
        expect(success, isTrue);

        final updatedPlan = await studyPlanService.getStudyPlan(testPlanId);
        final completedMilestone =
            updatedPlan!.milestones.firstWhere((m) => m.id == milestoneId);
        expect(completedMilestone.isCompleted, isTrue);
        expect(completedMilestone.completedAt, isNotNull);
        expect(updatedPlan.progressPercentage, greaterThan(0));
      });
    });

    group('Study Plan Queries', () {
      setUp(() async {
        // Create test plans
        await studyPlanService.createStudyPlan(
          userId: 'user1',
          title: 'Active Plan',
          description: 'Active plan description',
          category: 'Programming',
          type: StudyPlanType.structured,
          difficulty: DifficultyLevel.beginner,
          estimatedDurationDays: 10,
          dailyTimeMinutes: 30,
          topics: ['Topic 1'],
        );

        final planId2 = await studyPlanService.createStudyPlan(
          userId: 'user1',
          title: 'Completed Plan',
          description: 'Completed plan description',
          category: 'Design',
          type: StudyPlanType.flexible,
          difficulty: DifficultyLevel.advanced,
          estimatedDurationDays: 20,
          dailyTimeMinutes: 60,
          topics: ['Topic 2'],
        );

        await studyPlanService.startStudyPlan(planId2);
        await studyPlanService.completeStudyPlan(planId2);
      });

      test('should get user study plans', () async {
        // Act
        final plans = await studyPlanService.getUserStudyPlans('user1');

        // Assert
        expect(plans, hasLength(2));
        expect(plans.map((p) => p.title),
            containsAll(['Active Plan', 'Completed Plan']));
      });

      test('should get active study plans only', () async {
        // Act
        final activePlans = await studyPlanService.getActiveStudyPlans('user1');

        // Assert
        expect(activePlans, hasLength(0)); // None are active yet
      });

      test('should return empty list for non-existent user', () async {
        // Act
        final plans =
            await studyPlanService.getUserStudyPlans('non-existent-user');

        // Assert
        expect(plans, isEmpty);
      });
    });

    group('Study Schedules', () {
      test('should create a study schedule', () async {
        // Arrange
        const userId = 'test-user-123';
        const studyPlanId = 'test-plan-123';
        const title = 'Daily Flutter Study';
        final scheduledDate = DateTime.now().add(const Duration(days: 1));
        const scheduledTime = TimeOfDay(hour: 19, minute: 0);
        const durationMinutes = 60;
        final topics = ['Widgets', 'State Management'];

        // Act
        final scheduleId = await studyPlanService.createStudySchedule(
          userId: userId,
          studyPlanId: studyPlanId,
          title: title,
          scheduledDate: scheduledDate,
          scheduledTime: scheduledTime,
          durationMinutes: durationMinutes,
          topics: topics,
          sessionType: StudySessionType.learning,
        );

        // Assert
        expect(scheduleId, isNotNull);
        expect(scheduleId, isNotEmpty);
      });

      test('should get user schedules for specific date', () async {
        // Arrange
        const userId = 'test-user-123';
        final targetDate = DateTime.now().add(const Duration(days: 1));

        await studyPlanService.createStudySchedule(
          userId: userId,
          studyPlanId: 'plan1',
          title: 'Schedule 1',
          scheduledDate: targetDate,
          scheduledTime: const TimeOfDay(hour: 9, minute: 0),
          durationMinutes: 30,
          topics: ['Topic 1'],
          sessionType: StudySessionType.learning,
        );

        // Act
        final schedules =
            await studyPlanService.getUserSchedules(userId, date: targetDate);

        // Assert
        expect(schedules, hasLength(1));
        expect(schedules.first.title, equals('Schedule 1'));
      });

      test('should complete a scheduled session', () async {
        // Arrange
        const userId = 'test-user-123';
        final scheduleId = await studyPlanService.createStudySchedule(
          userId: userId,
          studyPlanId: 'plan1',
          title: 'Test Session',
          scheduledDate: DateTime.now(),
          scheduledTime: const TimeOfDay(hour: 10, minute: 0),
          durationMinutes: 45,
          topics: ['Topic 1'],
          sessionType: StudySessionType.practice,
        );

        // Act
        final success =
            await studyPlanService.completeScheduledSession(scheduleId);

        // Assert
        expect(success, isTrue);
      });
    });

    group('Error Handling', () {
      test('should handle non-existent study plan gracefully', () async {
        // Act
        final plan = await studyPlanService.getStudyPlan('non-existent-id');

        // Assert
        expect(plan, isNull);
      });

      test('should handle starting non-existent plan', () async {
        // Act
        final success =
            await studyPlanService.startStudyPlan('non-existent-id');

        // Assert
        expect(success, isFalse);
      });

      test('should handle completing non-existent milestone', () async {
        // Arrange
        final planId = await studyPlanService.createStudyPlan(
          userId: 'test-user',
          title: 'Test Plan',
          description: 'Test',
          category: 'Test',
          type: StudyPlanType.structured,
          difficulty: DifficultyLevel.beginner,
          estimatedDurationDays: 10,
          dailyTimeMinutes: 30,
          topics: ['Topic 1'],
        );

        // Act
        final success = await studyPlanService.completeMilestone(
            planId, 'non-existent-milestone');

        // Assert
        expect(
            success, isTrue); // Should still succeed but not find the milestone
      });
    });
  });
}

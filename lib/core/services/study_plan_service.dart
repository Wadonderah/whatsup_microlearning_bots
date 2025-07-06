import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/study_plan.dart';

class StudyPlanService {
  static StudyPlanService? _instance;
  static StudyPlanService get instance => _instance ??= StudyPlanService._();

  StudyPlanService._() : _firestore = FirebaseFirestore.instance;

  // Constructor for testing with dependency injection
  StudyPlanService.withFirestore(this._firestore);

  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  // Collection references
  CollectionReference<StudyPlan> get _studyPlansCollection =>
      _firestore.collection('study_plans').withConverter<StudyPlan>(
            fromFirestore: (snapshot, _) => StudyPlan.fromFirestore(snapshot),
            toFirestore: (plan, _) => plan.toFirestore(),
          );

  CollectionReference<StudySchedule> get _schedulesCollection =>
      _firestore.collection('study_schedules').withConverter<StudySchedule>(
            fromFirestore: (snapshot, _) =>
                StudySchedule.fromFirestore(snapshot),
            toFirestore: (schedule, _) => schedule.toFirestore(),
          );

  /// Create a new study plan
  Future<String> createStudyPlan({
    required String userId,
    required String title,
    required String description,
    required String category,
    required StudyPlanType type,
    required DifficultyLevel difficulty,
    required int estimatedDurationDays,
    required int dailyTimeMinutes,
    required List<String> topics,
    List<StudyPlanMilestone>? milestones,
    DateTime? startDate,
  }) async {
    try {
      final planId = _uuid.v4();
      final now = DateTime.now();
      final actualStartDate = startDate ?? now;
      final endDate =
          actualStartDate.add(Duration(days: estimatedDurationDays));

      // Generate default milestones if none provided
      final defaultMilestones = milestones ??
          _generateDefaultMilestones(topics, estimatedDurationDays);

      final studyPlan = StudyPlan(
        id: planId,
        userId: userId,
        title: title,
        description: description,
        category: category,
        type: type,
        difficulty: difficulty,
        estimatedDurationDays: estimatedDurationDays,
        dailyTimeMinutes: dailyTimeMinutes,
        topics: topics,
        milestones: defaultMilestones,
        status: StudyPlanStatus.draft,
        startDate: actualStartDate,
        endDate: endDate,
        progressPercentage: 0.0,
        completedSessions: 0,
        totalSessions:
            _calculateTotalSessions(estimatedDurationDays, dailyTimeMinutes),
        metadata: {},
        createdAt: now,
        updatedAt: now,
      );

      await _studyPlansCollection.doc(planId).set(studyPlan);
      log('Study plan created: $planId');
      return planId;
    } catch (e) {
      log('Error creating study plan: $e');
      rethrow;
    }
  }

  /// Get study plans for a user
  Future<List<StudyPlan>> getUserStudyPlans(String userId) async {
    try {
      final snapshot = await _studyPlansCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      log('Error getting user study plans: $e');
      return [];
    }
  }

  /// Get active study plans for a user
  Future<List<StudyPlan>> getActiveStudyPlans(String userId) async {
    try {
      final snapshot = await _studyPlansCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .orderBy('startDate')
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      log('Error getting active study plans: $e');
      return [];
    }
  }

  /// Get a specific study plan
  Future<StudyPlan?> getStudyPlan(String planId) async {
    try {
      final doc = await _studyPlansCollection.doc(planId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      log('Error getting study plan: $e');
      return null;
    }
  }

  /// Update study plan
  Future<bool> updateStudyPlan(StudyPlan studyPlan) async {
    try {
      final updatedPlan = studyPlan.copyWith(updatedAt: DateTime.now());
      await _studyPlansCollection.doc(studyPlan.id).set(updatedPlan);
      return true;
    } catch (e) {
      log('Error updating study plan: $e');
      return false;
    }
  }

  /// Start a study plan
  Future<bool> startStudyPlan(String planId) async {
    try {
      final plan = await getStudyPlan(planId);
      if (plan == null) return false;

      final updatedPlan = plan.copyWith(
        status: StudyPlanStatus.active,
        startDate: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await updateStudyPlan(updatedPlan);

      // Generate initial schedules
      await _generateInitialSchedules(updatedPlan);

      return true;
    } catch (e) {
      log('Error starting study plan: $e');
      return false;
    }
  }

  /// Pause a study plan
  Future<bool> pauseStudyPlan(String planId) async {
    try {
      final plan = await getStudyPlan(planId);
      if (plan == null) return false;

      final updatedPlan = plan.copyWith(
        status: StudyPlanStatus.paused,
        updatedAt: DateTime.now(),
      );

      return await updateStudyPlan(updatedPlan);
    } catch (e) {
      log('Error pausing study plan: $e');
      return false;
    }
  }

  /// Complete a study plan
  Future<bool> completeStudyPlan(String planId) async {
    try {
      final plan = await getStudyPlan(planId);
      if (plan == null) return false;

      final updatedPlan = plan.copyWith(
        status: StudyPlanStatus.completed,
        completedAt: DateTime.now(),
        progressPercentage: 100.0,
        updatedAt: DateTime.now(),
      );

      return await updateStudyPlan(updatedPlan);
    } catch (e) {
      log('Error completing study plan: $e');
      return false;
    }
  }

  /// Update study plan progress
  Future<bool> updateStudyPlanProgress(
      String planId, double progressPercentage) async {
    try {
      final plan = await getStudyPlan(planId);
      if (plan == null) return false;

      final updatedPlan = plan.copyWith(
        progressPercentage: progressPercentage,
        updatedAt: DateTime.now(),
      );

      // Check if plan should be completed
      if (progressPercentage >= 100.0) {
        return await completeStudyPlan(planId);
      }

      return await updateStudyPlan(updatedPlan);
    } catch (e) {
      log('Error updating study plan progress: $e');
      return false;
    }
  }

  /// Complete a milestone
  Future<bool> completeMilestone(String planId, String milestoneId) async {
    try {
      final plan = await getStudyPlan(planId);
      if (plan == null) return false;

      final updatedMilestones = plan.milestones.map((milestone) {
        if (milestone.id == milestoneId) {
          return milestone.copyWith(
            isCompleted: true,
            completedAt: DateTime.now(),
            progressPercentage: 100.0,
          );
        }
        return milestone;
      }).toList();

      // Calculate overall progress based on completed milestones
      final completedCount =
          updatedMilestones.where((m) => m.isCompleted).length;
      final overallProgress = (completedCount / updatedMilestones.length) * 100;

      final updatedPlan = plan.copyWith(
        milestones: updatedMilestones,
        progressPercentage: overallProgress,
        updatedAt: DateTime.now(),
      );

      return await updateStudyPlan(updatedPlan);
    } catch (e) {
      log('Error completing milestone: $e');
      return false;
    }
  }

  /// Create a study schedule
  Future<String> createStudySchedule({
    required String userId,
    required String studyPlanId,
    required String title,
    required DateTime scheduledDate,
    required TimeOfDay scheduledTime,
    required int durationMinutes,
    required List<String> topics,
    required StudySessionType sessionType,
    bool isRecurring = false,
    RecurrencePattern? recurrencePattern,
  }) async {
    try {
      final scheduleId = _uuid.v4();
      final now = DateTime.now();

      final schedule = StudySchedule(
        id: scheduleId,
        userId: userId,
        studyPlanId: studyPlanId,
        title: title,
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        durationMinutes: durationMinutes,
        topics: topics,
        sessionType: sessionType,
        status: ScheduleStatus.scheduled,
        isRecurring: isRecurring,
        recurrencePattern: recurrencePattern,
        metadata: {},
        createdAt: now,
        updatedAt: now,
      );

      await _schedulesCollection.doc(scheduleId).set(schedule);

      // Generate recurring schedules if needed
      if (isRecurring && recurrencePattern != null) {
        await _generateRecurringSchedules(schedule, recurrencePattern);
      }

      log('Study schedule created: $scheduleId');
      return scheduleId;
    } catch (e) {
      log('Error creating study schedule: $e');
      rethrow;
    }
  }

  /// Get user schedules
  Future<List<StudySchedule>> getUserSchedules(String userId,
      {DateTime? date}) async {
    try {
      Query<StudySchedule> query =
          _schedulesCollection.where('userId', isEqualTo: userId);

      if (date != null) {
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));

        query = query
            .where('scheduledDate',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('scheduledDate', isLessThan: Timestamp.fromDate(endOfDay));
      }

      final snapshot = await query.orderBy('scheduledDate').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      log('Error getting user schedules: $e');
      return [];
    }
  }

  /// Get upcoming schedules
  Future<List<StudySchedule>> getUpcomingSchedules(String userId,
      {int limit = 10}) async {
    try {
      final now = DateTime.now();
      final snapshot = await _schedulesCollection
          .where('userId', isEqualTo: userId)
          .where('scheduledDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where('status', isEqualTo: 'scheduled')
          .orderBy('scheduledDate')
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      log('Error getting upcoming schedules: $e');
      return [];
    }
  }

  /// Complete a scheduled session
  Future<bool> completeScheduledSession(String scheduleId) async {
    try {
      final doc = await _schedulesCollection.doc(scheduleId).get();
      if (!doc.exists) return false;

      final schedule = doc.data()!;
      final updatedSchedule = schedule.copyWith(
        status: ScheduleStatus.completed,
        updatedAt: DateTime.now(),
      );

      await _schedulesCollection.doc(scheduleId).set(updatedSchedule);

      // Update study plan progress
      await _updatePlanProgressFromSession(schedule.studyPlanId);

      return true;
    } catch (e) {
      log('Error completing scheduled session: $e');
      return false;
    }
  }

  /// Mark schedule as missed
  Future<bool> markScheduleAsMissed(String scheduleId) async {
    try {
      final doc = await _schedulesCollection.doc(scheduleId).get();
      if (!doc.exists) return false;

      final schedule = doc.data()!;
      final updatedSchedule = schedule.copyWith(
        status: ScheduleStatus.missed,
        updatedAt: DateTime.now(),
      );

      await _schedulesCollection.doc(scheduleId).set(updatedSchedule);
      return true;
    } catch (e) {
      log('Error marking schedule as missed: $e');
      return false;
    }
  }

  /// Stream study plans for real-time updates
  Stream<List<StudyPlan>> streamUserStudyPlans(String userId) {
    return _studyPlansCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Stream schedules for real-time updates
  Stream<List<StudySchedule>> streamUserSchedules(String userId) {
    return _schedulesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('scheduledDate')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Delete study plan
  Future<bool> deleteStudyPlan(String planId) async {
    try {
      // Delete associated schedules first
      final schedules = await _schedulesCollection
          .where('studyPlanId', isEqualTo: planId)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in schedules.docs) {
        batch.delete(doc.reference);
      }

      // Delete the study plan
      batch.delete(_studyPlansCollection.doc(planId));

      await batch.commit();
      return true;
    } catch (e) {
      log('Error deleting study plan: $e');
      return false;
    }
  }

  // Helper methods
  List<StudyPlanMilestone> _generateDefaultMilestones(
      List<String> topics, int durationDays) {
    final milestones = <StudyPlanMilestone>[];
    final topicsPerMilestone = (topics.length / 4).ceil();

    for (int i = 0; i < 4; i++) {
      final startIndex = i * topicsPerMilestone;
      final endIndex =
          (startIndex + topicsPerMilestone).clamp(0, topics.length);

      if (startIndex < topics.length) {
        final milestoneTopics = topics.sublist(startIndex, endIndex);

        milestones.add(StudyPlanMilestone(
          id: _uuid.v4(),
          title: 'Milestone ${i + 1}',
          description: 'Complete topics: ${milestoneTopics.join(', ')}',
          orderIndex: i,
          requiredTopics: milestoneTopics,
          estimatedDurationDays: (durationDays / 4).ceil(),
          isCompleted: false,
          progressPercentage: 0.0,
          metadata: {},
        ));
      }
    }

    return milestones;
  }

  int _calculateTotalSessions(int durationDays, int dailyTimeMinutes) {
    // Assume 30-minute sessions on average
    const averageSessionMinutes = 30;
    final sessionsPerDay = (dailyTimeMinutes / averageSessionMinutes).ceil();
    return durationDays * sessionsPerDay;
  }

  Future<void> _generateInitialSchedules(StudyPlan plan) async {
    // Generate first week of schedules
    final startDate = plan.startDate;

    for (int i = 0; i < 7; i++) {
      final scheduleDate = startDate.add(Duration(days: i));

      await createStudySchedule(
        userId: plan.userId,
        studyPlanId: plan.id,
        title: '${plan.title} - Day ${i + 1}',
        scheduledDate: scheduleDate,
        scheduledTime: const TimeOfDay(hour: 19, minute: 0), // Default 7 PM
        durationMinutes: plan.dailyTimeMinutes,
        topics: plan.topics.take(2).toList(), // First 2 topics
        sessionType: StudySessionType.learning,
      );
    }
  }

  Future<void> _generateRecurringSchedules(
      StudySchedule baseSchedule, RecurrencePattern pattern) async {
    // Generate up to 30 recurring schedules
    final maxSchedules = pattern.maxOccurrences ?? 30;
    var currentDate = baseSchedule.scheduledDate;

    for (int i = 1; i < maxSchedules; i++) {
      switch (pattern.type) {
        case RecurrenceType.daily:
          currentDate = currentDate.add(Duration(days: pattern.interval));
          break;
        case RecurrenceType.weekly:
          currentDate = currentDate.add(Duration(days: 7 * pattern.interval));
          break;
        case RecurrenceType.monthly:
          currentDate = DateTime(
            currentDate.year,
            currentDate.month + pattern.interval,
            currentDate.day,
          );
          break;
      }

      if (pattern.endDate != null && currentDate.isAfter(pattern.endDate!)) {
        break;
      }

      final recurringSchedule = baseSchedule.copyWith(
        id: _uuid.v4(),
        scheduledDate: currentDate,
        title: '${baseSchedule.title} (${i + 1})',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _schedulesCollection
          .doc(recurringSchedule.id)
          .set(recurringSchedule);
    }
  }

  Future<void> _updatePlanProgressFromSession(String planId) async {
    try {
      final plan = await getStudyPlan(planId);
      if (plan == null) return;

      final completedSessions = plan.completedSessions + 1;
      final progressPercentage = (completedSessions / plan.totalSessions) * 100;

      final updatedPlan = plan.copyWith(
        completedSessions: completedSessions,
        progressPercentage: progressPercentage.clamp(0.0, 100.0),
        updatedAt: DateTime.now(),
      );

      await updateStudyPlan(updatedPlan);
    } catch (e) {
      log('Error updating plan progress from session: $e');
    }
  }
}

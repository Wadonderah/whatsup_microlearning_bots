import '../models/firestore_models.dart';

class DemoDataService {
  static UserStats getDemoUserStats() {
    return UserStats(
      totalSessions: 24,
      totalMessages: 156,
      totalLearningMinutes: 480,
      experiencePoints: 2350,
      level: 5,
      streakDays: 7,
      lastActiveDate: DateTime.now().subtract(const Duration(hours: 2)),
    );
  }

  static List<LearningSession> getDemoRecentSessions() {
    final now = DateTime.now();
    return [
      LearningSession(
        id: 'session-1',
        userId: 'demo-user',
        topic: 'Flutter Development',
        type: LearningSessionType.general,
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now.subtract(const Duration(hours: 1, minutes: 45)),
        durationMinutes: 15,
        messageCount: 12,
        experienceGained: 50,
        topicsDiscussed: ['Flutter', 'Dart'],
      ),
      LearningSession(
        id: 'session-2',
        userId: 'demo-user',
        topic: 'JavaScript Fundamentals',
        type: LearningSessionType.quiz,
        startTime: now.subtract(const Duration(days: 1, hours: 3)),
        endTime: now.subtract(const Duration(days: 1, hours: 2, minutes: 45)),
        durationMinutes: 15,
        messageCount: 8,
        experienceGained: 75,
        topicsDiscussed: ['JavaScript', 'React'],
      ),
      LearningSession(
        id: 'session-3',
        userId: 'demo-user',
        topic: 'Python & Machine Learning',
        type: LearningSessionType.explanation,
        startTime: now.subtract(const Duration(days: 2, hours: 1)),
        endTime: now.subtract(const Duration(days: 2, hours: 0, minutes: 30)),
        durationMinutes: 30,
        messageCount: 15,
        experienceGained: 100,
        topicsDiscussed: ['Python', 'Machine Learning'],
      ),
      LearningSession(
        id: 'session-4',
        userId: 'demo-user',
        topic: 'Data Structures & Algorithms',
        type: LearningSessionType.practice,
        startTime: now.subtract(const Duration(days: 3, hours: 2)),
        endTime: now.subtract(const Duration(days: 3, hours: 1, minutes: 20)),
        durationMinutes: 40,
        messageCount: 20,
        experienceGained: 120,
        topicsDiscussed: ['Algorithms', 'Data Structures'],
      ),
      LearningSession(
        id: 'session-5',
        userId: 'demo-user',
        topic: 'Web Development Basics',
        type: LearningSessionType.general,
        startTime: now.subtract(const Duration(days: 4, hours: 1)),
        endTime: now.subtract(const Duration(days: 4, hours: 0, minutes: 45)),
        durationMinutes: 15,
        messageCount: 10,
        experienceGained: 60,
        topicsDiscussed: ['Web Development', 'CSS'],
      ),
    ];
  }

  static List<Achievement> getDemoAchievements() {
    final now = DateTime.now();
    return [
      Achievement(
        id: 'achievement-1',
        userId: 'demo-user',
        title: 'First Chat',
        description: 'Started your first AI conversation',
        icon: 'chat_bubble',
        type: AchievementType.sessions,
        pointsAwarded: 50,
        unlockedAt: now.subtract(const Duration(days: 25)),
      ),
      Achievement(
        id: 'achievement-2',
        userId: 'demo-user',
        title: '3-Day Streak',
        description: 'Learned for 3 consecutive days',
        icon: 'local_fire_department',
        type: AchievementType.streak,
        pointsAwarded: 100,
        unlockedAt: now.subtract(const Duration(days: 20)),
      ),
      Achievement(
        id: 'achievement-3',
        userId: 'demo-user',
        title: 'Quiz Master',
        description: 'Completed 10 quizzes',
        icon: 'quiz',
        type: AchievementType.sessions,
        pointsAwarded: 200,
        unlockedAt: now.subtract(const Duration(days: 15)),
      ),
      Achievement(
        id: 'achievement-4',
        userId: 'demo-user',
        title: 'Level Up',
        description: 'Reached level 5',
        icon: 'trending_up',
        type: AchievementType.special,
        pointsAwarded: 150,
        unlockedAt: now.subtract(const Duration(days: 10)),
      ),
    ];
  }
}

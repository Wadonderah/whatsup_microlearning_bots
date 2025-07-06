import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/firestore_models.dart';
import '../../core/services/learning_analytics_service.dart';
import '../../core/services/user_data_service.dart';
import '../auth/providers/auth_provider.dart';

class LearningDashboardScreen extends ConsumerStatefulWidget {
  const LearningDashboardScreen({super.key});

  @override
  ConsumerState<LearningDashboardScreen> createState() =>
      _LearningDashboardScreenState();
}

class _LearningDashboardScreenState
    extends ConsumerState<LearningDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _analytics;
  List<LearningSession> _recentSessions = [];
  List<Achievement> _achievements = [];
  List<UserProgress> _progress = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    final authState = ref.read(authProvider);
    if (authState.user == null) return;

    final userId = authState.user!.uid;

    try {
      setState(() => _isLoading = true);

      // Load analytics data
      final analytics =
          await LearningAnalyticsService.instance.getLearningAnalytics(userId);

      // Load recent sessions
      final sessions =
          await LearningAnalyticsService.instance.getLearningSessions(
        userId,
        limit: 10,
      );

      // Load achievements
      final achievements =
          await LearningAnalyticsService.instance.getUserAchievements(userId);

      // Load progress
      final progress =
          await LearningAnalyticsService.instance.getUserProgress(userId);

      setState(() {
        _analytics = analytics;
        _recentSessions = sessions;
        _achievements = achievements;
        _progress = progress;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dashboard: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.trending_up), text: 'Progress'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Achievements'),
            Tab(icon: Icon(Icons.history), text: 'History'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildProgressTab(),
                _buildAchievementsTab(),
                _buildHistoryTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    if (_analytics == null) {
      return const Center(child: Text('No data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCards(),
          const SizedBox(height: 24),
          _buildStreakCard(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          'Total Sessions',
          '${_analytics!['totalSessions'] ?? 0}',
          Icons.school,
          Colors.blue,
        ),
        _buildStatCard(
          'Learning Time',
          '${_analytics!['totalMinutes'] ?? 0} min',
          Icons.timer,
          Colors.green,
        ),
        _buildStatCard(
          'Topics Studied',
          '${_analytics!['topicsStudied'] ?? 0}',
          Icons.topic,
          Colors.orange,
        ),
        _buildStatCard(
          'Achievements',
          '${_analytics!['totalAchievements'] ?? 0}',
          Icons.emoji_events,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.orange[400]!, Colors.red[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Learning Streak',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '0 days', // TODO: Implement user stats
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Keep it up! 🔥',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Start Learning',
                Icons.play_arrow,
                Colors.green,
                () => _startLearningSession(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Review Progress',
                Icons.analytics,
                Colors.blue,
                () => _tabController.animateTo(1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (_recentSessions.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text('No recent activity'),
              ),
            ),
          )
        else
          ...(_recentSessions
              .take(3)
              .map((session) => _buildActivityItem(session))),
      ],
    );
  }

  Widget _buildActivityItem(LearningSession session) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getSessionTypeColor(session.type),
          child: Icon(
            _getSessionTypeIcon(session.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(session.topic),
        subtitle: Text(
          '${session.durationMinutes} minutes • ${_formatDate(session.startTime)}',
        ),
        trailing: Text(
          '+${session.experienceGained} XP',
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLevelProgress(),
          const SizedBox(height: 24),
          _buildTopicProgress(),
          const SizedBox(height: 24),
          _buildWeeklyChart(),
        ],
      ),
    );
  }

  Widget _buildLevelProgress() {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) return const SizedBox.shrink();

    final currentLevel = 1; // TODO: Implement user stats
    final currentXP = 0; // TODO: Implement user stats
    final nextLevelXP =
        UserDataService.instance.getXPForNextLevel(currentLevel);
    final progress =
        UserDataService.instance.getLevelProgress(currentXP, currentLevel);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Level $currentLevel',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$currentXP / $nextLevelXP XP',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
            ),
            const SizedBox(height: 8),
            Text(
              '${((progress * 100).round())}% to next level',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Topic Progress',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (_progress.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text('No progress data available'),
              ),
            ),
          )
        else
          ..._progress.map((progress) => _buildTopicProgressItem(progress)),
      ],
    );
  }

  Widget _buildTopicProgressItem(UserProgress progress) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    progress.topic,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '${progress.completionPercentage.round()}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.completionPercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress.isCompleted ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${progress.totalSessions} sessions • Last studied: ${_formatDate(progress.lastStudied)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    // Placeholder for weekly learning chart
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: const Center(
                child: Text(
                  'Chart visualization would go here\n(requires chart library)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Achievements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (_achievements.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text('No achievements yet. Keep learning!'),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: _achievements.length,
              itemBuilder: (context, index) {
                return _buildAchievementCard(_achievements[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              achievement.icon,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              achievement.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '+${achievement.pointsAwarded} XP',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(achievement.unlockedAt),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Learning History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (_recentSessions.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text('No learning sessions yet'),
                ),
              ),
            )
          else
            ..._recentSessions.map((session) => _buildHistoryItem(session)),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(LearningSession session) {
    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getSessionTypeColor(session.type),
          child: Icon(
            _getSessionTypeIcon(session.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(session.topic),
        subtitle: Text(
          '${session.durationMinutes} minutes • ${_formatDate(session.startTime)}',
        ),
        trailing: Text(
          '+${session.experienceGained} XP',
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (session.category != null) ...[
                  Text('Category: ${session.category}'),
                  const SizedBox(height: 8),
                ],
                if (session.topicsDiscussed.isNotEmpty) ...[
                  const Text('Topics Discussed:'),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: session.topicsDiscussed
                        .map((topic) => Chip(
                              label: Text(topic),
                              backgroundColor: Colors.blue[100],
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getSessionTypeColor(LearningSessionType type) {
    switch (type) {
      case LearningSessionType.quiz:
        return Colors.purple;
      case LearningSessionType.practice:
        return Colors.orange;
      case LearningSessionType.explanation:
        return Colors.blue;
      case LearningSessionType.summary:
        return Colors.green;
      case LearningSessionType.general:
        return Colors.grey;
    }
  }

  IconData _getSessionTypeIcon(LearningSessionType type) {
    switch (type) {
      case LearningSessionType.quiz:
        return Icons.quiz;
      case LearningSessionType.practice:
        return Icons.fitness_center;
      case LearningSessionType.explanation:
        return Icons.lightbulb;
      case LearningSessionType.summary:
        return Icons.summarize;
      case LearningSessionType.general:
        return Icons.school;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _startLearningSession() {
    // Navigate to AI assistant or start a new learning session
    Navigator.pushNamed(context, '/ai-assistant');
  }
}

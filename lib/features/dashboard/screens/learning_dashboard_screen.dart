import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/firestore_models.dart';
import '../../../core/services/demo_data_service.dart';
import '../widgets/achievements_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/learning_stats_card.dart';
import '../widgets/progress_overview_card.dart';
import '../widgets/quick_actions_card.dart';
import '../widgets/recent_activity_card.dart';
import '../widgets/study_streak_card.dart';

class LearningDashboardScreen extends StatefulWidget {
  const LearningDashboardScreen({super.key});

  @override
  State<LearningDashboardScreen> createState() =>
      _LearningDashboardScreenState();
}

class _LearningDashboardScreenState extends State<LearningDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  UserStats? _userStats;
  List<LearningSession> _recentSessions = [];
  List<Achievement> _achievements = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDashboardData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Simulate loading delay for demo
      await Future.delayed(const Duration(milliseconds: 1500));

      // Use demo data for now
      final stats = DemoDataService.getDemoUserStats();
      final sessions = DemoDataService.getDemoRecentSessions();
      final achievements = DemoDataService.getDemoAchievements();

      setState(() {
        _userStats = stats;
        _recentSessions = sessions;
        _achievements = achievements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Dashboard Header
            SliverToBoxAdapter(
              child: DashboardHeader(
                userStats: _userStats,
                onProfileTap: () => context.push('/profile'),
              ),
            ),

            // Main Content
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Learning Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: LearningStatsCard(
                          title: 'Total Sessions',
                          value: _userStats?.totalSessions.toString() ?? '0',
                          icon: Icons.school_outlined,
                          color: Colors.blue,
                          trend: '+12%',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LearningStatsCard(
                          title: 'Learning Time',
                          value: '${_userStats?.totalLearningMinutes ?? 0}m',
                          icon: Icons.access_time_outlined,
                          color: Colors.green,
                          trend: '+8%',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Study Streak Card
                  StudyStreakCard(
                    currentStreak: _userStats?.streakDays ?? 0,
                    longestStreak: 15, // TODO: Add to UserStats
                    lastStudyDate: _userStats?.lastActiveDate,
                  ),

                  const SizedBox(height: 16),

                  // Progress Overview
                  ProgressOverviewCard(
                    level: _userStats?.level ?? 1,
                    experiencePoints: _userStats?.experiencePoints ?? 0,
                    nextLevelXP: _calculateNextLevelXP(_userStats?.level ?? 1),
                  ),

                  const SizedBox(height: 16),

                  // Quick Actions
                  QuickActionsCard(
                    onStartLearning: () => context.push('/chat'),
                    onViewProgress: () => context.push('/progress'),
                    onTakeQuiz: () => context.push('/quiz'),
                    onViewAchievements: () => context.push('/achievements'),
                  ),

                  const SizedBox(height: 16),

                  // Recent Activity
                  RecentActivityCard(
                    sessions: _recentSessions,
                    onViewAll: () => context.push('/activity'),
                  ),

                  const SizedBox(height: 16),

                  // Achievements
                  AchievementsCard(
                    achievements: _achievements,
                    onViewAll: () => context.push('/achievements'),
                  ),

                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading your learning dashboard...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load dashboard',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error occurred',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadDashboardData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  int _calculateNextLevelXP(int currentLevel) {
    // Simple XP calculation: level * 1000
    return currentLevel * 1000;
  }
}

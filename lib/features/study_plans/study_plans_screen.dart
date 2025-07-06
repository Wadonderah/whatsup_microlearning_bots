import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_assets.dart';
import '../../core/models/study_plan.dart';
import '../../core/services/study_plan_service.dart';
import '../auth/providers/auth_provider.dart';
import 'create_study_plan_screen.dart';
import 'study_plan_detail_screen.dart';

// Study plans provider
final studyPlansProvider =
    StreamProvider.family<List<StudyPlan>, String>((ref, userId) {
  return StudyPlanService.instance.streamUserStudyPlans(userId);
});

class StudyPlansScreen extends ConsumerStatefulWidget {
  const StudyPlansScreen({super.key});

  @override
  ConsumerState<StudyPlansScreen> createState() => _StudyPlansScreenState();
}

class _StudyPlansScreenState extends ConsumerState<StudyPlansScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (authState.user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view study plans')),
      );
    }

    final studyPlansAsync = ref.watch(studyPlansProvider(authState.user!.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Plans'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _createNewStudyPlan(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: studyPlansAsync.when(
        data: (studyPlans) => TabBarView(
          controller: _tabController,
          children: [
            _buildStudyPlansList(studyPlans.where((p) => p.isActive).toList()),
            _buildStudyPlansList(
                studyPlans.where((p) => p.isCompleted).toList()),
            _buildStudyPlansList(studyPlans),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading study plans: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.refresh(studyPlansProvider(authState.user!.uid)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewStudyPlan(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStudyPlansList(List<StudyPlan> studyPlans) {
    if (studyPlans.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: studyPlans.length,
      itemBuilder: (context, index) {
        return _buildStudyPlanCard(studyPlans[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                AppAssets.emptyStateStudyPlans,
                width: 100,
                height: 100,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to icon if image not found
                  return Icon(
                    Icons.school_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No study plans yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first study plan to start learning',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _createNewStudyPlan(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Study Plan'),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyPlanCard(StudyPlan studyPlan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _openStudyPlanDetail(studyPlan),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          studyPlan.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          studyPlan.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(studyPlan.status),
                ],
              ),
              const SizedBox(height: 12),
              _buildProgressBar(studyPlan),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.category,
                    studyPlan.category,
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.schedule,
                    '${studyPlan.dailyTimeMinutes} min/day',
                    Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.calendar_today,
                    '${studyPlan.remainingDays} days left',
                    Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${studyPlan.completedMilestones}/${studyPlan.milestones.length} milestones',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  if (studyPlan.isActive) ...[
                    TextButton(
                      onPressed: () => _pauseStudyPlan(studyPlan.id),
                      child: const Text('Pause'),
                    ),
                    const SizedBox(width: 8),
                  ],
                  TextButton(
                    onPressed: () => _openStudyPlanDetail(studyPlan),
                    child: const Text('View Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(StudyPlanStatus status) {
    Color color;
    String label;

    switch (status) {
      case StudyPlanStatus.active:
        color = Colors.green;
        label = 'Active';
        break;
      case StudyPlanStatus.completed:
        color = Colors.blue;
        label = 'Completed';
        break;
      case StudyPlanStatus.paused:
        color = Colors.orange;
        label = 'Paused';
        break;
      case StudyPlanStatus.draft:
        color = Colors.grey;
        label = 'Draft';
        break;
      case StudyPlanStatus.cancelled:
        color = Colors.red;
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildProgressBar(StudyPlan studyPlan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${studyPlan.progressPercentage.round()}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: studyPlan.progressPercentage / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            studyPlan.isCompleted ? Colors.green : Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _createNewStudyPlan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateStudyPlanScreen(),
      ),
    );
  }

  void _openStudyPlanDetail(StudyPlan studyPlan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudyPlanDetailScreen(studyPlan: studyPlan),
      ),
    );
  }

  void _pauseStudyPlan(String planId) async {
    try {
      final success = await StudyPlanService.instance.pauseStudyPlan(planId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Study plan paused')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error pausing study plan: $e')),
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/study_plan.dart';
import '../../core/services/study_plan_service.dart';

class StudyPlanDetailScreen extends ConsumerStatefulWidget {
  final StudyPlan studyPlan;

  const StudyPlanDetailScreen({
    super.key,
    required this.studyPlan,
  });

  @override
  ConsumerState<StudyPlanDetailScreen> createState() => _StudyPlanDetailScreenState();
}

class _StudyPlanDetailScreenState extends ConsumerState<StudyPlanDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late StudyPlan _currentPlan;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentPlan = widget.studyPlan;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPlan.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              if (_currentPlan.status == StudyPlanStatus.draft)
                const PopupMenuItem(
                  value: 'start',
                  child: Text('Start Plan'),
                ),
              if (_currentPlan.isActive)
                const PopupMenuItem(
                  value: 'pause',
                  child: Text('Pause Plan'),
                ),
              if (_currentPlan.isPaused)
                const PopupMenuItem(
                  value: 'resume',
                  child: Text('Resume Plan'),
                ),
              if (!_currentPlan.isCompleted)
                const PopupMenuItem(
                  value: 'complete',
                  child: Text('Mark Complete'),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete Plan'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Milestones'),
            Tab(text: 'Schedule'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildMilestonesTab(),
          _buildScheduleTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildProgressCard(),
          const SizedBox(height: 16),
          _buildDetailsCard(),
          const SizedBox(height: 16),
          _buildTopicsCard(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(_currentPlan.status),
                  color: _getStatusColor(_currentPlan.status),
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(_currentPlan.status),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(_currentPlan.status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _currentPlan.description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoItem('Category', _currentPlan.category),
                const SizedBox(width: 24),
                _buildInfoItem('Type', _currentPlan.type.displayName),
                const SizedBox(width: 24),
                _buildInfoItem('Difficulty', _currentPlan.difficulty.name.toUpperCase()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_currentPlan.progressPercentage.round()}%',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const Text('Complete'),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: _currentPlan.progressPercentage / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _currentPlan.isCompleted ? Colors.green : Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_currentPlan.completedSessions}/${_currentPlan.totalSessions} sessions',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            '${_currentPlan.remainingDays} days left',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Duration', '${_currentPlan.estimatedDurationDays} days'),
            _buildDetailRow('Daily Time', '${_currentPlan.dailyTimeMinutes} minutes'),
            _buildDetailRow('Start Date', _formatDate(_currentPlan.startDate)),
            if (_currentPlan.endDate != null)
              _buildDetailRow('End Date', _formatDate(_currentPlan.endDate!)),
            if (_currentPlan.completedAt != null)
              _buildDetailRow('Completed', _formatDate(_currentPlan.completedAt!)),
            _buildDetailRow('Created', _formatDate(_currentPlan.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Topics (${_currentPlan.topics.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _currentPlan.topics.map((topic) => Chip(
                label: Text(topic),
                backgroundColor: Colors.blue[50],
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestonesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _currentPlan.milestones.length,
      itemBuilder: (context, index) {
        final milestone = _currentPlan.milestones[index];
        return _buildMilestoneCard(milestone, index);
      },
    );
  }

  Widget _buildMilestoneCard(StudyPlanMilestone milestone, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: milestone.isCompleted ? Colors.green : Colors.grey[300],
                  child: milestone.isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : Text('${index + 1}', style: const TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        milestone.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: milestone.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      Text(
                        milestone.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!milestone.isCompleted && _currentPlan.isActive)
                  TextButton(
                    onPressed: () => _completeMilestone(milestone.id),
                    child: const Text('Complete'),
                  ),
              ],
            ),
            if (milestone.requiredTopics.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Required Topics:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: milestone.requiredTopics.map((topic) => Chip(
                  label: Text(topic),
                  backgroundColor: Colors.orange[50],
                  labelStyle: const TextStyle(fontSize: 12),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleTab() {
    return const Center(
      child: Text('Schedule view coming soon!'),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  IconData _getStatusIcon(StudyPlanStatus status) {
    switch (status) {
      case StudyPlanStatus.active:
        return Icons.play_arrow;
      case StudyPlanStatus.completed:
        return Icons.check_circle;
      case StudyPlanStatus.paused:
        return Icons.pause;
      case StudyPlanStatus.draft:
        return Icons.edit;
      case StudyPlanStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getStatusColor(StudyPlanStatus status) {
    switch (status) {
      case StudyPlanStatus.active:
        return Colors.green;
      case StudyPlanStatus.completed:
        return Colors.blue;
      case StudyPlanStatus.paused:
        return Colors.orange;
      case StudyPlanStatus.draft:
        return Colors.grey;
      case StudyPlanStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(StudyPlanStatus status) {
    switch (status) {
      case StudyPlanStatus.active:
        return 'Active';
      case StudyPlanStatus.completed:
        return 'Completed';
      case StudyPlanStatus.paused:
        return 'Paused';
      case StudyPlanStatus.draft:
        return 'Draft';
      case StudyPlanStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleMenuAction(String action) async {
    switch (action) {
      case 'start':
        await _startPlan();
        break;
      case 'pause':
        await _pausePlan();
        break;
      case 'resume':
        await _resumePlan();
        break;
      case 'complete':
        await _completePlan();
        break;
      case 'delete':
        await _deletePlan();
        break;
    }
  }

  Future<void> _startPlan() async {
    try {
      final success = await StudyPlanService.instance.startStudyPlan(_currentPlan.id);
      if (success) {
        _refreshPlan();
        _showSnackBar('Study plan started!');
      }
    } catch (e) {
      _showSnackBar('Error starting plan: $e');
    }
  }

  Future<void> _pausePlan() async {
    try {
      final success = await StudyPlanService.instance.pauseStudyPlan(_currentPlan.id);
      if (success) {
        _refreshPlan();
        _showSnackBar('Study plan paused');
      }
    } catch (e) {
      _showSnackBar('Error pausing plan: $e');
    }
  }

  Future<void> _resumePlan() async {
    try {
      final success = await StudyPlanService.instance.startStudyPlan(_currentPlan.id);
      if (success) {
        _refreshPlan();
        _showSnackBar('Study plan resumed');
      }
    } catch (e) {
      _showSnackBar('Error resuming plan: $e');
    }
  }

  Future<void> _completePlan() async {
    try {
      final success = await StudyPlanService.instance.completeStudyPlan(_currentPlan.id);
      if (success) {
        _refreshPlan();
        _showSnackBar('Study plan completed! 🎉');
      }
    } catch (e) {
      _showSnackBar('Error completing plan: $e');
    }
  }

  Future<void> _deletePlan() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Study Plan'),
        content: const Text('Are you sure you want to delete this study plan? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await StudyPlanService.instance.deleteStudyPlan(_currentPlan.id);
        if (success && mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Study plan deleted')),
          );
        }
      } catch (e) {
        _showSnackBar('Error deleting plan: $e');
      }
    }
  }

  Future<void> _completeMilestone(String milestoneId) async {
    try {
      final success = await StudyPlanService.instance.completeMilestone(_currentPlan.id, milestoneId);
      if (success) {
        _refreshPlan();
        _showSnackBar('Milestone completed! 🎯');
      }
    } catch (e) {
      _showSnackBar('Error completing milestone: $e');
    }
  }

  Future<void> _refreshPlan() async {
    final updatedPlan = await StudyPlanService.instance.getStudyPlan(_currentPlan.id);
    if (updatedPlan != null) {
      setState(() {
        _currentPlan = updatedPlan;
      });
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}

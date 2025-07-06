import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/learning_category.dart';
import '../../core/services/learning_content_service.dart';
import '../auth/providers/auth_provider.dart';

// Topics provider for a category
final categoryTopicsProvider =
    FutureProvider.family<List<LearningTopic>, String>((ref, categoryId) {
  return LearningContentService.instance.getTopicsForCategory(categoryId);
});

// User progress provider for a category
final userCategoryProgressProvider = FutureProvider.family<
    List<UserTopicProgress>,
    ({String userId, String categoryId})>((ref, params) {
  return LearningContentService.instance
      .getUserCategoryProgress(params.userId, params.categoryId);
});

class CategoryDetailScreen extends ConsumerStatefulWidget {
  final LearningCategory category;

  const CategoryDetailScreen({
    super.key,
    required this.category,
  });

  @override
  ConsumerState<CategoryDetailScreen> createState() =>
      _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends ConsumerState<CategoryDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        Color(int.parse(widget.category.colorCode.replaceFirst('#', '0xFF')));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(color),
          SliverToBoxAdapter(
            child: _buildCategoryInfo(),
          ),
          SliverFillRemaining(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(Color color) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: color,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.category.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withValues(alpha: 0.7)],
            ),
          ),
          child: Center(
            child: Icon(
              _getIconData(widget.category.iconName),
              size: 80,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.category.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                Icons.topic,
                '${widget.category.topicCount} topics',
                Colors.blue,
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                Icons.schedule,
                '${widget.category.estimatedHours}h',
                Colors.green,
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                Icons.star,
                widget.category.averageRating.toStringAsFixed(1),
                Colors.amber,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.category.tags.isNotEmpty) ...[
            const Text(
              'Tags:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.category.tags
                  .map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Colors.grey[100],
                        labelStyle: const TextStyle(fontSize: 12),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Topics'),
            Tab(text: 'Progress'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTopicsTab(),
              _buildProgressTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopicsTab() {
    final topicsAsync = ref.watch(categoryTopicsProvider(widget.category.id));

    return topicsAsync.when(
      data: (topics) => _buildTopicsList(topics),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorWidget(error),
    );
  }

  Widget _buildProgressTab() {
    final authState = ref.watch(authProvider);

    if (authState.user == null) {
      return const Center(
        child: Text('Please log in to view your progress'),
      );
    }

    final progressAsync = ref.watch(userCategoryProgressProvider((
      userId: authState.user!.uid,
      categoryId: widget.category.id,
    )));

    return progressAsync.when(
      data: (progress) => _buildProgressList(progress),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorWidget(error),
    );
  }

  Widget _buildTopicsList(List<LearningTopic> topics) {
    if (topics.isEmpty) {
      return const Center(
        child: Text('No topics available yet'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        return _buildTopicCard(topics[index]);
      },
    );
  }

  Widget _buildTopicCard(LearningTopic topic) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openTopic(topic),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color:
                          _getTopicTypeColor(topic.type).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _getTopicTypeIcon(topic.type),
                      color: _getTopicTypeColor(topic.type),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          topic.description,
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
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTopicInfoChip(
                    Icons.schedule,
                    '${topic.estimatedMinutes} min',
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildTopicInfoChip(
                    Icons.trending_up,
                    topic.difficulty.displayName,
                    _getDifficultyColor(topic.difficulty),
                  ),
                  const SizedBox(width: 8),
                  _buildTopicInfoChip(
                    Icons.category,
                    topic.type.displayName,
                    _getTopicTypeColor(topic.type),
                  ),
                ],
              ),
              if (topic.learningObjectives.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Learning Objectives:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                ...topic.learningObjectives.take(2).map((objective) => Padding(
                      padding: const EdgeInsets.only(left: 8, top: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 12)),
                          Expanded(
                            child: Text(
                              objective,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    )),
                if (topic.learningObjectives.length > 2)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 2),
                    child: Text(
                      '... and ${topic.learningObjectives.length - 2} more',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressList(List<UserTopicProgress> progressList) {
    if (progressList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No progress yet'),
            SizedBox(height: 8),
            Text(
              'Start learning topics to track your progress',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: progressList.length,
      itemBuilder: (context, index) {
        return _buildProgressCard(progressList[index]);
      },
    );
  }

  Widget _buildProgressCard(UserTopicProgress progress) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getProgressStatusIcon(progress.status),
                  color: _getProgressStatusColor(progress.status),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Topic Progress', // TODO: Get topic name
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${progress.completionPercentage.round()}%',
                  style: TextStyle(
                    fontSize: 14,
                    color: _getProgressStatusColor(progress.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.completionPercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressStatusColor(progress.status),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Time spent: ${progress.timeSpentMinutes} min',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                Text(
                  'Last accessed: ${_formatDate(progress.lastAccessedAt)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
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
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 2),
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

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final _ = ref.refresh(categoryTopicsProvider(widget.category.id));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'code':
        return Icons.code;
      case 'analytics':
        return Icons.analytics;
      case 'palette':
        return Icons.palette;
      case 'business':
        return Icons.business;
      case 'language':
        return Icons.language;
      default:
        return Icons.category;
    }
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return Colors.green;
      case DifficultyLevel.intermediate:
        return Colors.orange;
      case DifficultyLevel.advanced:
        return Colors.red;
      case DifficultyLevel.expert:
        return Colors.purple;
    }
  }

  Color _getTopicTypeColor(TopicType type) {
    switch (type) {
      case TopicType.lesson:
        return Colors.blue;
      case TopicType.tutorial:
        return Colors.green;
      case TopicType.exercise:
        return Colors.orange;
      case TopicType.project:
        return Colors.purple;
      case TopicType.assessment:
        return Colors.red;
    }
  }

  IconData _getTopicTypeIcon(TopicType type) {
    switch (type) {
      case TopicType.lesson:
        return Icons.school;
      case TopicType.tutorial:
        return Icons.play_lesson;
      case TopicType.exercise:
        return Icons.fitness_center;
      case TopicType.project:
        return Icons.build;
      case TopicType.assessment:
        return Icons.quiz;
    }
  }

  IconData _getProgressStatusIcon(ProgressStatus status) {
    switch (status) {
      case ProgressStatus.notStarted:
        return Icons.radio_button_unchecked;
      case ProgressStatus.inProgress:
        return Icons.play_circle;
      case ProgressStatus.completed:
        return Icons.check_circle;
      case ProgressStatus.bookmarked:
        return Icons.bookmark;
    }
  }

  Color _getProgressStatusColor(ProgressStatus status) {
    switch (status) {
      case ProgressStatus.notStarted:
        return Colors.grey;
      case ProgressStatus.inProgress:
        return Colors.blue;
      case ProgressStatus.completed:
        return Colors.green;
      case ProgressStatus.bookmarked:
        return Colors.orange;
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

  void _openTopic(LearningTopic topic) {
    // TODO: Navigate to topic detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening topic: ${topic.name}')),
    );
  }
}

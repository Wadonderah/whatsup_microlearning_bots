import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/firestore_models.dart';

class RecentActivityCard extends StatelessWidget {
  final List<LearningSession> sessions;
  final VoidCallback? onViewAll;

  const RecentActivityCard({
    super.key,
    required this.sessions,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Activity',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Activity List
          if (sessions.isEmpty)
            _buildEmptyState(context)
          else
            Column(
              children: sessions
                  .take(5) // Show only first 5 sessions
                  .map((session) => _buildActivityItem(context, session))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No recent activity',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a learning session to see your activity here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, LearningSession session) {
    final theme = Theme.of(context);
    final timeAgo = _getTimeAgo(session.startTime);
    final duration = session.endTime != null
        ? session.endTime!.difference(session.startTime)
        : Duration.zero;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Activity Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  _getActivityColor(session.type.name).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getActivityIcon(session.type.name),
              color: _getActivityColor(session.type.name),
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // Activity Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getActivityTitle(session.type.name),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeAgo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    if (duration.inMinutes > 0) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${duration.inMinutes}m',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // XP Gained
          if (session.experienceGained > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.green,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+${session.experienceGained}',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  IconData _getActivityIcon(String sessionType) {
    switch (sessionType.toLowerCase()) {
      case 'general':
        return Icons.school_outlined;
      case 'quiz':
        return Icons.quiz_outlined;
      case 'explanation':
        return Icons.lightbulb_outlined;
      case 'practice':
        return Icons.fitness_center_outlined;
      case 'summary':
        return Icons.summarize_outlined;
      // Legacy support for old string values
      case 'chat':
        return Icons.chat_bubble_outline;
      case 'study':
        return Icons.school_outlined;
      default:
        return Icons.book_outlined;
    }
  }

  Color _getActivityColor(String sessionType) {
    switch (sessionType.toLowerCase()) {
      case 'general':
        return Colors.blue;
      case 'quiz':
        return Colors.orange;
      case 'explanation':
        return Colors.blue;
      case 'practice':
        return Colors.purple;
      case 'summary':
        return Colors.green;
      // Legacy support for old string values
      case 'chat':
        return Colors.blue;
      case 'study':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getActivityTitle(String sessionType) {
    switch (sessionType.toLowerCase()) {
      case 'general':
        return 'Learning Session';
      case 'quiz':
        return 'Quiz Completed';
      case 'explanation':
        return 'Explanation Session';
      case 'practice':
        return 'Practice Session';
      case 'summary':
        return 'Summary Session';
      // Legacy support for old string values
      case 'chat':
        return 'AI Chat Session';
      case 'study':
        return 'Study Session';
      default:
        return 'Learning Session';
    }
  }
}

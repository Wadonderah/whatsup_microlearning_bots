import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/notification_models.dart';
import 'providers/notification_provider.dart';

class NotificationListScreen extends ConsumerWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (notificationState.unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.mark_email_read),
              onPressed: () => ref.read(notificationProvider.notifier).markAllAsRead(),
              tooltip: 'Mark all as read',
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/notification-settings'),
            tooltip: 'Notification Settings',
          ),
        ],
      ),
      body: notificationState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificationState.notifications.isEmpty
              ? _buildEmptyState(context)
              : _buildNotificationList(context, ref, notificationState.notifications),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll see your learning reminders and updates here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/notification-settings'),
            icon: const Icon(Icons.settings),
            label: const Text('Notification Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(
    BuildContext context,
    WidgetRef ref,
    List<AppNotification> notifications,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _NotificationCard(
          notification: notification,
          onTap: () => _handleNotificationTap(context, ref, notification),
          onDismiss: () => ref.read(notificationProvider.notifier).removeNotification(notification.id),
        );
      },
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
  ) {
    // Mark as read
    if (!notification.isRead) {
      ref.read(notificationProvider.notifier).markAsRead(notification.id);
    }

    // Navigate based on notification type or action URL
    if (notification.actionUrl != null) {
      context.go(notification.actionUrl!);
    } else {
      switch (notification.type) {
        case NotificationType.learningReminder:
          context.go('/ai-assistant');
          break;
        case NotificationType.quizAvailable:
          context.go('/ai-assistant'); // Navigate to quiz when implemented
          break;
        case NotificationType.achievement:
          // Navigate to achievements when implemented
          break;
        case NotificationType.systemUpdate:
          context.go('/notification-settings');
          break;
        case NotificationType.general:
          // Stay on current screen or navigate to home
          break;
      }
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: notification.isRead ? 1 : 3,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notification icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getNotificationColor(notification.type).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          notification.type.icon,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Notification content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: notification.isRead 
                                        ? FontWeight.w500 
                                        : FontWeight.w600,
                                    color: notification.isRead 
                                        ? Colors.grey[700] 
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              if (!notification.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          
                          const SizedBox(height: 4),
                          
                          Text(
                            notification.body,
                            style: TextStyle(
                              fontSize: 14,
                              color: notification.isRead 
                                  ? Colors.grey[600] 
                                  : Colors.grey[700],
                              height: 1.3,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getNotificationColor(notification.type).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  notification.type.displayName,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _getNotificationColor(notification.type),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              
                              const Spacer(),
                              
                              Text(
                                _formatTimestamp(notification.timestamp),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Image if available
                if (notification.imageUrl != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      notification.imageUrl!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.image_not_supported),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.learningReminder:
        return Colors.blue;
      case NotificationType.quizAvailable:
        return Colors.orange;
      case NotificationType.achievement:
        return Colors.green;
      case NotificationType.systemUpdate:
        return Colors.purple;
      case NotificationType.general:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

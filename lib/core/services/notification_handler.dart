import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/notification_models.dart';
import 'notification_service.dart';

class NotificationHandler {
  static NotificationHandler? _instance;
  static NotificationHandler get instance =>
      _instance ??= NotificationHandler._();

  NotificationHandler._();

  final NotificationService _notificationService = NotificationService.instance;
  BuildContext? _context;

  /// Initialize notification handlers
  Future<void> initialize(BuildContext context) async {
    _context = context;

    // Handle notification when app is launched from terminated state
    await _handleInitialMessage();

    // Set up message handlers
    _setupMessageHandlers();
  }

  /// Handle initial message when app is launched from terminated state
  Future<void> _handleInitialMessage() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      debugPrint('App launched from notification: ${initialMessage.messageId}');
      _handleNotificationNavigation(initialMessage);
    }
  }

  /// Set up message handlers for different app states
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background messages (app in background, notification tapped)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
  }

  /// Handle foreground messages (app is active)
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground message received: ${message.messageId}');

    final notification = _createAppNotification(message);

    // Show in-app notification banner
    _showInAppNotification(notification);

    // Also show system notification if enabled
    await _notificationService.showLocalNotification(notification);
  }

  /// Handle background messages (app in background, notification tapped)
  void _handleBackgroundMessage(RemoteMessage message) {
    debugPrint('Background message opened: ${message.messageId}');

    _handleNotificationNavigation(message);
  }

  /// Handle notification navigation
  void _handleNotificationNavigation(RemoteMessage message) {
    if (_context == null) return;

    final notification = _createAppNotification(message);

    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.learningReminder:
        _navigateToLearning(notification);
        break;
      case NotificationType.quizAvailable:
        _navigateToQuiz(notification);
        break;
      case NotificationType.achievement:
        _navigateToAchievements(notification);
        break;
      case NotificationType.systemUpdate:
        _navigateToSettings(notification);
        break;
      case NotificationType.general:
        _navigateToHome(notification);
        break;
    }
  }

  /// Create AppNotification from RemoteMessage
  AppNotification _createAppNotification(RemoteMessage message) {
    return AppNotification(
      id: message.messageId ?? _generateId(),
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      imageUrl: message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl,
      data: message.data,
      timestamp: DateTime.now(),
      type: _getNotificationTypeFromData(message.data),
      priority: _getPriorityFromData(message.data),
      actionUrl: message.data['action_url'],
    );
  }

  /// Generate unique ID for notifications
  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return timestamp.toString();
  }

  /// Get notification type from message data
  NotificationType _getNotificationTypeFromData(Map<String, dynamic> data) {
    final typeString = data['type'] as String?;
    switch (typeString) {
      case 'learning_reminder':
        return NotificationType.learningReminder;
      case 'quiz_available':
        return NotificationType.quizAvailable;
      case 'achievement':
        return NotificationType.achievement;
      case 'system_update':
        return NotificationType.systemUpdate;
      default:
        return NotificationType.general;
    }
  }

  /// Get priority from message data
  NotificationPriority _getPriorityFromData(Map<String, dynamic> data) {
    final priorityString = data['priority'] as String?;
    switch (priorityString) {
      case 'low':
        return NotificationPriority.low;
      case 'high':
        return NotificationPriority.high;
      case 'urgent':
        return NotificationPriority.urgent;
      default:
        return NotificationPriority.normal;
    }
  }

  /// Show in-app notification banner
  void _showInAppNotification(AppNotification notification) {
    if (_context == null) return;

    ScaffoldMessenger.of(_context!).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  notification.type.icon,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    notification.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              notification.body,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: _getNotificationColor(notification.type),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () => _handleNotificationTap(notification),
        ),
      ),
    );
  }

  /// Get notification color based on type
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

  /// Handle notification tap
  void _handleNotificationTap(AppNotification notification) {
    switch (notification.type) {
      case NotificationType.learningReminder:
        _navigateToLearning(notification);
        break;
      case NotificationType.quizAvailable:
        _navigateToQuiz(notification);
        break;
      case NotificationType.achievement:
        _navigateToAchievements(notification);
        break;
      case NotificationType.systemUpdate:
        _navigateToSettings(notification);
        break;
      case NotificationType.general:
        _navigateToHome(notification);
        break;
    }
  }

  /// Navigation methods
  void _navigateToLearning(AppNotification notification) {
    if (_context == null) return;

    if (notification.actionUrl != null) {
      _context!.go(notification.actionUrl!);
    } else {
      _context!.go('/ai-assistant');
    }
  }

  void _navigateToQuiz(AppNotification notification) {
    if (_context == null) return;

    if (notification.actionUrl != null) {
      _context!.go(notification.actionUrl!);
    } else {
      // Navigate to quiz section (to be implemented)
      _context!.go('/ai-assistant');
    }
  }

  void _navigateToAchievements(AppNotification notification) {
    if (_context == null) return;

    if (notification.actionUrl != null) {
      _context!.go(notification.actionUrl!);
    } else {
      // Navigate to achievements section (to be implemented)
      _context!.go('/home');
    }
  }

  void _navigateToSettings(AppNotification notification) {
    if (_context == null) return;

    if (notification.actionUrl != null) {
      _context!.go(notification.actionUrl!);
    } else {
      _context!.go('/settings');
    }
  }

  void _navigateToHome(AppNotification notification) {
    if (_context == null) return;

    _context!.go('/home');
  }

  /// Schedule learning reminder notifications
  Future<void> scheduleLearningReminders() async {
    final settings = _notificationService.settings;

    if (!settings.learningRemindersEnabled) return;

    // Cancel existing reminders
    await _notificationService.cancelAllNotifications();

    // Schedule new reminders based on settings
    final reminderTime = _parseTime(settings.reminderTime);

    for (int day in settings.reminderDays) {
      final nextReminderDate = _getNextReminderDate(day, reminderTime);

      final notification = AppNotification.learningReminder(
        title: '📚 Time to Learn!',
        body: 'Ready for your daily microlearning session?',
        actionUrl: '/ai-assistant',
      );

      await _notificationService.scheduleNotification(
        notification: notification,
        scheduledDate: nextReminderDate,
      );
    }
  }

  /// Parse time string to TimeOfDay
  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  /// Get next reminder date for a specific day
  DateTime _getNextReminderDate(int weekday, TimeOfDay time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Find next occurrence of the weekday
    int daysUntilWeekday = (weekday - now.weekday) % 7;
    if (daysUntilWeekday == 0) {
      // If it's today, check if the time has passed
      final todayAtTime =
          DateTime(now.year, now.month, now.day, time.hour, time.minute);
      if (todayAtTime.isBefore(now)) {
        daysUntilWeekday = 7; // Schedule for next week
      }
    }

    final targetDate = today.add(Duration(days: daysUntilWeekday));
    return DateTime(targetDate.year, targetDate.month, targetDate.day,
        time.hour, time.minute);
  }

  /// Send test notification
  Future<void> sendTestNotification() async {
    final notification = AppNotificationGeneral.general(
      title: 'Test Notification',
      body: 'This is a test notification from WhatsApp MicroLearning Bot!',
    );

    await _notificationService.showLocalNotification(notification);
  }
}

extension AppNotificationGeneral on AppNotification {
  /// Create a general notification
  static AppNotification general({
    required String title,
    required String body,
    String? actionUrl,
  }) {
    return AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: NotificationType.general,
      priority: NotificationPriority.normal,
      actionUrl: actionUrl,
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/notification_models.dart';
import '../../../core/services/notification_service.dart';

// State class for notifications
class NotificationState {
  final NotificationSettings settings;
  final bool isPermissionGranted;
  final String? fcmToken;
  final List<AppNotification> notifications;
  final bool isLoading;
  final String? error;

  const NotificationState({
    this.settings = const NotificationSettings(),
    this.isPermissionGranted = false,
    this.fcmToken,
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    NotificationSettings? settings,
    bool? isPermissionGranted,
    String? fcmToken,
    List<AppNotification>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      settings: settings ?? this.settings,
      isPermissionGranted: isPermissionGranted ?? this.isPermissionGranted,
      fcmToken: fcmToken ?? this.fcmToken,
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasError => error != null;
  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

// Notification Provider
class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(const NotificationState()) {
    _initialize();
  }

  final NotificationService _notificationService = NotificationService.instance;

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      // Initialize notification service
      await _notificationService.initialize();

      // Load current settings
      final settings = _notificationService.settings;

      // Check permission status
      final isPermissionGranted =
          await _notificationService.areNotificationsEnabled();

      // Get FCM token
      final fcmToken = _notificationService.fcmToken;

      state = state.copyWith(
        settings: settings,
        isPermissionGranted: isPermissionGranted,
        fcmToken: fcmToken,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Request notification permission
  Future<void> requestPermission() async {
    try {
      // Re-initialize to check permissions
      await _notificationService.initialize();

      final isPermissionGranted =
          await _notificationService.areNotificationsEnabled();

      state = state.copyWith(
        isPermissionGranted: isPermissionGranted,
        error: null,
      );

      if (!isPermissionGranted) {
        state = state.copyWith(
          error:
              'Notification permission denied. Please enable in device settings.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to request permission: ${e.toString()}',
      );
    }
  }

  /// Update notification settings
  Future<void> updateSettings(NotificationSettings settings) async {
    try {
      await _notificationService.saveSettings(settings);

      state = state.copyWith(
        settings: settings,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update settings: ${e.toString()}',
      );
    }
  }

  /// Add notification to the list
  void addNotification(AppNotification notification) {
    final updatedNotifications = [notification, ...state.notifications];

    state = state.copyWith(
      notifications: updatedNotifications,
    );
  }

  /// Mark notification as read
  void markAsRead(String notificationId) {
    final updatedNotifications = state.notifications.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();

    state = state.copyWith(
      notifications: updatedNotifications,
    );
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    final updatedNotifications = state.notifications.map((notification) {
      return notification.copyWith(isRead: true);
    }).toList();

    state = state.copyWith(
      notifications: updatedNotifications,
    );
  }

  /// Remove notification
  void removeNotification(String notificationId) {
    final updatedNotifications = state.notifications
        .where((notification) => notification.id != notificationId)
        .toList();

    state = state.copyWith(
      notifications: updatedNotifications,
    );
  }

  /// Clear all notifications
  void clearAllNotifications() {
    state = state.copyWith(
      notifications: [],
    );
  }

  /// Schedule learning reminder
  Future<void> scheduleLearningReminder({
    required DateTime scheduledDate,
    required String title,
    required String body,
  }) async {
    try {
      final notification = AppNotification.learningReminder(
        title: title,
        body: body,
        actionUrl: '/ai-assistant',
      );

      await _notificationService.scheduleNotification(
        notification: notification,
        scheduledDate: scheduledDate,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to schedule reminder: ${e.toString()}',
      );
    }
  }

  /// Send test notification
  Future<void> sendTestNotification() async {
    try {
      final notification = AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '🧪 Test Notification',
        body: 'This is a test notification from WhatsApp MicroLearning Bot!',
        timestamp: DateTime.now(),
        type: NotificationType.general,
        priority: NotificationPriority.normal,
      );

      await _notificationService.showLocalNotification(notification);

      // Also add to the notification list
      addNotification(notification);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to send test notification: ${e.toString()}',
      );
    }
  }

  /// Get notifications by type
  List<AppNotification> getNotificationsByType(NotificationType type) {
    return state.notifications
        .where((notification) => notification.type == type)
        .toList();
  }

  /// Get unread notifications
  List<AppNotification> getUnreadNotifications() {
    return state.notifications
        .where((notification) => !notification.isRead)
        .toList();
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllScheduledNotifications() async {
    try {
      await _notificationService.cancelAllNotifications();
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to cancel notifications: ${e.toString()}',
      );
    }
  }

  /// Refresh FCM token
  Future<void> refreshFCMToken() async {
    try {
      // Re-initialize to get fresh token
      await _notificationService.initialize();

      final fcmToken = _notificationService.fcmToken;

      state = state.copyWith(
        fcmToken: fcmToken,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to refresh FCM token: ${e.toString()}',
      );
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider definition
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});

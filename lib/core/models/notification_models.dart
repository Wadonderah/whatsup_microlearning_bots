import 'package:json_annotation/json_annotation.dart';

part 'notification_models.g.dart';

@JsonSerializable()
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final NotificationType type;
  final NotificationPriority priority;
  final bool isRead;
  final String? actionUrl;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.data,
    required this.timestamp,
    required this.type,
    this.priority = NotificationPriority.normal,
    this.isRead = false,
    this.actionUrl,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => 
      _$AppNotificationFromJson(json);
  
  Map<String, dynamic> toJson() => _$AppNotificationToJson(this);

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    String? imageUrl,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    NotificationType? type,
    NotificationPriority? priority,
    bool? isRead,
    String? actionUrl,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  // Factory constructors for different notification types
  factory AppNotification.learningReminder({
    required String title,
    required String body,
    String? actionUrl,
  }) {
    return AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: NotificationType.learningReminder,
      priority: NotificationPriority.normal,
      actionUrl: actionUrl,
    );
  }

  factory AppNotification.quizAvailable({
    required String title,
    required String body,
    String? actionUrl,
  }) {
    return AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: NotificationType.quizAvailable,
      priority: NotificationPriority.high,
      actionUrl: actionUrl,
    );
  }

  factory AppNotification.achievementUnlocked({
    required String title,
    required String body,
    String? imageUrl,
  }) {
    return AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
      type: NotificationType.achievement,
      priority: NotificationPriority.high,
    );
  }
}

enum NotificationType {
  @JsonValue('learning_reminder')
  learningReminder,
  @JsonValue('quiz_available')
  quizAvailable,
  @JsonValue('achievement')
  achievement,
  @JsonValue('system_update')
  systemUpdate,
  @JsonValue('general')
  general,
}

enum NotificationPriority {
  @JsonValue('low')
  low,
  @JsonValue('normal')
  normal,
  @JsonValue('high')
  high,
  @JsonValue('urgent')
  urgent,
}

@JsonSerializable()
class NotificationSettings {
  final bool pushNotificationsEnabled;
  final bool learningRemindersEnabled;
  final bool quizNotificationsEnabled;
  final bool achievementNotificationsEnabled;
  final bool systemNotificationsEnabled;
  final String reminderTime; // Format: "HH:mm"
  final List<int> reminderDays; // 1-7 (Monday-Sunday)
  final bool soundEnabled;
  final bool vibrationEnabled;

  const NotificationSettings({
    this.pushNotificationsEnabled = true,
    this.learningRemindersEnabled = true,
    this.quizNotificationsEnabled = true,
    this.achievementNotificationsEnabled = true,
    this.systemNotificationsEnabled = true,
    this.reminderTime = "09:00",
    this.reminderDays = const [1, 2, 3, 4, 5], // Weekdays
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) => 
      _$NotificationSettingsFromJson(json);
  
  Map<String, dynamic> toJson() => _$NotificationSettingsToJson(this);

  NotificationSettings copyWith({
    bool? pushNotificationsEnabled,
    bool? learningRemindersEnabled,
    bool? quizNotificationsEnabled,
    bool? achievementNotificationsEnabled,
    bool? systemNotificationsEnabled,
    String? reminderTime,
    List<int>? reminderDays,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationSettings(
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      learningRemindersEnabled: learningRemindersEnabled ?? this.learningRemindersEnabled,
      quizNotificationsEnabled: quizNotificationsEnabled ?? this.quizNotificationsEnabled,
      achievementNotificationsEnabled: achievementNotificationsEnabled ?? this.achievementNotificationsEnabled,
      systemNotificationsEnabled: systemNotificationsEnabled ?? this.systemNotificationsEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderDays: reminderDays ?? this.reminderDays,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.learningReminder:
        return 'Learning Reminder';
      case NotificationType.quizAvailable:
        return 'Quiz Available';
      case NotificationType.achievement:
        return 'Achievement';
      case NotificationType.systemUpdate:
        return 'System Update';
      case NotificationType.general:
        return 'General';
    }
  }

  String get icon {
    switch (this) {
      case NotificationType.learningReminder:
        return '📚';
      case NotificationType.quizAvailable:
        return '❓';
      case NotificationType.achievement:
        return '🏆';
      case NotificationType.systemUpdate:
        return '🔄';
      case NotificationType.general:
        return '📢';
    }
  }
}

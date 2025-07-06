// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      imageUrl: json['imageUrl'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      priority: $enumDecodeNullable(
              _$NotificationPriorityEnumMap, json['priority']) ??
          NotificationPriority.normal,
      isRead: json['isRead'] as bool? ?? false,
      actionUrl: json['actionUrl'] as String?,
    );

Map<String, dynamic> _$AppNotificationToJson(AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'imageUrl': instance.imageUrl,
      'data': instance.data,
      'timestamp': instance.timestamp.toIso8601String(),
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'priority': _$NotificationPriorityEnumMap[instance.priority]!,
      'isRead': instance.isRead,
      'actionUrl': instance.actionUrl,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.learningReminder: 'learning_reminder',
  NotificationType.quizAvailable: 'quiz_available',
  NotificationType.achievement: 'achievement',
  NotificationType.systemUpdate: 'system_update',
  NotificationType.general: 'general',
};

const _$NotificationPriorityEnumMap = {
  NotificationPriority.low: 'low',
  NotificationPriority.normal: 'normal',
  NotificationPriority.high: 'high',
  NotificationPriority.urgent: 'urgent',
};

NotificationSettings _$NotificationSettingsFromJson(
        Map<String, dynamic> json) =>
    NotificationSettings(
      pushNotificationsEnabled:
          json['pushNotificationsEnabled'] as bool? ?? true,
      learningRemindersEnabled:
          json['learningRemindersEnabled'] as bool? ?? true,
      quizNotificationsEnabled:
          json['quizNotificationsEnabled'] as bool? ?? true,
      achievementNotificationsEnabled:
          json['achievementNotificationsEnabled'] as bool? ?? true,
      systemNotificationsEnabled:
          json['systemNotificationsEnabled'] as bool? ?? true,
      reminderTime: json['reminderTime'] as String? ?? "09:00",
      reminderDays: (json['reminderDays'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [1, 2, 3, 4, 5],
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
    );

Map<String, dynamic> _$NotificationSettingsToJson(
        NotificationSettings instance) =>
    <String, dynamic>{
      'pushNotificationsEnabled': instance.pushNotificationsEnabled,
      'learningRemindersEnabled': instance.learningRemindersEnabled,
      'quizNotificationsEnabled': instance.quizNotificationsEnabled,
      'achievementNotificationsEnabled':
          instance.achievementNotificationsEnabled,
      'systemNotificationsEnabled': instance.systemNotificationsEnabled,
      'reminderTime': instance.reminderTime,
      'reminderDays': instance.reminderDays,
      'soundEnabled': instance.soundEnabled,
      'vibrationEnabled': instance.vibrationEnabled,
    };

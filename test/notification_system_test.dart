import 'package:flutter_test/flutter_test.dart';
import 'package:whatsup_microlearning_bots/core/models/notification_models.dart';

void main() {
  group('Notification System Tests', () {
    group('AppNotification', () {
      test('should create notification with required fields', () {
        final notification = AppNotification(
          id: 'test-id',
          title: 'Test Title',
          body: 'Test Body',
          timestamp: DateTime.now(),
          type: NotificationType.general,
        );

        expect(notification.id, equals('test-id'));
        expect(notification.title, equals('Test Title'));
        expect(notification.body, equals('Test Body'));
        expect(notification.type, equals(NotificationType.general));
        expect(notification.priority, equals(NotificationPriority.normal));
        expect(notification.isRead, isFalse);
      });

      test('should create learning reminder notification', () {
        final notification = AppNotification.learningReminder(
          title: 'Time to Learn!',
          body: 'Your daily learning session awaits',
          actionUrl: '/ai-assistant',
        );

        expect(notification.title, equals('Time to Learn!'));
        expect(notification.body, equals('Your daily learning session awaits'));
        expect(notification.type, equals(NotificationType.learningReminder));
        expect(notification.priority, equals(NotificationPriority.normal));
        expect(notification.actionUrl, equals('/ai-assistant'));
      });

      test('should create quiz available notification', () {
        final notification = AppNotification.quizAvailable(
          title: 'New Quiz Available!',
          body: 'Test your knowledge with our latest quiz',
        );

        expect(notification.title, equals('New Quiz Available!'));
        expect(notification.type, equals(NotificationType.quizAvailable));
        expect(notification.priority, equals(NotificationPriority.high));
      });

      test('should create achievement notification', () {
        final notification = AppNotification.achievementUnlocked(
          title: 'Achievement Unlocked!',
          body: 'You completed 10 lessons this week',
          imageUrl: 'https://example.com/badge.png',
        );

        expect(notification.title, equals('Achievement Unlocked!'));
        expect(notification.type, equals(NotificationType.achievement));
        expect(notification.priority, equals(NotificationPriority.high));
        expect(notification.imageUrl, equals('https://example.com/badge.png'));
      });

      test('should copy notification with new values', () {
        final original = AppNotification(
          id: 'test-id',
          title: 'Original Title',
          body: 'Original Body',
          timestamp: DateTime.now(),
          type: NotificationType.general,
          isRead: false,
        );

        final updated = original.copyWith(
          title: 'Updated Title',
          isRead: true,
        );

        expect(updated.id, equals(original.id));
        expect(updated.title, equals('Updated Title'));
        expect(updated.body, equals(original.body));
        expect(updated.isRead, isTrue);
      });

      test('should serialize to and from JSON', () {
        final notification = AppNotification(
          id: 'test-id',
          title: 'Test Title',
          body: 'Test Body',
          timestamp: DateTime.parse('2024-01-01T12:00:00Z'),
          type: NotificationType.learningReminder,
          priority: NotificationPriority.high,
          isRead: true,
          actionUrl: '/test',
        );

        final json = notification.toJson();
        final fromJson = AppNotification.fromJson(json);

        expect(fromJson.id, equals(notification.id));
        expect(fromJson.title, equals(notification.title));
        expect(fromJson.body, equals(notification.body));
        expect(fromJson.timestamp, equals(notification.timestamp));
        expect(fromJson.type, equals(notification.type));
        expect(fromJson.priority, equals(notification.priority));
        expect(fromJson.isRead, equals(notification.isRead));
        expect(fromJson.actionUrl, equals(notification.actionUrl));
      });
    });

    group('NotificationSettings', () {
      test('should create default settings', () {
        const settings = NotificationSettings();

        expect(settings.pushNotificationsEnabled, isTrue);
        expect(settings.learningRemindersEnabled, isTrue);
        expect(settings.quizNotificationsEnabled, isTrue);
        expect(settings.achievementNotificationsEnabled, isTrue);
        expect(settings.systemNotificationsEnabled, isTrue);
        expect(settings.reminderTime, equals('09:00'));
        expect(settings.reminderDays, equals([1, 2, 3, 4, 5])); // Weekdays
        expect(settings.soundEnabled, isTrue);
        expect(settings.vibrationEnabled, isTrue);
      });

      test('should copy settings with new values', () {
        const original = NotificationSettings();

        final updated = original.copyWith(
          pushNotificationsEnabled: false,
          reminderTime: '18:00',
          reminderDays: [6, 7], // Weekends
        );

        expect(updated.pushNotificationsEnabled, isFalse);
        expect(updated.reminderTime, equals('18:00'));
        expect(updated.reminderDays, equals([6, 7]));
        expect(updated.learningRemindersEnabled, equals(original.learningRemindersEnabled));
      });

      test('should serialize to and from JSON', () {
        const settings = NotificationSettings(
          pushNotificationsEnabled: false,
          reminderTime: '20:30',
          reminderDays: [1, 3, 5],
          soundEnabled: false,
        );

        final json = settings.toJson();
        final fromJson = NotificationSettings.fromJson(json);

        expect(fromJson.pushNotificationsEnabled, equals(settings.pushNotificationsEnabled));
        expect(fromJson.reminderTime, equals(settings.reminderTime));
        expect(fromJson.reminderDays, equals(settings.reminderDays));
        expect(fromJson.soundEnabled, equals(settings.soundEnabled));
      });
    });

    group('NotificationType Extension', () {
      test('should return correct display names', () {
        expect(NotificationType.learningReminder.displayName, equals('Learning Reminder'));
        expect(NotificationType.quizAvailable.displayName, equals('Quiz Available'));
        expect(NotificationType.achievement.displayName, equals('Achievement'));
        expect(NotificationType.systemUpdate.displayName, equals('System Update'));
        expect(NotificationType.general.displayName, equals('General'));
      });

      test('should return correct icons', () {
        expect(NotificationType.learningReminder.icon, equals('📚'));
        expect(NotificationType.quizAvailable.icon, equals('❓'));
        expect(NotificationType.achievement.icon, equals('🏆'));
        expect(NotificationType.systemUpdate.icon, equals('🔄'));
        expect(NotificationType.general.icon, equals('📢'));
      });
    });

    group('Notification Priority', () {
      test('should handle different priority levels', () {
        final lowPriority = AppNotification(
          id: 'low',
          title: 'Low Priority',
          body: 'This is low priority',
          timestamp: DateTime.now(),
          type: NotificationType.general,
          priority: NotificationPriority.low,
        );

        final highPriority = AppNotification(
          id: 'high',
          title: 'High Priority',
          body: 'This is high priority',
          timestamp: DateTime.now(),
          type: NotificationType.achievement,
          priority: NotificationPriority.high,
        );

        final urgentPriority = AppNotification(
          id: 'urgent',
          title: 'Urgent',
          body: 'This is urgent',
          timestamp: DateTime.now(),
          type: NotificationType.systemUpdate,
          priority: NotificationPriority.urgent,
        );

        expect(lowPriority.priority, equals(NotificationPriority.low));
        expect(highPriority.priority, equals(NotificationPriority.high));
        expect(urgentPriority.priority, equals(NotificationPriority.urgent));
      });
    });

    group('Notification Data Handling', () {
      test('should handle custom data payload', () {
        final notification = AppNotification(
          id: 'test',
          title: 'Test',
          body: 'Test body',
          timestamp: DateTime.now(),
          type: NotificationType.general,
          data: {
            'custom_field': 'custom_value',
            'lesson_id': '123',
            'user_id': '456',
          },
        );

        expect(notification.data, isNotNull);
        expect(notification.data!['custom_field'], equals('custom_value'));
        expect(notification.data!['lesson_id'], equals('123'));
        expect(notification.data!['user_id'], equals('456'));
      });

      test('should handle image URLs', () {
        final notification = AppNotification(
          id: 'test',
          title: 'Test',
          body: 'Test body',
          timestamp: DateTime.now(),
          type: NotificationType.achievement,
          imageUrl: 'https://example.com/achievement.png',
        );

        expect(notification.imageUrl, equals('https://example.com/achievement.png'));
      });

      test('should handle action URLs', () {
        final notification = AppNotification(
          id: 'test',
          title: 'Test',
          body: 'Test body',
          timestamp: DateTime.now(),
          type: NotificationType.learningReminder,
          actionUrl: '/ai-assistant?lesson=123',
        );

        expect(notification.actionUrl, equals('/ai-assistant?lesson=123'));
      });
    });
  });
}

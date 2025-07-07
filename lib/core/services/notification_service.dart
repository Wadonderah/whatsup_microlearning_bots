import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart'
    hide NotificationSettings;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_models.dart';

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance =>
      _instance ??= NotificationService._();

  NotificationService._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _notificationChannelId = 'microlearning_channel';
  static const String _notificationChannelName = 'MicroLearning Notifications';
  static const String _notificationChannelDescription =
      'Notifications for learning reminders and updates';

  bool _isInitialized = false;
  String? _fcmToken;
  NotificationSettings _settings = const NotificationSettings();

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize local notifications (mobile only)
      if (!kIsWeb) {
        await _initializeLocalNotifications();
      }

      // Initialize Firebase messaging
      await _initializeFirebaseMessaging();

      // Load settings
      await _loadSettings();

      _isInitialized = true;
      debugPrint('NotificationService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@drawable/app_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // Windows-specific settings
    const windowsSettings = WindowsInitializationSettings(
      appName: 'WhatsApp MicroLearning Bot',
      appUserModelId: 'com.example.whatsup_microlearning_bots',
      guid: 'a7a9f7b8-4c3d-4e5f-9a8b-1c2d3e4f5a6b',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      windows: windowsSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      await _createNotificationChannel();
    }
  }

  /// Create notification channel for Android
  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      _notificationChannelId,
      _notificationChannelName,
      description: _notificationChannelDescription,
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Initialize Firebase messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Request permission
    await _requestNotificationPermissions();

    // Get FCM token
    _fcmToken = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $_fcmToken');

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      debugPrint('FCM Token refreshed: $token');
      // TODO: Send token to your backend server
    });

    // Configure message handlers
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  /// Request notification permissions
  Future<bool> _requestNotificationPermissions() async {
    if (kIsWeb) {
      // For web, request permission through Firebase Messaging
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } else if (Platform.isIOS) {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } else {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');

    final notification = _createNotificationFromRemoteMessage(message);
    showLocalNotification(notification);
  }

  /// Handle messages when app is opened from notification
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('App opened from notification: ${message.messageId}');

    final notification = _createNotificationFromRemoteMessage(message);
    _handleNotificationAction(notification);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.id}');

    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        final notification = AppNotification.fromJson(data);
        _handleNotificationAction(notification);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  /// Handle notification action
  void _handleNotificationAction(AppNotification notification) {
    // TODO: Navigate to appropriate screen based on notification type
    debugPrint('Handling notification action: ${notification.type}');

    if (notification.actionUrl != null) {
      // Navigate to specific URL/route
      debugPrint('Navigate to: ${notification.actionUrl}');
    }
  }

  /// Create AppNotification from RemoteMessage
  AppNotification _createNotificationFromRemoteMessage(RemoteMessage message) {
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

  /// Show local notification
  Future<void> showLocalNotification(AppNotification notification) async {
    if (!_settings.pushNotificationsEnabled) return;

    final androidDetails = AndroidNotificationDetails(
      _notificationChannelId,
      _notificationChannelName,
      channelDescription: _notificationChannelDescription,
      importance: _getAndroidImportance(notification.priority),
      priority: _getAndroidPriority(notification.priority),
      enableVibration: _settings.vibrationEnabled,
      playSound: _settings.soundEnabled,
      // largeIcon: notification.imageUrl != null
      //     ? AndroidBitmap.fromBase64String(notification.imageUrl!)
      //     : null,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.id.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(notification.toJson()),
    );
  }

  /// Get Android importance from priority
  Importance _getAndroidImportance(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Importance.low;
      case NotificationPriority.high:
      case NotificationPriority.urgent:
        return Importance.high;
      default:
        return Importance.defaultImportance;
    }
  }

  /// Get Android priority from priority
  Priority _getAndroidPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Priority.low;
      case NotificationPriority.high:
      case NotificationPriority.urgent:
        return Priority.high;
      default:
        return Priority.defaultPriority;
    }
  }

  /// Load notification settings
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('notification_settings');

      if (settingsJson != null) {
        final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
        _settings = NotificationSettings.fromJson(settingsMap);
      }
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    }
  }

  /// Save notification settings
  Future<void> saveSettings(NotificationSettings settings) async {
    try {
      _settings = settings;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'notification_settings', jsonEncode(settings.toJson()));
    } catch (e) {
      debugPrint('Error saving notification settings: $e');
    }
  }

  /// Get current settings
  NotificationSettings get settings => _settings;

  /// Get FCM token
  String? get fcmToken => _fcmToken;

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isIOS) {
      final settings = await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } else {
      return await Permission.notification.isGranted;
    }
  }

  /// Schedule local notification
  Future<void> scheduleNotification({
    required AppNotification notification,
    required DateTime scheduledDate,
  }) async {
    if (!_settings.pushNotificationsEnabled) return;

    final androidDetails = AndroidNotificationDetails(
      _notificationChannelId,
      _notificationChannelName,
      channelDescription: _notificationChannelDescription,
      importance: _getAndroidImportance(notification.priority),
      priority: _getAndroidPriority(notification.priority),
      enableVibration: _settings.vibrationEnabled,
      playSound: _settings.soundEnabled,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // For now, show immediately. TODO: Implement proper scheduling with timezone support
    await _localNotifications.show(
      notification.id.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(notification.toJson()),
    );
  }

  /// Cancel scheduled notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
  // Handle background message processing here
}

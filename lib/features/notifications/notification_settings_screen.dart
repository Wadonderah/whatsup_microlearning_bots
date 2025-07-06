import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/notification_models.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/notification_handler.dart';
import 'providers/notification_provider.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  late NotificationSettings _settings;
  final NotificationService _notificationService = NotificationService.instance;
  final NotificationHandler _notificationHandler = NotificationHandler.instance;

  @override
  void initState() {
    super.initState();
    _settings = _notificationService.settings;
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: _sendTestNotification,
            tooltip: 'Send Test Notification',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Push Notifications Section
          _buildSectionHeader('Push Notifications'),
          _buildSwitchTile(
            title: 'Enable Push Notifications',
            subtitle: 'Receive notifications from the app',
            value: _settings.pushNotificationsEnabled,
            onChanged: (value) => _updateSettings(
              _settings.copyWith(pushNotificationsEnabled: value),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Notification Types Section
          _buildSectionHeader('Notification Types'),
          _buildSwitchTile(
            title: 'Learning Reminders',
            subtitle: 'Daily reminders to continue learning',
            value: _settings.learningRemindersEnabled,
            onChanged: _settings.pushNotificationsEnabled
                ? (value) => _updateSettings(
                      _settings.copyWith(learningRemindersEnabled: value),
                    )
                : null,
            icon: Icons.school,
          ),
          _buildSwitchTile(
            title: 'Quiz Notifications',
            subtitle: 'Alerts when new quizzes are available',
            value: _settings.quizNotificationsEnabled,
            onChanged: _settings.pushNotificationsEnabled
                ? (value) => _updateSettings(
                      _settings.copyWith(quizNotificationsEnabled: value),
                    )
                : null,
            icon: Icons.quiz,
          ),
          _buildSwitchTile(
            title: 'Achievement Notifications',
            subtitle: 'Celebrate your learning milestones',
            value: _settings.achievementNotificationsEnabled,
            onChanged: _settings.pushNotificationsEnabled
                ? (value) => _updateSettings(
                      _settings.copyWith(achievementNotificationsEnabled: value),
                    )
                : null,
            icon: Icons.emoji_events,
          ),
          _buildSwitchTile(
            title: 'System Notifications',
            subtitle: 'App updates and important announcements',
            value: _settings.systemNotificationsEnabled,
            onChanged: _settings.pushNotificationsEnabled
                ? (value) => _updateSettings(
                      _settings.copyWith(systemNotificationsEnabled: value),
                    )
                : null,
            icon: Icons.system_update,
          ),

          const SizedBox(height: 24),

          // Reminder Schedule Section
          if (_settings.learningRemindersEnabled) ...[
            _buildSectionHeader('Reminder Schedule'),
            _buildTimeTile(),
            _buildDaysTile(),
            const SizedBox(height: 24),
          ],

          // Sound & Vibration Section
          _buildSectionHeader('Sound & Vibration'),
          _buildSwitchTile(
            title: 'Sound',
            subtitle: 'Play sound for notifications',
            value: _settings.soundEnabled,
            onChanged: _settings.pushNotificationsEnabled
                ? (value) => _updateSettings(
                      _settings.copyWith(soundEnabled: value),
                    )
                : null,
            icon: Icons.volume_up,
          ),
          _buildSwitchTile(
            title: 'Vibration',
            subtitle: 'Vibrate for notifications',
            value: _settings.vibrationEnabled,
            onChanged: _settings.pushNotificationsEnabled
                ? (value) => _updateSettings(
                      _settings.copyWith(vibrationEnabled: value),
                    )
                : null,
            icon: Icons.vibration,
          ),

          const SizedBox(height: 24),

          // Status Section
          _buildSectionHeader('Status'),
          _buildStatusCard(notificationState),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    IconData? icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        secondary: icon != null ? Icon(icon) : null,
        activeColor: Colors.blue,
      ),
    );
  }

  Widget _buildTimeTile() {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.access_time),
        title: const Text('Reminder Time'),
        subtitle: Text('Daily reminder at ${_settings.reminderTime}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: _selectReminderTime,
      ),
    );
  }

  Widget _buildDaysTile() {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final selectedDays = _settings.reminderDays
        .map((day) => dayNames[day - 1])
        .join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: const Text('Reminder Days'),
        subtitle: Text(selectedDays),
        trailing: const Icon(Icons.chevron_right),
        onTap: _selectReminderDays,
      ),
    );
  }

  Widget _buildStatusCard(NotificationState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  state.isPermissionGranted ? Icons.check_circle : Icons.error,
                  color: state.isPermissionGranted ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  state.isPermissionGranted 
                      ? 'Notifications Enabled' 
                      : 'Notifications Disabled',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (state.fcmToken != null) ...[
              const Text('FCM Token:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(
                '${state.fcmToken!.substring(0, 20)}...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontFamily: 'monospace',
                ),
              ),
            ],
            if (!state.isPermissionGranted) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _requestPermission,
                child: const Text('Enable Notifications'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _updateSettings(NotificationSettings newSettings) {
    setState(() {
      _settings = newSettings;
    });
    
    _notificationService.saveSettings(newSettings);
    ref.read(notificationProvider.notifier).updateSettings(newSettings);
    
    // Reschedule reminders if learning reminders are enabled
    if (newSettings.learningRemindersEnabled) {
      _notificationHandler.scheduleLearningReminders();
    }
  }

  void _selectReminderTime() async {
    final currentTime = _parseTime(_settings.reminderTime);
    
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );

    if (selectedTime != null) {
      final timeString = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
      _updateSettings(_settings.copyWith(reminderTime: timeString));
    }
  }

  void _selectReminderDays() async {
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final selectedDays = List<bool>.generate(7, (index) => _settings.reminderDays.contains(index + 1));

    final result = await showDialog<List<bool>>(
      context: context,
      builder: (context) => _DaySelectionDialog(
        dayNames: dayNames,
        selectedDays: selectedDays,
      ),
    );

    if (result != null) {
      final newReminderDays = <int>[];
      for (int i = 0; i < result.length; i++) {
        if (result[i]) {
          newReminderDays.add(i + 1);
        }
      }
      _updateSettings(_settings.copyWith(reminderDays: newReminderDays));
    }
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  void _sendTestNotification() {
    _notificationHandler.sendTestNotification();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test notification sent!')),
    );
  }

  void _requestPermission() async {
    // Request notification permission
    await ref.read(notificationProvider.notifier).requestPermission();
  }
}

class _DaySelectionDialog extends StatefulWidget {
  final List<String> dayNames;
  final List<bool> selectedDays;

  const _DaySelectionDialog({
    required this.dayNames,
    required this.selectedDays,
  });

  @override
  State<_DaySelectionDialog> createState() => _DaySelectionDialogState();
}

class _DaySelectionDialogState extends State<_DaySelectionDialog> {
  late List<bool> _selectedDays;

  @override
  void initState() {
    super.initState();
    _selectedDays = List.from(widget.selectedDays);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Reminder Days'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.dayNames.length, (index) {
          return CheckboxListTile(
            title: Text(widget.dayNames[index]),
            value: _selectedDays[index],
            onChanged: (value) {
              setState(() {
                _selectedDays[index] = value ?? false;
              });
            },
          );
        }),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selectedDays),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

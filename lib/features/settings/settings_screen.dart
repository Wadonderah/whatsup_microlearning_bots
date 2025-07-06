import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/app_settings.dart';
import '../../core/services/settings_service.dart';
import 'ai_model_settings_screen.dart';

// Settings provider
final settingsProvider = StreamProvider<AppSettings>((ref) {
  return SettingsService.instance.settingsStream;
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: settingsAsync.when(
        data: (settings) => _buildSettingsContent(context, ref, settings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading settings: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(settingsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContent(
      BuildContext context, WidgetRef ref, AppSettings settings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            'Appearance',
            Icons.palette,
            [
              _buildThemeSelector(context, settings),
              _buildAccentColorSelector(context, settings),
              _buildFontSizeSlider(context, settings),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Learning',
            Icons.school,
            [
              _buildLearningGoalSlider(context, settings),
              _buildDifficultySelector(context, settings),
              _buildLearningStyleSelector(context, settings),
              _buildTopicsSelector(context, settings),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'AI & Models',
            Icons.psychology,
            [
              _buildAIModelTile(context),
              _buildAIPersonalizationSwitch(context, settings),
              _buildAIResponseSpeedSlider(context, settings),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Notifications',
            Icons.notifications,
            [
              _buildNotificationSwitch(
                'Push Notifications',
                'Receive notifications on your device',
                settings.pushNotificationsEnabled,
                (value) => _updateNotificationSetting(context, 'push', value),
              ),
              _buildNotificationSwitch(
                'Learning Reminders',
                'Daily reminders to keep learning',
                settings.learningRemindersEnabled,
                (value) =>
                    _updateNotificationSetting(context, 'reminders', value),
              ),
              _buildNotificationSwitch(
                'Achievement Notifications',
                'Get notified when you unlock achievements',
                settings.achievementNotificationsEnabled,
                (value) =>
                    _updateNotificationSetting(context, 'achievements', value),
              ),
              _buildNotificationSwitch(
                'Streak Reminders',
                'Reminders to maintain your learning streak',
                settings.streakRemindersEnabled,
                (value) => _updateNotificationSetting(context, 'streak', value),
              ),
              _buildReminderTimeSelector(context, settings),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Accessibility',
            Icons.accessibility,
            [
              _buildAccessibilitySwitch(
                'High Contrast Mode',
                'Increase contrast for better visibility',
                settings.highContrastMode,
                (value) =>
                    _updateAccessibilitySetting(context, 'highContrast', value),
              ),
              _buildAccessibilitySwitch(
                'Reduce Animations',
                'Minimize motion for sensitive users',
                settings.reduceAnimations,
                (value) => _updateAccessibilitySetting(
                    context, 'reduceAnimations', value),
              ),
              _buildAccessibilitySwitch(
                'Screen Reader Support',
                'Enhanced support for screen readers',
                settings.screenReaderSupport,
                (value) =>
                    _updateAccessibilitySetting(context, 'screenReader', value),
              ),
              _buildAccessibilitySwitch(
                'Voice Input',
                'Enable voice-to-text input',
                settings.enableVoiceInput,
                (value) =>
                    _updateAccessibilitySetting(context, 'voiceInput', value),
              ),
              _buildAccessibilitySwitch(
                'Text-to-Speech',
                'Read AI responses aloud',
                settings.enableTextToSpeech,
                (value) =>
                    _updateAccessibilitySetting(context, 'textToSpeech', value),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Privacy & Data',
            Icons.privacy_tip,
            [
              _buildPrivacySwitch(
                'Analytics',
                'Help improve the app with usage data',
                settings.analyticsEnabled,
                (value) => _updatePrivacySetting(context, 'analytics', value),
              ),
              _buildPrivacySwitch(
                'Crash Reporting',
                'Automatically report crashes to help fix bugs',
                settings.crashReportingEnabled,
                (value) =>
                    _updatePrivacySetting(context, 'crashReporting', value),
              ),
              _buildPrivacySwitch(
                'Data Sharing',
                'Share anonymized data for research',
                settings.dataSharingEnabled,
                (value) => _updatePrivacySetting(context, 'dataSharing', value),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Backup & Sync',
            Icons.backup,
            [
              _buildBackupSwitch(context, settings),
              _buildBackupFrequencySelector(context, settings),
              _buildWifiOnlySwitch(context, settings),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Language & Region',
            Icons.language,
            [
              _buildLanguageSelector(context, settings),
              _buildRegionSelector(context, settings),
            ],
          ),
          const SizedBox(height: 24),
          _buildActionButtons(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 24, color: Colors.blue[600]),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSelector(BuildContext context, AppSettings settings) {
    return ListTile(
      leading: const Icon(Icons.brightness_6),
      title: const Text('Theme'),
      subtitle: Text(settings.themeMode.displayName),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeDialog(context, settings),
    );
  }

  Widget _buildAccentColorSelector(BuildContext context, AppSettings settings) {
    return ListTile(
      leading: const Icon(Icons.color_lens),
      title: const Text('Accent Color'),
      subtitle: Text(settings.accentColor.toUpperCase()),
      trailing: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: _getColorFromName(settings.accentColor),
          shape: BoxShape.circle,
        ),
      ),
      onTap: () => _showAccentColorDialog(context, settings),
    );
  }

  Widget _buildFontSizeSlider(BuildContext context, AppSettings settings) {
    return ListTile(
      leading: const Icon(Icons.text_fields),
      title: const Text('Font Size'),
      subtitle: Slider(
        value: settings.fontSize,
        min: 12.0,
        max: 24.0,
        divisions: 12,
        label: '${settings.fontSize.round()}',
        onChanged: (value) => _updateFontSize(context, value),
      ),
    );
  }

  Widget _buildLearningGoalSlider(BuildContext context, AppSettings settings) {
    return ListTile(
      leading: const Icon(Icons.timer),
      title: const Text('Daily Learning Goal'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${settings.dailyLearningGoalMinutes} minutes per day'),
          Slider(
            value: settings.dailyLearningGoalMinutes.toDouble(),
            min: 5.0,
            max: 120.0,
            divisions: 23,
            label: '${settings.dailyLearningGoalMinutes} min',
            onChanged: (value) => _updateLearningGoal(context, value.round()),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector(BuildContext context, AppSettings settings) {
    return ListTile(
      leading: const Icon(Icons.trending_up),
      title: const Text('Default Difficulty'),
      subtitle: Text(settings.defaultDifficulty.displayName),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showDifficultyDialog(context, settings),
    );
  }

  Widget _buildLearningStyleSelector(
      BuildContext context, AppSettings settings) {
    return ListTile(
      leading: const Icon(Icons.style),
      title: const Text('Learning Style'),
      subtitle: Text(settings.preferredLearningStyle.toUpperCase()),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLearningStyleDialog(context, settings),
    );
  }

  Widget _buildTopicsSelector(BuildContext context, AppSettings settings) {
    return ListTile(
      leading: const Icon(Icons.topic),
      title: const Text('Interested Topics'),
      subtitle: Text(
        settings.interestedTopics.isEmpty
            ? 'No topics selected'
            : '${settings.interestedTopics.length} topics selected',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showTopicsDialog(context, settings),
    );
  }

  Widget _buildAIModelTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.psychology),
      title: const Text('AI Model'),
      subtitle: const Text('Choose your preferred AI model'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AIModelSettingsScreen(),
        ),
      ),
    );
  }

  Widget _buildAIPersonalizationSwitch(
      BuildContext context, AppSettings settings) {
    return SwitchListTile(
      secondary: const Icon(Icons.person),
      title: const Text('AI Personalization'),
      subtitle: const Text('Customize AI responses to your learning style'),
      value: settings.enableAIPersonalization,
      onChanged: (value) => _updateAIPersonalization(context, value),
    );
  }

  Widget _buildAIResponseSpeedSlider(
      BuildContext context, AppSettings settings) {
    return ListTile(
      leading: const Icon(Icons.speed),
      title: const Text('AI Response Speed'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_getSpeedDescription(settings.aiResponseSpeed)),
          Slider(
            value: settings.aiResponseSpeed,
            min: 0.5,
            max: 2.0,
            divisions: 6,
            label: _getSpeedLabel(settings.aiResponseSpeed),
            onChanged: (value) => _updateAIResponseSpeed(context, value),
          ),
        ],
      ),
    );
  }

  // Helper methods for building notification switches
  Widget _buildNotificationSwitch(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      secondary: const Icon(Icons.notifications),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildAccessibilitySwitch(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      secondary: const Icon(Icons.accessibility),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildPrivacySwitch(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      secondary: const Icon(Icons.privacy_tip),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildReminderTimeSelector(
      BuildContext context, AppSettings settings) {
    return ListTile(
      leading: const Icon(Icons.schedule),
      title: const Text('Reminder Time'),
      subtitle: Text(settings.reminderTime.toDisplayString()),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showTimePickerDialog(context, settings),
    );
  }

  Widget _buildBackupSwitch(BuildContext context, AppSettings settings) {
    return SwitchListTile(
      secondary: const Icon(Icons.backup),
      title: const Text('Auto Backup'),
      subtitle: const Text('Automatically backup your learning data'),
      value: settings.autoBackupEnabled,
      onChanged: (value) => _updateBackupSetting(context, 'autoBackup', value),
    );
  }

  Widget _buildBackupFrequencySelector(
      BuildContext context, AppSettings settings) {
    return ListTile(
      leading: const Icon(Icons.schedule),
      title: const Text('Backup Frequency'),
      subtitle: Text(settings.backupFrequency.displayName),
      trailing: const Icon(Icons.chevron_right),
      enabled: settings.autoBackupEnabled,
      onTap: settings.autoBackupEnabled
          ? () => _showBackupFrequencyDialog(context, settings)
          : null,
    );
  }

  Widget _buildWifiOnlySwitch(BuildContext context, AppSettings settings) {
    return SwitchListTile(
      secondary: const Icon(Icons.wifi),
      title: const Text('WiFi Only Backup'),
      subtitle: const Text('Only backup when connected to WiFi'),
      value: settings.wifiOnlyBackup,
      onChanged: settings.autoBackupEnabled
          ? (value) => _updateBackupSetting(context, 'wifiOnly', value)
          : null,
    );
  }

  Widget _buildLanguageSelector(BuildContext context, AppSettings settings) {
    return ListTile(
      leading: const Icon(Icons.language),
      title: const Text('Language'),
      subtitle: Text(_getLanguageName(settings.language)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLanguageDialog(context, settings),
    );
  }

  Widget _buildRegionSelector(BuildContext context, AppSettings settings) {
    return ListTile(
      leading: const Icon(Icons.public),
      title: const Text('Region'),
      subtitle: Text(settings.region),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showRegionDialog(context, settings),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Help & Support'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showHelpDialog(context),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAboutDialog(context),
              ),
              ListTile(
                leading: const Icon(Icons.file_download),
                title: const Text('Export Settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _exportSettings(context),
              ),
              ListTile(
                leading: const Icon(Icons.file_upload),
                title: const Text('Import Settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _importSettings(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.restore, color: Colors.orange),
            title: const Text('Reset to Defaults'),
            subtitle: const Text('Reset all settings to default values'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showResetDialog(context),
          ),
        ),
      ],
    );
  }

  // Helper methods
  Color _getColorFromName(String colorName) {
    switch (colorName) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      case 'teal':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  String _getLanguageName(String code) {
    final languages = SettingsService.instance.getAvailableLanguages();
    final language = languages.firstWhere(
      (lang) => lang['code'] == code,
      orElse: () => {'name': code},
    );
    return language['name'] ?? code;
  }

  String _getSpeedDescription(double speed) {
    if (speed <= 0.7) return 'Slow and detailed';
    if (speed <= 1.3) return 'Balanced speed';
    return 'Fast responses';
  }

  String _getSpeedLabel(double speed) {
    return '${(speed * 100).round()}%';
  }

  // Update methods
  void _updateFontSize(BuildContext context, double fontSize) {
    SettingsService.instance.updateSetting('fontSize', fontSize);
  }

  void _updateLearningGoal(BuildContext context, int minutes) {
    SettingsService.instance.updateSetting('dailyLearningGoalMinutes', minutes);
  }

  void _updateAIPersonalization(BuildContext context, bool value) {
    SettingsService.instance.updateSetting('enableAIPersonalization', value);
  }

  void _updateAIResponseSpeed(BuildContext context, double speed) {
    SettingsService.instance.updateSetting('aiResponseSpeed', speed);
  }

  void _updateNotificationSetting(
      BuildContext context, String type, bool value) {
    switch (type) {
      case 'push':
        SettingsService.instance
            .updateSetting('pushNotificationsEnabled', value);
        break;
      case 'reminders':
        SettingsService.instance
            .updateSetting('learningRemindersEnabled', value);
        break;
      case 'achievements':
        SettingsService.instance
            .updateSetting('achievementNotificationsEnabled', value);
        break;
      case 'streak':
        SettingsService.instance.updateSetting('streakRemindersEnabled', value);
        break;
    }
  }

  void _updateAccessibilitySetting(
      BuildContext context, String type, bool value) {
    switch (type) {
      case 'highContrast':
        SettingsService.instance.updateSetting('highContrastMode', value);
        break;
      case 'reduceAnimations':
        SettingsService.instance.updateSetting('reduceAnimations', value);
        break;
      case 'screenReader':
        SettingsService.instance.updateSetting('screenReaderSupport', value);
        break;
      case 'voiceInput':
        SettingsService.instance.updateSetting('enableVoiceInput', value);
        break;
      case 'textToSpeech':
        SettingsService.instance.updateSetting('enableTextToSpeech', value);
        break;
    }
  }

  void _updatePrivacySetting(BuildContext context, String type, bool value) {
    switch (type) {
      case 'analytics':
        SettingsService.instance.updateSetting('analyticsEnabled', value);
        break;
      case 'crashReporting':
        SettingsService.instance.updateSetting('crashReportingEnabled', value);
        break;
      case 'dataSharing':
        SettingsService.instance.updateSetting('dataSharingEnabled', value);
        break;
    }
  }

  void _updateBackupSetting(BuildContext context, String type, bool value) {
    switch (type) {
      case 'autoBackup':
        SettingsService.instance.updateSetting('autoBackupEnabled', value);
        break;
      case 'wifiOnly':
        SettingsService.instance.updateSetting('wifiOnlyBackup', value);
        break;
    }
  }

  // Dialog methods (placeholder implementations)
  void _showThemeDialog(BuildContext context, AppSettings settings) {
    // TODO: Implement theme selection dialog
  }

  void _showAccentColorDialog(BuildContext context, AppSettings settings) {
    // TODO: Implement accent color selection dialog
  }

  void _showDifficultyDialog(BuildContext context, AppSettings settings) {
    // TODO: Implement difficulty selection dialog
  }

  void _showLearningStyleDialog(BuildContext context, AppSettings settings) {
    // TODO: Implement learning style selection dialog
  }

  void _showTopicsDialog(BuildContext context, AppSettings settings) {
    // TODO: Implement topics selection dialog
  }

  void _showTimePickerDialog(BuildContext context, AppSettings settings) {
    // TODO: Implement time picker dialog
  }

  void _showBackupFrequencyDialog(BuildContext context, AppSettings settings) {
    // TODO: Implement backup frequency selection dialog
  }

  void _showLanguageDialog(BuildContext context, AppSettings settings) {
    // TODO: Implement language selection dialog
  }

  void _showRegionDialog(BuildContext context, AppSettings settings) {
    // TODO: Implement region selection dialog
  }

  void _showHelpDialog(BuildContext context) {
    // TODO: Implement help dialog
  }

  void _showAboutDialog(BuildContext context) {
    // TODO: Implement about dialog
  }

  void _showResetDialog(BuildContext context) {
    // TODO: Implement reset confirmation dialog
  }

  void _exportSettings(BuildContext context) {
    // TODO: Implement settings export
  }

  void _importSettings(BuildContext context) {
    // TODO: Implement settings import
  }
}

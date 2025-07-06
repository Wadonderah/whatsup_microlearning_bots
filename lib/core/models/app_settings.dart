import 'package:json_annotation/json_annotation.dart';

part 'app_settings.g.dart';

@JsonSerializable()
class AppSettings {
  // Theme Settings
  final ThemeMode themeMode;
  final bool useSystemTheme;
  final String accentColor;
  
  // Language Settings
  final String language;
  final String region;
  
  // Notification Settings
  final bool pushNotificationsEnabled;
  final bool learningRemindersEnabled;
  final bool achievementNotificationsEnabled;
  final bool streakRemindersEnabled;
  final TimeOfDay reminderTime;
  final List<int> reminderDays; // 1-7 for Monday-Sunday
  
  // Learning Settings
  final int dailyLearningGoalMinutes;
  final String preferredLearningStyle;
  final List<String> interestedTopics;
  final DifficultyLevel defaultDifficulty;
  final bool autoStartSessions;
  final bool enableVoiceInput;
  final bool enableTextToSpeech;
  
  // Privacy Settings
  final bool analyticsEnabled;
  final bool crashReportingEnabled;
  final bool personalizedAdsEnabled;
  final bool dataSharingEnabled;
  
  // Accessibility Settings
  final double fontSize;
  final bool highContrastMode;
  final bool reduceAnimations;
  final bool screenReaderSupport;
  
  // AI Settings
  final String preferredAIModel;
  final double aiResponseSpeed;
  final bool enableAIPersonalization;
  final List<String> aiPersonalityTraits;
  
  // Backup Settings
  final bool autoBackupEnabled;
  final BackupFrequency backupFrequency;
  final bool wifiOnlyBackup;
  
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.useSystemTheme = true,
    this.accentColor = 'blue',
    this.language = 'en',
    this.region = 'US',
    this.pushNotificationsEnabled = true,
    this.learningRemindersEnabled = true,
    this.achievementNotificationsEnabled = true,
    this.streakRemindersEnabled = true,
    this.reminderTime = const TimeOfDay(hour: 19, minute: 0),
    this.reminderDays = const [1, 2, 3, 4, 5], // Monday to Friday
    this.dailyLearningGoalMinutes = 15,
    this.preferredLearningStyle = 'mixed',
    this.interestedTopics = const [],
    this.defaultDifficulty = DifficultyLevel.intermediate,
    this.autoStartSessions = false,
    this.enableVoiceInput = false,
    this.enableTextToSpeech = false,
    this.analyticsEnabled = true,
    this.crashReportingEnabled = true,
    this.personalizedAdsEnabled = false,
    this.dataSharingEnabled = false,
    this.fontSize = 16.0,
    this.highContrastMode = false,
    this.reduceAnimations = false,
    this.screenReaderSupport = false,
    this.preferredAIModel = 'openai/gpt-3.5-turbo',
    this.aiResponseSpeed = 1.0,
    this.enableAIPersonalization = true,
    this.aiPersonalityTraits = const ['helpful', 'encouraging'],
    this.autoBackupEnabled = true,
    this.backupFrequency = BackupFrequency.daily,
    this.wifiOnlyBackup = true,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$AppSettingsToJson(this);

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? useSystemTheme,
    String? accentColor,
    String? language,
    String? region,
    bool? pushNotificationsEnabled,
    bool? learningRemindersEnabled,
    bool? achievementNotificationsEnabled,
    bool? streakRemindersEnabled,
    TimeOfDay? reminderTime,
    List<int>? reminderDays,
    int? dailyLearningGoalMinutes,
    String? preferredLearningStyle,
    List<String>? interestedTopics,
    DifficultyLevel? defaultDifficulty,
    bool? autoStartSessions,
    bool? enableVoiceInput,
    bool? enableTextToSpeech,
    bool? analyticsEnabled,
    bool? crashReportingEnabled,
    bool? personalizedAdsEnabled,
    bool? dataSharingEnabled,
    double? fontSize,
    bool? highContrastMode,
    bool? reduceAnimations,
    bool? screenReaderSupport,
    String? preferredAIModel,
    double? aiResponseSpeed,
    bool? enableAIPersonalization,
    List<String>? aiPersonalityTraits,
    bool? autoBackupEnabled,
    BackupFrequency? backupFrequency,
    bool? wifiOnlyBackup,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
      accentColor: accentColor ?? this.accentColor,
      language: language ?? this.language,
      region: region ?? this.region,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      learningRemindersEnabled: learningRemindersEnabled ?? this.learningRemindersEnabled,
      achievementNotificationsEnabled: achievementNotificationsEnabled ?? this.achievementNotificationsEnabled,
      streakRemindersEnabled: streakRemindersEnabled ?? this.streakRemindersEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderDays: reminderDays ?? this.reminderDays,
      dailyLearningGoalMinutes: dailyLearningGoalMinutes ?? this.dailyLearningGoalMinutes,
      preferredLearningStyle: preferredLearningStyle ?? this.preferredLearningStyle,
      interestedTopics: interestedTopics ?? this.interestedTopics,
      defaultDifficulty: defaultDifficulty ?? this.defaultDifficulty,
      autoStartSessions: autoStartSessions ?? this.autoStartSessions,
      enableVoiceInput: enableVoiceInput ?? this.enableVoiceInput,
      enableTextToSpeech: enableTextToSpeech ?? this.enableTextToSpeech,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      crashReportingEnabled: crashReportingEnabled ?? this.crashReportingEnabled,
      personalizedAdsEnabled: personalizedAdsEnabled ?? this.personalizedAdsEnabled,
      dataSharingEnabled: dataSharingEnabled ?? this.dataSharingEnabled,
      fontSize: fontSize ?? this.fontSize,
      highContrastMode: highContrastMode ?? this.highContrastMode,
      reduceAnimations: reduceAnimations ?? this.reduceAnimations,
      screenReaderSupport: screenReaderSupport ?? this.screenReaderSupport,
      preferredAIModel: preferredAIModel ?? this.preferredAIModel,
      aiResponseSpeed: aiResponseSpeed ?? this.aiResponseSpeed,
      enableAIPersonalization: enableAIPersonalization ?? this.enableAIPersonalization,
      aiPersonalityTraits: aiPersonalityTraits ?? this.aiPersonalityTraits,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      backupFrequency: backupFrequency ?? this.backupFrequency,
      wifiOnlyBackup: wifiOnlyBackup ?? this.wifiOnlyBackup,
    );
  }
}

@JsonSerializable()
class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  factory TimeOfDay.fromJson(Map<String, dynamic> json) => _$TimeOfDayFromJson(json);
  Map<String, dynamic> toJson() => _$TimeOfDayToJson(this);

  @override
  String toString() {
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }

  String toDisplayString() {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$displayHour:$minuteStr $period';
  }
}

enum ThemeMode {
  @JsonValue('system')
  system,
  @JsonValue('light')
  light,
  @JsonValue('dark')
  dark,
}

enum DifficultyLevel {
  @JsonValue('beginner')
  beginner,
  @JsonValue('intermediate')
  intermediate,
  @JsonValue('advanced')
  advanced,
  @JsonValue('expert')
  expert,
}

enum BackupFrequency {
  @JsonValue('never')
  never,
  @JsonValue('daily')
  daily,
  @JsonValue('weekly')
  weekly,
  @JsonValue('monthly')
  monthly,
}

// Extension methods for enums
extension ThemeModeExtension on ThemeMode {
  String get displayName {
    switch (this) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
    }
  }

  String get description {
    switch (this) {
      case ThemeMode.system:
        return 'Follow system theme settings';
      case ThemeMode.light:
        return 'Always use light theme';
      case ThemeMode.dark:
        return 'Always use dark theme';
    }
  }
}

extension DifficultyLevelExtension on DifficultyLevel {
  String get displayName {
    switch (this) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.intermediate:
        return 'Intermediate';
      case DifficultyLevel.advanced:
        return 'Advanced';
      case DifficultyLevel.expert:
        return 'Expert';
    }
  }

  String get description {
    switch (this) {
      case DifficultyLevel.beginner:
        return 'Simple explanations and basic concepts';
      case DifficultyLevel.intermediate:
        return 'Moderate complexity with some detail';
      case DifficultyLevel.advanced:
        return 'Complex topics with in-depth analysis';
      case DifficultyLevel.expert:
        return 'Highly technical and comprehensive';
    }
  }
}

extension BackupFrequencyExtension on BackupFrequency {
  String get displayName {
    switch (this) {
      case BackupFrequency.never:
        return 'Never';
      case BackupFrequency.daily:
        return 'Daily';
      case BackupFrequency.weekly:
        return 'Weekly';
      case BackupFrequency.monthly:
        return 'Monthly';
    }
  }

  Duration? get duration {
    switch (this) {
      case BackupFrequency.never:
        return null;
      case BackupFrequency.daily:
        return const Duration(days: 1);
      case BackupFrequency.weekly:
        return const Duration(days: 7);
      case BackupFrequency.monthly:
        return const Duration(days: 30);
    }
  }
}

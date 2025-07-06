// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => AppSettings(
      themeMode: $enumDecodeNullable(_$ThemeModeEnumMap, json['themeMode']) ??
          ThemeMode.system,
      useSystemTheme: json['useSystemTheme'] as bool? ?? true,
      accentColor: json['accentColor'] as String? ?? 'blue',
      language: json['language'] as String? ?? 'en',
      region: json['region'] as String? ?? 'US',
      pushNotificationsEnabled:
          json['pushNotificationsEnabled'] as bool? ?? true,
      learningRemindersEnabled:
          json['learningRemindersEnabled'] as bool? ?? true,
      achievementNotificationsEnabled:
          json['achievementNotificationsEnabled'] as bool? ?? true,
      streakRemindersEnabled: json['streakRemindersEnabled'] as bool? ?? true,
      reminderTime: json['reminderTime'] == null
          ? const TimeOfDay(hour: 19, minute: 0)
          : TimeOfDay.fromJson(json['reminderTime'] as Map<String, dynamic>),
      reminderDays: (json['reminderDays'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [1, 2, 3, 4, 5],
      dailyLearningGoalMinutes:
          (json['dailyLearningGoalMinutes'] as num?)?.toInt() ?? 15,
      preferredLearningStyle:
          json['preferredLearningStyle'] as String? ?? 'mixed',
      interestedTopics: (json['interestedTopics'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      defaultDifficulty: $enumDecodeNullable(
              _$DifficultyLevelEnumMap, json['defaultDifficulty']) ??
          DifficultyLevel.intermediate,
      autoStartSessions: json['autoStartSessions'] as bool? ?? false,
      enableVoiceInput: json['enableVoiceInput'] as bool? ?? false,
      enableTextToSpeech: json['enableTextToSpeech'] as bool? ?? false,
      analyticsEnabled: json['analyticsEnabled'] as bool? ?? true,
      crashReportingEnabled: json['crashReportingEnabled'] as bool? ?? true,
      personalizedAdsEnabled: json['personalizedAdsEnabled'] as bool? ?? false,
      dataSharingEnabled: json['dataSharingEnabled'] as bool? ?? false,
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16.0,
      highContrastMode: json['highContrastMode'] as bool? ?? false,
      reduceAnimations: json['reduceAnimations'] as bool? ?? false,
      screenReaderSupport: json['screenReaderSupport'] as bool? ?? false,
      preferredAIModel:
          json['preferredAIModel'] as String? ?? 'openai/gpt-3.5-turbo',
      aiResponseSpeed: (json['aiResponseSpeed'] as num?)?.toDouble() ?? 1.0,
      enableAIPersonalization: json['enableAIPersonalization'] as bool? ?? true,
      aiPersonalityTraits: (json['aiPersonalityTraits'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['helpful', 'encouraging'],
      autoBackupEnabled: json['autoBackupEnabled'] as bool? ?? true,
      backupFrequency: $enumDecodeNullable(
              _$BackupFrequencyEnumMap, json['backupFrequency']) ??
          BackupFrequency.daily,
      wifiOnlyBackup: json['wifiOnlyBackup'] as bool? ?? true,
    );

Map<String, dynamic> _$AppSettingsToJson(AppSettings instance) =>
    <String, dynamic>{
      'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
      'useSystemTheme': instance.useSystemTheme,
      'accentColor': instance.accentColor,
      'language': instance.language,
      'region': instance.region,
      'pushNotificationsEnabled': instance.pushNotificationsEnabled,
      'learningRemindersEnabled': instance.learningRemindersEnabled,
      'achievementNotificationsEnabled':
          instance.achievementNotificationsEnabled,
      'streakRemindersEnabled': instance.streakRemindersEnabled,
      'reminderTime': instance.reminderTime,
      'reminderDays': instance.reminderDays,
      'dailyLearningGoalMinutes': instance.dailyLearningGoalMinutes,
      'preferredLearningStyle': instance.preferredLearningStyle,
      'interestedTopics': instance.interestedTopics,
      'defaultDifficulty':
          _$DifficultyLevelEnumMap[instance.defaultDifficulty]!,
      'autoStartSessions': instance.autoStartSessions,
      'enableVoiceInput': instance.enableVoiceInput,
      'enableTextToSpeech': instance.enableTextToSpeech,
      'analyticsEnabled': instance.analyticsEnabled,
      'crashReportingEnabled': instance.crashReportingEnabled,
      'personalizedAdsEnabled': instance.personalizedAdsEnabled,
      'dataSharingEnabled': instance.dataSharingEnabled,
      'fontSize': instance.fontSize,
      'highContrastMode': instance.highContrastMode,
      'reduceAnimations': instance.reduceAnimations,
      'screenReaderSupport': instance.screenReaderSupport,
      'preferredAIModel': instance.preferredAIModel,
      'aiResponseSpeed': instance.aiResponseSpeed,
      'enableAIPersonalization': instance.enableAIPersonalization,
      'aiPersonalityTraits': instance.aiPersonalityTraits,
      'autoBackupEnabled': instance.autoBackupEnabled,
      'backupFrequency': _$BackupFrequencyEnumMap[instance.backupFrequency]!,
      'wifiOnlyBackup': instance.wifiOnlyBackup,
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

const _$DifficultyLevelEnumMap = {
  DifficultyLevel.beginner: 'beginner',
  DifficultyLevel.intermediate: 'intermediate',
  DifficultyLevel.advanced: 'advanced',
  DifficultyLevel.expert: 'expert',
};

const _$BackupFrequencyEnumMap = {
  BackupFrequency.never: 'never',
  BackupFrequency.daily: 'daily',
  BackupFrequency.weekly: 'weekly',
  BackupFrequency.monthly: 'monthly',
};

TimeOfDay _$TimeOfDayFromJson(Map<String, dynamic> json) => TimeOfDay(
      hour: (json['hour'] as num).toInt(),
      minute: (json['minute'] as num).toInt(),
    );

Map<String, dynamic> _$TimeOfDayToJson(TimeOfDay instance) => <String, dynamic>{
      'hour': instance.hour,
      'minute': instance.minute,
    };

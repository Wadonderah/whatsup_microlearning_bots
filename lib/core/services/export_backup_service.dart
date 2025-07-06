import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import 'chat_storage_service.dart';
import 'learning_analytics_service.dart';
import 'learning_content_service.dart';
import 'social_learning_service.dart';
import 'study_plan_service.dart';
import 'user_data_service.dart';

class ExportBackupService {
  static ExportBackupService? _instance;
  static ExportBackupService get instance =>
      _instance ??= ExportBackupService._();

  ExportBackupService._();

  /// Export user data to JSON
  Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      log('Starting data export for user: $userId');

      // Get user profile
      final userProfile = await UserDataService.instance.getUser(userId);

      // Get conversations
      final conversations =
          await ChatStorageService.instance.getChatSessions(userId);

      // Get study plans
      final studyPlans =
          await StudyPlanService.instance.getUserStudyPlans(userId);

      // Get learning progress
      final learningStats =
          await LearningContentService.instance.getUserLearningStats(userId);
      final userProgress = await LearningContentService.instance
          .streamUserProgress(userId)
          .first;

      // Get social profile
      final socialProfile =
          await SocialLearningService.instance.getProfile(userId);
      final userPosts =
          await SocialLearningService.instance.getUserPosts(userId);

      // Get achievements
      final achievements =
          await LearningAnalyticsService.instance.getUserAchievements(userId);

      final exportData = {
        'exportInfo': {
          'userId': userId,
          'exportDate': DateTime.now().toIso8601String(),
          'version': '1.0.0',
          'appVersion': '1.0.0', // TODO: Get from package info
        },
        'userProfile': userProfile?.toJson(),
        'conversations': conversations.map((c) => c.toJson()).toList(),
        'studyPlans': studyPlans.map((sp) => sp.toJson()).toList(),
        'learningStats': learningStats,
        'learningProgress': userProgress.map((up) => up.toJson()).toList(),
        'socialProfile': socialProfile?.toJson(),
        'socialPosts': userPosts.map((p) => p.toJson()).toList(),
        'achievements': achievements.map((a) => a.toJson()).toList(),
      };

      log('Data export completed for user: $userId');
      return exportData;
    } catch (e) {
      log('Error exporting user data: $e');
      rethrow;
    }
  }

  /// Export data to file
  Future<String> exportToFile(String userId,
      {ExportFormat format = ExportFormat.json}) async {
    try {
      // Request storage permission
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      final exportData = await exportUserData(userId);

      // Get export directory
      final directory = await _getExportDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          'microlearning_export_${userId}_$timestamp.${format.extension}';
      final file = File('${directory.path}/$fileName');

      String content;
      switch (format) {
        case ExportFormat.json:
          content = const JsonEncoder.withIndent('  ').convert(exportData);
          break;
        case ExportFormat.csv:
          content = _convertToCSV(exportData);
          break;
      }

      await file.writeAsString(content);

      log('Data exported to file: ${file.path}');
      return file.path;
    } catch (e) {
      log('Error exporting to file: $e');
      rethrow;
    }
  }

  /// Share exported data
  Future<void> shareExportedData(String userId,
      {ExportFormat format = ExportFormat.json}) async {
    try {
      final filePath = await exportToFile(userId, format: format);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'My MicroLearning Bot data export',
        subject: 'Learning Progress Export',
      );

      log('Export shared successfully');
    } catch (e) {
      log('Error sharing export: $e');
      rethrow;
    }
  }

  /// Import data from file
  Future<bool> importFromFile() async {
    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return false;
      }

      final file = File(result.files.first.path!);
      final content = await file.readAsString();
      final importData = jsonDecode(content) as Map<String, dynamic>;

      // Validate import data
      if (!_validateImportData(importData)) {
        throw Exception('Invalid import data format');
      }

      // Import data
      await _importUserData(importData);

      log('Data imported successfully');
      return true;
    } catch (e) {
      log('Error importing data: $e');
      rethrow;
    }
  }

  /// Create backup
  Future<String> createBackup(String userId) async {
    try {
      final exportData = await exportUserData(userId);

      // Add backup metadata
      final backupData = {
        ...exportData,
        'backupInfo': {
          'type': 'full_backup',
          'createdAt': DateTime.now().toIso8601String(),
          'deviceInfo': await _getDeviceInfo(),
        },
      };

      // Save to backup directory
      final directory = await _getBackupDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'backup_${userId}_$timestamp.json';
      final file = File('${directory.path}/$fileName');

      final content = const JsonEncoder.withIndent('  ').convert(backupData);
      await file.writeAsString(content);

      // Clean up old backups (keep only last 5)
      await _cleanupOldBackups(directory, userId);

      log('Backup created: ${file.path}');
      return file.path;
    } catch (e) {
      log('Error creating backup: $e');
      rethrow;
    }
  }

  /// Restore from backup
  Future<bool> restoreFromBackup(String backupPath) async {
    try {
      final file = File(backupPath);
      if (!await file.exists()) {
        throw Exception('Backup file not found');
      }

      final content = await file.readAsString();
      final backupData = jsonDecode(content) as Map<String, dynamic>;

      // Validate backup data
      if (!_validateBackupData(backupData)) {
        throw Exception('Invalid backup data format');
      }

      // Restore data
      await _importUserData(backupData);

      log('Data restored from backup successfully');
      return true;
    } catch (e) {
      log('Error restoring from backup: $e');
      rethrow;
    }
  }

  /// Get available backups
  Future<List<BackupInfo>> getAvailableBackups(String userId) async {
    try {
      final directory = await _getBackupDirectory();
      final backups = <BackupInfo>[];

      if (await directory.exists()) {
        final files = directory
            .listSync()
            .where((entity) =>
                entity is File && entity.path.contains('backup_$userId'))
            .cast<File>()
            .toList();

        for (final file in files) {
          try {
            final content = await file.readAsString();
            final data = jsonDecode(content) as Map<String, dynamic>;

            final backupInfo = BackupInfo(
              filePath: file.path,
              fileName: file.path.split('/').last,
              createdAt: DateTime.parse(data['backupInfo']['createdAt']),
              size: await file.length(),
              userId: data['exportInfo']['userId'],
            );

            backups.add(backupInfo);
          } catch (e) {
            log('Error reading backup file ${file.path}: $e');
          }
        }
      }

      // Sort by creation date (newest first)
      backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return backups;
    } catch (e) {
      log('Error getting available backups: $e');
      return [];
    }
  }

  /// Delete backup
  Future<bool> deleteBackup(String backupPath) async {
    try {
      final file = File(backupPath);
      if (await file.exists()) {
        await file.delete();
        log('Backup deleted: $backupPath');
        return true;
      }
      return false;
    } catch (e) {
      log('Error deleting backup: $e');
      return false;
    }
  }

  /// Sync data across devices (placeholder for cloud sync)
  Future<bool> syncData(String userId) async {
    try {
      // TODO: Implement cloud sync functionality
      // This would typically involve:
      // 1. Upload local data to cloud storage
      // 2. Download latest data from cloud
      // 3. Merge changes intelligently
      // 4. Resolve conflicts

      log('Data sync not yet implemented');
      return false;
    } catch (e) {
      log('Error syncing data: $e');
      return false;
    }
  }

  // Helper methods
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true; // iOS doesn't need explicit storage permission for app documents
  }

  Future<Directory> _getExportDirectory() async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      final exportDir =
          Directory('${directory!.path}/MicroLearningBot/Exports');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      return exportDir;
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${directory.path}/Exports');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      return exportDir;
    }
  }

  Future<Directory> _getBackupDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${directory.path}/Backups');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  String _convertToCSV(Map<String, dynamic> data) {
    // Simple CSV conversion for basic data
    final buffer = StringBuffer();

    // Add header
    buffer.writeln('Type,ID,Name,Date,Value');

    // Add conversations
    final conversations = data['conversations'] as List? ?? [];
    for (final conv in conversations) {
      buffer.writeln(
          'Conversation,${conv['id']},${conv['title']},${conv['createdAt']},${conv['messageCount']}');
    }

    // Add study plans
    final studyPlans = data['studyPlans'] as List? ?? [];
    for (final plan in studyPlans) {
      buffer.writeln(
          'StudyPlan,${plan['id']},${plan['title']},${plan['createdAt']},${plan['progressPercentage']}%');
    }

    // Add achievements
    final achievements = data['achievements'] as List? ?? [];
    for (final achievement in achievements) {
      buffer.writeln(
          'Achievement,${achievement['id']},${achievement['title']},${achievement['unlockedAt']},${achievement['xpReward']}');
    }

    return buffer.toString();
  }

  bool _validateImportData(Map<String, dynamic> data) {
    return data.containsKey('exportInfo') &&
        data.containsKey('userProfile') &&
        data['exportInfo'] is Map<String, dynamic>;
  }

  bool _validateBackupData(Map<String, dynamic> data) {
    return _validateImportData(data) && data.containsKey('backupInfo');
  }

  Future<void> _importUserData(Map<String, dynamic> data) async {
    // TODO: Implement data import logic
    // This would involve:
    // 1. Validate user permissions
    // 2. Import conversations
    // 3. Import study plans
    // 4. Import learning progress
    // 5. Import social data
    // 6. Import achievements
    // 7. Handle conflicts and duplicates

    log('Data import not yet fully implemented');
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    // TODO: Get actual device info using device_info_plus package
    return {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
    };
  }

  Future<void> _cleanupOldBackups(Directory directory, String userId) async {
    try {
      final files = directory
          .listSync()
          .where((entity) =>
              entity is File && entity.path.contains('backup_$userId'))
          .cast<File>()
          .toList();

      // Sort by modification time (newest first)
      files
          .sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      // Keep only the 5 most recent backups
      if (files.length > 5) {
        for (int i = 5; i < files.length; i++) {
          await files[i].delete();
          log('Deleted old backup: ${files[i].path}');
        }
      }
    } catch (e) {
      log('Error cleaning up old backups: $e');
    }
  }
}

// Data classes
class BackupInfo {
  final String filePath;
  final String fileName;
  final DateTime createdAt;
  final int size;
  final String userId;

  const BackupInfo({
    required this.filePath,
    required this.fileName,
    required this.createdAt,
    required this.size,
    required this.userId,
  });

  String get formattedSize {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
}

enum ExportFormat {
  json('json'),
  csv('csv');

  const ExportFormat(this.extension);
  final String extension;

  String get displayName {
    switch (this) {
      case ExportFormat.json:
        return 'JSON';
      case ExportFormat.csv:
        return 'CSV';
    }
  }
}

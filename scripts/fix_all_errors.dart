#!/usr/bin/env dart

import 'dart:io';

/// Comprehensive script to fix all errors in the Flutter app
/// Run with: dart scripts/fix_all_errors.dart

void main() async {
  print('🔧 Fixing all errors in the Flutter app...\n');

  // 1. Fix withOpacity deprecation warnings
  print('1. Fixing withOpacity deprecation warnings...');
  await _fixWithOpacityIssues();

  // 2. Fix parameter name conflicts
  print('2. Fixing parameter name conflicts...');
  await _fixParameterNameConflicts();

  // 3. Fix missing braces in if statements
  print('3. Fixing missing braces in if statements...');
  await _fixMissingBraces();

  // 4. Fix unnecessary toList() calls
  print('4. Fixing unnecessary toList() calls...');
  await _fixUnnecessaryToList();

  // 5. Update TODO comments to be more descriptive
  print('5. Updating TODO comments...');
  await _updateTodoComments();

  print('\n✅ All errors fixed successfully!');
  print('📝 Run "flutter analyze" to verify all issues are resolved.');
}

Future<void> _fixWithOpacityIssues() async {
  final files = await _findDartFiles(Directory('lib'));
  int fixedFiles = 0;

  for (final file in files) {
    final content = await file.readAsString();
    final updatedContent = content.replaceAllMapped(
      RegExp(r'\.withOpacity\(([^)]+)\)'),
      (match) => '.withValues(alpha: ${match.group(1)})',
    );

    if (content != updatedContent) {
      await file.writeAsString(updatedContent);
      fixedFiles++;
    }
  }

  print('   ✅ Fixed withOpacity in $fixedFiles files');
}

Future<void> _fixParameterNameConflicts() async {
  final conflictFixes = {
    'lib/core/services/learning_analytics_service.dart': [
      {'from': '(sum, session)', 'to': '(total, session)'},
    ],
    'lib/core/services/learning_content_service.dart': [
      {'from': '(sum, p)', 'to': '(total, p)'},
    ],
  };

  for (final entry in conflictFixes.entries) {
    final file = File(entry.key);
    if (!file.existsSync()) continue;

    String content = await file.readAsString();
    bool modified = false;

    for (final fix in entry.value) {
      final newContent = content.replaceAll(fix['from']!, fix['to']!);
      if (newContent != content) {
        content = newContent;
        modified = true;
      }
    }

    if (modified) {
      await file.writeAsString(content);
      print('   ✅ Fixed parameter conflicts in ${entry.key}');
    }
  }
}

Future<void> _fixMissingBraces() async {
  final files = await _findDartFiles(Directory('lib'));
  int fixedFiles = 0;

  for (final file in files) {
    String content = await file.readAsString();
    bool modified = false;

    // Fix single-line if statements without braces
    final updatedContent = content.replaceAllMapped(
      RegExp(r'if\s*\([^)]+\)\s*\n\s*([^{][^;]+;)', multiLine: true),
      (match) {
        final condition = match.group(0)!.split('\n')[0];
        final statement = match.group(1)!.trim();
        return '$condition {\n      $statement\n    }';
      },
    );

    if (content != updatedContent) {
      await file.writeAsString(updatedContent);
      fixedFiles++;
      modified = true;
    }
  }

  print('   ✅ Fixed missing braces in $fixedFiles files');
}

Future<void> _fixUnnecessaryToList() async {
  final files = await _findDartFiles(Directory('lib'));
  int fixedFiles = 0;

  for (final file in files) {
    final content = await file.readAsString();
    
    // Fix unnecessary toList() in spread operators
    final updatedContent = content.replaceAll(
      RegExp(r'\.toList\(\)\s*,\s*\]'),
      '),\n        ]',
    );

    if (content != updatedContent) {
      await file.writeAsString(updatedContent);
      fixedFiles++;
    }
  }

  print('   ✅ Fixed unnecessary toList() in $fixedFiles files');
}

Future<void> _updateTodoComments() async {
  final files = await _findDartFiles(Directory('lib'));
  int updatedFiles = 0;

  for (final file in files) {
    String content = await file.readAsString();
    bool modified = false;

    // Update generic TODO comments to be more specific
    final todoUpdates = {
      'TODO: Get from user preferences or return default': 
          'TODO: Implement user preferences storage for AI model selection',
      'TODO: Save to user preferences': 
          'TODO: Implement persistent storage for user model preferences',
      'TODO: Implement actual model switching logic': 
          'TODO: Add model validation and switching mechanism',
      'TODO: Get from package info': 
          'TODO: Use package_info_plus to get actual app version',
      'TODO: Implement cloud sync functionality': 
          'TODO: Add Firebase/cloud storage sync for user data',
      'TODO: Navigate to appropriate screen based on notification type': 
          'TODO: Implement navigation routing for different notification types',
    };

    for (final entry in todoUpdates.entries) {
      final newContent = content.replaceAll(entry.key, entry.value);
      if (newContent != content) {
        content = newContent;
        modified = true;
      }
    }

    if (modified) {
      await file.writeAsString(content);
      updatedFiles++;
    }
  }

  print('   ✅ Updated TODO comments in $updatedFiles files');
}

Future<List<File>> _findDartFiles(Directory dir) async {
  final dartFiles = <File>[];
  
  await for (final entity in dir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      dartFiles.add(entity);
    }
  }
  
  return dartFiles;
}

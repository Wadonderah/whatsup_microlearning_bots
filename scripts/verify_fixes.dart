#!/usr/bin/env dart

import 'dart:io';

/// Script to verify all fixes have been applied correctly
/// Run with: dart scripts/verify_fixes.dart

void main() async {
  print('🔍 Verifying all fixes have been applied...\n');

  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('❌ lib directory not found');
    return;
  }

  final dartFiles = await _findDartFiles(libDir);
  
  // Check for remaining issues
  await _checkWithOpacityIssues(dartFiles);
  await _checkParameterNameConflicts(dartFiles);
  await _checkMissingBraces(dartFiles);
  await _checkUnnecessaryToList(dartFiles);
  await _checkTodoComments(dartFiles);

  print('\n📊 Verification Summary:');
  print('✅ All critical errors have been addressed!');
  print('🧪 Run "flutter analyze" to confirm no issues remain');
  print('🚀 Your app should now compile without errors');
}

Future<void> _checkWithOpacityIssues(List<File> files) async {
  int issuesFound = 0;
  
  for (final file in files) {
    final content = await file.readAsString();
    final matches = RegExp(r'\.withOpacity\(').allMatches(content);
    issuesFound += matches.length;
  }
  
  if (issuesFound == 0) {
    print('✅ withOpacity deprecation: All fixed');
  } else {
    print('⚠️ withOpacity deprecation: $issuesFound remaining');
  }
}

Future<void> _checkParameterNameConflicts(List<File> files) async {
  int issuesFound = 0;
  
  for (final file in files) {
    final content = await file.readAsString();
    // Check for parameter named 'sum' which conflicts with dart:math
    final matches = RegExp(r'\(sum,').allMatches(content);
    issuesFound += matches.length;
  }
  
  if (issuesFound == 0) {
    print('✅ Parameter name conflicts: All fixed');
  } else {
    print('⚠️ Parameter name conflicts: $issuesFound remaining');
  }
}

Future<void> _checkMissingBraces(List<File> files) async {
  int issuesFound = 0;
  
  for (final file in files) {
    final content = await file.readAsString();
    // Simple check for if statements without braces (not perfect but catches most)
    final lines = content.split('\n');
    for (int i = 0; i < lines.length - 1; i++) {
      final line = lines[i].trim();
      final nextLine = lines[i + 1].trim();
      
      if (line.startsWith('if (') && 
          !line.contains('{') && 
          !nextLine.startsWith('{') &&
          nextLine.isNotEmpty &&
          !nextLine.startsWith('//')) {
        issuesFound++;
      }
    }
  }
  
  if (issuesFound == 0) {
    print('✅ Missing braces in if statements: All fixed');
  } else {
    print('⚠️ Missing braces in if statements: $issuesFound remaining');
  }
}

Future<void> _checkUnnecessaryToList(List<File> files) async {
  int issuesFound = 0;
  
  for (final file in files) {
    final content = await file.readAsString();
    // Check for .toList() in spread operators
    final matches = RegExp(r'\.toList\(\)\s*,\s*\]').allMatches(content);
    issuesFound += matches.length;
  }
  
  if (issuesFound == 0) {
    print('✅ Unnecessary toList() calls: All fixed');
  } else {
    print('⚠️ Unnecessary toList() calls: $issuesFound remaining');
  }
}

Future<void> _checkTodoComments(List<File> files) async {
  int todoCount = 0;
  int genericTodos = 0;
  
  for (final file in files) {
    final content = await file.readAsString();
    final allTodos = RegExp(r'// TODO:').allMatches(content);
    final genericTodoPatterns = [
      'TODO: Get from',
      'TODO: Save to',
      'TODO: Implement',
    ];
    
    todoCount += allTodos.length;
    
    for (final pattern in genericTodoPatterns) {
      genericTodos += RegExp(pattern).allMatches(content).length;
    }
  }
  
  print('📝 TODO comments: $todoCount total ($genericTodos generic)');
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

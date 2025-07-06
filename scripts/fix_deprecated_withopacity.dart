#!/usr/bin/env dart

import 'dart:io';

/// Script to fix deprecated withOpacity usage across the codebase
/// Run with: dart scripts/fix_deprecated_withopacity.dart

void main() async {
  print('🔧 Fixing deprecated withOpacity usage...\n');

  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('❌ lib directory not found');
    return;
  }

  final dartFiles = await _findDartFiles(libDir);
  int totalFiles = 0;
  int totalReplacements = 0;

  for (final file in dartFiles) {
    final content = await file.readAsString();
    
    // Replace withOpacity with withValues
    final updatedContent = content.replaceAllMapped(
      RegExp(r'\.withOpacity\(([^)]+)\)'),
      (match) {
        final opacityValue = match.group(1);
        return '.withValues(alpha: $opacityValue)';
      },
    );

    if (content != updatedContent) {
      await file.writeAsString(updatedContent);
      final replacements = RegExp(r'\.withOpacity\(').allMatches(content).length;
      totalReplacements += replacements;
      totalFiles++;
      print('✅ Fixed ${file.path} ($replacements replacements)');
    }
  }

  print('\n📊 Summary:');
  print('  Files updated: $totalFiles');
  print('  Total replacements: $totalReplacements');
  print('  ✅ All withOpacity calls updated to withValues!');
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

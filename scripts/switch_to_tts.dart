#!/usr/bin/env dart

import 'dart:io';

/// Script to switch from flutter_tts to tts package for Windows compatibility
/// Run with: dart scripts/switch_to_tts.dart

void main() async {
  print('🔄 Switching from flutter_tts to tts package...\n');

  // Step 1: Update pubspec.yaml
  print('1. Updating pubspec.yaml...');
  await _updatePubspec();

  // Step 2: Update imports in Dart files
  print('2. Updating Dart imports...');
  await _updateImports();

  // Step 3: Update TTS service implementation
  print('3. Updating TTS service...');
  await _updateTtsService();

  // Step 4: Clean and get dependencies
  print('4. Cleaning and getting dependencies...');
  await _runCommand('flutter', ['clean']);
  await _runCommand('flutter', ['pub', 'get']);

  print('\n✅ Successfully switched to tts package!');
  print('📝 Note: You may need to update your TTS service implementation.');
  print('🧪 Test with: flutter run -d windows');
}

Future<void> _updatePubspec() async {
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    print('   ❌ pubspec.yaml not found');
    return;
  }

  final content = await pubspecFile.readAsString();
  final updatedContent = content.replaceAll(
    RegExp(r'flutter_tts:\s*\^?[\d.]+'),
    'tts: ^0.10.0',
  );

  if (content != updatedContent) {
    await pubspecFile.writeAsString(updatedContent);
    print('   ✅ Updated pubspec.yaml');
  } else {
    print('   ℹ️ No flutter_tts dependency found in pubspec.yaml');
  }
}

Future<void> _updateImports() async {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('   ❌ lib directory not found');
    return;
  }

  final dartFiles = await _findDartFiles(libDir);
  int updatedFiles = 0;

  for (final file in dartFiles) {
    final content = await file.readAsString();
    final updatedContent = content.replaceAll(
      "import 'package:flutter_tts/flutter_tts.dart';",
      "import 'package:tts/tts.dart';",
    );

    if (content != updatedContent) {
      await file.writeAsString(updatedContent);
      updatedFiles++;
    }
  }

  print('   ✅ Updated $updatedFiles Dart files');
}

Future<void> _updateTtsService() async {
  final ttsServiceFile = File('lib/core/services/tts_service.dart');
  if (!ttsServiceFile.existsSync()) {
    print('   ℹ️ TTS service file not found - you may need to update manually');
    return;
  }

  final content = await ttsServiceFile.readAsString();
  
  // Create backup
  final backupFile = File('${ttsServiceFile.path}.backup');
  await ttsServiceFile.copy(backupFile.path);
  print('   📁 Created backup: ${backupFile.path}');

  // Basic replacements for common flutter_tts usage
  String updatedContent = content
      .replaceAll('FlutterTts', 'Tts')
      .replaceAll('flutter_tts', 'tts')
      .replaceAll('flutterTts', 'tts');

  await ttsServiceFile.writeAsString(updatedContent);
  print('   ✅ Updated TTS service (basic replacements)');
  print('   ⚠️ Manual review recommended for complex TTS usage');
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

Future<bool> _runCommand(String command, List<String> args) async {
  try {
    print('   Running: $command ${args.join(' ')}');
    final result = await Process.run(command, args);
    
    if (result.exitCode == 0) {
      print('   ✅ Success');
      return true;
    } else {
      print('   ❌ Failed with exit code: ${result.exitCode}');
      return false;
    }
  } catch (e) {
    print('   ❌ Error running command: $e');
    return false;
  }
}

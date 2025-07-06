#!/usr/bin/env dart

import 'dart:io';

/// Script to temporarily disable Firebase and enable mock mode for testing
/// Run with: dart scripts/enable_mock_mode.dart

void main() async {
  print('🧪 Enabling Mock Mode for Testing...\n');

  // Step 1: Backup main.dart
  await _backupMainFile();
  
  // Step 2: Modify main.dart to skip Firebase initialization
  await _modifyMainFile();
  
  // Step 3: Test the app
  await _testApp();
}

Future<void> _backupMainFile() async {
  print('1. Creating backup of main.dart...');
  
  final mainFile = File('lib/main.dart');
  final backupFile = File('lib/main.dart.backup');
  
  if (mainFile.existsSync()) {
    await mainFile.copy(backupFile.path);
    print('   ✅ Backup created: lib/main.dart.backup');
  } else {
    print('   ❌ main.dart not found');
  }
}

Future<void> _modifyMainFile() async {
  print('2. Modifying main.dart to skip Firebase...');
  
  final mainFile = File('lib/main.dart');
  if (!mainFile.existsSync()) {
    print('   ❌ main.dart not found');
    return;
  }
  
  String content = await mainFile.readAsString();
  
  // Comment out Firebase initialization
  content = content.replaceAll(
    'await Firebase.initializeApp(',
    '// MOCK MODE: Firebase disabled\n  // await Firebase.initializeApp(',
  );
  
  content = content.replaceAll(
    'options: DefaultFirebaseOptions.currentPlatform,',
    '// options: DefaultFirebaseOptions.currentPlatform,',
  );
  
  content = content.replaceAll(
    ');',
    '// );',
  );
  
  // Add mock mode indicator
  if (!content.contains('MOCK MODE ENABLED')) {
    content = content.replaceFirst(
      'void main() async {',
      '''void main() async {
  // 🧪 MOCK MODE ENABLED - Firebase disabled for testing
  // To restore Firebase: dart scripts/restore_firebase.dart''',
    );
  }
  
  await mainFile.writeAsString(content);
  print('   ✅ main.dart modified for mock mode');
}

Future<void> _testApp() async {
  print('3. Testing app in mock mode...');
  
  // Clean and get dependencies
  await _runCommand('flutter', ['clean']);
  await _runCommand('flutter', ['pub', 'get']);
  
  print('\n🧪 Mock Mode Enabled Successfully!');
  print('');
  print('📋 What this means:');
  print('   ✅ Firebase is disabled');
  print('   ✅ Account creation will work (stored locally)');
  print('   ✅ Sign in will work (local storage)');
  print('   ❌ Google Sign-In is disabled');
  print('   ❌ Cloud sync is disabled');
  print('');
  print('🚀 Test your app now:');
  print('   flutter run -d windows');
  print('   flutter run -d chrome');
  print('');
  print('🔄 To restore Firebase later:');
  print('   dart scripts/restore_firebase.dart');
  print('');
  print('⚠️ Remember: This is for testing only!');
  print('   Set up real Firebase for production use.');
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
    print('   ❌ Error: $e');
    return false;
  }
}

#!/usr/bin/env dart

import 'dart:io';

/// Script to test Windows build after CMake fixes
/// Run with: dart scripts/test_windows_build.dart

void main() async {
  print('🧪 Testing Windows Build Fix...\n');

  // Step 1: Check if patch file exists
  print('1. Checking patch system...');
  final patchFile = File('windows/patch_flutter_tts.cmake');
  if (patchFile.existsSync()) {
    print('   ✅ CMake patch file exists');
  } else {
    print('   ❌ CMake patch file missing');
    return;
  }

  // Step 2: Check CMakeLists.txt includes patch
  final cmakeFile = File('windows/CMakeLists.txt');
  if (cmakeFile.existsSync()) {
    final content = await cmakeFile.readAsString();
    if (content.contains('patch_flutter_tts.cmake')) {
      print('   ✅ Main CMakeLists.txt includes patch');
    } else {
      print('   ❌ Main CMakeLists.txt missing patch inclusion');
      return;
    }
  }

  // Step 3: Clean project
  print('\n2. Cleaning project...');
  await _runCommand('flutter', ['clean']);

  // Step 4: Get dependencies
  print('\n3. Getting dependencies...');
  await _runCommand('flutter', ['pub', 'get']);

  // Step 5: Check if flutter_tts CMake file exists and needs patching
  print('\n4. Checking flutter_tts plugin...');
  final flutterTtsFile = File('windows/flutter/ephemeral/.plugin_symlinks/flutter_tts/windows/CMakeLists.txt');
  if (flutterTtsFile.existsSync()) {
    final content = await flutterTtsFile.readAsString();
    if (content.contains('install TARGETS') && !content.contains('install(TARGETS')) {
      print('   ⚠️ flutter_tts CMake file needs patching (will be auto-patched)');
    } else {
      print('   ✅ flutter_tts CMake file looks good');
    }
  } else {
    print('   ℹ️ flutter_tts plugin not found (may not be installed)');
  }

  // Step 6: Attempt Windows build
  print('\n5. Testing Windows build...');
  final buildSuccess = await _runCommand('flutter', ['build', 'windows', '--debug'], expectSuccess: false);

  // Step 7: Results
  print('\n📋 Test Results:');
  if (buildSuccess) {
    print('   🎉 Windows build SUCCESSFUL!');
    print('   ✅ CMake patch system working correctly');
    print('   🚀 You can now run: flutter run -d windows');
  } else {
    print('   ❌ Windows build FAILED');
    print('   💡 Try alternative solutions:');
    print('      1. dart scripts/switch_to_tts.dart');
    print('      2. Manual CMake fix (see docs/WINDOWS_BUILD_GUIDE.md)');
    print('      3. Use web version: flutter run -d chrome');
  }

  // Step 8: Additional checks
  print('\n6. Additional diagnostics...');
  await _checkCMakeVersion();
  await _checkVisualStudio();
}

Future<bool> _runCommand(String command, List<String> args, {bool expectSuccess = true}) async {
  try {
    print('   Running: $command ${args.join(' ')}');
    final result = await Process.run(command, args);
    
    if (result.exitCode == 0) {
      print('   ✅ Success');
      return true;
    } else {
      if (expectSuccess) {
        print('   ❌ Failed with exit code: ${result.exitCode}');
        if (result.stderr.toString().isNotEmpty) {
          final stderr = result.stderr.toString();
          // Show only relevant error lines
          final errorLines = stderr.split('\n')
              .where((line) => line.contains('Error') || line.contains('error'))
              .take(3);
          for (final line in errorLines) {
            print('      $line');
          }
        }
      }
      return false;
    }
  } catch (e) {
    print('   ❌ Error running command: $e');
    return false;
  }
}

Future<void> _checkCMakeVersion() async {
  try {
    final result = await Process.run('cmake', ['--version']);
    if (result.exitCode == 0) {
      final version = result.stdout.toString().split('\n').first;
      print('   ✅ CMake found: $version');
    } else {
      print('   ❌ CMake not found or not working');
    }
  } catch (e) {
    print('   ❌ CMake not available: $e');
  }
}

Future<void> _checkVisualStudio() async {
  try {
    final result = await Process.run('where', ['cl']);
    if (result.exitCode == 0) {
      print('   ✅ Visual Studio C++ compiler found');
    } else {
      print('   ⚠️ Visual Studio C++ compiler not found in PATH');
    }
  } catch (e) {
    print('   ⚠️ Could not check Visual Studio: $e');
  }
}

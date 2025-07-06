#!/usr/bin/env dart

import 'dart:io';

/// Script to fix CMake issues with flutter_tts on Windows
/// Run with: dart scripts/fix_cmake_windows.dart

void main() async {
  print('🔧 Fixing CMake issues for Windows build...\n');

  // Step 1: Clean the project
  print('1. Cleaning Flutter project...');
  await _runCommand('flutter', ['clean']);
  
  // Step 2: Get dependencies
  print('2. Getting dependencies...');
  await _runCommand('flutter', ['pub', 'get']);
  
  // Step 3: Check for problematic CMake file
  print('3. Checking for CMake issues...');
  final cmakeFile = File('windows/flutter/ephemeral/.plugin_symlinks/flutter_tts/windows/CMakeLists.txt');
  
  if (cmakeFile.existsSync()) {
    print('   Found flutter_tts CMakeLists.txt');
    await _fixCMakeFile(cmakeFile);
  } else {
    print('   CMakeLists.txt not found - may be fixed in newer version');
  }
  
  // Step 4: Try to build for Windows
  print('4. Testing Windows build...');
  final buildResult = await _runCommand('flutter', ['build', 'windows', '--debug'], expectSuccess: false);
  
  if (buildResult) {
    print('✅ Windows build successful!');
  } else {
    print('❌ Build still failing. Try alternative solutions below.');
    _printAlternativeSolutions();
  }
}

Future<void> _fixCMakeFile(File cmakeFile) async {
  try {
    print('   Reading CMakeLists.txt...');
    final content = await cmakeFile.readAsString();
    
    // Check if the file has the problematic install command
    if (content.contains('install TARGETS') && !content.contains('install(TARGETS')) {
      print('   Found problematic install command, fixing...');
      
      // Fix the install command syntax
      final fixedContent = content.replaceAll(
        RegExp(r'install\s+TARGETS\s+([^\s]+)\s+([^\n]+)'),
        'install(TARGETS \$1 \$2)'
      );
      
      // Backup original file
      final backupFile = File('${cmakeFile.path}.backup');
      await cmakeFile.copy(backupFile.path);
      print('   Created backup: ${backupFile.path}');
      
      // Write fixed content
      await cmakeFile.writeAsString(fixedContent);
      print('   ✅ Fixed CMakeLists.txt');
    } else {
      print('   CMakeLists.txt appears to be already fixed');
    }
  } catch (e) {
    print('   ❌ Error fixing CMakeLists.txt: $e');
  }
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
          print('   Error: ${result.stderr}');
        }
      }
      return false;
    }
  } catch (e) {
    print('   ❌ Error running command: $e');
    return false;
  }
}

void _printAlternativeSolutions() {
  print('\n🔧 Alternative Solutions:\n');
  
  print('Option A: Use alternative TTS package');
  print('1. Remove flutter_tts:');
  print('   flutter pub remove flutter_tts');
  print('2. Add text_to_speech instead:');
  print('   flutter pub add text_to_speech');
  print('');
  
  print('Option B: Disable TTS for Windows');
  print('1. Wrap TTS code with platform checks:');
  print('   if (!Platform.isWindows) {');
  print('     // TTS code here');
  print('   }');
  print('');
  
  print('Option C: Manual CMake fix');
  print('1. Navigate to:');
  print('   windows/flutter/ephemeral/.plugin_symlinks/flutter_tts/windows/CMakeLists.txt');
  print('2. Find line with "install TARGETS"');
  print('3. Change to: install(TARGETS ... ) with parentheses');
  print('');
  
  print('Option D: Use web version for testing');
  print('   flutter run -d chrome');
  print('');
  
  print('📖 For more help, see: docs/WINDOWS_BUILD_GUIDE.md');
}

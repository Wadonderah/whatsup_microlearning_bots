#!/usr/bin/env dart

import 'dart:io';

/// Complete Windows build script with flutter_tts fix
/// Run with: dart scripts/build_windows.dart

void main() async {
  print('🪟 Windows Build Script with flutter_tts Fix\n');

  // Step 1: Clean project
  print('1. Cleaning project...');
  await _runCommand('flutter', ['clean']);

  // Step 2: Get dependencies
  print('2. Getting dependencies...');
  await _runCommand('flutter', ['pub', 'get']);

  // Step 3: Wait for symlinks to be created
  print('3. Waiting for plugin symlinks...');
  await Future.delayed(Duration(seconds: 3));

  // Step 4: Apply flutter_tts fix
  print('4. Applying flutter_tts CMake fix...');
  await _fixFlutterTtsCMake();

  // Step 5: Build for Windows
  print('5. Building for Windows...');
  final buildSuccess = await _runCommand('flutter', ['build', 'windows', '--debug'], expectSuccess: false);

  // Step 6: Results and next steps
  print('\n📋 Build Results:');
  if (buildSuccess) {
    print('🎉 SUCCESS! Windows build completed!');
    print('');
    print('Next steps:');
    print('  🚀 Run app: flutter run -d windows');
    print('  📦 Release build: flutter build windows --release');
    print('  🧪 Test features: Verify TTS and other functionality');
  } else {
    print('❌ Build failed. Trying alternative solutions...');
    await _tryAlternativeSolutions();
  }
}

Future<void> _fixFlutterTtsCMake() async {
  final cmakeFile = File('windows/flutter/ephemeral/.plugin_symlinks/flutter_tts/windows/CMakeLists.txt');
  
  if (!cmakeFile.existsSync()) {
    print('   ⚠️ flutter_tts CMake file not found - may not be needed');
    return;
  }

  final content = await cmakeFile.readAsString();
  
  if (content.contains('install(TARGETS')) {
    print('   ✅ flutter_tts already fixed');
    return;
  }

  if (!content.contains('install TARGETS')) {
    print('   ℹ️ No problematic install commands found');
    return;
  }

  print('   🔧 Fixing CMake syntax...');
  
  // Create backup
  final backupFile = File('${cmakeFile.path}.backup');
  await cmakeFile.copy(backupFile.path);

  // Apply fixes
  String fixedContent = content;
  
  // Fix the specific known issue
  fixedContent = fixedContent.replaceAll(
    'install TARGETS flutter_tts_windows_plugin RUNTIME DESTINATION "\${INSTALL_BINDIR}"',
    'install(TARGETS flutter_tts_windows_plugin RUNTIME DESTINATION "\${INSTALL_BINDIR}")'
  );

  // Fix any other install TARGETS patterns
  fixedContent = fixedContent.replaceAllMapped(
    RegExp(r'install TARGETS ([^\n]+)'),
    (match) => 'install(TARGETS ${match.group(1)})'
  );

  await cmakeFile.writeAsString(fixedContent);
  print('   ✅ CMake syntax fixed');
}

Future<void> _tryAlternativeSolutions() async {
  print('\n🔄 Trying alternative solutions...\n');

  // Option 1: Switch to tts package
  print('Option 1: Switch to alternative TTS package');
  print('  Command: dart scripts/switch_to_tts.dart');
  
  // Option 2: Manual fix instructions
  print('\nOption 2: Manual CMake fix');
  print('  1. Navigate to: windows/flutter/ephemeral/.plugin_symlinks/flutter_tts/windows/CMakeLists.txt');
  print('  2. Find: install TARGETS flutter_tts_windows_plugin...');
  print('  3. Change to: install(TARGETS flutter_tts_windows_plugin...)');
  print('  4. Add parentheses around the command');

  // Option 3: Web development
  print('\nOption 3: Continue with web development');
  print('  Command: flutter run -d chrome');

  // Option 4: Check system requirements
  print('\nOption 4: Verify system requirements');
  await _checkSystemRequirements();

  print('\n💡 Recommendation: Try Option 1 first (switch to tts package)');
}

Future<void> _checkSystemRequirements() async {
  print('  Checking system requirements...');
  
  // Check CMake
  try {
    final cmakeResult = await Process.run('cmake', ['--version']);
    if (cmakeResult.exitCode == 0) {
      final version = cmakeResult.stdout.toString().split('\n').first;
      print('    ✅ CMake: $version');
    } else {
      print('    ❌ CMake not found');
    }
  } catch (e) {
    print('    ❌ CMake not available');
  }

  // Check Visual Studio
  try {
    final vsResult = await Process.run('where', ['cl']);
    if (vsResult.exitCode == 0) {
      print('    ✅ Visual Studio C++ compiler found');
    } else {
      print('    ❌ Visual Studio C++ compiler not found');
    }
  } catch (e) {
    print('    ❌ Visual Studio check failed');
  }

  // Check Flutter doctor
  print('    Running flutter doctor...');
  await _runCommand('flutter', ['doctor', '-v'], expectSuccess: false);
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
      }
      return false;
    }
  } catch (e) {
    print('   ❌ Error: $e');
    return false;
  }
}

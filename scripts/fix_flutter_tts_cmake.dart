#!/usr/bin/env dart

import 'dart:io';

/// Direct fix for flutter_tts CMake syntax issue
/// Run with: dart scripts/fix_flutter_tts_cmake.dart

void main() async {
  print('🔧 Fixing flutter_tts CMake syntax issue...\n');

  // Step 1: Ensure dependencies are installed
  print('1. Ensuring dependencies are installed...');
  await _runCommand('flutter', ['pub', 'get']);

  // Step 2: Wait a moment for symlinks to be created
  await Future.delayed(Duration(seconds: 2));

  // Step 3: Find and fix the CMake file
  print('2. Looking for flutter_tts CMake file...');
  final cmakeFile = File('windows/flutter/ephemeral/.plugin_symlinks/flutter_tts/windows/CMakeLists.txt');
  
  if (!cmakeFile.existsSync()) {
    print('   ❌ flutter_tts CMake file not found');
    print('   💡 Try running: flutter clean && flutter pub get');
    return;
  }

  print('   ✅ Found flutter_tts CMake file');

  // Step 4: Read and analyze the file
  print('3. Analyzing CMake file...');
  final content = await cmakeFile.readAsString();
  
  if (content.contains('install(TARGETS')) {
    print('   ✅ CMake file already fixed');
    return;
  }

  if (!content.contains('install TARGETS')) {
    print('   ℹ️ No install TARGETS command found - may not need fixing');
    return;
  }

  // Step 5: Create backup
  print('4. Creating backup...');
  final backupFile = File('${cmakeFile.path}.backup');
  await cmakeFile.copy(backupFile.path);
  print('   ✅ Backup created: ${backupFile.path}');

  // Step 6: Apply the fix
  print('5. Applying CMake syntax fix...');
  
  // The exact fix for the known issue
  String fixedContent = content.replaceAll(
    'install TARGETS flutter_tts_windows_plugin RUNTIME DESTINATION "\${INSTALL_BINDIR}"',
    'install(TARGETS flutter_tts_windows_plugin RUNTIME DESTINATION "\${INSTALL_BINDIR}")'
  );

  // Fallback fix for any other install TARGETS patterns
  fixedContent = fixedContent.replaceAllMapped(
    RegExp(r'install TARGETS ([^\n]+)'),
    (match) => 'install(TARGETS ${match.group(1)})'
  );

  // Write the fixed content
  await cmakeFile.writeAsString(fixedContent);
  print('   ✅ CMake syntax fixed!');

  // Step 7: Verify the fix
  print('6. Verifying fix...');
  final verifyContent = await cmakeFile.readAsString();
  if (verifyContent.contains('install(TARGETS')) {
    print('   ✅ Fix verified successfully');
  } else {
    print('   ❌ Fix verification failed');
    return;
  }

  // Step 8: Test build
  print('7. Testing Windows build...');
  final buildSuccess = await _runCommand('flutter', ['build', 'windows', '--debug'], expectSuccess: false);

  if (buildSuccess) {
    print('\n🎉 SUCCESS! Windows build completed successfully!');
    print('🚀 You can now run: flutter run -d windows');
  } else {
    print('\n❌ Build still failing. Additional troubleshooting needed.');
    print('💡 Try these alternatives:');
    print('   1. dart scripts/switch_to_tts.dart');
    print('   2. flutter run -d chrome (web version)');
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
        // Show relevant error lines
        final stderr = result.stderr.toString();
        if (stderr.isNotEmpty) {
          final errorLines = stderr.split('\n')
              .where((line) => line.toLowerCase().contains('error'))
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

#!/usr/bin/env dart

import 'dart:io';

/// Definitive fix for flutter_tts CMake issues
/// Run with: dart scripts/fix_flutter_tts_cmake_definitive.dart

void main() async {
  print('🔧 Applying definitive fix for flutter_tts CMake issues...\n');

  // Step 1: Clean and get dependencies
  print('1. Cleaning project and getting dependencies...');
  await _runCommand('flutter', ['clean']);
  await _runCommand('flutter', ['pub', 'get']);

  // Wait for symlinks to be created
  await Future.delayed(Duration(seconds: 2));

  // Step 2: Fix the CMake file
  print('2. Fixing flutter_tts CMake file...');
  await _fixCMakeFile();

  // Step 3: Test the build
  print('3. Testing Windows build...');
  final buildSuccess = await _runCommand('flutter', ['build', 'windows', '--debug'], expectSuccess: false);

  if (buildSuccess) {
    print('\n🎉 SUCCESS! Windows build completed successfully!');
    print('✅ flutter_tts CMake issues have been resolved');
    print('🚀 You can now run: flutter run -d windows');
  } else {
    print('\n❌ Build still failing. Trying alternative approach...');
    await _tryAlternativeApproach();
  }
}

Future<void> _fixCMakeFile() async {
  final cmakeFile = File('windows/flutter/ephemeral/.plugin_symlinks/flutter_tts/windows/CMakeLists.txt');
  
  if (!cmakeFile.existsSync()) {
    print('   ⚠️ flutter_tts CMake file not found');
    return;
  }

  // Create backup
  final backupFile = File('${cmakeFile.path}.backup');
  await cmakeFile.copy(backupFile.path);
  print('   📁 Created backup: ${backupFile.path}');

  // Read current content
  final content = await cmakeFile.readAsString();

  // Create a completely fixed version
  final fixedContent = '''cmake_minimum_required(VERSION 3.14)
if(POLICY CMP0153)
  cmake_policy(SET CMP0153 NEW)
endif()
set(PROJECT_NAME "flutter_tts")
project(\${PROJECT_NAME} LANGUAGES CXX)

################ NuGet install begin ################
find_program(NUGET_EXE NAMES nuget)
if(NOT NUGET_EXE)
	message("NUGET.EXE not found.")
	message(FATAL_ERROR "Please install this executable, and run CMake again.")
endif()

execute_process(
  COMMAND \${NUGET_EXE} install "Microsoft.Windows.CppWinRT" -Version 2.0.210503.1 -ExcludeVersion -OutputDirectory \${CMAKE_BINARY_DIR}/packages
)
################ NuGet install end ################

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "flutter_tts_plugin")

add_library(\${PLUGIN_NAME} SHARED
  "flutter_tts_plugin.cpp"
)
apply_standard_settings(\${PLUGIN_NAME})
set_target_properties(\${PLUGIN_NAME} PROPERTIES
CXX_VISIBILITY_PRESET hidden)
target_compile_features(\${PLUGIN_NAME} PUBLIC cxx_std_20)
target_compile_definitions(\${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(\${PLUGIN_NAME} INTERFACE
  "\${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(\${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

if(MSVC)
    target_compile_options(\${PLUGIN_NAME} PRIVATE "/await")
endif()

# List of absolute paths to libraries that should be bundled with the plugin
set(flutter_tts_bundled_libraries
  ""
  PARENT_SCOPE
)

################ NuGet import begin ################
set_target_properties(\${PLUGIN_NAME} PROPERTIES VS_PROJECT_IMPORT
  \${CMAKE_BINARY_DIR}/packages/Microsoft.Windows.CppWinRT/build/native/Microsoft.Windows.CppWinRT.props
)

target_link_libraries(\${PLUGIN_NAME} PRIVATE
  \${CMAKE_BINARY_DIR}/packages/Microsoft.Windows.CppWinRT/build/native/Microsoft.Windows.CppWinRT.targets
)
################ NuGet import end ################
''';

  // Write the fixed content
  await cmakeFile.writeAsString(fixedContent);
  print('   ✅ CMake file fixed successfully');
}

Future<void> _tryAlternativeApproach() async {
  print('\n🔄 Trying alternative approaches...\n');

  print('Option 1: Switch to alternative TTS package');
  print('  Command: dart scripts/switch_to_tts.dart');
  print('');

  print('Option 2: Disable TTS for Windows');
  print('  Add platform check in your TTS code:');
  print('  if (!Platform.isWindows) {');
  print('    // TTS code here');
  print('  }');
  print('');

  print('Option 3: Use web version for development');
  print('  Command: flutter run -d chrome');
  print('');

  print('💡 Recommendation: Try Option 1 (switch to alternative TTS package)');
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
    print('   ❌ Error: $e');
    return false;
  }
}

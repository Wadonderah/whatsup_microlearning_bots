# 🪟 Windows Build Fix Guide

## Problem
CMake error when building for Windows:
```
CMake Error at flutter/ephemeral/.plugin_symlinks/flutter_tts/windows/CMakeLists.txt:18:
Parse error. Expected "(", got identifier with text "install".
```

## Root Cause
- The `flutter_tts` plugin has outdated CMake syntax
- Newer CMake versions (3.20+) require parentheses for `install()` commands
- Flutter 3.x uses newer CMake versions with stricter syntax

## 🚀 Automated Solutions (Recommended)

### Solution 1: Use Automatic CMake Patch ✅
The project now includes an automatic patch system:

```bash
# Clean and rebuild - the patch will apply automatically
flutter clean
flutter pub get
flutter build windows --debug
```

**How it works:**
- `windows/patch_flutter_tts.cmake` automatically fixes CMake syntax
- Applied before Flutter subdirectory is processed
- No manual intervention required

### Solution 2: Switch to Alternative TTS Package
If CMake issues persist:

```bash
# Run the automated switch script
dart scripts/switch_to_tts.dart

# Or manually:
flutter pub remove flutter_tts
flutter pub add tts
```

## 🔧 Manual Solutions

### Solution 1: Update Plugin (Recommended)
```bash
# Clean project
flutter clean

# Update dependencies
flutter pub get

# Try building
flutter build windows --debug
```

The `flutter_tts` version has been updated to `^4.2.0` which should fix the CMake issue.

### Solution 2: Run Automated Fix Script
```bash
dart scripts/fix_cmake_windows.dart
```

This script will:
- Clean your project
- Check for CMake issues
- Attempt to fix them automatically
- Test the Windows build

### Solution 3: Manual CMake Fix
If the above don't work:

1. **Navigate to the problematic file:**
   ```
   windows/flutter/ephemeral/.plugin_symlinks/flutter_tts/windows/CMakeLists.txt
   ```

2. **Find line 18 (or search for "install TARGETS"):**
   ```cmake
   install TARGETS flutter_tts_windows_plugin ...  # ❌ Incorrect
   ```

3. **Change to:**
   ```cmake
   install(TARGETS flutter_tts_windows_plugin ...)  # ✅ Correct
   ```

4. **Rebuild:**
   ```bash
   flutter clean
   flutter build windows --debug
   ```

### Solution 4: Alternative TTS Package
If CMake issues persist:

```bash
# Remove problematic package
flutter pub remove flutter_tts

# Add alternative
flutter pub add text_to_speech

# Update your code to use the new package
```

### Solution 5: Platform-Specific Code
Disable TTS on Windows temporarily:

```dart
import 'dart:io';

// In your TTS code:
if (!Platform.isWindows) {
  // TTS functionality here
  await flutterTts.speak(text);
} else {
  // Alternative for Windows (e.g., show text dialog)
  print('TTS not available on Windows: $text');
}
```

## 🧪 Testing Your Fix

### Test Windows Build
```bash
flutter build windows --debug
```

### Test Other Platforms
```bash
# Web (should work fine)
flutter run -d chrome

# Android (if you have emulator)
flutter run -d android

# iOS (if on macOS)
flutter run -d ios
```

## 🔍 Troubleshooting

### Still Getting CMake Errors?
1. **Check CMake version:**
   ```bash
   cmake --version
   ```
   Should be 3.15 or higher.

2. **Update Visual Studio:**
   - Install Visual Studio 2019 or 2022
   - Include "Desktop development with C++" workload

3. **Clear Flutter cache:**
   ```bash
   flutter clean
   flutter pub cache clean
   flutter pub get
   ```

### Build Succeeds but App Crashes?
1. **Check Windows dependencies:**
   - Ensure all required DLLs are included
   - Test in release mode: `flutter build windows --release`

2. **Check plugin compatibility:**
   - Some plugins may not support Windows desktop
   - Use `flutter doctor -v` to check for issues

### Alternative Development Approach
If Windows builds continue to fail:

1. **Develop on web:**
   ```bash
   flutter run -d chrome
   ```

2. **Test on mobile:**
   ```bash
   flutter run -d android  # or ios
   ```

3. **Build Windows later:**
   - Focus on core functionality first
   - Add Windows support after main features work

## 📋 Verification Checklist

- [ ] Updated `flutter_tts` to version 4.2.0+
- [ ] Ran `flutter clean && flutter pub get`
- [ ] CMake file fixed (if manual fix needed)
- [ ] Windows build completes without errors
- [ ] App launches on Windows
- [ ] TTS functionality works (or gracefully disabled)

## 🆘 Still Need Help?

If none of these solutions work:

1. **Check Flutter version:**
   ```bash
   flutter --version
   ```
   Consider upgrading to latest stable.

2. **Check system requirements:**
   - Windows 10 version 1903 or higher
   - Visual Studio 2019/2022 with C++ tools
   - CMake 3.15+

3. **Create minimal test:**
   - Create new Flutter project
   - Add only `flutter_tts`
   - Test if it builds

4. **Report issue:**
   - If it's a plugin bug, report to flutter_tts repository
   - Include your Flutter version, Windows version, and full error log

## 🎯 Next Steps

Once Windows build works:
1. Test all app features on Windows
2. Optimize for desktop UI/UX
3. Test with different screen sizes
4. Prepare for Windows Store deployment (if needed)

Your app should now build successfully on Windows! 🎉

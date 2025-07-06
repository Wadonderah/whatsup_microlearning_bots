# 🚨 URGENT: Windows Build Fix for flutter_tts

## The Problem
```
CMake Error at flutter/ephemeral/.plugin_symlinks/flutter_tts/windows/CMakeLists.txt:18:
Parse error. Expected "(", got identifier with text "install".
```

## 🚀 QUICK FIX (Choose One)

### Option 1: Automated Fix Script ⭐ RECOMMENDED
```bash
dart scripts/build_windows.dart
```
This script will:
- Clean your project
- Get dependencies  
- Automatically fix the CMake syntax
- Build for Windows
- Provide alternatives if it fails

### Option 2: Direct CMake Fix
```bash
# 1. Get dependencies first
flutter pub get

# 2. Run the specific fix
dart scripts/fix_flutter_tts_cmake.dart
```

### Option 3: Manual Fix (If scripts don't work)
1. Navigate to: `windows/flutter/ephemeral/.plugin_symlinks/flutter_tts/windows/CMakeLists.txt`
2. Find line ~18: `install TARGETS flutter_tts_windows_plugin RUNTIME DESTINATION "${INSTALL_BINDIR}"`
3. Change to: `install(TARGETS flutter_tts_windows_plugin RUNTIME DESTINATION "${INSTALL_BINDIR}")`
4. Save and run: `flutter build windows --debug`

### Option 4: Switch to Alternative Package
```bash
dart scripts/switch_to_tts.dart
```

## ✅ Verification
After applying the fix, you should see:
```
Building Windows application...
Building Windows application... done
Launching lib\main.dart on Windows in debug mode...
```

## 🆘 If Nothing Works
1. **Use Web Version**: `flutter run -d chrome`
2. **Check System**: Ensure Visual Studio 2019/2022 with C++ tools installed
3. **Update Flutter**: `flutter upgrade`
4. **Clean Everything**: `flutter clean && flutter pub cache clean && flutter pub get`

## 📋 What's Been Done
- ✅ Created automatic CMake patch system
- ✅ Added direct fix scripts
- ✅ Provided alternative TTS package option
- ✅ Enhanced build process with error handling

## 🎯 Next Steps After Fix
1. Test the Windows app: `flutter run -d windows`
2. Verify TTS functionality works
3. Build release version: `flutter build windows --release`

---
**The core issue**: flutter_tts plugin uses outdated CMake syntax that newer Flutter versions don't accept. The fix adds required parentheses to the install command.

#!/usr/bin/env dart

import 'dart:io';

/// Setup checker script for WhatsApp MicroLearning Bot
/// Run with: dart scripts/check_setup.dart

void main() {
  print('🔍 WhatsApp MicroLearning Bot - Setup Checker\n');

  bool allGood = true;

  // Check 1: Asset directories
  print('📁 Checking asset directories...');
  final assetDirs = [
    'assets/images/splash',
    'assets/images/onboarding',
    'assets/images/categories',
    'assets/images/achievements',
    'assets/images/social',
    'assets/images/illustrations',
    'assets/images/icons',
    'assets/images/animations',
  ];

  for (final dir in assetDirs) {
    if (Directory(dir).existsSync()) {
      print('  ✅ $dir exists');
    } else {
      print('  ❌ $dir missing');
      allGood = false;
    }
  }

  // Check 2: Critical asset files
  print('\n🖼️ Checking critical asset files...');
  final criticalAssets = [
    'assets/images/splash/brain_animation.gif',
    'assets/images/onboarding/onboarding_1.png',
    'assets/images/onboarding/onboarding_2.png',
    'assets/images/onboarding/onboarding_3.png',
    'assets/images/onboarding/onboarding_4.png',
  ];

  int existingAssets = 0;
  for (final asset in criticalAssets) {
    if (File(asset).existsSync()) {
      final content = File(asset).readAsStringSync();
      if (content.contains('placeholder')) {
        print('  📝 $asset exists (placeholder)');
      } else {
        print('  ✅ $asset exists (real file)');
        existingAssets++;
      }
    } else {
      print('  ❌ $asset missing');
    }
  }

  if (existingAssets == 0) {
    print('  💡 All assets are placeholders - app will use fallback icons');
  }

  // Check 3: Configuration files
  print('\n⚙️ Checking configuration files...');

  // Check pubspec.yaml
  if (File('pubspec.yaml').existsSync()) {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    if (pubspec.contains('assets:')) {
      print('  ✅ pubspec.yaml has assets section');
    } else {
      print('  ❌ pubspec.yaml missing assets section');
      allGood = false;
    }
  } else {
    print('  ❌ pubspec.yaml not found');
    allGood = false;
  }

  // Check firebase_options.dart
  if (File('lib/firebase_options.dart').existsSync()) {
    final firebaseOptions =
        File('lib/firebase_options.dart').readAsStringSync();
    if (firebaseOptions.contains('your-project-id') ||
        firebaseOptions.contains('whatsup-microlearning-bot')) {
      print('  ⚠️ firebase_options.dart needs configuration');
    } else {
      print('  ✅ firebase_options.dart configured');
    }
  } else {
    print('  ❌ firebase_options.dart not found');
    allGood = false;
  }

  // Check web/index.html
  if (File('web/index.html').existsSync()) {
    final indexHtml = File('web/index.html').readAsStringSync();
    if (indexHtml.contains('YOUR_GOOGLE_CLIENT_ID')) {
      print('  ⚠️ web/index.html needs Google Client ID');
    } else if (indexHtml.contains('google-signin-client_id')) {
      print('  ✅ web/index.html has Google Sign-In config');
    } else {
      print('  ❌ web/index.html missing Google Sign-In config');
      allGood = false;
    }
  } else {
    print('  ❌ web/index.html not found');
    allGood = false;
  }

  // Check .env file
  if (File('.env').existsSync()) {
    print('  ✅ .env file exists');
  } else {
    print('  ⚠️ .env file missing (optional)');
  }

  // Check 4: Dependencies
  print('\n📦 Checking dependencies...');
  if (File('pubspec.lock').existsSync()) {
    print('  ✅ Dependencies installed (pubspec.lock exists)');
  } else {
    print('  ❌ Run "flutter pub get" to install dependencies');
    allGood = false;
  }

  // Summary
  print('\n📋 Summary:');
  if (allGood) {
    print('  🎉 All critical checks passed!');
    print('  💡 Review warnings above and update configurations as needed.');
  } else {
    print('  ⚠️ Some issues found. Please fix the ❌ items above.');
  }

  print('\n📖 For detailed setup instructions, see: docs/SETUP_GUIDE.md');
  print('🚀 Run "flutter run -d chrome" to test your app');
}

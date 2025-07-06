#!/usr/bin/env dart

import 'dart:io';

/// Script to test authentication setup and provide guidance
/// Run with: dart scripts/test_auth_setup.dart

void main() async {
  print('🔐 Testing Authentication Setup...\n');

  // Check Firebase configuration
  await _checkFirebaseConfig();
  
  // Check Google Sign-In config
  await _checkGoogleSignInConfig();
  
  // Check web configuration
  await _checkWebConfig();
  
  // Provide recommendations
  _provideRecommendations();
}

Future<void> _checkFirebaseConfig() async {
  print('1. Checking Firebase Configuration...');
  
  final firebaseOptionsFile = File('lib/firebase_options.dart');
  if (!firebaseOptionsFile.existsSync()) {
    print('   ❌ firebase_options.dart not found');
    return;
  }
  
  final content = await firebaseOptionsFile.readAsString();
  
  // Check for placeholder values
  final hasPlaceholders = content.contains('AIzaSyDemoKey') || 
                         content.contains('demo-replace') ||
                         content.contains('YOUR_ACTUAL');
  
  if (hasPlaceholders) {
    print('   ❌ Firebase config contains placeholder values');
    print('   💡 Update lib/firebase_options.dart with real Firebase config');
  } else {
    print('   ✅ Firebase config appears to be set up');
  }
  
  // Check for required fields
  final hasApiKey = content.contains("apiKey: '") && !content.contains('demo');
  final hasProjectId = content.contains("projectId: '") && !content.contains('demo');
  
  if (hasApiKey && hasProjectId) {
    print('   ✅ Required Firebase fields present');
  } else {
    print('   ⚠️ Some Firebase fields may be missing or invalid');
  }
}

Future<void> _checkGoogleSignInConfig() async {
  print('\n2. Checking Google Sign-In Configuration...');
  
  final webIndexFile = File('web/index.html');
  if (!webIndexFile.existsSync()) {
    print('   ❌ web/index.html not found');
    return;
  }
  
  final content = await webIndexFile.readAsString();
  
  // Check for Google Client ID
  if (content.contains('YOUR_GOOGLE_CLIENT_ID')) {
    print('   ❌ Google Client ID not configured (placeholder found)');
    print('   💡 Update web/index.html with real Google Client ID');
  } else if (content.contains('google-signin-client_id')) {
    print('   ✅ Google Client ID appears to be configured');
  } else {
    print('   ⚠️ Google Sign-In meta tag not found');
  }
  
  // Check environment config
  final envConfigFile = File('lib/core/config/environment_config.dart');
  if (envConfigFile.existsSync()) {
    final envContent = await envConfigFile.readAsString();
    if (envContent.contains('YOUR_ACTUAL_GOOGLE_CLIENT_ID')) {
      print('   ⚠️ Environment config has placeholder Google Client ID');
    } else {
      print('   ✅ Environment config appears updated');
    }
  }
}

Future<void> _checkWebConfig() async {
  print('\n3. Checking Web Configuration...');
  
  final webIndexFile = File('web/index.html');
  if (!webIndexFile.existsSync()) {
    print('   ❌ web/index.html not found');
    return;
  }
  
  final content = await webIndexFile.readAsString();
  
  // Check Firebase web config
  if (content.contains('your-api-key') || content.contains('your-project-id')) {
    print('   ❌ Web Firebase config has placeholder values');
    print('   💡 Update window.firebaseConfig in web/index.html');
  } else {
    print('   ✅ Web Firebase config appears to be set up');
  }
  
  // Check for required scripts
  final hasFirebaseScripts = content.contains('firebase-app-compat.js') &&
                            content.contains('firebase-auth-compat.js');
  
  if (hasFirebaseScripts) {
    print('   ✅ Firebase scripts loaded');
  } else {
    print('   ⚠️ Firebase scripts may be missing');
  }
}

void _provideRecommendations() {
  print('\n📋 Recommendations:\n');
  
  print('🔥 **IMMEDIATE ACTIONS NEEDED:**');
  print('   1. Set up a Firebase project at https://console.firebase.google.com/');
  print('   2. Enable Authentication (Email/Password + Google)');
  print('   3. Create a Firestore database');
  print('   4. Update lib/firebase_options.dart with real config');
  print('   5. Update web/index.html with real Firebase config');
  print('   6. Add real Google Client ID to web/index.html');
  print('');
  
  print('🧪 **TESTING:**');
  print('   1. Run: flutter clean && flutter pub get');
  print('   2. Test web: flutter run -d chrome');
  print('   3. Test Windows: flutter run -d windows');
  print('   4. Try creating an account with email/password');
  print('   5. Try Google Sign-In (web only)');
  print('');
  
  print('📖 **DETAILED GUIDE:**');
  print('   See FIREBASE_SETUP_GUIDE.md for step-by-step instructions');
  print('');
  
  print('🐛 **DEBUGGING:**');
  print('   - Check browser console for detailed error messages');
  print('   - Look for "Firebase Error" messages in app logs');
  print('   - Verify Firebase project settings match your config');
  print('');
  
  print('✅ **ONCE CONFIGURED:**');
  print('   - Manual signup should work');
  print('   - Google Sign-In should work on web');
  print('   - User data will be stored in Firestore');
}

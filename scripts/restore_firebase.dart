#!/usr/bin/env dart

import 'dart:io';

/// Script to restore Firebase initialization
/// Run with: dart scripts/restore_firebase.dart

void main() async {
  print('🔥 Restoring Firebase Mode...\n');

  final mainFile = File('lib/main.dart');
  final backupFile = File('lib/main.dart.backup');
  
  if (backupFile.existsSync()) {
    print('1. Restoring from backup...');
    await backupFile.copy(mainFile.path);
    await backupFile.delete();
    print('   ✅ Firebase mode restored');
    print('   ✅ Backup file removed');
  } else {
    print('1. No backup found, manually restoring...');
    
    if (!mainFile.existsSync()) {
      print('   ❌ main.dart not found');
      return;
    }
    
    String content = await mainFile.readAsString();
    
    // Restore Firebase initialization
    content = content.replaceAll(
      '// MOCK MODE: Firebase disabled\n  // await Firebase.initializeApp(',
      'await Firebase.initializeApp(',
    );
    
    content = content.replaceAll(
      '// options: DefaultFirebaseOptions.currentPlatform,',
      'options: DefaultFirebaseOptions.currentPlatform,',
    );
    
    content = content.replaceAll(
      '// );',
      ');',
    );
    
    // Remove mock mode comments
    content = content.replaceAll(
      RegExp(r'  // 🧪 MOCK MODE ENABLED.*\n.*\n'), 
      '',
    );
    
    await mainFile.writeAsString(content);
    print('   ✅ Firebase initialization restored');
  }
  
  print('\n🔥 Firebase Mode Restored!');
  print('');
  print('⚠️ Remember: You still need to configure Firebase properly');
  print('   See FIREBASE_SETUP_GUIDE.md for instructions');
}

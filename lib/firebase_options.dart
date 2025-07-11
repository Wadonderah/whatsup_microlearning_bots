// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDemoKey-Replace-With-Your-Actual-Web-API-Key',
    appId: '1:123456789:web:demo-replace-with-your-app-id',
    messagingSenderId: '123456789',
    projectId: 'whatsup-microlearning-demo',
    authDomain: 'whatsup-microlearning-demo.firebaseapp.com',
    storageBucket: 'whatsup-microlearning-demo.appspot.com',
    measurementId: 'G-DEMO123456',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoKey-Replace-With-Your-Android-API-Key',
    appId: '1:123456789:android:demo-replace-with-your-app-id',
    messagingSenderId: '123456789',
    projectId: 'whatsup-microlearning-demo',
    storageBucket: 'whatsup-microlearning-demo.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoKey-Replace-With-Your-iOS-API-Key',
    appId: '1:123456789:ios:demo-replace-with-your-app-id',
    messagingSenderId: '123456789',
    projectId: 'whatsup-microlearning-demo',
    storageBucket: 'whatsup-microlearning-demo.appspot.com',
    iosBundleId: 'com.example.whatsupMicrolearningBots',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDemoKey-Replace-With-Your-macOS-API-Key',
    appId: '1:123456789:macos:demo-replace-with-your-app-id',
    messagingSenderId: '123456789',
    projectId: 'whatsup-microlearning-demo',
    storageBucket: 'whatsup-microlearning-demo.appspot.com',
    iosBundleId: 'com.example.whatsupMicrolearningBots',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDemoKey-Replace-With-Your-Windows-API-Key',
    appId: '1:123456789:windows:demo-replace-with-your-app-id',
    messagingSenderId: '123456789',
    projectId: 'whatsup-microlearning-demo',
    authDomain: 'whatsup-microlearning-demo.firebaseapp.com',
    storageBucket: 'whatsup-microlearning-demo.appspot.com',
    measurementId: 'G-DEMO123456',
  );
}

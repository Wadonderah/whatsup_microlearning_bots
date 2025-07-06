import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/firestore_service.dart';
import 'core/services/notification_service.dart';
import 'firebase_options.dart';
import 'routes/auth_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Handle case where .env file doesn't exist
    debugPrint('Warning: .env file not found. Using default configuration.');
  }

  // Initialize Firebase with proper options
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Firebase initialization failed: $e');
    debugPrint('🔧 Running in development mode without Firebase');
    // Continue running in development mode
  }

  // Initialize Firestore service (only if Firebase is initialized)
  if (firebaseInitialized) {
    try {
      await FirestoreService.instance.initialize();
      debugPrint('✅ Firestore service initialized successfully');
    } catch (e) {
      debugPrint('⚠️ Firestore service initialization failed: $e');
    }
  } else {
    debugPrint('⚠️ Skipping Firestore initialization - Firebase not available');
  }

  // Initialize notification service
  try {
    await NotificationService.instance.initialize();
    debugPrint('✅ Notification service initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Notification service initialization failed: $e');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'WhatsApp MicroLearning Bot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        primarySwatch: Colors.green,
      ),
      routerConfig: router,
    );
  }
}

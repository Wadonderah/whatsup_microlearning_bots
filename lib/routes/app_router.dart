import 'package:go_router/go_router.dart';

import '../features/ai_assistant/ai_assistant_screen.dart';
import '../features/home/home_screen.dart';
import '../features/notifications/notification_list_screen.dart';
import '../features/notifications/notification_settings_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/splash/splash_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/ai-assistant',
        name: 'ai-assistant',
        builder: (context, state) => const AIAssistantScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationListScreen(),
      ),
      GoRoute(
        path: '/notification-settings',
        name: 'notification-settings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
    ],
  );
}

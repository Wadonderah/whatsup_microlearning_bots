import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/ai_assistant/ai_assistant_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/register_screen.dart';
import '../features/dashboard/learning_dashboard_screen.dart';
import '../features/home/home_screen.dart';
import '../features/notifications/notification_list_screen.dart';
import '../features/notifications/notification_settings_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/quiz/category_selection_screen.dart';
import '../features/settings/theme_settings_screen.dart';
import '../features/splash/splash_screen.dart';

class AuthRouter {
  static GoRouter createRouter(Ref ref) {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final authState = ref.read(authProvider);
        final currentLocation = state.uri.toString();

        // Public routes that don't require authentication
        final publicRoutes = [
          '/splash',
          '/login',
          '/register',
          '/forgot-password',
          '/onboarding',
        ];

        // If auth is still loading, stay on splash screen
        if (authState.isLoading && currentLocation != '/splash') {
          return '/splash';
        }

        // If there's an auth error, redirect to splash to handle it
        if (authState.hasError && currentLocation != '/splash') {
          return '/splash';
        }

        final isAuthenticated = authState.isAuthenticated;

        // If user is not authenticated and trying to access protected route
        if (!isAuthenticated && !publicRoutes.contains(currentLocation)) {
          return '/login';
        }

        // If user is authenticated and trying to access auth routes
        if (isAuthenticated &&
            ['/login', '/register', '/forgot-password']
                .contains(currentLocation)) {
          return '/home';
        }

        return null; // No redirect needed
      },
      routes: [
        // Splash route
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),

        // Authentication routes
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          name: 'forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),

        // Onboarding route
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),

        // Protected routes (require authentication)
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) => const LearningDashboardScreen(),
        ),
        GoRoute(
          path: '/ai-assistant',
          name: 'ai-assistant',
          builder: (context, state) => const AIAssistantScreen(),
        ),
        GoRoute(
          path: '/quiz',
          name: 'quiz',
          builder: (context, state) => const CategorySelectionScreen(),
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
        GoRoute(
          path: '/theme-settings',
          name: 'theme-settings',
          builder: (context, state) => const ThemeSettingsScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'The page you\'re looking for doesn\'t exist.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Provider for the router
final routerProvider = Provider<GoRouter>((ref) {
  return AuthRouter.createRouter(ref);
});

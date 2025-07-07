import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:whatsup_microlearning_bots/features/dashboard/learning_dashboard_screen.dart';
import 'package:whatsup_microlearning_bots/routes/auth_router.dart';

void main() {
  group('Dashboard Route Tests', () {
    testWidgets('Dashboard route should be accessible', (WidgetTester tester) async {
      // Create a test app with the router
      final app = ProviderScope(
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/dashboard',
            routes: [
              GoRoute(
                path: '/dashboard',
                name: 'dashboard',
                builder: (context, state) => const LearningDashboardScreen(),
              ),
            ],
          ),
        ),
      );

      // Build the app
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Verify that the dashboard screen is displayed
      expect(find.byType(LearningDashboardScreen), findsOneWidget);
    });

    testWidgets('Dashboard should show loading initially', (WidgetTester tester) async {
      final app = ProviderScope(
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/dashboard',
            routes: [
              GoRoute(
                path: '/dashboard',
                name: 'dashboard',
                builder: (context, state) => const LearningDashboardScreen(),
              ),
            ],
          ),
        ),
      );

      await tester.pumpWidget(app);
      
      // Should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

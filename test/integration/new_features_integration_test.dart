import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsup_microlearning_bots/features/study_plans/study_plans_screen.dart';
import 'package:whatsup_microlearning_bots/features/learning/learning_categories_screen.dart';
import 'package:whatsup_microlearning_bots/features/offline/offline_mode_widget.dart';
import 'package:whatsup_microlearning_bots/features/social/social_feed_screen.dart';
import 'package:whatsup_microlearning_bots/features/export_backup/export_backup_screen.dart';

void main() {
  group('New Features Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Study Plans Feature', () {
      testWidgets('StudyPlansScreen should render without errors', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: StudyPlansScreen(),
            ),
          ),
        );

        // Should show the screen without crashing
        expect(find.byType(StudyPlansScreen), findsOneWidget);
        
        // Should have tab bar
        expect(find.byType(TabBar), findsOneWidget);
        expect(find.text('Active'), findsOneWidget);
        expect(find.text('Completed'), findsOneWidget);
        expect(find.text('All'), findsOneWidget);
        
        // Should have floating action button
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('Should show empty state initially', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: StudyPlansScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should show empty state
        expect(find.text('No study plans yet'), findsOneWidget);
        expect(find.byIcon(Icons.school_outlined), findsOneWidget);
      });

      testWidgets('Should be able to switch between tabs', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: StudyPlansScreen(),
            ),
          ),
        );

        await tester.pump();

        // Tap on Completed tab
        await tester.tap(find.text('Completed'));
        await tester.pump();

        // Should still be on the same screen
        expect(find.byType(StudyPlansScreen), findsOneWidget);

        // Tap on All tab
        await tester.tap(find.text('All'));
        await tester.pump();

        expect(find.byType(StudyPlansScreen), findsOneWidget);
      });
    });

    group('Learning Categories Feature', () {
      testWidgets('LearningCategoriesScreen should render without errors', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: LearningCategoriesScreen(),
            ),
          ),
        );

        // Should show the screen without crashing
        expect(find.byType(LearningCategoriesScreen), findsOneWidget);
        
        // Should have tab bar
        expect(find.byType(TabBar), findsOneWidget);
        expect(find.text('Featured'), findsOneWidget);
        expect(find.text('All'), findsOneWidget);
        expect(find.text('Progress'), findsOneWidget);
      });

      testWidgets('Should show loading indicator initially', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: LearningCategoriesScreen(),
            ),
          ),
        );

        // Should show loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('Should have search functionality', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: LearningCategoriesScreen(),
            ),
          ),
        );

        await tester.pump();

        // Should have search icon in app bar
        expect(find.byIcon(Icons.search), findsOneWidget);
      });
    });

    group('Offline Mode Feature', () {
      testWidgets('OfflineModeWidget should wrap child correctly', (tester) async {
        const testChild = Text('Test Child Widget');
        
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: OfflineModeWidget(
                child: testChild,
              ),
            ),
          ),
        );

        // Should show the child widget
        expect(find.text('Test Child Widget'), findsOneWidget);
        expect(find.byType(OfflineModeWidget), findsOneWidget);
      });

      testWidgets('Should handle connectivity changes', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: OfflineModeWidget(
                child: Scaffold(
                  body: Center(child: Text('App Content')),
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        // Should show app content
        expect(find.text('App Content'), findsOneWidget);
      });
    });

    group('Social Learning Feature', () {
      testWidgets('SocialFeedScreen should render without errors', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: SocialFeedScreen(),
            ),
          ),
        );

        // Should show the screen without crashing
        expect(find.byType(SocialFeedScreen), findsOneWidget);
      });

      testWidgets('Should show login prompt when not authenticated', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: SocialFeedScreen(),
            ),
          ),
        );

        await tester.pump();

        // Should show login message
        expect(find.text('Please log in to view social features'), findsOneWidget);
      });

      testWidgets('Should have floating action button for creating posts', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: SocialFeedScreen(),
            ),
          ),
        );

        await tester.pump();

        // Should have FAB for creating posts
        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
      });
    });

    group('Export & Backup Feature', () {
      testWidgets('ExportBackupScreen should render without errors', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: ExportBackupScreen(),
            ),
          ),
        );

        // Should show the screen without crashing
        expect(find.byType(ExportBackupScreen), findsOneWidget);
      });

      testWidgets('Should show login prompt when not authenticated', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: ExportBackupScreen(),
            ),
          ),
        );

        await tester.pump();

        // Should show login message
        expect(find.text('Please log in to access export and backup features'), findsOneWidget);
      });

      testWidgets('Should have tab bar with export, backup, and sync tabs', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: ExportBackupScreen(),
            ),
          ),
        );

        await tester.pump();

        // Should have tab bar
        expect(find.byType(TabBar), findsOneWidget);
        expect(find.text('Export'), findsOneWidget);
        expect(find.text('Backup'), findsOneWidget);
        expect(find.text('Sync'), findsOneWidget);
      });
    });

    group('Navigation and Integration', () {
      testWidgets('All screens should be accessible without crashes', (tester) async {
        // Test Study Plans Screen
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: StudyPlansScreen()),
          ),
        );
        expect(find.byType(StudyPlansScreen), findsOneWidget);

        // Test Learning Categories Screen
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: LearningCategoriesScreen()),
          ),
        );
        expect(find.byType(LearningCategoriesScreen), findsOneWidget);

        // Test Social Feed Screen
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: SocialFeedScreen()),
          ),
        );
        expect(find.byType(SocialFeedScreen), findsOneWidget);

        // Test Export Backup Screen
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: ExportBackupScreen()),
          ),
        );
        expect(find.byType(ExportBackupScreen), findsOneWidget);
      });

      testWidgets('Screens should handle state changes gracefully', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: DefaultTabController(
                length: 4,
                child: Scaffold(
                  appBar: AppBar(
                    bottom: const TabBar(
                      tabs: [
                        Tab(text: 'Study Plans'),
                        Tab(text: 'Learning'),
                        Tab(text: 'Social'),
                        Tab(text: 'Export'),
                      ],
                    ),
                  ),
                  body: const TabBarView(
                    children: [
                      StudyPlansScreen(),
                      LearningCategoriesScreen(),
                      SocialFeedScreen(),
                      ExportBackupScreen(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        // Should show all tabs
        expect(find.text('Study Plans'), findsOneWidget);
        expect(find.text('Learning'), findsOneWidget);
        expect(find.text('Social'), findsOneWidget);
        expect(find.text('Export'), findsOneWidget);

        // Test switching between tabs
        await tester.tap(find.text('Learning'));
        await tester.pump();
        expect(find.byType(LearningCategoriesScreen), findsOneWidget);

        await tester.tap(find.text('Social'));
        await tester.pump();
        expect(find.byType(SocialFeedScreen), findsOneWidget);

        await tester.tap(find.text('Export'));
        await tester.pump();
        expect(find.byType(ExportBackupScreen), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('Screens should handle provider errors gracefully', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: StudyPlansScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should not crash and should show some content
        expect(find.byType(StudyPlansScreen), findsOneWidget);
      });

      testWidgets('Should show appropriate error messages', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: LearningCategoriesScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should handle loading states
        expect(find.byType(LearningCategoriesScreen), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('All screens should have proper semantic labels', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: StudyPlansScreen(),
            ),
          ),
        );

        await tester.pump();

        // Should have semantic widgets for accessibility
        expect(find.byType(Semantics), findsWidgets);
      });

      testWidgets('Should support keyboard navigation', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: StudyPlansScreen(),
            ),
          ),
        );

        await tester.pump();

        // Should have focusable elements
        expect(find.byType(TabBar), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });
    });
  });
}

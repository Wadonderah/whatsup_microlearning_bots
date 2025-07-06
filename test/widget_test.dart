import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsup_microlearning_bots/features/splash/splash_screen.dart';
import 'package:whatsup_microlearning_bots/main.dart';

void main() {
  group('WhatsApp MicroLearning Bot Tests', () {
    testWidgets('App should start with splash screen',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify that splash screen is displayed
      expect(find.byType(SplashScreen), findsOneWidget);

      // Verify splash screen contains the app name
      expect(find.text('WhatsApp'), findsOneWidget);
      expect(find.text('MicroLearning Bot'), findsOneWidget);

      // Verify loading indicator is present
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Splash screen should have animated logo',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify the chat bubble icon is present
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);

      // Verify the logo container is present
      expect(find.byType(Container), findsWidgets);
    });
  });
}

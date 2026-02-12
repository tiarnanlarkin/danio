import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aquarium_app/screens/create_tank_screen.dart';
import 'package:aquarium_app/models/tank.dart';
import 'package:aquarium_app/theme/app_theme.dart';

void main() {
  group('CreateTankScreen', () {
    setUp(() {
      // Initialize SharedPreferences for tests
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders tank name input field', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const CreateTankScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should find a text field for tank name
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('shows freshwater option by default', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const CreateTankScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show freshwater as an option
      expect(find.text('Freshwater'), findsOneWidget);
    });

    testWidgets('shows "Coming soon" for marine option', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const CreateTankScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Marine should show coming soon
      expect(find.textContaining('Coming soon'), findsWidgets);
    });

    testWidgets('can enter tank name', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const CreateTankScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find a text field and enter text
      final textField = find.byType(TextField).first;
      await tester.enterText(textField, 'My Test Tank');
      await tester.pumpAndSettle();

      // Verify the text was entered
      expect(find.text('My Test Tank'), findsOneWidget);
    });

    testWidgets('can navigate to size page', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const CreateTankScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // First enter a tank name (required to proceed)
      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, 'Test Tank');
      await tester.pumpAndSettle();

      // Tap Next button to go to size page
      final nextButton = find.text('Next');
      if (nextButton.evaluate().isNotEmpty) {
        await tester.tap(nextButton);
        await tester.pumpAndSettle();
      }

      // Now should see size-related UI
      final hasTankSize = find.textContaining('Tank size').evaluate().isNotEmpty;
      final hasLitres = find.textContaining('litres').evaluate().isNotEmpty;
      
      expect(hasTankSize || hasLitres, isTrue);
    });
  });
}

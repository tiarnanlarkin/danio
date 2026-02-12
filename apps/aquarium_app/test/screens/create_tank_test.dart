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

    testWidgets('shows volume input options', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const CreateTankScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should find volume-related UI (gallons or liters)
      final hasGallons = find.textContaining('gallon').evaluate().isNotEmpty;
      final hasLiters = find.textContaining('liter').evaluate().isNotEmpty;
      final hasVolume = find.textContaining('Volume').evaluate().isNotEmpty;
      
      expect(hasGallons || hasLiters || hasVolume, isTrue);
    });
  });
}

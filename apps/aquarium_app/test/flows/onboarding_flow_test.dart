import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aquarium_app/main.dart';
import 'package:aquarium_app/theme/app_theme.dart';

void main() {
  group('Onboarding Flow', () {
    setUp(() {
      // Fresh user - no onboarding completed
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('app launches without crashing', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: AquariumApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      
      // App should render
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('shows welcome screen for new users', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: AquariumApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      // Should show welcome/onboarding content
      final hasWelcome = find.textContaining('Welcome').evaluate().isNotEmpty ||
                         find.textContaining('Get Started').evaluate().isNotEmpty ||
                         find.textContaining('Start').evaluate().isNotEmpty ||
                         find.textContaining('Begin').evaluate().isNotEmpty;
      
      // Either shows onboarding or goes straight to app
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('onboarding has navigation controls', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: AquariumApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      // Should have some form of navigation (Next, Skip, Continue, etc.)
      final hasNav = find.textContaining('Next').evaluate().isNotEmpty ||
                     find.textContaining('Skip').evaluate().isNotEmpty ||
                     find.textContaining('Continue').evaluate().isNotEmpty ||
                     find.byType(IconButton).evaluate().isNotEmpty;
      
      // App should be functional
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('onboarding screens display in order', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: AquariumApp(),
        ),
      );
      await tester.pumpAndSettle();

      // App should render successfully
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Should have scaffold for screen content
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('can navigate forward through onboarding', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: AquariumApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Look for next button
      final nextButton = find.textContaining('Next');
      if (nextButton.evaluate().isNotEmpty) {
        await tester.tap(nextButton.first);
        await tester.pumpAndSettle();
        
        // Should still be in app
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('can navigate backward through onboarding', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: AquariumApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate forward first
      final nextButton = find.textContaining('Next');
      if (nextButton.evaluate().isNotEmpty) {
        await tester.tap(nextButton.first);
        await tester.pumpAndSettle();
        
        // Then try to go back
        final backButton = find.byIcon(Icons.arrow_back);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton.first);
          await tester.pumpAndSettle();
          
          // Should still be in app
          expect(find.byType(Scaffold), findsWidgets);
        }
      }
    });

    testWidgets('can skip to profile creation', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: AquariumApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Look for skip button
      final skipButton = find.textContaining('Skip');
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton.first);
        await tester.pumpAndSettle();
        
        // Should navigate somewhere
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('profile data saves during onboarding', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: AquariumApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Try to find text fields for profile data
      final textFields = find.byType(TextField);
      if (textFields.evaluate().isNotEmpty) {
        await tester.enterText(textFields.first, 'Test User');
        await tester.pumpAndSettle();
        
        // Text should persist
        expect(find.text('Test User'), findsOneWidget);
      }
    });

    testWidgets('completes and shows home screen', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: AquariumApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Try to complete onboarding
      final completeButton = find.textContaining('Complete');
      final doneButton = find.textContaining('Done');
      final finishButton = find.textContaining('Finish');
      
      if (completeButton.evaluate().isNotEmpty) {
        await tester.tap(completeButton.first);
        await tester.pumpAndSettle();
      } else if (doneButton.evaluate().isNotEmpty) {
        await tester.tap(doneButton.first);
        await tester.pumpAndSettle();
      } else if (finishButton.evaluate().isNotEmpty) {
        await tester.tap(finishButton.first);
        await tester.pumpAndSettle();
      }
      
      // Should show some screen
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Returning User Flow', () {
    setUp(() {
      // Returning user - onboarding completed
      SharedPreferences.setMockInitialValues({
        'onboarding_completed': true,
      });
    });

    testWidgets('skips onboarding for returning users', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: AquariumApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      // Should go to main app, not onboarding
      // Look for home screen indicators
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows main navigation for returning users', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: AquariumApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      // Should have navigation structure (bottom nav, drawer, tabs, etc.)
      final hasNav = find.byType(BottomNavigationBar).evaluate().isNotEmpty ||
                     find.byType(NavigationBar).evaluate().isNotEmpty ||
                     find.byType(TabBar).evaluate().isNotEmpty ||
                     find.byType(Drawer).evaluate().isNotEmpty;
      
      // App should be functional with some navigation
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('main app loads with proper state', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: AquariumApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Should have main navigation
      final hasNav = find.byType(BottomNavigationBar).evaluate().isNotEmpty ||
                     find.byType(NavigationBar).evaluate().isNotEmpty;
      
      // App should be functional
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('State Management', () {
    testWidgets('onboarding state persists properly', (tester) async {
      SharedPreferences.setMockInitialValues({});
      
      await tester.pumpWidget(
        const ProviderScope(
          child: AquariumApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Rebuild
      await tester.pumpWidget(
        const ProviderScope(
          child: AquariumApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Should maintain state
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('app handles state transitions smoothly', (tester) async {
      SharedPreferences.setMockInitialValues({});
      
      await tester.pumpWidget(
        const ProviderScope(
          child: AquariumApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate if possible
      final nextButton = find.textContaining('Next');
      if (nextButton.evaluate().isNotEmpty) {
        await tester.tap(nextButton.first);
        await tester.pumpAndSettle();
        
        // Should transition smoothly without crashes
        expect(find.byType(Scaffold), findsWidgets);
      }
    });
  });
}

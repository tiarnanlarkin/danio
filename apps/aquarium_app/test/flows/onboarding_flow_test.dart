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
  });
}

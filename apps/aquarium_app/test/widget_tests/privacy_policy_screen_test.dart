// Widget tests for PrivacyPolicyScreen.
//
// Run: flutter test test/widget_tests/privacy_policy_screen_test.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/privacy_policy_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const MaterialApp(home: PrivacyPolicyScreen());
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PrivacyPolicyScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
    });

    testWidgets('shows Privacy Policy app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Privacy Policy'), findsWidgets);
    });

    testWidgets('shows Your Privacy Matters heading', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Your Privacy Matters'), findsOneWidget);
    });

    testWidgets('shows shield icon', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byIcon(Icons.shield), findsOneWidget);
    });

    testWidgets('shows transparency subtitle', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.textContaining('Transparency'), findsOneWidget);
    });

    testWidgets('shows Summary section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Summary'), findsOneWidget);
    });

    testWidgets('tablet centers policy content in a readable rail', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap());
      await tester.pump();

      expect(
        tester.getTopLeft(find.text('Your Privacy Matters')).dx,
        greaterThan(650),
      );
    });

    testWidgets('shows open in new icon button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byIcon(Icons.open_in_new), findsOneWidget);
    });
  });

  group('PrivacyPolicyScreen — policy content', () {
    testWidgets('contains Introduction section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // Scroll to find content
      expect(find.text('1. Introduction'), findsOneWidget);
    });

    testWidgets('mentions Firebase Crashlytics', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.textContaining('Firebase Crashlytics'), findsWidgets);
    });

    testWidgets('describes cloud services as inactive in this version', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      expect(find.text('Cloud Sync & Accounts'), findsOneWidget);
      expect(
        find.textContaining(
          'Cloud sync and account login are not active in this version of Danio',
        ),
        findsWidgets,
      );
      expect(find.textContaining('local build'), findsNothing);
      expect(find.textContaining('synced cloud rows'), findsNothing);
      expect(find.textContaining('delete your cloud account'), findsNothing);
    });

    testWidgets('describes Optional AI data beyond Fish ID photos', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      expect(find.text('Optional AI services'), findsOneWidget);
      expect(
        find.textContaining(
          'Fish ID photos, symptom descriptions, stocking or compatibility requests, and weekly-plan tank context',
        ),
        findsWidgets,
      );
      expect(
        find.textContaining(
          'OpenAI may retain API inputs and outputs for abuse monitoring for up to 30 days',
        ),
        findsWidgets,
      );
      expect(
        find.textContaining('Fish ID images: Art. 6(1)(a)'),
        findsNothing,
      );
    });

    test('does not mention dormant provider or developer wording', () {
      final source = File(
        'lib/screens/privacy_policy_screen.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('Supabase')));
      expect(source, isNot(contains('When activated in future')));
      expect(source, isNot(contains('Cloud sync code exists')));
      expect(source, isNot(contains('local build')));
      expect(source, isNot(contains('\u2014')));
      expect(source, isNot(contains('OpenAI API - Fish ID')));
      expect(source, contains('Optional AI services'));
      expect(source, contains('symptom descriptions'));
      expect(source, contains('weekly-plan tank context'));
    });
  });
}

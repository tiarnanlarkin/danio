// Widget tests for ConsentScreen.
//
// Run: flutter test test/widget_tests/consent_screen_test.dart

import 'dart:ui' show CheckedState;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/onboarding/consent_screen.dart';
import 'package:danio/providers/user_profile_provider.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap({VoidCallback? onConsentGiven}) {
  SharedPreferences.setMockInitialValues({});
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async {
        return SharedPreferences.getInstance();
      }),
    ],
    child: MaterialApp(
      home: ConsentScreen(onConsentGiven: onConsentGiven ?? () {}),
    ),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ConsentScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(ConsentScreen), findsOneWidget);
    });

    testWidgets('shows Your Privacy Matters heading', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Your Privacy Matters'), findsOneWidget);
    });

    testWidgets('shows age confirmation checkbox', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(
        find.text('I confirm I am 13 years of age or older'),
        findsOneWidget,
      );
    });

    testWidgets('shows Accept Analytics button', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Accept Analytics'), findsOneWidget);
    });

    testWidgets('shows No Thanks button', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('No Thanks'), findsOneWidget);
    });

    testWidgets('shows privacy tip icon', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byIcon(Icons.privacy_tip_outlined), findsOneWidget);
    });

    testWidgets('consent controls expose direct semantic tap actions', (
      tester,
    ) async {
      final semanticsHandle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(_wrap());
        await _advance(tester);

        final ageNode = tester.getSemantics(
          find.bySemanticsLabel('Age confirmation checkbox'),
        );
        final tosNode = tester.getSemantics(
          find.bySemanticsLabel(
            'Terms of Service and Privacy Policy acceptance checkbox',
          ),
        );
        expect(
          ageNode.getSemanticsData().flagsCollection.isChecked,
          isNot(CheckedState.none),
        );
        expect(ageNode.getSemanticsData().flagsCollection.isButton, isTrue);
        expect(
          ageNode.getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
        );
        expect(
          tosNode.getSemanticsData().flagsCollection.isChecked,
          isNot(CheckedState.none),
        );
        expect(tosNode.getSemanticsData().flagsCollection.isButton, isTrue);
        expect(
          tosNode.getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
        );

        await tester.tap(find.byType(Checkbox).at(0));
        await tester.tap(find.byType(Checkbox).at(1));
        await tester.pump();

        final noThanksNode = tester.getSemantics(
          find.bySemanticsLabel('No Thanks'),
        );
        expect(
          noThanksNode.getSemanticsData().flagsCollection.isButton,
          isTrue,
        );
        expect(
          noThanksNode.getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
        );
      } finally {
        semanticsHandle.dispose();
      }
    });
  });
}

import 'dart:async';

import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/screens/lesson_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _EnergyExplainerLauncher extends ConsumerWidget {
  const _EnergyExplainerLauncher();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        unawaited(
          maybeExplainHearts(context, ref, isPracticeMode: false),
        );
      },
      child: const Text('Explain energy'),
    );
  }
}

void main() {
  testWidgets(
    'marks energy explainer seen only after the dialog is dismissed',
    (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async => prefs),
          ],
          child: const MaterialApp(
            home: Scaffold(body: _EnergyExplainerLauncher()),
          ),
        ),
      );

      await tester.tap(find.text('Explain energy'));
      await tester.pumpAndSettle();

      expect(find.text('Energy'), findsOneWidget);
      expect(prefs.getBool('hearts_explained'), isNull);

      await tester.tap(find.text('Got it!'));
      await tester.pumpAndSettle();

      expect(prefs.getBool('hearts_explained'), isTrue);
    },
  );

  testWidgets(
    'does not mark energy explainer seen when screen unmounts first',
    (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final prefsCompleter = Completer<SharedPreferences>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWith(
              (ref) => prefsCompleter.future,
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: _EnergyExplainerLauncher()),
          ),
        ),
      );

      await tester.tap(find.text('Explain energy'));
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());

      prefsCompleter.complete(prefs);
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(prefs.getBool('hearts_explained'), isNull);
    },
  );
}

import 'package:danio/screens/debug_qa_seed_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('debug lesson quiz hint state exposes the hint chip', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: DebugQaLessonQuizScreen(state: 'hint')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('QA Lesson Quiz'), findsOneWidget);
    expect(find.text('Need a hint?'), findsOneWidget);

    await tester.tap(find.text('Need a hint?'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Look for keywords'), findsOneWidget);

    await _disposeAnimatedTree(tester);
  });

  testWidgets('debug lesson quiz selected-correct state exposes marker', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DebugQaLessonQuizScreen(state: 'selected-correct'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('QA Lesson Quiz'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'Selected answer [A-D], correct')),
      findsOneWidget,
    );

    await _disposeAnimatedTree(tester);
  });
}

Future<void> _disposeAnimatedTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 2));
}

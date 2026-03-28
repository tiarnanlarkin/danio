// Widget tests for JournalScreen.
//
// Run: flutter test test/widget_tests/journal_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/journal_screen.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/models/models.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _fakeTankId = 'tank-journal-001';

Widget _wrap({List<LogEntry>? logs}) {
  final memStorage = InMemoryStorageService();
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(memStorage),
      allLogsProvider.overrideWith((ref, tankId) async => logs ?? []),
    ],
    child: MaterialApp(
      home: JournalScreen(tankId: _fakeTankId),
    ),
  );
}

LogEntry _journalEntry({String id = 'j-001', String notes = 'Tank looking healthy!'}) =>
    LogEntry(
      id: id,
      tankId: _fakeTankId,
      type: LogType.observation,
      timestamp: DateTime(2024, 7, 1),
      notes: notes,
      createdAt: DateTime(2024, 7, 1),
    );

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('JournalScreen — empty state', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(JournalScreen), findsOneWidget);
    });

    testWidgets('shows scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows Tank Journal title in app bar', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Tank Journal'), findsOneWidget);
    });

    testWidgets('shows add icon button in app bar', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byIcon(Icons.add), findsWidgets);
    });

    testWidgets('shows empty state message when no entries', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Your story starts here!'), findsOneWidget);
    });
  });

  group('JournalScreen — with entries', () {
    testWidgets('shows journal entry notes when entries exist', (tester) async {
      final entries = [_journalEntry(notes: 'Tank looking healthy!')];
      await tester.pumpWidget(_wrap(logs: entries));
      await _advance(tester);
      expect(find.text('Tank looking healthy!'), findsOneWidget);
    });
  });
}

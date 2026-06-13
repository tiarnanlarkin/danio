// Widget tests for BackupRestoreScreen.
//
// Run: flutter test test/widget_tests/backup_restore_screen_test.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/backup_restore_screen.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/services/storage_service.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(InMemoryStorageService()),
    ],
    child: const MaterialApp(home: BackupRestoreScreen()),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('BackupRestoreScreen - basic rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(BackupRestoreScreen), findsOneWidget);
    });

    testWidgets('shows Backup & Restore app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Backup & Restore'), findsOneWidget);
    });

    testWidgets('shows export button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining('Export'), findsWidgets);
    });

    testWidgets('shows import/restore button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.textContaining('Import').evaluate().isNotEmpty ||
            find.textContaining('Restore').evaluate().isNotEmpty,
        isTrue,
        reason: 'Should have an import or restore button',
      );
    });

    testWidgets('shows info card about backup', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      // The info card explains what the backup does
      expect(find.byIcon(Icons.backup), findsWidgets);
    });

    testWidgets('shows clear import safety copy', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.drag(find.byType(ListView), const Offset(0, -900));
      await tester.pumpAndSettle();

      expect(find.text('Import Safety'), findsOneWidget);
      expect(
        find.text(
          'Imports add backed-up tanks as new tanks. Existing tanks and logs stay on this device. App-wide profile, learning progress, gems, and preferences are replaced from the backup.',
        ),
        findsOneWidget,
      );
    });

    test('user-facing copy describes local ZIP backup only', () {
      final source = File(
        'lib/screens/backup_restore_screen.dart',
      ).readAsStringSync();

      expect(source, contains('ZIP file'));
      expect(RegExp(r'[^\x00-\x7F]').hasMatch(source), isFalse);
      expect(source, contains('Existing tanks and logs stay on this device'));
      expect(
        source,
        contains(
          'App-wide profile, learning progress, gems, and preferences are replaced',
        ),
      );
      expect(source, isNot(contains('sync your aquarium data')));
      expect(source, isNot(contains('cloud backup')));
      expect(source, isNot(contains('uploaded successfully')));
    });
  });
}

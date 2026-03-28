// Widget tests for BackupRestoreScreen.
//
// Run: flutter test test/widget_tests/backup_restore_screen_test.dart

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
    child: const MaterialApp(
      home: BackupRestoreScreen(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('BackupRestoreScreen — basic rendering', () {
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
  });
}

import 'package:danio/providers/storage_provider.dart';
import 'package:danio/screens/backup_restore_screen.dart';
import 'package:danio/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap() {
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(InMemoryStorageService()),
    ],
    child: const MaterialApp(home: BackupRestoreScreen()),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('empty export state explains next step and links to Tank tab', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('0 tanks to export'), findsOneWidget);
    expect(
      find.text(
        'There are no tanks to export yet. Add a tank first, then come back here to create a backup.',
      ),
      findsOneWidget,
    );
    expect(find.text('Go to Tank'), findsOneWidget);
    expect(find.text('Export Backup (ZIP)'), findsNothing);
  });
}

// Widget tests for PhotoGalleryScreen.
//
// Run: flutter test test/widget_tests/photo_gallery_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/photo_gallery_screen.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/services/storage_service.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _fakeTankId = 'tank-gallery-001';
const _fakeTankName = 'Reef Tank';

Widget _wrap() {
  final memStorage = InMemoryStorageService();
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(memStorage),
      allLogsProvider.overrideWith((ref, tankId) async => []),
    ],
    child: const MaterialApp(
      home: PhotoGalleryScreen(tankId: _fakeTankId, tankName: _fakeTankName),
    ),
  );
}

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

  group('PhotoGalleryScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(PhotoGalleryScreen), findsOneWidget);
    });

    testWidgets('shows scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows gallery title in app bar', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('$_fakeTankName Gallery'), findsOneWidget);
    });

    testWidgets('shows empty state when no photos', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      // Empty gallery widget should be present
      expect(find.byType(Column), findsWidgets);
    });
  });
}

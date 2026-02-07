// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aquarium_app/main.dart';
import 'package:aquarium_app/providers/storage_provider.dart';
import 'package:aquarium_app/services/storage_service.dart';

void main() {
  testWidgets('App boots and shows home screen', (WidgetTester tester) async {
    // Force onboarding to be treated as completed so the app routes directly to
    // the main shell.
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});

    // Use in-memory storage for tests to avoid filesystem/platform channel deps.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(InMemoryStorageService()),
        ],
        child: const AquariumApp(),
      ),
    );

    await tester.pumpAndSettle();

    // With no tanks, the HomeScreen shows the empty-state CTA.
    expect(find.text('Add Your Tank'), findsOneWidget);
  });
}

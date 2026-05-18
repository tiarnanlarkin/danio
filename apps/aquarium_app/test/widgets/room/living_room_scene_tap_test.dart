import 'package:danio/providers/room_theme_provider.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/theme/room_themes.dart';
import 'package:danio/widgets/room/living_room_scene.dart';
import 'package:danio/widgets/room/themed_aquarium.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('tapping the aquarium opens tank detail without fish fact dialog', (
    tester,
  ) async {
    var tankTapCount = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(InMemoryStorageService()),
          currentRoomThemeProvider.overrideWith((ref) => RoomTheme.ocean),
        ],
        child: MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: SizedBox(
                width: 390,
                height: 680,
                child: LivingRoomScene(
                  tankId: 'test-tank',
                  tankName: 'Test Tank',
                  tankVolume: 120,
                  theme: RoomTheme.ocean,
                  onTankTap: () => tankTapCount++,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(ThemedAquarium));
    await tester.pump(const Duration(milliseconds: 700));

    expect(tankTapCount, 1);
    expect(find.text('Got it!'), findsNothing);
  });
}

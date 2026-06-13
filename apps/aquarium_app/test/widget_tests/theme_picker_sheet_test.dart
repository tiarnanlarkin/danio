import 'package:danio/providers/room_theme_provider.dart';
import 'package:danio/providers/room_theme_unlock_provider.dart';
import 'package:danio/screens/home/theme_picker_sheet.dart';
import 'package:danio/services/room_theme_unlock_service.dart';
import 'package:danio/theme/room_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'room_theme': RoomThemeType.aurora.index,
    });
  });

  testWidgets('locked current room vibe shows requirement instead of apply', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        states: _statesForAurora(
          isUnlocked: false,
          requirementLabel: 'Reach 2500 XP to unlock Aurora.',
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Locked'), findsOneWidget);
    expect(find.textContaining('Reach 2500 XP'), findsOneWidget);
    expect(find.text('Apply'), findsNothing);
  });

  testWidgets('unlocked current room vibe can be applied', (tester) async {
    await tester.pumpWidget(
      _wrap(
        states: _statesForAurora(
          isUnlocked: true,
          requirementLabel: 'Unlocked',
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Apply'), findsOneWidget);
    expect(find.text('Locked'), findsNothing);
  });
}

Widget _wrap({required Map<RoomThemeType, RoomThemeUnlockState> states}) {
  return ProviderScope(
    overrides: [
      roomThemeProvider.overrideWith(
        (ref) => _TestRoomThemeNotifier(ref, RoomThemeType.aurora),
      ),
      roomThemeUnlockStatesProvider.overrideWith((ref) => states),
    ],
    child: const MaterialApp(
      home: Scaffold(body: Center(child: ThemePickerSheet())),
    ),
  );
}

Map<RoomThemeType, RoomThemeUnlockState> _statesForAurora({
  required bool isUnlocked,
  required String requirementLabel,
}) {
  return {
    for (final type in RoomThemeType.values)
      type: RoomThemeUnlockState(
        type: type,
        isUnlocked: type == RoomThemeType.aurora ? isUnlocked : true,
        requirementLabel: type == RoomThemeType.aurora
            ? requirementLabel
            : 'Unlocked',
      ),
  };
}

class _TestRoomThemeNotifier extends RoomThemeNotifier {
  _TestRoomThemeNotifier(super.ref, RoomThemeType initial) {
    state = initial;
  }

  @override
  Future<void> setTheme(RoomThemeType theme) async {
    state = theme;
  }
}

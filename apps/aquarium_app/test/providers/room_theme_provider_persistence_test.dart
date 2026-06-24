import 'package:danio/providers/room_theme_provider.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/theme/room_themes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ThrowingSetIntPrefs implements SharedPreferences {
  _ThrowingSetIntPrefs(this._delegate, this._shouldFail);

  final SharedPreferences _delegate;
  final bool Function(String key, int value) _shouldFail;

  @override
  int? getInt(String key) => _delegate.getInt(key);

  @override
  Future<bool> setInt(String key, int value) {
    if (_shouldFail(key, value)) {
      throw StateError('Simulated SharedPreferences write failure for $key');
    }
    return _delegate.setInt(key, value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _waitForThemeLoad(ProviderContainer container) async {
  for (var i = 0; i < 20; i += 1) {
    container.read(roomThemeProvider);
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RoomThemeNotifier persistence', () {
    test('setTheme keeps current room vibe when local save fails', () async {
      SharedPreferences.setMockInitialValues({
        'room_theme': RoomThemeType.ocean.index,
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async {
            return _ThrowingSetIntPrefs(
              prefs,
              (key, _) => key == 'room_theme',
            );
          }),
        ],
      );
      addTearDown(container.dispose);
      await _waitForThemeLoad(container);

      final applied = await container
          .read(roomThemeProvider.notifier)
          .setTheme(
            RoomThemeType.aurora,
          );

      expect(applied, isFalse);
      expect(container.read(roomThemeProvider), RoomThemeType.ocean);
      expect(prefs.getInt('room_theme'), RoomThemeType.ocean.index);
    });
  });
}

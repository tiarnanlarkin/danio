import 'package:danio/providers/reduced_motion_provider.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FailingReducedMotionPrefs implements SharedPreferences {
  _FailingReducedMotionPrefs(this._delegate, this._shouldFail);

  final SharedPreferences _delegate;
  final bool Function(String key, String operation) _shouldFail;

  @override
  bool containsKey(String key) => _delegate.containsKey(key);

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  Future<bool> setBool(String key, bool value) async {
    if (_shouldFail(key, 'setBool')) return false;
    return _delegate.setBool(key, value);
  }

  @override
  Future<bool> remove(String key) async {
    if (_shouldFail(key, 'remove')) return false;
    return _delegate.remove(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _waitForReducedMotionLoad(ProviderContainer container) async {
  for (var i = 0; i < 20; i += 1) {
    container.read(reducedMotionProvider);
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReducedMotionNotifier persistence', () {
    test('clearing a user override returns to the system preference', () async {
      SharedPreferences.setMockInitialValues({
        'reduced_motion_override': true,
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await _waitForReducedMotionLoad(container);

      final cleared = await container
          .read(reducedMotionProvider.notifier)
          .setUserPreference(null);

      expect(cleared, isTrue);
      final state = container.read(reducedMotionProvider);
      expect(state.userOverride, isNull);
      expect(state.systemPreference, isFalse);
      expect(state.isEnabled, isFalse);
      expect(prefs.containsKey('reduced_motion_override'), isFalse);
    });

    test('manual override stays unchanged when local set fails', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async {
            return _FailingReducedMotionPrefs(
              prefs,
              (key, operation) =>
                  key == 'reduced_motion_override' && operation == 'setBool',
            );
          }),
        ],
      );
      addTearDown(container.dispose);
      await _waitForReducedMotionLoad(container);

      final saved = await container
          .read(reducedMotionProvider.notifier)
          .setUserPreference(true);

      expect(saved, isFalse);
      final state = container.read(reducedMotionProvider);
      expect(state.userOverride, isNull);
      expect(state.isEnabled, isFalse);
      expect(prefs.containsKey('reduced_motion_override'), isFalse);
    });

    test('manual override stays unchanged when local clear fails', () async {
      SharedPreferences.setMockInitialValues({
        'reduced_motion_override': true,
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async {
            return _FailingReducedMotionPrefs(
              prefs,
              (key, operation) =>
                  key == 'reduced_motion_override' && operation == 'remove',
            );
          }),
        ],
      );
      addTearDown(container.dispose);
      await _waitForReducedMotionLoad(container);

      final cleared = await container
          .read(reducedMotionProvider.notifier)
          .setUserPreference(null);

      expect(cleared, isFalse);
      final state = container.read(reducedMotionProvider);
      expect(state.userOverride, isTrue);
      expect(state.isEnabled, isTrue);
      expect(prefs.getBool('reduced_motion_override'), isTrue);
    });
  });
}

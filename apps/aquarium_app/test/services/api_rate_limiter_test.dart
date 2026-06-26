import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/services/api_rate_limiter.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ApiRateLimiter persistence', () {
    test(
      'reports false setStringList results while keeping session count',
      () async {
        final delegate = await SharedPreferences.getInstance();
        final prefs = _FalseSetStringListPrefs(
          delegate,
          failedKey: 'rate_limit_${AIFeature.askDanio}',
        );
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async => prefs),
          ],
        );
        addTearDown(container.dispose);

        final limiter = container.read(apiRateLimiterProvider);

        expect(limiter.remainingRequests(AIFeature.askDanio), 10);
        final saved = await limiter.recordRequest(AIFeature.askDanio);

        expect(saved, isFalse);
        expect(limiter.remainingRequests(AIFeature.askDanio), 9);
        expect(
          delegate.getStringList('rate_limit_${AIFeature.askDanio}'),
          isNull,
        );
      },
    );
  });
}

class _FalseSetStringListPrefs implements SharedPreferences {
  _FalseSetStringListPrefs(this._delegate, {required this.failedKey});

  final SharedPreferences _delegate;
  final String failedKey;

  @override
  Set<String> getKeys() => _delegate.getKeys();

  @override
  List<String>? getStringList(String key) => _delegate.getStringList(key);

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    if (key == failedKey) return false;
    return _delegate.setStringList(key, value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

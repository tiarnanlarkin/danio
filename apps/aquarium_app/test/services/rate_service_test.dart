import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/services/rate_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(RateService.resetDependenciesForTesting);

  group('RateService local review tracking', () {
    test(
      'returns false when review_requested cannot be saved after prompt',
      () async {
        final delegate = await SharedPreferences.getInstance();
        var requested = false;
        RateService.overrideDependenciesForTesting(
          sharedPreferencesFactory: () async => _FalseSetBoolPrefs(
            delegate,
            failedKey: 'review_requested',
          ),
          isReviewAvailable: () async => true,
          requestReview: () async => requested = true,
        );

        final result = await RateService.maybeShowReview(lessonsCompleted: 5);

        expect(requested, isTrue);
        expect(result, isFalse);
        expect(delegate.getBool('review_requested'), isNull);
      },
    );
  });
}

class _FalseSetBoolPrefs implements SharedPreferences {
  _FalseSetBoolPrefs(this._delegate, {required this.failedKey});

  final SharedPreferences _delegate;
  final String failedKey;

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  Future<bool> setBool(String key, bool value) async {
    if (key == failedKey) return false;
    return _delegate.setBool(key, value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

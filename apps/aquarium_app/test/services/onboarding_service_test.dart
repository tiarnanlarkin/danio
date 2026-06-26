// Unit tests for OnboardingService.
//
// Run: flutter test test/services/onboarding_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/services/onboarding_service.dart';

class _FalseSetBoolPrefs implements SharedPreferences {
  _FalseSetBoolPrefs(this._delegate, this._shouldFail);

  final SharedPreferences _delegate;
  final bool Function(String key, bool value) _shouldFail;

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  Future<bool> setBool(String key, bool value) async {
    if (_shouldFail(key, value)) return false;
    return _delegate.setBool(key, value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FalseRemovePrefs implements SharedPreferences {
  _FalseRemovePrefs(this._delegate, this._shouldFail);

  final SharedPreferences _delegate;
  final bool Function(String key) _shouldFail;

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  Future<bool> remove(String key) async {
    if (_shouldFail(key)) return false;
    return _delegate.remove(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('OnboardingService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      OnboardingService.resetForTesting();
    });

    tearDown(OnboardingService.resetForTesting);

    test('completeOnboarding persists the completion flag', () async {
      final service = await OnboardingService.getInstance();

      expect(service.isOnboardingCompleted, isFalse);

      await service.completeOnboarding();

      expect(service.isOnboardingCompleted, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('onboarding_completed'), isTrue);
    });

    test('completeOnboarding surfaces failed completion flag writes', () async {
      final delegate = await SharedPreferences.getInstance();
      final prefs = _FalseSetBoolPrefs(
        delegate,
        (key, value) => key == 'onboarding_completed' && value,
      );
      OnboardingService.overrideSharedPreferencesFactoryForTesting(
        () async => prefs,
      );
      final service = await OnboardingService.getInstance();

      await expectLater(
        service.completeOnboarding(),
        throwsA(isA<StateError>()),
      );

      expect(delegate.getBool('onboarding_completed'), isNull);
      expect(service.isOnboardingCompleted, isFalse);
    });

    test('resetOnboarding surfaces failed completion flag removals', () async {
      SharedPreferences.setMockInitialValues({'onboarding_completed': true});
      final delegate = await SharedPreferences.getInstance();
      final prefs = _FalseRemovePrefs(
        delegate,
        (key) => key == 'onboarding_completed',
      );
      OnboardingService.overrideSharedPreferencesFactoryForTesting(
        () async => prefs,
      );
      final service = await OnboardingService.getInstance();

      expect(service.isOnboardingCompleted, isTrue);

      await expectLater(service.resetOnboarding(), throwsA(isA<StateError>()));

      expect(delegate.getBool('onboarding_completed'), isTrue);
      expect(service.isOnboardingCompleted, isTrue);
    });
  });
}

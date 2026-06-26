import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages onboarding/first-launch state.
class OnboardingService {
  static const _key = 'onboarding_completed';

  static OnboardingService? _instance;
  static Future<SharedPreferences> Function() _sharedPreferencesFactory =
      SharedPreferences.getInstance;
  SharedPreferences? _prefs;

  OnboardingService._();

  static Future<OnboardingService> getInstance() async {
    if (_instance == null) {
      _instance = OnboardingService._();
      _instance!._prefs = await _sharedPreferencesFactory();
    }
    return _instance!;
  }

  @visibleForTesting
  // ignore: use_setters_to_change_properties
  static void overrideSharedPreferencesFactoryForTesting(
    Future<SharedPreferences> Function() factory,
  ) {
    _sharedPreferencesFactory = factory;
    _instance = null;
  }

  @visibleForTesting
  static void resetForTesting() {
    _sharedPreferencesFactory = SharedPreferences.getInstance;
    _instance = null;
  }

  bool get isOnboardingCompleted => _prefs?.getBool(_key) ?? false;

  Future<void> completeOnboarding() async {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError('Onboarding preferences are not initialized.');
    }
    final saved = await prefs.setBool(_key, true);
    if (!saved) {
      throw StateError('Onboarding completion flag write returned false.');
    }
  }

  /// For testing: reset onboarding state.
  Future<void> resetOnboarding() async {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError('Onboarding preferences are not initialized.');
    }
    final removed = await prefs.remove(_key);
    if (!removed) {
      throw StateError('Onboarding completion flag removal returned false.');
    }
  }
}

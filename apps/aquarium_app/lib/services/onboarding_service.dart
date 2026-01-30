import 'package:shared_preferences/shared_preferences.dart';

/// Manages onboarding/first-launch state.
class OnboardingService {
  static const _key = 'onboarding_completed';

  static OnboardingService? _instance;
  SharedPreferences? _prefs;

  OnboardingService._();

  static Future<OnboardingService> getInstance() async {
    if (_instance == null) {
      _instance = OnboardingService._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  bool get isOnboardingCompleted => _prefs?.getBool(_key) ?? false;

  Future<void> completeOnboarding() async {
    await _prefs?.setBool(_key, true);
  }

  /// For testing: reset onboarding state.
  Future<void> resetOnboarding() async {
    await _prefs?.remove(_key);
  }
}

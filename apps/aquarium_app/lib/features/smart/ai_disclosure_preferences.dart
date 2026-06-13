import 'package:shared_preferences/shared_preferences.dart';

/// Local preference helpers for Optional AI data-disclosure consent.
class AiDisclosurePreferences {
  AiDisclosurePreferences._();

  static const acceptedKey = 'openai_disclosure_accepted';

  static bool isAccepted(SharedPreferences prefs) {
    return prefs.getBool(acceptedKey) == true;
  }

  static Future<void> markAccepted(SharedPreferences prefs) {
    return prefs.setBool(acceptedKey, true);
  }

  static Future<void> reset(SharedPreferences prefs) {
    return prefs.remove(acceptedKey);
  }
}

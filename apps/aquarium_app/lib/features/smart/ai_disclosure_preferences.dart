import 'package:shared_preferences/shared_preferences.dart';

/// Local preference helpers for Optional AI data-disclosure consent.
class AiDisclosurePreferences {
  AiDisclosurePreferences._();

  static const acceptedKey = 'openai_disclosure_accepted';

  static bool isAccepted(SharedPreferences prefs) {
    return prefs.getBool(acceptedKey) == true;
  }

  static Future<void> markAccepted(SharedPreferences prefs) async {
    final saved = await prefs.setBool(acceptedKey, true);
    if (!saved) {
      throw StateError('SharedPreferences returned false for $acceptedKey');
    }
  }

  static Future<void> reset(SharedPreferences prefs) async {
    if (!prefs.containsKey(acceptedKey)) return;
    final removed = await prefs.remove(acceptedKey);
    if (!removed) {
      throw StateError('SharedPreferences returned false for $acceptedKey');
    }
  }
}

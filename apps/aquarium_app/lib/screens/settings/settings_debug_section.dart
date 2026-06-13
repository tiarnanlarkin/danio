import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import '../debug_menu_screen.dart';

// Hidden version-tap debug gate. This keeps QA tooling available in debug
// builds without exposing crash/testing controls in the normal Preferences UI.

DateTime? _lastVersionTap;
int _versionTapCount = 0;

/// Handles a tap on the version row; opens [DebugMenuScreen] after 5 taps.
void handleVersionTap(BuildContext context) {
  if (!kDebugMode) return;
  final now = DateTime.now();
  if (_lastVersionTap != null &&
      now.difference(_lastVersionTap!).inSeconds > 3) {
    _versionTapCount = 0;
  }
  _lastVersionTap = now;
  _versionTapCount++;
  if (_versionTapCount >= 5) {
    _versionTapCount = 0;
    _lastVersionTap = null;
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const DebugMenuScreen()));
  }
}

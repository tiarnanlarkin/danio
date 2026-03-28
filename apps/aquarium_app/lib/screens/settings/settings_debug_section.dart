import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/app_list_tile.dart';
import '../debug_menu_screen.dart';

/// Debug section for the settings screen (debug builds only).
///
/// Exposes a hidden 5-tap tap-to-open debug menu and a test-crash button.
/// All widgets guard themselves with [kDebugMode].
class SettingsDebugSection extends StatelessWidget {
  const SettingsDebugSection({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    return AppListTile(
      leading: const Icon(Icons.bug_report_outlined, color: AppColors.warning),
      title: 'Test Error Boundary',
      subtitle: 'Trigger a crash to test error handling',
      onTap: () => _triggerTestCrash(),
    );
  }

  void _triggerTestCrash() {
    throw Exception('Test crash triggered from settings screen');
  }
}

// ── Version-tap debug gate ─────────────────────────────────────────────────

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
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DebugMenuScreen()),
    );
  }
}

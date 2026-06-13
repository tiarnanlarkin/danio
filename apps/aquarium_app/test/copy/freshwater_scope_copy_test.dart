import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _source(String path) => File(path).readAsStringSync();

void main() {
  test('setup and guide surfaces do not advertise marine setup scope', () {
    const scopedSurfaceFiles = [
      'lib/screens/acclimation_guide_screen.dart',
      'lib/screens/equipment_guide_screen.dart',
      'lib/screens/substrate_guide_screen.dart',
      'lib/widgets/mascot/mascot_helper.dart',
    ];

    for (final path in scopedSurfaceFiles) {
      final source = _source(path);

      expect(
        source,
        isNot(contains(RegExp(r'\bmarine\b', caseSensitive: false))),
        reason: path,
      );
      expect(
        source,
        isNot(contains(RegExp(r'\bsaltwater\b', caseSensitive: false))),
        reason: path,
      );
      expect(
        source,
        isNot(contains(RegExp(r'\breef tanks\b', caseSensitive: false))),
        reason: path,
      );
    }
  });

  test('optional AI prompts stay aligned to freshwater local scope', () {
    const aiPromptFiles = [
      'lib/features/smart/fish_id/fish_id_screen.dart',
      'lib/features/smart/weekly_plan/weekly_plan_screen.dart',
      'lib/features/smart/symptom_triage/symptom_triage_screen.dart',
    ];

    for (final path in aiPromptFiles) {
      final source = _source(path);

      expect(
        source,
        isNot(contains(RegExp(r'\bmarine\b', caseSensitive: false))),
        reason: path,
      );
      expect(
        source,
        isNot(contains(RegExp(r'\bsaltwater\b', caseSensitive: false))),
        reason: path,
      );
      expect(source, contains('freshwater'), reason: path);
    }
  });
}

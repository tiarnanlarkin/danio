import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Smart AI feature fallbacks use setup copy, not unavailable copy', () {
    final serviceSource = File(
      'lib/services/openai_service.dart',
    ).readAsStringSync();
    final featureFiles = [
      'lib/features/smart/fish_id/fish_id_screen.dart',
      'lib/features/smart/symptom_triage/symptom_triage_screen.dart',
      'lib/features/smart/weekly_plan/weekly_plan_screen.dart',
      'lib/widgets/ai_stocking_suggestion.dart',
    ];

    expect(serviceSource, contains('setupRequired'));
    expect(serviceSource, contains('Optional AI is not configured'));
    expect(
      serviceSource,
      contains('Optional AI server connection is not fully configured'),
    );
    expect(serviceSource, isNot(contains('Supabase anon key is missing')));

    for (final path in featureFiles) {
      final source = File(path).readAsStringSync();

      expect(
        source,
        contains('OpenAIUserMessages.setupRequired'),
        reason: path,
      );
      expect(source, isNot(contains('isn\'t available yet')), reason: path);
      expect(
        source,
        isNot(contains('working on bringing it to you')),
        reason: path,
      );
      expect(source, isNot(contains('Use emoji')), reason: path);
      expect(source, isNot(contains('emoji sparingly')), reason: path);
      expect(
        source,
        isNot(contains(String.fromCharCode(0x2014))),
        reason: '$path contains an em dash',
      );
      expect(
        source,
        isNot(contains(String.fromCharCode(0x00b7))),
        reason: '$path contains a middle dot',
      );
    }
  });
}

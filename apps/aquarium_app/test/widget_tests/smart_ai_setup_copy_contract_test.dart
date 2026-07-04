import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Smart AI feature fallbacks use setup copy, not unavailable copy', () {
    final serviceSource = File(
      'lib/services/openai_service.dart',
    ).readAsStringSync();
    final settingsSource = File(
      'lib/screens/settings/settings_screen.dart',
    ).readAsStringSync();
    final featureFiles = [
      'lib/features/smart/fish_id/fish_id_screen.dart',
      'lib/features/smart/symptom_triage/symptom_triage_screen.dart',
      'lib/features/smart/weekly_plan/weekly_plan_screen.dart',
      'lib/widgets/ai_stocking_suggestion.dart',
      'lib/widgets/compatibility_checker_widget.dart',
    ];

    expect(serviceSource, contains('setupRequired'));
    expect(serviceSource, contains('Optional AI is not set up'));
    expect(
      serviceSource,
      contains('Optional AI is not ready in this version of Danio'),
    );
    expect(serviceSource, isNot(contains('not configured')));
    expect(serviceSource, isNot(contains('this build')));
    expect(serviceSource, isNot(contains('Supabase anon key is missing')));
    expect(serviceSource, isNot(contains('server connection')));
    expect(settingsSource, contains('Danio-managed Optional AI is active'));
    expect(
      settingsSource,
      contains('Optional AI is not ready in this version of Danio'),
    );
    expect(settingsSource, isNot(contains('this build')));
    expect(settingsSource, isNot(contains('server connection')));
    expect(settingsSource, isNot(contains('server proxy')));

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

  test('Optional AI request surfaces require the shared disclosure gate', () {
    final requestFiles = [
      'lib/widgets/ai_stocking_suggestion.dart',
      'lib/widgets/compatibility_checker_widget.dart',
      'lib/features/smart/fish_id/fish_id_screen.dart',
      'lib/features/smart/symptom_triage/symptom_triage_screen.dart',
      'lib/features/smart/weekly_plan/weekly_plan_screen.dart',
      'lib/screens/smart_screen.dart',
    ];

    for (final path in requestFiles) {
      final source = File(path).readAsStringSync();

      expect(
        source,
        contains('ensureOpenAIDisclosureAccepted('),
        reason: path,
      );
    }
  });

  test('OpenAI disclosure gate failures stop before AI requests', () {
    final gateFile = File('lib/features/smart/openai_disclosure_gate.dart');

    expect(gateFile.existsSync(), isTrue);

    final source = gateFile.readAsStringSync();
    final normalizedSource = source.replaceAll(r"\'", "'");

    expect(
      source,
      contains('failed to save AI disclosure acceptance'),
      reason: gateFile.path,
    );
    expect(
      normalizedSource,
      contains("Couldn't save AI disclosure. Try again."),
      reason: gateFile.path,
    );
    expect(source, contains('return false;'), reason: gateFile.path);
  });
}

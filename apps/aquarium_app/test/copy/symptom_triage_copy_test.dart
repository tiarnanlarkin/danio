import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Symptom Triage copy has no mojibake artifacts', () {
    final source = File(
      'lib/features/smart/symptom_triage/symptom_triage_screen.dart',
    ).readAsStringSync();

    final mojibakeMarkers = [
      String.fromCharCode(0x00c2), // Common leading artifact in degree text.
      String.fromCharCode(0x00f0), // Common leading artifact in emoji mojibake.
      '${String.fromCharCode(0x00e2)}${String.fromCharCode(0x20ac)}',
    ];

    for (final marker in mojibakeMarkers) {
      expect(source, isNot(contains(marker)), reason: marker.codeUnits.join());
    }

    expect(source, contains('Most Likely Diagnosis'));
    expect(source, contains('Urgency Level'));
    expect(source, contains('Immediate Actions'));
    expect(source, contains('Treatment Options'));
  });

  test('Symptom Triage AI and journal copy use plain headings', () {
    final source = File(
      'lib/features/smart/symptom_triage/symptom_triage_screen.dart',
    ).readAsStringSync();

    final decorativeMarkers = [
      String.fromCharCode(0x1f50d),
      String.fromCharCode(0x26a0),
      String.fromCharCode(0x1fa7a),
      String.fromCharCode(0x1f48a),
      String.fromCharCode(0x1f52c),
      String.fromCharCode(0x2705),
    ];

    for (final marker in decorativeMarkers) {
      expect(source, isNot(contains(marker)), reason: marker.runes.join());
    }

    expect(source, contains("'## Most Likely Diagnosis\\n'"));
    expect(source, contains("'## Urgency Level\\n'"));
    expect(source, contains("'## Immediate Actions\\n'"));
    expect(source, contains("'## Treatment Options\\n'"));
    expect(source, contains("'Symptom Triage Result\\n\\n\$diagnosisText'"));
    expect(source, contains("'Diagnosis saved to journal'"));
  });
}

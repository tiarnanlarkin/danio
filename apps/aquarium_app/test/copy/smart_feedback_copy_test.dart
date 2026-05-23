import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Smart feature screens use Danio feedback wrappers for snackbars', () {
    final featureFiles = [
      'lib/features/smart/fish_id/fish_id_screen.dart',
      'lib/features/smart/symptom_triage/symptom_triage_screen.dart',
    ];

    for (final path in featureFiles) {
      final source = File(path).readAsStringSync();

      expect(source, isNot(contains('ScaffoldMessenger.of')), reason: path);
      expect(source, isNot(contains('SnackBar(')), reason: path);
      expect(source, contains('DanioSnackBar'), reason: path);
    }
  });
}

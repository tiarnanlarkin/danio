import 'dart:io';

import 'package:danio/theme/danio_surface_visuals.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('audited primary surfaces do not contain raw emoji strings', () {
    final files = [
      'lib/screens/smart_screen.dart',
      'lib/screens/settings/settings_screen.dart',
      'lib/screens/shop_street_screen.dart',
      'lib/screens/gem_shop_screen.dart',
      'lib/screens/achievements_screen.dart',
      'lib/screens/workshop_screen.dart',
      'lib/screens/compatibility_checker_screen.dart',
      'lib/screens/onboarding/xp_celebration_screen.dart',
      'lib/screens/onboarding/fish_select_screen.dart',
      'lib/screens/onboarding/feature_summary_screen.dart',
    ];
    final emoji = RegExp(
      r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE0F}]',
      unicode: true,
    );

    for (final path in files) {
      final source = File(path).readAsStringSync();
      expect(source, isNot(matches(emoji)), reason: path);
    }
  });

  test('Danio surface visual helper covers every polished key', () {
    for (final key in DanioSurfaceVisualKey.values) {
      final visual = danioSurfaceVisual(key);
      expect(visual.icon, isNotNull, reason: key.name);
      expect(visual.color, isNotNull, reason: key.name);
    }
  });

  test('AppCard does not emit a generic duplicate semantics label', () {
    final source = File('lib/widgets/core/app_card.dart').readAsStringSync();

    expect(source, isNot(contains('Interactive card')));
  });
}

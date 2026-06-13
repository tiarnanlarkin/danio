import 'dart:io';

import 'package:danio/data/shop_catalog.dart';
import 'package:danio/theme/danio_surface_visuals.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('audited primary surfaces do not contain raw emoji strings', () {
    final files = [
      'lib/screens/smart_screen.dart',
      'lib/screens/settings_hub_screen.dart',
      'lib/screens/settings/settings_screen.dart',
      'lib/screens/shop_street_screen.dart',
      'lib/screens/gem_shop_screen.dart',
      'lib/screens/inventory_screen.dart',
      'lib/screens/achievements_screen.dart',
      'lib/screens/livestock_detail_screen.dart',
      'lib/screens/workshop_screen.dart',
      'lib/screens/compatibility_checker_screen.dart',
      'lib/screens/tank_settings_screen.dart',
      'lib/screens/tank_detail/widgets/tank_health_card.dart',
      'lib/screens/create_tank_screen/widgets/basic_info_page.dart',
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

  test('audited shop screens do not render catalog emoji fields', () {
    final files = [
      'lib/screens/gem_shop_screen.dart',
      'lib/screens/inventory_screen.dart',
      'lib/screens/shop_street_screen.dart',
    ];

    for (final path in files) {
      final source = File(path).readAsStringSync();
      expect(source, isNot(contains('.emoji')), reason: path);
    }
  });

  test('tank health factors use icons rather than Unicode text markers', () {
    final source = File(
      'lib/screens/tank_detail/widgets/tank_health_card.dart',
    ).readAsStringSync();

    expect(source, isNot(contains(r'\u2705')));
    expect(source, isNot(contains(r'\u26A0')));
    expect(source, isNot(contains(r'\u2139')));
    expect(source, isNot(contains(r'\uFE0F')));
    expect(source, isNot(contains(r'\u2022')));
    expect(source, contains('Icons.info_outline'));
    expect(source, contains('Icons.warning_amber_outlined'));
    expect(source, contains('Icons.check_circle_outline'));
  });

  test('shipped surfaces avoid placeholder availability copy', () {
    final files = [
      'lib/screens/gem_shop_screen.dart',
      'lib/screens/shop_street_screen.dart',
      'lib/screens/tank_settings_screen.dart',
      'lib/screens/create_tank_screen/widgets/basic_info_page.dart',
    ];

    final placeholder = RegExp(
      r'on the way|coming soon|arriving soon|stay tuned|check back soon|planned',
      caseSensitive: false,
    );

    for (final path in files) {
      final source = File(path).readAsStringSync();
      expect(source, isNot(matches(placeholder)), reason: path);
    }
  });

  test('bottom-tab header badge shadows use shared alpha tokens', () {
    final files = [
      'lib/screens/learn/learn_screen.dart',
      'lib/screens/practice_hub_screen.dart',
      'lib/screens/smart_screen.dart',
    ];

    for (final path in files) {
      final source = File(path).readAsStringSync();
      expect(source, contains('AppColors.blackAlpha35'), reason: path);
      expect(
        source,
        isNot(contains('Colors.black.withValues(alpha: 0.35)')),
        reason: path,
      );
    }
  });

  test('unlock celebration uses shared white alpha tokens', () {
    final source = File(
      'lib/screens/learn/unlock_celebration_screen.dart',
    ).readAsStringSync();

    expect(source, contains('AppColors.whiteAlpha70'));
    expect(source, contains('AppColors.whiteAlpha60'));
    expect(source, contains('AppColors.whiteAlpha85'));
    expect(source, isNot(contains('Colors.white70')));
    expect(source, isNot(contains('Colors.white60')));
    expect(source, isNot(contains('Colors.white.withValues(alpha: 0.85)')));
  });

  test('Danio surface visual helper covers shipped shop item types', () {
    final visualNames = DanioSurfaceVisualKey.values
        .map((key) => key.name)
        .toSet();

    expect(
      visualNames,
      containsAll([
        'shopXpBoost',
        'shopStreakFreeze',
        'shopHeartsRefill',
        'shopGoalShield',
        'shopLessonHelper',
        'shopProfileBadge',
        'shopTankTheme',
        'shopCelebration',
      ]),
    );

    for (final item in ShopCatalog.availableItems) {
      final visual = danioShopItemVisual(item);
      expect(visual.icon, isNotNull, reason: item.id);
      expect(visual.color, isNotNull, reason: item.id);
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

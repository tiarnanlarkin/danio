import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('debug deep links expose standalone QA gap routes', () {
    final source = File(
      'lib/services/debug_deep_link_service.dart',
    ).readAsStringSync();

    final routes = <String>[
      'backup',
      'search',
      'notification-settings',
      'account',
      'about',
      'privacy',
      'terms',
      'shop',
      'wishlist',
      'gem-shop',
      'inventory',
      'aquarium-intelligence',
      'symptom-triage',
      'weekly-plan',
      'fish-id',
      'water-change',
      'tank-volume',
      'dosing',
      'co2',
      'lighting',
      'stocking',
      'compatibility',
      'unit-converter',
      'cost-tracker',
      'emergency-guide',
      'quick-start-guide',
      'nitrogen-cycle-guide',
      'parameter-guide',
      'algae-guide',
      'disease-guide',
      'feeding-guide',
      'acclimation-guide',
      'quarantine-guide',
      'breeding-guide',
      'equipment-guide',
      'substrate-guide',
      'hardscape-guide',
      'vacation-guide',
      'troubleshooting',
    ];

    for (final route in routes) {
      expect(
        source,
        contains("case '$route':"),
        reason: 'Missing danio://qa/$route debug deep link.',
      );
    }

    expect(source, contains('WishlistCategory.fish'));
    expect(source, contains('AquariumIntelligenceScreen'));
    expect(source, contains('TroubleshootingScreen'));
  });
}

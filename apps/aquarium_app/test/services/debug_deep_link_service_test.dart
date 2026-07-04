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
      'demo-tank',
      'today-board',
      'tank-detail',
      'tank-settings',
      'add-log',
      'logs',
      'log-detail',
      'tank-journal',
      'photo-gallery',
      'water-charts',
      'analytics',
      'tasks',
      'maintenance-checklist',
      'equipment',
      'livestock',
      'livestock-detail',
      'livestock-value',
      'reminders',
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
      'cycling-assistant',
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
      'learning-path-detail',
      'unlock-celebration',
      'story-browser',
      'story-play',
      'spaced-repetition',
      'difficulty-settings',
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
    expect(source, contains('tankActionsProvider'));
    expect(source, contains('LearningPathDetailScreen'));
    expect(source, contains('StoryPlayScreen'));
    expect(source, contains('TroubleshootingScreen'));
  });
}

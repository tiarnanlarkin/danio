import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _source(String path) => File(path).readAsStringSync();

void main() {
  test('local reward system avoids dormant social feature scaffolding', () {
    final files = {
      'lib/data/achievements.dart': RegExp(
        'social_butterfly|Social Butterfly|friends feature',
        caseSensitive: false,
      ),
      'lib/services/achievement_service.dart': RegExp(
        'friendsCount|social_butterfly',
        caseSensitive: false,
      ),
      'lib/providers/achievement_provider.dart': RegExp(
        'checkAfterFriendAdded|friendsCount|friend added',
        caseSensitive: false,
      ),
      'lib/models/gem_transaction.dart': RegExp(
        'referralBonus|Referred a friend',
        caseSensitive: false,
      ),
      'lib/models/gem_economy.dart': RegExp(
        'referralBonus|Friend completes onboarding',
        caseSensitive: false,
      ),
    };

    for (final entry in files.entries) {
      expect(
        _source(entry.key),
        isNot(contains(entry.value)),
        reason: entry.key,
      );
    }
  });
}

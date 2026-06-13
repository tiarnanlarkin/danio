import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _source(String path) => File(path).readAsStringSync();

void main() {
  test('weekly progress copy avoids social leaderboard promises', () {
    final files = [
      'lib/models/leaderboard.dart',
      'lib/models/user_profile.dart',
      'lib/data/achievements.dart',
      'lib/services/analytics_service.dart',
      'lib/services/difficulty_service.dart',
      'lib/providers/user_profile_notifier.dart',
    ];
    final oldCopy = RegExp(
      'Bronze League|Silver League|Gold League|Diamond League|'
      'League Climber|Leaderboard/Competition|Determine league|'
      'competitive spirit|competitive league|'
      'leaderboard/progress view|promote to|secure your promotion',
      caseSensitive: false,
    );

    for (final path in files) {
      expect(_source(path), isNot(contains(oldCopy)), reason: path);
    }

    expect(_source('lib/models/leaderboard.dart'), contains('Bronze Tier'));
    expect(_source('lib/data/achievements.dart'), contains('Weekly Climber'));
    expect(
      _source('lib/services/analytics_service.dart'),
      contains('next weekly tier'),
    );
  });
}

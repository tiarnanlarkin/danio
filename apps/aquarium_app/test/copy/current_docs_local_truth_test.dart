import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _source(String path) => File(path).readAsStringSync();

void main() {
  test('current docs describe the local-first build honestly', () {
    final staleClaims = {
      'README.md': RegExp(
        'uses Supabase for its backend|'
        'Supabase \\(Postgres \\+ Auth \\+ Realtime\\)|'
        'Business logic services \\(sync, backup, analytics\\)|'
        'Supabase client initialisation',
        caseSensitive: false,
      ),
      'docs/feature-registry.md': RegExp(
        'SyncService|Displays fake sync counts|'
        'Friends \\(CA-002\\)|Leaderboard \\(CA-003\\)',
        caseSensitive: false,
      ),
      'docs/data-resilience-audit.md': RegExp(
        'SyncService|queued for eventual sync|'
        'Via sync queue|Backend Sync Scaffold|friends / social',
        caseSensitive: false,
      ),
    };

    for (final entry in staleClaims.entries) {
      expect(
        _source(entry.key),
        isNot(contains(entry.value)),
        reason: entry.key,
      );
    }

    expect(_source('README.md'), contains('local-first'));
    expect(
      _source('docs/feature-registry.md'),
      contains('dormant backend-sync queue code has been removed'),
    );
    expect(
      _source('docs/data-resilience-audit.md'),
      contains('No dormant backend queue remains in the current local build'),
    );
  });
}

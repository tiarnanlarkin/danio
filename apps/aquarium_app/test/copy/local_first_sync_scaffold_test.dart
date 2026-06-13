import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _source(String path) => File(path).readAsStringSync();

void main() {
  test(
    'local-first profile activity avoids dormant backend sync scaffolding',
    () {
      final scaffoldFiles = [
        'lib/providers/sync_provider.dart',
        'lib/services/offline_aware_service.dart',
        'lib/services/sync_service.dart',
        'lib/services/conflict_resolver.dart',
      ];

      for (final path in scaffoldFiles) {
        expect(File(path).existsSync(), isFalse, reason: path);
      }

      final profileSource = _source('lib/providers/user_profile_notifier.dart');
      final dormantSyncTerms = RegExp(
        'offlineAwareServiceProvider|SyncActionType|sync_queue|queued for sync|'
        'Backend sync not yet implemented|Sync queue is scaffolding',
        caseSensitive: false,
      );

      expect(profileSource, isNot(contains(dormantSyncTerms)));
    },
  );
}

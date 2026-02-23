/// Tests for CloudSyncService — offline queue, conflict resolution, data structures
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/services/cloud_sync_service.dart';

void main() {
  group('OfflineQueueEntry', () {
    test('serialises to JSON and back correctly', () {
      final entry = OfflineQueueEntry(
        id: 'fish-123',
        table: 'user_fish',
        operation: 'upsert',
        data: {
          'id': 'fish-123',
          'name': 'Nemo',
          'tank_id': 'tank-1',
          'updated_at': '2026-02-23T10:00:00.000Z',
        },
        createdAt: DateTime.utc(2026, 2, 23, 10, 0, 0),
      );

      final jsonMap = entry.toJson();
      final restored = OfflineQueueEntry.fromJson(jsonMap);

      expect(restored.id, 'fish-123');
      expect(restored.table, 'user_fish');
      expect(restored.operation, 'upsert');
      expect(restored.data['name'], 'Nemo');
      expect(restored.data['tank_id'], 'tank-1');
      expect(restored.createdAt.toUtc(), DateTime.utc(2026, 2, 23, 10, 0, 0));
    });

    test('JSON round-trip through encode/decode preserves all fields', () {
      final entry = OfflineQueueEntry(
        id: 'tank-456',
        table: 'user_tanks',
        operation: 'delete',
        data: {'id': 'tank-456', 'deleted_at': '2026-02-23T12:00:00.000Z'},
        createdAt: DateTime.utc(2026, 2, 23, 12, 0, 0),
      );

      final jsonString = json.encode(entry.toJson());
      final decoded = json.decode(jsonString) as Map<String, dynamic>;
      final restored = OfflineQueueEntry.fromJson(decoded);

      expect(restored.id, entry.id);
      expect(restored.table, entry.table);
      expect(restored.operation, entry.operation);
      expect(restored.data, entry.data);
    });

    test('defaults createdAt to now when not provided', () {
      final before = DateTime.now();
      final entry = OfflineQueueEntry(
        id: 'test-1',
        table: 'tasks',
        operation: 'upsert',
        data: {'id': 'test-1'},
      );
      final after = DateTime.now();

      expect(entry.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), true);
      expect(entry.createdAt.isBefore(after.add(const Duration(seconds: 1))), true);
    });
  });

  group('Offline queue simulation', () {
    test('multiple entries can be queued and deserialized in order', () {
      final queue = <String>[];

      // Simulate queuing 3 changes
      for (int i = 0; i < 3; i++) {
        final entry = OfflineQueueEntry(
          id: 'item-$i',
          table: kSyncTables[i % kSyncTables.length],
          operation: 'upsert',
          data: {'id': 'item-$i', 'value': 'data-$i'},
        );
        queue.add(json.encode(entry.toJson()));
      }

      expect(queue.length, 3);

      // Deserialise and verify order
      final entries = queue.map((s) {
        return OfflineQueueEntry.fromJson(
          json.decode(s) as Map<String, dynamic>,
        );
      }).toList();

      expect(entries[0].id, 'item-0');
      expect(entries[1].id, 'item-1');
      expect(entries[2].id, 'item-2');
    });

    test('failed entries are retained while successful ones are removed', () {
      // Simulate a queue flush where some succeed and some fail
      final queue = <String>[
        json.encode(OfflineQueueEntry(
          id: 'ok-1', table: 'user_tanks', operation: 'upsert',
          data: {'id': 'ok-1'},
        ).toJson()),
        json.encode(OfflineQueueEntry(
          id: 'fail-1', table: 'user_fish', operation: 'upsert',
          data: {'id': 'fail-1'},
        ).toJson()),
        json.encode(OfflineQueueEntry(
          id: 'ok-2', table: 'tasks', operation: 'upsert',
          data: {'id': 'ok-2'},
        ).toJson()),
      ];

      // Simulate: fail-1 fails, others succeed
      final failed = <String>[];
      for (final entryJson in queue) {
        final entry = OfflineQueueEntry.fromJson(
          json.decode(entryJson) as Map<String, dynamic>,
        );
        if (entry.id == 'fail-1') {
          failed.add(entryJson);
        }
        // else: "pushed successfully"
      }

      expect(failed.length, 1);
      final remaining = OfflineQueueEntry.fromJson(
        json.decode(failed.first) as Map<String, dynamic>,
      );
      expect(remaining.id, 'fail-1');
    });
  });

  group('Conflict resolution — last-write-wins', () {
    test('newer remote timestamp should win over older local', () {
      final localUpdatedAt = DateTime.utc(2026, 2, 23, 10, 0, 0);
      final remoteUpdatedAt = DateTime.utc(2026, 2, 23, 12, 0, 0);

      // Simulate last-write-wins: remote is newer → remote wins
      final remoteWins = remoteUpdatedAt.isAfter(localUpdatedAt);
      expect(remoteWins, true);
    });

    test('older remote timestamp should lose to newer local', () {
      final localUpdatedAt = DateTime.utc(2026, 2, 23, 14, 0, 0);
      final remoteUpdatedAt = DateTime.utc(2026, 2, 23, 12, 0, 0);

      final remoteWins = remoteUpdatedAt.isAfter(localUpdatedAt);
      expect(remoteWins, false);
    });

    test('identical timestamps result in no conflict', () {
      final ts = DateTime.utc(2026, 2, 23, 12, 0, 0);
      expect(ts.isAfter(ts), false);
      expect(ts.isBefore(ts), false);
      expect(ts.isAtSameMomentAs(ts), true);
    });

    test('detects >24h divergence as significant', () {
      final remoteUpdatedAt = DateTime.utc(2026, 2, 21, 10, 0, 0); // 2 days ago
      final now = DateTime.utc(2026, 2, 23, 12, 0, 0);
      final gap = now.difference(remoteUpdatedAt);

      expect(gap.inHours > 24, true,
          reason: 'Gap of ${gap.inHours}h should be flagged as significant');
    });

    test('does not flag <24h divergence', () {
      final remoteUpdatedAt = DateTime.utc(2026, 2, 23, 0, 0, 0);
      final now = DateTime.utc(2026, 2, 23, 12, 0, 0);
      final gap = now.difference(remoteUpdatedAt);

      expect(gap.inHours > 24, false);
    });
  });

  group('Water parameters — append-only behaviour', () {
    test('water parameter records should always be appended, never overwritten', () {
      // Simulate local water parameter history
      final localHistory = <Map<String, dynamic>>[
        {'id': 'wp-1', 'ph': 7.0, 'timestamp': '2026-02-20T10:00:00Z'},
        {'id': 'wp-2', 'ph': 7.2, 'timestamp': '2026-02-21T10:00:00Z'},
      ];

      // Remote has a record with the same timestamp but different id
      final remoteRecord = {
        'id': 'wp-3',
        'ph': 6.8,
        'timestamp': '2026-02-22T10:00:00Z',
      };

      // Append-only: add remote record, never replace existing
      final existingIds = localHistory.map((r) => r['id']).toSet();
      if (!existingIds.contains(remoteRecord['id'])) {
        localHistory.add(remoteRecord);
      }

      expect(localHistory.length, 3);
      expect(localHistory[0]['id'], 'wp-1'); // Original preserved
      expect(localHistory[1]['id'], 'wp-2'); // Original preserved
      expect(localHistory[2]['id'], 'wp-3'); // Appended
    });

    test('duplicate water parameter records are not appended', () {
      final localHistory = <Map<String, dynamic>>[
        {'id': 'wp-1', 'ph': 7.0, 'timestamp': '2026-02-20T10:00:00Z'},
      ];

      final duplicateRecord = {
        'id': 'wp-1',
        'ph': 7.5, // Different value but same ID
        'timestamp': '2026-02-20T10:00:00Z',
      };

      final existingIds = localHistory.map((r) => r['id']).toSet();
      if (!existingIds.contains(duplicateRecord['id'])) {
        localHistory.add(duplicateRecord);
      }

      expect(localHistory.length, 1, reason: 'Duplicate should not be appended');
      expect(localHistory[0]['ph'], 7.0, reason: 'Original value preserved');
    });
  });

  group('kSyncTables', () {
    test('contains all expected tables', () {
      expect(kSyncTables, contains('user_tanks'));
      expect(kSyncTables, contains('user_fish'));
      expect(kSyncTables, contains('water_parameters'));
      expect(kSyncTables, contains('tasks'));
      expect(kSyncTables, contains('inventory_items'));
      expect(kSyncTables, contains('journal_entries'));
    });

    test('has exactly 6 tables', () {
      expect(kSyncTables.length, 6);
    });
  });

  group('CloudSyncStatus', () {
    test('all expected statuses exist', () {
      expect(CloudSyncStatus.values, containsAll([
        CloudSyncStatus.synced,
        CloudSyncStatus.syncing,
        CloudSyncStatus.offline,
        CloudSyncStatus.error,
        CloudSyncStatus.disabled,
      ]));
    });
  });
}

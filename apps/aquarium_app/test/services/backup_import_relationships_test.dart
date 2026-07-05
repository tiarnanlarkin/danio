import 'package:flutter_test/flutter_test.dart';

import 'package:danio/services/backup_import_relationships.dart';

void main() {
  group('backup import relationship remapping', () {
    test('remaps log relationships to regenerated entity IDs', () {
      final remapped = remapBackupLogRelationships(
        {
          'id': 'old-log',
          'relatedEquipmentId': 'old-equipment',
          'relatedLivestockId': 'old-fish',
          'relatedTaskId': 'old-task',
        },
        equipmentIdMap: {'old-equipment': 'new-equipment'},
        livestockIdMap: {'old-fish': 'new-fish'},
        taskIdMap: {'old-task': 'new-task'},
      );

      expect(remapped['relatedEquipmentId'], 'new-equipment');
      expect(remapped['relatedLivestockId'], 'new-fish');
      expect(remapped['relatedTaskId'], 'new-task');
    });

    test(
      'rejects log relationships when the referenced entity was not imported',
      () {
        expect(
          () => remapBackupLogRelationships(
            {
              'id': 'old-log',
              'relatedEquipmentId': 'missing-equipment',
              'relatedLivestockId': 'missing-fish',
              'relatedTaskId': 'missing-task',
            },
            equipmentIdMap: const {},
            livestockIdMap: const {},
            taskIdMap: const {},
          ),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'message',
              contains(
                'Invalid backup: logs relatedEquipmentId values must reference imported equipment records',
              ),
            ),
          ),
        );
      },
    );

    test('remaps task equipment relationship to regenerated equipment ID', () {
      final remapped = remapBackupTaskRelationships(
        {'id': 'old-task', 'relatedEquipmentId': 'old-equipment'},
        equipmentIdMap: {'old-equipment': 'new-equipment'},
      );

      expect(remapped['relatedEquipmentId'], 'new-equipment');
    });

    test(
      'rejects task equipment relationships when equipment was not imported',
      () {
        expect(
          () => remapBackupTaskRelationships(
            {'id': 'old-task', 'relatedEquipmentId': 'missing-equipment'},
            equipmentIdMap: const {},
          ),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'message',
              contains(
                'Invalid backup: tasks relatedEquipmentId values must reference imported equipment records',
              ),
            ),
          ),
        );
      },
    );
  });
}

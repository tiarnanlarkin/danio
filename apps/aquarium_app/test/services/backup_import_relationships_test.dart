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
      'drops log relationships when the referenced entity was not imported',
      () {
        final remapped = remapBackupLogRelationships(
          {
            'id': 'old-log',
            'relatedEquipmentId': 'missing-equipment',
            'relatedLivestockId': 'missing-fish',
            'relatedTaskId': 'missing-task',
          },
          equipmentIdMap: const {},
          livestockIdMap: const {},
          taskIdMap: const {},
        );

        expect(remapped['relatedEquipmentId'], isNull);
        expect(remapped['relatedLivestockId'], isNull);
        expect(remapped['relatedTaskId'], isNull);
      },
    );

    test('remaps task equipment relationship to regenerated equipment ID', () {
      final remapped = remapBackupTaskRelationships(
        {'id': 'old-task', 'relatedEquipmentId': 'old-equipment'},
        equipmentIdMap: {'old-equipment': 'new-equipment'},
      );

      expect(remapped['relatedEquipmentId'], 'new-equipment');
    });
  });
}

String? remapBackupRelatedId(
  Object? oldId,
  Map<String, String> idMap, {
  required String sourceCollection,
  required String field,
  required String targetLabel,
}) {
  if (oldId is! String || oldId.isEmpty) return null;
  final newId = idMap[oldId];
  if (newId == null) {
    throw FormatException(
      'Invalid backup: $sourceCollection $field values must reference imported $targetLabel records',
    );
  }
  return newId;
}

Map<String, dynamic> remapBackupLogRelationships(
  Map<String, dynamic> logJson, {
  required Map<String, String> equipmentIdMap,
  required Map<String, String> livestockIdMap,
  required Map<String, String> taskIdMap,
}) {
  return {
    ...logJson,
    'relatedEquipmentId': remapBackupRelatedId(
      logJson['relatedEquipmentId'],
      equipmentIdMap,
      sourceCollection: 'logs',
      field: 'relatedEquipmentId',
      targetLabel: 'equipment',
    ),
    'relatedLivestockId': remapBackupRelatedId(
      logJson['relatedLivestockId'],
      livestockIdMap,
      sourceCollection: 'logs',
      field: 'relatedLivestockId',
      targetLabel: 'livestock',
    ),
    'relatedTaskId': remapBackupRelatedId(
      logJson['relatedTaskId'],
      taskIdMap,
      sourceCollection: 'logs',
      field: 'relatedTaskId',
      targetLabel: 'task',
    ),
  };
}

Map<String, dynamic> remapBackupTaskRelationships(
  Map<String, dynamic> taskJson, {
  required Map<String, String> equipmentIdMap,
}) {
  return {
    ...taskJson,
    'relatedEquipmentId': remapBackupRelatedId(
      taskJson['relatedEquipmentId'],
      equipmentIdMap,
      sourceCollection: 'tasks',
      field: 'relatedEquipmentId',
      targetLabel: 'equipment',
    ),
  };
}

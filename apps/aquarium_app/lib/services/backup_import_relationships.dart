String? remapBackupRelatedId(Object? oldId, Map<String, String> idMap) {
  if (oldId is! String || oldId.isEmpty) return null;
  return idMap[oldId];
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
    ),
    'relatedLivestockId': remapBackupRelatedId(
      logJson['relatedLivestockId'],
      livestockIdMap,
    ),
    'relatedTaskId': remapBackupRelatedId(logJson['relatedTaskId'], taskIdMap),
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
    ),
  };
}

String? remapBackupRelatedId(
  Object? oldId,
  Map<String, String> idMap, {
  required String sourceCollection,
  required String field,
  required String targetLabel,
}) {
  if (oldId == null) return null;
  if (oldId is! String) {
    throw FormatException(
      'Invalid backup: $sourceCollection $field values must be strings',
    );
  }
  if (oldId.isEmpty) return null;
  final newId = idMap[oldId];
  if (newId == null) {
    throw FormatException(
      'Invalid backup: $sourceCollection $field values must reference imported $targetLabel records',
    );
  }
  return newId;
}

bool isBackupLivestockRemovalTombstone(
  Map<dynamic, dynamic> logJson, {
  required bool hasLiveLivestockTarget,
}) {
  final oldId = logJson['relatedLivestockId'];
  return logJson['type'] == 'livestockRemoved' &&
      oldId is String &&
      oldId.trim().isNotEmpty &&
      !hasLiveLivestockTarget;
}

String? backupLiveLivestockIdMapKey(
  Object? relatedLivestockId,
  Iterable<String> liveLivestockIds,
) {
  if (relatedLivestockId is! String) return null;
  if (liveLivestockIds.contains(relatedLivestockId)) {
    return relatedLivestockId;
  }

  final normalizedId = relatedLivestockId.trim();
  for (final liveId in liveLivestockIds) {
    if (liveId.trim() == normalizedId) return liveId;
  }
  return null;
}

Map<String, dynamic> remapBackupLogRelationships(
  Map<String, dynamic> logJson, {
  required Map<String, String> equipmentIdMap,
  required Map<String, String> livestockIdMap,
  required Map<String, String> taskIdMap,
}) {
  final oldLivestockId = logJson['relatedLivestockId'];
  final liveLivestockIdMapKey = backupLiveLivestockIdMapKey(
    oldLivestockId,
    livestockIdMap.keys,
  );
  final hasLiveLivestockTarget = liveLivestockIdMapKey != null;

  return {
    ...logJson,
    'relatedEquipmentId': remapBackupRelatedId(
      logJson['relatedEquipmentId'],
      equipmentIdMap,
      sourceCollection: 'logs',
      field: 'relatedEquipmentId',
      targetLabel: 'equipment',
    ),
    'relatedLivestockId':
        isBackupLivestockRemovalTombstone(
          logJson,
          hasLiveLivestockTarget: hasLiveLivestockTarget,
        )
        ? oldLivestockId
        : remapBackupRelatedId(
            liveLivestockIdMapKey ?? oldLivestockId,
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

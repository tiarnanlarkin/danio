
import '../utils/logger.dart';

/// Strategy for resolving conflicts between local and remote data
enum ConflictResolutionStrategy {
  /// Most recent update wins (based on timestamp)
  lastWriteWins,

  /// Local changes always take precedence
  localWins,

  /// Remote changes always take precedence
  remoteWins,

  /// Merge both changes intelligently
  merge,
}

/// Result of a conflict resolution
class ConflictResolution<T> {
  final T resolved;
  final bool hadConflict;
  final String? conflictDescription;
  final ConflictResolutionStrategy strategyUsed;

  const ConflictResolution({
    required this.resolved,
    required this.hadConflict,
    this.conflictDescription,
    required this.strategyUsed,
  });
}

/// Service for resolving data conflicts during sync
class ConflictResolver {
  /// Resolve conflict between local and remote data
  ///
  /// This is the main entry point for conflict resolution.
  /// For a local-only app, this handles edge cases where the same data
  /// was modified in quick succession or queued multiple times.
  static ConflictResolution<Map<String, dynamic>> resolve({
    required Map<String, dynamic> local,
    required Map<String, dynamic> remote,
    ConflictResolutionStrategy strategy =
        ConflictResolutionStrategy.lastWriteWins,
  }) {
    switch (strategy) {
      case ConflictResolutionStrategy.lastWriteWins:
        return _resolveLastWriteWins(local, remote);

      case ConflictResolutionStrategy.localWins:
        return ConflictResolution(
          resolved: local,
          hadConflict: !_areEqual(local, remote),
          conflictDescription: 'Local changes preserved',
          strategyUsed: strategy,
        );

      case ConflictResolutionStrategy.remoteWins:
        return ConflictResolution(
          resolved: remote,
          hadConflict: !_areEqual(local, remote),
          conflictDescription: 'Remote changes preserved',
          strategyUsed: strategy,
        );

      case ConflictResolutionStrategy.merge:
        return _resolveMerge(local, remote);
    }
  }

  /// Last-write-wins: Compare timestamps and keep most recent
  static ConflictResolution<Map<String, dynamic>> _resolveLastWriteWins(
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
  ) {
    // Extract timestamps
    final localTime = _extractTimestamp(local);
    final remoteTime = _extractTimestamp(remote);

    // If we can't determine timestamps, merge
    if (localTime == null && remoteTime == null) {
      return _resolveMerge(local, remote);
    }

    // One timestamp missing - prefer the one with timestamp
    if (localTime == null) {
      return ConflictResolution(
        resolved: remote,
        hadConflict: true,
        conflictDescription: 'Local missing timestamp, using remote',
        strategyUsed: ConflictResolutionStrategy.lastWriteWins,
      );
    }

    if (remoteTime == null) {
      return ConflictResolution(
        resolved: local,
        hadConflict: true,
        conflictDescription: 'Remote missing timestamp, using local',
        strategyUsed: ConflictResolutionStrategy.lastWriteWins,
      );
    }

    // Compare timestamps
    final hasConflict = !_areEqual(local, remote);

    if (localTime.isAfter(remoteTime)) {
      return ConflictResolution(
        resolved: local,
        hadConflict: hasConflict,
        conflictDescription: hasConflict
            ? 'Local is newer (${_formatTimeDiff(localTime, remoteTime)})'
            : null,
        strategyUsed: ConflictResolutionStrategy.lastWriteWins,
      );
    } else if (remoteTime.isAfter(localTime)) {
      return ConflictResolution(
        resolved: remote,
        hadConflict: hasConflict,
        conflictDescription: hasConflict
            ? 'Remote is newer (${_formatTimeDiff(remoteTime, localTime)})'
            : null,
        strategyUsed: ConflictResolutionStrategy.lastWriteWins,
      );
    } else {
      // Same timestamp - prefer local
      return ConflictResolution(
        resolved: local,
        hadConflict: hasConflict,
        conflictDescription: hasConflict
            ? 'Same timestamp, keeping local'
            : null,
        strategyUsed: ConflictResolutionStrategy.lastWriteWins,
      );
    }
  }

  /// Merge strategy: Intelligently combine both changes
  static ConflictResolution<Map<String, dynamic>> _resolveMerge(
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
  ) {
    final merged = <String, dynamic>{};
    final conflicts = <String>[];

    // Get all keys from both maps
    final allKeys = {...local.keys, ...remote.keys};

    for (final key in allKeys) {
      final localValue = local[key];
      final remoteValue = remote[key];

      // If key only exists in one, use that value
      if (localValue == null) {
        merged[key] = remoteValue;
      } else if (remoteValue == null) {
        merged[key] = localValue;
      } else if (_areEqual(localValue, remoteValue)) {
        // Values are the same
        merged[key] = localValue;
      } else {
        // Values differ - apply merge strategy based on type
        final mergedValue = _mergeValue(key, localValue, remoteValue);
        merged[key] = mergedValue;

        if (!_areEqual(mergedValue, localValue) ||
            !_areEqual(mergedValue, remoteValue)) {
          conflicts.add(key);
        }
      }
    }

    return ConflictResolution(
      resolved: merged,
      hadConflict: conflicts.isNotEmpty,
      conflictDescription: conflicts.isNotEmpty
          ? 'Merged conflicts in: ${conflicts.join(', ')}'
          : null,
      strategyUsed: ConflictResolutionStrategy.merge,
    );
  }

  /// Merge a single value intelligently based on type
  static dynamic _mergeValue(String key, dynamic local, dynamic remote) {
    // Numbers: Use the larger value (assumes incremental changes)
    if (local is num && remote is num) {
      // For XP, gems, counts - use max
      if (key.contains('xp') ||
          key.contains('gems') ||
          key.contains('count') ||
          key.contains('total') ||
          key.contains('hearts')) {
        return local > remote ? local : remote;
      }
      // For costs, use remote (more authoritative)
      if (key.contains('cost') || key.contains('price')) {
        return remote;
      }
      // Default: use larger value
      return local > remote ? local : remote;
    }

    // Lists: Union of both (deduplicate)
    if (local is List && remote is List) {
      final merged = [...local];
      for (final item in remote) {
        if (!merged.contains(item)) {
          merged.add(item);
        }
      }
      return merged;
    }

    // Maps: Recursive merge
    if (local is Map && remote is Map) {
      return _resolveMerge(
        Map<String, dynamic>.from(local),
        Map<String, dynamic>.from(remote),
      ).resolved;
    }

    // Strings: Prefer non-empty, or local if both non-empty
    if (local is String && remote is String) {
      if (local.isEmpty) return remote;
      if (remote.isEmpty) return local;
      // Both non-empty - prefer local
      return local;
    }

    // Booleans: OR them (if either is true, result is true)
    if (local is bool && remote is bool) {
      return local || remote;
    }

    // Default: prefer local
    return local;
  }

  /// Extract timestamp from data (looks for common timestamp fields)
  static DateTime? _extractTimestamp(Map<String, dynamic> data) {
    // Try common timestamp field names
    for (final key in [
      'timestamp',
      'updatedAt',
      'updated_at',
      'modifiedAt',
      'modified_at',
    ]) {
      final value = data[key];
      if (value != null) {
        try {
          if (value is String) {
            return DateTime.parse(value);
          } else if (value is int) {
            return DateTime.fromMillisecondsSinceEpoch(value);
          }
        } catch (e) {
          // Failed to parse, try next field
          appLog('ConflictResolver: failed to parse timestamp field: $e', tag: 'ConflictResolver');
        }
      }
    }
    return null;
  }

  /// Format time difference in human-readable form
  static String _formatTimeDiff(DateTime newer, DateTime older) {
    final diff = newer.difference(older);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s newer';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m newer';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h newer';
    } else {
      return '${diff.inDays}d newer';
    }
  }

  /// Deep equality check
  static bool _areEqual(dynamic a, dynamic b) {
    if (a == b) return true;
    if (a.runtimeType != b.runtimeType) return false;

    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final key in a.keys) {
        if (!b.containsKey(key)) return false;
        if (!_areEqual(a[key], b[key])) return false;
      }
      return true;
    }

    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (!_areEqual(a[i], b[i])) return false;
      }
      return true;
    }

    return false;
  }

  /// Detect potential conflicts before they happen
  static bool hasConflictPotential(
    Map<String, dynamic> data1,
    Map<String, dynamic> data2,
  ) {
    return !_areEqual(data1, data2);
  }
}

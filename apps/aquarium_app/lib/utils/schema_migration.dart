import 'package:shared_preferences/shared_preferences.dart';
import 'logger.dart';

/// Manages SharedPreferences schema versioning and forward migrations.
///
/// Call [SchemaMigration.runIfNeeded] once at startup — before the app router
/// builds — so that any structural data changes are in place before widgets
/// read from storage.
///
/// ## Adding a new migration
/// 1. Increment [_targetVersion].
/// 2. Add an `if (currentVersion < N)` block below the existing ones.
/// 3. Write your migration logic inside it, then update the version key.
///
/// Migrations are idempotent: running them multiple times is safe.
class SchemaMigration {
  SchemaMigration._(); // no instances

  /// The schema version this build of the app targets.
  /// Bump this whenever a new migration block is added.
  static const int _targetVersion = 1;

  static const String _key = '_schemaVersion';

  /// Run any outstanding migrations against [prefs].
  ///
  /// This is a fast, synchronous-friendly operation at current scale.
  /// If a migration becomes expensive, consider moving it to an isolate.
  static Future<void> runIfNeeded(SharedPreferences prefs) async {
    final currentVersion = prefs.getInt(_key) ?? 0;

    if (currentVersion >= _targetVersion) {
      // Already up to date — fast path.
      return;
    }

    appLog(
      'Schema migration: v$currentVersion → v$_targetVersion',
      tag: 'SchemaMigration',
    );

    // ── v0 → v1 ─────────────────────────────────────────────────────────
    // Initial schema.  All data was already written in v1 format before the
    // version key was introduced, so this migration is a no-op; we simply
    // stamp the version to prevent re-running on future startups.
    if (currentVersion < 1) {
      await prefs.setInt(_key, 1);
      appLog('Migration v0 → v1 complete (stamp only)', tag: 'SchemaMigration');
    }

    // ── Future migrations ────────────────────────────────────────────────
    // if (currentVersion < 2) {
    //   // e.g. rename a key, transform stored JSON, etc.
    //   await prefs.setInt(_key, 2);
    // }
  }
}

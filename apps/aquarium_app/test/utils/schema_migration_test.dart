// Unit tests for SchemaMigration.
//
// Run: flutter test test/utils/schema_migration_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/utils/schema_migration.dart';

void main() {
  group('SchemaMigration', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('stamps version key on first run (v0 → v1)', () async {
      final prefs = await SharedPreferences.getInstance();

      // No version key initially
      expect(prefs.getInt('_schemaVersion'), isNull);

      await SchemaMigration.runIfNeeded(prefs);

      expect(prefs.getInt('_schemaVersion'), 1);
    });

    test('is idempotent — second call does not change version', () async {
      final prefs = await SharedPreferences.getInstance();

      await SchemaMigration.runIfNeeded(prefs);
      final versionAfterFirst = prefs.getInt('_schemaVersion');

      await SchemaMigration.runIfNeeded(prefs);
      final versionAfterSecond = prefs.getInt('_schemaVersion');

      expect(versionAfterSecond, versionAfterFirst);
    });

    test('skips migration when already at target version', () async {
      // Pre-set the version to the current target
      SharedPreferences.setMockInitialValues({'_schemaVersion': 1});
      final prefs = await SharedPreferences.getInstance();

      // Should not throw or change anything
      await SchemaMigration.runIfNeeded(prefs);

      expect(prefs.getInt('_schemaVersion'), 1);
    });

    test('handles prefs with no prior version key gracefully', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      expect(() async => SchemaMigration.runIfNeeded(prefs),
          returnsNormally);
    });
  });
}

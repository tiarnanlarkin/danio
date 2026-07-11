import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _contractRoot = 'docs/agent/autonomous_completion';
const _schemaRoot = '$_contractRoot/schemas';
const _fixtureRoot = 'test/scripts/fixtures/autonomous_completion';

const _schemaPaths = <String>[
  '$_schemaRoot/run_state.schema.json',
  '$_schemaRoot/synchronization_receipt.schema.json',
  '$_schemaRoot/readiness_report.schema.json',
  '$_schemaRoot/transition_validation_report.schema.json',
  '$_schemaRoot/writer_claim_plan.schema.json',
  '$_schemaRoot/runner_compatibility.schema.json',
  '$_schemaRoot/evidence_manifest.schema.json',
  '$_schemaRoot/rehearsal_report.schema.json',
  '$_schemaRoot/handoff_prompt_report.schema.json',
];

const _fixturePaths = <String>[
  '$_fixtureRoot/inactive_run_state.json',
  '$_fixtureRoot/ready_run_state.json',
  '$_fixtureRoot/active_run_state.json',
  '$_fixtureRoot/handoff_ready_run_state.json',
  '$_fixtureRoot/finalizing_run_state.json',
  '$_fixtureRoot/complete_run_state.json',
  '$_fixtureRoot/runner_compatibility_unpinned.json',
];

const _otherContractPaths = <String>[
  'docs/agent/AUTONOMOUS_PHONE_COMPLETION_RUNBOOK.md',
  '$_contractRoot/runner_compatibility.json',
];

Map<String, dynamic> _readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

Iterable<Map<String, dynamic>> _jsonObjects(Object? value) sync* {
  if (value is Map<String, dynamic>) {
    yield value;
    for (final child in value.values) {
      yield* _jsonObjects(child);
    }
  } else if (value is List<Object?>) {
    for (final child in value) {
      yield* _jsonObjects(child);
    }
  }
}

void main() {
  test('autonomous completion contract files exist and stay ascii-only', () {
    for (final path in <String>[
      ..._schemaPaths,
      ..._fixturePaths,
      ..._otherContractPaths,
    ]) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: path);
      expect(
        file.readAsBytesSync().every((byte) => byte <= 0x7f),
        isTrue,
        reason: '$path must be ASCII-only',
      );
    }
  });

  test('machine schemas are strict draft 2020-12 contracts', () {
    for (final path in _schemaPaths) {
      final schema = _readJson(path);
      expect(
        schema[r'$schema'],
        'https://json-schema.org/draft/2020-12/schema',
        reason: path,
      );
      expect(schema['additionalProperties'], isFalse, reason: path);

      for (final objectSchema in _jsonObjects(schema).where(
        (node) => node['type'] == 'object',
      )) {
        expect(
          objectSchema['additionalProperties'],
          isFalse,
          reason: '$path contains a non-strict object schema: $objectSchema',
        );
      }
    }
  });

  test('runner compatibility starts unpinned and launch-blocked', () {
    final compatibility = _readJson(
      '$_contractRoot/runner_compatibility.json',
    );
    final skills = compatibility['skills'] as List<dynamic>;

    expect(compatibility['schema_version'], 1);
    expect(compatibility['manifest_id'], 'danio-phone-autonomy-runners');
    expect(compatibility['manifest_revision'], 1);
    expect(compatibility['authorizes_launch'], isFalse);
    expect(compatibility['runner_compatible'], isFalse);
    expect(compatibility['launch_proof'], isNull);
    expect(
      compatibility['runner_order'],
      <String>['danio-autonomous-slice-runner', 'verified-slice-runner'],
    );
    expect(
      skills.every(
        (skill) => (skill as Map<String, dynamic>)['skill_sha256'] == null,
      ),
      isTrue,
    );
    expect(
      skills.every(
        (skill) => (skill as Map<String, dynamic>)['contract_sha256'] == null,
      ),
      isTrue,
    );
  });

  test('normative fixtures model bootstrap modes without live state', () {
    const expectedModes = <String>[
      'inactive',
      'ready',
      'active',
      'handoff_ready',
      'finalizing',
      'complete',
    ];

    for (var index = 0; index < expectedModes.length; index += 1) {
      final fixture = _readJson(_fixturePaths[index]);
      final budget = fixture['budget'] as Map<String, dynamic>;

      expect(
        fixture['mode'],
        expectedModes[index],
        reason: _fixturePaths[index],
      );
      expect(budget['total_approved_units'], 20);
      expect(
        (budget['consumed_units'] as int) +
            (budget['remaining_units_including_current'] as int),
        budget['total_approved_units'],
      );
    }

    final inactive = _readJson(_fixturePaths[0]);
    final inactiveBudget = inactive['budget'] as Map<String, dynamic>;
    final inactiveCharge =
        inactiveBudget['current_charge'] as Map<String, dynamic>;
    expect(inactiveBudget['consumed_units'], 1);
    expect(inactiveBudget['remaining_units_including_current'], 19);
    expect(inactiveCharge['status'], 'none');

    expect(
      File('$_contractRoot/phone_completion_run_state.json').existsSync(),
      isFalse,
      reason: 'Task 13 alone creates operational run state',
    );
  });
}

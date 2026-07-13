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

const _implementedPowerShellPaths = <String>[
  'scripts/autonomous_completion/DanioAutonomousCompletion.psm1',
  'scripts/autonomous_completion/sync_autonomous_completion.ps1',
  'scripts/autonomous_completion/check_autonomous_completion_readiness.ps1',
  'scripts/autonomous_completion/validate_autonomous_completion_transition.ps1',
  'scripts/autonomous_completion/plan_autonomous_writer_claim.ps1',
  'scripts/autonomous_completion/invoke_autonomous_writer_claim.ps1',
  'scripts/autonomous_completion/commit_autonomous_completion_transition.ps1',
  'scripts/autonomous_completion/new_autonomous_handoff_prompt.ps1',
  'test/scripts/autonomous_completion_behavior_test.ps1',
  'test/scripts/autonomous_completion_git_fixture_test.ps1',
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

bool _jsonEqual(Object? left, Object? right) {
  if (left is Map && right is Map) {
    if (left.length != right.length || !left.keys.every(right.containsKey)) {
      return false;
    }
    return left.keys.every((key) => _jsonEqual(left[key], right[key]));
  }
  if (left is List && right is List) {
    if (left.length != right.length) {
      return false;
    }
    for (var index = 0; index < left.length; index += 1) {
      if (!_jsonEqual(left[index], right[index])) {
        return false;
      }
    }
    return true;
  }
  return left == right;
}

bool _isStrictUtc(String value) {
  if (value.length != 28 || !value.endsWith('Z')) {
    return false;
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null || !parsed.isUtc) {
    return false;
  }
  int part(int start, int end) => int.parse(value.substring(start, end));
  return parsed.year == part(0, 4) &&
      parsed.month == part(5, 7) &&
      parsed.day == part(8, 10) &&
      parsed.hour == part(11, 13) &&
      parsed.minute == part(14, 16) &&
      parsed.second == part(17, 19);
}

Object? _resolveJsonPointer(Object? root, String fragment) {
  if (fragment.isEmpty || fragment == '#') {
    return root;
  }
  var current = root;
  for (final encodedToken in fragment.substring(2).split('/')) {
    final token = encodedToken.replaceAll('~1', '/').replaceAll('~0', '~');
    if (current is Map<String, dynamic>) {
      current = current[token];
    } else if (current is List<dynamic>) {
      current = current[int.parse(token)];
    } else {
      return null;
    }
  }
  return current;
}

bool _matchesJsonType(Object? value, String type) => switch (type) {
  'null' => value == null,
  'object' => value is Map<String, dynamic>,
  'array' => value is List<dynamic>,
  'string' => value is String,
  'integer' => value is int,
  'number' => value is num && value is! bool,
  'boolean' => value is bool,
  _ => false,
};

List<String> _validateSchemaInstance(
  Object? instance,
  Object? schemaNode, {
  required String schemaPath,
  Map<String, dynamic>? rootSchema,
  String instancePath = r'$',
}) {
  if (schemaNode is bool) {
    return schemaNode ? <String>[] : <String>['$instancePath rejected'];
  }
  if (schemaNode is! Map<String, dynamic>) {
    return <String>['$instancePath has invalid schema node'];
  }
  rootSchema ??= schemaNode;
  final errors = <String>[];

  final reference = schemaNode[r'$ref'] as String?;
  if (reference != null) {
    final parts = reference.split('#');
    final externalPath = parts.first;
    final fragment = parts.length == 1 ? '' : '#${parts.sublist(1).join('#')}';
    late final String referencedSchemaPath;
    late final Map<String, dynamic> referencedRoot;
    if (externalPath.isEmpty) {
      referencedSchemaPath = schemaPath;
      referencedRoot = rootSchema;
    } else {
      referencedSchemaPath = '${File(schemaPath).parent.path}/$externalPath';
      referencedRoot = _readJson(referencedSchemaPath);
    }
    final target = _resolveJsonPointer(referencedRoot, fragment);
    errors.addAll(
      _validateSchemaInstance(
        instance,
        target,
        schemaPath: referencedSchemaPath,
        rootSchema: referencedRoot,
        instancePath: instancePath,
      ),
    );
  }

  final typeContract = schemaNode['type'];
  if (typeContract != null) {
    final types = typeContract is List<dynamic>
        ? typeContract.cast<String>()
        : <String>[typeContract as String];
    if (!types.any((type) => _matchesJsonType(instance, type))) {
      errors.add('$instancePath has wrong type');
      return errors;
    }
  }

  if (schemaNode.containsKey('const') &&
      !_jsonEqual(instance, schemaNode['const'])) {
    errors.add('$instancePath violates const');
  }
  final enumValues = schemaNode['enum'] as List<dynamic>?;
  if (enumValues != null &&
      !enumValues.any((value) => _jsonEqual(instance, value))) {
    errors.add('$instancePath violates enum');
  }

  if (instance is String) {
    final minLength = schemaNode['minLength'] as int?;
    final maxLength = schemaNode['maxLength'] as int?;
    if (minLength != null && instance.length < minLength) {
      errors.add('$instancePath is too short');
    }
    if (maxLength != null && instance.length > maxLength) {
      errors.add('$instancePath is too long');
    }
    final pattern = schemaNode['pattern'] as String?;
    if (pattern != null && !RegExp(pattern).hasMatch(instance)) {
      errors.add('$instancePath violates pattern');
    }
    if (schemaNode['format'] == 'date-time' && !_isStrictUtc(instance)) {
      errors.add('$instancePath violates date-time');
    }
  }

  if (instance is num) {
    final minimum = schemaNode['minimum'] as num?;
    if (minimum != null && instance < minimum) {
      errors.add('$instancePath is below minimum');
    }
  }

  if (instance is Map<String, dynamic>) {
    final required = (schemaNode['required'] as List<dynamic>? ?? const [])
        .cast<String>();
    for (final name in required) {
      if (!instance.containsKey(name)) {
        errors.add('$instancePath misses $name');
      }
    }
    final properties =
        schemaNode['properties'] as Map<String, dynamic>? ?? const {};
    for (final entry in properties.entries) {
      if (instance.containsKey(entry.key)) {
        errors.addAll(
          _validateSchemaInstance(
            instance[entry.key],
            entry.value,
            schemaPath: schemaPath,
            rootSchema: rootSchema,
            instancePath: '$instancePath.${entry.key}',
          ),
        );
      }
    }
    if (schemaNode['additionalProperties'] == false) {
      for (final name in instance.keys.where(
        (name) => !properties.containsKey(name),
      )) {
        errors.add('$instancePath has unknown $name');
      }
    }
  }

  if (instance is List<dynamic>) {
    final minItems = schemaNode['minItems'] as int?;
    final maxItems = schemaNode['maxItems'] as int?;
    if (minItems != null && instance.length < minItems) {
      errors.add('$instancePath has too few items');
    }
    if (maxItems != null && instance.length > maxItems) {
      errors.add('$instancePath has too many items');
    }
    if (schemaNode['uniqueItems'] == true) {
      final seen = <String>{};
      for (final value in instance) {
        if (!seen.add(jsonEncode(value))) {
          errors.add('$instancePath has duplicate items');
        }
      }
    }
    final prefixItems = schemaNode['prefixItems'] as List<dynamic>? ?? const [];
    for (
      var index = 0;
      index < instance.length && index < prefixItems.length;
      index += 1
    ) {
      errors.addAll(
        _validateSchemaInstance(
          instance[index],
          prefixItems[index],
          schemaPath: schemaPath,
          rootSchema: rootSchema,
          instancePath: '$instancePath[$index]',
        ),
      );
    }
    final items = schemaNode['items'];
    if (items == false && instance.length > prefixItems.length) {
      errors.add('$instancePath has forbidden extra items');
    } else if (items != null && items != false) {
      final start = prefixItems.isEmpty ? 0 : prefixItems.length;
      for (var index = start; index < instance.length; index += 1) {
        errors.addAll(
          _validateSchemaInstance(
            instance[index],
            items,
            schemaPath: schemaPath,
            rootSchema: rootSchema,
            instancePath: '$instancePath[$index]',
          ),
        );
      }
    }
    final contains = schemaNode['contains'];
    if (contains != null) {
      final matchCount = instance
          .where(
            (value) => _validateSchemaInstance(
              value,
              contains,
              schemaPath: schemaPath,
              rootSchema: rootSchema,
            ).isEmpty,
          )
          .length;
      if (matchCount < (schemaNode['minContains'] as int? ?? 1)) {
        errors.add('$instancePath violates contains');
      }
    }
  }

  final oneOf = schemaNode['oneOf'] as List<dynamic>?;
  if (oneOf != null) {
    final matches = oneOf
        .where(
          (alternative) => _validateSchemaInstance(
            instance,
            alternative,
            schemaPath: schemaPath,
            rootSchema: rootSchema,
          ).isEmpty,
        )
        .length;
    if (matches != 1) {
      errors.add('$instancePath violates oneOf');
    }
  }
  for (final contract in schemaNode['allOf'] as List<dynamic>? ?? const []) {
    errors.addAll(
      _validateSchemaInstance(
        instance,
        contract,
        schemaPath: schemaPath,
        rootSchema: rootSchema,
        instancePath: instancePath,
      ),
    );
  }
  final ifContract = schemaNode['if'];
  if (ifContract != null) {
    final conditionMatches = _validateSchemaInstance(
      instance,
      ifContract,
      schemaPath: schemaPath,
      rootSchema: rootSchema,
    ).isEmpty;
    final branch = conditionMatches ? schemaNode['then'] : schemaNode['else'];
    if (branch != null) {
      errors.addAll(
        _validateSchemaInstance(
          instance,
          branch,
          schemaPath: schemaPath,
          rootSchema: rootSchema,
          instancePath: instancePath,
        ),
      );
    }
  }
  final notContract = schemaNode['not'];
  if (notContract != null &&
      _validateSchemaInstance(
        instance,
        notContract,
        schemaPath: schemaPath,
        rootSchema: rootSchema,
      ).isEmpty) {
    errors.add('$instancePath violates not');
  }
  return errors;
}

Map<String, String> _parseCodexAgentRegistry(String source) {
  final rootFields = <String, Object?>{};
  final sections = <String, Map<String, Object?>>{};
  final seenSections = <String>{};
  String? currentSection;

  for (final rawLine in const LineSplitter().convert(source)) {
    final line = rawLine.trim();
    if (line.isEmpty || line.startsWith('#')) {
      continue;
    }

    final header = RegExp(
      r'^\[agents(?:\.([a-z][a-z0-9_]*))?\]$',
    ).firstMatch(line);
    if (header != null) {
      final section = header.group(1) ?? '';
      currentSection = section;
      if (!seenSections.add(section)) {
        throw const FormatException('duplicate Codex agent section');
      }
      if (section.isNotEmpty) {
        sections[section] = {};
      }
      continue;
    }

    if (currentSection == null) {
      throw FormatException('value outside Codex agent section: $line');
    }
    final assignment = RegExp(r'^([a-z_]+)\s*=\s*(.+)$').firstMatch(line);
    if (assignment == null) {
      throw FormatException('unsupported Codex TOML syntax: $line');
    }
    final key = assignment.group(1)!;
    final rawValue = assignment.group(2)!;
    final target = currentSection.isEmpty
        ? rootFields
        : sections[currentSection]!;
    if (target.containsKey(key)) {
      throw FormatException('duplicate Codex TOML key: $key');
    }
    if (currentSection.isEmpty) {
      if (!const {'max_threads', 'max_depth'}.contains(key)) {
        throw FormatException('unknown Codex root key: $key');
      }
      target[key] = int.parse(rawValue);
      continue;
    }
    if (!const {
      'description',
      'config_file',
      'nickname_candidates',
    }.contains(key)) {
      throw FormatException('unknown Codex agent key: $key');
    }
    target[key] = jsonDecode(rawValue);
  }

  if (rootFields.keys.toSet().difference(const {
        'max_threads',
        'max_depth',
      }).isNotEmpty ||
      rootFields.length != 2 ||
      rootFields['max_threads'] != 6 ||
      rootFields['max_depth'] != 1) {
    throw const FormatException('Codex root fields are incomplete');
  }

  final registry = <String, String>{};
  for (final entry in sections.entries) {
    final fields = entry.value;
    if (fields.keys.toSet().difference(const {
          'description',
          'config_file',
          'nickname_candidates',
        }).isNotEmpty ||
        fields.length != 3 ||
        fields['description'] is! String ||
        fields['nickname_candidates'] is! List<dynamic> ||
        !(fields['nickname_candidates'] as List<dynamic>).every(
          (value) => value is String,
        )) {
      throw FormatException('invalid Codex agent section: ${entry.key}');
    }
    final configFile = fields['config_file'];
    if (configFile is! String || configFile != 'agents/${entry.key}.toml') {
      throw FormatException('invalid Codex config_file for ${entry.key}');
    }
    registry[entry.key] = configFile;
  }
  return registry;
}

Map<String, Object?> _parseCodexAgentHeader(String source) {
  const instructionsMarker = 'developer_instructions = """';
  final markerIndex = source.indexOf(instructionsMarker);
  final closingIndex = source.lastIndexOf('"""');
  if (markerIndex < 0 ||
      closingIndex <= markerIndex + instructionsMarker.length ||
      source.indexOf('"""', markerIndex + instructionsMarker.length) !=
          closingIndex ||
      source.substring(closingIndex + 3).trim().isNotEmpty) {
    throw const FormatException('invalid Codex agent instruction block');
  }

  final fields = <String, Object?>{};
  final header = source.substring(0, markerIndex);
  for (final rawLine in const LineSplitter().convert(header)) {
    final line = rawLine.trim();
    if (line.isEmpty || line.startsWith('#')) {
      continue;
    }
    final assignment = RegExp(r'^([a-z_]+)\s*=\s*(.+)$').firstMatch(line);
    if (assignment == null) {
      throw FormatException('unsupported Codex agent TOML syntax: $line');
    }
    final key = assignment.group(1)!;
    if (fields.containsKey(key)) {
      throw FormatException('duplicate Codex agent key: $key');
    }
    fields[key] = jsonDecode(assignment.group(2)!);
  }

  const required = {
    'name',
    'description',
    'model',
    'model_reasoning_effort',
    'service_tier',
    'sandbox_mode',
    'nickname_candidates',
  };
  if (fields.keys.toSet().difference(required).isNotEmpty ||
      fields.length != required.length) {
    throw const FormatException('Codex agent header fields are invalid');
  }
  return fields;
}

void main() {
  test('autonomous completion contract files exist and stay ascii-only', () {
    for (final path in <String>[
      ..._schemaPaths,
      ..._fixturePaths,
      ..._otherContractPaths,
      ..._implementedPowerShellPaths,
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

  test('representative instances execute through the schema contracts', () {
    List<String> validate(String schemaPath, Object? instance) {
      final schema = _readJson(schemaPath);
      return _validateSchemaInstance(
        instance,
        schema,
        schemaPath: schemaPath,
        rootSchema: schema,
      );
    }

    Map<String, dynamic> copy(Map<String, dynamic> value) =>
        jsonDecode(jsonEncode(value)) as Map<String, dynamic>;

    final runSchema = '$_schemaRoot/run_state.schema.json';
    for (final path in _fixturePaths.take(6)) {
      final errors = validate(runSchema, _readJson(path));
      expect(errors, isEmpty, reason: '$path: ${errors.join('; ')}');
    }

    final ready = _readJson(_fixturePaths[1]);
    final badDate = copy(ready);
    (badDate['authorization'] as Map<String, dynamic>)['authorized_at_utc'] =
        '2026-02-31T12:00:00.0000000Z';
    expect(validate(runSchema, badDate), isNotEmpty);
    final missingCheckpoint = copy(_readJson(_fixturePaths[3]));
    missingCheckpoint['last_verified_checkpoint'] = null;
    expect(validate(runSchema, missingCheckpoint), isNotEmpty);

    final compatibilityPath = '$_schemaRoot/runner_compatibility.schema.json';
    final compatibility = _readJson('$_contractRoot/runner_compatibility.json');
    expect(validate(compatibilityPath, compatibility), isEmpty);
    final compatibleWithoutPins = copy(compatibility);
    compatibleWithoutPins['runner_compatible'] = true;
    for (final skill in compatibleWithoutPins['skills'] as List<dynamic>) {
      final typedSkill = skill as Map<String, dynamic>;
      typedSkill['skill_sha256'] = null;
      typedSkill['contract_sha256'] = null;
    }
    expect(validate(compatibilityPath, compatibleWithoutPins), isNotEmpty);
    final compatibleWithPins = copy(compatibleWithoutPins);
    for (final skill in compatibleWithPins['skills'] as List<dynamic>) {
      final typedSkill = skill as Map<String, dynamic>;
      typedSkill['skill_sha256'] = '0' * 64;
      typedSkill['contract_sha256'] = '1' * 64;
    }
    expect(validate(compatibilityPath, compatibleWithPins), isEmpty);

    final active = _readJson(_fixturePaths[2]);
    final owner = active['owner'] as Map<String, dynamic>;
    final cursor = active['cursor'] as Map<String, dynamic>;
    final rejectedClaim = <String, dynamic>{
      'document_type': 'danio_writer_claim_plan',
      'schema_version': 1,
      'planned_at_utc': '2026-07-11T12:00:00.0000000Z',
      'valid': false,
      'code': 'CLAIM_REJECTED',
      'details': <String>['unsafe input'],
      'mutations_performed': false,
      'run_id': null,
      'work_unit_id': null,
      'task_id': null,
      'expected_state_revision': null,
      'owner_token_sha256': null,
      'branch_name': null,
      'worktree_id': null,
      'worktree_path': null,
      'base_commit': null,
      'state_path':
          'apps/aquarium_app/docs/agent/autonomous_completion/'
          'phone_completion_run_state.json',
      'next_run_state': null,
    };
    final claimSchema = '$_schemaRoot/writer_claim_plan.schema.json';
    expect(validate(claimSchema, rejectedClaim), isEmpty);
    final validClaim = copy(rejectedClaim)
      ..addAll(<String, dynamic>{
        'valid': true,
        'code': 'CLAIM_PLAN_VALID',
        'details': <String>[],
        'run_id': active['run_id'],
        'work_unit_id': cursor['work_unit_id'],
        'task_id': owner['task_id'],
        'expected_state_revision': owner['claim_revision'],
        'owner_token_sha256': owner['token_sha256'],
        'branch_name': owner['branch_name'],
        'worktree_id': owner['worktree_id'],
        'worktree_path': owner['worktree_path'],
        'base_commit': owner['claim_parent_commit'],
        'next_run_state': active,
      });
    expect(validate(claimSchema, validClaim), isEmpty);
    final contradictoryRejection = copy(rejectedClaim)
      ..['run_id'] = active['run_id'];
    expect(validate(claimSchema, contradictoryRejection), isNotEmpty);
  });

  test('report outcome branches reject contradictory results', () {
    List<String> validate(String name, Object? instance) {
      final path = '$_schemaRoot/$name';
      final schema = _readJson(path);
      return _validateSchemaInstance(
        instance,
        schema,
        schemaPath: path,
        rootSchema: schema,
      );
    }

    Map<String, dynamic> copy(Map<String, dynamic> value) =>
        jsonDecode(jsonEncode(value)) as Map<String, dynamic>;

    final passCheck = <String, dynamic>{
      'code': 'AUTHORITY_VALID',
      'status': 'pass',
      'detail': 'Authority is current.',
    };
    final readiness = <String, dynamic>{
      'document_type': 'danio_readiness_report',
      'schema_version': 1,
      'intent': 'Claim',
      'checked_at_utc': '2026-07-11T12:00:00.0000000Z',
      'eligible': true,
      'stop_reason_code': null,
      'checks': <Map<String, dynamic>>[passCheck],
    };
    expect(validate('readiness_report.schema.json', readiness), isEmpty);
    final eligibleWithFailure = copy(readiness);
    ((eligibleWithFailure['checks'] as List<dynamic>).first
            as Map<String, dynamic>)['status'] =
        'fail';
    expect(
      validate('readiness_report.schema.json', eligibleWithFailure),
      isNotEmpty,
    );
    final ineligibleWithoutFailure = copy(readiness)
      ..['eligible'] = false
      ..['stop_reason_code'] = 'AUTHORITY_CONFLICT';
    expect(
      validate('readiness_report.schema.json', ineligibleWithoutFailure),
      isNotEmpty,
    );

    final handoff = <String, dynamic>{
      'document_type': 'danio_handoff_prompt_report',
      'schema_version': 1,
      'prompt_kind': 'Launch',
      'generated_at_utc': '2026-07-11T12:00:00.0000000Z',
      'accepted': true,
      'code': 'HANDOFF_PROMPT_GENERATED',
      'observed_state_mode': 'ready',
      'state_mode': 'ready',
      'title': 'Launch [fixture-run/launch/0]',
      'marker': 'fixture-run/launch/0',
      'prompt': 'Continue fixture-run/launch/0',
      'runner_compatible': true,
      'explicit_launch_task_capable': true,
      'automatic_successor_capable': false,
      'mutations_performed': false,
      'checks': <Map<String, dynamic>>[passCheck],
    };
    expect(validate('handoff_prompt_report.schema.json', handoff), isEmpty);
    final launchWithSuccessorCapability = copy(handoff)
      ..['automatic_successor_capable'] = true;
    expect(
      validate(
        'handoff_prompt_report.schema.json',
        launchWithSuccessorCapability,
      ),
      isNotEmpty,
    );
    final successor = copy(handoff)
      ..['prompt_kind'] = 'Successor'
      ..['observed_state_mode'] = 'handoff_ready'
      ..['state_mode'] = 'handoff_ready'
      ..['title'] = 'Successor [fixture-run/1]'
      ..['marker'] = 'fixture-run/1'
      ..['prompt'] = 'Continue fixture-run/1'
      ..['explicit_launch_task_capable'] = false
      ..['automatic_successor_capable'] = true;
    expect(validate('handoff_prompt_report.schema.json', successor), isEmpty);
    final successorWithLaunchCapability = copy(successor)
      ..['explicit_launch_task_capable'] = true;
    expect(
      validate(
        'handoff_prompt_report.schema.json',
        successorWithLaunchCapability,
      ),
      isNotEmpty,
    );
    final incompatibleWithCapability = copy(successor)
      ..['runner_compatible'] = false;
    expect(
      validate(
        'handoff_prompt_report.schema.json',
        incompatibleWithCapability,
      ),
      isNotEmpty,
    );

    final transition = <String, dynamic>{
      'document_type': 'danio_transition_validation_report',
      'schema_version': 1,
      'source': 'Staged',
      'validated_at_utc': '2026-07-11T12:00:00.0000000Z',
      'valid': true,
      'code': 'TRANSITION_VALID',
      'details': <String>[],
      'expected_parent_commit': null,
      'observed_parent_commit': null,
      'staged_tree_hash': null,
      'mutations_performed': false,
      'checks': <Map<String, dynamic>>[passCheck],
    };
    expect(
      validate('transition_validation_report.schema.json', transition),
      isEmpty,
    );
    final validWithFailure = copy(transition);
    ((validWithFailure['checks'] as List<dynamic>).first
            as Map<String, dynamic>)['status'] =
        'fail';
    expect(
      validate('transition_validation_report.schema.json', validWithFailure),
      isNotEmpty,
    );

    final evidence = <String, dynamic>{
      'schema_version': 1,
      'product_commit': '0' * 40,
      'work_unit_id': 'DCL-RC-001-final-candidate',
      'ledger_row_ids': <String>['DCL-RC-001'],
      'commands': <Map<String, dynamic>>[
        <String, dynamic>{
          'command': 'local gate',
          'exit_code': 0,
          'started_at_utc': '2026-07-11T12:00:00.0000000Z',
          'completed_at_utc': '2026-07-11T12:01:00.0000000Z',
        },
      ],
      'environment': <String, dynamic>{
        'platform': 'windows',
        'device_id': null,
      },
      'artifacts': <Map<String, dynamic>>[],
      'checks': <Map<String, dynamic>>[
        <String, dynamic>{
          'code': 'FULL',
          'status': 'pass',
          'command_indexes': <int>[0],
          'artifact_indexes': <int>[],
        },
      ],
      'overall_status': 'pass',
    };
    expect(validate('evidence_manifest.schema.json', evidence), isEmpty);
    final passingManifestWithFailedCommand = copy(evidence);
    ((passingManifestWithFailedCommand['commands'] as List<dynamic>).first
            as Map<String, dynamic>)['exit_code'] =
        1;
    expect(
      validate(
        'evidence_manifest.schema.json',
        passingManifestWithFailedCommand,
      ),
      isNotEmpty,
    );
    final evidenceWithoutChecks = copy(evidence)..remove('checks');
    expect(
      validate('evidence_manifest.schema.json', evidenceWithoutChecks),
      isNotEmpty,
    );
    final evidenceWithUnknownCheckField = copy(evidence);
    ((evidenceWithUnknownCheckField['checks'] as List<dynamic>).first
            as Map<String, dynamic>)['caller_claimed_pass'] =
        true;
    expect(
      validate(
        'evidence_manifest.schema.json',
        evidenceWithUnknownCheckField,
      ),
      isNotEmpty,
    );
  });

  test('machine schemas reject unsafe absolute Windows paths', () {
    for (final path in <String>[
      '$_schemaRoot/run_state.schema.json',
      '$_schemaRoot/synchronization_receipt.schema.json',
      '$_schemaRoot/writer_claim_plan.schema.json',
      '$_schemaRoot/rehearsal_report.schema.json',
    ]) {
      final schema = _readJson(path);
      final definitions = schema[r'$defs'] as Map<String, dynamic>;
      final absolutePath =
          definitions['absolute_windows_path'] as Map<String, dynamic>;
      final pattern = RegExp(absolutePath['pattern'] as String);

      expect(pattern.hasMatch('C:/safe/repository'), isTrue, reason: path);
      expect(pattern.hasMatch('D:/safe/repository'), isTrue, reason: path);
      expect(pattern.hasMatch(r'C:\unsafe\repository'), isFalse, reason: path);
      expect(pattern.hasMatch('C:/../escape'), isFalse, reason: path);
      expect(pattern.hasMatch('C:/safe/../escape'), isFalse, reason: path);
    }
  });

  test('writer claim plan represents fail-closed rejection output', () {
    final schema = _readJson('$_schemaRoot/writer_claim_plan.schema.json');
    final properties = schema['properties'] as Map<String, dynamic>;

    for (final field in <String>[
      'run_id',
      'work_unit_id',
      'task_id',
      'expected_state_revision',
      'owner_token_sha256',
      'branch_name',
      'worktree_id',
      'worktree_path',
      'base_commit',
      'next_run_state',
    ]) {
      var fieldSchema = properties[field] as Map<String, dynamic>;
      final reference = fieldSchema[r'$ref'] as String?;
      if (reference != null && reference.startsWith(r'#/$defs/')) {
        final definitionName = reference.substring(r'#/$defs/'.length);
        fieldSchema =
            (schema[r'$defs'] as Map<String, dynamic>)[definitionName]
                as Map<String, dynamic>;
      }
      final alternatives = fieldSchema['oneOf'] as List<dynamic>;
      expect(
        alternatives.any(
          (alternative) =>
              (alternative as Map<String, dynamic>)['type'] == 'null',
        ),
        isTrue,
        reason: '$field must be explicit null in a rejected claim plan',
      );
    }

    final conditionals = jsonEncode(schema['allOf']);
    expect(conditionals, contains(r'"valid":{"const":true}'));
    expect(conditionals, contains('"else"'));
  });

  test('durable closeout fixtures carry typed verification checkpoints', () {
    final productCommits = <String>[];
    for (final path in <String>[
      '$_fixtureRoot/handoff_ready_run_state.json',
      '$_fixtureRoot/finalizing_run_state.json',
      '$_fixtureRoot/complete_run_state.json',
    ]) {
      final fixture = _readJson(path);
      final checkpoint =
          fixture['last_verified_checkpoint'] as Map<String, dynamic>;
      final productCommit = checkpoint['product_commit'] as String;
      productCommits.add(productCommit);
      expect(productCommit, matches(RegExp(r'^[0-9a-f]{40}$')), reason: path);
      expect(
        checkpoint['evidence_manifest_path'],
        'apps/aquarium_app/docs/agent/autonomous_completion/evidence/'
        '$productCommit.json',
        reason: path,
      );
      final transition = fixture['transition'] as Map<String, dynamic>;
      final verifiedAt = DateTime.parse(
        checkpoint['verified_at_utc'] as String,
      );
      final transitionedAt = DateTime.parse(
        transition['occurred_at_utc'] as String,
      );
      expect(verifiedAt.isAfter(transitionedAt), isFalse, reason: path);
    }
    expect(productCommits[1], isNot(productCommits[2]));

    final runStateSchema = _readJson('$_schemaRoot/run_state.schema.json');
    final conditionals = jsonEncode(runStateSchema['allOf']);
    expect(
      conditionals,
      contains('"handoff_ready","paused","finalizing","complete"'),
    );
    expect(conditionals, contains('"last_verified_checkpoint"'));
  });

  test('runbook uses nested-repository-relative machine paths', () {
    final runbook = File(
      'docs/agent/AUTONOMOUS_PHONE_COMPLETION_RUNBOOK.md',
    ).readAsStringSync();

    for (final path in <String>[
      'apps/aquarium_app/docs/agent/autonomous_completion/phone_completion_run_state.json',
      'apps/aquarium_app/docs/agent/autonomous_completion/schemas/',
      'apps/aquarium_app/docs/agent/autonomous_completion/runner_compatibility.json',
      'apps/aquarium_app/test/scripts/fixtures/autonomous_completion/',
    ]) {
      expect(runbook, contains(path), reason: path);
    }
  });

  test('schema references resolve and strict UTC definitions are semantic', () {
    for (final path in _schemaPaths) {
      final schema = _readJson(path);
      for (final node in _jsonObjects(schema)) {
        final reference = node[r'$ref'];
        if (reference is! String || reference.startsWith('#')) {
          continue;
        }
        final relativePath = reference.split('#').first;
        final target = File('${File(path).parent.path}/$relativePath');
        expect(target.existsSync(), isTrue, reason: '$path -> $reference');
      }

      final definitions = schema[r'$defs'] as Map<String, dynamic>?;
      final strictUtc = definitions?['strict_utc'] as Map<String, dynamic>?;
      if (strictUtc != null) {
        expect(strictUtc['format'], 'date-time', reason: path);
        expect(strictUtc['minLength'], 28, reason: path);
        expect(strictUtc['maxLength'], 28, reason: path);
        final pattern = RegExp(strictUtc['pattern'] as String);
        bool accepts(String value) =>
            value.length == 28 && pattern.hasMatch(value);
        expect(accepts('2026-07-11T12:00:00.0000000Z'), isTrue, reason: path);
        expect(accepts('2024-02-29T12:00:00.0000000Z'), isTrue, reason: path);
        for (final invalid in <String>[
          '2026-99-11T12:00:00.0000000Z',
          '2026-07-32T12:00:00.0000000Z',
          '2026-02-29T12:00:00.0000000Z',
          '2026-02-31T12:00:00.0000000Z',
          '2026-04-31T12:00:00.0000000Z',
          '1900-02-29T12:00:00.0000000Z',
          '2026-07-11T24:00:00.0000000Z',
          '2026-07-11T12:60:00.0000000Z',
          '2026-07-11T12:00:00.0000000Z\n',
        ]) {
          expect(accepts(invalid), isFalse, reason: '$path accepted $invalid');
        }
      }
    }
  });

  test('future-facing discriminators stay fail-closed', () {
    final runState = _readJson('$_schemaRoot/run_state.schema.json');
    final controlSurface =
        (runState[r'$defs'] as Map<String, dynamic>)['control_surface_sync']
            as Map<String, dynamic>;
    final controlConditionals = jsonEncode(controlSurface['allOf']);
    for (final status in <String>[
      'not_required',
      'pending',
      'synced',
      'failed',
    ]) {
      expect(
        controlConditionals,
        contains('"status":{"const":"$status"}'),
        reason: status,
      );
    }

    final handoff = _readJson('$_schemaRoot/handoff_prompt_report.schema.json');
    final handoffRequired = (handoff['required'] as List<dynamic>)
        .cast<String>()
        .toSet();
    expect(
      handoffRequired,
      containsAll(<String>{
        'accepted',
        'code',
        'observed_state_mode',
        'mutations_performed',
      }),
    );
    final handoffConditionals = jsonEncode(handoff['allOf']);
    expect(handoffConditionals, contains('"accepted":{"const":true}'));
    expect(handoffConditionals, contains('"accepted":{"const":false}'));
    expect(handoffConditionals, contains('"prompt_kind":{"const":"Launch"}'));
    expect(handoffConditionals, contains('"state_mode":{"const":"ready"}'));
    expect(
      handoffConditionals,
      contains('"prompt_kind":{"const":"Successor"}'),
    );
    expect(
      handoffConditionals,
      contains('"state_mode":{"const":"handoff_ready"}'),
    );
    final handoffDefinitions = handoff[r'$defs'] as Map<String, dynamic>;
    final taskCapabilities =
        handoffDefinitions['task_capabilities'] as Map<String, dynamic>;
    expect(taskCapabilities['additionalProperties'], isFalse);
    expect(
      (taskCapabilities['required'] as List<dynamic>).cast<String>().toSet(),
      <String>{
        'list_threads',
        'read_thread',
        'create_thread.project_target',
      },
    );
    final savedProject =
        handoffDefinitions['saved_project'] as Map<String, dynamic>;
    expect(savedProject['additionalProperties'], isFalse);
    expect(
      (savedProject['required'] as List<dynamic>).cast<String>().toSet(),
      <String>{'project_id', 'root'},
    );
  });

  test('handoff generator is deterministic and task-tool-agnostic', () {
    const generatorPath =
        'scripts/autonomous_completion/new_autonomous_handoff_prompt.ps1';
    final source = File(generatorPath).readAsStringSync();
    for (final parameter in <String>[
      'PromptKind',
      'RunStateJson',
      'ReadinessReportJson',
      'TaskCapabilitiesJson',
      'SavedProjectJson',
      'RepositoryRoot',
    ]) {
      expect(source, contains(RegExp('\\b$parameter\\b')), reason: parameter);
    }
    for (final field in <String>[
      'runner_compatible',
      'explicit_launch_task_capable',
      'automatic_successor_capable',
      'mutations_performed',
    ]) {
      expect(source, contains(RegExp('\\b$field\\s*=')), reason: field);
    }
    expect(source, contains('/launch/0'));
    expect(source, contains('handoff_generation'));
    expect(source, isNot(contains('codex_app__')));
    expect(source, isNot(contains('fork_thread')));
    expect(source, isNot(contains('send_message_to_thread')));
    expect(source, isNot(contains('Invoke-RestMethod')));

    final runbook = File(
      'docs/agent/AUTONOMOUS_PHONE_COMPLETION_RUNBOOK.md',
    ).readAsStringSync();
    for (final rule in <String>[
      'Exhaust `list_threads` pagination',
      '`read_thread` every exact candidate',
      'Reuse one queued or running match without messaging it',
      'Create once only when zero exact matches remain',
      'Verify a returned task with `read_thread`',
      '`send_message_to_thread` is recovery-only',
      'Do not use `fork_thread` for successors',
    ]) {
      expect(runbook, contains(rule), reason: rule);
    }
  });

  test('autonomous proof tiers keep Git fixtures disposable', () {
    final gate = File(
      'scripts/quality_gates/run_local_quality_gate.ps1',
    ).readAsStringSync();
    final fixture = File(
      'test/scripts/autonomous_completion_git_fixture_test.ps1',
    ).readAsStringSync();
    final quality = File('docs/agent/QUALITY_LADDER.md').readAsStringSync();
    final checklist = File(
      'docs/agent/TESTING_CHECKLIST.md',
    ).readAsStringSync();
    final checklistFlat = checklist.replaceAll(RegExp(r'\s+'), ' ');

    expect(gate, contains('Invoke-AutonomousCompletionTests'));
    expect(
      gate,
      contains('test/scripts/autonomous_completion_script_test.dart'),
    );
    expect(gate, isNot(contains('autonomous_completion_git_fixture_test.ps1')));
    expect(fixture, contains("[Guid]::NewGuid().ToString('N')"));
    expect(fixture, contains('[System.IO.Path]::GetTempPath()'));
    expect(fixture, contains('finally'));
    expect(
      fixture,
      contains(
        r'$resolvedFixtureRoot.StartsWith($tempBase, '
        '[StringComparison]::OrdinalIgnoreCase)',
      ),
    );
    expect(
      fixture,
      contains(
        'Remove-Item -LiteralPath \$extendedFixtureRoot -Recurse -Force',
      ),
    );

    for (final tier in <String>[
      'Autonomy authority/schema change',
      'Autonomy pure state/readiness change',
      'Autonomy Git mutation/claim/closeout change',
      'Autonomy no-product rehearsal',
      'Phone release candidate',
    ]) {
      expect(quality, contains(tier), reason: tier);
      expect(checklist, contains(tier), reason: tier);
    }

    final qualityMappings = <String, List<String>>{
      'Autonomy authority/schema change': <String>[
        'Docs truth',
        'autonomous script contract',
        '-Profile Docs',
      ],
      'Autonomy pure state/readiness change': <String>[
        'PowerShell behavior suite',
        'disposable Git fixture suite',
        '-Profile Docs',
      ],
      'Autonomy Git mutation/claim/closeout change': <String>[
        'Race and disposable Git fixtures',
        '-Profile Docs',
        '-RequireCleanWorktree',
      ],
      'Autonomy no-product rehearsal': <String>[
        'All autonomous Dart, behavior, and disposable Git fixture suites',
        '-Profile Docs -RequireCleanWorktree',
      ],
      'Phone release candidate': <String>[
        '-Profile Full',
        '-Profile AndroidPrep',
        'evidence manifest',
        'phone QA',
      ],
    };
    for (final entry in qualityMappings.entries) {
      final row = quality
          .split(RegExp(r'\r?\n'))
          .singleWhere((line) => line.startsWith('| ${entry.key} |'));
      for (final requirement in entry.value) {
        expect(
          row,
          contains(requirement),
          reason: '${entry.key}: $requirement',
        );
      }
    }

    for (final mapping in <String>[
      <String>[
        'Autonomy authority/schema change:** run docs truth, the autonomous ',
        'script contract, and the Docs profile.',
      ].join(),
      <String>[
        'Autonomy pure state/readiness change:** run the behavior suite, the ',
        'disposable Git fixture suite, and the Docs profile.',
      ].join(),
      <String>[
        'Autonomy Git mutation/claim/closeout change:** run race/disposable Git ',
        'fixtures, the Docs profile, and the clean-main Docs profile.',
      ].join(),
      <String>[
        'Autonomy no-product rehearsal:** run all autonomous suites and the Docs ',
        'profile with `-RequireCleanWorktree`',
      ].join(),
      <String>[
        'Phone release candidate:** run Full, AndroidPrep, validate the evidence ',
        'manifest, and complete affected phone QA.',
      ].join(),
    ]) {
      expect(checklistFlat, contains(mapping), reason: mapping);
    }
  });

  test('runner manifest pins exact ordered semantic identities', () {
    final schema = _readJson('$_schemaRoot/runner_compatibility.schema.json');
    final properties = schema['properties'] as Map<String, dynamic>;
    final skills = properties['skills'] as Map<String, dynamic>;
    final skillItems = skills['prefixItems'] as List<dynamic>;
    expect(skillItems, hasLength(2));

    final expectedSkills = <Map<String, String>>[
      <String, String>{
        'name': 'danio-autonomous-slice-runner',
        'role': 'orchestrator',
        'skill_path': 'skills/danio-autonomous-slice-runner/SKILL.md',
        'contract_path':
            'skills/danio-autonomous-slice-runner/references/'
            'compatibility-contract.json',
        'contract_version': '1.0.0',
      },
      <String, String>{
        'name': 'verified-slice-runner',
        'role': 'base',
        'skill_path': 'skills/verified-slice-runner/SKILL.md',
        'contract_path':
            'skills/verified-slice-runner/references/'
            'compatibility-contract.json',
        'contract_version': '1.0.0',
      },
    ];

    for (var index = 0; index < expectedSkills.length; index += 1) {
      final item = skillItems[index] as Map<String, dynamic>;
      final itemProperties = item['properties'] as Map<String, dynamic>;
      for (final entry in expectedSkills[index].entries) {
        expect(
          (itemProperties[entry.key] as Map<String, dynamic>)['const'],
          entry.value,
          reason: '${entry.key}[$index]',
        );
      }
    }

    final compatibility = _readJson('$_contractRoot/runner_compatibility.json');
    expect(compatibility['skills'], hasLength(2));
    for (var index = 0; index < expectedSkills.length; index += 1) {
      final skill =
          (compatibility['skills'] as List<dynamic>)[index]
              as Map<String, dynamic>;
      for (final entry in expectedSkills[index].entries) {
        expect(skill[entry.key], entry.value, reason: '${entry.key}[$index]');
      }
    }

    expect(
      (compatibility['thread_capabilities']
          as Map<String, dynamic>)['required'],
      <String>['list_threads', 'read_thread', 'create_thread.project_target'],
    );
    expect(
      (compatibility['thread_capabilities']
          as Map<String, dynamic>)['recovery_only'],
      <String>['send_message_to_thread'],
    );
    expect(
      (compatibility['thread_capabilities']
          as Map<String, dynamic>)['not_for_successors'],
      <String>['fork_thread'],
    );
  });

  test('runner compatibility pins reviewed contracts but blocks launch', () {
    final compatibility = _readJson(
      '$_contractRoot/runner_compatibility.json',
    );
    final skills = compatibility['skills'] as List<dynamic>;

    expect(compatibility['schema_version'], 1);
    expect(compatibility['manifest_id'], 'danio-phone-autonomy-runners');
    expect(compatibility['manifest_revision'], 2);
    expect(compatibility['authorizes_launch'], isFalse);
    expect(compatibility['runner_compatible'], isTrue);
    expect(compatibility['launch_proof'], isNull);
    expect(
      compatibility['runner_order'],
      <String>['danio-autonomous-slice-runner', 'verified-slice-runner'],
    );
    expect(
      skills.every((skill) {
        final hash = (skill as Map<String, dynamic>)['skill_sha256'];
        return hash is String && RegExp(r'^[0-9a-f]{64}$').hasMatch(hash);
      }),
      isTrue,
    );
    expect(
      skills.every((skill) {
        final hash = (skill as Map<String, dynamic>)['contract_sha256'];
        return hash is String && RegExp(r'^[0-9a-f]{64}$').hasMatch(hash);
      }),
      isTrue,
    );
  });

  test('coordinator-only agent overlay is fail-closed', () {
    final config = File('../../.codex/config.toml').readAsStringSync();
    const expectedRegistry = <String, String>{
      'danio_product_auditor': 'agents/danio_product_auditor.toml',
      'danio_ui_auditor': 'agents/danio_ui_auditor.toml',
      'danio_quality_auditor': 'agents/danio_quality_auditor.toml',
      'danio_reviewer': 'agents/danio_reviewer.toml',
      'danio_android_qa_owner': 'agents/danio_android_qa_owner.toml',
    };
    final registry = _parseCodexAgentRegistry(config);
    expect(registry, expectedRegistry);
    expect(
      File('../../.codex/agents/danio_worker.toml').existsSync(),
      isTrue,
      reason: 'worker definition is retained but de-registered',
    );

    final auditorPaths = expectedRegistry.values
        .map((path) => '../../.codex/$path')
        .toList(growable: false);
    const exactAllowlist =
        '`rg`, `Get-Content`, `git show`, `git log`, '
        '`git diff --no-ext-diff`, and `git --no-optional-locks status` '
        'with `GIT_OPTIONAL_LOCKS=0`.';
    const standardDenylist =
        'Do not run fetch, checkout, add, commit, push, package resolution, '
        'Flutter/Gradle test/build/analyze, generators, quality wrappers, '
        'ADB/emulator commands, background processes, Figma writes, task '
        'creation, or account-backed actions.';
    const androidDenylist =
        'Do not run fetch, checkout, add, commit, push, package resolution, '
        'Flutter/Gradle test/build/analyze, generators, quality wrappers, '
        'background processes, Figma writes, task creation, or '
        'account-backed actions.';
    for (final entry in expectedRegistry.entries) {
      final path = '../../.codex/${entry.value}';
      final source = File(path).readAsStringSync();
      final header = _parseCodexAgentHeader(source);
      expect(header['name'], entry.key, reason: path);
      expect(header['sandbox_mode'], 'read-only', reason: path);
      expect(source, contains(exactAllowlist), reason: path);
      for (final safetyClause in <String>[
        'Get-Content -LiteralPath',
        'rg --pre',
        'GIT_PAGER=cat',
        '--no-textconv',
        '--output',
        'repo-relative',
      ]) {
        expect(source, contains(safetyClause), reason: '$path: $safetyClause');
      }
      for (final mutation in <String>[
        'package resolution',
        'Flutter/Gradle test/build/analyze',
        'generators',
        'quality wrappers',
        'background processes',
        'Figma writes',
        'task creation',
        'account-backed actions',
      ]) {
        expect(source, contains(mutation), reason: '$path: $mutation');
      }
    }

    for (final path in auditorPaths.take(4)) {
      final source = File(path).readAsStringSync();
      expect(source, contains(standardDenylist), reason: path);
    }

    final android = File(auditorPaths.last).readAsStringSync();
    expect(android, contains(androidDenylist));
    const serialScopedAdb =
        'Every device-affecting ADB command must use `adb -s <assigned-serial>`';
    const assignedPatrol =
        'Run local Patrol only when the coordinator supplies the exact serial-bound command';
    for (final contract in <String>[
      'DEVICE_OWNERSHIP.md',
      'coordinator-supplied immutable commit',
      'coordinator-supplied immutable APK',
      'coordinator-assigned serial',
      'coordinator owns durable evidence-file writes',
      'Only `adb devices` may be unscoped',
      serialScopedAdb,
      'overrides older unscoped ADB examples',
      assignedPatrol,
    ]) {
      expect(android, contains(contract), reason: contract);
    }

    final chainPrompt = File(
      'docs/agent/AUTONOMOUS_CHAIN_HANDOFF_PROMPT.md',
    ).readAsStringSync();
    final startupStart = chainPrompt.indexOf('Required startup:');
    final startupEnd = chainPrompt.indexOf('Objective:', startupStart);
    expect(startupStart, greaterThanOrEqualTo(0));
    expect(startupEnd, greaterThan(startupStart));
    final startup = chainPrompt.substring(startupStart, startupEnd);
    final danioRunner = startup.indexOf(
      r'1. Load the latest installed $danio-autonomous-slice-runner',
    );
    final verifiedRunner = startup.indexOf(
      r'2. Load the latest installed $verified-slice-runner',
    );
    expect(danioRunner, greaterThanOrEqualTo(0));
    expect(verifiedRunner, greaterThan(danioRunner));
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

  test('pure PowerShell module exposes the Task 5 validation surface', () {
    final source = File(_implementedPowerShellPaths.first).readAsStringSync();

    expect(source, contains('[CmdletBinding()]'));
    expect(source, contains('Set-StrictMode -Version Latest'));
    expect(source, contains(r'$ErrorActionPreference = "Stop"'));
    for (final functionName in <String>[
      'Resolve-DanioRepositoryRoot',
      'Read-DanioLedgerClosureRows',
      'Test-DanioLedgerClosureRows',
      'Test-DanioRunState',
      'Test-DanioRunStateTransition',
      'Test-DanioCompletionReadiness',
      'Get-DanioRepositoryObservation',
      'Test-DanioRunnerCompatibility',
      'New-DanioSynchronizationReceipt',
      'Test-DanioSynchronizationReceipt',
      'Test-DanioAutonomousReadiness',
      'New-DanioWriterClaimPlan',
    ]) {
      expect(source, contains('function $functionName'));
      expect(source, contains('"$functionName"'));
    }

    for (final laterFunction in <String>['New-DanioRehearsalReport']) {
      expect(source, isNot(contains('function $laterFunction')));
    }

    for (final mutation in <String>[
      'git fetch',
      'git add',
      'git commit',
      'git push',
      'git worktree',
      'Set-Content',
      'Add-Content',
      'Out-File',
      'New-Item',
      'Remove-Item',
      'Start-Process',
      'Invoke-RestMethod',
      'Invoke-WebRequest',
      'adb ',
    ]) {
      expect(source, isNot(contains(mutation)), reason: mutation);
    }
    expect(
      RegExp(
        r'^\s*(?:&\s*)?create_thread(?:\s|$)',
        caseSensitive: false,
        multiLine: true,
      ).hasMatch(source),
      isFalse,
      reason: 'create_thread invocation',
    );
  });

  test('Task 9 transition surfaces carry exact evidence and release inputs', () {
    final readiness = File(
      'scripts/autonomous_completion/check_autonomous_completion_readiness.ps1',
    ).readAsStringSync();
    final validator = File(
      'scripts/autonomous_completion/validate_autonomous_completion_transition.ps1',
    ).readAsStringSync();
    final transaction = File(
      'scripts/autonomous_completion/commit_autonomous_completion_transition.ps1',
    ).readAsStringSync();

    for (final source in <String>[readiness, validator]) {
      expect(source, contains(r'$EvidenceManifestPath'));
      expect(source, contains(r'$LeaseReleaseJson'));
      expect(
        source,
        contains("-cnotmatch '^[A-Za-z0-9._/-]+\$'"),
        reason: 'unsafe artifact paths must be rejected before Git probing',
      );
    }
    expect(validator, isNot(contains('"write-tree"')));
    expect(validator, contains('precomputed tree hash'));
    expect(validator, contains('"diff", "--cached", "--quiet"'));
    for (final parameter in <String>[
      'NextRunStateJson',
      'ExpectedStateRevision',
      'ExpectedOriginMainCommit',
      'EvidenceManifestPath',
      'LeaseReleaseJson',
      'RepositoryRoot',
      'TestTransportOutcome',
    ]) {
      expect(transaction, contains(r'$' + parameter), reason: parameter);
    }
    for (final resultField in <String>[
      'document_type',
      'schema_version',
      'completed_at_utc',
      'accepted',
      'code',
      'details',
      'transition_action',
      'from_mode',
      'to_mode',
      'run_id',
      'work_unit_id',
      'expected_state_revision',
      'candidate_state_revision',
      'evidence_manifest_path',
      'owner_token_sha256',
      'mutations_performed',
      'push_attempted',
      'push_attempt_count',
      'push_timed_out',
      'push_termination_confirmed',
      'push_rejection_proven',
      'retry_performed',
      'reconciliation_status',
      'candidate_charge_consumed',
      'durable_charge_consumption_proven',
      'owner_retained',
      'owner_released',
      'owned_cleanup_proven',
      'artifacts_preserved',
      'candidate_commit',
      'staged_tree_hash',
      'origin_main_commit',
      'test_transport_outcome',
    ]) {
      expect(
        transaction,
        contains(RegExp('\\b$resultField\\s*=')),
        reason: resultField,
      );
    }
    expect(transaction, contains('danio_transition_commit_result'));
    expect(transaction, contains('TRANSITION_COMMITTED'));
    expect(transaction, contains('Danio-Evidence-Manifest'));
    expect(transaction, contains('PUSH_OUTCOME_UNKNOWN'));
    expect(transaction, contains('REMOTE_MOVED'));
    expect(transaction, contains('STOP_PENDING'));
    expect(transaction, isNot(contains('git push --force')));
  });

  test('evidence schema binds named checks to commands and artifacts', () {
    final schema = _readJson('$_schemaRoot/evidence_manifest.schema.json');
    final required = (schema['required'] as List<dynamic>).cast<String>();
    expect(required, contains('checks'));
    final properties = schema['properties'] as Map<String, dynamic>;
    final checks = properties['checks'] as Map<String, dynamic>;
    final checkReference = checks['items'] as Map<String, dynamic>;
    expect(checkReference[r'$ref'], '#/\$defs/check_result');
    final definitions = schema[r'$defs'] as Map<String, dynamic>;
    final check = definitions['check_result'] as Map<String, dynamic>;
    expect(check['additionalProperties'], isFalse);
    expect(
      (check['required'] as List<dynamic>).cast<String>().toSet(),
      <String>{'code', 'status', 'command_indexes', 'artifact_indexes'},
    );
  });

  test('pure module carries the exact allowed transition matrix', () {
    final source = File(_implementedPowerShellPaths.first).readAsStringSync();
    const allowed = <String, String>{
      'inactive>ready': 'launch',
      'ready>active': 'claim',
      'handoff_ready>active': 'claim',
      'ready>stopped': 'preclaim_stop',
      'handoff_ready>stopped': 'preclaim_stop',
      'active>handoff_ready': 'closeout',
      'active>paused': 'pause',
      'active>stopped': 'stop',
      'active>finalizing': 'finalize',
      'finalizing>complete': 'complete',
      'finalizing>stopped': 'finalization_stop',
      'paused>ready': 'resume',
      'stopped>ready': 'resume',
      'handoff_ready>handoff_ready': 'administrative_sync',
      'complete>complete': 'administrative_sync',
    };

    for (final entry in allowed.entries) {
      expect(source, contains('"${entry.key}" = "${entry.value}"'));
    }
    expect(source, isNot(contains('"active>complete"')));
    expect(source, isNot(contains('"active>active"')));
    expect(source, isNot(contains('"STOP_PENDING" =')));
  });

  test('state fixtures encode claim and exactly-once charge semantics', () {
    final inactive = _readJson(_fixturePaths[0]);
    final ready = _readJson(_fixturePaths[1]);
    final active = _readJson(_fixturePaths[2]);
    final handoffReady = _readJson(_fixturePaths[3]);
    final finalizing = _readJson(_fixturePaths[4]);
    final complete = _readJson(_fixturePaths[5]);

    Map<String, dynamic> budget(Map<String, dynamic> state) =>
        state['budget'] as Map<String, dynamic>;
    Map<String, dynamic> charge(Map<String, dynamic> state) =>
        budget(state)['current_charge'] as Map<String, dynamic>;

    expect(budget(inactive)['consumed_units'], 1);
    expect(budget(inactive)['remaining_units_including_current'], 19);
    expect(charge(inactive)['status'], 'none');
    expect(budget(ready)['consumed_units'], 2);
    expect(budget(ready)['remaining_units_including_current'], 18);
    expect(charge(ready)['status'], 'none');
    expect(budget(active)['consumed_units'], 2);
    expect(budget(active)['remaining_units_including_current'], 18);
    expect(charge(active)['status'], 'pending');
    expect(active['owner'], isNotNull);
    expect(
      (active['owner'] as Map<String, dynamic>)['token_sha256'],
      '5566cc56fcd32df88a240501e09417589eab91939aa46f6bfde7a4a2b806ea89',
    );

    for (final state in <Map<String, dynamic>>[
      handoffReady,
      finalizing,
      complete,
    ]) {
      expect(budget(state)['consumed_units'], 3);
      expect(budget(state)['remaining_units_including_current'], 17);
      expect(charge(state)['status'], 'consumed');
    }
    expect(handoffReady['owner'], isNull);
    expect(finalizing['owner'], isNotNull);
    expect(complete['owner'], isNull);
  });
}

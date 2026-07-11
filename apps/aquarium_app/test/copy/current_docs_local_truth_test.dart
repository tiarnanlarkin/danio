import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _source(String path) => File(path).readAsStringSync();
bool _exists(String path) => File(path).existsSync();

void _expectContainsAll(String path, Iterable<String> values) {
  final source = _source(path);
  for (final value in values) {
    expect(source, contains(value), reason: '$path should link $value');
  }
}

String _markdownSection(String source, String heading) {
  final headingPattern = RegExp(
    '^${RegExp.escape('## $heading')}\$',
    multiLine: true,
  );
  final matches = headingPattern.allMatches(source).toList();
  if (matches.length != 1) {
    throw StateError(
      'Expected one "## $heading" section, found ${matches.length}',
    );
  }

  final start = matches.single.end;
  final remainder = source.substring(start);
  final nextHeading = RegExp(r'^## ', multiLine: true).firstMatch(remainder);
  return remainder.substring(0, nextHeading?.start ?? remainder.length);
}

List<String> _markdownCells(String line) {
  final trimmed = line.trim();
  if (!trimmed.startsWith('|') || !trimmed.endsWith('|')) {
    throw StateError('Malformed Markdown table row: $line');
  }
  return trimmed
      .substring(1, trimmed.length - 1)
      .split('|')
      .map((cell) => cell.trim())
      .toList();
}

List<Map<String, String>> _markdownRows(String source, String heading) {
  final lines = _markdownSection(
    source,
    heading,
  ).split('\n').where((line) => line.trim().startsWith('|')).toList();
  if (lines.length < 3) {
    throw StateError('Expected a Markdown table under "## $heading"');
  }

  final headers = _markdownCells(lines.first);
  final separator = _markdownCells(lines[1]);
  if (headers.any((header) => header.isEmpty) ||
      headers.toSet().length != headers.length ||
      separator.length != headers.length ||
      separator.any((cell) => !RegExp(r'^:?-{3,}:?$').hasMatch(cell))) {
    throw StateError('Malformed Markdown table header under "## $heading"');
  }

  return lines.skip(2).map((line) {
    final cells = _markdownCells(line);
    if (cells.length != headers.length) {
      throw StateError(
        'Expected ${headers.length} cells under "## $heading", '
        'found ${cells.length}: $line',
      );
    }
    return {
      for (var index = 0; index < headers.length; index++)
        headers[index]: cells[index],
    };
  }).toList();
}

Map<String, dynamic> _jsonBlock(
  String source,
  String documentType,
) {
  final matches = RegExp(
    r'```json\s*(.*?)```',
    dotAll: true,
  ).allMatches(source);
  final documents = <Map<String, dynamic>>[];
  for (final match in matches) {
    final decoded = jsonDecode(match.group(1)!) as Map<String, dynamic>;
    if (decoded['document_type'] == documentType) {
      documents.add(decoded);
    }
  }
  if (documents.length != 1) {
    throw StateError(
      'Expected one $documentType JSON block, found ${documents.length}',
    );
  }
  return documents.single;
}

Iterable<String?> _statesFor(
  List<Map<String, String>> rows,
  Set<String> ids,
) => ids.map(
  (id) => rows.singleWhere((row) => row['ID'] == id)['Closure State'],
);

String _plainMarkdownCell(String value) => value.replaceAll('`', '').trim();

String _normalizedLedgerIds(String value) {
  final plain = _plainMarkdownCell(value);
  if (plain == 'none') {
    return plain;
  }
  return plain.split(',').map((id) => id.trim()).join(',');
}

void main() {
  test('current docs describe the local-first build honestly', () {
    final staleClaims = {
      'README.md': RegExp(
        'uses Supabase for its backend|'
        'Supabase \\(Postgres \\+ Auth \\+ Realtime\\)|'
        'Business logic services \\(sync, backup, analytics\\)|'
        'Supabase client initialisation',
        caseSensitive: false,
      ),
      'docs/feature-registry.md': RegExp(
        'SyncService|Displays fake sync counts|'
        'Friends \\(CA-002\\)|Leaderboard \\(CA-003\\)',
        caseSensitive: false,
      ),
      'docs/data-resilience-audit.md': RegExp(
        'SyncService|queued for eventual sync|'
        'Via sync queue|Backend Sync Scaffold|friends / social',
        caseSensitive: false,
      ),
    };

    for (final entry in staleClaims.entries) {
      expect(
        _source(entry.key),
        isNot(contains(entry.value)),
        reason: entry.key,
      );
    }

    expect(_source('README.md'), contains('local-first'));
    expect(
      _source('docs/feature-registry.md'),
      contains('dormant backend-sync queue code has been removed'),
    );
    expect(
      _source('docs/data-resilience-audit.md'),
      contains('No dormant backend queue remains in the current local build'),
    );
  });

  test('agent workflow foundation docs exist and are linked', () {
    const requiredDocs = [
      'docs/agent/WORKFLOW_CHARTER.md',
      'docs/agent/RESEARCH_PROTOCOL.md',
      'docs/agent/ACTIVE_HANDOFF.md',
      'docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md',
      'docs/agent/VERIFIED_SLICE_EXECUTION_CONTRACT.md',
      'docs/agent/COMPLETE_LOCAL_FORECAST.md',
      'docs/agent/AUTONOMOUS_CHAIN_HANDOFF_PROMPT.md',
      'docs/agent/SCREEN_INVENTORY.md',
      'docs/agent/SLICE_LOG.md',
      'docs/agent/HOUSEKEEPING.md',
      'docs/agent/QUALITY_LADDER.md',
      'docs/agent/SOURCE_REFERENCES.md',
      'docs/agent/plans/2026-07-11-phone-complete-local-completion-program.md',
    ];

    for (final path in requiredDocs) {
      expect(_exists(path), isTrue, reason: path);
    }

    final entryDocs = <String, List<String>>{
      '../../AGENTS.md': [
        'WORKFLOW_CHARTER.md',
        'RESEARCH_PROTOCOL.md',
        'ACTIVE_HANDOFF.md',
        'COMPLETE_LOCAL_CLOSURE_LEDGER.md',
        'VERIFIED_SLICE_EXECUTION_CONTRACT.md',
        'COMPLETE_LOCAL_FORECAST.md',
        'AUTONOMOUS_CHAIN_HANDOFF_PROMPT.md',
        'SCREEN_INVENTORY.md',
        'QUALITY_LADDER.md',
        '2026-07-11-phone-complete-local-completion-program.md',
      ],
      'docs/agent/CODEX_SETUP.md': [
        'WORKFLOW_CHARTER.md',
        'RESEARCH_PROTOCOL.md',
        'ACTIVE_HANDOFF.md',
        'COMPLETE_LOCAL_CLOSURE_LEDGER.md',
        'VERIFIED_SLICE_EXECUTION_CONTRACT.md',
        'COMPLETE_LOCAL_FORECAST.md',
        'SCREEN_INVENTORY.md',
        'QUALITY_LADDER.md',
      ],
      'docs/agent/AUTONOMOUS_QUALITY_SETUP.md': [
        'WORKFLOW_CHARTER.md',
        'RESEARCH_PROTOCOL.md',
        'ACTIVE_HANDOFF.md',
        'COMPLETE_LOCAL_CLOSURE_LEDGER.md',
        'VERIFIED_SLICE_EXECUTION_CONTRACT.md',
        'COMPLETE_LOCAL_FORECAST.md',
        'QUALITY_LADDER.md',
      ],
      'docs/agent/TESTING_CHECKLIST.md': [
        'WORKFLOW_CHARTER.md',
        'COMPLETE_LOCAL_CLOSURE_LEDGER.md',
        'VERIFIED_SLICE_EXECUTION_CONTRACT.md',
        'COMPLETE_LOCAL_FORECAST.md',
        'RESEARCH_PROTOCOL.md',
        'ACTIVE_HANDOFF.md',
        'QUALITY_LADDER.md',
        'SCREEN_INVENTORY.md',
      ],
      'docs/agent/MULTI_AGENT_WORKFLOW.md': [
        'WORKFLOW_CHARTER.md',
        'RESEARCH_PROTOCOL.md',
        'ACTIVE_HANDOFF.md',
        'COMPLETE_LOCAL_CLOSURE_LEDGER.md',
        'VERIFIED_SLICE_EXECUTION_CONTRACT.md',
        'COMPLETE_LOCAL_FORECAST.md',
        'SLICE_LOG.md',
        'QUALITY_LADDER.md',
      ],
      'docs/agent/FINISH_MAP.md': [
        'ACTIVE_HANDOFF.md',
        'COMPLETE_LOCAL_CLOSURE_LEDGER.md',
        'VERIFIED_SLICE_EXECUTION_CONTRACT.md',
        'COMPLETE_LOCAL_FORECAST.md',
        'SCREEN_INVENTORY.md',
        'SLICE_LOG.md',
        '2026-07-11-phone-complete-local-completion-program.md',
      ],
    };

    for (final entry in entryDocs.entries) {
      _expectContainsAll(entry.key, entry.value);
    }
  });

  test('phone completion scope keeps tablet and external lanes parked', () {
    _expectContainsAll(
      'docs/agent/plans/2026-07-11-phone-complete-local-completion-program.md',
      [
        'Android phone only',
        'DCL-DR-001',
        'DCL-P1-001',
        'DCL-P1-002',
        'DCL-TAB-001',
        'JnSwJlWnisxF6xtiwK6nFc',
      ],
    );
    _expectContainsAll('docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md', [
      'PHASE_PARKED',
      'Current Phone Completion Boundary',
    ]);
    _expectContainsAll('docs/agent/QUALITY_LADDER.md', [
      'Current phase: Android phone complete-local',
      'Phone release candidate',
    ]);
  });

  test('accepted phone product-depth boundaries are recorded', () {
    _expectContainsAll('docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md', [
      'DCL-P1-001',
      'DCL-P1-002',
      'ACCEPTED_LOCAL_LIMITATION',
      'current data-derived plant, aquascape, decoration, progression, and seasonal cues',
      'current room vibes, badges, inventory, earned decorations, and equip controls',
    ]);
    _expectContainsAll(
      'docs/agent/plans/2026-07-11-phone-complete-local-completion-program.md',
      [
        'Resolved on 2026-07-11',
        'Both ledger rows are closed as `ACCEPTED_LOCAL_LIMITATION`',
      ],
    );
    _expectContainsAll('docs/agent/FINISH_MAP.md', [
      'accepted the current Living Tank and rewards depth',
      'Dedicated plant inventory, broader seasonal variants',
    ]);
  });

  test('autonomy bootstrap authority is canonical and fail-closed', () {
    const parkedIds = {
      'DCL-TAB-001',
      'DCL-QA-001',
      'DCL-EXT-001',
      'DCL-PREMIUM-001',
      'DCL-EXT-002',
    };
    const acceptedOrArchivedIds = {
      'DCL-ARCH-001',
      'DCL-DR-005',
      'DCL-P1-001',
      'DCL-P1-002',
    };
    const programLedgerIds = {
      'DCL-DR-001',
      'DCL-DR-002',
      'DCL-DR-003',
      'DCL-DR-004',
      'DCL-AI-001',
      'DCL-P1-001',
      'DCL-P1-002',
      'DCL-P1-003',
      'DCL-P1-004',
      'DCL-P1-005',
      'DCL-P1-006',
      'DCL-PREF-001',
      'DCL-CONTENT-001',
      'DCL-RULE-001',
      'DCL-A11Y-001',
      'DCL-VIS-001',
      'DCL-VIS-002',
      'DCL-TAB-001',
      'DCL-MOTION-001',
      'DCL-PERF-001',
      'DCL-QA-001',
      'DCL-EXT-001',
      'DCL-PREMIUM-001',
      'DCL-RC-001',
      'DCL-EXT-002',
    };
    const allowedStates = {
      'open',
      'closed',
      'parked',
      'decision_required',
    };

    final ledger = _source('docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md');
    final rows = [
      ..._markdownRows(ledger, 'Active Findings'),
      ..._markdownRows(ledger, 'Closed, Accepted, Or Superseded Findings'),
    ];
    final ids = rows.map((row) => row['ID']).toSet();
    expect(ids.length, rows.length, reason: 'Ledger IDs must be unique');
    expect(
      rows.every((row) => allowedStates.contains(row['Closure State'])),
      isTrue,
      reason: 'Every ledger row needs an allowed Closure State',
    );
    expect(_statesFor(rows, parkedIds), everyElement('parked'));
    expect(_statesFor(rows, acceptedOrArchivedIds), everyElement('closed'));
    expect(ids, containsAll(programLedgerIds));

    for (final id in {'DCL-A11Y-001', 'DCL-PERF-001'}) {
      final row = rows.singleWhere((candidate) => candidate['ID'] == id);
      final activeScope = [
        row['Finding'],
        row['Lane'],
        row['Done Condition'],
      ].join(' ').toLowerCase();
      expect(activeScope, contains('phone'), reason: '$id must be phone-only');
      expect(
        activeScope,
        isNot(contains('tablet')),
        reason: '$id must not own later tablet work',
      );
    }
    final tabletRow = rows.singleWhere(
      (candidate) => candidate['ID'] == 'DCL-TAB-001',
    );
    final tabletScope = tabletRow.values.join(' ').toLowerCase();
    expect(tabletScope, contains('accessibility'));
    expect(tabletScope, contains('performance'));

    final program = _source(
      'docs/agent/plans/2026-07-11-phone-complete-local-completion-program.md',
    );
    final phaseRows = _markdownRows(program, 'Ordered Completion Phases');
    expect(
      program,
      contains('This program is the only authority for ordered phase sequence'),
    );
    expect(
      phaseRows.map((row) => row['Phase']),
      equals([
        '0. Scope lock',
        '1. Data resilience',
        '2. Optional AI and preferences',
        '3. Normal-user depth',
        '4. Content and rules',
        '5. Phone accessibility and visual quality',
        '6. Phone performance',
        '7. Final phone candidate',
      ]),
    );
    expect(
      _normalizedLedgerIds(phaseRows[2]['Ledger rows']!),
      'DCL-AI-001,DCL-PREF-001',
    );
    expect(
      _normalizedLedgerIds(phaseRows[6]['Ledger rows']!),
      'DCL-PERF-001',
    );
    expect(
      _normalizedLedgerIds(phaseRows.last['Ledger rows']!),
      'DCL-RC-001',
    );
    expect(
      program,
      contains('First Product Slice After Workflow Setup And Explicit Launch'),
    );
    expect(program, isNot(contains('tablet portion of `DCL-PERF-001`')));

    final forecast = _source('docs/agent/COMPLETE_LOCAL_FORECAST.md');
    expect(
      forecast,
      contains('| 6. Phone performance evidence | `DCL-PERF-001` |'),
    );
    expect(forecast, isNot(contains('tablet portion of `DCL-PERF-001`')));
    expect(
      forecast,
      contains('| Tablet sequencing. | `DCL-TAB-001` |'),
    );

    final finishMap = _source('docs/agent/FINISH_MAP.md');
    final completionRows = _markdownRows(finishMap, 'Current Completion Map');
    final areas = completionRows.map((row) => row['Area']!).toList();
    expect(areas.toSet().length, areas.length, reason: 'Areas must be unique');
    final ledgerIdsByArea = {
      for (final row in completionRows)
        row['Area']!: _normalizedLedgerIds(row['Ledger IDs']!),
    };
    const expectedMappings = {
      'Living Tank': 'DCL-P1-001',
      'Rewards and collectibles': 'DCL-P1-002',
      'Species and plants': 'DCL-P1-006',
      'Learning': 'DCL-P1-005',
      'Practice': 'DCL-P1-003',
      'Guided tools': 'DCL-P1-003',
      'Timeline and journal': 'DCL-P1-004',
      'Backup and restore': 'DCL-DR-001,DCL-DR-002,DCL-DR-004',
      'Preferences': 'DCL-PREF-001',
      'Tablet layout': 'DCL-TAB-001',
      'Whole-app tablet audit': 'DCL-TAB-001',
      'Visual asset quality': 'DCL-VIS-001',
      'Accessibility': 'DCL-A11Y-001',
      'Motion and haptics': 'DCL-MOTION-001',
      'Performance': 'DCL-PERF-001',
      'Optional AI providers': 'DCL-EXT-001',
      'AI confirmation': 'DCL-AI-001',
      'Premium AI path': 'DCL-PREMIUM-001',
      'Citations': 'DCL-P1-005,DCL-P1-006,DCL-CONTENT-001',
      'Whole-app phone audit': 'DCL-RC-001',
      'Visual regression': 'DCL-VIS-002',
      'Rule tests': 'DCL-RULE-001',
      'Content validation': 'DCL-CONTENT-001',
      'Data resilience': 'DCL-DR-001,DCL-DR-002,DCL-DR-003,DCL-DR-004',
      'Debug QA seeds': 'DCL-QA-001',
    };
    const preLedgerAreas = {
      'Product spine P0',
      'First-run onboarding',
      'Tank daily loop',
      'Emergency access',
      'No-AI Smart Hub',
      'Multi-tank',
      'Global search',
      'Demo mode',
      'Weekly Plan cache clear',
    };
    expect(
      areas.toSet(),
      equals({...expectedMappings.keys, ...preLedgerAreas}),
    );
    for (final entry in expectedMappings.entries) {
      expect(ledgerIdsByArea[entry.key], entry.value, reason: entry.key);
    }
    for (final area in preLedgerAreas) {
      expect(ledgerIdsByArea[area], 'none', reason: area);
    }
    expect(
      _markdownSection(finishMap, 'Slice Selection Rule'),
      allOf(
        contains('delegates solely'),
        contains('2026-07-11-phone-complete-local-completion-program.md'),
      ),
    );

    final design = _source(
      'docs/agent/plans/2026-07-11-autonomous-phone-completion-operating-model-design.md',
    );
    expect(
      design,
      contains('product_complete := run_state.mode == "complete"'),
    );
    expect(
      design,
      contains('canonical_reference := { path, commit, blob_oid }'),
    );
    expect(design, contains('bootstrap authority input snapshot'));
    const parentCommit = 'd62a174a41bbd7814f27163b93c077336e171336';
    const expectedPins = {
      'apps/aquarium_app/docs/agent/plans/2026-07-11-phone-complete-local-completion-program.md':
          '89c834f4cb2fb893086e184dc7b0760c8b668d3c',
      'apps/aquarium_app/docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md':
          'f331860f7bfe335e65cee3c78c0d730d772cdd28',
      'apps/aquarium_app/docs/agent/FINISH_MAP.md':
          '852420754061c1d814931e7c2819004b1f058915',
      'apps/aquarium_app/docs/agent/QUALITY_LADDER.md':
          '91f4dd98e2b9953852bec632b86e78812e130291',
      'apps/aquarium_app/docs/agent/VERIFIED_SLICE_EXECUTION_CONTRACT.md':
          '0fd22199a62f9cf68e8f397af217f8a9f31f73f1',
      'apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md':
          '921e22a5fb1a05cbe45ce80062209f337326d58c',
      'apps/aquarium_app/docs/agent/DEVICE_OWNERSHIP.md':
          '229a3471399b0cd270ee0f34ecd9379b45b18590',
    };
    final referenceRows = _markdownRows(
      design,
      'Task 1 bootstrap authority input snapshot',
    );
    expect(referenceRows.length, expectedPins.length);
    for (final row in referenceRows) {
      final path = _plainMarkdownCell(row['Path']!);
      expect(expectedPins, contains(path));
      expect(_plainMarkdownCell(row['Commit']!), parentCommit, reason: path);
      expect(
        _plainMarkdownCell(row['Blob OID']!),
        expectedPins[path],
        reason: path,
      );
    }

    final handoff = _source('docs/agent/ACTIVE_HANDOFF.md');
    final budget = _jsonBlock(
      handoff,
      'danio_autonomy_bootstrap_budget',
    );
    final total = budget['total_approved_units'] as int;
    final consumed = budget['consumed_units'] as int;
    final remaining = budget['remaining_units_including_current'] as int;
    final lastClosedUnitId = budget['last_closed_unit_id'] as String;
    expect(budget['schema_version'], 1);
    expect(total, consumed + remaining);
    expect(total, 20);
    expect(consumed, greaterThanOrEqualTo(1));
    expect(consumed, lessThanOrEqualTo(total));
    expect(remaining, greaterThanOrEqualTo(0));
    expect(budget['authorization_id'], 'danio-phone-complete-local-2026-07-11');
    expect(budget['operational_state_path'], isNull);
    final sliceLog = _source('docs/agent/SLICE_LOG.md');
    expect(
      RegExp(
        r'^\| WF-2026-07-11-007 \|',
        multiLine: true,
      ).allMatches(sliceLog).length,
      1,
      reason: 'The planning unit must be recorded exactly once',
    );
    expect(
      RegExp(
        '^\\| ${RegExp.escape(lastClosedUnitId)} \\|',
        multiLine: true,
      ).allMatches(sliceLog).length,
      1,
      reason: 'The latest consumed unit must be recorded exactly once',
    );

    final chainPrompt = _source(
      'docs/agent/AUTONOMOUS_CHAIN_HANDOFF_PROMPT.md',
    );
    const disabledStatus =
        'Status: Bootstrap handoff only; automatic successor creation disabled until\n'
        'runner compatibility, single-writer enforcement, readiness validation, and\n'
        'the no-product-change rehearsal pass.';
    expect(chainPrompt, contains(disabledStatus));
    expect(chainPrompt, isNot(contains('Status: Active successor prompt')));
    final danioRunnerIndex = chainPrompt.indexOf(
      r'$danio-autonomous-slice-runner',
    );
    final verifiedRunnerIndex = chainPrompt.indexOf(r'$verified-slice-runner');
    expect(danioRunnerIndex, greaterThanOrEqualTo(0));
    expect(verifiedRunnerIndex, greaterThanOrEqualTo(0));
    expect(danioRunnerIndex, lessThan(verifiedRunnerIndex));
    _expectContainsAll('../../AGENTS.md', [
      'automatic operational chaining remains disabled',
      'explicit user-authorized project-scoped bootstrap handoff',
    ]);
    _expectContainsAll('docs/agent/VERIFIED_SLICE_EXECUTION_CONTRACT.md', [
      r'$danio-autonomous-slice-runner',
      r'$verified-slice-runner',
      'automatic operational chaining remains disabled',
    ]);
    _expectContainsAll('docs/agent/QUALITY_LADDER.md', [
      'Autonomy authority/bootstrap setup',
      'automatic successor creation disabled',
    ]);
  });
}

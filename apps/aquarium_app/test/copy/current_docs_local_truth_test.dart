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
  test('release documents carry the current security hold', () {
    const marker =
        'Current security clearance (2026-07-15): **NOT RELEASE-READY.**';
    const playConsoleMarker =
        'Danio is not listed in the Play Console account inspected on '
        '2026-07-15.';
    const releaseDocuments = [
      'docs/qa/final-launch-readiness-2026-06-12.md',
      'docs/LAUNCH_CHECKLIST.md',
      '../../docs/audit/LAUNCH_STATUS_DASHBOARD.md',
      '../../docs/audit/LAUNCH_READINESS_AUDIT.md',
      '../../docs/completed/PLAY_STORE_LAUNCH_COMPLETE.md',
      '../../docs/guides/RELEASE_BUILD_INSTRUCTIONS.md',
      'docs/RELEASE_READINESS.md',
      '../../docs/LAUNCH_CHECKLIST.md',
      '../../docs/audit/LAUNCH_ACTION_PLAN.md',
      '../../docs/audit/LAUNCH_CHECKLIST_SUMMARY.md',
      '../../docs/plans/LAUNCH_NIGHT_PLAN.md',
      'docs/play-store-readiness-audit.md',
    ];

    for (final path in releaseDocuments) {
      final openingLines = _source(path).split('\n').take(8).join('\n');
      expect(openingLines, contains(marker), reason: path);
      expect(openingLines, contains(playConsoleMarker), reason: path);
    }

    expect(
      _source('docs/agent/ACTIVE_HANDOFF.md'),
      contains(playConsoleMarker),
    );
    expect(
      _source(
        'docs/agent/plans/'
        'SEC-2026-07-15-013-android-signing-exposure-containment-'
        'slice-contract.md',
      ),
      contains(playConsoleMarker),
    );
  });

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
      'docs/agent/DCL_DR_002_MIGRATION_CORRUPTION_RECOVERY_MATRIX.md',
      'docs/agent/VERIFIED_SLICE_EXECUTION_CONTRACT.md',
      'docs/agent/COMPLETE_LOCAL_FORECAST.md',
      'docs/agent/AUTONOMOUS_CHAIN_HANDOFF_PROMPT.md',
      'docs/agent/AUTONOMOUS_PHONE_COMPLETION_RUNBOOK.md',
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
        'GIT_WORKFLOW.md',
        'ACTIVE_HANDOFF.md',
        'VERIFIED_SLICE_EXECUTION_CONTRACT.md',
        'QUALITY_LADDER.md',
      ],
      'docs/agent/CODEX_SETUP.md': [
        'GIT_WORKFLOW.md',
        'ACTIVE_HANDOFF.md',
        'VERIFIED_SLICE_EXECUTION_CONTRACT.md',
        'QUALITY_LADDER.md',
      ],
      'docs/agent/TESTING_CHECKLIST.md': [
        'VERIFIED_SLICE_EXECUTION_CONTRACT.md',
        'QUALITY_LADDER.md',
        '-FocusedTests',
        '-RunAutonomyTests',
      ],
      'docs/agent/FINISH_MAP.md': [
        'COMPLETE_LOCAL_CLOSURE_LEDGER.md',
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
    _expectContainsAll('docs/agent/ACTIVE_HANDOFF.md', [
      'DCL-DR-001',
      'DCL-DR-001-F2',
      'DCL-DR-001-F3',
      'DCL-DR-001-F4',
      'DCL-DR-001-F5',
      'DCL-DR-001-F6',
      'DCL-DR-002',
      '`DCL-DR-001` is `closed`',
      '`DCL-DR-002` is `closed`',
      'DCL-DR-002-F1',
      'DCL-DR-002-F2',
      'DCL-DR-002-F3',
      'DCL-DR-002-F4',
      'DCL-DR-002-F5',
      'DCL-DR-002-F6',
      'DCL-DR-002-F7',
      'DCL-DR-002-F8',
      'DR-2026-07-16-022',
      'danio-dcl-dr-002-migration-corruption-recovery-audit-2026-07-16/1',
      'danio-dcl-dr-002-recovery-copy-honesty-2026-07-16/1',
      'danio-dcl-dr-002-corrupt-json-retry-proof-2026-07-16/1',
      'danio-dcl-dr-002-start-fresh-cancel-back-proof-2026-07-16/1',
      'danio-dcl-dr-002-start-fresh-scoped-deletion-proof-2026-07-16/1',
      'danio-dcl-dr-002-start-fresh-failure-proof-2026-07-16/1',
      'danio-dcl-dr-002-v0-preference-preservation-proof-2026-07-16/1',
      'danio-dcl-dr-002-local-json-first-run-proof-2026-07-16/1',
      'DCL-DR-003',
      '`DCL-DR-003` remains `open`',
      'DCL-DR-003-F1',
      'DCL-DR-003-F2',
      'DCL-DR-003-F3',
      'DCL-DR-003-F4',
      'DCL-DR-003-F5',
      'DCL-DR-003-F6',
      'DCL-DR-003-F7',
      'DCL-DR-003-F8',
      'DCL_DR_003_CRUD_UNDO_RESILIENCE_MATRIX.md',
      'danio-dcl-dr-003-crud-undo-resilience-audit-2026-07-16/1',
      'danio-dcl-dr-003-equipment-undo-rollback-proof-2026-07-16/1',
      'danio-dcl-dr-003-review-answer-persistence-proof-2026-07-16/1',
      'danio-dcl-dr-003-normal-lesson-gem-retry-proof-2026-07-16/1',
      'danio-dcl-dr-003-home-quick-feed-parent-preflight-proof-2026-07-16/1',
      'danio-dcl-dr-003-livestock-quick-feed-parent-preflight-proof-2026-07-16/1',
      'danio-dcl-dr-003-home-quick-water-parent-preflight-proof-2026-07-16/1',
      'danio-dcl-dr-003-task-delete-failure-proof-2026-07-16/1',
      'danio-dcl-dr-003-task-completion-stale-id-proof-2026-07-16/1',
      'locally fixed',
      'locally verified',
    ]);
    _expectContainsAll(
      'docs/agent/DCL_DR_001_RESTORE_BEHAVIOR_MATRIX.md',
      [
        'danio-dcl-dr-001-restore-matrix-audit-2026-07-15/1',
        'DCL-DR-001-F1',
        'DCL-DR-001-F2',
        'DCL-DR-001-F3',
        'DCL-DR-001-F4',
        'DCL-DR-001-F5',
        'DCL-DR-001-F6',
        'restore preserves the initiating error when snapshot rollback also fails',
        'restoreBackup cleans new photos and preserves existing files after mid-extraction failure',
        'Status: closed',
      ],
    );
    _expectContainsAll(
      'docs/agent/DCL_DR_002_MIGRATION_CORRUPTION_RECOVERY_MATRIX.md',
      [
        'danio-dcl-dr-002-migration-corruption-recovery-audit-2026-07-16/1',
        'DCL-DR-002-F1',
        'I/O load error offers real retry without destructive start fresh',
        'danio-dcl-dr-002-recovery-copy-honesty-2026-07-16/1',
        'DCL-DR-002-F2',
        'malformed JSON copy failure does not advertise recovery path',
        'corruption without recovery path never claims a copy exists',
        'danio-dcl-dr-002-corrupt-json-retry-proof-2026-07-16/1',
        'DCL-DR-002-F3',
        'unchanged malformed JSON retry stays corrupted and blocks empty success',
        'repaired malformed JSON succeeds only through retry without rewriting repair',
        'danio-dcl-dr-002-start-fresh-cancel-back-proof-2026-07-16/1',
        'DCL-DR-002-F4',
        'canceling start fresh preserves corrupted storage and provider state',
        'system back dismisses start fresh without recovery side effects',
        'danio-dcl-dr-002-start-fresh-scoped-deletion-proof-2026-07-16/1',
        'DCL-DR-002-F5',
        'start fresh deletes only corrupt main and exposes healthy empty storage',
        'danio-dcl-dr-002-start-fresh-failure-proof-2026-07-16/1',
        'DCL-DR-002-F6',
        'failed start fresh retains recovery state without false success',
        'danio-dcl-dr-002-v0-preference-preservation-proof-2026-07-16/1',
        'DCL-DR-002-F7',
        'v0 stamp preserves every existing preference value and type',
        'danio-dcl-dr-002-local-json-first-run-proof-2026-07-16/1',
        'DCL-DR-002-F8',
        'missing local JSON loads healthy empty without recovery artifacts',
        'empty local JSON loads healthy empty without rewrite or recovery artifacts',
        'Status: closed',
      ],
    );
    _expectContainsAll(
      'docs/agent/DCL_DR_003_CRUD_UNDO_RESILIENCE_MATRIX.md',
      [
        'Status: open',
        'danio-dcl-dr-003-crud-undo-resilience-audit-2026-07-16/1',
        'DR-2026-07-16-022',
        'DCL-DR-003-F1',
        'Feed quick care rejects a missing tank before saving a log',
        'danio-dcl-dr-003-equipment-undo-rollback-proof-2026-07-16/1',
        'DCL-DR-003-F2',
        'failed maintenance-task undo rolls back restored equipment',
        'undo after leaving screen refreshes equipment watchers',
        'danio-dcl-dr-003-review-answer-persistence-proof-2026-07-16/1',
        'DCL-DR-003-F3',
        'recordSessionResult keeps the answer pending when review-card save fails',
        'recordSessionResult restores the card when review-stats save fails',
        'recordSessionResult rejects a session card missing from saved cards',
        'recordSessionResult does not resurrect an abandoned session after save',
        'failed review save neither advances nor awards XP',
        'failed XP save does not retry an already recorded answer',
        'danio-dcl-dr-003-normal-lesson-gem-retry-proof-2026-07-16/1',
        'DCL-DR-003-F4',
        'failed normal lesson save retries without duplicate quiz gems or false progress',
        'normal lesson no-op cannot claim saved progress',
        'already completed normal lesson adds no duplicate rewards',
        'post-commit activity failure does not claim lesson progress was unsaved',
        'post-commit quiz reward failure preserves saved lesson progress',
        'danio-dcl-dr-003-home-quick-feed-parent-preflight-proof-2026-07-16/1',
        'DCL-DR-003-F5',
        'main Tank Feed quick action rejects a missing parent before saving a log',
        'danio-dcl-dr-003-livestock-quick-feed-parent-preflight-proof-2026-07-16/1',
        'DCL-DR-003-F6',
        'quick feeding rejects a missing parent before saving or rewarding',
        'danio-dcl-dr-003-home-quick-water-parent-preflight-proof-2026-07-16/1',
        'DCL-DR-003-F7',
        'quick water test rejects a missing parent before saving or rewarding',
        'danio-dcl-dr-003-task-delete-failure-proof-2026-07-16/1',
        'DCL-DR-003-F8',
        'failed primary delete keeps task visible with error feedback',
        'danio-dcl-dr-003-task-completion-stale-id-proof-2026-07-16/1',
      ],
    );
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

  test('E0 roadmap authority lock is finite and cannot revive old workflow', () {
    const marker = 'danio-completion-roadmap-authority-lock-2026-07-15/1';
    const authorityPaths = [
      'docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md',
      'docs/agent/FINISH_MAP.md',
      'docs/agent/COMPLETE_LOCAL_FORECAST.md',
      'docs/agent/plans/2026-07-11-phone-complete-local-completion-program.md',
      'docs/agent/PERFORMANCE_TARGETS.md',
      'docs/design/BASELINES.md',
      'docs/agent/ACTIVE_HANDOFF.md',
      'docs/agent/SLICE_LOG.md',
    ];
    final authorityText = authorityPaths.map(_source).join('\n');
    for (final path in authorityPaths) {
      expect(_source(path), contains(marker), reason: path);
    }

    final ledger = _source('docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md');
    final rows = [
      ..._markdownRows(ledger, 'Active Findings'),
      ..._markdownRows(ledger, 'Closed, Accepted, Or Superseded Findings'),
    ];
    for (final id in {
      'DCL-DR-003',
      'DCL-P1-005',
      'DCL-P1-006',
      'DCL-VIS-001',
      'DCL-VIS-002',
      'DCL-MOTION-001',
    }) {
      expect(
        rows.singleWhere((row) => row['ID'] == id)['Disposition'],
        '`VERIFY_LOCALLY`',
        reason: '$id must start from current proof, not a work quota',
      );
    }
    final aiRow = rows
        .singleWhere((row) => row['ID'] == 'DCL-AI-001')
        .values
        .join(' ');
    expect(aiRow, contains('Fish ID'));
    expect(aiRow, contains('AI Compatibility'));
    expect(aiRow, contains('separate future single-slice epochs'));

    final program = _source(
      'docs/agent/plans/2026-07-11-phone-complete-local-completion-program.md',
    );
    final doneRows = _markdownRows(program, 'Finite Phone Done Conditions');
    expect(
      doneRows.map((row) => row['Area']),
      equals([
        'Learning',
        'Species and plants',
        'Guided tools and timeline',
        'Content and rules',
        'Accessibility',
        'Visual assets and regression',
        'Motion and haptics',
        'Performance',
        'Final acceptance',
      ]),
    );
    _expectContainsAll(
      'docs/agent/plans/'
      '2026-07-11-phone-complete-local-completion-program.md',
      [
        '82 lessons',
        '75+ species',
        '40+ plants',
        'no mandatory asset-replacement or new-animation quota',
        'keyed-AI seed',
        'signing',
        'legal hosting',
        'public-history recovery',
      ],
    );
    for (final staleWorkflowText in [
      'Task 13',
      'explicit launch',
      'autonomous workflow setup',
      'rerun required clean-main proof',
    ]) {
      expect(program, isNot(contains(staleWorkflowText)));
    }

    final profileLines = authorityText
        .split('\n')
        .where(
          (line) =>
              line.contains('-Profile Focused') ||
              line.contains('-Profile Visual'),
        );
    for (final line in profileLines) {
      expect(
        line,
        contains('-FocusedTests'),
        reason: 'Focused and Visual examples require explicit paths: $line',
      );
    }

    final performance = _source('docs/agent/PERFORMANCE_TARGETS.md');
    expect(performance, contains('phone-only local completion boundary'));
    expect(performance, isNot(contains('Android tablet second')));
    expect(performance, isNot(contains('Firebase Test Lab')));

    final baselines = _source('docs/design/BASELINES.md');
    expect(
      baselines,
      contains(
        'docs/qa/screenshots/2026-07-04/'
        'cl-qa-001-phone-whole-app-map',
      ),
    );
    expect(baselines, isNot(contains('2026-05-18')));
    expect(authorityText, contains('March visual asset audit'));
    expect(
      authorityText,
      contains('historical evidence, not current defect authority'),
    );
  });

  test('product authority stays canonical while autonomy is frozen', () {
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
    expect(
      rows.singleWhere((row) => row['ID'] == 'DCL-DR-001')['Closure State'],
      'closed',
    );
    expect(
      rows.singleWhere((row) => row['ID'] == 'DCL-DR-002')['Closure State'],
      'closed',
    );

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
    final programFlat = program.replaceAll(RegExp(r'\s+'), ' ');
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
    expect(program, contains('Roadmap authority lock - E0'));
    expect(program, contains('DCL-DR-001-F2'));
    expect(program, contains('DCL-DR-001-F3'));
    expect(program, contains('DCL-DR-001-F4'));
    expect(program, contains('DCL-DR-001-F5'));
    expect(program, contains('DCL-DR-001-F6'));
    expect(program, contains('DCL-DR-002'));
    expect(program, contains('DCL-DR-002-F1'));
    expect(program, contains('DCL-DR-002-F2'));
    expect(program, contains('DCL-DR-002-F3'));
    expect(program, contains('DCL-DR-002-F4'));
    expect(program, contains('DCL-DR-002-F5'));
    expect(program, contains('DCL-DR-002-F6'));
    expect(program, contains('DCL-DR-002-F7'));
    expect(program, contains('DCL-DR-002-F8'));
    expect(
      program,
      contains(
        'danio-dcl-dr-002-recovery-copy-honesty-2026-07-16/1',
      ),
    );
    expect(
      program,
      contains(
        'danio-dcl-dr-002-start-fresh-scoped-deletion-proof-2026-07-16/1',
      ),
    );
    expect(
      program,
      contains('danio-dcl-dr-002-corrupt-json-retry-proof-2026-07-16/1'),
    );
    expect(
      program,
      contains(
        'danio-dcl-dr-002-start-fresh-cancel-back-proof-2026-07-16/1',
      ),
    );
    expect(
      program,
      contains(
        'danio-dcl-dr-002-start-fresh-failure-proof-2026-07-16/1',
      ),
    );
    expect(
      program,
      contains(
        'danio-dcl-dr-002-v0-preference-preservation-proof-2026-07-16/1',
      ),
    );
    expect(
      program,
      contains(
        'danio-dcl-dr-002-local-json-first-run-proof-2026-07-16/1',
      ),
    );
    expect(
      program,
      contains(
        'danio-dcl-dr-003-crud-undo-resilience-audit-2026-07-16/1',
      ),
    );
    expect(program, contains('closed'));
    expect(program, contains('open'));
    expect(programFlat, contains('current lean Verified Slice contract'));
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
        contains('DCL-DR-001'),
        contains('DCL-DR-002'),
        allOf(
          allOf(
            contains('DCL-DR-002-F1'),
            contains('DCL-DR-002-F2'),
            contains('DCL-DR-002-F3'),
            contains('DCL-DR-002-F4'),
          ),
          allOf(
            contains('DCL-DR-002-F5'),
            contains('DCL-DR-002-F6'),
            contains('DCL-DR-002-F7'),
            contains('DCL-DR-002-F8'),
          ),
        ),
        contains('next manual'),
        allOf(
          contains('locally fixed'),
          contains('locally verified'),
          contains('closed'),
        ),
        contains('crud-undo-resilience-audit'),
        allOf(
          isNot(contains('Task 13')),
          isNot(contains('explicit launch')),
        ),
      ),
    );
    expect(
      _markdownSection(ledger, 'Next Ledger Target Rule'),
      allOf(
        contains('DCL-DR-001'),
        contains('DCL-DR-002'),
        allOf(
          allOf(
            contains('DCL-DR-002-F1'),
            contains('DCL-DR-002-F2'),
            contains('DCL-DR-002-F3'),
            contains('DCL-DR-002-F4'),
          ),
          allOf(
            contains('DCL-DR-002-F5'),
            contains('DCL-DR-002-F6'),
            contains('DCL-DR-002-F7'),
            contains('DCL-DR-002-F8'),
          ),
        ),
        contains('next manual'),
        allOf(
          contains('locally fixed'),
          contains('locally verified'),
          contains('closed'),
        ),
        contains('crud-undo-resilience-audit'),
        allOf(
          isNot(contains('Task 13')),
          isNot(contains('explicit launch')),
        ),
      ),
    );
    expect(
      _markdownSection(finishMap, 'Evidence Recording Rule'),
      allOf(
        contains('once per epoch'),
        contains('one concise'),
        contains('only when'),
      ),
    );

    const liveStatePath =
        'docs/agent/autonomous_completion/phone_completion_run_state.json';
    final liveState =
        jsonDecode(_source(liveStatePath)) as Map<String, dynamic>;
    final transition = liveState['transition'] as Map<String, dynamic>;
    final authorization = liveState['authorization'] as Map<String, dynamic>;
    final cursor = liveState['cursor'] as Map<String, dynamic>;
    final liveBudget = liveState['budget'] as Map<String, dynamic>;
    final currentCharge = liveBudget['current_charge'] as Map<String, dynamic>;

    expect(liveState['document_type'], 'danio_phone_completion_run_state');
    expect(liveState['schema_version'], 1);
    expect(liveState['run_id'], 'danio-phone-complete-local-2026-07-11');
    expect(liveState['state_revision'], 2);
    expect(liveState['mode'], 'stopped');
    expect(transition['action'], 'preclaim_stop');
    expect(transition['from_mode'], 'ready');
    expect(transition['to_mode'], 'stopped');
    expect(transition['parent_state_revision'], 1);
    expect(
      transition['work_unit_id'],
      'DCL-DR-001-restore-matrix-audit',
    );
    expect(
      transition['reason_code'],
      'USER_REQUESTED_WORKFLOW_SIMPLIFICATION',
    );
    expect(
      liveState['stop_reason_code'],
      'USER_REQUESTED_WORKFLOW_SIMPLIFICATION',
    );
    expect(
      authorization['authorization_id'],
      'danio-phone-complete-local-2026-07-11',
    );
    expect(cursor['phase'], '1-data-resilience');
    expect(cursor['work_unit_id'], 'DCL-DR-001-restore-matrix-audit');
    expect(cursor['ledger_row_ids'], <String>['DCL-DR-001']);
    expect(liveState['owner'], isNull);
    expect(liveState['handoff_generation'], 0);
    expect(liveBudget['total_approved_units'], 20);
    expect(liveBudget['consumed_units'], 10);
    expect(liveBudget['remaining_units_including_current'], 10);
    expect(currentCharge['status'], 'none');
    expect(currentCharge['work_unit_id'], isNull);
    expect(currentCharge['claimed_revision'], isNull);
    expect(currentCharge['consumed_revision'], isNull);

    _expectContainsAll('docs/agent/ACTIVE_HANDOFF.md', [
      'manual lean workflow',
      'DCL-DR-001',
      'DCL-DR-001-F2',
      'DCL-DR-001-F3',
      'DCL-DR-001-F4',
      'DCL-DR-001-F5',
      'DCL-DR-001-F6',
      'DCL-DR-002',
      '`DCL-DR-001` is `closed`',
      '`DCL-DR-002` is `closed`',
      'DCL-DR-002-F1',
      'DCL-DR-002-F2',
      'DCL-DR-002-F3',
      'DCL-DR-002-F4',
      'DCL-DR-002-F5',
      'DCL-DR-002-F6',
      'DCL-DR-002-F7',
      'DCL-DR-002-F8',
      'DR-2026-07-16-022',
      'danio-dcl-dr-002-migration-corruption-recovery-audit-2026-07-16/1',
      'danio-dcl-dr-002-recovery-copy-honesty-2026-07-16/1',
      'danio-dcl-dr-002-corrupt-json-retry-proof-2026-07-16/1',
      'danio-dcl-dr-002-start-fresh-cancel-back-proof-2026-07-16/1',
      'danio-dcl-dr-002-start-fresh-scoped-deletion-proof-2026-07-16/1',
      'danio-dcl-dr-002-start-fresh-failure-proof-2026-07-16/1',
      'danio-dcl-dr-002-v0-preference-preservation-proof-2026-07-16/1',
      'danio-dcl-dr-002-local-json-first-run-proof-2026-07-16/1',
      'DCL-DR-003',
      '`DCL-DR-003` remains `open`',
      'DCL-DR-003-F1',
      'DCL-DR-003-F2',
      'DCL-DR-003-F3',
      'DCL-DR-003-F4',
      'DCL-DR-003-F5',
      'DCL-DR-003-F6',
      'DCL-DR-003-F7',
      'DCL-DR-003-F8',
      'DCL_DR_003_CRUD_UNDO_RESILIENCE_MATRIX.md',
      'danio-dcl-dr-003-crud-undo-resilience-audit-2026-07-16/1',
      'danio-dcl-dr-003-equipment-undo-rollback-proof-2026-07-16/1',
      'danio-dcl-dr-003-review-answer-persistence-proof-2026-07-16/1',
      'danio-dcl-dr-003-normal-lesson-gem-retry-proof-2026-07-16/1',
      'danio-dcl-dr-003-home-quick-feed-parent-preflight-proof-2026-07-16/1',
      'danio-dcl-dr-003-livestock-quick-feed-parent-preflight-proof-2026-07-16/1',
      'danio-dcl-dr-003-home-quick-water-parent-preflight-proof-2026-07-16/1',
      'danio-dcl-dr-003-task-delete-failure-proof-2026-07-16/1',
      'danio-dcl-dr-003-task-completion-stale-id-proof-2026-07-16/1',
      'locally fixed',
      'locally verified',
      'Next manual action',
      'Never create an automatic successor task.',
    ]);
    _expectContainsAll('docs/agent/autonomous_completion/README.md', [
      'FROZEN HISTORICAL WORKFLOW',
      'new explicit user request',
      'reconciliation plan',
    ]);
    _expectContainsAll('docs/agent/SLICE_LOG.md', [
      'DR-2026-07-16-001',
      'DR-2026-07-16-002',
      'DR-2026-07-16-003',
      'DR-2026-07-16-004',
      'DR-2026-07-16-005',
      'DR-2026-07-16-006',
      'DR-2026-07-16-007',
      'DR-2026-07-16-008',
      'DR-2026-07-16-009',
      'DR-2026-07-16-010',
      'DR-2026-07-16-011',
      'DR-2026-07-16-012',
      'DR-2026-07-16-013',
      'DR-2026-07-16-014',
      'DR-2026-07-16-015',
      'DR-2026-07-16-016',
      'DR-2026-07-16-017',
      'DR-2026-07-16-018',
      'DR-2026-07-16-019',
      'DR-2026-07-16-020',
      'DR-2026-07-16-021',
      'DR-2026-07-16-022',
      'DCL-DR-001',
      'DCL-DR-002',
      'danio-dcl-dr-001-restore-matrix-audit-2026-07-15/1',
      'danio-dcl-dr-001-export-share-outcome-2026-07-16/1',
      'danio-dcl-dr-001-file-selection-outcome-proof-2026-07-16/1',
      'danio-dcl-dr-001-confirmation-cancel-proof-2026-07-16/1',
      'danio-dcl-dr-001-tank-import-rollback-failure-proof-2026-07-16/1',
      'danio-dcl-dr-001-mid-extraction-cleanup-proof-2026-07-16/1',
      'danio-dcl-dr-002-migration-corruption-recovery-audit-2026-07-16/1',
      'danio-dcl-dr-002-recovery-copy-honesty-2026-07-16/1',
      'danio-dcl-dr-002-corrupt-json-retry-proof-2026-07-16/1',
      'danio-dcl-dr-002-start-fresh-cancel-back-proof-2026-07-16/1',
      'danio-dcl-dr-002-start-fresh-scoped-deletion-proof-2026-07-16/1',
      'danio-dcl-dr-002-start-fresh-failure-proof-2026-07-16/1',
      'danio-dcl-dr-002-v0-preference-preservation-proof-2026-07-16/1',
      'danio-dcl-dr-002-local-json-first-run-proof-2026-07-16/1',
      'danio-dcl-dr-003-crud-undo-resilience-audit-2026-07-16/1',
      'danio-dcl-dr-003-equipment-undo-rollback-proof-2026-07-16/1',
      'danio-dcl-dr-003-review-answer-persistence-proof-2026-07-16/1',
      'danio-dcl-dr-003-normal-lesson-gem-retry-proof-2026-07-16/1',
      'danio-dcl-dr-003-home-quick-feed-parent-preflight-proof-2026-07-16/1',
      'danio-dcl-dr-003-livestock-quick-feed-parent-preflight-proof-2026-07-16/1',
      'danio-dcl-dr-003-home-quick-water-parent-preflight-proof-2026-07-16/1',
      'danio-dcl-dr-003-task-delete-failure-proof-2026-07-16/1',
      'danio-dcl-dr-003-task-completion-stale-id-proof-2026-07-16/1',
    ]);
  });
}

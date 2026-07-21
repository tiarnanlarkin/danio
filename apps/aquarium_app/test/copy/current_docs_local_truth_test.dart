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

void _expectContainsAllAcross(
  Iterable<String> paths,
  Iterable<String> values,
) {
  final source = paths.map(_source).join('\n');
  for (final value in values) {
    expect(
      source,
      contains(value),
      reason: 'current evidence should preserve $value',
    );
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
      'docs/agent/plans/2026-07-19-phone-release-candidate-finalization-plan.md',
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
        '2026-07-19-phone-release-candidate-finalization-plan.md',
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
    _expectContainsAllAcross(
      [
        'docs/agent/ACTIVE_HANDOFF.md',
        'docs/agent/DCL_DR_001_RESTORE_BEHAVIOR_MATRIX.md',
        'docs/agent/DCL_DR_002_MIGRATION_CORRUPTION_RECOVERY_MATRIX.md',
        'docs/agent/DCL_DR_003_CRUD_UNDO_RESILIENCE_MATRIX.md',
        'docs/agent/SLICE_LOG.md',
        'docs/archive/agent-workflow-2026-07-16/SLICE_LOG-rolling-overflow.md',
      ],
      [
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
        'DR-2026-07-16-037',
        'DR-2026-07-18-039',
        'DR-2026-07-18-040',
        'DR-2026-07-18-041',
        'DR-2026-07-18-042',
        'DR-2026-07-18-043',
        'DR-2026-07-18-044',
        'danio-dcl-dr-002-migration-corruption-recovery-audit-2026-07-16/1',
        'danio-dcl-dr-002-recovery-copy-honesty-2026-07-16/1',
        'danio-dcl-dr-002-corrupt-json-retry-proof-2026-07-16/1',
        'danio-dcl-dr-002-start-fresh-cancel-back-proof-2026-07-16/1',
        'danio-dcl-dr-002-start-fresh-scoped-deletion-proof-2026-07-16/1',
        'danio-dcl-dr-002-start-fresh-failure-proof-2026-07-16/1',
        'danio-dcl-dr-002-v0-preference-preservation-proof-2026-07-16/1',
        'danio-dcl-dr-002-local-json-first-run-proof-2026-07-16/1',
        'DCL-DR-003',
        '`DCL-DR-003` is `closed`',
        'DCL-DR-003-F1',
        'DCL-DR-003-F2',
        'DCL-DR-003-F3',
        'DCL-DR-003-F4',
        'DCL-DR-003-F5',
        'DCL-DR-003-F6',
        'DCL-DR-003-F7',
        'DCL-DR-003-F8',
        'DCL-DR-003-F9',
        'DCL-DR-003-F10',
        'DCL-DR-003-F11',
        'DCL-DR-003-F12',
        'DCL-DR-003-F13',
        'DCL-DR-003-F14',
        'DCL-DR-003-F15',
        'DCL-DR-003-F16',
        'DCL-DR-003-F17',
        'DCL-DR-003-F18',
        'DCL-DR-003-F19',
        'DCL-DR-003-F20',
        'DCL-DR-003-F21',
        'DCL-DR-003-F22',
        'DCL-DR-003-F23',
        'DCL-DR-003-F24',
        'DCL-DR-003-F25',
        'DCL-DR-003-F26',
        'DCL-DR-003-F27',
        'DCL-DR-003-F28',
        'DCL-DR-003-F29',
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
        'danio-dcl-dr-003-task-completion-parent-preflight-proof-2026-07-16/1',
        'danio-dcl-dr-003-tank-detail-task-completion-stale-id-proof-2026-07-16/1',
        'danio-dcl-dr-003-tank-detail-task-completion-parent-preflight-proof-2026-07-16/1',
        'danio-dcl-dr-003-equipment-service-stale-id-proof-2026-07-16/1',
        'danio-dcl-dr-003-task-snooze-stale-id-proof-2026-07-16/1',
        'danio-dcl-dr-003-livestock-bulk-move-stale-id-proof-2026-07-16/1',
        'danio-dcl-dr-003-livestock-bulk-expiry-failure-feedback-2026-07-16/1',
        'danio-dcl-dr-003-wishlist-edit-stale-id-proof-2026-07-16/1',
        'danio-dcl-dr-003-wishlist-remove-stale-id-proof-2026-07-16/1',
        'danio-dcl-dr-003-local-shop-edit-stale-id-proof-2026-07-16/1',
        'danio-dcl-dr-003-local-shop-remove-stale-id-proof-2026-07-16/1',
        'danio-dcl-dr-003-wishlist-purchase-compensation-failure-feedback-2026-07-16/1',
        'danio-dcl-dr-003-cost-delete-stale-index-proof-2026-07-16/1',
        'danio-dcl-dr-003-review-completion-redundant-save-proof-2026-07-16/1',
        'danio-dcl-dr-003-gem-purchase-refund-failure-feedback-2026-07-16/1',
        'danio-dcl-dr-003-inventory-expired-cleanup-failure-feedback-2026-07-18/1',
        'danio-dcl-dr-003-achievement-unlock-reward-recovery-proof-2026-07-18/1',
        'danio-dcl-dr-003-next-finding-triage-2026-07-18/1',
        'danio-dcl-dr-003-task-completion-xp-failure-honesty-proof-2026-07-18/1',
        'danio-dcl-dr-003-next-finding-triage-2026-07-18/2',
        'danio-dcl-dr-003-livestock-bulk-add-rollback-uncertainty-proof-2026-07-18/1',
        'danio-dcl-dr-003-tank-create-rollback-uncertainty-proof-2026-07-18/1',
        'createTank preserves task-save and rollback failures when cleanup is uncertain',
        'failed tank-create rollback reports uncertainty and blocks duplicate retry',
        'stale tank-create retry cannot bypass uncertain persistence lock',
        'clean tank-create compensation retains safe Retry',
        'warns about uncertain persistence without Retry',
        'failed bulk-add rollback reports uncertainty and blocks duplicate retry',
        'stale bulk-add retry cannot bypass uncertain persistence lock',
        'expired item cleanup failure shows feedback without changing inventory',
      ],
    );
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
        'Status: closed - all current P0/P1 paths settled and Full passed',
        'danio-dcl-dr-003-crud-undo-resilience-audit-2026-07-16/1',
        'DR-2026-07-16-037',
        'DR-2026-07-18-039',
        'DR-2026-07-18-040',
        'DR-2026-07-18-041',
        'DR-2026-07-18-042',
        'DR-2026-07-18-043',
        'DR-2026-07-18-044',
        'DR-2026-07-18-045',
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
        'DCL-DR-003-F9',
        'stale task completion does not recreate a deleted task',
        'danio-dcl-dr-003-task-completion-parent-preflight-proof-2026-07-16/1',
        'DCL-DR-003-F10',
        'task completion rejects a missing parent before writing',
        'danio-dcl-dr-003-tank-detail-task-completion-stale-id-proof-2026-07-16/1',
        'DCL-DR-003-F11',
        'stale tank-detail equipment-task completion does not recreate task or service equipment',
        'danio-dcl-dr-003-tank-detail-task-completion-parent-preflight-proof-2026-07-16/1',
        'DCL-DR-003-F12',
        'tank-detail task completion rejects a missing parent before writing',
        'danio-dcl-dr-003-equipment-service-stale-id-proof-2026-07-16/1',
        'DCL-DR-003-F13',
        'stale equipment service does not recreate deleted equipment',
        'danio-dcl-dr-003-task-snooze-stale-id-proof-2026-07-16/1',
        'DCL-DR-003-F14',
        'stale task snooze does not recreate a deleted task',
        'danio-dcl-dr-003-livestock-bulk-move-stale-id-proof-2026-07-16/1',
        'DCL-DR-003-F15',
        'bulk move reports actual count when a selected livestock id is missing',
        'danio-dcl-dr-003-livestock-bulk-expiry-failure-feedback-2026-07-16/1',
        'DCL-DR-003-F16',
        'failed bulk removal expiry restores item with feedback',
        'danio-dcl-dr-003-wishlist-edit-stale-id-proof-2026-07-16/1',
        'DCL-DR-003-F17',
        'editing a stale wishlist item shows error instead of false success',
        'danio-dcl-dr-003-wishlist-remove-stale-id-proof-2026-07-16/1',
        'DCL-DR-003-F18',
        'deleting a stale wishlist item shows error instead of false success',
        'danio-dcl-dr-003-local-shop-edit-stale-id-proof-2026-07-16/1',
        'DCL-DR-003-F19',
        'editing a stale local shop shows error instead of false success',
        'danio-dcl-dr-003-local-shop-remove-stale-id-proof-2026-07-16/1',
        'DCL-DR-003-F20',
        'deleting a stale local shop shows error instead of false success',
        'danio-dcl-dr-003-wishlist-purchase-compensation-failure-feedback-2026-07-16/1',
        'DCL-DR-003-F21',
        'failed purchase compensation reports persisted purchase and missing budget update',
        'danio-dcl-dr-003-cost-delete-stale-index-proof-2026-07-16/1',
        'DCL-DR-003-F22',
        'rapid expense dismissals delete both expenses without stale-index failure',
        'danio-dcl-dr-003-review-completion-redundant-save-proof-2026-07-16/1',
        'DCL-DR-003-F23',
        'completeSession does not fail after durable count and streak when stats mirror rejects save',
        'danio-dcl-dr-003-gem-purchase-refund-failure-feedback-2026-07-16/1',
        'DCL-DR-003-F24',
        'DCL-DR-003-F25',
        'DCL-DR-003-F26',
        'DCL-DR-003-F27',
        'DCL-DR-003-F28',
        'DCL-DR-003-F29',
        'expired item cleanup failure shows feedback without changing inventory',
        'danio-dcl-dr-003-inventory-expired-cleanup-failure-feedback-2026-07-18/1',
        'danio-dcl-dr-003-achievement-unlock-reward-recovery-proof-2026-07-18/1',
        'danio-dcl-dr-003-task-completion-xp-failure-honesty-proof-2026-07-18/1',
        'danio-dcl-dr-003-next-finding-triage-2026-07-18/2',
        'danio-dcl-dr-003-livestock-bulk-add-rollback-uncertainty-proof-2026-07-18/1',
        'danio-dcl-dr-003-next-finding-triage-2026-07-18/3',
        'danio-dcl-dr-003-tank-create-rollback-uncertainty-proof-2026-07-18/1',
        'createTank preserves task-save and rollback failures when cleanup is uncertain',
        'failed tank-create rollback reports uncertainty and blocks duplicate retry',
        'stale tank-create retry cannot bypass uncertain persistence lock',
        'clean tank-create compensation retains safe Retry',
        'warns about uncertain persistence without Retry',
        'failed bulk-add rollback reports uncertainty and blocks duplicate retry',
        'stale bulk-add retry cannot bypass uncertain persistence lock',
        'profile activity failure does not report durable task completion as failed',
        'is locally fixed for `TasksScreen` only',
        'failed profile write leaves first lesson reward recoverable on retry',
        'failed gem cumulative write leaves first lesson reward recoverable after reload',
        'failed profile compensation surfaces both achievement reward errors',
        'failed gem rollback surfaces uncertainty without duplicate retry',
        'settled profile reward catches progress up silently after reload',
      ],
    );
  });

  test('phone release-candidate authority uses a finite P0/P1 selector', () {
    const plan =
        'docs/agent/plans/2026-07-19-phone-release-candidate-finalization-plan.md';
    expect(_exists(plan), isTrue, reason: '$plan must be current authority');
    final planSource = _source(plan);
    final flatPlan = planSource.replaceAll(RegExp(r'\s+'), ' ');

    _expectContainsAll(plan, [
      'danio-phone-rc-authority-reset-2026-07-19/1',
      'P0',
      'P1',
      'P2/P3',
      'ten planned product/test epochs',
      'danio_api36',
      'one repository-writing coordinator',
      'DCL-DR-003',
      'DCL-RC-001',
    ]);
    for (final contract in [
      'Deleted-livestock removal logs remain tombstone history',
      'User Optional-AI keys move to Android Keystore-backed secure storage',
      'accept a nonblank deleted livestock ID as an opaque tombstone',
      'Decline or dismissal writes no AI history; confirmation writes exactly once',
      'Failed migration retains the legacy value and reports an honest error',
      'No plaintext key may appear in preferences, logs, backups, errors, or diagnostics',
      'machine-readable product commit, device, scenario, samples, median/frame statistics, budget, and pass/fail',
      'APK SHA-256',
      'Do not begin another finding hunt or create a successor task',
    ]) {
      expect(
        flatPlan,
        contains(contract),
        reason: 'missing contract: $contract',
      );
    }
    const orderedEpochs = [
      '### 1. Tasks completion compensation',
      '### 2. Equipment Mark Serviced compensation',
      '### 3. Single livestock-add compensation',
      '### 4. Backup tombstone relationship',
      '### 5. Fish ID activity consent',
      '### 6. Compatibility activity consent',
      '### 7. Secure Optional-AI key storage',
      '### 8. Compatibility and calculation rule coverage',
      '### 9. Global haptic-preference enforcement',
      '### 10. Profile performance harness',
    ];
    var previousEpoch = -1;
    for (final epoch in orderedEpochs) {
      final index = planSource.indexOf(epoch);
      expect(index, greaterThan(previousEpoch), reason: 'epoch order: $epoch');
      previousEpoch = index;
    }
    for (final budget in [
      'cold start <= 2500 ms',
      'warm resume <= 1200 ms',
      'tab switch <= 300 ms',
      'tank feedback <= 16.667 ms average and <= 5% dropped frames',
      'main scrolling <= 20 ms average and <= 8% dropped frames',
      'local-image first paint <= 500 ms',
    ]) {
      expect(flatPlan, contains(budget), reason: 'missing budget: $budget');
    }
    for (final path in [
      'docs/agent/FINISH_MAP.md',
      'docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md',
      'docs/agent/ACTIVE_HANDOFF.md',
      'docs/agent/plans/2026-07-11-phone-complete-local-completion-program.md',
    ]) {
      _expectContainsAll(path, [
        '2026-07-19-phone-release-candidate-finalization-plan.md',
        'P0/P1 release selector',
        'P2/P3',
      ]);
    }
    for (final path in [
      'docs/agent/FINISH_MAP.md',
      'docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md',
    ]) {
      final source = _source(path);
      expect(
        source,
        contains(
          'Android Keystore-backed secure-storage migration remains active',
        ),
        reason: path,
      );
      expect(
        source,
        isNot(contains('API-key/provider expansion')),
        reason: path,
      );
    }
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
    expect(aiRow, contains('dismiss/cancel writes nothing'));

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
    expect(programFlat, contains('no longer selects work'));
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
    expect(program, contains('Superseded ordered authority'));
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
          contains('DCL-DR-003-F1'),
          contains('DCL-DR-003-F34'),
          contains('DCL-DR-003'),
          contains('DCL-DR-004'),
        ),
        allOf(
          contains('P0/P1 release selector'),
          contains('DCL-DR-003-F38'),
          contains('DCL-DR-003` is closed'),
          contains('DCL-DR-004` is next'),
        ),
        allOf(
          isNot(contains('Task 13')),
          isNot(contains('explicit launch')),
        ),
      ),
    );
    expect(
      _markdownSection(ledger, 'Next Ledger Target Rule'),
      allOf(
        allOf(
          contains('DCL-DR-003'),
          contains('next manual'),
          contains('F1 through F38'),
          contains('DCL-DR-004` is the next'),
        ),
        allOf(
          contains('DCL-DR-004'),
          contains('2026-07-19-phone-release-candidate-finalization-plan.md'),
        ),
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

    _expectContainsAllAcross(
      [
        'docs/agent/ACTIVE_HANDOFF.md',
        'docs/agent/DCL_DR_001_RESTORE_BEHAVIOR_MATRIX.md',
        'docs/agent/DCL_DR_002_MIGRATION_CORRUPTION_RECOVERY_MATRIX.md',
        'docs/agent/DCL_DR_003_CRUD_UNDO_RESILIENCE_MATRIX.md',
        'docs/agent/SLICE_LOG.md',
        'docs/archive/agent-workflow-2026-07-16/SLICE_LOG-rolling-overflow.md',
      ],
      [
        'user-directed manual phone RC chain',
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
        'DR-2026-07-16-037',
        'DR-2026-07-18-039',
        'DR-2026-07-18-040',
        'DR-2026-07-18-041',
        'DR-2026-07-18-042',
        'DR-2026-07-18-043',
        'DR-2026-07-18-044',
        'DR-2026-07-18-045',
        'danio-dcl-dr-002-migration-corruption-recovery-audit-2026-07-16/1',
        'danio-dcl-dr-002-recovery-copy-honesty-2026-07-16/1',
        'danio-dcl-dr-002-corrupt-json-retry-proof-2026-07-16/1',
        'danio-dcl-dr-002-start-fresh-cancel-back-proof-2026-07-16/1',
        'danio-dcl-dr-002-start-fresh-scoped-deletion-proof-2026-07-16/1',
        'danio-dcl-dr-002-start-fresh-failure-proof-2026-07-16/1',
        'danio-dcl-dr-002-v0-preference-preservation-proof-2026-07-16/1',
        'danio-dcl-dr-002-local-json-first-run-proof-2026-07-16/1',
        'DCL-DR-003',
        '`DCL-DR-003` is `closed`',
        'DCL-DR-003-F1',
        'DCL-DR-003-F2',
        'DCL-DR-003-F3',
        'DCL-DR-003-F4',
        'DCL-DR-003-F5',
        'DCL-DR-003-F6',
        'DCL-DR-003-F7',
        'DCL-DR-003-F8',
        'DCL-DR-003-F9',
        'DCL-DR-003-F10',
        'DCL-DR-003-F11',
        'DCL-DR-003-F12',
        'DCL-DR-003-F13',
        'DCL-DR-003-F14',
        'DCL-DR-003-F15',
        'DCL-DR-003-F16',
        'DCL-DR-003-F17',
        'DCL-DR-003-F18',
        'DCL-DR-003-F19',
        'DCL-DR-003-F20',
        'DCL-DR-003-F21',
        'DCL-DR-003-F22',
        'DCL-DR-003-F23',
        'DCL-DR-003-F24',
        'DCL-DR-003-F25',
        'DCL-DR-003-F26',
        'DCL-DR-003-F27',
        'DCL-DR-003-F28',
        'DCL-DR-003-F29',
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
        'danio-dcl-dr-003-task-completion-parent-preflight-proof-2026-07-16/1',
        'danio-dcl-dr-003-tank-detail-task-completion-stale-id-proof-2026-07-16/1',
        'danio-dcl-dr-003-tank-detail-task-completion-parent-preflight-proof-2026-07-16/1',
        'danio-dcl-dr-003-equipment-service-stale-id-proof-2026-07-16/1',
        'danio-dcl-dr-003-task-snooze-stale-id-proof-2026-07-16/1',
        'danio-dcl-dr-003-livestock-bulk-move-stale-id-proof-2026-07-16/1',
        'danio-dcl-dr-003-livestock-bulk-expiry-failure-feedback-2026-07-16/1',
        'danio-dcl-dr-003-wishlist-edit-stale-id-proof-2026-07-16/1',
        'danio-dcl-dr-003-wishlist-remove-stale-id-proof-2026-07-16/1',
        'danio-dcl-dr-003-local-shop-edit-stale-id-proof-2026-07-16/1',
        'danio-dcl-dr-003-local-shop-remove-stale-id-proof-2026-07-16/1',
        'danio-dcl-dr-003-wishlist-purchase-compensation-failure-feedback-2026-07-16/1',
        'danio-dcl-dr-003-cost-delete-stale-index-proof-2026-07-16/1',
        'danio-dcl-dr-003-review-completion-redundant-save-proof-2026-07-16/1',
        'danio-dcl-dr-003-gem-purchase-refund-failure-feedback-2026-07-16/1',
        'danio-dcl-dr-003-inventory-expired-cleanup-failure-feedback-2026-07-18/1',
        'danio-dcl-dr-003-achievement-unlock-reward-recovery-proof-2026-07-18/1',
        'danio-dcl-dr-003-next-finding-triage-2026-07-18/1',
        'danio-dcl-dr-003-task-completion-xp-failure-honesty-proof-2026-07-18/1',
        'danio-dcl-dr-003-next-finding-triage-2026-07-18/2',
        'danio-dcl-dr-003-livestock-bulk-add-rollback-uncertainty-proof-2026-07-18/1',
        'danio-dcl-dr-003-next-finding-triage-2026-07-18/3',
        'danio-dcl-dr-003-tank-create-rollback-uncertainty-proof-2026-07-18/1',
        'createTank preserves task-save and rollback failures when cleanup is uncertain',
        'failed tank-create rollback reports uncertainty and blocks duplicate retry',
        'stale tank-create retry cannot bypass uncertain persistence lock',
        'clean tank-create compensation retains safe Retry',
        'warns about uncertain persistence without Retry',
        'failed bulk-add rollback reports uncertainty and blocks duplicate retry',
        'stale bulk-add retry cannot bypass uncertain persistence lock',
        'expired item cleanup failure shows feedback without changing inventory',
        'Next manual action',
        'Never create an automatic successor task.',
      ],
    );
    _expectContainsAll('docs/agent/autonomous_completion/README.md', [
      'FROZEN HISTORICAL WORKFLOW',
      'new explicit user request',
      'reconciliation plan',
    ]);
    _expectContainsAllAcross(
      [
        'docs/agent/SLICE_LOG.md',
        'docs/archive/agent-workflow-2026-07-16/SLICE_LOG-rolling-overflow.md',
      ],
      [
        'DR-2026-07-19-057',
        'DR-2026-07-19-056',
        'DR-2026-07-16-016',
        'DR-2026-07-16-017',
        'DR-2026-07-16-018',
        'DR-2026-07-16-022',
        'DR-2026-07-16-023',
        'DR-2026-07-16-024',
        'DR-2026-07-16-025',
        'DR-2026-07-16-026',
        'DR-2026-07-16-027',
        'DR-2026-07-16-028',
        'DR-2026-07-16-030',
        'DR-2026-07-16-033',
        'DR-2026-07-16-034',
        'DR-2026-07-16-035',
        'DR-2026-07-16-036',
        'DR-2026-07-16-037',
        'DR-2026-07-18-038',
        'DR-2026-07-18-039',
        'DR-2026-07-18-040',
        'DR-2026-07-18-041',
        'DR-2026-07-18-042',
        'DR-2026-07-18-043',
        'DR-2026-07-18-044',
        'DR-2026-07-18-045',
        'DR-2026-07-18-046',
        'DCL-DR-001',
        'DCL-DR-002',
        'DCL-DR-003-F13',
        'DCL-DR-003-F14',
        'DCL-DR-003-F16',
        'DCL-DR-003-F17',
        'DCL-DR-003-F18',
        'DCL-DR-003-F19',
        'DCL-DR-003-F20',
        'DCL-DR-003-F21',
        'DCL-DR-003-F22',
        'DCL-DR-003-F23',
        'DCL-DR-003-F24',
        'DCL-DR-003-F25',
        'DCL-DR-003-F26',
        'DCL-DR-003-F27',
        'DCL-DR-003-F28',
        'DCL-DR-003-F29',
        'DCL-DR-003-F34',
        'danio-dcl-dr-002-local-json-first-run-proof-2026-07-16/1',
        'danio-dcl-dr-003-crud-undo-resilience-audit-2026-07-16/1',
        'danio-dcl-dr-003-equipment-undo-rollback-proof-2026-07-16/1',
        'danio-dcl-dr-003-review-answer-persistence-proof-2026-07-16/1',
        'danio-dcl-dr-003-normal-lesson-gem-retry-proof-2026-07-16/1',
        'danio-dcl-dr-003-home-quick-feed-parent-preflight-proof-2026-07-16/1',
        'danio-dcl-dr-003-home-quick-water-parent-preflight-proof-2026-07-16/1',
        'danio-dcl-dr-003-task-delete-failure-proof-2026-07-16/1',
        'danio-dcl-dr-003-task-completion-stale-id-proof-2026-07-16/1',
        'danio-dcl-dr-003-task-completion-parent-preflight-proof-2026-07-16/1',
        'danio-dcl-dr-003-tank-detail-task-completion-stale-id-proof-2026-07-16/1',
        'danio-dcl-dr-003-tank-detail-task-completion-parent-preflight-proof-2026-07-16/1',
        'danio-dcl-dr-003-equipment-service-stale-id-proof-2026-07-16/1',
        'danio-dcl-dr-003-task-snooze-stale-id-proof-2026-07-16/1',
        'danio-dcl-dr-003-livestock-bulk-expiry-failure-feedback-2026-07-16/1',
        'danio-dcl-dr-003-wishlist-edit-stale-id-proof-2026-07-16/1',
        'danio-dcl-dr-003-wishlist-remove-stale-id-proof-2026-07-16/1',
        'danio-dcl-dr-003-local-shop-edit-stale-id-proof-2026-07-16/1',
        'danio-dcl-dr-003-local-shop-remove-stale-id-proof-2026-07-16/1',
        'danio-dcl-dr-003-wishlist-purchase-compensation-failure-feedback-2026-07-16/1',
        'danio-dcl-dr-003-cost-delete-stale-index-proof-2026-07-16/1',
        'danio-dcl-dr-003-review-completion-redundant-save-proof-2026-07-16/1',
        'danio-dcl-dr-003-gem-purchase-refund-failure-feedback-2026-07-16/1',
        'danio-dcl-dr-003-inventory-expired-cleanup-failure-feedback-2026-07-18/1',
        'danio-dcl-dr-003-achievement-unlock-reward-recovery-proof-2026-07-18/1',
        'danio-dcl-dr-003-next-finding-triage-2026-07-18/1',
        'danio-dcl-dr-003-task-completion-xp-failure-honesty-proof-2026-07-18/1',
        'danio-dcl-dr-003-next-finding-triage-2026-07-18/2',
        'danio-dcl-dr-003-livestock-bulk-add-rollback-uncertainty-proof-2026-07-18/1',
        'danio-dcl-dr-003-next-finding-triage-2026-07-18/3',
        'danio-dcl-dr-003-tank-create-rollback-uncertainty-proof-2026-07-18/1',
        'danio-dcl-dr-003-tank-detail-task-completion-rollback-uncertainty-proof-2026-07-19/1',
      ],
    );
    final currentSliceRows = _source('docs/agent/SLICE_LOG.md')
        .split('\n')
        .where((line) => line.startsWith('| DR-') || line.startsWith('| WF-'))
        .toList();
    expect(currentSliceRows, hasLength(25));
    expect(
      currentSliceRows.where(
        (line) => line.startsWith('| DR-2026-07-19-057 |'),
      ),
      hasLength(1),
    );
    expect(
      currentSliceRows.any(
        (line) => line.startsWith('| DR-2026-07-16-032 |'),
      ),
      isFalse,
    );
    _expectContainsAll(
      'docs/archive/agent-workflow-2026-07-16/SLICE_LOG-rolling-overflow.md',
      [
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
        'DR-2026-07-16-029',
        'DR-2026-07-16-030',
        'DR-2026-07-16-031',
        'DR-2026-07-16-032',
        'DCL-DR-003-F15',
        'DCL-DR-003-F16',
        'DCL-DR-003-F17',
        'danio-dcl-dr-003-livestock-bulk-move-stale-id-proof-2026-07-16/1',
        'danio-dcl-dr-003-livestock-bulk-expiry-failure-feedback-2026-07-16/1',
        'danio-dcl-dr-003-wishlist-edit-stale-id-proof-2026-07-16/1',
        'WF-2026-07-15-019',
        'DCL-DR-003-F2',
        'DCL-DR-003-F3',
        'DCL-DR-003-F4',
        'DCL-DR-003-F6',
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
        'danio-dcl-dr-003-equipment-undo-rollback-proof-2026-07-16/1',
        'danio-dcl-dr-003-review-answer-persistence-proof-2026-07-16/1',
        'danio-dcl-dr-003-normal-lesson-gem-retry-proof-2026-07-16/1',
        'danio-dcl-dr-003-livestock-quick-feed-parent-preflight-proof-2026-07-16/1',
      ],
    );
  });

  test('DCL-DR-003 records the fixed F30 rollback-uncertainty epoch', () {
    const fixedFindingTruth = [
      'DR-2026-07-19-048',
      'DCL-DR-003-F30',
      'danio-dcl-dr-003-equipment-add-rollback-uncertainty-proof-2026-07-19/1',
      'EquipmentAddCompensationException',
      'failed maintenance-task sync rolls back new equipment',
      'failed equipment-add rollback reports uncertainty and blocks duplicate retry',
      'stale equipment-add retry cannot bypass uncertain persistence lock',
      'clean equipment-add compensation retains safe Retry',
      'DCL-DR-003 remains open',
    ];

    _expectContainsAll(
      'docs/agent/DCL_DR_003_CRUD_UNDO_RESILIENCE_MATRIX.md',
      fixedFindingTruth,
    );
    _expectContainsAll('docs/agent/SLICE_LOG.md', fixedFindingTruth);
  });

  test('DCL-DR-003 records the fixed F31 equipment-delete uncertainty epoch', () {
    const fixedFindingTruth = [
      'DR-2026-07-19-050',
      'DCL-DR-003-F31',
      'danio-dcl-dr-003-equipment-delete-rollback-uncertainty-proof-2026-07-19/1',
      'failed maintenance-task deletion keeps equipment saved',
      'failed equipment-delete rollback reports orphan uncertainty',
      'EquipmentDeleteCompensationException',
      'equipment is gone',
      'maintenance task may remain',
      'DCL-DR-003 remains open',
    ];

    _expectContainsAll(
      'docs/agent/DCL_DR_003_CRUD_UNDO_RESILIENCE_MATRIX.md',
      fixedFindingTruth,
    );
    _expectContainsAll('docs/agent/SLICE_LOG.md', fixedFindingTruth);
  });

  test('DCL-DR-003 ranks only F32 livestock bulk-move uncertainty', () {
    const rankedFindingTruth = [
      'DR-2026-07-19-051',
      'DCL-DR-003-F32',
      'danio-dcl-dr-003-next-finding-triage-2026-07-18/6',
      'rolls back earlier moves when a later save fails',
      'bulk move preserves initiating and rollback failures when compensation is uncertain',
      'failed bulk-move rollback reports partial-move uncertainty without unsafe retry',
      'DCL-DR-003 remains open',
    ];

    _expectContainsAll(
      'docs/agent/DCL_DR_003_CRUD_UNDO_RESILIENCE_MATRIX.md',
      rankedFindingTruth,
    );
    _expectContainsAll(
      'docs/agent/DCL_DR_003_CRUD_UNDO_RESILIENCE_MATRIX.md',
      [
        'ranked only in `DR-2026-07-19-051`',
        'remain outside',
      ],
    );
    _expectContainsAll('docs/agent/SLICE_LOG.md', rankedFindingTruth);
    _expectContainsAll('docs/agent/SLICE_LOG.md', [
      'Ranked only `DCL-DR-003-F32`',
      'livestock save failed',
      'livestock rollback failed',
      'No closure/successor',
    ]);
  });

  test('DCL-DR-003 records the fixed F32 livestock bulk-move uncertainty epoch', () {
    const fixedFindingTruth = [
      'DR-2026-07-19-052',
      'DCL-DR-003-F32',
      'danio-dcl-dr-003-livestock-bulk-move-rollback-uncertainty-proof-2026-07-19/1',
      'LivestockBulkMoveCompensationException',
      'rolls back earlier moves when a later save fails',
      'bulk move preserves initiating and rollback failures when compensation is uncertain',
      'failed bulk-move rollback reports partial-move uncertainty without unsafe retry',
      'source and target tank and livestock authority',
      'DCL-DR-003 remains open',
    ];

    _expectContainsAll(
      'docs/agent/DCL_DR_003_CRUD_UNDO_RESILIENCE_MATRIX.md',
      fixedFindingTruth,
    );
    _expectContainsAll('docs/agent/SLICE_LOG.md', fixedFindingTruth);
  });

  test('DCL-DR-003 ranks only F33 inventory-use compensation uncertainty', () {
    const rankedFindingTruth = [
      'DR-2026-07-19-053',
      'DCL-DR-003-F33',
      'danio-dcl-dr-003-next-finding-triage-2026-07-19/7',
      'useItem surfaces inventory save failures before applying profile effect',
      'failed item use shows retry feedback and keeps the item visible',
      'useItem preserves effect and rollback failures when inventory restore is uncertain',
      'failed consumable rollback reports lost-item uncertainty without unsafe retry',
      'DCL-DR-003 remains open',
    ];

    _expectContainsAll(
      'docs/agent/DCL_DR_003_CRUD_UNDO_RESILIENCE_MATRIX.md',
      rankedFindingTruth,
    );
    _expectContainsAll('docs/agent/SLICE_LOG.md', rankedFindingTruth);
    _expectContainsAll(
      'docs/agent/DCL_DR_003_CRUD_UNDO_RESILIENCE_MATRIX.md',
      [
        'ranked only in `DR-2026-07-19-053`',
        'every inventory-restore failure/stack',
        'remain outside',
      ],
    );
    _expectContainsAll('docs/agent/SLICE_LOG.md', [
      'Ranked only `DCL-DR-003-F33`',
      'profile effect failed',
      'inventory rollback failed',
      'No closure/successor',
    ]);
  });

  test('DCL-DR-003 records the fixed F33 inventory-use uncertainty epoch', () {
    const fixedFindingTruth = [
      'DR-2026-07-19-054',
      'DCL-DR-003-F33',
      'danio-dcl-dr-003-inventory-use-rollback-uncertainty-proof-2026-07-19/1',
      'InventoryUseCompensationException',
      'useItem preserves effect and rollback failures when inventory restore is uncertain',
      'useItem restores inventory after profile effect failure when compensation succeeds',
      'failed consumable rollback reports lost-item uncertainty without unsafe retry',
      'inventory and profile authority',
      'DCL-DR-003 remains open',
    ];

    _expectContainsAll(
      'docs/agent/DCL_DR_003_CRUD_UNDO_RESILIENCE_MATRIX.md',
      fixedFindingTruth,
    );
    _expectContainsAll('docs/agent/SLICE_LOG.md', fixedFindingTruth);
  });

  test(
    'DCL-DR-003 preserves the single F34 ranking history',
    () {
      const sharedFindingTruth = [
        'DR-2026-07-19-055',
        'DCL-DR-003-F34',
        'danio-dcl-dr-003-next-finding-triage-2026-07-19/8',
        'failed tank-detail task rollback reports uncertain completion without unsafe retry',
        'danio-dcl-dr-003-tank-detail-task-completion-rollback-uncertainty-proof-2026-07-19/1',
      ];
      const settledBoundaryTruth = [
        'failed completion log write rolls back task completion',
        'DCL-DR-003 remains open',
      ];

      final matrixSource = _source(
        'docs/agent/DCL_DR_003_CRUD_UNDO_RESILIENCE_MATRIX.md',
      );
      const matrixRecordStart =
          'Fresh current matrix, source, and executable-test inspection in\n'
          '`DR-2026-07-19-055`';
      final matrixStart = matrixSource.indexOf(matrixRecordStart);
      expect(matrixStart, greaterThanOrEqualTo(0));
      final matrixEnd = matrixSource.indexOf(
        '\nImplementation epoch `DR-2026-07-19-058`',
        matrixStart,
      );
      expect(matrixEnd, greaterThan(matrixStart));
      final matrixRecord = matrixSource.substring(matrixStart, matrixEnd);
      final sliceLogRecord = _source('docs/agent/SLICE_LOG.md')
          .split('\n')
          .singleWhere((line) => line.startsWith('| DR-2026-07-19-055 |'));
      String normalized(String value) => value.replaceAll(RegExp(r'\s+'), ' ');

      for (final entry in <(String, String)>[
        ('DCL-DR-003 epoch 055 narrative', matrixRecord),
        ('SLICE_LOG epoch 055 row', sliceLogRecord),
      ]) {
        for (final value in sharedFindingTruth) {
          expect(
            normalized(entry.$2),
            contains(value),
            reason: '${entry.$1}: $value',
          );
        }
        final findingIds = RegExp(
          r'DCL-DR-003-F\d+',
        ).allMatches(entry.$2).map((match) => match.group(0)).toSet();
        expect(
          findingIds,
          equals({'DCL-DR-003-F34'}),
          reason: '${entry.$1} must rank exactly one finding',
        );
      }

      for (final value in settledBoundaryTruth) {
        expect(
          normalized(matrixRecord),
          contains(value),
          reason: 'matrix: $value',
        );
        expect(
          normalized(sliceLogRecord),
          contains(value),
          reason: 'slice log: $value',
        );
      }
      expect(normalized(matrixRecord), contains('task completion log failed'));
      expect(normalized(matrixRecord), contains('task rollback failed'));
      expect(
        normalized(matrixRecord),
        contains('completion count reached two'),
      );
      expect(sliceLogRecord, contains('completion count reached two'));
      expect(sliceLogRecord, contains('probe removed'));
      expect(sliceLogRecord, contains('No closure/successor'));
    },
  );

  test('DCL-DR-003 records the fixed F34 Tank Detail uncertainty epoch', () {
    const fixedFindingTruth = [
      'DR-2026-07-19-056',
      'DCL-DR-003-F34',
      'danio-dcl-dr-003-tank-detail-task-completion-rollback-uncertainty-proof-2026-07-19/1',
      'TankDetailTaskCompletionCompensationException',
      'failed tank-detail task rollback reports uncertain completion without unsafe retry',
      'failed completion log write rolls back task completion',
      'one durable completion',
      'both causes with task/tank context',
      'task, equipment, and log authority refreshes',
      'visible and stale completion callbacks',
      'no success, Retry, or `Try again`',
      'DCL-DR-003 remains open',
      'no second finding',
    ];
    _expectContainsAll(
      'docs/agent/DCL_DR_003_CRUD_UNDO_RESILIENCE_MATRIX.md',
      fixedFindingTruth,
    );
    _expectContainsAll('docs/agent/SLICE_LOG.md', fixedFindingTruth);
    _expectContainsAll('docs/agent/ACTIVE_HANDOFF.md', [
      'F34 is complete',
      'reopen without contradictory live evidence',
      'Tasks completion compensation',
      'Never create an automatic successor task.',
    ]);
  });

  test('DCL-DR-003 records only the fixed F35 Tasks uncertainty epoch', () {
    const fixedFindingTruth = [
      'DR-2026-07-19-058',
      'DCL-DR-003-F35',
      'danio-dcl-dr-003-tasks-completion-rollback-uncertainty-proof-2026-07-19/1',
      'TasksScreenTaskCompletionCompensationException',
      'failed Tasks task rollback reports uncertain completion without unsafe retry',
      'in-flight task completion ignores a repeated stale callback',
      'uncertain completion reloads authority after leaving Tasks',
      'one durable completion',
      'both errors and task/tank context',
      'tank, task, equipment, recent-log, and full-log authority',
      'in-flight, visible, and stale completion callbacks',
      'no success, Retry, or `Try again`',
      'DCL-DR-003 remains open',
      'Equipment Mark Serviced compensation next',
      'no second finding',
    ];
    const sliceLogTruth = [
      'DR-2026-07-19-058',
      'DCL-DR-003-F35',
      'danio-dcl-dr-003-tasks-completion-rollback-uncertainty-proof-2026-07-19/1',
      'TasksScreenTaskCompletionCompensationException',
      'failed Tasks task rollback reports uncertain completion without unsafe retry',
      'uncertain completion reloads authority after leaving Tasks',
      'one durable completion',
      'DCL-DR-003 remains open',
      'Equipment Mark Serviced compensation next',
      'no second finding',
    ];

    final matrixSource = _source(
      'docs/agent/DCL_DR_003_CRUD_UNDO_RESILIENCE_MATRIX.md',
    );
    const matrixRecordStart = 'Implementation epoch `DR-2026-07-19-058`';
    final matrixStart = matrixSource.indexOf(matrixRecordStart);
    expect(matrixStart, greaterThanOrEqualTo(0));
    final matrixEnd = matrixSource.indexOf(
      '\nImplementation epoch `DR-2026-07-19-059`',
      matrixStart,
    );
    expect(matrixEnd, greaterThan(matrixStart));
    final matrixRecord = matrixSource.substring(matrixStart, matrixEnd);
    final sliceLogRecord = _source('docs/agent/SLICE_LOG.md')
        .split('\n')
        .singleWhere((line) => line.startsWith('| DR-2026-07-19-058 |'));

    final normalizedMatrix = matrixRecord.replaceAll(RegExp(r'\s+'), ' ');
    for (final value in fixedFindingTruth) {
      expect(
        normalizedMatrix,
        contains(value),
        reason: 'DCL-DR-003 epoch 058 narrative: $value',
      );
    }
    final normalizedLog = sliceLogRecord.replaceAll(RegExp(r'\s+'), ' ');
    for (final value in sliceLogTruth) {
      expect(
        normalizedLog,
        contains(value),
        reason: 'SLICE_LOG epoch 058 row: $value',
      );
    }
    for (final entry in <(String, String)>[
      ('DCL-DR-003 epoch 058 narrative', matrixRecord),
      ('SLICE_LOG epoch 058 row', sliceLogRecord),
    ]) {
      final findingIds = RegExp(
        r'DCL-DR-003-F\d+',
      ).allMatches(entry.$2).map((match) => match.group(0)).toSet();
      expect(
        findingIds,
        equals({'DCL-DR-003-F35'}),
        reason: '${entry.$1} must record exactly one finding',
      );
    }
  });

  test('DCL-DR-003 records only the fixed F36 Equipment service epoch', () {
    const fixedFindingTruth = [
      'DR-2026-07-19-059',
      'DCL-DR-003-F36',
      'danio-dcl-dr-003-equipment-service-rollback-uncertainty-proof-2026-07-19/1',
      'EquipmentServiceCompensationException',
      'failed service log rollback reports uncertain service without unsafe retry',
      'in-flight equipment service ignores a repeated stale callback',
      'uncertain equipment service reloads authority after leaving Equipment',
      'failed service task rollback reports uncertain service without unsafe retry',
      'Attempted service and task log IDs are compensated',
      'zero residual service history rows after route re-entry',
      'all rollback errors and stacks',
      'equipment, tank, task, and log identifiers',
      'Tank, equipment, task, recent-log, and full-log authority',
      'in-flight, visible, and stale Mark Serviced callbacks',
      'no success, Retry, or `Try again`',
      'DCL-DR-003 remains open',
      'single livestock-add compensation next',
      'no second finding',
    ];
    const sliceLogTruth = [
      'DR-2026-07-19-059',
      'DCL-DR-003-F36',
      'danio-dcl-dr-003-equipment-service-rollback-uncertainty-proof-2026-07-19/1',
      'EquipmentServiceCompensationException',
      'failed service log rollback reports uncertain service without unsafe retry',
      'failed service task rollback reports uncertain service without unsafe retry',
      'zero residual service history rows after route re-entry',
      'DCL-DR-003 remains open',
      'single livestock-add compensation next',
      'no second finding',
    ];

    final matrixSource = _source(
      'docs/agent/DCL_DR_003_CRUD_UNDO_RESILIENCE_MATRIX.md',
    );
    const matrixRecordStart = 'Implementation epoch `DR-2026-07-19-059`';
    final matrixStart = matrixSource.indexOf(matrixRecordStart);
    expect(matrixStart, greaterThanOrEqualTo(0));
    final matrixEnd = matrixSource.indexOf(
      '\nImplementation epoch `DR-2026-07-19-060`',
      matrixStart,
    );
    expect(matrixEnd, greaterThan(matrixStart));
    final matrixRecord = matrixSource.substring(matrixStart, matrixEnd);
    final sliceLogRecord = _source('docs/agent/SLICE_LOG.md')
        .split('\n')
        .singleWhere((line) => line.startsWith('| DR-2026-07-19-059 |'));

    final normalizedMatrix = matrixRecord.replaceAll(RegExp(r'\s+'), ' ');
    for (final value in fixedFindingTruth) {
      expect(
        normalizedMatrix,
        contains(value),
        reason: 'DCL-DR-003 epoch 059 narrative: $value',
      );
    }
    final normalizedLog = sliceLogRecord.replaceAll(RegExp(r'\s+'), ' ');
    for (final value in sliceLogTruth) {
      expect(
        normalizedLog,
        contains(value),
        reason: 'SLICE_LOG epoch 059 row: $value',
      );
    }
    for (final entry in <(String, String)>[
      ('DCL-DR-003 epoch 059 narrative', matrixRecord),
      ('SLICE_LOG epoch 059 row', sliceLogRecord),
    ]) {
      final findingIds = RegExp(
        r'DCL-DR-003-F\d+',
      ).allMatches(entry.$2).map((match) => match.group(0)).toSet();
      expect(
        findingIds,
        equals({'DCL-DR-003-F36'}),
        reason: '${entry.$1} must record exactly one finding',
      );
    }
  });

  test('DCL-DR-003 records only the fixed F37 single livestock-add epoch', () {
    const fixedFindingTruth = [
      'DR-2026-07-19-060',
      'DCL-DR-003-F37',
      'danio-dcl-dr-003-single-livestock-add-rollback-uncertainty-proof-2026-07-19/1',
      'LivestockAddCompensationException',
      'failed single-add log and deletion rollback preserves uncertain id and blocks repeated submit',
      'in-flight single-add ignores a repeated stale callback',
      'stale single-add Retry is ignored after sheet dismissal',
      'initiating error and stack',
      'all rollback errors and stacks',
      'tank, livestock, and activity-log identifiers',
      'tank, livestock, recent-log, and full-log authority',
      'no success or unsafe Retry',
      'DCL-DR-003 remains open',
      'Wishlist replay probe next',
      'no second finding',
    ];
    const sliceLogTruth = [
      'DR-2026-07-19-060',
      'DCL-DR-003-F37',
      'danio-dcl-dr-003-single-livestock-add-rollback-uncertainty-proof-2026-07-19/1',
      'LivestockAddCompensationException',
      'failed single-add log and deletion rollback preserves uncertain id and blocks repeated submit',
      'in-flight single-add ignores a repeated stale callback',
      'stale single-add Retry is ignored after sheet dismissal',
      'DCL-DR-003 remains open',
      'Wishlist replay probe next',
      'no second finding',
    ];

    final matrixSource = _source(
      'docs/agent/DCL_DR_003_CRUD_UNDO_RESILIENCE_MATRIX.md',
    );
    const matrixRecordStart = 'Implementation epoch `DR-2026-07-19-060`';
    final matrixStart = matrixSource.indexOf(matrixRecordStart);
    expect(matrixStart, greaterThanOrEqualTo(0));
    final matrixEnd = matrixSource.indexOf(
      '\nImplementation epoch `DR-2026-07-21-062`',
      matrixStart,
    );
    expect(matrixEnd, greaterThan(matrixStart));
    final matrixRecord = matrixSource.substring(matrixStart, matrixEnd);
    final sliceLogRecord = _source('docs/agent/SLICE_LOG.md')
        .split('\n')
        .singleWhere((line) => line.startsWith('| DR-2026-07-19-060 |'));

    final normalizedMatrix = matrixRecord.replaceAll(RegExp(r'\s+'), ' ');
    for (final value in fixedFindingTruth) {
      expect(
        normalizedMatrix,
        contains(value),
        reason: 'DCL-DR-003 epoch 060 narrative: $value',
      );
    }
    final normalizedLog = sliceLogRecord.replaceAll(RegExp(r'\s+'), ' ');
    for (final value in sliceLogTruth) {
      expect(
        normalizedLog,
        contains(value),
        reason: 'SLICE_LOG epoch 060 row: $value',
      );
    }
    for (final entry in <(String, String)>[
      ('DCL-DR-003 epoch 060 narrative', matrixRecord),
      ('SLICE_LOG epoch 060 row', sliceLogRecord),
    ]) {
      final findingIds = RegExp(
        r'DCL-DR-003-F\d+',
      ).allMatches(entry.$2).map((match) => match.group(0)).toSet();
      expect(
        findingIds,
        equals({'DCL-DR-003-F37'}),
        reason: '${entry.$1} must record exactly one finding',
      );
    }

    _expectContainsAll('docs/agent/ACTIVE_HANDOFF.md', [
      '`DCL-DR-003-F38`',
      '`DCL-DR-003-F1`',
      'through `DCL-DR-003-F38` are settled evidence',
      '`GATE_TOTAL|PASS|187023|Full`',
      '`GATE_TOTAL|PASS|4551|Docs`',
      '`DCL-DR-003` is `closed`',
      'Never create an automatic successor task.',
    ]);
    for (final path in [
      'docs/agent/FINISH_MAP.md',
      'docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md',
    ]) {
      _expectContainsAll(path, [
        'F1 through F38',
        'DCL-DR-003` is closed',
        'DCL-DR-004',
      ]);
    }

    final currentLog = _source('docs/agent/SLICE_LOG.md');
    final overflowLog = _source(
      'docs/archive/agent-workflow-2026-07-16/SLICE_LOG-rolling-overflow.md',
    );
    expect(
      RegExp(
        r'^\| DR-2026-07-19-060 \|',
        multiLine: true,
      ).allMatches(currentLog),
      hasLength(1),
    );
    expect(
      RegExp(
        r'^\| DR-2026-07-16-035 \|',
        multiLine: true,
      ).allMatches(currentLog),
      isEmpty,
    );
    expect(
      RegExp(
        r'^\| DR-2026-07-16-035 \|',
        multiLine: true,
      ).allMatches(overflowLog),
      hasLength(1),
    );
  });

  test('manual user-directed phone RC continuation has distinct authority', () {
    const planPath =
        'docs/agent/plans/'
        '2026-07-21-user-directed-phone-rc-continuation-reconciliation.md';
    expect(_exists(planPath), isTrue, reason: 'reconciliation plan exists');
    final normalizedPlan = _source(planPath).replaceAll(RegExp(r'\s+'), ' ');
    const requiredPlanTruth = [
      'danio-user-directed-continuation-reconciliation-2026-07-21/1',
      r'The saved Codex project is `C:\Users\larki\OneDrive\Documents\App Projects\Danio Aquarium App Project`',
      r'The repository root and Git authority are `C:\Users\larki\OneDrive\Documents\App Projects\Danio Aquarium App Project\repo`',
      'Continuation mode: autonomous chain approved',
      '20 verified sessions total, including this reconciliation session',
      'durable stop, including a stop without product changes',
      'safety ceiling, not a workload target',
      'phone_completion_run_state.json',
      'frozen historical record',
      'schema, claims, leases, transitions, budgets',
      'do not authorize, constrain, or account for this manual chain',
      'Do not invoke, edit, resume, reinterpret, or delete',
      'It does not authorize tablet, Play Store signing or submission, public release, cloud/accounts, paid services, provider keys, secrets, iOS',
      'one repository-writing coordinator',
      'read-only auditors',
      'focused RED',
      'focused GREEN',
      'independent read-only review',
      'fast-forward local `main` to the tested branch commit',
      'one non-force push',
      'Dirty or unexpected Git: preserve it, make no overlapping edit, and stop',
      'Remote ahead or divergence: do not merge, rebase, or push; stop',
      'Concurrent or uncertain writer ownership: remain read-only and stop',
      'Gate failure: do not commit, merge, push, or chain',
      'If ownership is unclear, do not start, stop, wipe, install, tap, capture, or otherwise affect a device; stop',
      'uncovered product decision: do not infer authority; stop and ask the user',
      'PUSH_OUTCOME_UNKNOWN',
      'Do not retry the push in this session; stop and ask the user',
      'Lookup the exact marker in the same saved project before creation',
      'Create only on an unambiguous, exhaustive zero result',
      'An ambiguous lookup creates nothing; stop and ask the user',
      'unknown create outcome',
      'never retry the unknown create outcome',
      '`danio-dcl-dr-003-wishlist-replay-probe-2026-07-21/1` and the budget is 19',
      'DCL-RC-001',
      'no successor',
    ];
    for (final value in requiredPlanTruth) {
      expect(
        normalizedPlan,
        contains(value),
        reason: '$planPath should preserve $value',
      );
    }
    final normalizedHandoff = _source(
      'docs/agent/ACTIVE_HANDOFF.md',
    ).replaceAll(RegExp(r'\s+'), ' ');
    const requiredHandoffTruth = [
      'DR-2026-07-21-063',
      'danio-dcl-dr-004-backup-tombstone-relationship-proof-2026-07-21/1',
      '2026-07-21-user-directed-phone-rc-continuation-reconciliation.md',
      '`DCL-DR-004` is `closed`',
      'danio-dcl-ai-001-fish-id-activity-consent-proof-2026-07-21/1',
      '17 verified sessions',
    ];
    for (final value in requiredHandoffTruth) {
      expect(
        normalizedHandoff,
        contains(value),
        reason: 'ACTIVE_HANDOFF should preserve $value',
      );
    }
    _expectContainsAll(
      'docs/agent/DCL_DR_003_CRUD_UNDO_RESILIENCE_MATRIX.md',
      [
        'Status: closed - all current P0/P1 paths settled and Full passed',
        'DR-2026-07-21-062',
        'DCL-DR-003-F38',
        'captured stale add callback cannot replay across failure and retry',
        'lower-severity omission-only evidence gaps are parked',
        'GATE_TOTAL|PASS|187023|Full',
      ],
    );
    for (final path in [
      'docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md',
      'docs/agent/FINISH_MAP.md',
    ]) {
      _expectContainsAll(path, [
        'DCL-DR-003',
        'F1 through F38',
        'DCL-DR-004',
      ]);
    }
    final normalizedSliceLog = _source(
      'docs/agent/SLICE_LOG.md',
    ).replaceAll(RegExp(r'\s+'), ' ');
    const requiredSliceLogTruth = [
      'DR-2026-07-21-061',
      'danio-user-directed-continuation-reconciliation-2026-07-21/1',
      'Wishlist replay probe',
      '19 sessions',
      'No product task completed',
      'DR-2026-07-21-062',
      'DCL-DR-003-F38',
      '2,279 tests',
      'Docs 25/signing PASS, 4,551 ms',
      'danio-dcl-dr-004-backup-tombstone-relationship-proof-2026-07-21/1',
      '18',
    ];
    for (final value in requiredSliceLogTruth) {
      expect(
        normalizedSliceLog,
        contains(value),
        reason: 'SLICE_LOG should preserve $value',
      );
    }
  });
}

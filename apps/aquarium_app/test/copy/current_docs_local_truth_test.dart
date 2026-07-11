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
}

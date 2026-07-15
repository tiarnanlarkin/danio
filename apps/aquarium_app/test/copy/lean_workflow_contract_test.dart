import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

const _archiveRoot = 'apps/aquarium_app/docs/archive/agent-workflow-2026-07-15';
const _agentRoot = 'apps/aquarium_app/docs/agent';

String _repoPath(String relativePath) => '../../$relativePath';

int _lineCount(File file) =>
    const LineSplitter().convert(file.readAsStringSync()).length;

void main() {
  const startupPaths = <String>[
    'AGENTS.md',
    'GIT_WORKFLOW.md',
    '$_agentRoot/ACTIVE_HANDOFF.md',
    '$_agentRoot/VERIFIED_SLICE_EXECUTION_CONTRACT.md',
    '$_agentRoot/QUALITY_LADDER.md',
  ];

  const archiveHashes = <String, String>{
    'ACTIVE_HANDOFF-through-2026-07-15.md':
        '501A5BD16258D95A762109E197A0DE6603B6101DB1FAC5B6034BDCB956D9E40E',
    'SLICE_LOG-2026-07-03-through-2026-07-15.md':
        'D8BF4F46B1972043CFDF171C0CE288B808A5AAC69019BA8E9807E3F2D8F36B37',
    'VERIFIED_SLICE_EXECUTION_CONTRACT-autonomous-through-2026-07-15.md':
        '58AD0683425C2F86CBEB4B352758ECA99E01B507EBE5C59BE15387CA579869B4',
    'MULTI_AGENT_WORKFLOW-autonomous-through-2026-07-15.md':
        'B3FD10FE62097227A35B0BFCCC3AF12C878C24E643D2826EEFB963E0DF01606E',
  };

  test('routine startup is exact, compact, and current-only', () {
    var totalLines = 0;
    var totalBytes = 0;
    for (final relativePath in startupPaths) {
      final file = File(_repoPath(relativePath));
      expect(file.existsSync(), isTrue, reason: relativePath);
      totalLines += _lineCount(file);
      totalBytes += file.lengthSync();
    }

    expect(totalLines, lessThanOrEqualTo(600));
    expect(totalBytes, lessThanOrEqualTo(50 * 1024));

    final contract = File(
      _repoPath('$_agentRoot/VERIFIED_SLICE_EXECUTION_CONTRACT.md'),
    ).readAsStringSync();
    expect(contract, contains('Routine startup (exact)'));
    for (final path in startupPaths) {
      expect(contract, contains('`$path`'), reason: path);
    }
    expect(contract, contains('Do not add routine startup reads'));
  });

  test('live handoff and rolling log stay bounded', () {
    final handoff = File(_repoPath('$_agentRoot/ACTIVE_HANDOFF.md'));
    final sliceLog = File(_repoPath('$_agentRoot/SLICE_LOG.md'));
    final verifiedContract = File(
      _repoPath('$_agentRoot/VERIFIED_SLICE_EXECUTION_CONTRACT.md'),
    );
    final multiAgent = File(
      _repoPath('$_agentRoot/MULTI_AGENT_WORKFLOW.md'),
    );

    expect(_lineCount(handoff), lessThanOrEqualTo(150));
    expect(handoff.lengthSync(), lessThanOrEqualTo(16 * 1024));
    expect(_lineCount(verifiedContract), lessThanOrEqualTo(120));
    expect(_lineCount(multiAgent), lessThanOrEqualTo(100));
    expect(sliceLog.lengthSync(), lessThanOrEqualTo(25 * 1024));

    final rows = const LineSplitter()
        .convert(sliceLog.readAsStringSync())
        .where((line) {
          final trimmed = line.trim();
          return trimmed.startsWith('|') &&
              !trimmed.startsWith('| Epoch |') &&
              !RegExp(r'^\|\s*:?-').hasMatch(trimmed);
        })
        .toList();
    expect(rows.length, lessThanOrEqualTo(25));
    for (final row in rows) {
      expect(row.length, lessThanOrEqualTo(800), reason: row.substring(0, 20));
    }
    expect(sliceLog.readAsStringSync(), contains('WF-2026-07-15-019'));
  });

  test('archived workflow history is immutable and non-authoritative', () {
    final archiveReadme = File(
      _repoPath('$_archiveRoot/README.md'),
    );
    expect(archiveReadme.existsSync(), isTrue);
    final readme = archiveReadme.readAsStringSync();
    expect(readme, contains('b691709f4499f21a6b35fa30340a8a6cbe3b9afe'));
    expect(readme.toLowerCase(), contains('non-authoritative'));

    for (final entry in archiveHashes.entries) {
      final file = File(_repoPath('$_archiveRoot/${entry.key}'));
      expect(file.existsSync(), isTrue, reason: entry.key);
      final actual = sha256
          .convert(file.readAsBytesSync())
          .toString()
          .toUpperCase();
      expect(actual, entry.value, reason: entry.key);
      expect(readme, contains(entry.value), reason: entry.key);
    }
  });

  test('autonomy is stopped without consuming the preserved budget', () {
    final state =
        jsonDecode(
              File(
                _repoPath(
                  '$_agentRoot/autonomous_completion/phone_completion_run_state.json',
                ),
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    final transition = state['transition'] as Map<String, dynamic>;
    final budget = state['budget'] as Map<String, dynamic>;
    final charge = budget['current_charge'] as Map<String, dynamic>;
    final cursor = state['cursor'] as Map<String, dynamic>;

    expect(state['state_revision'], 2);
    expect(state['mode'], 'stopped');
    expect(transition['action'], 'preclaim_stop');
    expect(transition['from_mode'], 'ready');
    expect(transition['to_mode'], 'stopped');
    expect(transition['parent_state_revision'], 1);
    expect(
      transition['reason_code'],
      'USER_REQUESTED_WORKFLOW_SIMPLIFICATION',
    );
    expect(
      state['stop_reason_code'],
      'USER_REQUESTED_WORKFLOW_SIMPLIFICATION',
    );
    expect(cursor['work_unit_id'], 'DCL-DR-001-restore-matrix-audit');
    expect(state['owner'], isNull);
    expect(budget['total_approved_units'], 20);
    expect(budget['consumed_units'], 10);
    expect(budget['remaining_units_including_current'], 10);
    expect(charge['status'], 'none');
    expect(charge['work_unit_id'], isNull);

    final autonomyReadme = File(
      _repoPath('$_agentRoot/autonomous_completion/README.md'),
    );
    expect(autonomyReadme.existsSync(), isTrue);
    expect(autonomyReadme.readAsStringSync().toLowerCase(), contains('frozen'));
  });

  test('current workflow cannot instruct claim or successor execution', () {
    final currentFiles = <File>[
      File(_repoPath('AGENTS.md')),
      File(_repoPath('GIT_WORKFLOW.md')),
      File(_repoPath('$_agentRoot/ACTIVE_HANDOFF.md')),
      File(_repoPath('$_agentRoot/VERIFIED_SLICE_EXECUTION_CONTRACT.md')),
      File(_repoPath('$_agentRoot/QUALITY_LADDER.md')),
    ];
    final currentText = currentFiles
        .map((file) => file.readAsStringSync())
        .join('\n');

    expect(currentText, contains('Never create an automatic successor task.'));
    expect(currentText, isNot(contains('invoke_autonomous_writer_claim.ps1')));
    expect(currentText, isNot(contains('win `ready -> active`')));
    expect(currentText, isNot(contains(r'$danio-autonomous-slice-runner')));

    for (final path in <String>[
      '$_agentRoot/AUTONOMOUS_PHONE_COMPLETION_RUNBOOK.md',
      '$_agentRoot/AUTONOMOUS_CHAIN_HANDOFF_PROMPT.md',
      '$_agentRoot/AUTONOMOUS_QUALITY_SETUP.md',
    ]) {
      final text = File(_repoPath(path)).readAsStringSync();
      expect(text, contains('FROZEN HISTORICAL WORKFLOW'), reason: path);
    }
  });
}

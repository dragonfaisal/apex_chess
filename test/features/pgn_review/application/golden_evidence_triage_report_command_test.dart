@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/golden_evidence_triage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/golden_evidence_triage_report.dart';

void main() {
  group('Golden Evidence Triage report command', () {
    test('command file exists', () {
      expect(
        File('tool/golden_evidence_triage_report.dart').existsSync(),
        true,
      );
    });

    test('default command options are deterministic', () {
      final request = validateGoldenEvidenceTriageReportArgs(const []);

      expect(request.isValid, isTrue);
      expect(request.format, GoldenEvidenceTriageReportFormat.markdown);
      expect(request.maxProofTargets, 3);
      expect(request.includeProtected, isFalse);
    });

    test('markdown output is deterministic', () {
      final first = _run();
      final second = _run();

      expect(first.exitCode, goldenEvidenceTriageReportExitSuccess);
      expect(first.stdoutText, second.stdoutText);
      expect(first.stdoutText, contains('Golden Evidence Triage'));
      expect(first.stdoutText, contains('Proof Queue'));
      expect(first.stdoutText, contains('Android Proof Evidence'));
      expect(first.stdoutText, contains('s22-ultra-phase-30u-owner-queue'));
    });

    test('json output is valid and deterministic', () {
      final first = _run(args: const ['--format=json']);
      final second = _run(args: const ['--format=json']);
      final decoded = jsonDecode(first.stdoutText) as Map<String, Object?>;
      final summary = decoded['summary'] as Map<String, Object?>;

      expect(first.exitCode, goldenEvidenceTriageReportExitSuccess);
      expect(first.stdoutText, second.stdoutText);
      expect(decoded['version'], goldenEvidenceTriageReportVersion);
      expect(decoded['summary'], isA<Map<String, Object?>>());
      expect(decoded['proofQueue'], isA<Map<String, Object?>>());
      expect(summary['totalCases'], 15);
      expect(summary['protectedCount'], 13);
      expect(summary['incompleteCount'], 2);
    });

    test('triage output includes new quiet hard-case action', () {
      final result = _run();

      expect(result.exitCode, goldenEvidenceTriageReportExitSuccess);
      expect(result.stdoutText, contains('quiet-preparatory-hard-case'));
      expect(result.stdoutText, contains('addFakeEvidence'));
      expect(result.triage!.recommendedOwnerRunProofQueue.targets, isEmpty);
    });

    test('max proof targets flag keeps ingested queue empty', () {
      final result = _run(args: const ['--max-proof-targets=2']);

      expect(result.exitCode, goldenEvidenceTriageReportExitSuccess);
      expect(result.maxProofTargets, 2);
      expect(result.triage!.recommendedOwnerRunProofQueue.targets, isEmpty);
      expect(
        result.stdoutText,
        contains('mate-threat-fast-evidence, queen-win-major-swing'),
      );
    });

    test('include protected flag lists protected rows', () {
      final result = _run(args: const ['--include-protected']);

      expect(result.exitCode, goldenEvidenceTriageReportExitSuccess);
      expect(result.includeProtected, isTrue);
      expect(result.stdoutText, contains('quiet-opening-skip'));
    });

    test('unknown flag exits usage error', () {
      final result = _run(args: const ['--unknown']);

      expect(result.exitCode, goldenEvidenceTriageReportExitUsage);
      expect(result.commandFailure, 'unknownFlag');
      expect(result.stderrText, contains('Usage:'));
    });

    test('unknown format exits usage error', () {
      final result = _run(args: const ['--format=xml']);

      expect(result.exitCode, goldenEvidenceTriageReportExitUsage);
      expect(result.commandFailure, 'unknownFormat');
    });

    test('invalid max proof targets exits usage error', () {
      final result = _run(args: const ['--max-proof-targets=-1']);

      expect(result.exitCode, goldenEvidenceTriageReportExitUsage);
      expect(result.commandFailure, 'invalidMaxProofTargets');
    });
  });

  group('Golden Evidence Triage command guardrails', () {
    test('report contains no raw UCI spam', () {
      final report = _run().stdoutText;

      expect(report, isNot(contains('uciok')));
      expect(report, isNot(contains('readyok')));
      expect(report, isNot(contains('info depth')));
      expect(report, isNot(contains('bestmove e2e4')));
    });

    test('report contains no PV dumps', () {
      final report = _run().stdoutText;

      expect(report, isNot(contains(' pv ')));
      expect(report, isNot(contains('pvMoves')));
      expect(report, isNot(contains('e2e4 e7e5')));
    });

    test('report contains no final quality labels', () {
      final report = _run().stdoutText;

      expect(report, isNot(contains('Brilliant')));
      expect(report, isNot(contains('Great')));
      expect(report, isNot(contains('Miss')));
    });

    test('report contains no official metric text', () {
      final report = _run().stdoutText;

      expect(report, isNot(contains('ACPL')));
      expect(report, isNot(contains('accuracy')));
    });

    test('command source does not import UI or widgets', () {
      final imports = _imports(_commandSource());

      expect(imports, isNot(contains('package:flutter/material.dart')));
      expect(imports, isNot(contains('package:flutter/widgets.dart')));
      expect(imports, isNot(contains('Widget')));
    });

    test(
      'command source does not import backend, preflight, or server files',
      () {
        final imports = _imports(_commandSource());

        expect(imports, isNot(contains('backend')));
        expect(imports, isNot(contains('preflight')));
        expect(imports, isNot(contains('server')));
      },
    );

    test(
      'command source does not import persistence, cache, or database files',
      () {
        final imports = _imports(_commandSource());

        expect(imports, isNot(contains('persistence')));
        expect(imports, isNot(contains('cache')));
        expect(imports, isNot(contains('database')));
        expect(imports, isNot(contains('shared_preferences')));
        expect(imports, isNot(contains('hive')));
      },
    );

    test('command source does not import engine bridge files directly', () {
      final imports = _imports(_commandSource());

      expect(imports, isNot(contains('LocalEvalService')));
      expect(imports, isNot(contains('local_eval_service.dart')));
      expect(imports, isNot(contains('stockfish')));
      expect(imports, isNot(contains('Stockfish')));
      expect(imports, isNot(contains('dart:ffi')));
      expect(imports, isNot(contains('native')));
      expect(_commandSource(), isNot(contains('Process.run')));
      expect(_commandSource(), isNot(contains('Process.start')));
    });
  });
}

GoldenEvidenceTriageReportCommandResult _run({List<String> args = const []}) {
  return runGoldenEvidenceTriageReportCommand(args: args);
}

String _commandSource() {
  return File('tool/golden_evidence_triage_report.dart').readAsStringSync();
}

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}

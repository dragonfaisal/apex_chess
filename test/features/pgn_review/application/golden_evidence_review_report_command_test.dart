@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/golden_evidence_review.dart';
import 'package:apex_chess/features/pgn_review/application/golden_evidence_review_report.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/golden_evidence_review_report.dart';

void main() {
  group('Golden Evidence Review report command', () {
    test('command file exists', () {
      expect(
        File('tool/golden_evidence_review_report.dart').existsSync(),
        true,
      );
    });

    test('default command mode is fakeEvidence', () {
      final request = validateGoldenEvidenceReviewReportArgs(const []);

      expect(request.isValid, isTrue);
      expect(request.mode, GoldenEvidenceReviewMode.fakeEvidence);
      expect(request.format, GoldenEvidenceReviewReportFormat.markdown);
    });

    test('metadataOnly output is deterministic', () {
      final first = _run(args: const ['--mode=metadataOnly']);
      final second = _run(args: const ['--mode=metadataOnly']);

      expect(first.exitCode, goldenEvidenceReviewReportExitSuccess);
      expect(first.stdoutText, second.stdoutText);
      expect(first.stdoutText, contains('mode: metadataOnly'));
    });

    test('planOnly output is deterministic', () {
      final first = _run(args: const ['--mode=planOnly']);
      final second = _run(args: const ['--mode=planOnly']);

      expect(first.exitCode, goldenEvidenceReviewReportExitSuccess);
      expect(first.stdoutText, second.stdoutText);
      expect(first.stdoutText, contains('mode: planOnly'));
    });

    test('fakeEvidence output is deterministic', () {
      final first = _run();
      final second = _run();

      expect(first.exitCode, goldenEvidenceReviewReportExitSuccess);
      expect(first.stdoutText, second.stdoutText);
      expect(first.stdoutText, contains('mode: fakeEvidence'));
    });

    test('realDeviceEvidenceReferenceOnly shows ingested proof safely', () {
      final result = _run(
        args: const ['--mode=realDeviceEvidenceReferenceOnly'],
      );

      expect(result.exitCode, goldenEvidenceReviewReportExitSuccess);
      expect(result.review!.needsRealDeviceEvidenceCount, 0);
      expect(result.stdoutText, contains('Android Proof Evidence'));
      expect(result.stdoutText, contains('s22-ultra-phase-30u-owner-queue'));
      expect(result.stdoutText, contains('mate-threat-fast-evidence'));
      expect(result.stdoutText, isNot(contains('Real-Device Evidence Needed')));
      expect(_commandSource(), isNot(contains('Process.run')));
      expect(_commandSource(), isNot(contains('Process.start')));
    });

    test('JSON format is valid and stable', () {
      final first = _run(args: const ['--format=json']);
      final second = _run(args: const ['--format=json']);
      final decoded = jsonDecode(first.stdoutText) as Map<String, Object?>;

      expect(first.exitCode, goldenEvidenceReviewReportExitSuccess);
      expect(first.stdoutText, second.stdoutText);
      expect(decoded['version'], goldenEvidenceReviewReportVersion);
      expect(decoded['mode'], GoldenEvidenceReviewMode.fakeEvidence.wire);
      expect(decoded['summary'], isA<Map<String, Object?>>());
      expect(decoded['caseSummaries'], isA<List<Object?>>());
      expect(decoded['motifGroupCoverage'], isA<List<Object?>>());
      expect(decoded['motifEvidenceGroupCoverage'], isA<List<Object?>>());
      expect(decoded['casesMissingMotifEvidence'], isA<List<Object?>>());
    });

    test('Markdown format includes summary and per-case table', () {
      final result = _run(args: const ['--format=markdown']);

      expect(result.exitCode, goldenEvidenceReviewReportExitSuccess);
      expect(result.stdoutText, contains('# Golden Evidence Review Report'));
      expect(result.stdoutText, contains('## Summary'));
      expect(result.stdoutText, contains('## Motif Evidence Group Coverage'));
      expect(result.stdoutText, contains('## Motif Evidence Gaps'));
      expect(result.stdoutText, contains('## Per-Case Summary'));
      expect(
        result.stdoutText,
        contains('| Case | Category | Status | Evidence Gaps |'),
      );
    });

    test('report includes Phase 30W handcrafted cases', () {
      final result = _run(args: const ['--format=markdown']);

      expect(result.exitCode, goldenEvidenceReviewReportExitSuccess);
      expect(result.review!.totalCases, 15);
      expect(result.stdoutText, contains('king-safety-mating-net-hard-case'));
      expect(result.stdoutText, contains('quiet-preparatory-hard-case'));
      expect(result.stdoutText, contains('sacrifice-compensation-hard-case'));
      expect(result.stdoutText, contains('endgame-precision-hard-case'));
      expect(result.stdoutText, contains('forcing-line-variation-hard-case'));
    });

    test('JSON report captures updated motif coverage', () {
      final result = _run(args: const ['--format=json']);
      final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;
      final summary = decoded['summary'] as Map<String, Object?>;

      expect(summary['totalCases'], 15);
      expect(summary['incompleteCount'], 2);
      expect(summary['needsRealDeviceEvidenceCount'], 0);
    });

    test('unknown flag exits usage error', () {
      final result = _run(args: const ['--unknown']);

      expect(result.exitCode, goldenEvidenceReviewReportExitUsage);
      expect(result.commandFailure, 'unknownFlag');
      expect(result.stderrText, contains('Usage:'));
    });

    test('unknown mode exits usage error', () {
      final result = _run(args: const ['--mode=unknown']);

      expect(result.exitCode, goldenEvidenceReviewReportExitUsage);
      expect(result.commandFailure, 'unknownMode');
    });

    test('unknown format exits usage error', () {
      final result = _run(args: const ['--format=xml']);

      expect(result.exitCode, goldenEvidenceReviewReportExitUsage);
      expect(result.commandFailure, 'unknownFormat');
    });

    test('--fail-on-incomplete returns nonzero with incomplete cases', () {
      final result = _run(args: const ['--fail-on-incomplete']);

      expect(result.exitCode, goldenEvidenceReviewReportExitIncomplete);
      expect(result.review!.incomplete, greaterThan(0));
    });

    test('--fail-on-real-device-needed stays zero after proof ingestion', () {
      final result = _run(args: const ['--fail-on-real-device-needed']);

      expect(result.exitCode, goldenEvidenceReviewReportExitSuccess);
      expect(result.review!.needsRealDeviceEvidenceCount, 0);
    });

    test('--fail-on-real-device-needed returns nonzero for unproven IDs', () {
      final unproven = _caseById(
        'mate-threat-fast-evidence',
      ).copyWith(id: 'mate-threat-unproven');
      final result = _run(
        args: const ['--fail-on-real-device-needed'],
        cases: [unproven],
      );

      expect(result.exitCode, goldenEvidenceReviewReportExitRealDeviceNeeded);
      expect(result.review!.needsRealDeviceEvidenceCount, 1);
    });

    test('--fail-on-mismatch returns nonzero for unsafe cases', () {
      final result = _run(
        args: const ['--fail-on-mismatch'],
        cases: [_unsafeCase()],
      );

      expect(result.exitCode, goldenEvidenceReviewReportExitMismatch);
      expect(result.review!.blockedUnsafeClaims, 1);
    });
  });

  group('Golden Evidence Review report guardrails', () {
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
      final source = _commandSource();
      final imports = _imports(source);

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
    });
  });
}

GoldenEvidenceReviewReportCommandResult _run({
  List<String> args = const [],
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
}) {
  return runGoldenEvidenceReviewReportCommand(args: args, cases: cases);
}

GoldenAnalysisCase _unsafeCase() {
  return _caseById('quiet-opening-skip').copyWith(
    id: 'unsafe-license-case',
    safety: const GoldenAnalysisSafetyFlags(licenseSafe: false),
  );
}

GoldenAnalysisCase _caseById(String id) {
  return GoldenAnalysisCases.defaults.singleWhere((item) => item.id == id);
}

String _commandSource() {
  return File('tool/golden_evidence_review_report.dart').readAsStringSync();
}

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}

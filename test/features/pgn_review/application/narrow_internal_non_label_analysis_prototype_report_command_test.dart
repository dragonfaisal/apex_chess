@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_non_label_signal_profile.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_observation_review_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/narrow_internal_non_label_analysis_prototype.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/narrow_internal_non_label_analysis_prototype_report.dart';

void main() {
  group('Narrow Internal Non-Label Analysis Prototype report command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/narrow_internal_non_label_analysis_prototype_report.dart',
        ).existsSync(),
        true,
      );
    });

    test('default output is safe-demo markdown and succeeds', () {
      final result = _run();

      expect(
        result.exitCode,
        narrowInternalNonLabelAnalysisPrototypeReportExitSuccess,
      );
      expect(
        result.format,
        NarrowInternalNonLabelAnalysisPrototypeReportFormat.markdown,
      );
      expect(result.strict, isFalse);
      expect(result.safeDemo, isTrue);
      expect(result.includeWarnings, isTrue);
      expect(
        result.stdoutText,
        contains('# Narrow Internal Non-Label Analysis Prototype'),
      );
      expect(result.stdoutText, contains('completedWithCoverageWarnings'));
      expect(result.result!.packetCount, 6);
    });

    test('json output is valid and deterministic', () {
      final first = _run(args: const ['--format=json']);
      final second = _run(args: const ['--format=json']);
      final decoded = jsonDecode(first.stdoutText) as Map<String, Object?>;

      expect(
        first.exitCode,
        narrowInternalNonLabelAnalysisPrototypeReportExitSuccess,
      );
      expect(first.stdoutText, second.stdoutText);
      expect(
        decoded['version'],
        narrowInternalNonLabelAnalysisPrototypeReportVersion,
      );
      expect(decoded['prototypeStatus'], 'completedWithCoverageWarnings');
      expect(decoded['packets'], isA<List<Object?>>());
    });

    test('strict mode succeeds for safe demo', () {
      final result = _run(args: const ['--strict']);

      expect(
        result.exitCode,
        narrowInternalNonLabelAnalysisPrototypeReportExitSuccess,
      );
      expect(result.result!.readinessGatePassed, isTrue);
      expect(result.result!.reviewUnsafeCount, 0);
      expect(result.result!.consistencyBlockerCount, 0);
      expect(result.result!.consistencyCriticalCount, 0);
    });

    test('safe-demo and include-warnings flags are accepted', () {
      final result = _run(args: const ['--safe-demo', '--include-warnings']);

      expect(
        result.exitCode,
        narrowInternalNonLabelAnalysisPrototypeReportExitSuccess,
      );
      expect(result.safeDemo, isTrue);
      expect(result.includeWarnings, isTrue);
      expect(result.result!.warningLimitedScopeIds, isNotEmpty);
    });

    test('strict mode fails on unsafe policy seam', () {
      final result = _run(
        args: const ['--strict'],
        request: _unsafePrototypeRequest(),
      );

      expect(
        result.exitCode,
        narrowInternalNonLabelAnalysisPrototypeReportExitUnsafePolicy,
      );
      expect(
        result.result!.prototypeStatus,
        NarrowInternalNonLabelAnalysisPrototypeStatus.blockedByPolicy,
      );
    });

    test('unknown flag exits usage error', () {
      final result = _run(args: const ['--unknown']);

      expect(
        result.exitCode,
        narrowInternalNonLabelAnalysisPrototypeReportExitUsage,
      );
      expect(result.commandFailure, 'unknownFlag');
      expect(result.stderrText, contains('Usage:'));
    });

    test('unknown format exits usage error', () {
      final result = _run(args: const ['--format=xml']);

      expect(
        result.exitCode,
        narrowInternalNonLabelAnalysisPrototypeReportExitUsage,
      );
      expect(result.commandFailure, 'unknownFormat');
    });

    test('command output keeps report guardrails', () {
      final report = _run().stdoutText;

      expect(report, isNot(contains('uciok')));
      expect(report, isNot(contains('readyok')));
      expect(report, isNot(contains('info depth')));
      expect(report, isNot(contains('bestmove e2e4')));
      expect(report, isNot(contains(' pv ')));
      expect(report, isNot(contains('Brilliant')));
      expect(report, isNot(contains('Great')));
      expect(report, isNot(contains('Miss')));
      expect(report, isNot(contains('Best')));
      expect(report, isNot(contains('Good')));
      expect(report, isNot(contains('Inaccuracy')));
      expect(report, isNot(contains('Mistake')));
      expect(report, isNot(contains('Blunder')));
      expect(report, isNot(contains('ACPL')));
      expect(report, isNot(contains('accuracy')));
      expect(report, isNot(contains('moveScore')));
      expect(report, isNot(contains('rankedMoves')));
      expect(report, isNot(contains('moveRanking')));
    });

    test(
      'command source does not execute proof commands or import boundaries',
      () {
        final source = _commandSource();
        final imports = _imports(source);

        expect(source, isNot(contains('Process.run')));
        expect(source, isNot(contains('Process.start')));
        expect(imports, isNot(contains('Stockfish')));
        expect(imports, isNot(contains('stockfish_bridge')));
        expect(imports, isNot(contains('dart:ffi')));
        expect(imports, isNot(contains('native')));
        expect(imports, isNot(contains('LocalEvalService')));
        expect(imports, isNot(contains('flutter/material')));
        expect(imports, isNot(contains('Widget')));
        expect(imports, isNot(contains('backend')));
        expect(imports, isNot(contains('preflight')));
        expect(imports, isNot(contains('server')));
        expect(imports, isNot(contains('persistence')));
        expect(imports, isNot(contains('cache')));
        expect(imports, isNot(contains('database')));
      },
    );
  });
}

NarrowInternalNonLabelAnalysisPrototypeReportCommandResult _run({
  List<String> args = const [],
  NarrowInternalNonLabelAnalysisPrototypeRequest? request,
}) {
  return runNarrowInternalNonLabelAnalysisPrototypeReportCommand(
    args: args,
    request: request,
  );
}

NarrowInternalNonLabelAnalysisPrototypeRequest _unsafePrototypeRequest() {
  final review = const InternalSignalObservationReviewMatrix().evaluate(
    const InternalSignalObservationReviewMatrixRequest(),
  );
  final unsafeReview = review.copyWith(
    rows: review.rows
        .map(
          (row) =>
              row.signalId == InternalNonLabelSignalId.tacticalPressureSignal
              ? row.copyWith(supportCaseIds: const <String>[])
              : row,
        )
        .toList(growable: false),
  );
  return NarrowInternalNonLabelAnalysisPrototypeRequest(
    reviewResult: unsafeReview,
  );
}

String _commandSource() {
  return File(
    'tool/narrow_internal_non_label_analysis_prototype_report.dart',
  ).readAsStringSync();
}

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}

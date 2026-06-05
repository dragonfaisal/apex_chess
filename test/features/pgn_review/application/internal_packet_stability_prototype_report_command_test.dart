@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_non_label_prototype_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_review_aggregation_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_stability_prototype.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/internal_packet_stability_prototype_report.dart';

void main() {
  group('Internal Packet Stability Prototype report command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/internal_packet_stability_prototype_report.dart',
        ).existsSync(),
        true,
      );
    });

    test('default output is safe-demo markdown and succeeds', () {
      final result = _run();

      expect(
        result.exitCode,
        internalPacketStabilityPrototypeReportExitSuccess,
      );
      expect(
        result.format,
        InternalPacketStabilityPrototypeReportFormat.markdown,
      );
      expect(result.strict, isFalse);
      expect(result.safeDemo, isTrue);
      expect(result.includeWarnings, isTrue);
      expect(
        result.stdoutText,
        contains('# Internal Packet Stability Prototype'),
      );
      expect(result.stdoutText, contains('stableWithWarnings'));
      expect(result.result!.proofLimitedStableCount, 1);
    });

    test('json output is valid and deterministic', () {
      final first = _run(args: const ['--format=json']);
      final second = _run(args: const ['--format=json']);
      final decoded = jsonDecode(first.stdoutText) as Map<String, Object?>;

      expect(first.exitCode, internalPacketStabilityPrototypeReportExitSuccess);
      expect(first.stdoutText, second.stdoutText);
      expect(decoded['version'], internalPacketStabilityPrototypeReportVersion);
      expect(decoded['prototypeStatus'], 'stableWithWarnings');
      expect(decoded['records'], isA<List<Object?>>());
    });

    test('strict mode succeeds for safe demo', () {
      final result = _run(args: const ['--strict']);

      expect(
        result.exitCode,
        internalPacketStabilityPrototypeReportExitSuccess,
      );
      expect(result.result!.safeForPhase32D, isTrue);
      expect(result.result!.unsafeCount, 0);
      expect(result.result!.unstableCount, 0);
    });

    test('safe-demo and include-warnings flags are accepted', () {
      final result = _run(args: const ['--safe-demo', '--include-warnings']);

      expect(
        result.exitCode,
        internalPacketStabilityPrototypeReportExitSuccess,
      );
      expect(result.safeDemo, isTrue);
      expect(result.includeWarnings, isTrue);
      expect(result.result!.warningLimitedCount, 4);
    });

    test('strict mode fails on unsafe seam', () {
      final result = _run(
        args: const ['--strict'],
        request: _unsafePrototypeRequest(),
      );

      expect(
        result.exitCode,
        internalPacketStabilityPrototypeReportExitUnsafePolicy,
      );
      expect(result.result!.unsafeCount, greaterThan(0));
    });

    test('unknown flag exits usage error', () {
      final result = _run(args: const ['--unknown']);

      expect(result.exitCode, internalPacketStabilityPrototypeReportExitUsage);
      expect(result.commandFailure, 'unknownFlag');
      expect(result.stderrText, contains('Usage:'));
    });

    test('unknown format exits usage error', () {
      final result = _run(args: const ['--format=xml']);

      expect(result.exitCode, internalPacketStabilityPrototypeReportExitUsage);
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
      expect(report, isNot(contains('scoreValue')));
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

InternalPacketStabilityPrototypeReportCommandResult _run({
  List<String> args = const [],
  InternalPacketStabilityPrototypeRequest? request,
}) {
  return runInternalPacketStabilityPrototypeReportCommand(
    args: args,
    request: request,
  );
}

InternalPacketStabilityPrototypeRequest _unsafePrototypeRequest() {
  final matrix = const InternalPacketReviewAggregationMatrix().evaluate(
    const InternalPacketReviewAggregationMatrixRequest(),
  );
  final unsafeMatrix = matrix.copyWith(
    rows: matrix.rows
        .map(
          (row) =>
              row.allowedScopeId ==
                  InternalNonLabelPrototypeScopeId
                      .tacticalInternalPrototypeScope
              ? row.copyWith(
                  isClassifierLabel: true,
                  hasNumericScore: true,
                  ranksMoves: true,
                )
              : row,
        )
        .toList(growable: false),
  );
  return InternalPacketStabilityPrototypeRequest(matrixResult: unsafeMatrix);
}

String _commandSource() {
  return File(
    'tool/internal_packet_stability_prototype_report.dart',
  ).readAsStringSync();
}

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}

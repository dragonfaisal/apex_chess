@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_design.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/internal_evidence_adapter_prototype_report.dart';

void main() {
  group('Internal Evidence Adapter Prototype report command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/internal_evidence_adapter_prototype_report.dart',
        ).existsSync(),
        true,
      );
    });

    test('markdown works for safe demo', () {
      final result = _run();

      expect(
        result.exitCode,
        internalEvidenceAdapterPrototypeReportExitSuccess,
      );
      expect(
        result.format,
        InternalEvidenceAdapterPrototypeReportFormat.markdown,
      );
      expect(
        result.stdoutText,
        contains('# Internal Evidence Adapter Prototype'),
      );
      expect(result.stdoutText, contains('## Adapter Packet Table'));
      expect(result.stdoutText, contains('## Core Packets'));
      expect(result.stdoutText, contains('## Blocked Output Field Summary'));
      expect(result.stdoutText, contains('owner proof queue count: 0'));
      expect(result.stderrText, isEmpty);
      expect(result.result!.safeForPhase32O, isTrue);
    });

    test('JSON works for safe demo', () {
      final result = _run(args: const <String>['--format=json']);
      final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;

      expect(
        result.exitCode,
        internalEvidenceAdapterPrototypeReportExitSuccess,
      );
      expect(result.format, InternalEvidenceAdapterPrototypeReportFormat.json);
      expect(decoded['version'], internalEvidenceAdapterPrototypeReportVersion);
      expect(decoded['totalPackets'], 7);
      expect(decoded['corePacketCount'], 2);
      expect(decoded['contextOnlyPacketCount'], 3);
      expect(decoded['blockedPacketCount'], 1);
      expect(decoded['futureOnlyPacketCount'], 1);
      expect(decoded['ownerProofQueueCount'], 0);
      expect(decoded['safeForPhase32O'], isTrue);
    });

    test('strict passes for safe demo', () {
      final result = _run(args: const <String>['--strict']);

      expect(
        result.exitCode,
        internalEvidenceAdapterPrototypeReportExitSuccess,
      );
      expect(result.result!.safeForPhase32O, isTrue);
      expect(result.result!.unsafeCount, 0);
      expect(result.result!.criticalCount, 0);
    });

    test('strict fails on unsafe seam', () {
      final unsafeDesign = const InternalEvidenceAdapterDesign()
          .evaluate()
          .copyWith(
            designStatus:
                InternalEvidenceAdapterDesignStatus.blockedByUnsafeSummary,
            unsafeCount: 1,
            safeForPhase32N: false,
          );
      final result = _run(
        args: const <String>['--strict'],
        request: InternalEvidenceAdapterPrototypeRequest(
          designResult: unsafeDesign,
        ),
      );

      expect(
        result.exitCode,
        internalEvidenceAdapterPrototypeReportExitUnsafePolicy,
      );
      expect(result.result!.hasUnsafeAdapterPrototypePolicyViolation, isTrue);
    });

    test('safe-demo and include-warnings flags are accepted', () {
      final result = _run(
        args: const <String>['--safe-demo', '--include-warnings'],
      );

      expect(
        result.exitCode,
        internalEvidenceAdapterPrototypeReportExitSuccess,
      );
      expect(result.safeDemo, isTrue);
      expect(result.includeWarnings, isTrue);
      expect(result.result!.contextOnlyPacketCount, 3);
    });

    test('usage errors return usage exit code', () {
      final result = _run(args: const <String>['--format=xml']);

      expect(result.exitCode, internalEvidenceAdapterPrototypeReportExitUsage);
      expect(result.stderrText, contains('unknownFormat'));
      expect(result.commandFailure, 'unknownFormat');
    });

    test('command output keeps active-output guardrails', () {
      final report = _run().stdoutText;

      for (final token in const <String>[
        'uciok',
        'readyok',
        'info depth',
        'bestmove e2e4',
        ' pv ',
        'pvMoves',
        'active productLabel',
        'active finalMoveLabel',
        'numeric move score:',
        'scoreValue',
        'moveScore',
        'rankedMoves',
        'moveRanking active',
        'ACPL',
        'official accuracy',
      ]) {
        expect(report, isNot(contains(token)), reason: token);
      }
    });

    test('command source does not execute proof or boundary integrations', () {
      final source = File(
        'tool/internal_evidence_adapter_prototype_report.dart',
      ).readAsStringSync();
      final imports = source
          .split('\n')
          .where((line) => line.trimLeft().startsWith('import '))
          .join('\n');

      expect(source, isNot(contains('Process.run')));
      expect(source, isNot(contains('Process.start')));
      expect(imports, isNot(contains('dart:ffi')));
      expect(imports.toLowerCase(), isNot(contains('stockfish')));
      expect(imports, isNot(contains('LocalEvalService')));
      expect(imports, isNot(contains('package:flutter/')));
      expect(imports, isNot(contains('Widget')));
      expect(imports, isNot(contains('backend')));
      expect(imports, isNot(contains('preflight')));
      expect(imports, isNot(contains('server')));
      expect(imports, isNot(contains('persistence')));
      expect(imports, isNot(contains('cache')));
      expect(imports, isNot(contains('database')));
    });
  });
}

InternalEvidenceAdapterPrototypeReportCommandResult _run({
  List<String> args = const <String>[],
  InternalEvidenceAdapterPrototypeRequest? request,
}) {
  return runInternalEvidenceAdapterPrototypeReportCommand(
    args: args,
    request: request,
  );
}

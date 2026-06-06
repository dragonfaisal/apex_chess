@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype_validation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/internal_evidence_adapter_prototype_readiness_gate_report.dart';

void main() {
  group('Internal Evidence Adapter Prototype Readiness Gate report command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/internal_evidence_adapter_prototype_readiness_gate_report.dart',
        ).existsSync(),
        true,
      );
    });

    test('markdown works for safe demo', () {
      final result = _run();

      expect(
        result.exitCode,
        internalEvidenceAdapterPrototypeReadinessGateReportExitSuccess,
      );
      expect(
        result.format,
        InternalEvidenceAdapterPrototypeReadinessGateReportFormat.markdown,
      );
      expect(
        result.stdoutText,
        contains('# Internal Evidence Adapter Prototype Readiness Gate'),
      );
      expect(result.stdoutText, contains('## Readiness Group Table'));
      expect(result.stdoutText, contains('## Readiness Record Table'));
      expect(result.stdoutText, contains('## Allowed Core Packets'));
      expect(result.stdoutText, contains('## Blocked Output Field Summary'));
      expect(result.stdoutText, contains('owner proof queue count: 0'));
      expect(result.stderrText, isEmpty);
      expect(result.result!.safeForPhase32R, isTrue);
    });

    test('JSON works for safe demo', () {
      final result = _run(args: const <String>['--format=json']);
      final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;

      expect(
        result.exitCode,
        internalEvidenceAdapterPrototypeReadinessGateReportExitSuccess,
      );
      expect(
        result.format,
        InternalEvidenceAdapterPrototypeReadinessGateReportFormat.json,
      );
      expect(
        decoded['version'],
        internalEvidenceAdapterPrototypeReadinessGateReportVersion,
      );
      expect(decoded['totalRecords'], 7);
      expect(decoded['allowedCorePacketCount'], 2);
      expect(decoded['constrainedContextPacketCount'], 3);
      expect(decoded['inactiveBlockedPacketCount'], 1);
      expect(decoded['inactiveFutureOnlyPacketCount'], 1);
      expect(decoded['ownerProofQueueCount'], 0);
      expect(decoded['safeForPhase32R'], isTrue);
    });

    test('strict passes for safe demo', () {
      final result = _run(args: const <String>['--strict']);

      expect(
        result.exitCode,
        internalEvidenceAdapterPrototypeReadinessGateReportExitSuccess,
      );
      expect(result.result!.safeForPhase32R, isTrue);
      expect(result.result!.unsafeCount, 0);
      expect(result.result!.criticalCount, 0);
      expect(result.result!.blockerCount, 0);
    });

    test('strict fails on unsafe seam', () {
      final unsafeValidation =
          const InternalEvidenceAdapterPrototypeValidation()
              .evaluate()
              .copyWith(
                validationStatus:
                    InternalEvidenceAdapterPrototypeValidationStatus
                        .blockedByUnsafeReview,
                unsafeCount: 1,
                unsafePacketCount: 1,
                safeForPhase32Q: false,
              );
      final result = _run(
        args: const <String>['--strict'],
        request: InternalEvidenceAdapterPrototypeReadinessGateRequest(
          validationResult: unsafeValidation,
        ),
      );

      expect(
        result.exitCode,
        internalEvidenceAdapterPrototypeReadinessGateReportExitUnsafePolicy,
      );
      expect(result.result!.hasUnsafeAdapterReadinessPolicyViolation, isTrue);
    });

    test('safe-demo and include-warnings flags are accepted', () {
      final result = _run(
        args: const <String>['--safe-demo', '--include-warnings'],
      );

      expect(
        result.exitCode,
        internalEvidenceAdapterPrototypeReadinessGateReportExitSuccess,
      );
      expect(result.safeDemo, isTrue);
      expect(result.includeWarnings, isTrue);
      expect(result.result!.constrainedContextPacketCount, 3);
    });

    test('usage errors return usage exit code', () {
      final result = _run(args: const <String>['--format=xml']);

      expect(
        result.exitCode,
        internalEvidenceAdapterPrototypeReadinessGateReportExitUsage,
      );
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
        'tool/internal_evidence_adapter_prototype_readiness_gate_report.dart',
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

InternalEvidenceAdapterPrototypeReadinessGateReportCommandResult _run({
  List<String> args = const <String>[],
  InternalEvidenceAdapterPrototypeReadinessGateRequest? request,
}) {
  return runInternalEvidenceAdapterPrototypeReadinessGateReportCommand(
    args: args,
    request: request,
  );
}

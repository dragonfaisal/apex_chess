@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype_review.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype_validation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/internal_evidence_adapter_prototype_validation_report.dart';

void main() {
  group('Internal Evidence Adapter Prototype Validation report command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/internal_evidence_adapter_prototype_validation_report.dart',
        ).existsSync(),
        true,
      );
    });

    test('markdown works for safe demo', () {
      final result = _run();

      expect(
        result.exitCode,
        internalEvidenceAdapterPrototypeValidationReportExitSuccess,
      );
      expect(
        result.format,
        InternalEvidenceAdapterPrototypeValidationReportFormat.markdown,
      );
      expect(
        result.stdoutText,
        contains('# Internal Evidence Adapter Prototype Validation'),
      );
      expect(result.stdoutText, contains('## Validation Check Table'));
      expect(result.stdoutText, contains('## Packet Validation Table'));
      expect(result.stdoutText, contains('## Core Packet Validation Rows'));
      expect(result.stdoutText, contains('## Blocked Output Field Summary'));
      expect(result.stdoutText, contains('owner proof queue count: 0'));
      expect(result.stderrText, isEmpty);
      expect(result.result!.safeForPhase32Q, isTrue);
    });

    test('JSON works for safe demo', () {
      final result = _run(args: const <String>['--format=json']);
      final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;

      expect(
        result.exitCode,
        internalEvidenceAdapterPrototypeValidationReportExitSuccess,
      );
      expect(
        result.format,
        InternalEvidenceAdapterPrototypeValidationReportFormat.json,
      );
      expect(
        decoded['version'],
        internalEvidenceAdapterPrototypeValidationReportVersion,
      );
      expect(decoded['totalChecks'], 13);
      expect(decoded['totalPacketRows'], 7);
      expect(decoded['validCorePacketCount'], 2);
      expect(decoded['validContextOnlyPacketCount'], 3);
      expect(decoded['validBlockedPacketCount'], 1);
      expect(decoded['validFutureOnlyPacketCount'], 1);
      expect(decoded['ownerProofQueueCount'], 0);
      expect(decoded['safeForPhase32Q'], isTrue);
    });

    test('strict passes for safe demo', () {
      final result = _run(args: const <String>['--strict']);

      expect(
        result.exitCode,
        internalEvidenceAdapterPrototypeValidationReportExitSuccess,
      );
      expect(result.result!.safeForPhase32Q, isTrue);
      expect(result.result!.unsafePacketCount, 0);
      expect(result.result!.criticalCount, 0);
    });

    test('strict fails on unsafe seam', () {
      final unsafeReview = const InternalEvidenceAdapterPrototypeReview()
          .evaluate()
          .copyWith(
            reviewStatus: InternalEvidenceAdapterPrototypeReviewStatus
                .blockedByUnsafePrototype,
            unsafeCount: 1,
            safeForPhase32P: false,
          );
      final result = _run(
        args: const <String>['--strict'],
        request: InternalEvidenceAdapterPrototypeValidationRequest(
          reviewResult: unsafeReview,
        ),
      );

      expect(
        result.exitCode,
        internalEvidenceAdapterPrototypeValidationReportExitUnsafePolicy,
      );
      expect(result.result!.hasUnsafeAdapterValidationPolicyViolation, isTrue);
    });

    test('safe-demo and include-warnings flags are accepted', () {
      final result = _run(
        args: const <String>['--safe-demo', '--include-warnings'],
      );

      expect(
        result.exitCode,
        internalEvidenceAdapterPrototypeValidationReportExitSuccess,
      );
      expect(result.safeDemo, isTrue);
      expect(result.includeWarnings, isTrue);
      expect(result.result!.validContextOnlyPacketCount, 3);
    });

    test('usage errors return usage exit code', () {
      final result = _run(args: const <String>['--format=xml']);

      expect(
        result.exitCode,
        internalEvidenceAdapterPrototypeValidationReportExitUsage,
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
        'tool/internal_evidence_adapter_prototype_validation_report.dart',
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

InternalEvidenceAdapterPrototypeValidationReportCommandResult _run({
  List<String> args = const <String>[],
  InternalEvidenceAdapterPrototypeValidationRequest? request,
}) {
  return runInternalEvidenceAdapterPrototypeValidationReportCommand(
    args: args,
    request: request,
  );
}

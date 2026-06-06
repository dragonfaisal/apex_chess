@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_design.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_summary_layer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/internal_evidence_adapter_design_report.dart';

void main() {
  group('Internal Evidence Adapter Design report command', () {
    test('command file exists', () {
      expect(
        File('tool/internal_evidence_adapter_design_report.dart').existsSync(),
        true,
      );
    });

    test('markdown works for safe demo', () {
      final result = _run();

      expect(result.exitCode, internalEvidenceAdapterDesignReportExitSuccess);
      expect(result.format, InternalEvidenceAdapterDesignReportFormat.markdown);
      expect(result.stdoutText, contains('# Internal Evidence Adapter Design'));
      expect(result.stdoutText, contains('## Input Contract Table'));
      expect(result.stdoutText, contains('## Output Contract Table'));
      expect(result.stdoutText, contains('## Blocked Output Fields'));
      expect(result.stdoutText, contains('owner proof queue count: 0'));
      expect(result.stderrText, isEmpty);
      expect(result.result!.safeForPhase32N, isTrue);
    });

    test('JSON works for safe demo', () {
      final result = _run(args: const <String>['--format=json']);
      final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;

      expect(result.exitCode, internalEvidenceAdapterDesignReportExitSuccess);
      expect(result.format, InternalEvidenceAdapterDesignReportFormat.json);
      expect(decoded['version'], internalEvidenceAdapterDesignReportVersion);
      expect(decoded['totalAdapterRecords'], 7);
      expect(decoded['coreAdapterRecordCount'], 2);
      expect(decoded['contextOnlyRecordCount'], 3);
      expect(decoded['blockedRecordCount'], 1);
      expect(decoded['futureOnlyRecordCount'], 1);
      expect(decoded['ownerProofQueueCount'], 0);
      expect(decoded['safeForPhase32N'], isTrue);
    });

    test('strict passes for safe demo', () {
      final result = _run(args: const <String>['--strict']);

      expect(result.exitCode, internalEvidenceAdapterDesignReportExitSuccess);
      expect(result.result!.safeForPhase32N, isTrue);
      expect(result.result!.unsafeCount, 0);
      expect(result.result!.criticalCount, 0);
    });

    test('strict fails on unsafe seam', () {
      final unsafeSummary = const InternalEvidenceSummaryLayer()
          .evaluate()
          .copyWith(
            summaryStatus:
                InternalEvidenceSummaryLayerStatus.blockedByUnsafeReadiness,
            unsafeCount: 1,
            safeForPhase32M: false,
          );
      final result = _run(
        args: const <String>['--strict'],
        request: InternalEvidenceAdapterDesignRequest(
          summaryResult: unsafeSummary,
        ),
      );

      expect(
        result.exitCode,
        internalEvidenceAdapterDesignReportExitUnsafePolicy,
      );
      expect(result.result!.hasUnsafeAdapterDesignPolicyViolation, isTrue);
    });

    test('safe-demo and include-warnings flags are accepted', () {
      final result = _run(
        args: const <String>['--safe-demo', '--include-warnings'],
      );

      expect(result.exitCode, internalEvidenceAdapterDesignReportExitSuccess);
      expect(result.safeDemo, isTrue);
      expect(result.includeWarnings, isTrue);
      expect(result.result!.contextOnlyRecordCount, 3);
    });

    test('usage errors return usage exit code', () {
      final result = _run(args: const <String>['--format=xml']);

      expect(result.exitCode, internalEvidenceAdapterDesignReportExitUsage);
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
        'tool/internal_evidence_adapter_design_report.dart',
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

InternalEvidenceAdapterDesignReportCommandResult _run({
  List<String> args = const <String>[],
  InternalEvidenceAdapterDesignRequest? request,
}) {
  return runInternalEvidenceAdapterDesignReportCommand(
    args: args,
    request: request,
  );
}

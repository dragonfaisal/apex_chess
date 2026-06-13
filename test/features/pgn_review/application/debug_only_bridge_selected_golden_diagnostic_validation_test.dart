@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_developer_diagnostic_command.dart';

void main() {
  group('DebugOnlyBridgeSelectedGoldenDiagnosticValidation', () {
    test('default validation is safe and warning-aware', () {
      final result = const DebugOnlyBridgeSelectedGoldenDiagnosticValidation()
          .evaluate();

      expect(
        result.status,
        DebugOnlyBridgeSelectedGoldenDiagnosticValidationStatus
            .selectedGoldenDiagnosticValidatedWithWarnings,
      );
      expect(result.safeForPhase33M, isTrue);
      expect(
        result.phase33MRecommendation,
        'proceedToDebugOnlyBridgeAnalyzerAdapterBoundaryDesign',
      );
      expect(result.totalChecks, 19);
      expect(result.blockerCount, 0);
      expect(result.criticalCount, 0);
      expect(result.unsafeCount, 0);
      expect(result.activeDeniedFieldCount, 0);
      expect(result.productOutputCount, 0);
      expect(result.engineCallCount, 0);
      expect(result.schedulerExecutionCount, 0);
      expect(result.androidCollectorExecutionCount, 0);
      expect(result.defaultSelectedRowCount, 7);
      expect(result.allSafeSelectedRowCount, greaterThan(7));
      expect(result.safeForPhase33M, isTrue);
    });

    test('selected row validation keeps roles deterministic', () {
      final result = const DebugOnlyBridgeSelectedGoldenDiagnosticValidation()
          .evaluate();
      final rowsByCaseId = {
        for (final row in result.selectedRows) row.caseId: row,
      };

      expect(
        rowsByCaseId['queen-win-major-swing']!.diagnosticRole,
        DebugOnlyBridgeSelectedGoldenDiagnosticRole.coreSupport,
      );
      expect(
        rowsByCaseId['endgame-precision-candidate-spread-32e']!.diagnosticRole,
        DebugOnlyBridgeSelectedGoldenDiagnosticRole.contextOnly,
      );
      expect(
        rowsByCaseId['budget-pressure-wide-candidate-32e']!.diagnosticRole,
        DebugOnlyBridgeSelectedGoldenDiagnosticRole.warningLimited,
      );
      expect(
        rowsByCaseId['pv-multipv-support-boundary-32e']!.diagnosticRole,
        DebugOnlyBridgeSelectedGoldenDiagnosticRole.proofBoundaryOnly,
      );
      expect(
        rowsByCaseId['quiet-preparatory-hard-case']!.diagnosticRole,
        DebugOnlyBridgeSelectedGoldenDiagnosticRole.excludedNegativeGuard,
      );
    });

    test('Phase 32E rows do not claim captured Android proof', () {
      final result = const DebugOnlyBridgeSelectedGoldenDiagnosticValidation()
          .evaluate();
      final phase32ERows = result.selectedRows.where(
        (row) => row.sourcePhase == 'Phase 32E',
      );

      expect(phase32ERows, isNotEmpty);
      for (final row in phase32ERows) {
        expect(row.androidProofCaseIds, isEmpty, reason: row.caseId);
        expect(row.findings, isEmpty, reason: row.caseId);
      }
      expect(result.phase32EProofClaimCount, 0);
      expect(result.unprovenAndroidProofCount, 0);
    });

    test('PV MultiPV remains boundary only without owner proof', () {
      final result = const DebugOnlyBridgeSelectedGoldenDiagnosticValidation()
          .evaluate();
      final row = result.selectedRows.singleWhere(
        (item) => item.caseId == 'pv-multipv-support-boundary-32e',
      );

      expect(
        row.diagnosticRole,
        DebugOnlyBridgeSelectedGoldenDiagnosticRole.proofBoundaryOnly,
      );
      expect(row.androidProofCaseIds, isEmpty);
      expect(row.ownerProofRequired, isFalse);
      expect(row.findings, isEmpty);
    });

    test('unknown single Golden case blocks validation', () {
      final result = const DebugOnlyBridgeSelectedGoldenDiagnosticValidation()
          .evaluate(singleCaseId: 'not-a-golden-case');

      expect(
        result.status,
        DebugOnlyBridgeSelectedGoldenDiagnosticValidationStatus
            .invalidGoldenDiagnostic,
      );
      expect(result.safeForPhase33M, isFalse);
      expect(result.blockerCount, greaterThan(0));
      expect(
        result.reportFindings.map((finding) => finding.id),
        contains('unknownGoldenCase'),
      );
    });

    test('validator rejects active denied and product label fields', () {
      final row = _row(activeDeniedFields: const <String>['productLabel']);
      final validation =
          const DebugOnlyBridgeSelectedGoldenDiagnosticValidationValidator()
              .validateRow(row, knownCaseIds: const <String>{'known-case'});

      expect(validation.status.isUnsafe, isTrue);
      expect(validation.findings, contains('activeDeniedField'));
      expect(validation.findings, contains('productOutput'));
      expect(validation.findings, contains('labelLeak'));
    });

    test(
      'validator rejects score metric CP-loss and win probability fields',
      () {
        final row = _row(
          activeDeniedFields: const <String>[
            'numericMoveScore',
            'aggregateScore',
            'officialAccuracy',
            'acpl',
            'cpLoss',
            'winProbability',
            'moveRanking',
          ],
        );
        final validation =
            const DebugOnlyBridgeSelectedGoldenDiagnosticValidationValidator()
                .validateRow(row, knownCaseIds: const <String>{'known-case'});

        expect(validation.status.isUnsafe, isTrue);
        expect(validation.findings, contains('scoreLeak'));
        expect(validation.findings, contains('metricLeak'));
        expect(validation.findings, contains('cpLossLeak'));
        expect(validation.findings, contains('winProbabilityLeak'));
        expect(validation.findings, contains('moveRankingLeak'));
      },
    );

    test(
      'validator rejects engine scheduler and raw engine field activation',
      () {
        final row = _row(
          activeDeniedFields: const <String>[
            'uiOutput',
            'backendOutput',
            'persistenceOutput',
            'directEngineCall',
            'schedulerExecution',
            'androidCollectorExecution',
            'stockfishCommand',
            'rawUci',
            'pvDump',
          ],
        );
        final validation =
            const DebugOnlyBridgeSelectedGoldenDiagnosticValidationValidator()
                .validateRow(row, knownCaseIds: const <String>{'known-case'});

        expect(validation.status.isUnsafe, isTrue);
        expect(validation.findings, contains('uiTarget'));
        expect(validation.findings, contains('backendTarget'));
        expect(validation.findings, contains('persistenceWrite'));
        expect(validation.findings, contains('engineCall'));
        expect(validation.findings, contains('schedulerExecution'));
        expect(validation.findings, contains('androidCollectorExecution'));
        expect(validation.findings, contains('stockfishCommandLeak'));
        expect(validation.findings, contains('rawUciLeak'));
        expect(validation.findings, contains('pvDumpLeak'));
      },
    );

    test('validator rejects raw UCI and PV dump report text leaks', () {
      final findings =
          const DebugOnlyBridgeSelectedGoldenDiagnosticValidationValidator()
              .validateReportText('info depth 1 pv e2e4 bestmove e2e4');

      expect(findings, isNotEmpty);
      expect(findings.every((finding) => finding.critical), isTrue);
    });

    test('source imports remain developer-only and integration-free', () {
      final source = File(
        'tool/debug_only_bridge_developer_diagnostic_command.dart',
      ).readAsStringSync();
      final imports = source
          .split('\n')
          .where((line) => line.trimLeft().startsWith('import '))
          .join('\n');

      expect(imports, isNot(contains('dart:ffi')));
      expect(imports, isNot(contains('package:flutter/')));
      expect(imports, isNot(contains('LocalEvalService')));
      expect(imports.toLowerCase(), isNot(contains('stockfish')));
      expect(imports, isNot(contains('backend')));
      expect(imports, isNot(contains('preflight')));
      expect(imports, isNot(contains('server')));
      expect(imports, isNot(contains('persistence')));
      expect(imports, isNot(contains('cache')));
      expect(imports, isNot(contains('database')));
      expect(imports, isNot(contains('scheduler')));
    });
  });
}

DebugOnlyBridgeSelectedGoldenDiagnosticRow _row({
  List<String> activeDeniedFields = const <String>[],
}) {
  return DebugOnlyBridgeSelectedGoldenDiagnosticRow(
    caseId: 'known-case',
    caseTitle: 'Known case',
    sourcePhase: 'existing',
    selectedReason: 'test seam',
    diagnosticRole: DebugOnlyBridgeSelectedGoldenDiagnosticRole.coreSupport,
    supportAreaIds: const <String>['tacticalShot'],
    blockedBoundaryIds: const <String>[],
    warningReasons: const <String>[],
    proofLimitReasons: const <String>[],
    androidProofCaseIds: const <String>[],
    ownerProofRequired: false,
    activeDeniedFields: activeDeniedFields,
    recommendation: 'proceedToDebugOnlyBridgeAnalyzerAdapterBoundaryDesign',
  );
}

@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_evidence_area_coverage_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_buckets.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_scoring_design.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_signal_profile.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_profile_consistency_matrix.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InternalSignalProfileConsistencyMatrix default matrix', () {
    test('includes all expected consistency checks', () {
      final result = _run();

      expect(
        result.rows.map((row) => row.checkId).toList(),
        InternalSignalProfileConsistencyCheckId.values,
      );
      expect(
        result.totalChecks,
        InternalSignalProfileConsistencyCheckId.values.length,
      );
      expect(
        result.matrixStatus,
        InternalSignalProfileConsistencyMatrixStatus.consistentWithWarnings,
      );
      expect(result.blockerCount, 0);
      expect(result.criticalCount, 0);
      expect(result.safeForGuardedInternalExperiment, isTrue);
    });

    test('active tactical signal has support, dimension, and area', () {
      final result = _run();

      expect(
        result
            .row(
              InternalSignalProfileConsistencyCheckId
                  .activeSignalHasSupportCases,
            )
            .signalIds,
        contains(InternalNonLabelSignalId.tacticalPressureSignal),
      );
      expect(
        result
            .row(
              InternalSignalProfileConsistencyCheckId
                  .activeSignalHasSupportCases,
            )
            .supportCaseIds,
        contains('simple-tactical-capture-check'),
      );
      expect(
        result
            .row(
              InternalSignalProfileConsistencyCheckId
                  .activeSignalHasSourceDimension,
            )
            .relatedDimensionIds,
        contains(InternalNonLabelScoringDimensionId.tacticalPressureDimension),
      );
      expect(
        result
            .row(
              InternalSignalProfileConsistencyCheckId
                  .activeSignalHasEvidenceArea,
            )
            .relatedAreaIds,
        contains(InternalEvidenceAreaId.tacticalArea),
      );
    });

    test('active material signal has support, dimension, and area', () {
      final result = _run();
      final supportRow = result.row(
        InternalSignalProfileConsistencyCheckId.activeSignalHasSupportCases,
      );
      final sourceRow = result.row(
        InternalSignalProfileConsistencyCheckId.activeSignalHasSourceDimension,
      );
      final areaRow = result.row(
        InternalSignalProfileConsistencyCheckId.activeSignalHasEvidenceArea,
      );

      expect(
        supportRow.signalIds,
        contains(InternalNonLabelSignalId.materialSwingSignal),
      );
      expect(supportRow.supportCaseIds, contains('queen-win-major-swing'));
      expect(
        sourceRow.relatedDimensionIds,
        contains(InternalNonLabelScoringDimensionId.materialSwingDimension),
      );
      expect(
        areaRow.relatedAreaIds,
        contains(InternalEvidenceAreaId.materialSwingArea),
      );
    });

    test('active forcing signal has support, dimension, and area', () {
      final result = _run();

      expect(
        result
            .row(
              InternalSignalProfileConsistencyCheckId
                  .activeSignalHasSupportCases,
            )
            .signalIds,
        contains(InternalNonLabelSignalId.forcingLineSignal),
      );
      expect(
        result
            .row(
              InternalSignalProfileConsistencyCheckId
                  .activeSignalHasSupportCases,
            )
            .supportCaseIds,
        contains('forcing-line-variation-hard-case'),
      );
      expect(
        result
            .row(
              InternalSignalProfileConsistencyCheckId
                  .activeSignalHasSourceDimension,
            )
            .relatedDimensionIds,
        contains(InternalNonLabelScoringDimensionId.forcingLineDimension),
      );
      expect(
        result
            .row(
              InternalSignalProfileConsistencyCheckId
                  .activeSignalHasEvidenceArea,
            )
            .relatedAreaIds,
        contains(InternalEvidenceAreaId.forcingLineArea),
      );
    });

    test('active candidate spread signal has support, dimension, and area', () {
      final result = _run();
      final row = result.row(
        InternalSignalProfileConsistencyCheckId
            .candidateSpreadSignalHasSpreadSupport,
      );

      expect(row.status, InternalSignalProfileConsistencyStatus.consistent);
      expect(row.severity, InternalSignalProfileConsistencySeverity.none);
      expect(
        row.signalIds,
        contains(InternalNonLabelSignalId.candidateSpreadSignal),
      );
      expect(
        row.relatedAreaIds,
        contains(InternalEvidenceAreaId.candidateSpreadArea),
      );
      expect(
        row.relatedBucketIds,
        contains(InternalEvidenceBucketId.candidateSpreadSupported),
      );
      expect(row.supportCaseIds, contains('mate-threat-fast-evidence'));
    });

    test('active PV and MultiPV signal has proof or PV support', () {
      final row = _run().row(
        InternalSignalProfileConsistencyCheckId
            .pvMultiPvSignalUsesProofOrPvSupport,
      );

      expect(row.status, InternalSignalProfileConsistencyStatus.consistent);
      expect(row.signalIds, [InternalNonLabelSignalId.pvMultiPvSupportSignal]);
      expect(row.relatedAreaIds, [InternalEvidenceAreaId.pvMultiPvArea]);
      expect(row.androidProofCaseIds, [
        'mate-threat-fast-evidence',
        'queen-win-major-swing',
        'simple-tactical-capture-check',
      ]);
    });

    test('Android proof confidence cites only the three proven IDs', () {
      final result = _run();
      final row = result.row(
        InternalSignalProfileConsistencyCheckId
            .androidProofSignalUsesCapturedIdsOnly,
      );

      expect(row.status, InternalSignalProfileConsistencyStatus.consistent);
      expect(row.severity, InternalSignalProfileConsistencySeverity.none);
      expect(result.provenAndroidCaseIds, [
        'mate-threat-fast-evidence',
        'queen-win-major-swing',
        'simple-tactical-capture-check',
      ]);
      expect(result.unprovenAndroidCaseIds, isEmpty);
      expect(row.androidProofCaseIds, result.provenAndroidCaseIds);
    });

    test('warning and partial signals keep caution context visible', () {
      final result = _run();
      final warningRow = result.row(
        InternalSignalProfileConsistencyCheckId.warningSignalHasWarningReason,
      );
      final partialRow = result.row(
        InternalSignalProfileConsistencyCheckId
            .partialSignalHasFuturePrerequisite,
      );

      expect(
        warningRow.status,
        InternalSignalProfileConsistencyStatus.consistentWithWarnings,
      );
      expect(
        warningRow.severity,
        InternalSignalProfileConsistencySeverity.warning,
      );
      expect(
        warningRow.signalIds,
        containsAll(<InternalNonLabelSignalId>[
          InternalNonLabelSignalId.kingSafetySignal,
          InternalNonLabelSignalId.endgameSupportSignal,
          InternalNonLabelSignalId.suppressionSafetySignal,
        ]),
      );
      expect(
        partialRow.signalIds,
        contains(InternalNonLabelSignalId.budgetRiskSignal),
      );
      expect(partialRow.warningReason, contains('future prerequisites'));
    });

    test('suppression safety signal preserves partial coverage reason', () {
      final row = _run().row(
        InternalSignalProfileConsistencyCheckId
            .suppressionSignalShowsPartialCoverage,
      );

      expect(
        row.status,
        InternalSignalProfileConsistencyStatus.consistentWithWarnings,
      );
      expect(row.severity, InternalSignalProfileConsistencySeverity.warning);
      expect(
        row.relatedAreaIds,
        contains(InternalEvidenceAreaId.budgetPressureArea),
      );
      expect(
        row.relatedAreaIds,
        contains(InternalEvidenceAreaId.openingSuppressionArea),
      );
      expect(row.warningReason, contains('partial subareas visible'));
    });

    test('budget risk signal remains warning-only or partial', () {
      final row = _run().row(
        InternalSignalProfileConsistencyCheckId
            .budgetRiskSignalStaysWarningOnly,
      );

      expect(
        row.status,
        InternalSignalProfileConsistencyStatus.consistentWithWarnings,
      );
      expect(row.severity, InternalSignalProfileConsistencySeverity.warning);
      expect(row.signalIds, [InternalNonLabelSignalId.budgetRiskSignal]);
      expect(row.supportCaseIds, [
        'budget-pressure-candidates',
        'budget-pressure-wide-candidate-32e',
      ]);
    });

    test('quiet, blocked, and future-only signals are correct', () {
      final result = _run();

      expect(
        result
            .row(
              InternalSignalProfileConsistencyCheckId
                  .quietPreparatorySignalRemainsExcluded,
            )
            .status,
        InternalSignalProfileConsistencyStatus.excludedCorrectly,
      );
      expect(
        result
            .row(
              InternalSignalProfileConsistencyCheckId
                  .productLabelSignalRemainsBlocked,
            )
            .status,
        InternalSignalProfileConsistencyStatus.blockedCorrectly,
      );
      expect(
        result
            .row(
              InternalSignalProfileConsistencyCheckId
                  .advancedLabelSignalRemainsBlocked,
            )
            .status,
        InternalSignalProfileConsistencyStatus.blockedCorrectly,
      );
      expect(
        result
            .row(
              InternalSignalProfileConsistencyCheckId
                  .officialMetricSignalRemainsBlocked,
            )
            .status,
        InternalSignalProfileConsistencyStatus.blockedCorrectly,
      );
      expect(
        result
            .row(
              InternalSignalProfileConsistencyCheckId
                  .cpLossSignalRemainsFutureOnly,
            )
            .status,
        InternalSignalProfileConsistencyStatus.futureOnlyCorrectly,
      );
      expect(
        result
            .row(
              InternalSignalProfileConsistencyCheckId
                  .winProbabilitySignalRemainsFutureOnly,
            )
            .status,
        InternalSignalProfileConsistencyStatus.futureOnlyCorrectly,
      );
    });
  });

  group('InternalSignalProfileConsistencyMatrix validator seams', () {
    test('unproven Android proof ID is rejected', () {
      final result = _run(
        profileResult: _withSignal(
          InternalNonLabelSignalId.androidProofConfidenceSignal,
          (signal) => signal.copyWith(
            androidProofCaseIds: <String>[
              ...signal.androidProofCaseIds,
              'unproven-proof-case',
            ],
          ),
        ),
      );

      expect(
        result
            .row(
              InternalSignalProfileConsistencyCheckId
                  .androidProofSignalUsesCapturedIdsOnly,
            )
            .status,
        InternalSignalProfileConsistencyStatus.inconsistent,
      );
      expect(result.blockerCount, greaterThan(0));
      expect(result.safeForGuardedInternalExperiment, isFalse);
      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('unprovenAndroidProofCitation'),
      );
    });

    test('active signal without support becomes blocker', () {
      final result = _run(
        profileResult: _withSignal(
          InternalNonLabelSignalId.tacticalPressureSignal,
          (signal) => signal.copyWith(supportingCaseIds: <String>[]),
        ),
      );

      expect(
        result
            .row(
              InternalSignalProfileConsistencyCheckId
                  .activeSignalHasSupportCases,
            )
            .status,
        InternalSignalProfileConsistencyStatus.missingSupport,
      );
      expect(result.blockerCount, greaterThan(0));
      expect(
        result.matrixStatus,
        InternalSignalProfileConsistencyMatrixStatus.blockedByValidation,
      );
    });

    test('active signal without source dimension becomes blocker', () {
      final result = _run(
        profileResult: _withSignal(
          InternalNonLabelSignalId.materialSwingSignal,
          (signal) => signal.copyWith(
            sourceDimensionIds: <InternalNonLabelScoringDimensionId>[],
          ),
        ),
      );

      expect(
        result
            .row(
              InternalSignalProfileConsistencyCheckId
                  .activeSignalHasSourceDimension,
            )
            .status,
        InternalSignalProfileConsistencyStatus.inconsistent,
      );
      expect(result.blockerCount, greaterThan(0));
    });

    test('warning signal without warning reason becomes blocker', () {
      final result = _run(
        profileResult: _withSignal(
          InternalNonLabelSignalId.kingSafetySignal,
          (signal) => signal.copyWith(
            warningReasons: <String>[],
            futurePrerequisites: <String>[],
          ),
        ),
      );

      expect(
        result
            .row(
              InternalSignalProfileConsistencyCheckId
                  .warningSignalHasWarningReason,
            )
            .status,
        InternalSignalProfileConsistencyStatus.inconsistent,
      );
      expect(result.blockerCount, greaterThan(0));
    });

    test('partial signal without future prerequisite becomes blocker', () {
      final result = _run(
        profileResult: _withSignal(
          InternalNonLabelSignalId.budgetRiskSignal,
          (signal) => signal.copyWith(futurePrerequisites: <String>[]),
        ),
      );

      expect(
        result
            .row(
              InternalSignalProfileConsistencyCheckId
                  .partialSignalHasFuturePrerequisite,
            )
            .status,
        InternalSignalProfileConsistencyStatus.inconsistent,
      );
      expect(result.blockerCount, greaterThan(0));
    });

    test('label emission seam becomes critical', () {
      final result = _run(
        profileResult: _withSignal(
          InternalNonLabelSignalId.tacticalPressureSignal,
          (signal) => signal.copyWith(emitsClassifierLabel: true),
        ),
      );

      expect(
        result
            .row(InternalSignalProfileConsistencyCheckId.noSignalEmitsMoveLabel)
            .severity,
        InternalSignalProfileConsistencySeverity.critical,
      );
      expect(result.criticalCount, greaterThan(0));
      expect(result.hasUnsafeConsistencyPolicyViolation, isTrue);
    });

    test('numeric score seam becomes critical', () {
      final result = _run(
        profileResult: _withSignal(
          InternalNonLabelSignalId.materialSwingSignal,
          (signal) => signal.copyWith(hasNumericMoveScore: true),
        ),
      );

      expect(
        result
            .row(
              InternalSignalProfileConsistencyCheckId.noSignalEmitsNumericScore,
            )
            .severity,
        InternalSignalProfileConsistencySeverity.critical,
      );
      expect(result.criticalCount, greaterThan(0));
    });

    test('move ranking seam becomes critical', () {
      final result = _run(
        profileResult: _withSignal(
          InternalNonLabelSignalId.forcingLineSignal,
          (signal) => signal.copyWith(ranksMoves: true),
        ),
      );

      expect(
        result
            .row(InternalSignalProfileConsistencyCheckId.noSignalRanksMoves)
            .severity,
        InternalSignalProfileConsistencySeverity.critical,
      );
      expect(result.criticalCount, greaterThan(0));
    });

    test('official metric seam becomes critical', () {
      final result = _run(
        profileResult: _withSignal(
          InternalNonLabelSignalId.officialMetricSignalBlocked,
          (signal) => signal.copyWith(claimsOfficialMetrics: true),
        ),
      );

      expect(result.criticalCount, greaterThan(0));
      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('blockedSignalBecameActive'),
      );
    });

    test('quiet activation seam becomes critical', () {
      final result = _run(
        profileResult: _withSignal(
          InternalNonLabelSignalId.quietPreparatorySignalExcluded,
          (signal) => signal.copyWith(
            status: InternalNonLabelSignalStatus.active,
            quietScopeActive: true,
          ),
        ),
      );

      expect(
        result
            .row(
              InternalSignalProfileConsistencyCheckId
                  .quietPreparatorySignalRemainsExcluded,
            )
            .severity,
        InternalSignalProfileConsistencySeverity.critical,
      );
      expect(result.criticalCount, greaterThan(0));
    });
  });

  group('InternalSignalProfileConsistencyMatrix reports and guardrails', () {
    test('markdown report includes consistency table and warning rows', () {
      final report = _run().renderMarkdownReport();

      expect(report, contains('# Internal Signal Profile Consistency Matrix'));
      expect(report, contains('matrix status: consistentWithWarnings'));
      expect(report, contains('Consistency Check Table'));
      expect(report, contains('warningSignalHasWarningReason'));
      expect(report, contains('budgetRiskSignalStaysWarningOnly'));
      expect(report, contains('safe for guarded internal experiment: true'));
    });

    test(
      'markdown report includes support case IDs and Android proof validity',
      () {
        final report = _run().renderMarkdownReport();

        expect(report, contains('Support Cases'));
        expect(report, contains('simple-tactical-capture-check'));
        expect(report, contains('mate-threat-fast-evidence'));
        expect(report, contains('Android Proof Validity'));
        expect(report, contains('unproven case IDs: -'));
      },
    );

    test('json report is deterministic and valid', () {
      final first = _run().renderJsonReport();
      final second = _run().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(
        decoded['version'],
        internalSignalProfileConsistencyMatrixReportVersion,
      );
      expect(decoded['matrixStatus'], 'consistentWithWarnings');
      expect(decoded['rows'], isA<List<Object?>>());
      expect(decoded['safeForGuardedInternalExperiment'], true);
    });

    test('reports contain no raw UCI spam or PV line dumps', () {
      final report = _run().renderMarkdownReport();
      final findings = const InternalSignalProfileConsistencyMatrixValidator()
          .validateReportText(report);

      expect(findings, isEmpty);
      expect(report, isNot(contains('uciok')));
      expect(report, isNot(contains('readyok')));
      expect(report, isNot(contains('info depth')));
      expect(report, isNot(contains('bestmove e2e4')));
      expect(report, isNot(contains(' pv ')));
      expect(report, isNot(contains('pvMoves')));
    });

    test('reports do not emit final labels or official metric names', () {
      final report = _run().renderMarkdownReport();

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
    });

    test('reports contain no numeric move score or move ranking output', () {
      final report = _run().renderMarkdownReport();

      expect(report, contains('numeric score values emitted: false'));
      expect(report, isNot(contains('numeric move score:')));
      expect(report, isNot(contains('scoreValue')));
      expect(report, isNot(contains('moveScore')));
      expect(report, isNot(contains('rankedMoves')));
      expect(report, isNot(contains('moveRanking')));
    });

    test('source imports stay pure and local-only', () {
      final source = File(
        'lib/features/pgn_review/application/internal_signal_profile_consistency_matrix.dart',
      ).readAsStringSync();
      final imports = _imports(source);

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
    });
  });
}

InternalSignalProfileConsistencyMatrixResult _run({
  InternalNonLabelSignalProfileResult? profileResult,
}) {
  return const InternalSignalProfileConsistencyMatrix().evaluate(
    InternalSignalProfileConsistencyMatrixRequest(profileResult: profileResult),
  );
}

InternalNonLabelSignalProfileResult _profile() {
  return const InternalNonLabelSignalProfilePrototype().evaluate(
    const InternalNonLabelSignalProfileRequest(),
  );
}

InternalNonLabelSignalProfileResult _withSignal(
  InternalNonLabelSignalId id,
  InternalNonLabelSignalProfileEntry Function(
    InternalNonLabelSignalProfileEntry signal,
  )
  mutate,
) {
  final profile = _profile();
  final signals = profile.signals
      .map((signal) => signal.signalId == id ? mutate(signal) : signal)
      .toList(growable: false);
  return profile.copyWith(signals: signals);
}

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}

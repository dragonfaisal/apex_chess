@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_non_label_scoring_design.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InternalNonLabelScoringDesign default design', () {
    test('includes all expected dimensions', () {
      final result = _run();

      expect(
        result.status,
        InternalNonLabelScoringDesignStatus.designReadyWithWarnings,
      );
      expect(
        result.dimensionCount,
        InternalNonLabelScoringDimensionId.values.length,
      );
      expect(
        result.dimensions.map((dimension) => dimension.dimensionId).toSet(),
        InternalNonLabelScoringDimensionId.values.toSet(),
      );
      expect(result.validationFindings, isEmpty);
      expect(result.guardAllowed, isTrue);
    });

    test('tactical dimension is designReady with support cases', () {
      final dimension = _run().dimension(
        InternalNonLabelScoringDimensionId.tacticalPressureDimension,
      );

      expect(
        dimension.readiness,
        InternalNonLabelScoringDimensionReadiness.designReady,
      );
      expect(
        dimension.signalType,
        InternalNonLabelScoringSignalType.primarySignal,
      );
      expect(
        dimension.supportingCaseIds,
        containsAll([
          'simple-tactical-capture-check',
          'forcing-line-variation-hard-case',
          'mate-threat-fast-evidence',
        ]),
      );
    });

    test('material dimension is ready with support cases', () {
      final dimension = _run().dimension(
        InternalNonLabelScoringDimensionId.materialSwingDimension,
      );

      expect(
        dimension.readiness,
        anyOf(
          InternalNonLabelScoringDimensionReadiness.designReady,
          InternalNonLabelScoringDimensionReadiness.designReadyWithWarnings,
        ),
      );
      expect(
        dimension.supportingCaseIds,
        containsAll([
          'queen-win-major-swing',
          'sacrifice-compensation-hard-case',
          'material-sacrifice-compensation',
        ]),
      );
    });

    test('forcing-line dimension is ready with support cases', () {
      final dimension = _run().dimension(
        InternalNonLabelScoringDimensionId.forcingLineDimension,
      );

      expect(
        dimension.readiness,
        anyOf(
          InternalNonLabelScoringDimensionReadiness.designReady,
          InternalNonLabelScoringDimensionReadiness.designReadyWithWarnings,
        ),
      );
      expect(
        dimension.supportingCaseIds,
        containsAll([
          'forcing-line-variation-hard-case',
          'mate-threat-fast-evidence',
          'king-safety-mating-net-hard-case',
        ]),
      );
    });

    test('king-safety dimension is ready or warning-ready with support', () {
      final dimension = _run().dimension(
        InternalNonLabelScoringDimensionId.kingSafetyDimension,
      );

      expect(
        dimension.readiness,
        anyOf(
          InternalNonLabelScoringDimensionReadiness.designReady,
          InternalNonLabelScoringDimensionReadiness.designReadyWithWarnings,
        ),
      );
      expect(
        dimension.supportingCaseIds,
        containsAll([
          'king-safety-mating-net-hard-case',
          'mate-threat-fast-evidence',
        ]),
      );
    });

    test('endgame dimension is warning-ready or partial', () {
      final dimension = _run().dimension(
        InternalNonLabelScoringDimensionId.endgamePrecisionDimension,
      );

      expect(
        dimension.readiness,
        anyOf(
          InternalNonLabelScoringDimensionReadiness.designReadyWithWarnings,
          InternalNonLabelScoringDimensionReadiness.partialNeedsMoreCases,
        ),
      );
      expect(
        dimension.supportingCaseIds,
        containsAll([
          'technical-endgame-conservative',
          'endgame-precision-hard-case',
        ]),
      );
    });

    test('suppression safety dimension reflects partial subareas', () {
      final dimension = _run().dimension(
        InternalNonLabelScoringDimensionId.suppressionSafetyDimension,
      );

      expect(
        dimension.readiness,
        InternalNonLabelScoringDimensionReadiness.designReadyWithWarnings,
      );
      expect(
        dimension.supportingCaseIds,
        containsAll([
          'invalid-fen-safety',
          'quiet-opening-skip',
          'forced-move-skip',
          'budget-pressure-candidates',
        ]),
      );
      expect(dimension.warnings, isNotEmpty);
    });

    test('budget risk dimension is partialNeedsMoreCases', () {
      final dimension = _run().dimension(
        InternalNonLabelScoringDimensionId.budgetRiskDimension,
      );

      expect(
        dimension.readiness,
        InternalNonLabelScoringDimensionReadiness.partialNeedsMoreCases,
      );
      expect(
        dimension.signalType,
        InternalNonLabelScoringSignalType.riskSignal,
      );
      expect(dimension.supportingCaseIds, ['budget-pressure-candidates']);
    });

    test('candidate spread dimension is designReady', () {
      final dimension = _run().dimension(
        InternalNonLabelScoringDimensionId.candidateSpreadDimension,
      );

      expect(
        dimension.readiness,
        InternalNonLabelScoringDimensionReadiness.designReady,
      );
      expect(
        dimension.supportingCaseIds,
        containsAll([
          'simple-tactical-capture-check',
          'forcing-line-variation-hard-case',
          'mate-threat-fast-evidence',
        ]),
      );
    });

    test('PV and MultiPV dimension is limited to proof-backed cases', () {
      final dimension = _run().dimension(
        InternalNonLabelScoringDimensionId.pvMultiPvSupportDimension,
      );

      expect(
        dimension.readiness,
        InternalNonLabelScoringDimensionReadiness.designReady,
      );
      expect(
        dimension.supportingCaseIds,
        orderedEquals([
          'mate-threat-fast-evidence',
          'queen-win-major-swing',
          'simple-tactical-capture-check',
        ]),
      );
      expect(
        dimension.androidProofCaseIds,
        orderedEquals(dimension.supportingCaseIds),
      );
    });

    test('Android proof confidence includes only three proven IDs', () {
      final dimension = _run().dimension(
        InternalNonLabelScoringDimensionId.androidProofConfidenceDimension,
      );

      expect(
        dimension.readiness,
        InternalNonLabelScoringDimensionReadiness.designReady,
      );
      expect(
        dimension.androidProofCaseIds,
        orderedEquals([
          'mate-threat-fast-evidence',
          'queen-win-major-swing',
          'simple-tactical-capture-check',
        ]),
      );
      expect(
        dimension.androidProofCaseIds,
        isNot(contains('quiet-preparatory-hard-case')),
      );
    });

    test('quiet preparatory dimension is excluded', () {
      final result = _run();
      final dimension = result.dimension(
        InternalNonLabelScoringDimensionId.quietPreparatoryDimensionExcluded,
      );

      expect(
        dimension.readiness,
        InternalNonLabelScoringDimensionReadiness.excluded,
      );
      expect(
        dimension.signalType,
        InternalNonLabelScoringSignalType.excludedSignal,
      );
      expect(result.excludedScopeIds, contains('quiet-preparatory-uncertain'));
      expect(dimension.futurePrerequisites, isNotEmpty);
    });

    test('product, advanced, and official metric dimensions are blocked', () {
      final result = _run();

      expect(
        result
            .dimension(
              InternalNonLabelScoringDimensionId.productLabelDimensionBlocked,
            )
            .readiness,
        InternalNonLabelScoringDimensionReadiness.blockedByPolicy,
      );
      expect(
        result
            .dimension(
              InternalNonLabelScoringDimensionId.advancedLabelDimensionBlocked,
            )
            .readiness,
        InternalNonLabelScoringDimensionReadiness.blockedByPolicy,
      );
      expect(
        result
            .dimension(
              InternalNonLabelScoringDimensionId.officialMetricDimensionBlocked,
            )
            .readiness,
        InternalNonLabelScoringDimensionReadiness.blockedByPolicy,
      );
    });

    test('CP-loss and win-probability dimensions are future-only', () {
      final result = _run();

      expect(
        result
            .dimension(
              InternalNonLabelScoringDimensionId.cpLossDimensionFutureOnly,
            )
            .readiness,
        InternalNonLabelScoringDimensionReadiness.futureOnly,
      );
      expect(
        result
            .dimension(
              InternalNonLabelScoringDimensionId
                  .winProbabilityDimensionFutureOnly,
            )
            .readiness,
        InternalNonLabelScoringDimensionReadiness.futureOnly,
      );
      expect(result.cpLossComputationImplemented, isFalse);
      expect(result.winProbabilityComputationImplemented, isFalse);
    });

    test(
      'no dimension emits labels, metrics, scores, engine, UI, or storage',
      () {
        final result = _run();

        for (final dimension in result.dimensions) {
          expect(dimension.emitsProductLabel, isFalse);
          expect(dimension.emitsClassifierLabel, isFalse);
          expect(dimension.emitsFinalMoveLabel, isFalse);
          expect(dimension.hasNumericMoveScore, isFalse);
          expect(dimension.claimsOfficialMetrics, isFalse);
        }
        expect(result.productLabelsEmitted, isFalse);
        expect(result.classifierLabelsEmitted, isFalse);
        expect(result.finalMoveLabelsEmitted, isFalse);
        expect(result.officialMetricsAllowed, isFalse);
        expect(result.numericMoveScoresComputed, isFalse);
        expect(result.directEngineAccessUsed, isFalse);
        expect(result.uiOutputUsed, isFalse);
        expect(result.backendOutputUsed, isFalse);
        expect(result.persistenceUsed, isFalse);
        expect(result.hasUnsafeScoringDesignPolicyViolation, isFalse);
      },
    );
  });

  group('InternalNonLabelScoringDesign validator', () {
    test('rejects numeric score output when seam is mutated', () {
      final mutated = _withDimension(
        _run(),
        InternalNonLabelScoringDimensionId.tacticalPressureDimension,
        (dimension) => dimension.copyWith(hasNumericMoveScore: true),
      );

      final findings = const InternalNonLabelScoringDesignValidator().validate(
        mutated,
      );

      expect(
        findings.map((finding) => finding.id),
        contains('dimensionEmitsNumericScore'),
      );
    });

    test('rejects product labels when seam is mutated', () {
      final mutated = _withDimension(
        _run(),
        InternalNonLabelScoringDimensionId.tacticalPressureDimension,
        (dimension) => dimension.copyWith(emitsProductLabel: true),
      );

      final findings = const InternalNonLabelScoringDesignValidator().validate(
        mutated,
      );

      expect(
        findings.map((finding) => finding.id),
        contains('dimensionEmitsLabel'),
      );
    });

    test('rejects official metric activation', () {
      final mutated = _withDimension(
        _run(),
        InternalNonLabelScoringDimensionId.officialMetricDimensionBlocked,
        (dimension) => dimension.copyWith(claimsOfficialMetrics: true),
      );

      final findings = const InternalNonLabelScoringDesignValidator().validate(
        mutated,
      );

      expect(
        findings.map((finding) => finding.id),
        contains('dimensionClaimsOfficialMetric'),
      );
    });

    test('rejects quiet activation', () {
      final mutated = _withDimension(
        _run(),
        InternalNonLabelScoringDimensionId.quietPreparatoryDimensionExcluded,
        (dimension) => dimension.copyWith(
          readiness: InternalNonLabelScoringDimensionReadiness.designReady,
          quietScopeActive: true,
        ),
      );

      final findings = const InternalNonLabelScoringDesignValidator().validate(
        mutated,
      );

      expect(
        findings.map((finding) => finding.id),
        containsAll([
          'quietDimensionBecameActive',
          'quietDimensionNotExcluded',
        ]),
      );
    });

    test('rejects unproven Android proof support', () {
      final mutated = _withDimension(
        _run(),
        InternalNonLabelScoringDimensionId.androidProofConfidenceDimension,
        (dimension) => dimension.copyWith(
          androidProofCaseIds: [
            ...dimension.androidProofCaseIds,
            'quiet-preparatory-hard-case',
          ],
        ),
      );

      final findings = const InternalNonLabelScoringDesignValidator().validate(
        mutated,
      );

      expect(
        findings.map((finding) => finding.id),
        contains('unprovenAndroidProofSupport'),
      );
    });

    test('rejects designReady without support', () {
      final mutated = _withDimension(
        _run(),
        InternalNonLabelScoringDimensionId.tacticalPressureDimension,
        (dimension) => dimension.copyWith(
          supportingCaseIds: const <String>[],
          protectedSupportCaseIds: const <String>[],
          androidProofCaseIds: const <String>[],
        ),
      );

      final findings = const InternalNonLabelScoringDesignValidator().validate(
        mutated,
      );

      expect(
        findings.map((finding) => finding.id),
        contains('designReadyDimensionWithoutCases'),
      );
    });

    test('rejects forbidden emitted output names', () {
      final mutated = _withDimension(
        _run(),
        InternalNonLabelScoringDimensionId.tacticalPressureDimension,
        (dimension) => dimension.copyWith(
          emittedOutputNames: const <String>['finalMoveQuality'],
        ),
      );

      final findings = const InternalNonLabelScoringDesignValidator().validate(
        mutated,
      );

      expect(
        findings.map((finding) => finding.id),
        contains('forbiddenDimensionOutputName'),
      );
    });

    test('future computation activation is rejected', () {
      final mutated = _run().copyWith(cpLossComputationImplemented: true);

      final findings = const InternalNonLabelScoringDesignValidator().validate(
        mutated,
      );

      expect(
        findings.map((finding) => finding.id),
        contains('designOutputPolicyViolation'),
      );
    });
  });

  group('InternalNonLabelScoringDesign reports and guardrails', () {
    test('markdown report includes dimension table and prerequisites', () {
      final report = _run().renderMarkdownReport();

      expect(report, contains('# Internal Non-Label Scoring Design'));
      expect(
        report,
        contains('scoring design status: designReadyWithWarnings'),
      );
      expect(report, contains('Dimension Table'));
      expect(report, contains('qualitative signal types'));
      expect(report, contains('tacticalPressureDimension'));
      expect(report, contains('Future Prerequisites'));
      expect(report, contains('quiet-preparatory-uncertain'));
    });

    test('json report is deterministic and valid', () {
      final first = _run().renderJsonReport();
      final second = _run().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(decoded['version'], internalNonLabelScoringDesignReportVersion);
      expect(decoded['scoringDesignStatus'], 'designReadyWithWarnings');
      expect(decoded['dimensions'], isA<List<Object?>>());
    });

    test('markdown report is deterministic', () {
      expect(_run().renderMarkdownReport(), _run().renderMarkdownReport());
    });

    test('reports contain no raw UCI spam or PV dumps', () {
      final report = _run().renderMarkdownReport();
      final findings = const InternalNonLabelScoringDesignValidator()
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

    test('reports contain no numeric move score output', () {
      final report = _run().renderMarkdownReport();

      expect(report, contains('numeric score values emitted: false'));
      expect(report, isNot(contains('numeric move score:')));
      expect(report, isNot(contains('scoreValue')));
      expect(report, isNot(contains('moveScore')));
    });

    test('source imports stay pure and local-only', () {
      final imports = _imports(_designSource);

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

InternalNonLabelScoringDesignResult _run() {
  return const InternalNonLabelScoringDesign().evaluate(
    const InternalNonLabelScoringDesignRequest(),
  );
}

InternalNonLabelScoringDesignResult _withDimension(
  InternalNonLabelScoringDesignResult base,
  InternalNonLabelScoringDimensionId id,
  InternalNonLabelScoringDimensionDesign Function(
    InternalNonLabelScoringDimensionDesign,
  )
  update,
) {
  return base.copyWith(
    dimensions: [
      for (final dimension in base.dimensions)
        if (dimension.dimensionId == id) update(dimension) else dimension,
    ],
  );
}

String get _designSource => File(
  'lib/features/pgn_review/application/internal_non_label_scoring_design.dart',
).readAsStringSync();

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}

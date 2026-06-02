@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_bucket_experiment_guards.dart';
import 'package:apex_chess/features/pgn_review/application/internal_bucket_experiment_harness.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_area_coverage_matrix.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InternalEvidenceAreaCoverageMatrix default matrix', () {
    test('includes all expected evidence areas', () {
      final result = _run();

      expect(
        result.status,
        InternalEvidenceAreaCoverageMatrixStatus.readyWithWarnings,
      );
      expect(
        result.harnessStatus,
        InternalBucketExperimentHarnessStatus.completedInternalOnly,
      );
      expect(
        result.guardStatus,
        InternalBucketExperimentGuardStatus.allowedInternalOnly,
      );
      expect(result.guardAllowed, isTrue);
      expect(result.areaCount, InternalEvidenceAreaId.values.length);
      expect(
        result.entries.map((entry) => entry.areaId).toSet(),
        equals(InternalEvidenceAreaId.values.toSet()),
      );
      expect(result.validationFindings, isEmpty);
    });

    test('tactical area has support cases', () {
      final area = _run().area(InternalEvidenceAreaId.tacticalArea);

      expect(area.status, InternalEvidenceAreaCoverageStatus.strong);
      expect(
        area.supportCaseIds,
        containsAll([
          'simple-tactical-capture-check',
          'forcing-line-variation-hard-case',
          'mate-threat-fast-evidence',
        ]),
      );
      expect(
        area.recommendation,
        InternalEvidenceAreaGapRecommendation.keepStable,
      );
    });

    test('material area has support cases', () {
      final area = _run().area(InternalEvidenceAreaId.materialSwingArea);

      expect(area.status, InternalEvidenceAreaCoverageStatus.adequate);
      expect(
        area.supportCaseIds,
        containsAll([
          'queen-win-major-swing',
          'sacrifice-compensation-hard-case',
          'material-sacrifice-compensation',
        ]),
      );
    });

    test('forcing-line area has support cases', () {
      final area = _run().area(InternalEvidenceAreaId.forcingLineArea);

      expect(area.status, InternalEvidenceAreaCoverageStatus.adequate);
      expect(
        area.supportCaseIds,
        containsAll([
          'forcing-line-variation-hard-case',
          'mate-threat-fast-evidence',
          'king-safety-mating-net-hard-case',
        ]),
      );
    });

    test('king-safety area has support cases', () {
      final area = _run().area(InternalEvidenceAreaId.kingSafetyArea);

      expect(area.status, InternalEvidenceAreaCoverageStatus.adequate);
      expect(
        area.supportCaseIds,
        containsAll([
          'king-safety-mating-net-hard-case',
          'mate-threat-fast-evidence',
        ]),
      );
    });

    test('conservative endgame area has support cases', () {
      final area = _run().area(InternalEvidenceAreaId.conservativeEndgameArea);

      expect(area.status, InternalEvidenceAreaCoverageStatus.adequate);
      expect(
        area.supportCaseIds,
        containsAll([
          'endgame-precision-hard-case',
          'technical-endgame-conservative',
        ]),
      );
    });

    test(
      'safety suppression area has invalid/opening/forced/budget support',
      () {
        final area = _run().area(InternalEvidenceAreaId.safetySuppressionArea);

        expect(area.status, InternalEvidenceAreaCoverageStatus.strong);
        expect(
          area.supportCaseIds,
          containsAll([
            'invalid-fen-safety',
            'quiet-opening-skip',
            'forced-move-skip',
            'budget-pressure-candidates',
          ]),
        );
        expect(area.suppressionSupport, greaterThanOrEqualTo(4));
      },
    );

    test('Android-proof-backed area contains only three proven IDs', () {
      final area = _run().area(InternalEvidenceAreaId.androidProofBackedArea);

      expect(area.status, InternalEvidenceAreaCoverageStatus.adequate);
      expect(
        area.supportCaseIds,
        orderedEquals([
          'mate-threat-fast-evidence',
          'queen-win-major-swing',
          'simple-tactical-capture-check',
        ]),
      );
      expect(area.androidProofCaseIds, orderedEquals(area.supportCaseIds));
      expect(
        area.supportCaseIds,
        isNot(contains('quiet-preparatory-hard-case')),
      );
    });

    test('candidate-spread area maps to supported cases', () {
      final area = _run().area(InternalEvidenceAreaId.candidateSpreadArea);

      expect(area.status, InternalEvidenceAreaCoverageStatus.adequate);
      expect(
        area.supportCaseIds,
        containsAll([
          'simple-tactical-capture-check',
          'forcing-line-variation-hard-case',
          'king-safety-mating-net-hard-case',
          'sacrifice-compensation-hard-case',
          'mate-threat-fast-evidence',
        ]),
      );
    });

    test('PV and MultiPV area maps only to proof-backed cases', () {
      final area = _run().area(InternalEvidenceAreaId.pvMultiPvArea);

      expect(area.status, InternalEvidenceAreaCoverageStatus.adequate);
      expect(
        area.supportCaseIds,
        orderedEquals([
          'mate-threat-fast-evidence',
          'queen-win-major-swing',
          'simple-tactical-capture-check',
        ]),
      );
      expect(area.androidProofCaseIds, orderedEquals(area.supportCaseIds));
    });

    test('quiet preparatory area is excluded', () {
      final area = _run().area(
        InternalEvidenceAreaId.quietPreparatoryExcludedArea,
      );

      expect(area.status, InternalEvidenceAreaCoverageStatus.excluded);
      expect(area.isQuietScope, isTrue);
      expect(area.negativeGuardExclusion, isTrue);
      expect(area.supportCaseIds, contains('quiet-preparatory-hard-case'));
      expect(
        _run().excludedScopeIds,
        containsAll([
          'quiet-preparatory-uncertain',
          'quietPreparatoryEvidenceClassification',
        ]),
      );
    });

    test('product, advanced, and official metric areas are blocked', () {
      final result = _run();

      expect(
        result
            .area(InternalEvidenceAreaId.productLabelOutputBlockedArea)
            .status,
        InternalEvidenceAreaCoverageStatus.blockedByPolicy,
      );
      expect(
        result.area(InternalEvidenceAreaId.advancedLabelGateBlockedArea).status,
        InternalEvidenceAreaCoverageStatus.blockedByPolicy,
      );
      expect(
        result.area(InternalEvidenceAreaId.officialMetricsBlockedArea).status,
        InternalEvidenceAreaCoverageStatus.blockedByPolicy,
      );
    });

    test('CP-loss and win-probability areas are future-only', () {
      final result = _run();

      expect(
        result.area(InternalEvidenceAreaId.cpLossComputationBlockedArea).status,
        InternalEvidenceAreaCoverageStatus.futureOnly,
      );
      expect(
        result
            .area(InternalEvidenceAreaId.winProbabilityComputationBlockedArea)
            .status,
        InternalEvidenceAreaCoverageStatus.futureOnly,
      );
      expect(result.cpLossComputed, isFalse);
      expect(result.winProbabilityComputed, isFalse);
    });

    test(
      'matrix does not emit labels, metrics, engine, UI, backend, or storage',
      () {
        final result = _run();

        expect(result.productOutputEmitted, isFalse);
        expect(result.classifierLabelsEmitted, isFalse);
        expect(result.officialMetricsEmitted, isFalse);
        expect(result.cpLossComputed, isFalse);
        expect(result.winProbabilityComputed, isFalse);
        expect(result.directEngineAccessUsed, isFalse);
        expect(result.uiOutputUsed, isFalse);
        expect(result.backendOutputUsed, isFalse);
        expect(result.persistenceUsed, isFalse);
        expect(result.hasUnsafeMatrixPolicyViolation, isFalse);
      },
    );
  });

  group('InternalEvidenceAreaCoverageMatrix validator', () {
    test('strong or adequate area cannot have zero support cases', () {
      final mutated = _withArea(
        _run(),
        InternalEvidenceAreaId.tacticalArea,
        (entry) => entry.copyWith(
          supportCaseIds: const <String>[],
          protectedSupportCaseIds: const <String>[],
          androidProofCaseIds: const <String>[],
        ),
      );

      final findings = const InternalEvidenceAreaCoverageMatrixValidator()
          .validate(mutated);

      expect(
        findings.map((finding) => finding.id),
        contains('supportedAreaWithoutCases'),
      );
    });

    test('Android proof area rejects unproven case IDs', () {
      final mutated = _withArea(
        _run(),
        InternalEvidenceAreaId.androidProofBackedArea,
        (entry) => entry.copyWith(
          supportCaseIds: [
            ...entry.supportCaseIds,
            'quiet-preparatory-hard-case',
          ],
        ),
      );

      final findings = const InternalEvidenceAreaCoverageMatrixValidator()
          .validate(mutated);

      expect(
        findings.map((finding) => finding.id),
        contains('unprovenAndroidProofAreaCase'),
      );
    });

    test('quiet area cannot become active', () {
      final mutated = _withArea(
        _run(),
        InternalEvidenceAreaId.quietPreparatoryExcludedArea,
        (entry) =>
            entry.copyWith(status: InternalEvidenceAreaCoverageStatus.adequate),
      );

      final findings = const InternalEvidenceAreaCoverageMatrixValidator()
          .validate(mutated);

      expect(
        findings.map((finding) => finding.id),
        contains('quietAreaNotExcluded'),
      );
      expect(
        findings.map((finding) => finding.id),
        contains('areaBecameUnsafeOutput'),
      );
    });

    test('product-label area cannot become active', () {
      final mutated = _withArea(
        _run(),
        InternalEvidenceAreaId.productLabelOutputBlockedArea,
        (entry) => entry.copyWith(
          status: InternalEvidenceAreaCoverageStatus.adequate,
          supportCaseIds: const <String>['simple-tactical-capture-check'],
        ),
      );

      final findings = const InternalEvidenceAreaCoverageMatrixValidator()
          .validate(mutated);

      expect(
        findings.map((finding) => finding.id),
        contains('policyAreaNotBlocked'),
      );
    });

    test('classifier label seam is rejected when active', () {
      final mutated = _withArea(
        _run(),
        InternalEvidenceAreaId.tacticalArea,
        (entry) => entry.copyWith(isClassifierLabel: true),
      );

      final findings = const InternalEvidenceAreaCoverageMatrixValidator()
          .validate(mutated);

      expect(
        findings.map((finding) => finding.id),
        contains('areaBecameClassifierLabel'),
      );
    });

    test('implemented computation seams are rejected', () {
      final mutated = _run().copyWith(cpLossComputed: true);

      final findings = const InternalEvidenceAreaCoverageMatrixValidator()
          .validate(mutated);

      expect(
        findings.map((finding) => finding.id),
        contains('matrixOutputPolicyViolation'),
      );
    });

    test('gap recommendations are deterministic', () {
      final first = _run();
      final second = _run();

      expect(
        first.entries.map((entry) => entry.recommendation),
        orderedEquals(second.entries.map((entry) => entry.recommendation)),
      );
    });

    test('partial area recommends adding coverage', () {
      final area = _run().area(InternalEvidenceAreaId.budgetPressureArea);

      expect(area.status, InternalEvidenceAreaCoverageStatus.partial);
      expect(
        area.recommendation,
        anyOf(
          InternalEvidenceAreaGapRecommendation.addHandcraftedCase,
          InternalEvidenceAreaGapRecommendation.addFakeEvidence,
        ),
      );
    });

    test('blocked area recommends keeping policy block', () {
      final area = _run().area(
        InternalEvidenceAreaId.productLabelOutputBlockedArea,
      );

      expect(
        area.recommendation,
        InternalEvidenceAreaGapRecommendation.keepBlockedByPolicy,
      );
    });

    test('quiet excluded area recommends keeping negative guard', () {
      final area = _run().area(
        InternalEvidenceAreaId.quietPreparatoryExcludedArea,
      );

      expect(
        area.recommendation,
        InternalEvidenceAreaGapRecommendation.keepExcludedByNegativeGuard,
      );
    });

    test('future product field area recommends future input only', () {
      final area = _run().area(
        InternalEvidenceAreaId.winProbabilityComputationBlockedArea,
      );

      expect(
        area.recommendation,
        InternalEvidenceAreaGapRecommendation.futureProductInputOnly,
      );
    });
  });

  group('InternalEvidenceAreaCoverageMatrix reports and guardrails', () {
    test('markdown report includes area table, cases, and recommendations', () {
      final report = _run().renderMarkdownReport();

      expect(report, contains('# Internal Evidence Area Coverage Matrix'));
      expect(report, contains('matrix status: readyWithWarnings'));
      expect(report, contains('Area Table'));
      expect(report, contains('tacticalArea'));
      expect(report, contains('Support Cases'));
      expect(report, contains('Gaps And Recommendations'));
      expect(report, contains('quiet-preparatory-uncertain'));
    });

    test('json report is deterministic and valid', () {
      final first = _run().renderJsonReport();
      final second = _run().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(
        decoded['version'],
        internalEvidenceAreaCoverageMatrixReportVersion,
      );
      expect(decoded['matrixStatus'], 'readyWithWarnings');
      expect(decoded['harnessStatus'], 'completedInternalOnly');
      expect(decoded['guardStatus'], 'allowedInternalOnly');
      expect(decoded['areas'], isA<List<Object?>>());
    });

    test('reports contain no raw UCI spam or PV dumps', () {
      final report = _run().renderMarkdownReport();

      expect(report, isNot(contains('uciok')));
      expect(report, isNot(contains('readyok')));
      expect(report, isNot(contains('info depth')));
      expect(report, isNot(contains('bestmove e2e4')));
      expect(report, isNot(contains(' pv ')));
      expect(report, isNot(contains('pvMoves')));
      expect(report, isNot(contains('e2e4 e7e5')));
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

    test('source imports stay pure and local-only', () {
      final imports = _imports(_matrixSource);

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

InternalEvidenceAreaCoverageMatrixResult _run() {
  return const InternalEvidenceAreaCoverageMatrix().evaluate(
    const InternalEvidenceAreaCoverageMatrixRequest(),
  );
}

InternalEvidenceAreaCoverageMatrixResult _withArea(
  InternalEvidenceAreaCoverageMatrixResult base,
  InternalEvidenceAreaId id,
  InternalEvidenceAreaCoverageEntry Function(InternalEvidenceAreaCoverageEntry)
  update,
) {
  return base.copyWith(
    entries: [
      for (final entry in base.entries)
        if (entry.areaId == id) update(entry) else entry,
    ],
  );
}

String get _matrixSource => File(
  'lib/features/pgn_review/application/internal_evidence_area_coverage_matrix.dart',
).readAsStringSync();

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}

import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/game_level_deep_gating_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoldenAnalysisCases metadata', () {
    test('golden case IDs are unique', () {
      final ids = GoldenAnalysisCases.defaults.map((item) => item.id).toList();

      expect(ids.toSet(), hasLength(ids.length));
    });

    test('every case has a category and safe source metadata', () {
      for (final item in GoldenAnalysisCases.defaults) {
        expect(item.category, isA<GoldenAnalysisCategory>());
        expect(item.hasSource, isTrue, reason: item.id);
        expect(item.safety.licenseSafe, isTrue, reason: item.id);
        expect(item.safety.explicitlySafe, isTrue, reason: item.id);
      }
    });

    test('every non-invalid case has at least one motif tag', () {
      for (final item in GoldenAnalysisCases.defaults) {
        if (item.category == GoldenAnalysisCategory.invalidSafety) continue;
        expect(item.motifTags, isNotEmpty, reason: item.id);
      }
    });

    test('cases do not encode product labels or official metrics', () {
      for (final item in GoldenAnalysisCases.defaults) {
        expect(item.containsBlockedClaim, isFalse, reason: item.id);
      }
    });

    test('expanded motif tags are unique and stable', () {
      final wires = GoldenMotifTag.values.map((motif) => motif.wire).toList();

      expect(wires.toSet(), hasLength(wires.length));
      expect(
        wires,
        containsAll(const [
          'sacrifice',
          'temporarySacrifice',
          'exchangeSacrifice',
          'pieceSacrifice',
          'materialCompensation',
          'queenWin',
          'rookWin',
          'pieceWin',
          'pawnBreakthrough',
          'mateThreat',
          'forcedMate',
          'backRankWeakness',
          'exposedKing',
          'kingHunt',
          'matingNet',
          'forcingLine',
          'checkSequence',
          'zwischenzug',
          'fork',
          'pin',
          'skewer',
          'discoveredAttack',
          'deflection',
          'decoy',
          'overload',
          'trappedPiece',
          'clearance',
          'interference',
          'removeDefender',
          'quietMove',
          'quietPreparatoryMove',
          'prophylaxis',
          'restriction',
          'outpost',
          'openFile',
          'passedPawn',
          'endgamePrecision',
          'onlyMove',
          'openingTheory',
          'invalidSafety',
          'budgetPressure',
          'evidenceIncomplete',
          'realDeviceProofNeeded',
        ]),
      );
    });

    test('existing cases use expanded motifs', () {
      final motifs = GoldenAnalysisCases.defaults
          .expand((item) => item.motifTags)
          .toSet();

      expect(motifs, contains(GoldenMotifTag.checkSequence));
      expect(motifs, contains(GoldenMotifTag.pieceSacrifice));
      expect(motifs, contains(GoldenMotifTag.exposedKing));
      expect(motifs, contains(GoldenMotifTag.matingNet));
      expect(motifs, contains(GoldenMotifTag.quietPreparatoryMove));
      expect(motifs, contains(GoldenMotifTag.evidenceIncomplete));
      expect(motifs, contains(GoldenMotifTag.passedPawn));
      expect(motifs, contains(GoldenMotifTag.realDeviceProofNeeded));
    });

    test('Phase 30W handcrafted cases are present and safe', () {
      final cases = _phase30wCases();

      expect(
        cases.map((item) => item.id),
        orderedEquals(const [
          'king-safety-mating-net-hard-case',
          'quiet-preparatory-hard-case',
          'sacrifice-compensation-hard-case',
          'endgame-precision-hard-case',
          'forcing-line-variation-hard-case',
        ]),
      );
      for (final item in cases) {
        expect(item.safety.licenseSafe, isTrue, reason: item.id);
        expect(item.safety.handcrafted, isTrue, reason: item.id);
        expect(item.safety.noFinalLabel, isTrue, reason: item.id);
        expect(item.containsBlockedClaim, isFalse, reason: item.id);
      }
    });
  });

  group('GoldenMotifEvidencePolicy', () {
    const policy = GoldenMotifEvidencePolicy();

    test('sacrifice motif requires material and compensation evidence', () {
      final requirement = policy.requirementsFor(const [
        GoldenMotifTag.sacrifice,
      ]);

      expect(
        requirement.evidence.evidenceGroups,
        contains(GoldenMotifEvidenceGroup.material),
      );
      expect(
        requirement.evidence.evidenceGroups,
        contains(GoldenMotifEvidenceGroup.tactical),
      );
      expect(requirement.evidence.requiresMaterialSwing, isTrue);
      expect(requirement.evidence.requiresMaterialCompensation, isTrue);
    });

    test(
      'mate-threat motif requires mate, king-safety, and forcing evidence',
      () {
        final requirement = policy.requirementsFor(const [
          GoldenMotifTag.mateThreat,
        ]);

        expect(
          requirement.evidence.evidenceGroups,
          contains(GoldenMotifEvidenceGroup.kingSafety),
        );
        expect(
          requirement.evidence.evidenceGroups,
          contains(GoldenMotifEvidenceGroup.forcing),
        );
        expect(requirement.evidence.requiresMateSignal, isTrue);
        expect(requirement.evidence.requiresKingSafetySignal, isTrue);
        expect(requirement.evidence.requiresForcingLineSignal, isTrue);
      },
    );

    test('quiet preparatory move does not force deep without evidence', () {
      final profile = policy.profileFor(GoldenMotifTag.quietPreparatoryMove);

      expect(profile.doesNotForceDeepByItself, isTrue);
      expect(
        policy.shouldForceDeepByItself(GoldenMotifTag.quietPreparatoryMove),
        isFalse,
      );
      expect(profile.evidence.requiresQuietMoveEvidence, isTrue);
    });

    test('opening theory expects suppression instead of deep work', () {
      final profile = policy.profileFor(GoldenMotifTag.openingTheory);

      expect(profile.metadataOnlySafe, isTrue);
      expect(profile.doesNotForceDeepByItself, isTrue);
      expect(profile.evidence.requiresSuppressionReason, isTrue);
      expect(
        profile.evidence.suppressionReasons,
        contains(DeepCandidateReasonCode.openingSuppressed),
      );
    });

    test('invalid safety expects rejection before engine evidence', () {
      final profile = policy.profileFor(GoldenMotifTag.invalidSafety);

      expect(profile.metadataOnlySafe, isTrue);
      expect(profile.evidence.requiresSuppressionReason, isTrue);
      expect(
        profile.evidence.suppressionReasons,
        contains(DeepCandidateReasonCode.invalidFenSuppressed),
      );
    });

    test('budget pressure expects suppression visibility', () {
      final profile = policy.profileFor(GoldenMotifTag.budgetPressure);

      expect(profile.evidence.requiresBudgetPressure, isTrue);
      expect(profile.evidence.requiresSuppressionReason, isTrue);
      expect(
        profile.evidence.suppressionReasons,
        contains(DeepCandidateReasonCode.budgetSuppressed),
      );
    });

    test('queen win expects material and major swing evidence', () {
      final profile = policy.profileFor(GoldenMotifTag.queenWin);

      expect(profile.evidence.requiresMaterialSwing, isTrue);
      expect(
        profile.evidence.materialReasons,
        contains(DeepCandidateReasonCode.materialSwing),
      );
      expect(
        profile.evidence.materialReasons,
        contains(DeepCandidateReasonCode.majorEvalSwing),
      );
    });
  });

  group('GoldenAnalysisSuiteRunner metadata', () {
    test('metadata-only runner passes valid cases', () {
      final result = const GoldenAnalysisSuiteRunner().run(
        const GoldenAnalysisSuiteRequest(),
      );

      expect(result.status, GoldenAnalysisSuiteStatus.passed);
      expect(result.caseCount, GoldenAnalysisCases.defaults.length);
      expect(result.failedCount, 0);
      expect(
        result.categoriesCovered,
        contains(GoldenAnalysisCategory.tacticalShot),
      );
      expect(result.motifCoverage[GoldenMotifTag.forcingLine], isNotNull);
      expect(
        result.behaviorCoverage[GoldenExpectedBehaviorCode
            .shouldNotEmitFinalLabel],
        greaterThan(0),
      );
    });

    test('duplicate ID fails', () {
      final duplicated = GoldenAnalysisCases.defaults.first;

      final result = const GoldenAnalysisSuiteRunner().run(
        GoldenAnalysisSuiteRequest(cases: [duplicated, duplicated]),
      );

      expect(result.status, GoldenAnalysisSuiteStatus.failed);
      expect(result.failures.join('\n'), contains('duplicated'));
    });

    test('missing source fails', () {
      final missingSource = GoldenAnalysisCases.defaults.first.copyWith(
        id: 'missing-source',
        clearFen: true,
      );

      final result = const GoldenAnalysisSuiteRunner().run(
        GoldenAnalysisSuiteRequest(cases: [missingSource]),
      );

      expect(result.status, GoldenAnalysisSuiteStatus.failed);
      expect(result.failures.join('\n'), contains('source is missing'));
    });
  });

  group('GoldenAnalysisSuiteRunner planning', () {
    test('invalid FEN case expects rejection before deep gating', () {
      final result = _runSingle('invalid-fen-safety');

      expect(result.passed, isTrue);
      expect(
        result.suppressionCounts,
        containsPair(DeepCandidateReasonCode.invalidFenSuppressed, 1),
      );
      expect(result.selectedDeepCount, 0);
    });

    test('opening skip case expects no deep', () {
      final result = _runSingle('quiet-opening-skip');

      expect(result.passed, isTrue);
      expect(
        result.suppressionCounts,
        containsPair(DeepCandidateReasonCode.openingSuppressed, 1),
      );
      expect(result.selectedDeepCount, 0);
    });

    test('forced skip case expects no deep when forced hint is supplied', () {
      final result = _runSingle('forced-move-skip');

      expect(result.passed, isTrue);
      expect(
        result.suppressionCounts,
        containsPair(DeepCandidateReasonCode.forcedSuppressed, 1),
      );
      expect(result.selectedDeepCount, 0);
    });

    test('tactical case expects a deep candidate', () {
      final result = _runSingle('simple-tactical-capture-check');

      expect(result.passed, isTrue);
      expect(result.candidateCount, 1);
      expect(result.selectedDeepCount, 1);
      expect(
        result.reasonCounts,
        containsPair(DeepCandidateReasonCode.tacticalSignal, 1),
      );
    });

    test('material sacrifice case expects material or tactical evidence', () {
      final result = _runSingle('material-sacrifice-compensation');

      expect(result.passed, isTrue);
      expect(
        result.reasonCounts,
        containsPair(DeepCandidateReasonCode.materialSwing, 1),
      );
    });

    test('mate-threat case uses fake evidence for mate signal', () {
      final result = _runSingle(
        'mate-threat-fast-evidence',
        mode: GoldenAnalysisSuiteMode.fakeEvidence,
      );

      expect(result.passed, isTrue);
      expect(
        result.reasonCounts,
        containsPair(DeepCandidateReasonCode.mateScoreDetected, 1),
      );
      expect(result.selectedDeepCount, 1);
    });

    test('quiet preparatory case does not fake deep without evidence', () {
      final result = _runSingle('quiet-preparatory-uncertain');

      expect(result.passed, isTrue);
      expect(result.candidateCount, 0);
      expect(result.selectedDeepCount, 0);
    });

    test('budget pressure case expects suppression visibility', () {
      final result = _runSingle('budget-pressure-candidates');

      expect(result.passed, isTrue);
      expect(result.candidateCount, greaterThan(result.selectedDeepCount));
      expect(
        result.suppressionCounts,
        containsPair(DeepCandidateReasonCode.budgetSuppressed, 2),
      );
    });

    test('endgame precision case remains conservative without evidence', () {
      final result = _runSingle('technical-endgame-conservative');

      expect(result.passed, isTrue);
      expect(result.candidateCount, 0);
      expect(result.selectedDeepCount, 0);
    });

    test('fake evidence mode satisfies default case expectations', () {
      final result = const GoldenAnalysisSuiteRunner().run(
        const GoldenAnalysisSuiteRequest(
          mode: GoldenAnalysisSuiteMode.fakeEvidence,
        ),
      );

      expect(result.failedCount, 0);
      expect(result.status, GoldenAnalysisSuiteStatus.passedWithWarnings);
      expect(result.casesRequiringFutureRealEngineProof, 1);
    });

    test(
      'king-safety mating-net case requires king-safety and forcing evidence',
      () {
        final item = _caseById('king-safety-mating-net-hard-case');
        final result = _runSingle(item.id);

        expect(result.passed, isTrue);
        expect(result.selectedDeepCount, 1);
        expect(
          item.expected.evidence.tactical.requiresKingSafetySignal,
          isTrue,
        );
        expect(
          item.expected.evidence.tactical.requiresForcingLineSignal,
          isTrue,
        );
        expect(
          result.reasonCounts,
          containsPair(DeepCandidateReasonCode.givesCheck, 1),
        );
      },
    );

    test('quiet preparatory hard case does not force deep by tag alone', () {
      final result = _runSingle('quiet-preparatory-hard-case');

      expect(result.passed, isTrue);
      expect(result.candidateCount, 0);
      expect(result.selectedDeepCount, 0);
    });

    test('sacrifice compensation hard case requires material evidence', () {
      final item = _caseById('sacrifice-compensation-hard-case');
      final result = _runSingle(item.id);

      expect(result.passed, isTrue);
      expect(item.expected.evidence.tactical.requiresMaterialSwing, isTrue);
      expect(
        item.expected.evidence.tactical.requiresMaterialCompensation,
        isTrue,
      );
      expect(
        result.reasonCounts,
        containsPair(DeepCandidateReasonCode.materialSwing, 1),
      );
    });

    test(
      'endgame precision hard case remains conservative without evidence',
      () {
        final result = _runSingle('endgame-precision-hard-case');

        expect(result.passed, isTrue);
        expect(result.candidateCount, 0);
        expect(result.selectedDeepCount, 0);
      },
    );

    test('forcing-line variation requires forcing and tactical evidence', () {
      final item = _caseById('forcing-line-variation-hard-case');
      final result = _runSingle(item.id);

      expect(result.passed, isTrue);
      expect(item.expected.evidence.tactical.requiresForcingLineSignal, isTrue);
      expect(
        result.reasonCounts,
        containsPair(DeepCandidateReasonCode.givesCheck, 1),
      );
      expect(
        result.reasonCounts,
        containsPair(DeepCandidateReasonCode.candidateEvalSpread, 1),
      );
    });

    test('plan-only mode performs no real engine calls', () {
      final result = const GoldenAnalysisSuiteRunner().run(
        const GoldenAnalysisSuiteRequest(
          mode: GoldenAnalysisSuiteMode.planOnly,
        ),
      );

      expect(result.caseResults, isNotEmpty);
      expect(_goldenSource, isNot(contains('LocalEvalService')));
      expect(_goldenSource, isNot(contains('stockfish_bridge')));
      expect(_goldenSource, isNot(contains('dart:ffi')));
    });

    test('performance profile can satisfy performance deep expectation', () {
      final item = _caseById('simple-tactical-capture-check').copyWith(
        expected: GoldenExpectedBehavior(
          behaviors: {
            GoldenExpectedBehaviorCode.shouldGenerateDeepCandidate,
            GoldenExpectedBehaviorCode.shouldSelectDeepUnderPerformance,
            GoldenExpectedBehaviorCode.shouldNotEmitFinalLabel,
          },
        ),
      );

      final result = const GoldenAnalysisSuiteRunner().run(
        GoldenAnalysisSuiteRequest(
          cases: [item],
          mode: GoldenAnalysisSuiteMode.planOnly,
          profile: LocalSchedulerProfile.performance,
        ),
      );

      expect(result.failedCount, 0);
      expect(result.caseResults.single.selectedDeepCount, 1);
    });
  });

  group('GoldenAnalysisSuite report and guardrails', () {
    test('golden report is deterministic and includes coverage', () {
      final result = const GoldenAnalysisSuiteRunner().run(
        const GoldenAnalysisSuiteRequest(
          mode: GoldenAnalysisSuiteMode.fakeEvidence,
        ),
      );

      expect(result.renderMarkdownReport(), result.renderMarkdownReport());
      expect(result.renderMarkdownReport(), contains('Category Coverage'));
      expect(result.renderMarkdownReport(), contains('Motif Coverage'));
      expect(result.renderMarkdownReport(), contains('Behavior Coverage'));
    });

    test('report contains no raw UCI or PV spam', () {
      final report = const GoldenAnalysisSuiteRunner()
          .run(
            const GoldenAnalysisSuiteRequest(
              mode: GoldenAnalysisSuiteMode.fakeEvidence,
            ),
          )
          .renderMarkdownReport();

      expect(report, isNot(contains('uciok')));
      expect(report, isNot(contains('readyok')));
      expect(report, isNot(contains('info depth')));
      expect(report, isNot(contains('bestmove e2e4')));
      expect(report, isNot(contains('pv ')));
    });

    test('report contains no product labels or official metrics', () {
      final report = const GoldenAnalysisSuiteRunner()
          .run(
            const GoldenAnalysisSuiteRequest(
              mode: GoldenAnalysisSuiteMode.fakeEvidence,
            ),
          )
          .renderMarkdownReport();

      expect(report, isNot(contains('Brilliant')));
      expect(report, isNot(contains('Great')));
      expect(report, isNot(contains('Miss')));
      expect(report, isNot(contains('ACPL')));
      expect(report, isNot(contains('accuracy')));
    });

    test('source guardrails stay local-only', () {
      expect(_goldenSource, isNot(contains('stockfish')));
      expect(_goldenSource, isNot(contains('Stockfish')));
      expect(_goldenSource, isNot(contains('dart:ffi')));
      expect(_goldenSource, isNot(contains('native')));
      expect(_goldenSource, isNot(contains('Widget')));
      expect(_goldenSource, isNot(contains('flutter/material')));
      expect(_goldenSource, isNot(contains('backend')));
      expect(_goldenSource, isNot(contains('preflight')));
      expect(_goldenSource, isNot(contains('server')));
      expect(_goldenSource, isNot(contains('database')));
      expect(_goldenSource, isNot(contains('cache')));
      expect(_goldenSource, isNot(contains('Brilliant')));
      expect(_goldenSource, isNot(contains('Great')));
      expect(_goldenSource, isNot(contains('Miss')));
      expect(_goldenSource, isNot(contains('ACPL')));
      expect(_goldenSource, isNot(contains('accuracy')));
    });
  });
}

GoldenAnalysisCaseResult _runSingle(
  String id, {
  GoldenAnalysisSuiteMode mode = GoldenAnalysisSuiteMode.planOnly,
}) {
  final result = const GoldenAnalysisSuiteRunner().run(
    GoldenAnalysisSuiteRequest(cases: [_caseById(id)], mode: mode),
  );
  expect(result.caseResults, hasLength(1));
  return result.caseResults.single;
}

GoldenAnalysisCase _caseById(String id) {
  return GoldenAnalysisCases.defaults.singleWhere((item) => item.id == id);
}

List<GoldenAnalysisCase> _phase30wCases() {
  const ids = [
    'king-safety-mating-net-hard-case',
    'quiet-preparatory-hard-case',
    'sacrifice-compensation-hard-case',
    'endgame-precision-hard-case',
    'forcing-line-variation-hard-case',
  ];
  return ids.map(_caseById).toList(growable: false);
}

String get _goldenSource => File(
  'lib/features/pgn_review/application/golden_analysis_suite.dart',
).readAsStringSync();

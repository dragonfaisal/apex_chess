@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/game_level_deep_gating_policy.dart';
import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/golden_evidence_review.dart';
import 'package:apex_chess/features/pgn_review/application/golden_evidence_review_report.dart';
import 'package:apex_chess/features/pgn_review/application/golden_evidence_triage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoldenAndroidProofEvidence fixture', () {
    test('contains exactly the three owner-proven case IDs', () {
      expect(
        _evidence.targetCaseIds,
        orderedEquals([
          'mate-threat-fast-evidence',
          'queen-win-major-swing',
          'simple-tactical-capture-check',
        ]),
      );
    });

    test('fixture file mirrors model identity and target IDs', () {
      final decoded = jsonDecode(_fixture.readAsStringSync()) as Map;

      expect(decoded['sourceId'], _evidence.sourceId);
      expect(decoded['proofVersion'], goldenAndroidProofEvidenceVersion);
      expect(decoded['targetCaseIds'], _evidence.targetCaseIds);
      expect(decoded['sourceNote'], contains('developer evidence only'));
    });

    test('balanced proof rows are preserved', () {
      final run = _run('balancedDefault');

      expect(run.status, 'completedWithWarnings');
      expect(run.targetCaseCount, 3);
      expect(run.executedTargetCount, 3);
      expect(run.selectedDeepCount, 3);
      expect(run.executedDeepCount, 3);
      expect(run.fastEngineCalls, 3);
      expect(run.deepEngineCalls, 6);
      expect(run.totalEngineCalls, 9);
      expect(run.elapsedMs, 1672);
      expect(run.caseRows, hasLength(3));
    });

    test('performance proof rows are preserved', () {
      final run = _run('performanceMeasured');

      expect(run.status, 'completedWithWarnings');
      expect(run.targetCaseCount, 3);
      expect(run.executedTargetCount, 3);
      expect(run.selectedDeepCount, 6);
      expect(run.executedDeepCount, 6);
      expect(run.fastEngineCalls, 6);
      expect(run.deepEngineCalls, 12);
      expect(run.totalEngineCalls, 18);
      expect(run.elapsedMs, 4505);
      expect(run.caseRows, hasLength(3));
    });

    test('stub, timeout, and failure counts are preserved as safe facts', () {
      expect(_evidence.stubIdentityDetected, isFalse);
      for (final run in _evidence.runs) {
        expect(run.timeoutCount, 0);
        expect(run.failureCount, 0);
        expect(run.budgetPressureCount, 0);
        expect(run.missingPvCount, 0);
        expect(run.insufficientMultiPvCount, 0);
        expect(run.failures, isEmpty);
      }
    });

    test('PV and MultiPV facts are preserved per proven case', () {
      for (final caseId in _evidence.targetCaseIds) {
        final row = _evidence.preferredRowFor(caseId)!;

        expect(row.pvPresent, isTrue);
        expect(row.multiPvLineCount, 3);
        expect(row.selectedDeepCount, 1);
        expect(row.executedDeepCount, 1);
        expect(row.proofStatus, 'proofCaptured');
      }
    });

    test('reason-code counts are preserved per proven case', () {
      expect(
        _evidence
            .reasonCountsFor('mate-threat-fast-evidence')
            .keys
            .map((reason) => reason.wire),
        containsAll(['candidateEvalSpread', 'givesCheck', 'tacticalSignal']),
      );
      expect(
        _evidence.reasonCountsFor('queen-win-major-swing'),
        containsPair(DeepCandidateReasonCode.materialSwing, 1),
      );
      expect(
        _evidence.reasonCountsFor('simple-tactical-capture-check'),
        containsPair(DeepCandidateReasonCode.captureOrPromotion, 1),
      );
    });

    test('rendered proof evidence is deterministic and safe', () {
      final first = _evidence.renderJson();
      final second = _evidence.renderJson();
      final markdown = _evidence.renderMarkdownSummary();

      expect(first, second);
      expect(markdown, contains('Android Proof Evidence'));
      expect(markdown, contains('s22-ultra-phase-30u-owner-queue'));
      expect(markdown, isNot(contains('uciok')));
      expect(markdown, isNot(contains('info depth')));
      expect(markdown, isNot(contains(' pv ')));
    });
  });

  group('Golden Android proof integration', () {
    test('review marks owner-proven cases real-device proof satisfied', () {
      for (final caseId in _evidence.targetCaseIds) {
        final review = _review(caseId);

        expect(review.realEngineEvidenceNeeded, isFalse);
        expect(
          review.status,
          anyOf(
            GoldenEvidenceReviewStatus.passed,
            GoldenEvidenceReviewStatus.passedWithWarnings,
          ),
        );
      }
    });

    test('review does not mark unproven cases as real-device proven', () {
      final unproven = _caseById(
        'mate-threat-fast-evidence',
      ).copyWith(id: 'mate-threat-unproven');
      final result = const GoldenEvidenceReviewRunner().review(
        GoldenEvidenceReviewRequest(
          cases: [unproven],
          mode: GoldenEvidenceReviewMode.realDeviceEvidenceReferenceOnly,
          requireAllEvidence: true,
        ),
      );

      expect(result.needsRealDeviceEvidenceCount, 1);
      expect(
        result.caseReviews.single.status,
        GoldenEvidenceReviewStatus.needsRealEngineEvidence,
      );
    });

    test('triage proof queue excludes the three proven cases', () {
      final triage = const GoldenEvidenceTriageRunner().run(
        const GoldenEvidenceTriageRequest(),
      );

      expect(triage.recommendedOwnerRunProofQueue.targetCaseIds, isEmpty);
      expect(triage.androidProofEvidenceCaseIds, _evidence.targetCaseIds);
    });

    test('incomplete quiet preparatory uncertainty remains visible', () {
      final triage = const GoldenEvidenceTriageRunner().run(
        const GoldenEvidenceTriageRequest(),
      );
      final quiet = triage.entries.singleWhere(
        (entry) => entry.caseId == 'quiet-preparatory-uncertain',
      );

      expect(
        quiet.currentReviewStatus,
        GoldenEvidenceReviewStatus.incompleteEvidence,
      );
      expect(quiet.nextAction, GoldenEvidenceTriageNextAction.addFakeEvidence);
    });

    test('weak motif group recommendations remain visible', () {
      final triage = const GoldenEvidenceTriageRunner().run(
        const GoldenEvidenceTriageRequest(),
      );

      expect(
        triage.weakMotifGroups.map((group) => group.group),
        contains(GoldenMotifGroup.kingSafetyAndMate),
      );
      expect(
        triage.recommendedNewHandcraftedHardCaseAreas.map((area) => area.id),
        contains('king-safety-mating-net-proof'),
      );
    });

    test('review report includes proof source summary', () {
      final result = const GoldenEvidenceReviewRunner().review(
        const GoldenEvidenceReviewRequest(),
      );
      final markdown = renderGoldenEvidenceReviewReportMarkdown(
        result,
        mode: GoldenEvidenceReviewMode.fakeEvidence,
      );
      final json =
          jsonDecode(
                renderGoldenEvidenceReviewReportJson(
                  result,
                  mode: GoldenEvidenceReviewMode.fakeEvidence,
                ),
              )
              as Map<String, Object?>;

      expect(markdown, contains('Android Proof Evidence'));
      expect(markdown, contains(_evidence.sourceId));
      expect(json['androidProofEvidence'], isA<Map<String, Object?>>());
    });

    test('triage report includes updated proof queue state', () {
      final triage = const GoldenEvidenceTriageRunner().run(
        const GoldenEvidenceTriageRequest(),
      );
      final markdown = triage.renderMarkdownReport();
      final json =
          jsonDecode(triage.renderJsonReport()) as Map<String, Object?>;
      final proofQueue = json['proofQueue'] as Map<String, Object?>;

      expect(markdown, contains('Proof Queue'));
      expect(markdown, contains('- none'));
      expect(proofQueue['targetCaseIds'], isEmpty);
      expect(json['androidProofEvidence'], isA<Map<String, Object?>>());
    });

    test('reports contain no blocked report content', () {
      final review = const GoldenEvidenceReviewRunner().review(
        const GoldenEvidenceReviewRequest(),
      );
      final report = [
        renderGoldenEvidenceReviewReportMarkdown(
          review,
          mode: GoldenEvidenceReviewMode.fakeEvidence,
        ),
        const GoldenEvidenceTriageRunner()
            .run(const GoldenEvidenceTriageRequest())
            .renderMarkdownReport(),
      ].join('\n');

      expect(report, isNot(contains('uciok')));
      expect(report, isNot(contains('readyok')));
      expect(report, isNot(contains('info depth')));
      expect(report, isNot(contains('bestmove e2e4')));
      expect(report, isNot(contains(' pv ')));
      expect(report, isNot(contains('Brilliant')));
      expect(report, isNot(contains('Great')));
      expect(report, isNot(contains('Miss')));
      expect(report, isNot(contains('ACPL')));
      expect(report, isNot(contains('accuracy')));
    });

    test('proof evidence source imports stay pure', () {
      final imports = _imports(_modelSource);

      expect(imports, isNot(contains('Stockfish')));
      expect(imports, isNot(contains('stockfish_bridge')));
      expect(imports, isNot(contains('dart:ffi')));
      expect(imports, isNot(contains('native')));
      expect(imports, isNot(contains('Widget')));
      expect(imports, isNot(contains('flutter/material')));
      expect(imports, isNot(contains('backend')));
      expect(imports, isNot(contains('preflight')));
      expect(imports, isNot(contains('server')));
      expect(imports, isNot(contains('database')));
      expect(imports, isNot(contains('cache')));
    });
  });
}

GoldenAndroidProofEvidence get _evidence =>
    GoldenAndroidProofEvidence.phase30uS22Ultra;

GoldenAndroidProofRunEvidence _run(String preset) {
  return _evidence.runs.singleWhere((run) => run.preset == preset);
}

GoldenEvidenceCaseReview _review(String caseId) {
  final item = _caseById(caseId);
  final result = const GoldenEvidenceReviewRunner().review(
    GoldenEvidenceReviewRequest(
      cases: [item],
      mode: GoldenEvidenceReviewMode.realDeviceEvidenceReferenceOnly,
      requireAllEvidence: true,
    ),
  );
  return result.caseReviews.single;
}

GoldenAnalysisCase _caseById(String id) {
  return GoldenAnalysisCases.defaults.singleWhere((item) => item.id == id);
}

File get _fixture => File(
  'test/fixtures/pgn_review/golden_android_proof/s22_ultra_phase_30u_owner_queue.json',
);

String get _modelSource => File(
  'lib/features/pgn_review/application/golden_android_proof_evidence.dart',
).readAsStringSync();

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}

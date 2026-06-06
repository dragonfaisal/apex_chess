@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/golden_evidence_review.dart';
import 'package:apex_chess/features/pgn_review/application/golden_evidence_triage.dart';
import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_scheduler.dart';
import 'package:apex_chess/features/pgn_review/application/quiet_preparatory_evidence.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoldenEvidenceTriageRunner', () {
    test('triage includes all golden cases', () {
      final result = _run();

      expect(result.totalCases, GoldenAnalysisCases.defaults.length);
      expect(result.totalCases, 20);
      expect(
        result.entries.map((entry) => entry.caseId),
        containsAll(GoldenAnalysisCases.defaults.map((item) => item.id)),
      );
    });

    test('protected cases get priority none', () {
      final result = _run();
      final entry = _entry(result, 'quiet-opening-skip');

      expect(entry.currentReviewStatus, GoldenEvidenceReviewStatus.passed);
      expect(entry.priority, GoldenEvidenceTriagePriority.none);
      expect(entry.nextAction, GoldenEvidenceTriageNextAction.keepProtected);
    });

    test('ordinary incomplete evidence produces fake-evidence action', () {
      final ordinaryIncomplete = _caseById('quiet-preparatory-uncertain')
          .copyWith(
            id: 'quiet-preparatory-ordinary-incomplete',
            evidenceIntent: GoldenEvidenceIntent.protectiveRegression,
          );
      final result = _run(cases: [ordinaryIncomplete]);
      final entry = _entry(result, 'quiet-preparatory-ordinary-incomplete');

      expect(
        entry.currentReviewStatus,
        GoldenEvidenceReviewStatus.incompleteEvidence,
      );
      expect(
        entry.quietEvidenceStatus,
        QuietPreparatoryEvidenceStatus.incompleteQuietEvidence,
      );
      expect(entry.priority, GoldenEvidenceTriagePriority.medium);
      expect(entry.nextAction, GoldenEvidenceTriageNextAction.addFakeEvidence);
      expect(entry.hasEvidenceGap, isTrue);
    });

    test('quiet negative guard is excluded from classifier scope', () {
      final result = _run();
      final entry = _entry(result, 'quiet-preparatory-uncertain');

      expect(
        entry.currentReviewStatus,
        GoldenEvidenceReviewStatus.negativeGuard,
      );
      expect(
        entry.quietEvidenceStatus,
        QuietPreparatoryEvidenceStatus.incompleteQuietEvidence,
      );
      expect(entry.priority, GoldenEvidenceTriagePriority.medium);
      expect(
        entry.nextAction,
        GoldenEvidenceTriageNextAction.excludeFromClassifierScope,
      );
      expect(entry.hasEvidenceGap, isFalse);
      expect(result.negativeGuardCases, contains(entry));
    });

    test('real-device-needed cases produce owner Android proof action', () {
      final unproven = _caseById(
        'mate-threat-fast-evidence',
      ).copyWith(id: 'mate-threat-unproven');
      final result = _run(cases: [unproven]);
      final entry = _entry(result, 'mate-threat-unproven');

      expect(entry.realDeviceProofRequired, isTrue);
      expect(entry.priority, GoldenEvidenceTriagePriority.high);
      expect(
        entry.nextAction,
        GoldenEvidenceTriageNextAction.runOwnerAndroidProof,
      );
    });

    test('unsafe claims become critical block action', () {
      final unsafe = _caseById('quiet-opening-skip').copyWith(
        id: 'unsafe-license-case',
        safety: const GoldenAnalysisSafetyFlags(licenseSafe: false),
      );

      final result = _run(cases: [unsafe]);
      final entry = result.entries.single;

      expect(entry.priority, GoldenEvidenceTriagePriority.critical);
      expect(entry.nextAction, GoldenEvidenceTriageNextAction.blockUnsafeClaim);
      expect(result.blockedUnsafeCases, hasLength(1));
    });

    test('behavior mismatch becomes high-priority investigation', () {
      final mismatch = _caseById('quiet-opening-skip').copyWith(
        id: 'opening-behavior-mismatch',
        inputs: const [LocalAnalysisPositionInput(fen: _fen)],
      );

      final result = _run(cases: [mismatch]);
      final entry = result.entries.single;

      expect(
        entry.currentReviewStatus,
        GoldenEvidenceReviewStatus.behaviorMismatch,
      );
      expect(entry.priority, GoldenEvidenceTriagePriority.high);
      expect(
        entry.nextAction,
        GoldenEvidenceTriageNextAction.investigateMismatch,
      );
    });

    test('budget mismatch becomes high-priority investigation', () {
      final base = _caseById('simple-tactical-capture-check');
      final mismatch = base.copyWith(
        id: 'budget-mismatch',
        expected: GoldenExpectedBehavior(
          behaviors: base.expected.behaviors,
          evidence: base.expected.evidence,
          maxSelectedDeepRatio: 0,
        ),
      );

      final result = _run(cases: [mismatch]);
      final entry = result.entries.single;

      expect(
        entry.currentReviewStatus,
        GoldenEvidenceReviewStatus.budgetMismatch,
      );
      expect(entry.priority, GoldenEvidenceTriagePriority.high);
      expect(
        entry.nextAction,
        GoldenEvidenceTriageNextAction.investigateMismatch,
      );
    });

    test('sacrifice evidence gap gets high priority', () {
      final weak = _caseById('material-sacrifice-compensation').copyWith(
        id: 'weak-sacrifice-evidence',
        inputs: const [LocalAnalysisPositionInput(fen: _fen)],
        fakeEvidence: const [],
      );

      final result = _run(cases: [weak]);
      final entry = result.entries.single;

      expect(
        entry.currentReviewStatus,
        GoldenEvidenceReviewStatus.incompleteEvidence,
      );
      expect(entry.priority, GoldenEvidenceTriagePriority.high);
      expect(entry.nextAction, GoldenEvidenceTriageNextAction.addFakeEvidence);
    });

    test('mate-threat evidence gap gets high priority', () {
      final weak = _caseById(
        'mate-threat-fast-evidence',
      ).copyWith(id: 'weak-mate-threat-evidence', fakeEvidence: const []);

      final result = _run(cases: [weak]);
      final entry = result.entries.single;

      expect(
        entry.currentReviewStatus,
        GoldenEvidenceReviewStatus.incompleteEvidence,
      );
      expect(entry.priority, GoldenEvidenceTriagePriority.high);
    });

    test('quiet preparatory uncertainty is visible but not protected', () {
      final result = _run();
      final entry = _entry(result, 'quiet-preparatory-uncertain');

      expect(entry.isProtected, isFalse);
      expect(
        entry.currentReviewStatus,
        GoldenEvidenceReviewStatus.negativeGuard,
      );
      expect(
        entry.evidenceGapGroups,
        contains(GoldenMotifEvidenceGroup.uncertainty),
      );
      expect(result.motifEvidenceGapCases, isNot(contains(entry)));
      expect(result.recommendedOwnerRunProofQueue.targetCaseIds, isEmpty);
    });

    test('weak motif groups are detected', () {
      final result = _run();

      expect(result.weakMotifGroups, isEmpty);
      expect(
        result.strongMotifGroups.map((group) => group.group),
        contains(GoldenMotifGroup.kingSafetyAndMate),
      );
    });

    test('proof queue excludes protected and fake-evidence-only cases', () {
      final result = _run();
      final ids = result.recommendedOwnerRunProofQueue.targetCaseIds;

      expect(ids, isNot(contains('quiet-opening-skip')));
      expect(ids, isNot(contains('quiet-preparatory-uncertain')));
      expect(ids, isNot(contains('mate-threat-fast-evidence')));
      expect(ids, isNot(contains('queen-win-major-swing')));
      expect(ids, isNot(contains('simple-tactical-capture-check')));
      expect(ids, isNot(contains('king-safety-mating-net-pressure-32e')));
      expect(ids, isNot(contains('endgame-precision-candidate-spread-32e')));
      expect(ids, isNot(contains('suppression-forced-only-legal-32e')));
      expect(ids, isNot(contains('budget-pressure-wide-candidate-32e')));
      expect(ids, isNot(contains('pv-multipv-support-boundary-32e')));
      expect(ids, isEmpty);
    });

    test('proof queue respects max target count', () {
      final result = _run(cases: _unprovenProofCases(), maxProofTargets: 2);

      expect(result.recommendedOwnerRunProofQueue.targets, hasLength(2));
    });

    test('proof queue order is deterministic', () {
      final first = _run();
      final second = _run();

      expect(
        first.recommendedOwnerRunProofQueue.targetCaseIds,
        second.recommendedOwnerRunProofQueue.targetCaseIds,
      );
      expect(first.recommendedOwnerRunProofQueue.targetCaseIds, isEmpty);

      final unproven = _run(cases: _unprovenProofCases());
      expect(
        unproven.recommendedOwnerRunProofQueue.targetCaseIds,
        orderedEquals([
          'mate-threat-unproven',
          'queen-win-unproven',
          'tactical-check-unproven',
        ]),
      );
    });

    test('suggested Android command is safe and not executed', () {
      final result = _run();
      final command =
          result.recommendedOwnerRunProofQueue.suggestedCommandGuidance;

      expect(command, contains('flutter test'));
      expect(command, contains('<android-device-id>'));
      expect(_triageSource, isNot(contains('Process.run')));
      expect(_triageSource, isNot(contains('Process.start')));
    });

    test('hard-case area recommendations are deterministic', () {
      final first = _run();
      final second = _run();

      expect(
        first.recommendedNewHandcraftedHardCaseAreas.map((area) => area.id),
        second.recommendedNewHandcraftedHardCaseAreas.map((area) => area.id),
      );
      expect(
        first.recommendedNewHandcraftedHardCaseAreas.map((area) => area.id),
        isNot(contains('quiet-preparatory-evidence')),
      );
      expect(
        first.recommendedNewHandcraftedHardCaseAreas.map((area) => area.id),
        isNot(contains('king-safety-mating-net-proof')),
      );
    });

    test('new hard cases are triaged without hiding uncertainty', () {
      final result = _run();

      expect(
        _entry(result, 'king-safety-mating-net-hard-case').isProtected,
        isTrue,
      );
      expect(
        _entry(result, 'sacrifice-compensation-hard-case').isProtected,
        isTrue,
      );
      expect(_entry(result, 'endgame-precision-hard-case').isProtected, isTrue);
      expect(
        _entry(result, 'forcing-line-variation-hard-case').isProtected,
        isTrue,
      );

      final quiet = _entry(result, 'quiet-preparatory-hard-case');
      expect(quiet.isProtected, isTrue);
      expect(quiet.currentReviewStatus, GoldenEvidenceReviewStatus.passed);
      expect(quiet.nextAction, GoldenEvidenceTriageNextAction.keepProtected);
      expect(
        quiet.quietEvidenceStatus,
        QuietPreparatoryEvidenceStatus.quietEvidenceProtected,
      );
      expect(
        quiet.quietEvidenceSupportGroups,
        contains(
          QuietPreparatoryEvidenceSupportGroup.candidateSpreadFutureThreat,
        ),
      );
    });

    test('Phase 32E targeted cases are protected triage inputs', () {
      final result = _run();

      for (final id in const <String>[
        'king-safety-mating-net-pressure-32e',
        'endgame-precision-candidate-spread-32e',
        'suppression-forced-only-legal-32e',
        'budget-pressure-wide-candidate-32e',
        'pv-multipv-support-boundary-32e',
      ]) {
        final entry = _entry(result, id);
        expect(entry.currentReviewStatus, GoldenEvidenceReviewStatus.passed);
        expect(entry.priority, GoldenEvidenceTriagePriority.none);
        expect(entry.nextAction, GoldenEvidenceTriageNextAction.keepProtected);
        expect(entry.realDeviceProofRequired, isFalse);
      }
      expect(result.recommendedOwnerRunProofQueue.targetCaseIds, isEmpty);
    });
  });

  group('GoldenEvidenceTriage report and guardrails', () {
    test('markdown report is deterministic', () {
      final first = _run().renderMarkdownReport();
      final second = _run().renderMarkdownReport();

      expect(first, second);
      expect(first, contains('Golden Evidence Triage'));
      expect(first, contains('Proof Queue'));
      expect(first, contains('Weak Motif Groups'));
      expect(first, contains('Quiet Preparatory Evidence'));
      expect(first, contains('total cases: 20'));
      expect(first, contains('forcingAndTactical: 13 case(s)'));
      expect(first, contains('kingSafetyAndMate: 3 case(s)'));
    });

    test('json report is valid and deterministic', () {
      final first = _run().renderJsonReport();
      final second = _run().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(decoded['version'], goldenEvidenceTriageReportVersion);
      expect(decoded['summary'], isA<Map<String, Object?>>());
      expect(decoded['proofQueue'], isA<Map<String, Object?>>());
      expect(decoded['quietPreparatoryEvidence'], isA<List<Object?>>());
    });

    test('report contains no raw UCI spam', () {
      final report = _run().renderMarkdownReport();

      expect(report, isNot(contains('uciok')));
      expect(report, isNot(contains('readyok')));
      expect(report, isNot(contains('info depth')));
      expect(report, isNot(contains('bestmove e2e4')));
    });

    test('report contains no PV dumps', () {
      final report = _run().renderMarkdownReport();

      expect(report, isNot(contains(' pv ')));
      expect(report, isNot(contains('pvMoves')));
      expect(report, isNot(contains('e2e4 e7e5')));
    });

    test('report contains no final quality labels', () {
      final report = _run().renderMarkdownReport();

      expect(report, isNot(contains('Brilliant')));
      expect(report, isNot(contains('Great')));
      expect(report, isNot(contains('Miss')));
    });

    test('report contains no official metric text', () {
      final report = _run().renderMarkdownReport();

      expect(report, isNot(contains('ACPL')));
      expect(report, isNot(contains('accuracy')));
    });

    test('source imports stay pure and local-only', () {
      final imports = _imports(_triageSource);

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

GoldenEvidenceTriageResult _run({
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  int maxProofTargets = 3,
}) {
  return const GoldenEvidenceTriageRunner().run(
    GoldenEvidenceTriageRequest(cases: cases, maxProofTargets: maxProofTargets),
  );
}

GoldenEvidenceTriageEntry _entry(GoldenEvidenceTriageResult result, String id) {
  return result.entries.singleWhere((entry) => entry.caseId == id);
}

GoldenAnalysisCase _caseById(String id) {
  return GoldenAnalysisCases.defaults.singleWhere((item) => item.id == id);
}

List<GoldenAnalysisCase> _unprovenProofCases() {
  return [
    _caseById('mate-threat-fast-evidence').copyWith(id: 'mate-threat-unproven'),
    _caseById('queen-win-major-swing').copyWith(id: 'queen-win-unproven'),
    _caseById(
      'simple-tactical-capture-check',
    ).copyWith(id: 'tactical-check-unproven'),
  ];
}

String get _triageSource => File(
  'lib/features/pgn_review/application/golden_evidence_triage.dart',
).readAsStringSync();

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}

const _fen =
    'rn1qkbnr/ppp2ppp/3b4/3pp3/4P3/2NP1N2/PPP2PPP/R1BQKB1R w KQkq - 2 5';

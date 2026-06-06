@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/game_level_deep_gating_policy.dart';
import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/golden_classifier_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_scheduler.dart';
import 'package:apex_chess/features/pgn_review/application/quiet_preparatory_evidence.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoldenClassifierReadinessGate default decision', () {
    test('readiness gate includes all current golden cases', () {
      final result = _run();

      expect(result.totalCaseCount, 20);
      expect(result.totalCaseCount, GoldenAnalysisCases.defaults.length);
    });

    test('reports protected rows, negative guard, and no incomplete rows', () {
      final result = _run();

      expect(result.protectedCount, 19);
      expect(result.negativeGuardCount, 1);
      expect(result.incompleteCount, 0);
      expect(
        result.negativeGuardCaseIds,
        orderedEquals(['quiet-preparatory-uncertain']),
      );
      expect(result.incompleteCaseIds, isEmpty);
    });

    test('reports no real-device-needed rows and empty owner proof queue', () {
      final result = _run();

      expect(result.realDeviceNeededCount, 0);
      expect(result.realDeviceNeededCaseIds, isEmpty);
      expect(result.ownerProofQueueCount, 0);
      expect(result.ownerProofQueueCaseIds, isEmpty);
    });

    test('product-facing labels remain blocked', () {
      final scope = _run().scope(GoldenClassifierScope.productFacingLabels);

      expect(scope.status, GoldenClassifierScopeStatus.blockedByPolicy);
      expect(scope.supportingCaseIds, isEmpty);
      expect(scope.recommendation, contains('blocked'));
    });

    test('advanced candidate gates remain blocked', () {
      final result = _run();

      expect(
        result.scope(GoldenClassifierScope.brilliantCandidateGate).status,
        GoldenClassifierScopeStatus.blockedByPolicy,
      );
      expect(
        result.scope(GoldenClassifierScope.greatMoveCandidateGate).status,
        GoldenClassifierScopeStatus.blockedByPolicy,
      );
      expect(
        result.scope(GoldenClassifierScope.missedWinCandidateGate).status,
        GoldenClassifierScopeStatus.blockedByPolicy,
      );
      expect(
        result.advancedLabelStatus,
        GoldenClassifierReadinessStatus.notReadyForAdvancedLabels,
      );
    });

    test('quiet preparatory scope is blocked by the negative guard', () {
      final scope = _run().scope(
        GoldenClassifierScope.quietPreparatoryFoundation,
      );

      expect(scope.status, GoldenClassifierScopeStatus.blockedByEvidence);
      expect(
        scope.missingCaseIds,
        orderedEquals(['quiet-preparatory-uncertain']),
      );
      expect(scope.supportingCaseIds, contains('quiet-preparatory-hard-case'));
      expect(scope.blockers.join('\n'), contains('negative guard'));
    });

    test('tactical material forcing and king-safety scopes are stronger', () {
      final result = _run();

      expect(
        result.scope(GoldenClassifierScope.tacticalCandidateFoundation).status,
        GoldenClassifierScopeStatus.allowedForDeveloperPrototype,
      );
      expect(
        result.scope(GoldenClassifierScope.materialSwingFoundation).status,
        GoldenClassifierScopeStatus.allowedForDeveloperPrototype,
      );
      expect(
        result.scope(GoldenClassifierScope.forcingLineFoundation).status,
        GoldenClassifierScopeStatus.allowedForDeveloperPrototype,
      );
      expect(
        result.scope(GoldenClassifierScope.kingSafetyFoundation).status,
        GoldenClassifierScopeStatus.allowedForDeveloperPrototype,
      );
      expect(
        result.scope(GoldenClassifierScope.productFacingLabels).status,
        GoldenClassifierScopeStatus.blockedByPolicy,
      );
    });

    test('basic foundation is developer-only and excludes quiet scope', () {
      final scope = _run().scope(
        GoldenClassifierScope.basicMoveQualityFoundation,
      );

      expect(
        scope.status,
        GoldenClassifierScopeStatus.allowedForDeveloperPrototype,
      );
      expect(scope.missingCaseIds, isEmpty);
      expect(
        scope.supportingCaseIds,
        isNot(contains('quiet-preparatory-uncertain')),
      );
      expect(
        scope.supportingCaseIds,
        isNot(contains('quiet-preparatory-hard-case')),
      );
      expect(scope.recommendation, contains('developer-only'));
      expect(scope.recommendation, contains('emit no labels'));
      expect(scope.recommendation, contains('exclude quiet/preparatory'));
    });

    test('endgame precision is design-only and not label-ready', () {
      final scope = _run().scope(
        GoldenClassifierScope.endgamePrecisionFoundation,
      );

      expect(scope.status, GoldenClassifierScopeStatus.allowedForDesignOnly);
      expect(
        scope.supportingCaseIds,
        containsAll([
          'technical-endgame-conservative',
          'endgame-precision-hard-case',
        ]),
      );
    });

    test('current default recommendation excludes quiet scope', () {
      final result = _run();

      expect(
        result.status,
        GoldenClassifierReadinessStatus.readyForLimitedClassifierFoundation,
      );
      expect(
        result.nextRecommendedPhase,
        GoldenClassifierNextPhase.basicClassifierFoundationDesignOnly,
      );
    });

    test(
      'quiet scope can become design-only when quiet cases are resolved',
      () {
        final result = _run(cases: _quietResolvedCases());
        final quietScope = result.scope(
          GoldenClassifierScope.quietPreparatoryFoundation,
        );
        final basicScope = result.scope(
          GoldenClassifierScope.basicMoveQualityFoundation,
        );

        expect(result.incompleteCount, 0);
        expect(result.negativeGuardCount, 0);
        expect(
          quietScope.status,
          GoldenClassifierScopeStatus.allowedForDesignOnly,
        );
        expect(
          quietScope.supportingCaseIds,
          containsAll([
            'quiet-preparatory-hard-case',
            'quiet-preparatory-uncertain',
          ]),
        );
        expect(
          basicScope.supportingCaseIds,
          contains('quiet-preparatory-uncertain'),
        );
        expect(
          result.nextRecommendedPhase,
          GoldenClassifierNextPhase.basicClassifierFoundationDesignOnly,
        );
      },
    );
  });

  group('GoldenClassifierReadinessGate proof and blocker behavior', () {
    test('existing Android proof supports only the three proven IDs', () {
      final result = _run();

      expect(result.capturedAndroidProofCount, 3);
      expect(
        result.capturedAndroidProofCaseIds,
        orderedEquals([
          'mate-threat-fast-evidence',
          'queen-win-major-swing',
          'simple-tactical-capture-check',
        ]),
      );
    });

    test('fake proof evidence is not treated as real Android proof', () {
      final result = _run(
        cases: [_caseById('mate-threat-fast-evidence')],
        proof: _hostOnlyProofForMateThreat,
      );

      expect(result.capturedAndroidProofCount, 0);
      expect(result.realDeviceNeededCount, 1);
      expect(
        result.status,
        GoldenClassifierReadinessStatus.blockedByRealDeviceProof,
      );
    });

    test('unsafe claim rows block all classifier readiness', () {
      final result = _run(cases: [_unsafeCase()]);

      expect(result.unsafeCount, 1);
      expect(
        result.status,
        GoldenClassifierReadinessStatus.blockedByUnsafeClaim,
      );
      for (final scope in result.scopes.where(
        (scope) => !_policyScope(scope),
      )) {
        expect(scope.status, GoldenClassifierScopeStatus.blockedByEvidence);
      }
    });

    test('behavior mismatch rows block classifier readiness', () {
      final mismatch = _caseById('quiet-opening-skip').copyWith(
        id: 'opening-behavior-mismatch',
        inputs: const [LocalAnalysisPositionInput(fen: _fen)],
      );
      final result = _run(cases: [mismatch]);

      expect(result.behaviorMismatchCount, 1);
      expect(result.status, GoldenClassifierReadinessStatus.blockedByMismatch);
      expect(
        result.nextRecommendedPhase,
        GoldenClassifierNextPhase.mismatchInvestigation,
      );
    });

    test('budget mismatch rows block classifier readiness', () {
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

      expect(result.budgetMismatchCount, 1);
      expect(result.status, GoldenClassifierReadinessStatus.blockedByMismatch);
    });

    test('non-empty proof queue blocks affected scopes', () {
      final result = _run(cases: [_unprovenMateThreat()]);
      final scope = result.scope(GoldenClassifierScope.kingSafetyFoundation);

      expect(result.ownerProofQueueCount, 1);
      expect(result.realDeviceNeededCount, 1);
      expect(scope.status, GoldenClassifierScopeStatus.blockedByMissingProof);
      expect(scope.missingCaseIds, contains('mate-threat-unproven'));
      expect(
        result.nextRecommendedPhase,
        GoldenClassifierNextPhase.ownerAndroidProofQueue,
      );
    });

    test('negative guard blocks only relevant quiet scope', () {
      final result = _run();

      expect(
        result.scope(GoldenClassifierScope.quietPreparatoryFoundation).status,
        GoldenClassifierScopeStatus.blockedByEvidence,
      );
      expect(
        result
            .scope(GoldenClassifierScope.quietPreparatoryFoundation)
            .blockers
            .join('\n'),
        contains('negative guard'),
      );
      expect(
        result.scope(GoldenClassifierScope.tacticalCandidateFoundation).status,
        GoldenClassifierScopeStatus.allowedForDeveloperPrototype,
      );
      expect(
        result.scope(GoldenClassifierScope.materialSwingFoundation).status,
        GoldenClassifierScopeStatus.allowedForDeveloperPrototype,
      );
    });

    test('scope support lists include relevant protected case IDs', () {
      final result = _run();

      expect(
        result
            .scope(GoldenClassifierScope.tacticalCandidateFoundation)
            .supportingCaseIds,
        contains('forcing-line-variation-hard-case'),
      );
      expect(
        result
            .scope(GoldenClassifierScope.materialSwingFoundation)
            .supportingCaseIds,
        contains('queen-win-major-swing'),
      );
      expect(
        result
            .scope(GoldenClassifierScope.kingSafetyFoundation)
            .supportingCaseIds,
        contains('king-safety-mating-net-hard-case'),
      );
      expect(
        result
            .scope(GoldenClassifierScope.forcingLineFoundation)
            .supportingCaseIds,
        contains('forcing-line-variation-hard-case'),
      );
    });
  });

  group('GoldenClassifierReadinessGate reports and guardrails', () {
    test('markdown report is deterministic', () {
      final first = _run().renderMarkdownReport();
      final second = _run().renderMarkdownReport();

      expect(first, second);
      expect(first, contains('Golden Classifier Readiness Gate'));
      expect(first, contains('Scope Readiness'));
    });

    test('json report is deterministic and valid', () {
      final first = _run().renderJsonReport();
      final second = _run().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(decoded['version'], goldenClassifierReadinessReportVersion);
      expect(decoded['summary'], isA<Map<String, Object?>>());
      expect(decoded['scopes'], isA<List<Object?>>());
    });

    test('report includes captured proof count and per-scope readiness', () {
      final report = _run().renderMarkdownReport();

      expect(report, contains('captured Android proof count: 3'));
      expect(report, contains('basicMoveQualityFoundation'));
      expect(report, contains('quietPreparatoryFoundation'));
      expect(report, contains('productFacingLabels'));
    });

    test('report includes next recommended phase', () {
      final report = _run().renderMarkdownReport();

      expect(report, contains('Next Recommended Phase'));
      expect(
        report,
        contains(
          'Phase 31A -- Basic Classifier Foundation Design With Quiet Scope Excluded',
        ),
      );
    });

    test('report includes negative guard count and case IDs', () {
      final result = _run();
      final report = result.renderMarkdownReport();
      final decoded =
          jsonDecode(result.renderJsonReport()) as Map<String, Object?>;
      final summary = decoded['summary'] as Map<String, Object?>;

      expect(report, contains('negative guard count: 1'));
      expect(report, contains('quiet-preparatory-uncertain'));
      expect(summary['negativeGuardCount'], 1);
      expect(
        decoded['negativeGuardCaseIds'],
        orderedEquals(['quiet-preparatory-uncertain']),
      );
    });

    test('report includes quiet evidence status and support groups', () {
      final result = _run();
      final report = result.renderMarkdownReport();
      final decoded =
          jsonDecode(result.renderJsonReport()) as Map<String, Object?>;

      expect(report, contains('Quiet Preparatory Evidence'));
      expect(report, contains('quietEvidenceProtected'));
      expect(report, contains('candidateSpreadFutureThreat'));
      expect(decoded['quietPreparatoryEvidence'], isA<List<Object?>>());
    });

    test('report contains no raw UCI spam or PV dumps', () {
      final report = _run().renderMarkdownReport();

      expect(report, isNot(contains('uciok')));
      expect(report, isNot(contains('readyok')));
      expect(report, isNot(contains('info depth')));
      expect(report, isNot(contains('bestmove e2e4')));
      expect(report, isNot(contains(' pv ')));
      expect(report, isNot(contains('pvMoves')));
      expect(report, isNot(contains('e2e4 e7e5')));
    });

    test('report does not emit final labels or official metrics', () {
      final report = _run().renderMarkdownReport();

      expect(report, isNot(contains('Brilliant')));
      expect(report, isNot(contains('Great')));
      expect(report, isNot(contains('Miss')));
      expect(report, isNot(contains('ACPL')));
      expect(report, isNot(contains('accuracy')));
      expect(report, isNot(contains('final move label')));
    });

    test('report does not claim advanced candidate gates are ready', () {
      final result = _run();
      final report = result.renderMarkdownReport();

      expect(result.hasUnsafeReadinessClaim, isFalse);
      expect(
        report,
        isNot(
          contains('brilliantCandidateGate | allowedForDeveloperPrototype'),
        ),
      );
      expect(
        report,
        isNot(
          contains('greatMoveCandidateGate | allowedForDeveloperPrototype'),
        ),
      );
      expect(
        report,
        isNot(
          contains('missedWinCandidateGate | allowedForDeveloperPrototype'),
        ),
      );
    });

    test('source imports stay pure and local-only', () {
      final imports = _imports(_gateSource);

      expect(imports, isNot(contains('Stockfish')));
      expect(imports, isNot(contains('stockfish_bridge')));
      expect(imports, isNot(contains('dart:ffi')));
      expect(imports, isNot(contains('native')));
      expect(imports, isNot(contains('Widget')));
      expect(imports, isNot(contains('flutter/material')));
      expect(imports, isNot(contains('backend')));
      expect(imports, isNot(contains('preflight')));
      expect(imports, isNot(contains('server')));
      expect(imports, isNot(contains('persistence')));
      expect(imports, isNot(contains('database')));
      expect(imports, isNot(contains('cache')));
      expect(imports, isNot(contains('LocalEvalService')));
    });
  });
}

GoldenClassifierReadinessResult _run({
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  GoldenAndroidProofEvidence? proof =
      GoldenAndroidProofEvidence.phase30uS22Ultra,
}) {
  return const GoldenClassifierReadinessGate().evaluate(
    GoldenClassifierReadinessRequest(cases: cases, androidProofEvidence: proof),
  );
}

bool _policyScope(GoldenClassifierScopeReadiness scope) {
  return scope.scope == GoldenClassifierScope.productFacingLabels ||
      scope.scope == GoldenClassifierScope.brilliantCandidateGate ||
      scope.scope == GoldenClassifierScope.greatMoveCandidateGate ||
      scope.scope == GoldenClassifierScope.missedWinCandidateGate;
}

GoldenAnalysisCase _unsafeCase() {
  return _caseById('quiet-opening-skip').copyWith(
    id: 'unsafe-license-case',
    safety: const GoldenAnalysisSafetyFlags(licenseSafe: false),
  );
}

GoldenAnalysisCase _unprovenMateThreat() {
  return _caseById(
    'mate-threat-fast-evidence',
  ).copyWith(id: 'mate-threat-unproven');
}

GoldenAnalysisCase _caseById(String id) {
  return GoldenAnalysisCases.defaults.singleWhere((item) => item.id == id);
}

List<GoldenAnalysisCase> _quietResolvedCases() {
  return GoldenAnalysisCases.defaults.map((item) {
    if (item.id != 'quiet-preparatory-uncertain') return item;
    return item.copyWith(
      motifTags: const [
        GoldenMotifTag.quietMove,
        GoldenMotifTag.quietPreparatoryMove,
      ],
      evidenceIntent: GoldenEvidenceIntent.protectiveRegression,
      quietPreparatoryEvidence: const QuietPreparatoryEvidence(
        candidateSpreadPresent: true,
        futureTacticalThreatPrepared: true,
        keySquareControlImproved: true,
        forcingLineEnabledNext: true,
        noImmediateCaptureCheckPromotion: true,
      ),
    );
  }).toList();
}

String get _gateSource => File(
  'lib/features/pgn_review/application/golden_classifier_readiness_gate.dart',
).readAsStringSync();

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}

const _hostOnlyProofForMateThreat = GoldenAndroidProofEvidence(
  proofVersion: goldenAndroidProofEvidenceVersion,
  sourceId: 'host-only-fake-proof',
  sourceNote: 'fake proof must not satisfy real-device proof',
  deviceFamily: 'host',
  deviceModel: 'host',
  platform: 'host',
  abi: 'x64',
  engineIdentity: 'fake-engine',
  stubIdentityDetected: false,
  runs: <GoldenAndroidProofRunEvidence>[
    GoldenAndroidProofRunEvidence(
      preset: 'balancedDefault',
      status: 'completedWithWarnings',
      targetCaseCount: 1,
      executedTargetCount: 1,
      selectedDeepCount: 1,
      executedDeepCount: 1,
      fastEngineCalls: 1,
      deepEngineCalls: 2,
      totalEngineCalls: 3,
      elapsedMs: 1,
      timeoutCount: 0,
      warningCount: 0,
      failureCount: 0,
      budgetPressureCount: 0,
      missingPvCount: 0,
      insufficientMultiPvCount: 0,
      warnings: <String>[],
      failures: <String>[],
      caseRows: <GoldenAndroidProofCaseEvidence>[
        GoldenAndroidProofCaseEvidence(
          caseId: 'mate-threat-fast-evidence',
          preset: 'balancedDefault',
          proofStatus: 'proofCaptured',
          selectedDeepCount: 1,
          executedDeepCount: 1,
          pvPresent: true,
          multiPvLineCount: 3,
          reasonCodeCounts: <DeepCandidateReasonCode, int>{
            DeepCandidateReasonCode.tacticalSignal: 1,
          },
          warnings: <String>[],
          failures: <String>[],
          nextAction: 'ignoreFakeProof',
        ),
      ],
    ),
  ],
);

const _fen =
    'rn1qkbnr/ppp2ppp/3b4/3pp3/4P3/2NP1N2/PPP2PPP/R1BQKB1R w KQkq - 2 5';

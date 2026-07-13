import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';

import 'package:apex_chess/app/di/providers.dart';
import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/classification_evidence.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/win_percent_calculator.dart';
import 'package:apex_chess/features/archives/data/archive_repository.dart';
import 'package:apex_chess/features/archives/domain/review_document.dart';
import 'package:apex_chess/features/pgn_review/domain/analysis_contract.dart';
import 'package:apex_chess/features/pgn_review/domain/review_analysis_provider.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';

import '../test/support/classification_corpus_runner.dart';

const _gate = 'APEX_RUN_CHAPTER4_CLASSIFICATION_PROOF';
const _smokeGate = 'APEX_RUN_CHAPTER4_CLASSIFICATION_SMOKE';
const _hiveDirectory = 'chapter4_offline_classification_proof';
const _smokeHiveDirectory = 'chapter4_offline_classification_smoke';
const _nnueIdentity = 'nn-37f18f62d772.nnue';
const _proofCommand =
    'flutter test '
    'integration_test/chapter4_offline_classification_device_test.dart '
    '-d R5CT33FXE5K '
    '--dart-define=APEX_RUN_CHAPTER4_CLASSIFICATION_PROOF=true';
const _smokeCommand =
    'flutter test '
    'integration_test/chapter4_offline_classification_device_test.dart '
    '-d R5CT33FXE5K '
    '--dart-define=APEX_RUN_CHAPTER4_CLASSIFICATION_SMOKE=true';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Chapter 4 real offline classification and exact reopen proof',
    (tester) async {
      const fullEnabled = bool.fromEnvironment(_gate);
      const smokeEnabled = bool.fromEnvironment(_smokeGate);
      if (!fullEnabled && !smokeEnabled) {
        markTestSkipped(
          'Set --dart-define=$_gate=true or '
          '--dart-define=$_smokeGate=true to run this proof.',
        );
        return;
      }
      expect(fullEnabled && smokeEnabled, isFalse);
      const compact = smokeEnabled;
      const proofPgn = compact ? _matePgn : _representativePgn;

      expect(Platform.isAndroid, isTrue);
      final device = _AndroidDeviceIdentity.read();
      expect(device.manufacturer.toLowerCase(), 'samsung');
      expect(device.model, 'SM-S908U1');
      expect(device.release, '16');
      expect(device.sdk, '36');
      expect(device.abi, 'arm64-v8a');
      expect(device.runtimeAbi, 'arm64-v8a');

      final corpus = _boundedDeviceCorpus();
      expect(corpus.cases, hasLength(19));
      final corpusRun = const ClassificationCorpusRunner().run(corpus);
      expect(corpusRun.policyVersion, kApexClassifierVersion);
      expect(corpusRun.failedCases, 0);
      expect(corpusRun.forbiddenLabelViolationCount, 0);
      expect(corpusRun.reasonCodeMismatchCount, 0);
      expect(corpusRun.specialLabelFalsePositiveCount, 0);
      for (final result in corpusRun.caseResults) {
        expect(result.passed, isTrue, reason: result.caseId);
      }
      _assertBoundedCorpusSemantics(corpusRun);

      await Hive.initFlutter(compact ? _smokeHiveDirectory : _hiveDirectory);
      var repository = await ArchiveRepository.open();
      await repository.clear();
      final container = ProviderContainer(
        overrides: apexDefaultProviderOverrides(),
      );
      final pipeline = await container.read(
        reviewAnalysisPipelineProvider.future,
      );
      final engine = container.read(stockfishEngineProvider);
      final controller = container.read(reviewControllerProvider.notifier);

      var providerExecutions = 0;
      var observedEngineCalls = 0;
      var observedClassifierDecisions = 0;

      Future<GameReviewResult> execute(GameReviewRequest request) async {
        providerExecutions++;
        final result = await pipeline.analyzeOffline(request);
        observedEngineCalls += result.telemetry.engineCallsCount;
        observedClassifierDecisions += result.timeline.totalPlies;
        return result;
      }

      Future<String> persist(ReviewDocument document) =>
          repository.saveReviewDocument(document);

      final fastWatch = Stopwatch()..start();
      final fastCompleted = await controller.analyzeOffline(
        request: const ReviewRuntimeRequest(
          pgn: proofPgn,
          profile: AnalysisProfile.fastReview,
          source: ReviewRuntimeSource.pastedPgn,
          sourceProvider: AnalysisGameSource.chessCom,
          userIsWhite: false,
        ),
        execute: execute,
        cancelExecution: pipeline.cancelLocalAnalysis,
        persist: persist,
      );
      fastWatch.stop();
      expect(fastCompleted, isTrue);
      final fastState = container.read(reviewControllerProvider);
      final fastTimeline = fastState.timeline!;
      final fastDocumentId = fastState.savedDocumentId!;
      _assertProfileEvidence(
        fastTimeline,
        AnalysisProfile.fastReview,
        expectedPlies: compact ? 1 : 30,
      );
      _assertLiveMath(fastTimeline, expectedBlackMoves: compact ? 0 : 15);
      const evidenceHeavy = <MoveQuality>{
        MoveQuality.brilliant,
        MoveQuality.great,
        MoveQuality.onlyMove,
        MoveQuality.missedWin,
      };
      expect(
        fastTimeline.moves.where(
          (move) => evidenceHeavy.contains(move.classification),
        ),
        isEmpty,
      );

      final deepWatch = Stopwatch()..start();
      final deepCompleted = await controller.analyzeOffline(
        request: const ReviewRuntimeRequest(
          pgn: proofPgn,
          profile: AnalysisProfile.deepReview,
          source: ReviewRuntimeSource.importedGame,
          sourceProvider: AnalysisGameSource.chessCom,
          sourceGameId: 'chapter4-device-representative',
          userIsWhite: false,
        ),
        execute: execute,
        cancelExecution: pipeline.cancelLocalAnalysis,
        persist: persist,
      );
      deepWatch.stop();
      expect(deepCompleted, isTrue);
      final deepState = container.read(reviewControllerProvider);
      final deepTimeline = deepState.timeline!;
      final deepDocumentId = deepState.savedDocumentId!;
      _assertProfileEvidence(
        deepTimeline,
        AnalysisProfile.deepReview,
        expectedPlies: compact ? 1 : 30,
      );
      _assertLiveMath(deepTimeline, expectedBlackMoves: compact ? 0 : 15);
      _assertSpecialLabelGates(deepTimeline);
      expect(deepTimeline.depth, greaterThan(fastTimeline.depth!));
      expect(deepState.gameId, fastState.gameId);
      expect(deepState.analysisVariantId, isNot(fastState.analysisVariantId));
      expect(deepDocumentId, isNot(fastDocumentId));
      expect(repository.listVariants(deepState.gameId!), hasLength(2));
      if (!compact) {
        expect(fastTimeline.moves[6].uci, 'e1g1');
        expect(fastTimeline.moves[11].uci, 'e8g8');
      }

      final forcedWatch = Stopwatch()..start();
      final forcedResult = await execute(
        const GameReviewRequest(
          pgn: _forcedOnlyLegalPgn,
          profile: AnalysisProfile.fastReview,
          userIsWhite: true,
        ),
      );
      forcedWatch.stop();
      expect(forcedResult.timeline.moves, hasLength(1));
      final forcedMove = forcedResult.timeline.moves.single;
      expect(forcedMove.classification, MoveQuality.forced);
      expect(forcedMove.classificationReasonCodes, contains('only_legal_move'));
      expect(forcedMove.classificationEvidence!.legalMoveCount, 1);

      final mateWatch = Stopwatch()..start();
      final mateResult = await execute(
        const GameReviewRequest(
          pgn: _matePgn,
          profile: AnalysisProfile.fastReview,
          userIsWhite: true,
        ),
      );
      mateWatch.stop();
      final mateMove = mateResult.timeline.moves.single;
      expect(mateMove.scoreCpAfter, isNull);
      expect(mateMove.mateInAfter, isNotNull);
      expect(mateMove.moverCpLoss, isNull);
      final mateEvidence = mateMove.classificationEvidence!;
      expect(mateEvidence.playedMoveEvaluation!.whiteCp, isNull);
      expect(mateEvidence.playedMoveEvaluation!.whiteMate, isNotNull);

      final deepLabelDigest = jsonEncode(_labelDigest(deepTimeline));
      final executionsBeforeReopen = providerExecutions;
      final engineCallsBeforeReopen = observedEngineCalls;
      final classifierDecisionsBeforeReopen = observedClassifierDecisions;

      expect(engine.isRunning, isTrue);
      await engine.dispose().timeout(const Duration(seconds: 5));
      expect(engine.isRunning, isFalse);
      container.dispose();
      await Hive.close();

      await Hive.initFlutter(compact ? _smokeHiveDirectory : _hiveDirectory);
      repository = await ArchiveRepository.open();
      final exactDeep = repository.find(deepDocumentId);
      expect(exactDeep, isNotNull);
      expect(repository.find(fastDocumentId), isNotNull);
      expect(repository.listVariants(deepState.gameId!), hasLength(2));

      final reopenContainer = ProviderContainer();
      final reopenWatch = Stopwatch()..start();
      final opened = reopenContainer
          .read(reviewControllerProvider.notifier)
          .openSavedReview(
            exactDeep!,
            source: ReviewRuntimeSource.archiveExact,
          );
      reopenWatch.stop();
      expect(opened, isTrue);
      final reopened = reopenContainer.read(reviewControllerProvider);
      expect(reopened.reviewDocumentId, deepDocumentId);
      expect(reopened.analysisVariantId, deepState.analysisVariantId);
      expect(reopened.requestedProfile, AnalysisProfile.deepReview);
      expect(reopened.userIsWhite, isFalse);
      expect(jsonEncode(_labelDigest(reopened.timeline!)), deepLabelDigest);
      expect(providerExecutions, executionsBeforeReopen);
      expect(observedEngineCalls, engineCallsBeforeReopen);
      expect(observedClassifierDecisions, classifierDecisionsBeforeReopen);

      final report = <String, Object?>{
        'proof': compact
            ? 'chapter4_offline_classification_smoke'
            : 'chapter4_offline_classification_device',
        'command': compact ? _smokeCommand : _proofCommand,
        'device': device.toJson(),
        'build': <String, Object?>{
          'fingerprint': device.fingerprint,
          'buildId': device.buildId,
          'incremental': device.incremental,
          'dartRuntime': Platform.version,
        },
        'engine': <String, Object?>{
          'declaredIdentity': deepTimeline.engineVersion,
          'stockfish17': deepTimeline.engineVersion.contains('Stockfish 17'),
          'bridge': deepTimeline.engineVersion.split('|').first,
          'nnueDeclared': _nnueIdentity,
          'nnueMode': 'production embedded/default network',
          'disposedAfterRun': !engine.isRunning,
        },
        'policy': <String, Object?>{
          'corpusVersion': corpusRun.corpusVersion,
          'policyVersion': corpusRun.policyVersion,
          'caseCount': corpusRun.totalCases,
          'durationMicroseconds': corpusRun.totalDurationMicroseconds,
          'cases': [
            for (final result in corpusRun.caseResults)
              <String, Object?>{
                'id': result.caseId,
                'allowed': result.allowedLabels,
                'label': result.actualLabel,
                'reasons': result.reasonCodes,
                'failedGates': result.failedGates,
                'depthAchieved': result.achievedDepthFloor,
                'multiPvReceived': result.receivedMultiPv,
                'durationMicroseconds': result.durationMicroseconds,
                'state': result.outcome,
              },
          ],
        },
        'fast': _profileReport(
          timeline: fastTimeline,
          profile: AnalysisProfile.fastReview,
          durationMs: fastWatch.elapsedMilliseconds,
        )..['evidenceHeavyLabelsSuppressed'] = true,
        'deep': _profileReport(
          timeline: deepTimeline,
          profile: AnalysisProfile.deepReview,
          durationMs: deepWatch.elapsedMilliseconds,
        ),
        'forcedOnlyLegal': <String, Object?>{
          'durationMs': forcedWatch.elapsedMilliseconds,
          'label': forcedMove.classification.name,
          'reasons': forcedMove.classificationReasonCodes,
          'legalMoveCount': forcedMove.classificationEvidence!.legalMoveCount,
        },
        'mateTransition': <String, Object?>{
          'durationMs': mateWatch.elapsedMilliseconds,
          'label': mateMove.classification.name,
          'reasons': mateMove.classificationReasonCodes,
          'cpAfter': mateMove.scoreCpAfter,
          'mateAfter': mateMove.mateInAfter,
          'moverCpLoss': mateMove.moverCpLoss,
        },
        'reopen': <String, Object?>{
          'selectedDocumentId': deepDocumentId,
          'selectedVariantId': deepState.analysisVariantId,
          'fastVariantId': fastState.analysisVariantId,
          'variantCount': repository.listVariants(deepState.gameId!).length,
          'labelsAndReasonsIdentical': true,
          'perspective': reopened.userIsWhite == false ? 'black' : 'other',
          'profile': reopened.requestedProfile?.id.wire,
          'providerExecutions': providerExecutions,
          'engineCallsOnReopen': observedEngineCalls - engineCallsBeforeReopen,
          'classifierRerunsOnReopen':
              observedClassifierDecisions - classifierDecisionsBeforeReopen,
          'latencyMs': reopenWatch.elapsedMilliseconds,
        },
      };

      reopenContainer.dispose();
      await repository.clear();
      await Hive.close();

      // Exactly one machine-readable sentinel. Raw UCI/PV output is omitted.
      // ignore: avoid_print
      print('CHAPTER4_DEVICE_RESULT_JSON=${jsonEncode(report)}');
    },
    timeout: const Timeout(Duration(minutes: 20)),
  );
}

void _assertProfileEvidence(
  AnalysisTimeline timeline,
  AnalysisProfile profile, {
  required int expectedPlies,
}) {
  expect(timeline.isComplete, isTrue);
  expect(timeline.totalPlies, expectedPlies);
  expect(timeline.requestedDepth, profile.localDepth);
  expect(timeline.movetimeMs, profile.localMovetimeMs);
  expect(timeline.multipv, profile.localMultiPv);
  expect(
    timeline.candidateVerificationEnabled,
    profile.candidateVerificationEnabled,
  );
  expect(timeline.depth, isNotNull);
  expect(timeline.depth, greaterThan(0));
  expect(timeline.engineVersion, contains('Stockfish 17'));
  expect(timeline.engineVersion.toLowerCase(), isNot(contains('stub')));
  for (final move in timeline.moves) {
    expect(move.requestedDepth, profile.localDepth);
    expect(move.achievedDepthBefore, isNotNull);
    expect(move.achievedDepthBefore, greaterThan(0));
    if (move.achievedDepthAfter != null) {
      expect(move.achievedDepthAfter, greaterThan(0));
    }
    expect(move.multiPvReceived, greaterThanOrEqualTo(profile.localMultiPv));
    expect(move.classificationEvidence, isNotNull);
    expect(
      move.searchQualityMet,
      move.achievedDepthBefore! >= profile.localDepth &&
          (move.achievedDepthAfter == null ||
              move.achievedDepthAfter! >= profile.localDepth),
    );
    expect(
      move.classificationEvidence!.searchQualityMet,
      move.searchQualityMet,
    );
  }
}

void _assertLiveMath(
  AnalysisTimeline timeline, {
  required int expectedBlackMoves,
}) {
  const perspective = MoverPerspective();
  var blackMoves = 0;
  for (final move in timeline.moves) {
    if (!move.isWhiteMove) blackMoves++;
    expect(
      move.deltaW,
      closeTo(
        perspective.deltaW(
          whiteWinBefore: move.winPercentBefore,
          whiteWinAfter: move.winPercentAfter,
          isWhiteMove: move.isWhiteMove,
        ),
        1e-9,
      ),
    );
    final evidence = move.classificationEvidence!;
    final expectedSignedLoss = perspective.cpLoss(
      whiteCpBefore: evidence.bestMoveEvaluation?.whiteCp,
      whiteCpAfter: evidence.playedMoveEvaluation?.whiteCp,
      mateBefore: evidence.bestMoveEvaluation?.whiteMate,
      mateAfter: evidence.playedMoveEvaluation?.whiteMate,
      isWhiteMove: move.isWhiteMove,
    );
    final expectedLoss = expectedSignedLoss == null
        ? null
        : expectedSignedLoss < 0
        ? 0
        : expectedSignedLoss;
    expect(move.moverCpLoss, expectedLoss);
    if (move.mateInAfter != null) {
      expect(move.scoreCpAfter, isNull);
      expect(move.moverCpLoss, isNull);
    }
  }
  expect(blackMoves, expectedBlackMoves);
}

void _assertSpecialLabelGates(AnalysisTimeline timeline) {
  for (final move in timeline.moves) {
    final evidence = move.classificationEvidence!;
    switch (move.classification) {
      case MoveQuality.brilliant:
        expect(evidence.searchQualityMet, isTrue);
        expect(evidence.hasCompleteCandidateSet, isTrue);
        expect(evidence.bestMovePv1Consistent, isTrue);
        expect(
          evidence.verificationState,
          ClassificationVerificationState.complete,
        );
        expect(evidence.isSacrifice, isTrue);
        expect(evidence.isRecapture, isNot(true));
      case MoveQuality.great:
        expect(evidence.searchQualityMet, isTrue);
        expect(evidence.hasCompleteCandidateSet, isTrue);
        expect(evidence.bestMovePv1Consistent, isTrue);
        expect(evidence.candidates.length, greaterThanOrEqualTo(3));
      case MoveQuality.onlyMove:
        expect(evidence.searchQualityMet, isTrue);
        expect(evidence.hasCompleteCandidateSet, isTrue);
        expect(evidence.requestedMultiPv, greaterThanOrEqualTo(3));
        expect(evidence.legalMoveCount, greaterThan(1));
      case MoveQuality.missedWin:
        expect(evidence.searchQualityMet, isTrue);
        expect(evidence.hasCompleteCandidateSet, isTrue);
        expect(evidence.candidates.length, greaterThanOrEqualTo(2));
      case MoveQuality.forced:
        expect(evidence.legalMoveCount, 1);
      default:
        break;
    }
  }
}

Map<String, Object?> _profileReport({
  required AnalysisTimeline timeline,
  required AnalysisProfile profile,
  required int durationMs,
}) => <String, Object?>{
  'requested': <String, Object?>{
    'profile': profile.id.wire,
    'depth': profile.localDepth,
    'movetimeMs': profile.localMovetimeMs,
    'multiPv': profile.localMultiPv,
    'candidateVerification': profile.candidateVerificationEnabled,
  },
  'achieved': <String, Object?>{
    'minimumDepth': timeline.depth,
    'minimumMultiPv': timeline.moves
        .map((move) => move.multiPvReceived)
        .reduce((left, right) => left < right ? left : right),
    'maximumMultiPv': timeline.moves
        .map((move) => move.multiPvReceived)
        .reduce((left, right) => left > right ? left : right),
    'candidateVerification': timeline.candidateVerificationEnabled,
    'engineSearchCount': timeline.engineSearchCount,
    'engineCacheHitCount': timeline.engineCacheHitCount,
  },
  'durationMs': durationMs,
  'plies': _labelDigest(timeline),
};

List<Map<String, Object?>> _labelDigest(AnalysisTimeline timeline) => [
  for (final move in timeline.moves)
    <String, Object?>{
      'ply': move.ply,
      'mover': move.isWhiteMove ? 'white' : 'black',
      'label': move.classification.name,
      'baseLabel': move.baseClassification.name,
      'reasons': move.classificationReasonCodes,
      'failedGates': move.classificationFailedGates,
      'depthRequested': move.requestedDepth,
      'depthBefore': move.achievedDepthBefore,
      'depthAfter': move.achievedDepthAfter,
      'multiPvReceived': move.multiPvReceived,
      'searchQualityMet': move.searchQualityMet,
      'verification': move.classificationEvidence?.verificationState.name,
      'candidateVerified': move.tacticalVerdict.candidateVerified,
      'moverCpLoss': move.moverCpLoss,
      'scoreDomainAfter': move.mateInAfter != null ? 'mate' : 'centipawn',
    },
];

void _assertBoundedCorpusSemantics(ClassificationCorpusRunResult run) {
  final results = <String, ClassificationCorpusCaseResult>{
    for (final result in run.caseResults) result.caseId: result,
  };
  expect(results['perspective-white-decisive-loss']!.actualLabel, 'blunder');
  expect(results['perspective-black-decisive-loss']!.actualLabel, 'blunder');
  expect(
    results['mate-found-from-cp']!.diagnostics['scoreDomainAfter'],
    'mate',
  );
  expect(
    results['mate-delayed-not-cp-fabricated']!.diagnostics['scoreDomainAfter'],
    'mate',
  );
  expect(results['alternatives-one-clearly-superior']!.actualLabel, 'onlyMove');
  expect(
    results['alternatives-two-equivalent-best']!.actualLabel,
    isNot('onlyMove'),
  );
  expect(
    results['brilliant-verified-queen-sacrifice-mate']!.actualLabel,
    'brilliant',
  );
  expect(
    results['brilliant-forced-recapture-negative']!.actualLabel,
    isNot('brilliant'),
  );
  expect(results['great-verified-tactical-breakthrough']!.actualLabel, 'great');
  expect(results['great-routine-pv1-negative']!.actualLabel, isNot('great'));
  expect(
    results['missed-win-valid-winning-to-equal']!.actualLabel,
    'missedWin',
  );
  expect(
    results['missed-win-no-prior-win-negative']!.actualLabel,
    isNot('missedWin'),
  );
  expect(results['book-severe-damiano-drop-visible']!.actualLabel, 'blunder');
  expect(results['state-queen-promotion-checkmate']!.actualLabel, 'best');
  expect(results['state-castling-normalized-best']!.actualLabel, 'best');
  expect(results['forced-only-legal-response-positive']!.actualLabel, 'forced');
}

ClassificationCorpus _boundedDeviceCorpus() => ClassificationCorpus(
  schemaVersion: 1,
  corpusVersion: 'apex-classification-policy-corpus-v1-device-subset',
  policyVersion: kApexClassifierVersion,
  expectationOwner: 'Apex Chess classification policy',
  evidenceDefaults: _evidenceDefaults,
  cases: <ClassificationCorpusCase>[
    _case(
      'general-exact-pv1-best',
      move: 'e2e4',
      evidence: const {'prevWhiteCp': 0, 'currWhiteCp': 0},
      allowed: const ['best'],
      forbidden: _special,
      reasons: const ['pv1_best'],
      tags: const ['general'],
    ),
    _case(
      'general-decisive-blunder',
      move: 'g2g4',
      evidence: const {
        'prevWhiteCp': 0,
        'currWhiteCp': -400,
        'engineBestMoveUci': 'e2e4',
      },
      allowed: const ['blunder'],
      forbidden: _special,
      reasons: const ['baseline_blunder'],
      tags: const ['general'],
    ),
    _case(
      'general-unavailable-comparison',
      move: 'e2e4',
      evidence: const {
        'prevWhiteCp': null,
        'prevWhiteMate': null,
        'currWhiteCp': 0,
        'scoreCoverage': 'missingBefore',
        'multiPvCoherent': false,
        'alternativeEvidenceComplete': false,
      },
      allowed: const ['unavailable'],
      forbidden: const ['best', ..._special],
      reasons: const ['evidence_unavailable_missingEvaluationBefore'],
      tags: const ['general'],
    ),
    _case(
      'perspective-white-decisive-loss',
      move: 'd1d3',
      evidence: const {
        'prevWhiteCp': 300,
        'currWhiteCp': -100,
        'engineBestMoveUci': 'd1h5',
        'multiPvWhiteWinPercents': [75.1],
        'receivedMultiPvCount': 1,
        'alternativeEvidenceComplete': false,
      },
      allowed: const ['blunder'],
      forbidden: _special,
      reasons: const ['baseline_blunder'],
      tags: const ['perspective'],
    ),
    _case(
      'perspective-black-decisive-loss',
      mover: 'black',
      move: 'd8d6',
      evidence: const {
        'prevWhiteCp': -300,
        'currWhiteCp': 100,
        'engineBestMoveUci': 'd8h4',
        'multiPvWhiteWinPercents': [24.9],
        'receivedMultiPvCount': 1,
        'alternativeEvidenceComplete': false,
      },
      allowed: const ['blunder'],
      forbidden: _special,
      reasons: const ['baseline_blunder'],
      tags: const ['perspective'],
    ),
    _case(
      'mate-found-from-cp',
      fen: '7k/5Q2/6K1/8/8/8/8/8 w - - 0 1',
      move: 'f7f8',
      evidence: const {
        'prevWhiteCp': 300,
        'currWhiteCp': null,
        'currWhiteMate': 1,
        'bestWhiteCp': null,
        'bestWhiteMate': 1,
        'engineBestMoveUci': 'f7f8',
        'multiPvWhiteWinPercents': [100.0, 90.0, 85.0],
      },
      allowed: const ['best'],
      forbidden: const ['blunder', 'mistake', 'missedWin'],
      reasons: const ['pv1_best'],
      tags: const ['mate'],
    ),
    _case(
      'mate-delayed-not-cp-fabricated',
      move: 'a1b1',
      evidence: const {
        'prevWhiteCp': null,
        'prevWhiteMate': 2,
        'currWhiteCp': null,
        'currWhiteMate': 6,
        'engineBestMoveUci': 'a1a8',
      },
      allowed: const ['excellent', 'good'],
      forbidden: const [
        'blunder',
        'missedWin',
        'brilliant',
        'onlyMove',
        'forced',
      ],
      reasons: const ['baseline_excellent'],
      tags: const ['mate'],
    ),
    _case(
      'alternatives-one-clearly-superior',
      move: 'a2a3',
      evidence: const {
        'prevWhiteCp': 50,
        'currWhiteCp': 300,
        'bestWhiteCp': 300,
        'engineBestMoveUci': 'a2a3',
        'multiPvWhiteWinPercents': [75.0, 40.0, 35.0],
        'forcedResponseEvidence': 'onlyOutcomePreservingMove',
      },
      allowed: const ['onlyMove'],
      forbidden: const ['brilliant', 'great', 'forced', 'missedWin', 'book'],
      reasons: const ['only_outcome_preserving_move'],
      tags: const ['alternatives'],
    ),
    _case(
      'alternatives-two-equivalent-best',
      move: 'd2d4',
      evidence: const {
        'engineBestMoveUci': 'e2e4',
        'prevWhiteCp': 20,
        'currWhiteCp': 19,
        'multiPvWhiteWinPercents': [51.8, 51.7, 40.0],
      },
      allowed: const ['best'],
      forbidden: _special,
      reasons: const ['equivalent_best'],
      tags: const ['alternatives'],
    ),
    _case(
      'brilliant-verified-queen-sacrifice-mate',
      mover: 'black',
      move: 'b2a1',
      evidence: const {
        'prevWhiteCp': -250,
        'currWhiteCp': null,
        'currWhiteMate': -3,
        'engineBestMoveUci': 'b2a1',
        'isCapture': true,
        'isSacrifice': true,
        'candidateVerificationStatus': 'verified',
        'tacticalVerdict': {
          'isBestOrNearBest': true,
          'hasForcingOutcome': true,
          'forcedMate': true,
        },
      },
      allowed: const ['brilliant'],
      forbidden: const [
        'great',
        'onlyMove',
        'forced',
        'missedWin',
        'book',
        'blunder',
      ],
      reasons: const ['verified_sound_sacrifice'],
      tags: const ['brilliant-positive'],
    ),
    _case(
      'brilliant-forced-recapture-negative',
      move: 'a2a1',
      evidence: const {
        'prevWhiteCp': 20,
        'currWhiteCp': 20,
        'engineBestMoveUci': 'a2a1',
        'isCapture': true,
        'isRecapture': true,
        'isTrivialRecapture': true,
        'isSacrifice': true,
        'candidateVerificationStatus': 'verified',
      },
      allowed: const ['best'],
      forbidden: const ['brilliant', 'great', 'onlyMove', 'forced'],
      reasons: const ['pv1_best'],
      tags: const ['brilliant-negative'],
    ),
    _case(
      'great-verified-tactical-breakthrough',
      move: 'd1d8',
      evidence: const {
        'prevWhiteCp': 50,
        'currWhiteCp': 250,
        'bestWhiteCp': 250,
        'engineBestMoveUci': 'd1d8',
        'multiPvWhiteWinPercents': [71.5, 60.0, 55.0],
        'isCapture': true,
        'candidateVerificationStatus': 'verified',
        'tacticalVerdict': {
          'isBestOrNearBest': true,
          'hasForcingOutcome': true,
        },
      },
      allowed: const ['great'],
      forbidden: const ['brilliant', 'onlyMove', 'forced', 'missedWin', 'book'],
      reasons: const ['verified_great_move'],
      tags: const ['great-positive'],
    ),
    _case(
      'great-routine-pv1-negative',
      fen: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
      move: 'e2e4',
      evidence: const {
        'prevWhiteCp': 20,
        'currWhiteCp': 20,
        'engineBestMoveUci': 'e2e4',
        'multiPvWhiteWinPercents': [51.8, 51.0, 50.5],
        'bookEvidenceState': 'notBook',
      },
      allowed: const ['best'],
      forbidden: const ['brilliant', 'great', 'onlyMove', 'forced'],
      reasons: const ['pv1_best'],
      tags: const ['great-negative'],
    ),
    _case(
      'missed-win-valid-winning-to-equal',
      move: 'd1d2',
      evidence: const {
        'prevWhiteCp': 300,
        'currWhiteCp': 20,
        'engineBestMoveUci': 'd1h5',
        'multiPvWhiteWinPercents': [75.1, 55.0, 45.0],
      },
      allowed: const ['missedWin'],
      forbidden: const ['brilliant', 'great', 'onlyMove', 'forced', 'book'],
      reasons: const ['missed_decisive_line'],
      tags: const ['missed-win-positive'],
    ),
    _case(
      'missed-win-no-prior-win-negative',
      move: 'd1d2',
      evidence: const {
        'prevWhiteCp': 80,
        'currWhiteCp': -100,
        'engineBestMoveUci': 'd1h5',
        'multiPvWhiteWinPercents': [57.3, 52.0, 48.0],
      },
      allowed: const ['mistake', 'blunder'],
      forbidden: const [
        'missedWin',
        'brilliant',
        'great',
        'onlyMove',
        'forced',
      ],
      reasons: const ['baseline_mistake'],
      tags: const ['missed-win-negative'],
    ),
    _case(
      'book-severe-damiano-drop-visible',
      mover: 'black',
      fen: 'rnbqkbnr/pppp1ppp/8/4p3/8/5N2/PPPPPPPP/RNBQKB1R b KQkq - 1 2',
      move: 'f7f6',
      evidence: const {
        'prevWhiteCp': 20,
        'currWhiteCp': 500,
        'engineBestMoveUci': 'b8c6',
        'multiPvWhiteWinPercents': [48.2, 47.0, 45.0],
        'bookEvidenceState': 'verifiedBook',
      },
      allowed: const ['blunder'],
      forbidden: const ['book', 'brilliant', 'great', 'onlyMove', 'forced'],
      reasons: const ['book_severe_cp_loss'],
      tags: const ['book'],
    ),
    _case(
      'state-queen-promotion-checkmate',
      mover: 'black',
      move: 'c2c1q',
      evidence: const {
        'prevWhiteCp': -900,
        'currWhiteCp': null,
        'currWhiteMate': -1,
        'bestWhiteCp': null,
        'bestWhiteMate': -1,
        'engineBestMoveUci': 'c2c1q',
        'multiPvWhiteWinPercents': [0.0, 10.0, 15.0],
      },
      allowed: const ['best'],
      forbidden: const ['blunder', 'mistake', 'missedWin'],
      reasons: const ['pv1_best'],
      tags: const ['promotion'],
    ),
    _case(
      'state-castling-normalized-best',
      mover: 'black',
      fen:
          'r1bqk2r/1pppbppp/p1n2n2/4p3/B3P3/2P2N2/PP1P1PPP/RNBQR1K1 b kq - 3 8',
      move: 'e8g8',
      evidence: const {
        'prevWhiteCp': 0,
        'currWhiteCp': 0,
        'engineBestMoveUci': 'e8h8',
        'multiPvWhiteWinPercents': [50.0, 49.5, 49.0],
      },
      allowed: const ['best'],
      forbidden: _special,
      reasons: const ['pv1_best'],
      tags: const ['castling'],
    ),
    _case(
      'forced-only-legal-response-positive',
      fen: 'r1b1kbnr/pppp1ppp/n3p3/8/5P1q/P1P5/1P1PP1PP/RNBQKBNR w KQkq - 1 4',
      move: 'g2g3',
      evidence: const {
        'prevWhiteCp': -80,
        'currWhiteCp': -85,
        'engineBestMoveUci': 'g2g3',
        'multiPvWhiteWinPercents': [42.7],
        'legalCandidateCount': 1,
        'receivedMultiPvCount': 1,
        'multiPvCoherent': true,
        'alternativeEvidenceComplete': true,
        'forcedResponseEvidence': 'onlyLegalMove',
      },
      allowed: const ['forced'],
      forbidden: const ['brilliant', 'great', 'onlyMove', 'missedWin', 'book'],
      reasons: const ['only_legal_move'],
      tags: const ['forced-positive'],
    ),
  ],
);

ClassificationCorpusCase _case(
  String id, {
  String mover = 'white',
  String fen = 'n/a: frozen structured evidence',
  required String move,
  required Map<String, Object?> evidence,
  required List<String> allowed,
  required List<String> forbidden,
  required List<String> reasons,
  required List<String> tags,
}) => ClassificationCorpusCase(
  id: id,
  schemaVersion: 1,
  provenanceType: 'APEX_FROZEN_DEVICE_SUBSET',
  expectationOwner: 'Apex Chess classification policy',
  fenBefore: fen,
  playedMoveUci: move,
  mover: mover,
  evidence: evidence,
  allowedLabels: allowed,
  forbiddenLabels: forbidden,
  requiredReasonCodes: reasons,
  tags: tags,
  rationale: 'Frozen Chapter 4 high-risk device case: $id',
  calibrationStatus: 'FROZEN_DEVICE_SUBSET',
);

const _special = <String>[
  'brilliant',
  'great',
  'onlyMove',
  'forced',
  'missedWin',
  'book',
];

const _evidenceDefaults = <String, Object?>{
  'prevWhiteCp': 0,
  'prevWhiteMate': null,
  'currWhiteCp': 0,
  'currWhiteMate': null,
  'engineBestMoveUci': 'e2e4',
  'multiPvWhiteWinPercents': [50.0, 48.0, 46.0],
  'legalCandidateCount': 20,
  'receivedMultiPvCount': 3,
  'multiPvCoherent': true,
  'alternativeEvidenceComplete': true,
  'bestEquivalentMoveCount': 1,
  'candidateVerificationStatus': 'notRequired',
  'achievedDepth': 22,
  'achievedDepthFloor': 22,
  'scoreCoverage': 'complete',
  'bookEvidenceState': 'notBook',
  'forcedResponseEvidence': 'none',
  'isSacrifice': false,
  'isCapture': false,
  'isFreeCapture': false,
  'isRecapture': false,
  'isTrivialRecapture': false,
  'isFirstSacrificePly': true,
  'deepVerificationComplete': false,
};

final class _AndroidDeviceIdentity {
  const _AndroidDeviceIdentity({
    required this.manufacturer,
    required this.model,
    required this.release,
    required this.sdk,
    required this.abi,
    required this.runtimeAbi,
    required this.fingerprint,
    required this.buildId,
    required this.incremental,
  });

  final String manufacturer;
  final String model;
  final String release;
  final String sdk;
  final String abi;
  final String runtimeAbi;
  final String fingerprint;
  final String buildId;
  final String incremental;

  factory _AndroidDeviceIdentity.read() => _AndroidDeviceIdentity(
    manufacturer: _androidProperty('ro.product.manufacturer'),
    model: _androidProperty('ro.product.model'),
    release: _androidProperty('ro.build.version.release'),
    sdk: _androidProperty('ro.build.version.sdk'),
    abi: _androidProperty('ro.product.cpu.abi'),
    runtimeAbi: _runtimeAbiLabel(),
    fingerprint: _androidProperty('ro.build.fingerprint'),
    buildId: _androidProperty('ro.build.id'),
    incremental: _androidProperty('ro.build.version.incremental'),
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'manufacturer': manufacturer,
    'model': model,
    'androidRelease': release,
    'api': sdk,
    'abi': abi,
    'runtimeAbi': runtimeAbi,
  };
}

typedef _PropertyGetNative = Int32 Function(Pointer<Utf8>, Pointer<Utf8>);
typedef _PropertyGetDart = int Function(Pointer<Utf8>, Pointer<Utf8>);

String _androidProperty(String name) {
  final getProperty = DynamicLibrary.open('libc.so')
      .lookupFunction<_PropertyGetNative, _PropertyGetDart>(
        '__system_property_get',
      );
  final key = name.toNativeUtf8();
  final buffer = calloc<Uint8>(92);
  try {
    final length = getProperty(key, buffer.cast<Utf8>());
    return length <= 0 ? '' : buffer.cast<Utf8>().toDartString(length: length);
  } finally {
    calloc.free(key);
    calloc.free(buffer);
  }
}

String _runtimeAbiLabel() => switch (Abi.current()) {
  Abi.androidArm64 => 'arm64-v8a',
  Abi.androidArm => 'armeabi-v7a',
  Abi.androidX64 => 'x86_64',
  Abi.androidIA32 => 'x86',
  _ => Abi.current().toString(),
};

const _representativePgn = '''
[Event "Chapter 4 Samsung proof"]
[Site "Chess.com"]
[Date "2026.07.11"]
[White "Apex"]
[Black "Opponent"]
[Result "1-0"]
[ECO "C50"]

1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5 4. O-O Nf6 5. d3 d6
6. c3 O-O 7. Re1 a6 8. Bb3 Ba7 9. h3 h6 10. Nbd2 Re8
11. Nf1 Be6 12. Bc2 d5 13. exd5 Bxd5 14. Ng3 Qd7 15. Be3 Bxe3 1-0
''';

const _forcedOnlyLegalPgn = '''
[Event "Chapter 4 forced-only-legal proof"]
[SetUp "1"]
[FEN "r1b1kbnr/pppp1ppp/n3p3/8/5P1q/P1P5/1P1PP1PP/RNBQKBNR w KQkq - 1 4"]
[Result "*"]

4. g3 *
''';

const _matePgn = '''
[Event "Chapter 4 mate-domain proof"]
[SetUp "1"]
[FEN "7k/5Q2/6K1/8/8/8/8/8 w - - 0 1"]
[Result "1-0"]

1. Qf8# 1-0
''';

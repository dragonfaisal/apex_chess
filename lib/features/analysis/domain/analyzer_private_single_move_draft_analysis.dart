import 'dart:convert';

import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_draft_classification_gate.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_draft_classifier.dart';

const analyzerPrivateSingleMoveDraftAnalysisPlayedMoveUci =
    analyzerPrivateDraftClassifierPlayedMoveUci;
const analyzerPrivateSingleMoveDraftAnalysisCandidateMoveUci =
    analyzerPrivateDraftClassifierCandidateMoveUci;
const analyzerPrivateSingleMoveDraftAnalysisDepth =
    analyzerPrivateDraftClassifierDepth;
const analyzerPrivateSingleMoveDraftAnalysisSource =
    'phase35QControlledPrivateSingleMoveDraftAnalysis';
const analyzerPrivateSingleMoveDraftAnalysisModelName =
    'internalPrivateSingleMoveDraftAnalysisDeveloperOnly';
const analyzerPrivateSingleMoveDraftAnalysisModelVersion = 'phase35Q.v1';
const analyzerPrivateSingleMoveDraftAnalysisNextRecommendation =
    'beginLegacyAnalyzerReintegrationAgainstPrivateDraftContract';
const analyzerPrivateSingleMoveDraftAnalysisFailureRecommendation =
    'fixPrivateSingleMoveDraftAnalysisContract';

class AnalyzerPrivateSingleMoveDraftAnalysisRequest {
  const AnalyzerPrivateSingleMoveDraftAnalysisRequest({
    required this.playedMoveUci,
    required this.candidateMoveUci,
    required this.moverColor,
    required this.requestedDepth,
    required this.source,
  });

  const AnalyzerPrivateSingleMoveDraftAnalysisRequest.controlled({
    AnalyzerMoverColor moverColor = AnalyzerMoverColor.white,
  }) : this(
         playedMoveUci: analyzerPrivateSingleMoveDraftAnalysisPlayedMoveUci,
         candidateMoveUci:
             analyzerPrivateSingleMoveDraftAnalysisCandidateMoveUci,
         moverColor: moverColor,
         requestedDepth: analyzerPrivateSingleMoveDraftAnalysisDepth,
         source: analyzerPrivateSingleMoveDraftAnalysisSource,
       );

  final String playedMoveUci;
  final String candidateMoveUci;
  final AnalyzerMoverColor moverColor;
  final int requestedDepth;
  final String source;
}

class AnalyzerPrivateSingleMoveDraftAnalysisResult {
  const AnalyzerPrivateSingleMoveDraftAnalysisResult({
    required this.analysisResultId,
    required this.playedMoveUci,
    required this.candidateMoveUci,
    required this.moverColor,
    required this.requestedDepth,
    required this.analysisSource,
    required this.analysisModelName,
    required this.analysisModelVersion,
    required this.beforeMoverPerspectiveCp,
    required this.playedAfterMoverPerspectiveCp,
    required this.candidateAfterMoverPerspectiveCp,
    required this.moverPerspectiveDeltaCp,
    required this.moverPerspectiveCpLossCandidate,
    required this.cpDeltaComputed,
    required this.cpLossCandidateComputed,
    required this.cpLossCandidateDirection,
    required this.expectedPointsComputed,
    required this.expectedPointsModelName,
    required this.expectedPointsModelVersion,
    required this.expectedPointsModelIsOfficial,
    required this.beforeExpectedPoints,
    required this.playedAfterExpectedPoints,
    required this.candidateAfterExpectedPoints,
    required this.playedExpectedPointsDelta,
    required this.candidateVsPlayedExpectedPointsDelta,
    required this.draftClassificationGateComputed,
    required this.evidenceStructurallyEligibleForFutureClassification,
    required this.evidenceIsDeveloperOnly,
    required this.gateRecommendation,
    required this.privateDraftClassifierComputed,
    required this.privateDraftBucket,
    required this.privateDraftReasonCode,
    required this.privateDraftConfidenceTier,
    required this.privateDraftClassifierIsPublic,
    required this.privateDraftClassifierIsOfficialMoveQuality,
    required this.privateDraftClassifierIsPublicLabel,
    required this.privateSingleMoveDraftAnalysisComputed,
    required this.privateSingleMoveDraftAnalysisIsPublic,
    required this.privateSingleMoveDraftAnalysisIsProductReview,
    required this.privateSingleMoveDraftAnalysisIsSavedAnalysis,
    required this.privateSingleMoveDraftAnalysisIsOfficial,
    required this.publicLabelComputed,
    required this.publicLabel,
    required this.officialMoveQualityComputed,
    required this.officialMoveQuality,
    required this.officialCpLossComputed,
    required this.officialWinPercentComputed,
    required this.accuracyComputed,
    required this.acplComputed,
    required this.classificationComputed,
    required this.publicClassifierOutputComputed,
    required this.savedAnalysisWritten,
    required this.uiOutputProduced,
    required this.privateSingleMoveDraftAnalysisProbeSucceeded,
    required this.failureMessage,
    required this.safeForPhase36A,
    required this.nextRecommendation,
    required this.blockers,
    required this.warnings,
  });

  final String analysisResultId;
  final String playedMoveUci;
  final String candidateMoveUci;
  final AnalyzerMoverColor moverColor;
  final int requestedDepth;
  final String analysisSource;
  final String analysisModelName;
  final String analysisModelVersion;
  final int? beforeMoverPerspectiveCp;
  final int? playedAfterMoverPerspectiveCp;
  final int? candidateAfterMoverPerspectiveCp;
  final int? moverPerspectiveDeltaCp;
  final int? moverPerspectiveCpLossCandidate;
  final bool cpDeltaComputed;
  final bool cpLossCandidateComputed;
  final String? cpLossCandidateDirection;
  final bool expectedPointsComputed;
  final String? expectedPointsModelName;
  final String? expectedPointsModelVersion;
  final bool expectedPointsModelIsOfficial;
  final double? beforeExpectedPoints;
  final double? playedAfterExpectedPoints;
  final double? candidateAfterExpectedPoints;
  final double? playedExpectedPointsDelta;
  final double? candidateVsPlayedExpectedPointsDelta;
  final bool draftClassificationGateComputed;
  final bool evidenceStructurallyEligibleForFutureClassification;
  final bool evidenceIsDeveloperOnly;
  final AnalyzerDraftClassificationGateRecommendation gateRecommendation;
  final bool privateDraftClassifierComputed;
  final AnalyzerPrivateDraftBucket privateDraftBucket;
  final AnalyzerPrivateDraftReasonCode privateDraftReasonCode;
  final AnalyzerPrivateDraftConfidenceTier privateDraftConfidenceTier;
  final bool privateDraftClassifierIsPublic;
  final bool privateDraftClassifierIsOfficialMoveQuality;
  final bool privateDraftClassifierIsPublicLabel;
  final bool privateSingleMoveDraftAnalysisComputed;
  final bool privateSingleMoveDraftAnalysisIsPublic;
  final bool privateSingleMoveDraftAnalysisIsProductReview;
  final bool privateSingleMoveDraftAnalysisIsSavedAnalysis;
  final bool privateSingleMoveDraftAnalysisIsOfficial;
  final bool publicLabelComputed;
  final String? publicLabel;
  final bool officialMoveQualityComputed;
  final String? officialMoveQuality;
  final bool officialCpLossComputed;
  final bool officialWinPercentComputed;
  final bool accuracyComputed;
  final bool acplComputed;
  final bool classificationComputed;
  final bool publicClassifierOutputComputed;
  final bool savedAnalysisWritten;
  final bool uiOutputProduced;
  final bool privateSingleMoveDraftAnalysisProbeSucceeded;
  final String? failureMessage;
  final bool safeForPhase36A;
  final String nextRecommendation;
  final List<String> blockers;
  final List<String> warnings;

  Map<String, Object?> toJson() => {
    'analysisResultId': analysisResultId,
    'playedMoveUci': playedMoveUci,
    'candidateMoveUci': candidateMoveUci,
    'moverColor': moverColor.wire,
    'requestedDepth': requestedDepth,
    'analysisSource': analysisSource,
    'analysisModelName': analysisModelName,
    'analysisModelVersion': analysisModelVersion,
    'beforeMoverPerspectiveCp': beforeMoverPerspectiveCp,
    'playedAfterMoverPerspectiveCp': playedAfterMoverPerspectiveCp,
    'candidateAfterMoverPerspectiveCp': candidateAfterMoverPerspectiveCp,
    'moverPerspectiveDeltaCp': moverPerspectiveDeltaCp,
    'moverPerspectiveCpLossCandidate': moverPerspectiveCpLossCandidate,
    'cpDeltaComputed': cpDeltaComputed,
    'cpLossCandidateComputed': cpLossCandidateComputed,
    'cpLossCandidateDirection': cpLossCandidateDirection,
    'expectedPointsComputed': expectedPointsComputed,
    'expectedPointsModelName': expectedPointsModelName,
    'expectedPointsModelVersion': expectedPointsModelVersion,
    'expectedPointsModelIsOfficial': expectedPointsModelIsOfficial,
    'beforeExpectedPoints': beforeExpectedPoints,
    'playedAfterExpectedPoints': playedAfterExpectedPoints,
    'candidateAfterExpectedPoints': candidateAfterExpectedPoints,
    'playedExpectedPointsDelta': playedExpectedPointsDelta,
    'candidateVsPlayedExpectedPointsDelta':
        candidateVsPlayedExpectedPointsDelta,
    'draftClassificationGateComputed': draftClassificationGateComputed,
    'evidenceStructurallyEligibleForFutureClassification':
        evidenceStructurallyEligibleForFutureClassification,
    'evidenceIsDeveloperOnly': evidenceIsDeveloperOnly,
    'gateRecommendation': gateRecommendation.wire,
    'privateDraftClassifierComputed': privateDraftClassifierComputed,
    'privateDraftBucket': privateDraftBucket.wire,
    'privateDraftReasonCode': privateDraftReasonCode.wire,
    'privateDraftConfidenceTier': privateDraftConfidenceTier.wire,
    'privateDraftClassifierIsPublic': privateDraftClassifierIsPublic,
    'privateDraftClassifierIsOfficialMoveQuality':
        privateDraftClassifierIsOfficialMoveQuality,
    'privateDraftClassifierIsPublicLabel': privateDraftClassifierIsPublicLabel,
    'privateSingleMoveDraftAnalysisComputed':
        privateSingleMoveDraftAnalysisComputed,
    'privateSingleMoveDraftAnalysisIsPublic':
        privateSingleMoveDraftAnalysisIsPublic,
    'privateSingleMoveDraftAnalysisIsProductReview':
        privateSingleMoveDraftAnalysisIsProductReview,
    'privateSingleMoveDraftAnalysisIsSavedAnalysis':
        privateSingleMoveDraftAnalysisIsSavedAnalysis,
    'privateSingleMoveDraftAnalysisIsOfficial':
        privateSingleMoveDraftAnalysisIsOfficial,
    'publicLabelComputed': publicLabelComputed,
    'publicLabel': publicLabel,
    'officialMoveQualityComputed': officialMoveQualityComputed,
    'officialMoveQuality': officialMoveQuality,
    'officialCpLossComputed': officialCpLossComputed,
    'officialWinPercentComputed': officialWinPercentComputed,
    'accuracyComputed': accuracyComputed,
    'acplComputed': acplComputed,
    'classificationComputed': classificationComputed,
    'publicClassifierOutputComputed': publicClassifierOutputComputed,
    'savedAnalysisWritten': savedAnalysisWritten,
    'uiOutputProduced': uiOutputProduced,
    'privateSingleMoveDraftAnalysisProbeSucceeded':
        privateSingleMoveDraftAnalysisProbeSucceeded,
    'failureMessage': failureMessage,
    'safeForPhase36A': safeForPhase36A,
    'nextRecommendation': nextRecommendation,
    'blockers': blockers,
    'warnings': warnings,
  };

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Apex Private Single-Move Draft Analysis Probe')
      ..writeln()
      ..writeln(
        'phase: Phase 35Q - Private Single-Move Draft Analysis Result Contract',
      )
      ..writeln('analysisResultId: $analysisResultId')
      ..writeln('playedMoveUci: $playedMoveUci')
      ..writeln('candidateMoveUci: $candidateMoveUci')
      ..writeln('moverColor: ${moverColor.wire}')
      ..writeln('requestedDepth: $requestedDepth')
      ..writeln('analysisSource: $analysisSource')
      ..writeln('analysisModelName: $analysisModelName')
      ..writeln('analysisModelVersion: $analysisModelVersion')
      ..writeln(
        'beforeMoverPerspectiveCp: ${beforeMoverPerspectiveCp ?? 'none'}',
      )
      ..writeln(
        'playedAfterMoverPerspectiveCp: '
        '${playedAfterMoverPerspectiveCp ?? 'none'}',
      )
      ..writeln(
        'candidateAfterMoverPerspectiveCp: '
        '${candidateAfterMoverPerspectiveCp ?? 'none'}',
      )
      ..writeln('moverPerspectiveDeltaCp: ${moverPerspectiveDeltaCp ?? 'none'}')
      ..writeln(
        'moverPerspectiveCpLossCandidate: '
        '${moverPerspectiveCpLossCandidate ?? 'none'}',
      )
      ..writeln('cpDeltaComputed: $cpDeltaComputed')
      ..writeln('cpLossCandidateComputed: $cpLossCandidateComputed')
      ..writeln(
        'cpLossCandidateDirection: ${cpLossCandidateDirection ?? 'none'}',
      )
      ..writeln('expectedPointsComputed: $expectedPointsComputed')
      ..writeln('expectedPointsModelName: ${expectedPointsModelName ?? 'none'}')
      ..writeln(
        'expectedPointsModelVersion: ${expectedPointsModelVersion ?? 'none'}',
      )
      ..writeln('expectedPointsModelIsOfficial: $expectedPointsModelIsOfficial')
      ..writeln('beforeExpectedPoints: ${beforeExpectedPoints ?? 'none'}')
      ..writeln(
        'playedAfterExpectedPoints: ${playedAfterExpectedPoints ?? 'none'}',
      )
      ..writeln(
        'candidateAfterExpectedPoints: '
        '${candidateAfterExpectedPoints ?? 'none'}',
      )
      ..writeln(
        'playedExpectedPointsDelta: ${playedExpectedPointsDelta ?? 'none'}',
      )
      ..writeln(
        'candidateVsPlayedExpectedPointsDelta: '
        '${candidateVsPlayedExpectedPointsDelta ?? 'none'}',
      )
      ..writeln(
        'draftClassificationGateComputed: '
        '$draftClassificationGateComputed',
      )
      ..writeln(
        'evidenceStructurallyEligibleForFutureClassification: '
        '$evidenceStructurallyEligibleForFutureClassification',
      )
      ..writeln('evidenceIsDeveloperOnly: $evidenceIsDeveloperOnly')
      ..writeln('gateRecommendation: ${gateRecommendation.wire}')
      ..writeln(
        'privateDraftClassifierComputed: $privateDraftClassifierComputed',
      )
      ..writeln('privateDraftBucket: ${privateDraftBucket.wire}')
      ..writeln('privateDraftReasonCode: ${privateDraftReasonCode.wire}')
      ..writeln(
        'privateDraftConfidenceTier: ${privateDraftConfidenceTier.wire}',
      )
      ..writeln(
        'privateDraftClassifierIsPublic: $privateDraftClassifierIsPublic',
      )
      ..writeln(
        'privateDraftClassifierIsOfficialMoveQuality: '
        '$privateDraftClassifierIsOfficialMoveQuality',
      )
      ..writeln(
        'privateDraftClassifierIsPublicLabel: '
        '$privateDraftClassifierIsPublicLabel',
      )
      ..writeln(
        'privateSingleMoveDraftAnalysisComputed: '
        '$privateSingleMoveDraftAnalysisComputed',
      )
      ..writeln(
        'privateSingleMoveDraftAnalysisIsPublic: '
        '$privateSingleMoveDraftAnalysisIsPublic',
      )
      ..writeln(
        'privateSingleMoveDraftAnalysisIsProductReview: '
        '$privateSingleMoveDraftAnalysisIsProductReview',
      )
      ..writeln(
        'privateSingleMoveDraftAnalysisIsSavedAnalysis: '
        '$privateSingleMoveDraftAnalysisIsSavedAnalysis',
      )
      ..writeln(
        'privateSingleMoveDraftAnalysisIsOfficial: '
        '$privateSingleMoveDraftAnalysisIsOfficial',
      )
      ..writeln('publicLabelComputed: $publicLabelComputed')
      ..writeln('publicLabel: ${publicLabel ?? 'none'}')
      ..writeln('officialMoveQualityComputed: $officialMoveQualityComputed')
      ..writeln('officialMoveQuality: ${officialMoveQuality ?? 'none'}')
      ..writeln('officialCpLossComputed: $officialCpLossComputed')
      ..writeln('officialWinPercentComputed: $officialWinPercentComputed')
      ..writeln('accuracyComputed: $accuracyComputed')
      ..writeln('acplComputed: $acplComputed')
      ..writeln('classificationComputed: $classificationComputed')
      ..writeln(
        'publicClassifierOutputComputed: $publicClassifierOutputComputed',
      )
      ..writeln('savedAnalysisWritten: $savedAnalysisWritten')
      ..writeln('uiOutputProduced: $uiOutputProduced')
      ..writeln(
        'privateSingleMoveDraftAnalysisProbeSucceeded: '
        '$privateSingleMoveDraftAnalysisProbeSucceeded',
      )
      ..writeln('failureMessage: ${failureMessage ?? 'none'}')
      ..writeln('safeForPhase36A: $safeForPhase36A')
      ..writeln('nextRecommendation: $nextRecommendation')
      ..writeln()
      ..writeln('## Blockers');
    _writeList(buffer, blockers);
    buffer
      ..writeln()
      ..writeln('## Warnings');
    _writeList(buffer, warnings);
    buffer
      ..writeln()
      ..writeln('## Safety Notes')
      ..writeln('- Developer-only private single-move draft analysis')
      ..writeln('- Not product review, saved analysis, or official output')
      ..writeln(
        '- No public label, official metrics, or public classifier output',
      )
      ..writeln(
        '- No PGN, scheduler, persistence, UI, archive, stats, or backend',
      );
    return buffer.toString();
  }

  static void _writeList(StringBuffer buffer, List<String> values) {
    if (values.isEmpty) {
      buffer.writeln('- none');
      return;
    }
    for (final value in values) {
      buffer.writeln('- $value');
    }
  }
}

AnalyzerPrivateSingleMoveDraftAnalysisResult
evaluateAnalyzerPrivateSingleMoveDraftAnalysis({
  required AnalyzerPrivateSingleMoveDraftAnalysisRequest request,
  required AnalyzerPrivateDraftClassifierResult privateClassifier,
}) {
  const privateSingleMoveDraftAnalysisIsPublic = false;
  const privateSingleMoveDraftAnalysisIsProductReview = false;
  const privateSingleMoveDraftAnalysisIsSavedAnalysis = false;
  const privateSingleMoveDraftAnalysisIsOfficial = false;
  const savedAnalysisWritten = false;
  const uiOutputProduced = false;

  final cpDeltaComputed = privateClassifier.moverPerspectiveDeltaCp != null;
  final cpLossCandidateComputed =
      privateClassifier.moverPerspectiveCpLossCandidate != null;
  final expectedPointsComputed =
      privateClassifier.beforeExpectedPoints != null &&
      privateClassifier.playedAfterExpectedPoints != null &&
      privateClassifier.candidateAfterExpectedPoints != null &&
      privateClassifier.playedExpectedPointsDelta != null &&
      privateClassifier.candidateVsPlayedExpectedPointsDelta != null;
  final publicStringsClean = !_containsForbiddenPublicString(privateClassifier);
  final privateClassifierClean =
      privateClassifier.privateDraftClassifierProbeSucceeded &&
      privateClassifier.safeForPhase35O &&
      privateClassifier.draftClassificationGateComputed &&
      privateClassifier.evidenceStructurallyEligibleForFutureClassification &&
      privateClassifier.evidenceIsDeveloperOnly &&
      privateClassifier.privateDraftClassifierComputed &&
      privateClassifier.privateDraftBucket !=
          AnalyzerPrivateDraftBucket.unavailable &&
      !privateClassifier.privateDraftClassifierIsPublic &&
      !privateClassifier.privateDraftClassifierIsOfficialMoveQuality &&
      !privateClassifier.privateDraftClassifierIsPublicLabel &&
      !privateClassifier.expectedPointsModelIsOfficial &&
      !privateClassifier.publicLabelComputed &&
      privateClassifier.publicLabel == null &&
      !privateClassifier.officialMoveQualityComputed &&
      privateClassifier.officialMoveQuality == null &&
      !privateClassifier.officialCpLossComputed &&
      !privateClassifier.officialWinPercentComputed &&
      !privateClassifier.accuracyComputed &&
      !privateClassifier.acplComputed &&
      !privateClassifier.classificationComputed &&
      !privateClassifier.publicClassifierOutputComputed;
  final privateSingleMoveDraftAnalysisComputed =
      privateClassifierClean && publicStringsClean;
  final succeeded =
      privateSingleMoveDraftAnalysisComputed &&
      !privateSingleMoveDraftAnalysisIsPublic &&
      !privateSingleMoveDraftAnalysisIsProductReview &&
      !privateSingleMoveDraftAnalysisIsSavedAnalysis &&
      !privateSingleMoveDraftAnalysisIsOfficial &&
      !savedAnalysisWritten &&
      !uiOutputProduced;

  final blockers = <String>[];
  if (!succeeded) {
    blockers.add('Private single-move draft analysis proof is blocked.');
  }
  if (!privateClassifier.privateDraftClassifierProbeSucceeded) {
    blockers.add('Private draft classifier did not succeed.');
  }
  if (!publicStringsClean) {
    blockers.add('Public label string appeared in private draft analysis.');
  }
  blockers.addAll(privateClassifier.blockers.map((b) => 'classifier: $b'));

  final warnings = <String>[];
  if (!succeeded) {
    warnings.add(
      'This is not a successful private single-move draft analysis proof.',
    );
    warnings.add('Do not proceed to Phase 36A yet.');
  }
  warnings.addAll(privateClassifier.warnings.map((w) => 'classifier: $w'));

  return AnalyzerPrivateSingleMoveDraftAnalysisResult(
    analysisResultId: _analysisResultId(request),
    playedMoveUci: request.playedMoveUci,
    candidateMoveUci: request.candidateMoveUci,
    moverColor: request.moverColor,
    requestedDepth: request.requestedDepth,
    analysisSource: request.source,
    analysisModelName: analyzerPrivateSingleMoveDraftAnalysisModelName,
    analysisModelVersion: analyzerPrivateSingleMoveDraftAnalysisModelVersion,
    beforeMoverPerspectiveCp: privateClassifier.beforeMoverPerspectiveCp,
    playedAfterMoverPerspectiveCp:
        privateClassifier.playedAfterMoverPerspectiveCp,
    candidateAfterMoverPerspectiveCp:
        privateClassifier.candidateAfterMoverPerspectiveCp,
    moverPerspectiveDeltaCp: privateClassifier.moverPerspectiveDeltaCp,
    moverPerspectiveCpLossCandidate:
        privateClassifier.moverPerspectiveCpLossCandidate,
    cpDeltaComputed: cpDeltaComputed,
    cpLossCandidateComputed: cpLossCandidateComputed,
    cpLossCandidateDirection: privateClassifier.cpLossCandidateDirection,
    expectedPointsComputed: expectedPointsComputed,
    expectedPointsModelName: privateClassifier.expectedPointsModelName,
    expectedPointsModelVersion: privateClassifier.expectedPointsModelVersion,
    expectedPointsModelIsOfficial:
        privateClassifier.expectedPointsModelIsOfficial,
    beforeExpectedPoints: privateClassifier.beforeExpectedPoints,
    playedAfterExpectedPoints: privateClassifier.playedAfterExpectedPoints,
    candidateAfterExpectedPoints:
        privateClassifier.candidateAfterExpectedPoints,
    playedExpectedPointsDelta: privateClassifier.playedExpectedPointsDelta,
    candidateVsPlayedExpectedPointsDelta:
        privateClassifier.candidateVsPlayedExpectedPointsDelta,
    draftClassificationGateComputed:
        privateClassifier.draftClassificationGateComputed,
    evidenceStructurallyEligibleForFutureClassification:
        privateClassifier.evidenceStructurallyEligibleForFutureClassification,
    evidenceIsDeveloperOnly: privateClassifier.evidenceIsDeveloperOnly,
    gateRecommendation: privateClassifier.gateRecommendation,
    privateDraftClassifierComputed:
        privateClassifier.privateDraftClassifierComputed,
    privateDraftBucket: privateClassifier.privateDraftBucket,
    privateDraftReasonCode: privateClassifier.privateDraftReasonCode,
    privateDraftConfidenceTier: privateClassifier.privateDraftConfidenceTier,
    privateDraftClassifierIsPublic:
        privateClassifier.privateDraftClassifierIsPublic,
    privateDraftClassifierIsOfficialMoveQuality:
        privateClassifier.privateDraftClassifierIsOfficialMoveQuality,
    privateDraftClassifierIsPublicLabel:
        privateClassifier.privateDraftClassifierIsPublicLabel,
    privateSingleMoveDraftAnalysisComputed:
        privateSingleMoveDraftAnalysisComputed,
    privateSingleMoveDraftAnalysisIsPublic:
        privateSingleMoveDraftAnalysisIsPublic,
    privateSingleMoveDraftAnalysisIsProductReview:
        privateSingleMoveDraftAnalysisIsProductReview,
    privateSingleMoveDraftAnalysisIsSavedAnalysis:
        privateSingleMoveDraftAnalysisIsSavedAnalysis,
    privateSingleMoveDraftAnalysisIsOfficial:
        privateSingleMoveDraftAnalysisIsOfficial,
    publicLabelComputed: privateClassifier.publicLabelComputed,
    publicLabel: privateClassifier.publicLabel,
    officialMoveQualityComputed: privateClassifier.officialMoveQualityComputed,
    officialMoveQuality: privateClassifier.officialMoveQuality,
    officialCpLossComputed: privateClassifier.officialCpLossComputed,
    officialWinPercentComputed: privateClassifier.officialWinPercentComputed,
    accuracyComputed: privateClassifier.accuracyComputed,
    acplComputed: privateClassifier.acplComputed,
    classificationComputed: privateClassifier.classificationComputed,
    publicClassifierOutputComputed:
        privateClassifier.publicClassifierOutputComputed,
    savedAnalysisWritten: savedAnalysisWritten,
    uiOutputProduced: uiOutputProduced,
    privateSingleMoveDraftAnalysisProbeSucceeded: succeeded,
    failureMessage: succeeded
        ? null
        : privateClassifier.failureMessage ??
              'Private single-move draft analysis proof did not succeed.',
    safeForPhase36A: succeeded,
    nextRecommendation: succeeded
        ? analyzerPrivateSingleMoveDraftAnalysisNextRecommendation
        : analyzerPrivateSingleMoveDraftAnalysisFailureRecommendation,
    blockers: List.unmodifiable(blockers.toSet().toList()..sort()),
    warnings: List.unmodifiable(warnings.toSet().toList()..sort()),
  );
}

String _analysisResultId(
  AnalyzerPrivateSingleMoveDraftAnalysisRequest request,
) {
  return [
    'phase35Q',
    request.playedMoveUci,
    request.candidateMoveUci,
    request.moverColor.wire,
    'depth${request.requestedDepth}',
  ].join(':');
}

bool _containsForbiddenPublicString(
  AnalyzerPrivateDraftClassifierResult privateClassifier,
) {
  final values = <String?>[
    privateClassifier.publicLabel,
    privateClassifier.officialMoveQuality,
    privateClassifier.privateDraftBucket.wire,
    privateClassifier.privateDraftReasonCode.wire,
    privateClassifier.privateDraftConfidenceTier.wire,
  ].whereType<String>();
  return values.any(_forbiddenPublicStrings.contains);
}

const _forbiddenPublicStrings = <String>{
  'Brilliant',
  'Great',
  'Best',
  'Excellent',
  'Good',
  'Book',
  'Inaccuracy',
  'Mistake',
  'Miss',
  'Blunder',
  'Checkmate',
};

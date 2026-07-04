import 'dart:convert';

import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_draft_classification_gate.dart';

const analyzerPrivateDraftClassifierPlayedMoveUci =
    analyzerDraftClassificationGatePlayedMoveUci;
const analyzerPrivateDraftClassifierCandidateMoveUci =
    analyzerDraftClassificationGateCandidateMoveUci;
const analyzerPrivateDraftClassifierDepth =
    analyzerDraftClassificationGateDepth;
const analyzerPrivateDraftClassifierSource =
    'phase35NControlledPrivateDraftClassifier';
const analyzerPrivateDraftClassifierModelName =
    'internalPrivateDraftClassifierDeveloperOnly';
const analyzerPrivateDraftClassifierModelVersion = 'phase35N.v1';
const analyzerPrivateDraftClassifierNextRecommendation =
    'implementPrivateDraftClassifierGoldenCasesWithoutPublicLabels';
const analyzerPrivateDraftClassifierFailureRecommendation =
    'fixAnalyzerPrivateDraftClassifier';

enum AnalyzerPrivateDraftBucket {
  positiveCandidate('positiveCandidate'),
  neutralCandidate('neutralCandidate'),
  negativeCandidate('negativeCandidate'),
  unavailable('unavailable');

  const AnalyzerPrivateDraftBucket(this.wire);

  final String wire;
}

enum AnalyzerPrivateDraftReasonCode {
  improvedAndCandidateSimilar('improvedAndCandidateSimilar'),
  improvedButCandidateSlightlyBetter('improvedButCandidateSlightlyBetter'),
  worsenedAgainstCandidate('worsenedAgainstCandidate'),
  equalToCandidate('equalToCandidate'),
  missingEvidence('missingEvidence'),
  gateBlocked('gateBlocked');

  const AnalyzerPrivateDraftReasonCode(this.wire);

  final String wire;
}

enum AnalyzerPrivateDraftConfidenceTier {
  low('low'),
  medium('medium'),
  high('high'),
  unavailable('unavailable');

  const AnalyzerPrivateDraftConfidenceTier(this.wire);

  final String wire;
}

class AnalyzerPrivateDraftClassifierRequest {
  const AnalyzerPrivateDraftClassifierRequest({
    required this.playedMoveUci,
    required this.candidateMoveUci,
    required this.moverColor,
    required this.requestedDepth,
    required this.source,
  });

  const AnalyzerPrivateDraftClassifierRequest.controlled({
    AnalyzerMoverColor moverColor = AnalyzerMoverColor.white,
  }) : this(
         playedMoveUci: analyzerPrivateDraftClassifierPlayedMoveUci,
         candidateMoveUci: analyzerPrivateDraftClassifierCandidateMoveUci,
         moverColor: moverColor,
         requestedDepth: analyzerPrivateDraftClassifierDepth,
         source: analyzerPrivateDraftClassifierSource,
       );

  final String playedMoveUci;
  final String candidateMoveUci;
  final AnalyzerMoverColor moverColor;
  final int requestedDepth;
  final String source;
}

class AnalyzerPrivateDraftClassifierResult {
  const AnalyzerPrivateDraftClassifierResult({
    required this.playedMoveUci,
    required this.candidateMoveUci,
    required this.moverColor,
    required this.requestedDepth,
    required this.privateClassifierSource,
    required this.privateClassifierModelName,
    required this.privateClassifierModelVersion,
    required this.draftClassificationGateComputed,
    required this.evidenceStructurallyEligibleForFutureClassification,
    required this.evidenceIsDeveloperOnly,
    required this.gateRecommendation,
    this.beforeMoverPerspectiveCp,
    this.playedAfterMoverPerspectiveCp,
    this.candidateAfterMoverPerspectiveCp,
    required this.moverPerspectiveDeltaCp,
    required this.moverPerspectiveCpLossCandidate,
    required this.cpLossCandidateDirection,
    this.expectedPointsModelName,
    this.expectedPointsModelVersion,
    this.expectedPointsModelIsOfficial = false,
    this.beforeExpectedPoints,
    this.playedAfterExpectedPoints,
    this.candidateAfterExpectedPoints,
    required this.playedExpectedPointsDelta,
    required this.candidateVsPlayedExpectedPointsDelta,
    required this.privateDraftClassifierComputed,
    required this.privateDraftBucket,
    required this.privateDraftReasonCode,
    required this.privateDraftConfidenceTier,
    required this.privateDraftClassifierIsPublic,
    required this.privateDraftClassifierIsOfficialMoveQuality,
    required this.privateDraftClassifierIsPublicLabel,
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
    required this.privateDraftClassifierProbeSucceeded,
    required this.failureMessage,
    required this.safeForPhase35O,
    required this.nextRecommendation,
    required this.blockers,
    required this.warnings,
  });

  final String playedMoveUci;
  final String candidateMoveUci;
  final AnalyzerMoverColor moverColor;
  final int requestedDepth;
  final String privateClassifierSource;
  final String privateClassifierModelName;
  final String privateClassifierModelVersion;
  final bool draftClassificationGateComputed;
  final bool evidenceStructurallyEligibleForFutureClassification;
  final bool evidenceIsDeveloperOnly;
  final AnalyzerDraftClassificationGateRecommendation gateRecommendation;
  final int? beforeMoverPerspectiveCp;
  final int? playedAfterMoverPerspectiveCp;
  final int? candidateAfterMoverPerspectiveCp;
  final int? moverPerspectiveDeltaCp;
  final int? moverPerspectiveCpLossCandidate;
  final String? cpLossCandidateDirection;
  final String? expectedPointsModelName;
  final String? expectedPointsModelVersion;
  final bool expectedPointsModelIsOfficial;
  final double? beforeExpectedPoints;
  final double? playedAfterExpectedPoints;
  final double? candidateAfterExpectedPoints;
  final double? playedExpectedPointsDelta;
  final double? candidateVsPlayedExpectedPointsDelta;
  final bool privateDraftClassifierComputed;
  final AnalyzerPrivateDraftBucket privateDraftBucket;
  final AnalyzerPrivateDraftReasonCode privateDraftReasonCode;
  final AnalyzerPrivateDraftConfidenceTier privateDraftConfidenceTier;
  final bool privateDraftClassifierIsPublic;
  final bool privateDraftClassifierIsOfficialMoveQuality;
  final bool privateDraftClassifierIsPublicLabel;
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
  final bool privateDraftClassifierProbeSucceeded;
  final String? failureMessage;
  final bool safeForPhase35O;
  final String nextRecommendation;
  final List<String> blockers;
  final List<String> warnings;

  Map<String, Object?> toJson() => {
    'playedMoveUci': playedMoveUci,
    'candidateMoveUci': candidateMoveUci,
    'moverColor': moverColor.wire,
    'requestedDepth': requestedDepth,
    'privateClassifierSource': privateClassifierSource,
    'privateClassifierModelName': privateClassifierModelName,
    'privateClassifierModelVersion': privateClassifierModelVersion,
    'draftClassificationGateComputed': draftClassificationGateComputed,
    'evidenceStructurallyEligibleForFutureClassification':
        evidenceStructurallyEligibleForFutureClassification,
    'evidenceIsDeveloperOnly': evidenceIsDeveloperOnly,
    'gateRecommendation': gateRecommendation.wire,
    'beforeMoverPerspectiveCp': beforeMoverPerspectiveCp,
    'playedAfterMoverPerspectiveCp': playedAfterMoverPerspectiveCp,
    'candidateAfterMoverPerspectiveCp': candidateAfterMoverPerspectiveCp,
    'moverPerspectiveDeltaCp': moverPerspectiveDeltaCp,
    'moverPerspectiveCpLossCandidate': moverPerspectiveCpLossCandidate,
    'cpLossCandidateDirection': cpLossCandidateDirection,
    'expectedPointsModelName': expectedPointsModelName,
    'expectedPointsModelVersion': expectedPointsModelVersion,
    'expectedPointsModelIsOfficial': expectedPointsModelIsOfficial,
    'beforeExpectedPoints': beforeExpectedPoints,
    'playedAfterExpectedPoints': playedAfterExpectedPoints,
    'candidateAfterExpectedPoints': candidateAfterExpectedPoints,
    'playedExpectedPointsDelta': playedExpectedPointsDelta,
    'candidateVsPlayedExpectedPointsDelta':
        candidateVsPlayedExpectedPointsDelta,
    'privateDraftClassifierComputed': privateDraftClassifierComputed,
    'privateDraftBucket': privateDraftBucket.wire,
    'privateDraftReasonCode': privateDraftReasonCode.wire,
    'privateDraftConfidenceTier': privateDraftConfidenceTier.wire,
    'privateDraftClassifierIsPublic': privateDraftClassifierIsPublic,
    'privateDraftClassifierIsOfficialMoveQuality':
        privateDraftClassifierIsOfficialMoveQuality,
    'privateDraftClassifierIsPublicLabel': privateDraftClassifierIsPublicLabel,
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
    'privateDraftClassifierProbeSucceeded':
        privateDraftClassifierProbeSucceeded,
    'failureMessage': failureMessage,
    'safeForPhase35O': safeForPhase35O,
    'nextRecommendation': nextRecommendation,
    'blockers': blockers,
    'warnings': warnings,
  };

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Apex Private Draft Classifier Probe')
      ..writeln()
      ..writeln(
        'phase: Phase 35N - Private Single-Move Draft Classifier Without Public Labels',
      )
      ..writeln('playedMoveUci: $playedMoveUci')
      ..writeln('candidateMoveUci: $candidateMoveUci')
      ..writeln('moverColor: ${moverColor.wire}')
      ..writeln('requestedDepth: $requestedDepth')
      ..writeln('privateClassifierSource: $privateClassifierSource')
      ..writeln('privateClassifierModelName: $privateClassifierModelName')
      ..writeln('privateClassifierModelVersion: $privateClassifierModelVersion')
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
      ..writeln(
        'cpLossCandidateDirection: ${cpLossCandidateDirection ?? 'none'}',
      )
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
      ..writeln(
        'privateDraftClassifierProbeSucceeded: '
        '$privateDraftClassifierProbeSucceeded',
      )
      ..writeln('failureMessage: ${failureMessage ?? 'none'}')
      ..writeln('safeForPhase35O: $safeForPhase35O')
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
      ..writeln('- Developer-only private draft bucket')
      ..writeln('- Private bucket is not product move quality')
      ..writeln(
        '- No public label, official metrics, or public classifier output',
      )
      ..writeln('- No PGN, scheduler, persistence, UI, or backend');
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

AnalyzerPrivateDraftClassifierResult evaluateAnalyzerPrivateDraftClassifier({
  required AnalyzerPrivateDraftClassifierRequest request,
  required AnalyzerDraftClassificationGateResult gate,
}) {
  const privateDraftClassifierIsPublic = false;
  const privateDraftClassifierIsOfficialMoveQuality = false;
  const privateDraftClassifierIsPublicLabel = false;
  const publicLabelComputed = false;
  const publicLabel = null;
  const officialMoveQualityComputed = false;
  const officialMoveQuality = null;
  const officialCpLossComputed = false;
  const officialWinPercentComputed = false;
  const accuracyComputed = false;
  const acplComputed = false;
  const classificationComputed = false;
  const publicClassifierOutputComputed = false;

  final gateReady =
      gate.draftClassificationGateProbeSucceeded &&
      gate.draftClassificationGateComputed &&
      gate.evidenceStructurallyEligibleForFutureClassification &&
      gate.evidenceIsDeveloperOnly &&
      gate.gateRecommendation ==
          AnalyzerDraftClassificationGateRecommendation
              .eligibleForFutureDraftClassifier;
  final requiredEvidencePresent =
      gate.moverPerspectiveDeltaCp != null &&
      gate.moverPerspectiveCpLossCandidate != null &&
      gate.candidateVsPlayedExpectedPointsDelta != null;
  final decision = _privateDraftDecision(
    gateReady: gateReady,
    requiredEvidencePresent: requiredEvidencePresent,
    moverPerspectiveDeltaCp: gate.moverPerspectiveDeltaCp,
    moverPerspectiveCpLossCandidate: gate.moverPerspectiveCpLossCandidate,
  );
  final privateDraftClassifierComputed =
      gateReady &&
      requiredEvidencePresent &&
      decision.bucket != AnalyzerPrivateDraftBucket.unavailable;
  final succeeded =
      privateDraftClassifierComputed &&
      !privateDraftClassifierIsPublic &&
      !privateDraftClassifierIsOfficialMoveQuality &&
      !privateDraftClassifierIsPublicLabel &&
      !publicLabelComputed &&
      !officialMoveQualityComputed &&
      !officialCpLossComputed &&
      !officialWinPercentComputed &&
      !accuracyComputed &&
      !acplComputed &&
      !classificationComputed &&
      !publicClassifierOutputComputed;

  final blockers = <String>[];
  if (!succeeded) {
    blockers.add('Private draft classifier proof is blocked.');
  }
  if (!gateReady) {
    blockers.add('Draft classification gate is not eligible.');
  }
  if (!requiredEvidencePresent) {
    blockers.add('Required private draft classifier evidence is incomplete.');
  }
  blockers.addAll(gate.blockers.map((b) => 'gate: $b'));

  final warnings = <String>[];
  if (!succeeded) {
    warnings.add('This is not a successful private draft classifier proof.');
    warnings.add('Do not proceed to Phase 35O yet.');
  }
  warnings.addAll(gate.warnings.map((w) => 'gate: $w'));

  return AnalyzerPrivateDraftClassifierResult(
    playedMoveUci: request.playedMoveUci,
    candidateMoveUci: request.candidateMoveUci,
    moverColor: request.moverColor,
    requestedDepth: request.requestedDepth,
    privateClassifierSource: request.source,
    privateClassifierModelName: analyzerPrivateDraftClassifierModelName,
    privateClassifierModelVersion: analyzerPrivateDraftClassifierModelVersion,
    draftClassificationGateComputed: gate.draftClassificationGateComputed,
    evidenceStructurallyEligibleForFutureClassification:
        gate.evidenceStructurallyEligibleForFutureClassification,
    evidenceIsDeveloperOnly: gate.evidenceIsDeveloperOnly,
    gateRecommendation: gate.gateRecommendation,
    beforeMoverPerspectiveCp: gate.beforeMoverPerspectiveCp,
    playedAfterMoverPerspectiveCp: gate.playedAfterMoverPerspectiveCp,
    candidateAfterMoverPerspectiveCp: gate.candidateAfterMoverPerspectiveCp,
    moverPerspectiveDeltaCp: gate.moverPerspectiveDeltaCp,
    moverPerspectiveCpLossCandidate: gate.moverPerspectiveCpLossCandidate,
    cpLossCandidateDirection: gate.cpLossCandidateDirection,
    expectedPointsModelName: gate.expectedPointsModelName,
    expectedPointsModelVersion: gate.expectedPointsModelVersion,
    expectedPointsModelIsOfficial: gate.expectedPointsModelIsOfficial,
    beforeExpectedPoints: gate.beforeExpectedPoints,
    playedAfterExpectedPoints: gate.playedAfterExpectedPoints,
    candidateAfterExpectedPoints: gate.candidateAfterExpectedPoints,
    playedExpectedPointsDelta: gate.playedExpectedPointsDelta,
    candidateVsPlayedExpectedPointsDelta:
        gate.candidateVsPlayedExpectedPointsDelta,
    privateDraftClassifierComputed: privateDraftClassifierComputed,
    privateDraftBucket: decision.bucket,
    privateDraftReasonCode: decision.reasonCode,
    privateDraftConfidenceTier: decision.confidenceTier,
    privateDraftClassifierIsPublic: privateDraftClassifierIsPublic,
    privateDraftClassifierIsOfficialMoveQuality:
        privateDraftClassifierIsOfficialMoveQuality,
    privateDraftClassifierIsPublicLabel: privateDraftClassifierIsPublicLabel,
    publicLabelComputed: publicLabelComputed,
    publicLabel: publicLabel,
    officialMoveQualityComputed: officialMoveQualityComputed,
    officialMoveQuality: officialMoveQuality,
    officialCpLossComputed: officialCpLossComputed,
    officialWinPercentComputed: officialWinPercentComputed,
    accuracyComputed: accuracyComputed,
    acplComputed: acplComputed,
    classificationComputed: classificationComputed,
    publicClassifierOutputComputed: publicClassifierOutputComputed,
    privateDraftClassifierProbeSucceeded: succeeded,
    failureMessage: succeeded
        ? null
        : _failureMessage(
            gateReady: gateReady,
            requiredEvidencePresent: requiredEvidencePresent,
            gate: gate,
          ),
    safeForPhase35O: succeeded,
    nextRecommendation: succeeded
        ? analyzerPrivateDraftClassifierNextRecommendation
        : analyzerPrivateDraftClassifierFailureRecommendation,
    blockers: List.unmodifiable(blockers.toSet().toList()..sort()),
    warnings: List.unmodifiable(warnings.toSet().toList()..sort()),
  );
}

({
  AnalyzerPrivateDraftBucket bucket,
  AnalyzerPrivateDraftReasonCode reasonCode,
  AnalyzerPrivateDraftConfidenceTier confidenceTier,
})
_privateDraftDecision({
  required bool gateReady,
  required bool requiredEvidencePresent,
  required int? moverPerspectiveDeltaCp,
  required int? moverPerspectiveCpLossCandidate,
}) {
  if (!gateReady) {
    return (
      bucket: AnalyzerPrivateDraftBucket.unavailable,
      reasonCode: AnalyzerPrivateDraftReasonCode.gateBlocked,
      confidenceTier: AnalyzerPrivateDraftConfidenceTier.unavailable,
    );
  }
  if (!requiredEvidencePresent ||
      moverPerspectiveDeltaCp == null ||
      moverPerspectiveCpLossCandidate == null) {
    return (
      bucket: AnalyzerPrivateDraftBucket.unavailable,
      reasonCode: AnalyzerPrivateDraftReasonCode.missingEvidence,
      confidenceTier: AnalyzerPrivateDraftConfidenceTier.unavailable,
    );
  }
  if (moverPerspectiveDeltaCp < 0 || moverPerspectiveCpLossCandidate > 120) {
    return (
      bucket: AnalyzerPrivateDraftBucket.negativeCandidate,
      reasonCode: AnalyzerPrivateDraftReasonCode.worsenedAgainstCandidate,
      confidenceTier: AnalyzerPrivateDraftConfidenceTier.low,
    );
  }
  if (moverPerspectiveDeltaCp > 0 && moverPerspectiveCpLossCandidate <= 35) {
    return (
      bucket: AnalyzerPrivateDraftBucket.positiveCandidate,
      reasonCode: moverPerspectiveCpLossCandidate > 0
          ? AnalyzerPrivateDraftReasonCode.improvedButCandidateSlightlyBetter
          : AnalyzerPrivateDraftReasonCode.improvedAndCandidateSimilar,
      confidenceTier: AnalyzerPrivateDraftConfidenceTier.low,
    );
  }
  if (moverPerspectiveDeltaCp >= -20 && moverPerspectiveCpLossCandidate <= 60) {
    return (
      bucket: AnalyzerPrivateDraftBucket.neutralCandidate,
      reasonCode: moverPerspectiveCpLossCandidate == 0
          ? AnalyzerPrivateDraftReasonCode.equalToCandidate
          : AnalyzerPrivateDraftReasonCode.improvedButCandidateSlightlyBetter,
      confidenceTier: AnalyzerPrivateDraftConfidenceTier.low,
    );
  }
  return (
    bucket: AnalyzerPrivateDraftBucket.unavailable,
    reasonCode: AnalyzerPrivateDraftReasonCode.missingEvidence,
    confidenceTier: AnalyzerPrivateDraftConfidenceTier.unavailable,
  );
}

String _failureMessage({
  required bool gateReady,
  required bool requiredEvidencePresent,
  required AnalyzerDraftClassificationGateResult gate,
}) {
  if (!gateReady) {
    return gate.failureMessage ?? 'Draft classification gate is not eligible.';
  }
  if (!requiredEvidencePresent) {
    return 'Required private draft classifier evidence is incomplete.';
  }
  return 'Private draft classifier proof did not succeed.';
}

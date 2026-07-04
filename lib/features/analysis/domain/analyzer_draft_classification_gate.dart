import 'dart:convert';

import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_move_quality_draft_evidence.dart';

const analyzerDraftClassificationGatePlayedMoveUci =
    analyzerMoveQualityDraftEvidencePlayedMoveUci;
const analyzerDraftClassificationGateCandidateMoveUci =
    analyzerMoveQualityDraftEvidenceCandidateMoveUci;
const analyzerDraftClassificationGateDepth =
    analyzerMoveQualityDraftEvidenceDepth;
const analyzerDraftClassificationGateSource =
    'phase35MControlledDraftClassificationGate';
const analyzerDraftClassificationGateModelName =
    'internalDraftClassificationGateDeveloperOnly';
const analyzerDraftClassificationGateModelVersion = 'phase35M.v1';
const analyzerDraftClassificationGateNextRecommendation =
    'implementPrivateSingleMoveDraftClassifierWithoutPublicLabels';
const analyzerDraftClassificationGateFailureRecommendation =
    'fixAnalyzerDraftClassificationGate';

enum AnalyzerDraftClassificationGateRecommendation {
  eligibleForFutureDraftClassifier('eligibleForFutureDraftClassifier'),
  notEligibleMissingEvidence('notEligibleMissingEvidence'),
  blockedBecauseEvidenceIsPublic('blockedBecauseEvidenceIsPublic'),
  blockedBecauseEvidenceIsOfficialMoveQuality(
    'blockedBecauseEvidenceIsOfficialMoveQuality',
  ),
  blockedBecauseEvidenceIsClassifierOutput(
    'blockedBecauseEvidenceIsClassifierOutput',
  ),
  blockedBecauseOfficialMetricsAlreadyComputed(
    'blockedBecauseOfficialMetricsAlreadyComputed',
  );

  const AnalyzerDraftClassificationGateRecommendation(this.wire);

  final String wire;
}

class AnalyzerDraftClassificationGateRequest {
  const AnalyzerDraftClassificationGateRequest({
    required this.playedMoveUci,
    required this.candidateMoveUci,
    required this.moverColor,
    required this.requestedDepth,
    required this.source,
  });

  const AnalyzerDraftClassificationGateRequest.controlled({
    AnalyzerMoverColor moverColor = AnalyzerMoverColor.white,
  }) : this(
         playedMoveUci: analyzerDraftClassificationGatePlayedMoveUci,
         candidateMoveUci: analyzerDraftClassificationGateCandidateMoveUci,
         moverColor: moverColor,
         requestedDepth: analyzerDraftClassificationGateDepth,
         source: analyzerDraftClassificationGateSource,
       );

  final String playedMoveUci;
  final String candidateMoveUci;
  final AnalyzerMoverColor moverColor;
  final int requestedDepth;
  final String source;
}

class AnalyzerDraftClassificationGateResult {
  const AnalyzerDraftClassificationGateResult({
    required this.playedMoveUci,
    required this.candidateMoveUci,
    required this.moverColor,
    required this.requestedDepth,
    required this.gateSource,
    required this.gateModelName,
    required this.gateModelVersion,
    required this.draftEvidenceComputed,
    required this.cpDeltaComputed,
    required this.cpLossCandidateComputed,
    required this.expectedPointsComputed,
    required this.expectedPointsModelIsOfficial,
    required this.draftEvidenceIsPublic,
    required this.draftEvidenceIsOfficialMoveQuality,
    required this.draftEvidenceIsClassifierOutput,
    this.beforeMoverPerspectiveCp,
    this.playedAfterMoverPerspectiveCp,
    this.candidateAfterMoverPerspectiveCp,
    required this.moverPerspectiveDeltaCp,
    required this.moverPerspectiveCpLossCandidate,
    required this.cpLossCandidateDirection,
    this.expectedPointsModelName,
    this.expectedPointsModelVersion,
    this.beforeExpectedPoints,
    this.playedAfterExpectedPoints,
    this.candidateAfterExpectedPoints,
    required this.playedExpectedPointsDelta,
    required this.candidateVsPlayedExpectedPointsDelta,
    required this.draftClassificationGateComputed,
    required this.evidenceStructurallyEligibleForFutureClassification,
    required this.evidenceHasBeforeAfterCp,
    required this.evidenceHasCandidateComparison,
    required this.evidenceHasExpectedPoints,
    required this.evidenceIsDeveloperOnly,
    required this.gateRecommendation,
    required this.publicLabelComputed,
    required this.publicLabel,
    required this.officialMoveQualityComputed,
    required this.officialMoveQuality,
    required this.officialCpLossComputed,
    required this.officialWinPercentComputed,
    required this.accuracyComputed,
    required this.acplComputed,
    required this.classificationComputed,
    required this.classifierOutputComputed,
    required this.draftClassificationGateProbeSucceeded,
    required this.failureMessage,
    required this.safeForPhase35N,
    required this.nextRecommendation,
    required this.blockers,
    required this.warnings,
  });

  final String playedMoveUci;
  final String candidateMoveUci;
  final AnalyzerMoverColor moverColor;
  final int requestedDepth;
  final String gateSource;
  final String gateModelName;
  final String gateModelVersion;
  final bool draftEvidenceComputed;
  final bool cpDeltaComputed;
  final bool cpLossCandidateComputed;
  final bool expectedPointsComputed;
  final bool expectedPointsModelIsOfficial;
  final bool draftEvidenceIsPublic;
  final bool draftEvidenceIsOfficialMoveQuality;
  final bool draftEvidenceIsClassifierOutput;
  final int? beforeMoverPerspectiveCp;
  final int? playedAfterMoverPerspectiveCp;
  final int? candidateAfterMoverPerspectiveCp;
  final int? moverPerspectiveDeltaCp;
  final int? moverPerspectiveCpLossCandidate;
  final String? cpLossCandidateDirection;
  final String? expectedPointsModelName;
  final String? expectedPointsModelVersion;
  final double? beforeExpectedPoints;
  final double? playedAfterExpectedPoints;
  final double? candidateAfterExpectedPoints;
  final double? playedExpectedPointsDelta;
  final double? candidateVsPlayedExpectedPointsDelta;
  final bool draftClassificationGateComputed;
  final bool evidenceStructurallyEligibleForFutureClassification;
  final bool evidenceHasBeforeAfterCp;
  final bool evidenceHasCandidateComparison;
  final bool evidenceHasExpectedPoints;
  final bool evidenceIsDeveloperOnly;
  final AnalyzerDraftClassificationGateRecommendation gateRecommendation;
  final bool publicLabelComputed;
  final String? publicLabel;
  final bool officialMoveQualityComputed;
  final String? officialMoveQuality;
  final bool officialCpLossComputed;
  final bool officialWinPercentComputed;
  final bool accuracyComputed;
  final bool acplComputed;
  final bool classificationComputed;
  final bool classifierOutputComputed;
  final bool draftClassificationGateProbeSucceeded;
  final String? failureMessage;
  final bool safeForPhase35N;
  final String nextRecommendation;
  final List<String> blockers;
  final List<String> warnings;

  Map<String, Object?> toJson() => {
    'playedMoveUci': playedMoveUci,
    'candidateMoveUci': candidateMoveUci,
    'moverColor': moverColor.wire,
    'requestedDepth': requestedDepth,
    'gateSource': gateSource,
    'gateModelName': gateModelName,
    'gateModelVersion': gateModelVersion,
    'draftEvidenceComputed': draftEvidenceComputed,
    'cpDeltaComputed': cpDeltaComputed,
    'cpLossCandidateComputed': cpLossCandidateComputed,
    'expectedPointsComputed': expectedPointsComputed,
    'expectedPointsModelIsOfficial': expectedPointsModelIsOfficial,
    'draftEvidenceIsPublic': draftEvidenceIsPublic,
    'draftEvidenceIsOfficialMoveQuality': draftEvidenceIsOfficialMoveQuality,
    'draftEvidenceIsClassifierOutput': draftEvidenceIsClassifierOutput,
    'beforeMoverPerspectiveCp': beforeMoverPerspectiveCp,
    'playedAfterMoverPerspectiveCp': playedAfterMoverPerspectiveCp,
    'candidateAfterMoverPerspectiveCp': candidateAfterMoverPerspectiveCp,
    'moverPerspectiveDeltaCp': moverPerspectiveDeltaCp,
    'moverPerspectiveCpLossCandidate': moverPerspectiveCpLossCandidate,
    'cpLossCandidateDirection': cpLossCandidateDirection,
    'expectedPointsModelName': expectedPointsModelName,
    'expectedPointsModelVersion': expectedPointsModelVersion,
    'beforeExpectedPoints': beforeExpectedPoints,
    'playedAfterExpectedPoints': playedAfterExpectedPoints,
    'candidateAfterExpectedPoints': candidateAfterExpectedPoints,
    'playedExpectedPointsDelta': playedExpectedPointsDelta,
    'candidateVsPlayedExpectedPointsDelta':
        candidateVsPlayedExpectedPointsDelta,
    'draftClassificationGateComputed': draftClassificationGateComputed,
    'evidenceStructurallyEligibleForFutureClassification':
        evidenceStructurallyEligibleForFutureClassification,
    'evidenceHasBeforeAfterCp': evidenceHasBeforeAfterCp,
    'evidenceHasCandidateComparison': evidenceHasCandidateComparison,
    'evidenceHasExpectedPoints': evidenceHasExpectedPoints,
    'evidenceIsDeveloperOnly': evidenceIsDeveloperOnly,
    'gateRecommendation': gateRecommendation.wire,
    'publicLabelComputed': publicLabelComputed,
    'publicLabel': publicLabel,
    'officialMoveQualityComputed': officialMoveQualityComputed,
    'officialMoveQuality': officialMoveQuality,
    'officialCpLossComputed': officialCpLossComputed,
    'officialWinPercentComputed': officialWinPercentComputed,
    'accuracyComputed': accuracyComputed,
    'acplComputed': acplComputed,
    'classificationComputed': classificationComputed,
    'classifierOutputComputed': classifierOutputComputed,
    'draftClassificationGateProbeSucceeded':
        draftClassificationGateProbeSucceeded,
    'failureMessage': failureMessage,
    'safeForPhase35N': safeForPhase35N,
    'nextRecommendation': nextRecommendation,
    'blockers': blockers,
    'warnings': warnings,
  };

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Apex Draft Classification Gate Probe')
      ..writeln()
      ..writeln(
        'phase: Phase 35M - Single-Move Draft Classification Gate Without Public Labels',
      )
      ..writeln('playedMoveUci: $playedMoveUci')
      ..writeln('candidateMoveUci: $candidateMoveUci')
      ..writeln('moverColor: ${moverColor.wire}')
      ..writeln('requestedDepth: $requestedDepth')
      ..writeln('gateSource: $gateSource')
      ..writeln('gateModelName: $gateModelName')
      ..writeln('gateModelVersion: $gateModelVersion')
      ..writeln('draftEvidenceComputed: $draftEvidenceComputed')
      ..writeln('cpDeltaComputed: $cpDeltaComputed')
      ..writeln('cpLossCandidateComputed: $cpLossCandidateComputed')
      ..writeln('expectedPointsComputed: $expectedPointsComputed')
      ..writeln('expectedPointsModelIsOfficial: $expectedPointsModelIsOfficial')
      ..writeln('draftEvidenceIsPublic: $draftEvidenceIsPublic')
      ..writeln(
        'draftEvidenceIsOfficialMoveQuality: '
        '$draftEvidenceIsOfficialMoveQuality',
      )
      ..writeln(
        'draftEvidenceIsClassifierOutput: $draftEvidenceIsClassifierOutput',
      )
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
      ..writeln('evidenceHasBeforeAfterCp: $evidenceHasBeforeAfterCp')
      ..writeln(
        'evidenceHasCandidateComparison: $evidenceHasCandidateComparison',
      )
      ..writeln('evidenceHasExpectedPoints: $evidenceHasExpectedPoints')
      ..writeln('evidenceIsDeveloperOnly: $evidenceIsDeveloperOnly')
      ..writeln('gateRecommendation: ${gateRecommendation.wire}')
      ..writeln('publicLabelComputed: $publicLabelComputed')
      ..writeln('publicLabel: ${publicLabel ?? 'none'}')
      ..writeln('officialMoveQualityComputed: $officialMoveQualityComputed')
      ..writeln('officialMoveQuality: ${officialMoveQuality ?? 'none'}')
      ..writeln('officialCpLossComputed: $officialCpLossComputed')
      ..writeln('officialWinPercentComputed: $officialWinPercentComputed')
      ..writeln('accuracyComputed: $accuracyComputed')
      ..writeln('acplComputed: $acplComputed')
      ..writeln('classificationComputed: $classificationComputed')
      ..writeln('classifierOutputComputed: $classifierOutputComputed')
      ..writeln(
        'draftClassificationGateProbeSucceeded: '
        '$draftClassificationGateProbeSucceeded',
      )
      ..writeln('failureMessage: ${failureMessage ?? 'none'}')
      ..writeln('safeForPhase35N: $safeForPhase35N')
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
      ..writeln('- Developer-only classification readiness gate')
      ..writeln('- Internal eligibility is not public move quality')
      ..writeln('- No public label, official metrics, or classifier output')
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

AnalyzerDraftClassificationGateResult evaluateAnalyzerDraftClassificationGate({
  required AnalyzerDraftClassificationGateRequest request,
  required AnalyzerMoveQualityDraftEvidenceResult draftEvidence,
}) {
  const publicLabel = null;
  const officialMoveQuality = null;
  const classifierOutputComputed = false;

  final evidenceHasBeforeAfterCp =
      draftEvidence.cpDeltaComputed &&
      draftEvidence.beforeMoverPerspectiveCp != null &&
      draftEvidence.playedAfterMoverPerspectiveCp != null &&
      draftEvidence.moverPerspectiveDeltaCp != null;
  final evidenceHasCandidateComparison =
      draftEvidence.cpLossCandidateComputed &&
      draftEvidence.playedAfterMoverPerspectiveCp != null &&
      draftEvidence.candidateAfterMoverPerspectiveCp != null &&
      draftEvidence.moverPerspectiveCpLossCandidate != null &&
      draftEvidence.cpLossCandidateDirection != null &&
      draftEvidence.cpLossCandidateDirection != 'unavailable';
  final evidenceHasExpectedPoints =
      draftEvidence.expectedPointsComputed &&
      draftEvidence.playedExpectedPointsDelta != null &&
      draftEvidence.candidateVsPlayedExpectedPointsDelta != null;
  final evidenceIsDeveloperOnly =
      !draftEvidence.draftEvidenceIsPublic &&
      !draftEvidence.draftEvidenceIsOfficialMoveQuality &&
      !draftEvidence.draftEvidenceIsClassifierOutput;
  final officialMetricsAlreadyComputed =
      draftEvidence.expectedPointsModelIsOfficial ||
      draftEvidence.officialCpLossComputed ||
      draftEvidence.officialWinPercentComputed ||
      draftEvidence.accuracyComputed ||
      draftEvidence.acplComputed ||
      draftEvidence.classificationComputed;
  final requiredEvidencePresent =
      draftEvidence.moveQualityDraftEvidenceProbeSucceeded &&
      draftEvidence.draftEvidenceComputed &&
      evidenceHasBeforeAfterCp &&
      evidenceHasCandidateComparison &&
      evidenceHasExpectedPoints;

  final gateRecommendation = _gateRecommendation(
    draftEvidence: draftEvidence,
    officialMetricsAlreadyComputed: officialMetricsAlreadyComputed,
    requiredEvidencePresent: requiredEvidencePresent,
  );
  final eligible =
      gateRecommendation ==
      AnalyzerDraftClassificationGateRecommendation
          .eligibleForFutureDraftClassifier;
  final succeeded =
      eligible &&
      evidenceIsDeveloperOnly &&
      !draftEvidence.publicLabelComputed &&
      !draftEvidence.officialMoveQualityComputed &&
      !draftEvidence.officialCpLossComputed &&
      !draftEvidence.officialWinPercentComputed &&
      !draftEvidence.accuracyComputed &&
      !draftEvidence.acplComputed &&
      !draftEvidence.classificationComputed &&
      !classifierOutputComputed;

  final blockers = <String>[];
  if (!succeeded) {
    blockers.add('Draft classification gate proof is blocked.');
  }
  if (!requiredEvidencePresent) {
    blockers.add('Required draft evidence is incomplete.');
  }
  if (draftEvidence.draftEvidenceIsPublic ||
      draftEvidence.publicLabelComputed) {
    blockers.add('Draft evidence is public or public-label-like.');
  }
  if (draftEvidence.draftEvidenceIsOfficialMoveQuality ||
      draftEvidence.officialMoveQualityComputed) {
    blockers.add('Draft evidence is already official move quality.');
  }
  if (draftEvidence.draftEvidenceIsClassifierOutput) {
    blockers.add('Draft evidence is already classifier output.');
  }
  if (officialMetricsAlreadyComputed) {
    blockers.add('Official metrics or classification were already computed.');
  }
  blockers.addAll(draftEvidence.blockers.map((b) => 'draftEvidence: $b'));

  final warnings = <String>[];
  if (!succeeded) {
    warnings.add('This is not a successful draft classification gate proof.');
    warnings.add('Do not proceed to Phase 35N yet.');
  }
  warnings.addAll(draftEvidence.warnings.map((w) => 'draftEvidence: $w'));

  return AnalyzerDraftClassificationGateResult(
    playedMoveUci: request.playedMoveUci,
    candidateMoveUci: request.candidateMoveUci,
    moverColor: request.moverColor,
    requestedDepth: request.requestedDepth,
    gateSource: request.source,
    gateModelName: analyzerDraftClassificationGateModelName,
    gateModelVersion: analyzerDraftClassificationGateModelVersion,
    draftEvidenceComputed: draftEvidence.draftEvidenceComputed,
    cpDeltaComputed: draftEvidence.cpDeltaComputed,
    cpLossCandidateComputed: draftEvidence.cpLossCandidateComputed,
    expectedPointsComputed: draftEvidence.expectedPointsComputed,
    expectedPointsModelIsOfficial: draftEvidence.expectedPointsModelIsOfficial,
    draftEvidenceIsPublic: draftEvidence.draftEvidenceIsPublic,
    draftEvidenceIsOfficialMoveQuality:
        draftEvidence.draftEvidenceIsOfficialMoveQuality,
    draftEvidenceIsClassifierOutput:
        draftEvidence.draftEvidenceIsClassifierOutput,
    beforeMoverPerspectiveCp: draftEvidence.beforeMoverPerspectiveCp,
    playedAfterMoverPerspectiveCp: draftEvidence.playedAfterMoverPerspectiveCp,
    candidateAfterMoverPerspectiveCp:
        draftEvidence.candidateAfterMoverPerspectiveCp,
    moverPerspectiveDeltaCp: draftEvidence.moverPerspectiveDeltaCp,
    moverPerspectiveCpLossCandidate:
        draftEvidence.moverPerspectiveCpLossCandidate,
    cpLossCandidateDirection: draftEvidence.cpLossCandidateDirection,
    expectedPointsModelName: draftEvidence.expectedPointsModelName,
    expectedPointsModelVersion: draftEvidence.expectedPointsModelVersion,
    beforeExpectedPoints: draftEvidence.beforeExpectedPoints,
    playedAfterExpectedPoints: draftEvidence.playedAfterExpectedPoints,
    candidateAfterExpectedPoints: draftEvidence.candidateAfterExpectedPoints,
    playedExpectedPointsDelta: draftEvidence.playedExpectedPointsDelta,
    candidateVsPlayedExpectedPointsDelta:
        draftEvidence.candidateVsPlayedExpectedPointsDelta,
    draftClassificationGateComputed: true,
    evidenceStructurallyEligibleForFutureClassification: eligible,
    evidenceHasBeforeAfterCp: evidenceHasBeforeAfterCp,
    evidenceHasCandidateComparison: evidenceHasCandidateComparison,
    evidenceHasExpectedPoints: evidenceHasExpectedPoints,
    evidenceIsDeveloperOnly: evidenceIsDeveloperOnly,
    gateRecommendation: gateRecommendation,
    publicLabelComputed: draftEvidence.publicLabelComputed,
    publicLabel: publicLabel,
    officialMoveQualityComputed: draftEvidence.officialMoveQualityComputed,
    officialMoveQuality: officialMoveQuality,
    officialCpLossComputed: draftEvidence.officialCpLossComputed,
    officialWinPercentComputed: draftEvidence.officialWinPercentComputed,
    accuracyComputed: draftEvidence.accuracyComputed,
    acplComputed: draftEvidence.acplComputed,
    classificationComputed: draftEvidence.classificationComputed,
    classifierOutputComputed: classifierOutputComputed,
    draftClassificationGateProbeSucceeded: succeeded,
    failureMessage: succeeded
        ? null
        : _failureMessage(
            gateRecommendation: gateRecommendation,
            draftEvidence: draftEvidence,
          ),
    safeForPhase35N: succeeded,
    nextRecommendation: succeeded
        ? analyzerDraftClassificationGateNextRecommendation
        : analyzerDraftClassificationGateFailureRecommendation,
    blockers: List.unmodifiable(blockers.toSet().toList()..sort()),
    warnings: List.unmodifiable(warnings.toSet().toList()..sort()),
  );
}

AnalyzerDraftClassificationGateRecommendation _gateRecommendation({
  required AnalyzerMoveQualityDraftEvidenceResult draftEvidence,
  required bool officialMetricsAlreadyComputed,
  required bool requiredEvidencePresent,
}) {
  if (draftEvidence.draftEvidenceIsPublic ||
      draftEvidence.publicLabelComputed) {
    return AnalyzerDraftClassificationGateRecommendation
        .blockedBecauseEvidenceIsPublic;
  }
  if (draftEvidence.draftEvidenceIsOfficialMoveQuality ||
      draftEvidence.officialMoveQualityComputed) {
    return AnalyzerDraftClassificationGateRecommendation
        .blockedBecauseEvidenceIsOfficialMoveQuality;
  }
  if (draftEvidence.draftEvidenceIsClassifierOutput) {
    return AnalyzerDraftClassificationGateRecommendation
        .blockedBecauseEvidenceIsClassifierOutput;
  }
  if (officialMetricsAlreadyComputed) {
    return AnalyzerDraftClassificationGateRecommendation
        .blockedBecauseOfficialMetricsAlreadyComputed;
  }
  if (!requiredEvidencePresent) {
    return AnalyzerDraftClassificationGateRecommendation
        .notEligibleMissingEvidence;
  }
  return AnalyzerDraftClassificationGateRecommendation
      .eligibleForFutureDraftClassifier;
}

String _failureMessage({
  required AnalyzerDraftClassificationGateRecommendation gateRecommendation,
  required AnalyzerMoveQualityDraftEvidenceResult draftEvidence,
}) {
  if (draftEvidence.failureMessage != null) {
    return draftEvidence.failureMessage!;
  }
  return switch (gateRecommendation) {
    AnalyzerDraftClassificationGateRecommendation
        .eligibleForFutureDraftClassifier =>
      'Draft classification gate did not succeed.',
    AnalyzerDraftClassificationGateRecommendation.notEligibleMissingEvidence =>
      'Required draft evidence is incomplete.',
    AnalyzerDraftClassificationGateRecommendation
        .blockedBecauseEvidenceIsPublic =>
      'Draft evidence is public or public-label-like.',
    AnalyzerDraftClassificationGateRecommendation
        .blockedBecauseEvidenceIsOfficialMoveQuality =>
      'Draft evidence is already official move quality.',
    AnalyzerDraftClassificationGateRecommendation
        .blockedBecauseEvidenceIsClassifierOutput =>
      'Draft evidence is already classifier output.',
    AnalyzerDraftClassificationGateRecommendation
        .blockedBecauseOfficialMetricsAlreadyComputed =>
      'Official metrics or classification were already computed.',
  };
}

import 'dart:convert';

import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_expected_points.dart';

const analyzerMoveQualityDraftEvidencePlayedMoveUci =
    analyzerExpectedPointsPlayedMoveUci;
const analyzerMoveQualityDraftEvidenceCandidateMoveUci =
    analyzerExpectedPointsCandidateMoveUci;
const analyzerMoveQualityDraftEvidenceDepth = analyzerExpectedPointsDepth;
const analyzerMoveQualityDraftEvidenceSource =
    'phase35LControlledExpectedPointsEvidence';
const analyzerMoveQualityDraftEvidenceModelName =
    'internalMoveQualityDraftEvidenceDeveloperOnly';
const analyzerMoveQualityDraftEvidenceModelVersion = 'phase35L.v1';
const analyzerMoveQualityDraftEvidenceNextRecommendation =
    'implementSingleMoveDraftClassificationGateWithoutPublicLabels';
const analyzerMoveQualityDraftEvidenceFailureRecommendation =
    'fixAnalyzerMoveQualityDraftEvidenceProbe';

class AnalyzerMoveQualityDraftEvidenceRequest {
  const AnalyzerMoveQualityDraftEvidenceRequest({
    required this.playedMoveUci,
    required this.candidateMoveUci,
    required this.moverColor,
    required this.requestedDepth,
    required this.source,
  });

  const AnalyzerMoveQualityDraftEvidenceRequest.controlled({
    AnalyzerMoverColor moverColor = AnalyzerMoverColor.white,
  }) : this(
         playedMoveUci: analyzerMoveQualityDraftEvidencePlayedMoveUci,
         candidateMoveUci: analyzerMoveQualityDraftEvidenceCandidateMoveUci,
         moverColor: moverColor,
         requestedDepth: analyzerMoveQualityDraftEvidenceDepth,
         source: analyzerMoveQualityDraftEvidenceSource,
       );

  final String playedMoveUci;
  final String candidateMoveUci;
  final AnalyzerMoverColor moverColor;
  final int requestedDepth;
  final String source;
}

class AnalyzerMoveQualityDraftEvidenceResult {
  const AnalyzerMoveQualityDraftEvidenceResult({
    required this.playedMoveUci,
    required this.candidateMoveUci,
    required this.moverColor,
    required this.requestedDepth,
    required this.evidenceSource,
    required this.evidenceModelName,
    required this.evidenceModelVersion,
    required this.beforeMoverPerspectiveCp,
    required this.playedAfterMoverPerspectiveCp,
    required this.candidateAfterMoverPerspectiveCp,
    required this.moverPerspectiveDeltaCp,
    required this.moverPerspectiveCpLossCandidate,
    required this.cpDeltaComputed,
    required this.cpLossCandidateComputed,
    required this.cpLossCandidateDirection,
    required this.expectedPointsModelName,
    required this.expectedPointsModelVersion,
    required this.expectedPointsModelIsOfficial,
    required this.beforeExpectedPoints,
    required this.playedAfterExpectedPoints,
    required this.candidateAfterExpectedPoints,
    required this.playedExpectedPointsDelta,
    required this.candidateVsPlayedExpectedPointsDelta,
    required this.expectedPointsComputed,
    required this.draftEvidenceComputed,
    required this.draftEvidenceIsPublic,
    required this.draftEvidenceIsOfficialMoveQuality,
    required this.draftEvidenceIsClassifierOutput,
    required this.publicLabelComputed,
    required this.officialMoveQualityComputed,
    required this.officialCpLossComputed,
    required this.officialWinPercentComputed,
    required this.accuracyComputed,
    required this.acplComputed,
    required this.classificationComputed,
    required this.moveQualityDraftEvidenceProbeSucceeded,
    required this.failureMessage,
    required this.safeForPhase35M,
    required this.nextRecommendation,
    required this.blockers,
    required this.warnings,
  });

  final String playedMoveUci;
  final String candidateMoveUci;
  final AnalyzerMoverColor moverColor;
  final int requestedDepth;
  final String evidenceSource;
  final String evidenceModelName;
  final String evidenceModelVersion;
  final int? beforeMoverPerspectiveCp;
  final int? playedAfterMoverPerspectiveCp;
  final int? candidateAfterMoverPerspectiveCp;
  final int? moverPerspectiveDeltaCp;
  final int? moverPerspectiveCpLossCandidate;
  final bool cpDeltaComputed;
  final bool cpLossCandidateComputed;
  final String? cpLossCandidateDirection;
  final String expectedPointsModelName;
  final String expectedPointsModelVersion;
  final bool expectedPointsModelIsOfficial;
  final double? beforeExpectedPoints;
  final double? playedAfterExpectedPoints;
  final double? candidateAfterExpectedPoints;
  final double? playedExpectedPointsDelta;
  final double? candidateVsPlayedExpectedPointsDelta;
  final bool expectedPointsComputed;
  final bool draftEvidenceComputed;
  final bool draftEvidenceIsPublic;
  final bool draftEvidenceIsOfficialMoveQuality;
  final bool draftEvidenceIsClassifierOutput;
  final bool publicLabelComputed;
  final bool officialMoveQualityComputed;
  final bool officialCpLossComputed;
  final bool officialWinPercentComputed;
  final bool accuracyComputed;
  final bool acplComputed;
  final bool classificationComputed;
  final bool moveQualityDraftEvidenceProbeSucceeded;
  final String? failureMessage;
  final bool safeForPhase35M;
  final String nextRecommendation;
  final List<String> blockers;
  final List<String> warnings;

  Map<String, Object?> toJson() => {
    'playedMoveUci': playedMoveUci,
    'candidateMoveUci': candidateMoveUci,
    'moverColor': moverColor.wire,
    'requestedDepth': requestedDepth,
    'evidenceSource': evidenceSource,
    'evidenceModelName': evidenceModelName,
    'evidenceModelVersion': evidenceModelVersion,
    'beforeMoverPerspectiveCp': beforeMoverPerspectiveCp,
    'playedAfterMoverPerspectiveCp': playedAfterMoverPerspectiveCp,
    'candidateAfterMoverPerspectiveCp': candidateAfterMoverPerspectiveCp,
    'moverPerspectiveDeltaCp': moverPerspectiveDeltaCp,
    'moverPerspectiveCpLossCandidate': moverPerspectiveCpLossCandidate,
    'cpDeltaComputed': cpDeltaComputed,
    'cpLossCandidateComputed': cpLossCandidateComputed,
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
    'expectedPointsComputed': expectedPointsComputed,
    'draftEvidenceComputed': draftEvidenceComputed,
    'draftEvidenceIsPublic': draftEvidenceIsPublic,
    'draftEvidenceIsOfficialMoveQuality': draftEvidenceIsOfficialMoveQuality,
    'draftEvidenceIsClassifierOutput': draftEvidenceIsClassifierOutput,
    'publicLabelComputed': publicLabelComputed,
    'officialMoveQualityComputed': officialMoveQualityComputed,
    'officialCpLossComputed': officialCpLossComputed,
    'officialWinPercentComputed': officialWinPercentComputed,
    'accuracyComputed': accuracyComputed,
    'acplComputed': acplComputed,
    'classificationComputed': classificationComputed,
    'moveQualityDraftEvidenceProbeSucceeded':
        moveQualityDraftEvidenceProbeSucceeded,
    'failureMessage': failureMessage,
    'safeForPhase35M': safeForPhase35M,
    'nextRecommendation': nextRecommendation,
    'blockers': blockers,
    'warnings': warnings,
  };

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Apex Move Quality Draft Evidence Probe')
      ..writeln()
      ..writeln(
        'phase: Phase 35L - Move Quality Draft Evidence Probe Without Classifier',
      )
      ..writeln('playedMoveUci: $playedMoveUci')
      ..writeln('candidateMoveUci: $candidateMoveUci')
      ..writeln('moverColor: ${moverColor.wire}')
      ..writeln('requestedDepth: $requestedDepth')
      ..writeln('evidenceSource: $evidenceSource')
      ..writeln('evidenceModelName: $evidenceModelName')
      ..writeln('evidenceModelVersion: $evidenceModelVersion')
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
      ..writeln('draftEvidenceComputed: $draftEvidenceComputed')
      ..writeln('draftEvidenceIsPublic: $draftEvidenceIsPublic')
      ..writeln(
        'draftEvidenceIsOfficialMoveQuality: '
        '$draftEvidenceIsOfficialMoveQuality',
      )
      ..writeln(
        'draftEvidenceIsClassifierOutput: $draftEvidenceIsClassifierOutput',
      )
      ..writeln('publicLabelComputed: $publicLabelComputed')
      ..writeln('officialMoveQualityComputed: $officialMoveQualityComputed')
      ..writeln('officialCpLossComputed: $officialCpLossComputed')
      ..writeln('officialWinPercentComputed: $officialWinPercentComputed')
      ..writeln('accuracyComputed: $accuracyComputed')
      ..writeln('acplComputed: $acplComputed')
      ..writeln('classificationComputed: $classificationComputed')
      ..writeln(
        'moveQualityDraftEvidenceProbeSucceeded: '
        '$moveQualityDraftEvidenceProbeSucceeded',
      )
      ..writeln('failureMessage: ${failureMessage ?? 'none'}')
      ..writeln('safeForPhase35M: $safeForPhase35M')
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
      ..writeln('- Internal draft evidence only')
      ..writeln('- No public move labels')
      ..writeln('- No official move quality, Win%, CP-loss, accuracy, or ACPL')
      ..writeln('- No classifier output')
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

import 'dart:convert';
import 'dart:math' as math;

import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_cp_loss_candidate.dart';

const analyzerExpectedPointsBeforeFen = analyzerCpLossCandidateBeforeFen;
const analyzerExpectedPointsPlayedAfterFen =
    analyzerCpLossCandidatePlayedAfterFen;
const analyzerExpectedPointsCandidateAfterFen =
    analyzerCpLossCandidateCandidateAfterFen;
const analyzerExpectedPointsPlayedMoveUci =
    analyzerCpLossCandidatePlayedMoveUci;
const analyzerExpectedPointsCandidateMoveUci =
    analyzerCpLossCandidateCandidateMoveUci;
const analyzerExpectedPointsDepth = analyzerCpLossCandidateDepth;
const analyzerExpectedPointsDefaultSource =
    'phase35KControlledExpectedPointsDelta';
const analyzerExpectedPointsNextRecommendation =
    'implementMoveQualityDraftProbeWithoutClassifier';
const analyzerExpectedPointsFailureRecommendation =
    'fixAnalyzerExpectedPointsDeltaProbe';
const analyzerExpectedPointsModelName =
    'provisionalSigmoidExpectedPointsDeveloperOnly';
const analyzerExpectedPointsModelVersion = 'phase35K.v1';
const analyzerExpectedPointsModelIsOfficial = false;

class ProvisionalExpectedPointsConverter {
  const ProvisionalExpectedPointsConverter({this.cpScale = 400.0});

  final double cpScale;

  double? convertCp(int? moverPerspectiveCp) {
    if (moverPerspectiveCp == null || cpScale <= 0) return null;
    final raw = 1.0 / (1.0 + math.exp(-moverPerspectiveCp / cpScale));
    if (raw.isNaN) return null;
    return raw.clamp(0.0, 1.0);
  }
}

class AnalyzerExpectedPointsDeltaRequest {
  const AnalyzerExpectedPointsDeltaRequest({
    required this.beforeFen,
    required this.playedAfterFen,
    required this.candidateAfterFen,
    required this.playedMoveUci,
    required this.candidateMoveUci,
    required this.moverColor,
    required this.requestedDepth,
    required this.source,
  });

  const AnalyzerExpectedPointsDeltaRequest.controlled({
    AnalyzerMoverColor moverColor = AnalyzerMoverColor.white,
  }) : this(
         beforeFen: analyzerExpectedPointsBeforeFen,
         playedAfterFen: analyzerExpectedPointsPlayedAfterFen,
         candidateAfterFen: analyzerExpectedPointsCandidateAfterFen,
         playedMoveUci: analyzerExpectedPointsPlayedMoveUci,
         candidateMoveUci: analyzerExpectedPointsCandidateMoveUci,
         moverColor: moverColor,
         requestedDepth: analyzerExpectedPointsDepth,
         source: analyzerExpectedPointsDefaultSource,
       );

  final String beforeFen;
  final String playedAfterFen;
  final String candidateAfterFen;
  final String playedMoveUci;
  final String candidateMoveUci;
  final AnalyzerMoverColor moverColor;
  final int requestedDepth;
  final String source;
}

class AnalyzerExpectedPointsDeltaResult {
  const AnalyzerExpectedPointsDeltaResult({
    required this.beforeFen,
    required this.playedAfterFen,
    required this.candidateAfterFen,
    required this.playedMoveUci,
    required this.candidateMoveUci,
    required this.moverColor,
    required this.requestedDepth,
    required this.cpLossCandidateProbeSucceeded,
    required this.beforeMoverPerspectiveCp,
    required this.playedAfterMoverPerspectiveCp,
    required this.candidateAfterMoverPerspectiveCp,
    required this.moverPerspectiveDeltaCp,
    required this.moverPerspectiveCpLossCandidate,
    required this.beforeExpectedPoints,
    required this.playedAfterExpectedPoints,
    required this.candidateAfterExpectedPoints,
    required this.playedExpectedPointsDelta,
    required this.candidateVsPlayedExpectedPointsDelta,
    required this.expectedPointsComputed,
    required this.expectedPointsModelName,
    required this.expectedPointsModelVersion,
    required this.expectedPointsModelIsOfficial,
    required this.officialWinPercentComputed,
    required this.officialCpLossComputed,
    required this.classificationComputed,
    required this.moveQualityComputed,
    required this.accuracyComputed,
    required this.acplComputed,
    required this.expectedPointsDeltaProbeSucceeded,
    required this.failureMessage,
    required this.safeForPhase35L,
    required this.nextRecommendation,
    required this.blockers,
    required this.warnings,
  });

  final String beforeFen;
  final String playedAfterFen;
  final String candidateAfterFen;
  final String playedMoveUci;
  final String candidateMoveUci;
  final AnalyzerMoverColor moverColor;
  final int requestedDepth;
  final bool cpLossCandidateProbeSucceeded;
  final int? beforeMoverPerspectiveCp;
  final int? playedAfterMoverPerspectiveCp;
  final int? candidateAfterMoverPerspectiveCp;
  final int? moverPerspectiveDeltaCp;
  final int? moverPerspectiveCpLossCandidate;
  final double? beforeExpectedPoints;
  final double? playedAfterExpectedPoints;
  final double? candidateAfterExpectedPoints;
  final double? playedExpectedPointsDelta;
  final double? candidateVsPlayedExpectedPointsDelta;
  final bool expectedPointsComputed;
  final String expectedPointsModelName;
  final String expectedPointsModelVersion;
  final bool expectedPointsModelIsOfficial;
  final bool officialWinPercentComputed;
  final bool officialCpLossComputed;
  final bool classificationComputed;
  final bool moveQualityComputed;
  final bool accuracyComputed;
  final bool acplComputed;
  final bool expectedPointsDeltaProbeSucceeded;
  final String? failureMessage;
  final bool safeForPhase35L;
  final String nextRecommendation;
  final List<String> blockers;
  final List<String> warnings;

  Map<String, Object?> toJson() => {
    'beforeFen': beforeFen,
    'playedAfterFen': playedAfterFen,
    'candidateAfterFen': candidateAfterFen,
    'playedMoveUci': playedMoveUci,
    'candidateMoveUci': candidateMoveUci,
    'moverColor': moverColor.wire,
    'requestedDepth': requestedDepth,
    'cpLossCandidateProbeSucceeded': cpLossCandidateProbeSucceeded,
    'beforeMoverPerspectiveCp': beforeMoverPerspectiveCp,
    'playedAfterMoverPerspectiveCp': playedAfterMoverPerspectiveCp,
    'candidateAfterMoverPerspectiveCp': candidateAfterMoverPerspectiveCp,
    'moverPerspectiveDeltaCp': moverPerspectiveDeltaCp,
    'moverPerspectiveCpLossCandidate': moverPerspectiveCpLossCandidate,
    'beforeExpectedPoints': beforeExpectedPoints,
    'playedAfterExpectedPoints': playedAfterExpectedPoints,
    'candidateAfterExpectedPoints': candidateAfterExpectedPoints,
    'playedExpectedPointsDelta': playedExpectedPointsDelta,
    'candidateVsPlayedExpectedPointsDelta':
        candidateVsPlayedExpectedPointsDelta,
    'expectedPointsComputed': expectedPointsComputed,
    'expectedPointsModelName': expectedPointsModelName,
    'expectedPointsModelVersion': expectedPointsModelVersion,
    'expectedPointsModelIsOfficial': expectedPointsModelIsOfficial,
    'officialWinPercentComputed': officialWinPercentComputed,
    'officialCpLossComputed': officialCpLossComputed,
    'classificationComputed': classificationComputed,
    'moveQualityComputed': moveQualityComputed,
    'accuracyComputed': accuracyComputed,
    'acplComputed': acplComputed,
    'expectedPointsDeltaProbeSucceeded': expectedPointsDeltaProbeSucceeded,
    'failureMessage': failureMessage,
    'safeForPhase35L': safeForPhase35L,
    'nextRecommendation': nextRecommendation,
    'blockers': blockers,
    'warnings': warnings,
  };

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Apex Analyzer Expected Points Delta Probe')
      ..writeln()
      ..writeln(
        'phase: Phase 35K - Expected Points Delta Probe Without Classifier',
      )
      ..writeln('moverColor: ${moverColor.wire}')
      ..writeln('requestedDepth: $requestedDepth')
      ..writeln('playedMoveUci: $playedMoveUci')
      ..writeln('candidateMoveUci: $candidateMoveUci')
      ..writeln('cpLossCandidateProbeSucceeded: $cpLossCandidateProbeSucceeded')
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
      ..writeln('expectedPointsComputed: $expectedPointsComputed')
      ..writeln('expectedPointsModelName: $expectedPointsModelName')
      ..writeln('expectedPointsModelVersion: $expectedPointsModelVersion')
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
      ..writeln('officialWinPercentComputed: $officialWinPercentComputed')
      ..writeln('officialCpLossComputed: $officialCpLossComputed')
      ..writeln('classificationComputed: $classificationComputed')
      ..writeln('moveQualityComputed: $moveQualityComputed')
      ..writeln('accuracyComputed: $accuracyComputed')
      ..writeln('acplComputed: $acplComputed')
      ..writeln(
        'expectedPointsDeltaProbeSucceeded: '
        '$expectedPointsDeltaProbeSucceeded',
      )
      ..writeln('failureMessage: ${failureMessage ?? 'none'}')
      ..writeln('safeForPhase35L: $safeForPhase35L')
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
      ..writeln('- Provisional developer-only expected-points model')
      ..writeln('- This is not official Win% or accuracy math')
      ..writeln(
        '- Official CP-loss, labels, move quality, accuracy, and ACPL are not computed',
      )
      ..writeln('- Mate is not converted to centipawns')
      ..writeln(
        '- No PGN, legal move generation, MultiPV, scheduler, persistence, UI, or backend',
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

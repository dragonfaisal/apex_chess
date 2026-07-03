import 'dart:convert';

import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';

const analyzerCpLossCandidateBeforeFen =
    'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
const analyzerCpLossCandidatePlayedAfterFen =
    'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1';
const analyzerCpLossCandidateCandidateAfterFen =
    'rnbqkbnr/pppppppp/8/8/8/4P3/PPPP1PPP/RNBQKBNR b KQkq - 0 1';
const analyzerCpLossCandidatePlayedMoveUci = 'e2e4';
const analyzerCpLossCandidateCandidateMoveUci = 'e2e3';
const analyzerCpLossCandidateDepth = 1;
const analyzerCpLossCandidateDefaultSource =
    'phase35JControlledCpLossCandidate';
const analyzerCpLossCandidateNextRecommendation =
    'implementExpectedPointsDeltaProbeWithoutClassifier';
const analyzerCpLossCandidateFailureRecommendation =
    'fixAnalyzerCpLossCandidateProbe';
const analyzerCpLossCandidateControlledFens = <String>{
  analyzerCpLossCandidateBeforeFen,
  analyzerCpLossCandidatePlayedAfterFen,
  analyzerCpLossCandidateCandidateAfterFen,
};

enum AnalyzerCpLossCandidateDirection {
  candidateBetter('candidateBetter'),
  playedBetter('playedBetter'),
  equal('equal'),
  unavailable('unavailable');

  const AnalyzerCpLossCandidateDirection(this.wire);

  final String wire;
}

class AnalyzerCpLossCandidateRequest {
  const AnalyzerCpLossCandidateRequest({
    required this.beforeFen,
    required this.playedAfterFen,
    required this.candidateAfterFen,
    required this.playedMoveUci,
    required this.candidateMoveUci,
    required this.moverColor,
    required this.requestedDepth,
    required this.source,
  });

  const AnalyzerCpLossCandidateRequest.controlled({
    AnalyzerMoverColor moverColor = AnalyzerMoverColor.white,
  }) : this(
         beforeFen: analyzerCpLossCandidateBeforeFen,
         playedAfterFen: analyzerCpLossCandidatePlayedAfterFen,
         candidateAfterFen: analyzerCpLossCandidateCandidateAfterFen,
         playedMoveUci: analyzerCpLossCandidatePlayedMoveUci,
         candidateMoveUci: analyzerCpLossCandidateCandidateMoveUci,
         moverColor: moverColor,
         requestedDepth: analyzerCpLossCandidateDepth,
         source: analyzerCpLossCandidateDefaultSource,
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

class AnalyzerCpLossCandidateResult {
  const AnalyzerCpLossCandidateResult({
    required this.beforeFen,
    required this.playedAfterFen,
    required this.candidateAfterFen,
    required this.playedMoveUci,
    required this.candidateMoveUci,
    required this.moverColor,
    required this.requestedDepth,
    required this.beforeEvalSucceeded,
    required this.beforeMoverPerspectiveCp,
    required this.beforeMoverPerspectiveMate,
    required this.beforeBestMove,
    required this.beforeBestMoveReceived,
    required this.playedAfterEvalSucceeded,
    required this.playedAfterMoverPerspectiveCp,
    required this.playedAfterMoverPerspectiveMate,
    required this.playedAfterBestMove,
    required this.playedAfterBestMoveReceived,
    required this.candidateAfterEvalSucceeded,
    required this.candidateAfterMoverPerspectiveCp,
    required this.candidateAfterMoverPerspectiveMate,
    required this.candidateAfterBestMove,
    required this.candidateAfterBestMoveReceived,
    required this.cpDeltaComputed,
    required this.moverPerspectiveDeltaCp,
    required this.cpLossCandidateComputed,
    required this.moverPerspectiveCpLossCandidate,
    required this.cpLossCandidateDirection,
    required this.officialCpLossComputed,
    required this.winPercentComputed,
    required this.classificationComputed,
    required this.moveQualityComputed,
    required this.accuracyComputed,
    required this.cpLossCandidateProbeSucceeded,
    required this.failureMessage,
    required this.safeForPhase35K,
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
  final bool beforeEvalSucceeded;
  final int? beforeMoverPerspectiveCp;
  final int? beforeMoverPerspectiveMate;
  final String? beforeBestMove;
  final bool beforeBestMoveReceived;
  final bool playedAfterEvalSucceeded;
  final int? playedAfterMoverPerspectiveCp;
  final int? playedAfterMoverPerspectiveMate;
  final String? playedAfterBestMove;
  final bool playedAfterBestMoveReceived;
  final bool candidateAfterEvalSucceeded;
  final int? candidateAfterMoverPerspectiveCp;
  final int? candidateAfterMoverPerspectiveMate;
  final String? candidateAfterBestMove;
  final bool candidateAfterBestMoveReceived;
  final bool cpDeltaComputed;
  final int? moverPerspectiveDeltaCp;
  final bool cpLossCandidateComputed;
  final int? moverPerspectiveCpLossCandidate;
  final AnalyzerCpLossCandidateDirection cpLossCandidateDirection;
  final bool officialCpLossComputed;
  final bool winPercentComputed;
  final bool classificationComputed;
  final bool moveQualityComputed;
  final bool accuracyComputed;
  final bool cpLossCandidateProbeSucceeded;
  final String? failureMessage;
  final bool safeForPhase35K;
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
    'beforeEvalSucceeded': beforeEvalSucceeded,
    'beforeMoverPerspectiveCp': beforeMoverPerspectiveCp,
    'beforeMoverPerspectiveMate': beforeMoverPerspectiveMate,
    'beforeBestMove': beforeBestMove,
    'beforeBestMoveReceived': beforeBestMoveReceived,
    'playedAfterEvalSucceeded': playedAfterEvalSucceeded,
    'playedAfterMoverPerspectiveCp': playedAfterMoverPerspectiveCp,
    'playedAfterMoverPerspectiveMate': playedAfterMoverPerspectiveMate,
    'playedAfterBestMove': playedAfterBestMove,
    'playedAfterBestMoveReceived': playedAfterBestMoveReceived,
    'candidateAfterEvalSucceeded': candidateAfterEvalSucceeded,
    'candidateAfterMoverPerspectiveCp': candidateAfterMoverPerspectiveCp,
    'candidateAfterMoverPerspectiveMate': candidateAfterMoverPerspectiveMate,
    'candidateAfterBestMove': candidateAfterBestMove,
    'candidateAfterBestMoveReceived': candidateAfterBestMoveReceived,
    'cpDeltaComputed': cpDeltaComputed,
    'moverPerspectiveDeltaCp': moverPerspectiveDeltaCp,
    'cpLossCandidateComputed': cpLossCandidateComputed,
    'moverPerspectiveCpLossCandidate': moverPerspectiveCpLossCandidate,
    'cpLossCandidateDirection': cpLossCandidateDirection.wire,
    'officialCpLossComputed': officialCpLossComputed,
    'winPercentComputed': winPercentComputed,
    'classificationComputed': classificationComputed,
    'moveQualityComputed': moveQualityComputed,
    'accuracyComputed': accuracyComputed,
    'cpLossCandidateProbeSucceeded': cpLossCandidateProbeSucceeded,
    'failureMessage': failureMessage,
    'safeForPhase35K': safeForPhase35K,
    'nextRecommendation': nextRecommendation,
    'blockers': blockers,
    'warnings': warnings,
  };

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Apex Analyzer CP Loss Candidate Probe')
      ..writeln()
      ..writeln('phase: Phase 35J - CP Loss Candidate Probe Without Classifier')
      ..writeln('moverColor: ${moverColor.wire}')
      ..writeln('requestedDepth: $requestedDepth')
      ..writeln('beforeFen: $beforeFen')
      ..writeln('playedMoveUci: $playedMoveUci')
      ..writeln('playedAfterFen: $playedAfterFen')
      ..writeln('candidateMoveUci: $candidateMoveUci')
      ..writeln('candidateAfterFen: $candidateAfterFen')
      ..writeln('beforeEvalSucceeded: $beforeEvalSucceeded')
      ..writeln('playedAfterEvalSucceeded: $playedAfterEvalSucceeded')
      ..writeln('candidateAfterEvalSucceeded: $candidateAfterEvalSucceeded')
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
      ..writeln('cpDeltaComputed: $cpDeltaComputed')
      ..writeln(
        'moverPerspectiveCpLossCandidate: '
        '${moverPerspectiveCpLossCandidate ?? 'none'}',
      )
      ..writeln('cpLossCandidateComputed: $cpLossCandidateComputed')
      ..writeln('cpLossCandidateDirection: ${cpLossCandidateDirection.wire}')
      ..writeln('officialCpLossComputed: $officialCpLossComputed')
      ..writeln('winPercentComputed: $winPercentComputed')
      ..writeln('classificationComputed: $classificationComputed')
      ..writeln('moveQualityComputed: $moveQualityComputed')
      ..writeln('accuracyComputed: $accuracyComputed')
      ..writeln('cpLossCandidateProbeSucceeded: $cpLossCandidateProbeSucceeded')
      ..writeln('failureMessage: ${failureMessage ?? 'none'}')
      ..writeln('safeForPhase35K: $safeForPhase35K')
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
      ..writeln('- Controlled triple-FEN comparison only')
      ..writeln('- CP delta and CP loss candidate remain separate')
      ..writeln('- Negative candidate values are preserved, not clamped')
      ..writeln('- Mate is not converted to centipawns')
      ..writeln(
        '- Official CP-loss, Win%, accuracy, move quality, and labels are not computed',
      )
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

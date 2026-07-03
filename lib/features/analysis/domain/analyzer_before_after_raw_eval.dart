import 'dart:convert';

import 'package:apex_chess/features/analysis/domain/analyzer_raw_eval_result.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_single_fen_raw_eval.dart';

const analyzerBeforeAfterRawEvalControlledBeforeFen =
    'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
const analyzerBeforeAfterRawEvalControlledAfterFen =
    'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1';
const analyzerBeforeAfterRawEvalPlayedMoveUci = 'e2e4';
const analyzerBeforeAfterRawEvalDepth = 1;
const analyzerBeforeAfterRawEvalDefaultSource =
    'phase35HControlledBeforeAfterRawEval';
const analyzerBeforeAfterRawEvalNextRecommendation =
    'implementCpDeltaProbeWithoutClassifier';
const analyzerBeforeAfterRawEvalFailureRecommendation =
    'fixAnalyzerBeforeAfterRawEvalProbe';
const analyzerBeforeAfterRawEvalControlledFens = <String>{
  analyzerBeforeAfterRawEvalControlledBeforeFen,
  analyzerBeforeAfterRawEvalControlledAfterFen,
};

enum AnalyzerMoverColor {
  white('white'),
  black('black');

  const AnalyzerMoverColor(this.wire);

  final String wire;

  AnalyzerRequestedPlayerColor get requestedPlayerColor => switch (this) {
    AnalyzerMoverColor.white => AnalyzerRequestedPlayerColor.white,
    AnalyzerMoverColor.black => AnalyzerRequestedPlayerColor.black,
  };
}

class AnalyzerBeforeAfterRawEvalRequest {
  const AnalyzerBeforeAfterRawEvalRequest({
    required this.beforeFen,
    required this.afterFen,
    required this.playedMoveUci,
    required this.moverColor,
    required this.requestedDepth,
    required this.source,
  });

  const AnalyzerBeforeAfterRawEvalRequest.controlled({
    AnalyzerMoverColor moverColor = AnalyzerMoverColor.white,
  }) : this(
         beforeFen: analyzerBeforeAfterRawEvalControlledBeforeFen,
         afterFen: analyzerBeforeAfterRawEvalControlledAfterFen,
         playedMoveUci: analyzerBeforeAfterRawEvalPlayedMoveUci,
         moverColor: moverColor,
         requestedDepth: analyzerBeforeAfterRawEvalDepth,
         source: analyzerBeforeAfterRawEvalDefaultSource,
       );

  final String beforeFen;
  final String afterFen;
  final String playedMoveUci;
  final AnalyzerMoverColor moverColor;
  final int requestedDepth;
  final String source;
}

class AnalyzerBeforeAfterRawEvalResult {
  const AnalyzerBeforeAfterRawEvalResult({
    required this.beforeFen,
    required this.afterFen,
    required this.playedMoveUci,
    required this.moverColor,
    required this.requestedDepth,
    required this.beforeEvalSucceeded,
    required this.afterEvalSucceeded,
    required this.beforeSideToMove,
    required this.afterSideToMove,
    required this.beforeRawScoreType,
    required this.afterRawScoreType,
    required this.beforeRawScoreCp,
    required this.afterRawScoreCp,
    required this.beforeRawScoreMate,
    required this.afterRawScoreMate,
    required this.beforeWhitePerspectiveCp,
    required this.afterWhitePerspectiveCp,
    required this.beforeBlackPerspectiveCp,
    required this.afterBlackPerspectiveCp,
    required this.beforeWhitePerspectiveMate,
    required this.afterWhitePerspectiveMate,
    required this.beforeBlackPerspectiveMate,
    required this.afterBlackPerspectiveMate,
    required this.moverPerspectiveBeforeCp,
    required this.moverPerspectiveAfterCp,
    required this.moverPerspectiveBeforeMate,
    required this.moverPerspectiveAfterMate,
    required this.beforeBestMove,
    required this.afterBestMove,
    required this.beforeBestMoveReceived,
    required this.afterBestMoveReceived,
    required this.beforeInfoDepthSeen,
    required this.afterInfoDepthSeen,
    required this.beforeAfterRawEvalSucceeded,
    required this.deltaComputed,
    required this.cpLossComputed,
    required this.winPercentComputed,
    required this.classificationComputed,
    required this.failureMessage,
    required this.safeForPhase35I,
    required this.nextRecommendation,
    required this.blockers,
    required this.warnings,
  });

  final String beforeFen;
  final String afterFen;
  final String playedMoveUci;
  final AnalyzerMoverColor moverColor;
  final int requestedDepth;
  final bool beforeEvalSucceeded;
  final bool afterEvalSucceeded;
  final AnalyzerFenSideToMove? beforeSideToMove;
  final AnalyzerFenSideToMove? afterSideToMove;
  final String? beforeRawScoreType;
  final String? afterRawScoreType;
  final int? beforeRawScoreCp;
  final int? afterRawScoreCp;
  final int? beforeRawScoreMate;
  final int? afterRawScoreMate;
  final int? beforeWhitePerspectiveCp;
  final int? afterWhitePerspectiveCp;
  final int? beforeBlackPerspectiveCp;
  final int? afterBlackPerspectiveCp;
  final int? beforeWhitePerspectiveMate;
  final int? afterWhitePerspectiveMate;
  final int? beforeBlackPerspectiveMate;
  final int? afterBlackPerspectiveMate;
  final int? moverPerspectiveBeforeCp;
  final int? moverPerspectiveAfterCp;
  final int? moverPerspectiveBeforeMate;
  final int? moverPerspectiveAfterMate;
  final String? beforeBestMove;
  final String? afterBestMove;
  final bool beforeBestMoveReceived;
  final bool afterBestMoveReceived;
  final int? beforeInfoDepthSeen;
  final int? afterInfoDepthSeen;
  final bool beforeAfterRawEvalSucceeded;
  final bool deltaComputed;
  final bool cpLossComputed;
  final bool winPercentComputed;
  final bool classificationComputed;
  final String? failureMessage;
  final bool safeForPhase35I;
  final String nextRecommendation;
  final List<String> blockers;
  final List<String> warnings;

  Map<String, Object?> toJson() => {
    'beforeFen': beforeFen,
    'afterFen': afterFen,
    'playedMoveUci': playedMoveUci,
    'moverColor': moverColor.wire,
    'requestedDepth': requestedDepth,
    'beforeEvalSucceeded': beforeEvalSucceeded,
    'afterEvalSucceeded': afterEvalSucceeded,
    'beforeSideToMove': beforeSideToMove?.wire,
    'afterSideToMove': afterSideToMove?.wire,
    'beforeRawScoreType': beforeRawScoreType,
    'afterRawScoreType': afterRawScoreType,
    'beforeRawScoreCp': beforeRawScoreCp,
    'afterRawScoreCp': afterRawScoreCp,
    'beforeRawScoreMate': beforeRawScoreMate,
    'afterRawScoreMate': afterRawScoreMate,
    'beforeWhitePerspectiveCp': beforeWhitePerspectiveCp,
    'afterWhitePerspectiveCp': afterWhitePerspectiveCp,
    'beforeBlackPerspectiveCp': beforeBlackPerspectiveCp,
    'afterBlackPerspectiveCp': afterBlackPerspectiveCp,
    'beforeWhitePerspectiveMate': beforeWhitePerspectiveMate,
    'afterWhitePerspectiveMate': afterWhitePerspectiveMate,
    'beforeBlackPerspectiveMate': beforeBlackPerspectiveMate,
    'afterBlackPerspectiveMate': afterBlackPerspectiveMate,
    'moverPerspectiveBeforeCp': moverPerspectiveBeforeCp,
    'moverPerspectiveAfterCp': moverPerspectiveAfterCp,
    'moverPerspectiveBeforeMate': moverPerspectiveBeforeMate,
    'moverPerspectiveAfterMate': moverPerspectiveAfterMate,
    'beforeBestMove': beforeBestMove,
    'afterBestMove': afterBestMove,
    'beforeBestMoveReceived': beforeBestMoveReceived,
    'afterBestMoveReceived': afterBestMoveReceived,
    'beforeInfoDepthSeen': beforeInfoDepthSeen,
    'afterInfoDepthSeen': afterInfoDepthSeen,
    'beforeAfterRawEvalSucceeded': beforeAfterRawEvalSucceeded,
    'deltaComputed': deltaComputed,
    'cpLossComputed': cpLossComputed,
    'winPercentComputed': winPercentComputed,
    'classificationComputed': classificationComputed,
    'failureMessage': failureMessage,
    'safeForPhase35I': safeForPhase35I,
    'nextRecommendation': nextRecommendation,
    'blockers': blockers,
    'warnings': warnings,
  };

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Apex Analyzer Before/After Raw Eval Probe')
      ..writeln()
      ..writeln('phase: Phase 35H - Single-FEN Before/After Raw Eval Probe')
      ..writeln('playedMoveUci: $playedMoveUci')
      ..writeln('moverColor: ${moverColor.wire}')
      ..writeln('requestedDepth: $requestedDepth')
      ..writeln('beforeFen: $beforeFen')
      ..writeln('afterFen: $afterFen')
      ..writeln('beforeEvalSucceeded: $beforeEvalSucceeded')
      ..writeln('afterEvalSucceeded: $afterEvalSucceeded')
      ..writeln('beforeAfterRawEvalSucceeded: $beforeAfterRawEvalSucceeded')
      ..writeln('beforeSideToMove: ${beforeSideToMove?.wire ?? 'none'}')
      ..writeln('afterSideToMove: ${afterSideToMove?.wire ?? 'none'}')
      ..writeln('beforeRawScoreType: ${beforeRawScoreType ?? 'none'}')
      ..writeln('afterRawScoreType: ${afterRawScoreType ?? 'none'}')
      ..writeln('beforeRawScoreCp: ${beforeRawScoreCp ?? 'none'}')
      ..writeln('afterRawScoreCp: ${afterRawScoreCp ?? 'none'}')
      ..writeln('beforeRawScoreMate: ${beforeRawScoreMate ?? 'none'}')
      ..writeln('afterRawScoreMate: ${afterRawScoreMate ?? 'none'}')
      ..writeln(
        'beforeWhitePerspectiveCp: ${beforeWhitePerspectiveCp ?? 'none'}',
      )
      ..writeln('afterWhitePerspectiveCp: ${afterWhitePerspectiveCp ?? 'none'}')
      ..writeln(
        'beforeBlackPerspectiveCp: ${beforeBlackPerspectiveCp ?? 'none'}',
      )
      ..writeln('afterBlackPerspectiveCp: ${afterBlackPerspectiveCp ?? 'none'}')
      ..writeln(
        'moverPerspectiveBeforeCp: ${moverPerspectiveBeforeCp ?? 'none'}',
      )
      ..writeln('moverPerspectiveAfterCp: ${moverPerspectiveAfterCp ?? 'none'}')
      ..writeln(
        'moverPerspectiveBeforeMate: ${moverPerspectiveBeforeMate ?? 'none'}',
      )
      ..writeln(
        'moverPerspectiveAfterMate: ${moverPerspectiveAfterMate ?? 'none'}',
      )
      ..writeln('beforeBestMoveReceived: $beforeBestMoveReceived')
      ..writeln('afterBestMoveReceived: $afterBestMoveReceived')
      ..writeln('beforeBestMove: ${beforeBestMove ?? 'none'}')
      ..writeln('afterBestMove: ${afterBestMove ?? 'none'}')
      ..writeln('beforeInfoDepthSeen: ${beforeInfoDepthSeen ?? 'none'}')
      ..writeln('afterInfoDepthSeen: ${afterInfoDepthSeen ?? 'none'}')
      ..writeln('deltaComputed: $deltaComputed')
      ..writeln('cpLossComputed: $cpLossComputed')
      ..writeln('winPercentComputed: $winPercentComputed')
      ..writeln('classificationComputed: $classificationComputed')
      ..writeln('failureMessage: ${failureMessage ?? 'none'}')
      ..writeln('safeForPhase35I: $safeForPhase35I')
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
      ..writeln('- Controlled before/after FEN pair only')
      ..writeln('- Played move is traceability only')
      ..writeln('- No delta, CP-loss, Win%, accuracy, ACPL, or labels')
      ..writeln('- No PGN, move-list, legal move generation, or user games')
      ..writeln('- No scheduler, persistence, saved analysis, UI, or backend');
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

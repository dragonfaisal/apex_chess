import 'dart:convert';

import 'package:apex_chess/features/analysis/domain/analyzer_single_fen_raw_eval.dart'
    show AnalyzerRequestedPlayerColor;

const analyzerRawEvalNextRecommendation =
    'implementSingleFenBeforeAfterRawEvalProbe';
const analyzerRawEvalFailureRecommendation =
    'fixAnalyzerSingleFenRawEvalContract';

enum AnalyzerFenSideToMove {
  white('white'),
  black('black');

  const AnalyzerFenSideToMove(this.wire);

  final String wire;
}

class AnalyzerRawEvalResult {
  const AnalyzerRawEvalResult({
    required this.fen,
    required this.requestedDepth,
    required this.requestedPlayerColor,
    required this.engineSource,
    required this.bridgeSource,
    required this.rawScoreType,
    required this.rawScoreCp,
    required this.rawScoreMate,
    required this.rawScorePerspective,
    required this.sideToMove,
    required this.whitePerspectiveCp,
    required this.blackPerspectiveCp,
    required this.whitePerspectiveMate,
    required this.blackPerspectiveMate,
    required this.playerPerspectiveCp,
    required this.playerPerspectiveMate,
    required this.bestMove,
    required this.bestMoveReceived,
    required this.infoDepthSeen,
    required this.engineSucceeded,
    required this.perspectiveNormalizationSucceeded,
    required this.analyzerRawEvalSucceeded,
    required this.failureMessage,
    required this.safeForPhase35H,
    required this.nextRecommendation,
    required this.blockers,
    required this.warnings,
  });

  final String fen;
  final int requestedDepth;
  final AnalyzerRequestedPlayerColor requestedPlayerColor;
  final String engineSource;
  final String bridgeSource;
  final String? rawScoreType;
  final int? rawScoreCp;
  final int? rawScoreMate;
  final String rawScorePerspective;
  final AnalyzerFenSideToMove? sideToMove;
  final int? whitePerspectiveCp;
  final int? blackPerspectiveCp;
  final int? whitePerspectiveMate;
  final int? blackPerspectiveMate;
  final int? playerPerspectiveCp;
  final int? playerPerspectiveMate;
  final String? bestMove;
  final bool bestMoveReceived;
  final int? infoDepthSeen;
  final bool engineSucceeded;
  final bool perspectiveNormalizationSucceeded;
  final bool analyzerRawEvalSucceeded;
  final String? failureMessage;
  final bool safeForPhase35H;
  final String nextRecommendation;
  final List<String> blockers;
  final List<String> warnings;

  Map<String, Object?> toJson() => {
    'fen': fen,
    'requestedDepth': requestedDepth,
    'requestedPlayerColor': requestedPlayerColor.wire,
    'engineSource': engineSource,
    'bridgeSource': bridgeSource,
    'rawScoreType': rawScoreType,
    'rawScoreCp': rawScoreCp,
    'rawScoreMate': rawScoreMate,
    'rawScorePerspective': rawScorePerspective,
    'sideToMove': sideToMove?.wire,
    'whitePerspectiveCp': whitePerspectiveCp,
    'blackPerspectiveCp': blackPerspectiveCp,
    'whitePerspectiveMate': whitePerspectiveMate,
    'blackPerspectiveMate': blackPerspectiveMate,
    'playerPerspectiveCp': playerPerspectiveCp,
    'playerPerspectiveMate': playerPerspectiveMate,
    'bestMove': bestMove,
    'bestMoveReceived': bestMoveReceived,
    'infoDepthSeen': infoDepthSeen,
    'engineSucceeded': engineSucceeded,
    'perspectiveNormalizationSucceeded': perspectiveNormalizationSucceeded,
    'analyzerRawEvalSucceeded': analyzerRawEvalSucceeded,
    'failureMessage': failureMessage,
    'safeForPhase35H': safeForPhase35H,
    'nextRecommendation': nextRecommendation,
    'blockers': blockers,
    'warnings': warnings,
  };

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Apex Analyzer Single-FEN Raw Eval Adapter')
      ..writeln()
      ..writeln(
        'phase: Phase 35G - Analyzer Adapter Single-FEN Raw Eval Contract',
      )
      ..writeln('fen: $fen')
      ..writeln('requestedDepth: $requestedDepth')
      ..writeln('requestedPlayerColor: ${requestedPlayerColor.wire}')
      ..writeln('engineSource: $engineSource')
      ..writeln('bridgeSource: $bridgeSource')
      ..writeln('engineSucceeded: $engineSucceeded')
      ..writeln(
        'perspectiveNormalizationSucceeded: '
        '$perspectiveNormalizationSucceeded',
      )
      ..writeln('analyzerRawEvalSucceeded: $analyzerRawEvalSucceeded')
      ..writeln('sideToMove: ${sideToMove?.wire ?? 'none'}')
      ..writeln('rawScoreType: ${rawScoreType ?? 'none'}')
      ..writeln('rawScoreCp: ${rawScoreCp ?? 'none'}')
      ..writeln('rawScoreMate: ${rawScoreMate ?? 'none'}')
      ..writeln('rawScorePerspective: $rawScorePerspective')
      ..writeln('whitePerspectiveCp: ${whitePerspectiveCp ?? 'none'}')
      ..writeln('blackPerspectiveCp: ${blackPerspectiveCp ?? 'none'}')
      ..writeln('whitePerspectiveMate: ${whitePerspectiveMate ?? 'none'}')
      ..writeln('blackPerspectiveMate: ${blackPerspectiveMate ?? 'none'}')
      ..writeln('playerPerspectiveCp: ${playerPerspectiveCp ?? 'none'}')
      ..writeln('playerPerspectiveMate: ${playerPerspectiveMate ?? 'none'}')
      ..writeln('bestMoveReceived: $bestMoveReceived')
      ..writeln('bestMove: ${bestMove ?? 'none'}')
      ..writeln('infoDepthSeen: ${infoDepthSeen ?? 'none'}')
      ..writeln('failureMessage: ${failureMessage ?? 'none'}')
      ..writeln('safeForPhase35H: $safeForPhase35H')
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
      ..writeln('- Analyzer-facing single-FEN raw eval only')
      ..writeln('- No PGN, move-list, or user-game analysis')
      ..writeln('- No move comparison or before/after delta')
      ..writeln('- No Win%, CP-loss, accuracy, ACPL, or classifier labels')
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

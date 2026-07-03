const analyzerSingleFenRawEvalControlledFen =
    'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
const analyzerSingleFenRawEvalDepth = 1;
const analyzerSingleFenRawEvalDefaultSource =
    'phase35GControlledSingleFenRawEval';

enum AnalyzerRequestedPlayerColor {
  white('white'),
  black('black');

  const AnalyzerRequestedPlayerColor(this.wire);

  final String wire;
}

class AnalyzerSingleFenRawEvalRequest {
  const AnalyzerSingleFenRawEvalRequest({
    required this.fen,
    required this.requestedDepth,
    required this.requestedPlayerColor,
    required this.source,
  });

  const AnalyzerSingleFenRawEvalRequest.controlled({
    AnalyzerRequestedPlayerColor requestedPlayerColor =
        AnalyzerRequestedPlayerColor.white,
  }) : this(
         fen: analyzerSingleFenRawEvalControlledFen,
         requestedDepth: analyzerSingleFenRawEvalDepth,
         requestedPlayerColor: requestedPlayerColor,
         source: analyzerSingleFenRawEvalDefaultSource,
       );

  final String fen;
  final int requestedDepth;
  final AnalyzerRequestedPlayerColor requestedPlayerColor;
  final String source;
}

/// Value types for UCI events emitted by the engine.
///
/// Every line read from the engine is parsed into one of these events and
/// broadcast on [ChessEngine.events]. Unknown / unparsed lines fall through
/// as [EngineRawLine] so no information is ever lost.
library;

/// Base type for every UCI event.
sealed class EngineEvent {
  const EngineEvent();
}

/// `id name ...` / `id author ...`.
class EngineId extends EngineEvent {
  const EngineId({this.name, this.author});
  final String? name;
  final String? author;
  @override
  String toString() => 'EngineId(name: $name, author: $author)';
}

/// `option name <name> type <type> ...` — engine-declared option.
class EngineOption extends EngineEvent {
  const EngineOption({
    required this.name,
    required this.type,
    this.defaultValue,
    this.min,
    this.max,
    this.vars = const [],
  });

  final String name;
  final String type;
  final String? defaultValue;
  final int? min;
  final int? max;
  final List<String> vars;

  @override
  String toString() => 'EngineOption(name: $name, type: $type)';
}

/// `uciok` — handshake complete.
class EngineUciOk extends EngineEvent {
  const EngineUciOk();
  @override
  String toString() => 'EngineUciOk()';
}

/// `readyok` — engine has drained its command queue.
class EngineReadyOk extends EngineEvent {
  const EngineReadyOk();
  @override
  String toString() => 'EngineReadyOk()';
}

/// `info ...` — periodic search progress.
///
/// The raw [fields] map is kept for diagnostics / tests; the most common
/// fields are also exposed as typed getters.
class EngineInfo extends EngineEvent {
  const EngineInfo({
    this.depth,
    this.seldepth,
    this.multipv,
    this.scoreCp,
    this.scoreMate,
    this.scoreBound,
    this.nodes,
    this.nps,
    this.time,
    this.hashfull,
    this.tbhits,
    this.pv = const [],
    this.currmove,
    this.currmovenumber,
    this.string,
    this.fields = const {},
  });

  final int? depth;
  final int? seldepth;
  final int? multipv;

  /// Centipawn score from the side-to-move perspective. Null if the engine
  /// sent `score mate` instead.
  final int? scoreCp;

  /// Moves-to-mate, from the side-to-move perspective. Positive: we mate in
  /// N; negative: we get mated in N.
  final int? scoreMate;

  /// `lowerbound` / `upperbound` / null.
  final String? scoreBound;

  final int? nodes;
  final int? nps;
  final Duration? time;
  final int? hashfull;
  final int? tbhits;

  /// Principal variation in UCI coordinate notation (`e2e4`, `g1f3`, …).
  final List<String> pv;

  final String? currmove;
  final int? currmovenumber;
  final String? string;

  /// Raw whitespace-split field map for rarely-used keys.
  final Map<String, String> fields;

  @override
  String toString() =>
      'EngineInfo(depth: $depth, cp: $scoreCp, mate: $scoreMate, pv: $pv)';
}

/// `bestmove <move> [ponder <move>]` — terminates a search.
class EngineBestMove extends EngineEvent {
  const EngineBestMove({required this.move, this.ponder});
  final String move;
  final String? ponder;
  @override
  String toString() => 'EngineBestMove(move: $move, ponder: $ponder)';
}

/// Any line the parser did not recognize. Always surfaced so consumers can
/// log / inspect it.
class EngineRawLine extends EngineEvent {
  const EngineRawLine(this.line);
  final String line;
  @override
  String toString() => 'EngineRawLine($line)';
}

/// A fatal error reported by the isolate. The engine is unusable after this
/// is emitted; the stream will close shortly after.
class EngineError extends EngineEvent {
  const EngineError(this.message, {this.cause});
  final String message;
  final Object? cause;
  @override
  String toString() => 'EngineError($message)';
}

/// Value types for UCI commands the Flutter layer sends to the engine.
///
/// Every command knows how to render itself to the text UCI dialect via
/// [toUci]. Callers compose analyses by pushing a sequence of commands into
/// [ChessEngine.send]; the engine serializes them onto its worker isolate
/// in-order so no UI frame ever blocks on engine I/O.
library;

/// Base type for every UCI command.
sealed class UciCommand {
  const UciCommand();

  /// Render this command to a UCI wire string (no trailing newline).
  String toUci();
}

/// `uci` — request engine identity + options.
class UciHandshake extends UciCommand {
  const UciHandshake();
  @override
  String toUci() => 'uci';
}

/// `isready` — synchronization primitive; engine replies `readyok`.
class UciIsReady extends UciCommand {
  const UciIsReady();
  @override
  String toUci() => 'isready';
}

/// `ucinewgame` — reset engine state between games.
class UciNewGame extends UciCommand {
  const UciNewGame();
  @override
  String toUci() => 'ucinewgame';
}

/// `setoption name <name> value <value>`.
class UciSetOption extends UciCommand {
  const UciSetOption({required this.name, this.value});

  final String name;
  final String? value;

  @override
  String toUci() {
    final buf = StringBuffer('setoption name ')..write(name);
    if (value != null) buf.write(' value $value');
    return buf.toString();
  }
}

/// `position startpos [moves ...]` or `position fen <fen> [moves ...]`.
class UciPosition extends UciCommand {
  const UciPosition.startpos({this.moves = const []}) : fen = null;
  const UciPosition.fen(this.fen, {this.moves = const []});

  final String? fen;
  final List<String> moves;

  @override
  String toUci() {
    final buf = StringBuffer('position ');
    if (fen == null) {
      buf.write('startpos');
    } else {
      buf
        ..write('fen ')
        ..write(fen);
    }
    if (moves.isNotEmpty) {
      buf
        ..write(' moves ')
        ..write(moves.join(' '));
    }
    return buf.toString();
  }
}

/// `go` — search command. Use the named constructors for common shapes.
class UciGo extends UciCommand {
  const UciGo({
    this.depth,
    this.movetime,
    this.nodes,
    this.wtime,
    this.btime,
    this.winc,
    this.binc,
    this.infinite = false,
    this.searchMoves = const [],
  });

  const UciGo.depth(int depth) : this(depth: depth);
  const UciGo.movetime(Duration duration)
      : this(movetime: duration);
  const UciGo.nodes(int nodes) : this(nodes: nodes);
  const UciGo.infinite() : this(infinite: true);

  final int? depth;
  final Duration? movetime;
  final int? nodes;
  final Duration? wtime;
  final Duration? btime;
  final Duration? winc;
  final Duration? binc;
  final bool infinite;
  final List<String> searchMoves;

  @override
  String toUci() {
    final buf = StringBuffer('go');
    if (depth != null) buf.write(' depth $depth');
    if (movetime != null) buf.write(' movetime ${movetime!.inMilliseconds}');
    if (nodes != null) buf.write(' nodes $nodes');
    if (wtime != null) buf.write(' wtime ${wtime!.inMilliseconds}');
    if (btime != null) buf.write(' btime ${btime!.inMilliseconds}');
    if (winc != null) buf.write(' winc ${winc!.inMilliseconds}');
    if (binc != null) buf.write(' binc ${binc!.inMilliseconds}');
    if (infinite) buf.write(' infinite');
    if (searchMoves.isNotEmpty) {
      buf
        ..write(' searchmoves ')
        ..write(searchMoves.join(' '));
    }
    return buf.toString();
  }
}

/// `stop` — halt the current search; engine will still emit `bestmove`.
class UciStop extends UciCommand {
  const UciStop();
  @override
  String toUci() => 'stop';
}

/// `quit` — shut the engine down. Prefer [ChessEngine.dispose] instead.
class UciQuit extends UciCommand {
  const UciQuit();
  @override
  String toUci() => 'quit';
}

/// Escape hatch for commands the typed API does not yet cover.
class UciRaw extends UciCommand {
  const UciRaw(this.line);
  final String line;
  @override
  String toUci() => line;
}

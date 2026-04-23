/// Barrel file for the in-process chess engine layer.
///
/// Feature modules should import this file instead of reaching into the
/// `uci/` or `stockfish/` sub-folders so the concrete backend stays swappable.
library;

export 'chess_engine.dart';
export 'stockfish/stockfish_engine.dart';
export 'uci/uci_command.dart';
export 'uci/uci_event.dart';

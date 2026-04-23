/// Parser from UCI wire lines to [EngineEvent] value objects.
///
/// Implemented as a single pure function so it can be unit-tested without any
/// FFI / isolate scaffolding.
library;

import 'uci_event.dart';

/// Parse a single UCI output line into an [EngineEvent].
///
/// Never throws — malformed input falls through as [EngineRawLine].
EngineEvent parseUciLine(String rawLine) {
  final line = rawLine.trim();
  if (line.isEmpty) return EngineRawLine(rawLine);

  if (line == 'uciok') return const EngineUciOk();
  if (line == 'readyok') return const EngineReadyOk();

  if (line.startsWith('id ')) return _parseId(line);
  if (line.startsWith('option ')) return _parseOption(line);
  if (line.startsWith('bestmove')) return _parseBestMove(line);
  if (line.startsWith('info ')) return _parseInfo(line);

  return EngineRawLine(rawLine);
}

EngineId _parseId(String line) {
  final rest = line.substring(3);
  final space = rest.indexOf(' ');
  if (space < 0) return const EngineId();
  final key = rest.substring(0, space);
  final value = rest.substring(space + 1);
  return switch (key) {
    'name' => EngineId(name: value),
    'author' => EngineId(author: value),
    _ => const EngineId(),
  };
}

EngineOption _parseOption(String line) {
  // option name <name ...> type <type> [default <v>] [min <v>] [max <v>]
  // [var <v>] [var <v>] ...
  final tokens = line.split(RegExp(r'\s+'));
  String? name;
  String? type;
  String? def;
  int? min;
  int? max;
  final vars = <String>[];

  for (var i = 1; i < tokens.length; i++) {
    final tok = tokens[i];
    if (tok == 'name' || tok == 'type' || tok == 'default' ||
        tok == 'min' || tok == 'max' || tok == 'var') {
      final buf = StringBuffer();
      var j = i + 1;
      while (j < tokens.length &&
          tokens[j] != 'name' && tokens[j] != 'type' &&
          tokens[j] != 'default' && tokens[j] != 'min' &&
          tokens[j] != 'max' && tokens[j] != 'var') {
        if (buf.isNotEmpty) buf.write(' ');
        buf.write(tokens[j]);
        j++;
      }
      final value = buf.toString();
      switch (tok) {
        case 'name': name = value;
        case 'type': type = value;
        case 'default': def = value;
        case 'min': min = int.tryParse(value);
        case 'max': max = int.tryParse(value);
        case 'var': vars.add(value);
      }
      i = j - 1;
    }
  }

  return EngineOption(
    name: name ?? '',
    type: type ?? 'string',
    defaultValue: def,
    min: min,
    max: max,
    vars: List.unmodifiable(vars),
  );
}

EngineBestMove _parseBestMove(String line) {
  final tokens = line.split(RegExp(r'\s+'));
  final move = tokens.length > 1 ? tokens[1] : '(none)';
  String? ponder;
  final ponderIdx = tokens.indexOf('ponder');
  if (ponderIdx >= 0 && ponderIdx + 1 < tokens.length) {
    ponder = tokens[ponderIdx + 1];
  }
  return EngineBestMove(move: move, ponder: ponder);
}

EngineInfo _parseInfo(String line) {
  // Tokens that take a variable-length tail until the next known key.
  const listTokens = <String>{'pv', 'currline', 'refutation'};
  const singleTokens = <String>{
    'depth', 'seldepth', 'multipv', 'nodes', 'nps',
    'time', 'hashfull', 'tbhits', 'cpuload', 'currmove',
    'currmovenumber',
  };
  // 'string' consumes the rest of the line.

  final tokens = line.split(RegExp(r'\s+')).skip(1).toList(growable: false);

  int? depth;
  int? seldepth;
  int? multipv;
  int? scoreCp;
  int? scoreMate;
  String? scoreBound;
  int? nodes;
  int? nps;
  Duration? time;
  int? hashfull;
  int? tbhits;
  final pv = <String>[];
  String? currmove;
  int? currmovenumber;
  String? info;
  final fields = <String, String>{};

  var i = 0;
  while (i < tokens.length) {
    final key = tokens[i];

    if (key == 'string') {
      info = tokens.skip(i + 1).join(' ');
      break;
    }

    if (key == 'score') {
      // score cp <n> | score mate <n> [lowerbound|upperbound]
      if (i + 2 < tokens.length) {
        final kind = tokens[i + 1];
        final value = int.tryParse(tokens[i + 2]);
        if (kind == 'cp') {
          scoreCp = value;
        } else if (kind == 'mate') {
          scoreMate = value;
        }
        i += 3;
        if (i < tokens.length &&
            (tokens[i] == 'lowerbound' || tokens[i] == 'upperbound')) {
          scoreBound = tokens[i];
          i++;
        }
        continue;
      }
    }

    if (listTokens.contains(key)) {
      final tail = <String>[];
      var j = i + 1;
      while (j < tokens.length &&
          !singleTokens.contains(tokens[j]) &&
          !listTokens.contains(tokens[j]) &&
          tokens[j] != 'score' &&
          tokens[j] != 'string') {
        tail.add(tokens[j]);
        j++;
      }
      if (key == 'pv') pv.addAll(tail);
      fields[key] = tail.join(' ');
      i = j;
      continue;
    }

    if (singleTokens.contains(key) && i + 1 < tokens.length) {
      final value = tokens[i + 1];
      fields[key] = value;
      switch (key) {
        case 'depth': depth = int.tryParse(value);
        case 'seldepth': seldepth = int.tryParse(value);
        case 'multipv': multipv = int.tryParse(value);
        case 'nodes': nodes = int.tryParse(value);
        case 'nps': nps = int.tryParse(value);
        case 'time':
          final ms = int.tryParse(value);
          time = ms == null ? null : Duration(milliseconds: ms);
        case 'hashfull': hashfull = int.tryParse(value);
        case 'tbhits': tbhits = int.tryParse(value);
        case 'currmove': currmove = value;
        case 'currmovenumber': currmovenumber = int.tryParse(value);
      }
      i += 2;
      continue;
    }

    // Unknown token: skip.
    i++;
  }

  return EngineInfo(
    depth: depth,
    seldepth: seldepth,
    multipv: multipv,
    scoreCp: scoreCp,
    scoreMate: scoreMate,
    scoreBound: scoreBound,
    nodes: nodes,
    nps: nps,
    time: time,
    hashfull: hashfull,
    tbhits: tbhits,
    pv: List.unmodifiable(pv),
    currmove: currmove,
    currmovenumber: currmovenumber,
    string: info,
    fields: Map.unmodifiable(fields),
  );
}

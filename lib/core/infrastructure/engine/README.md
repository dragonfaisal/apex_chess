# `core/infrastructure/engine`

Local, in-process chess engine integration. Stockfish is spoken to over UCI
through a thin C bridge (`src/native/`) loaded via `dart:ffi` and driven from
a dedicated worker `Isolate` so the UI thread is never blocked by search,
NNUE eval, or hash-table bookkeeping.

## Layout

```
engine/
├── chess_engine.dart          # Abstract interface consumed by features
├── engine.dart                # Barrel export
├── uci/
│   ├── uci_command.dart       # Typed UCI commands (go, position, setoption…)
│   ├── uci_event.dart         # Typed UCI events (info, bestmove, id…)
│   └── uci_parser.dart        # Pure-Dart parser, no FFI or Flutter deps
├── stockfish/
│   ├── stockfish_bindings.dart    # dart:ffi function table
│   ├── stockfish_library.dart     # Platform-specific DynamicLibrary loader
│   ├── stockfish_isolate.dart     # Worker isolate entrypoint + protocol
│   └── stockfish_engine.dart      # Public ChessEngine implementation
└── README.md                  # This file
```

## Threading model

```
┌──────────────────────┐           SendPort                 ┌──────────────────────┐
│   UI isolate         │  ───── UciCommand.toUci() ─────►   │   Worker isolate     │
│                      │                                     │                      │
│  StockfishEngine     │  ◄───── String (raw UCI line) ───   │  stockfish_write     │
│   .send / .events    │                                     │  Timer(4ms) poll     │
└──────────────────────┘                                     │  stockfish_read_line │
                                                             └─────────┬────────────┘
                                                                       │ FFI
                                                             ┌─────────▼────────────┐
                                                             │ libstockfish_bridge  │
                                                             │  (native worker      │
                                                             │   thread running     │
                                                             │   UCI loop)          │
                                                             └──────────────────────┘
```

Guarantees:

* The UI isolate performs **zero FFI calls**. Every `Pointer<...>` is created,
  passed, and freed on the worker isolate.
* The worker isolate **never blocks on I/O** — `stockfish_read_line` is called
  with `timeout_ms = 0` from a 4 ms `Timer.periodic`. Blocking on `-1` would
  starve the command loop; polling every 4 ms drains typical search output
  in real time while staying well under 1 % CPU at idle (measured on a 2020
  Pixel 5 in STUB mode).
* Bursty output is buffered inside the native line queue between polls so
  nothing is dropped even at > 10k `info` lines/sec.
* `dispose()` is cooperative: it sends a shutdown message, the worker
  cancels its timer, destroys the native handle (which joins the engine's
  native worker thread), and then signals the UI isolate to tear the port
  down. Falls back to `Isolate.kill` after a 3 s grace window.

## Usage

```dart
import 'package:apex_chess/core/infrastructure/engine/engine.dart';

final engine = StockfishEngine();
await engine.start();

final sub = engine.events.listen((event) {
  switch (event) {
    case EngineInfo(:final depth, :final scoreCp, :final pv):
      debugPrint('depth=$depth cp=$scoreCp pv=${pv.take(5).join(' ')}');
    case EngineBestMove(:final move):
      debugPrint('best=$move');
    default:
      break;
  }
});

engine.send(const UciHandshake());
engine.send(const UciIsReady());
engine.send(const UciNewGame());
engine.send(const UciPosition.startpos(moves: ['e2e4', 'e7e5']));
engine.send(const UciGo.movetime(Duration(milliseconds: 500)));

// ...later
await sub.cancel();
await engine.dispose();
```

### Riverpod wiring

See `lib/app/di/providers.dart` for the `stockfishEngineProvider` that owns
the singleton and disposes it with the `ProviderContainer`.

## Testing without the real engine

The native bridge ships with a built-in UCI stub (see
`src/native/stockfish_bridge.cpp`) so unit tests and hot-reload iteration work
out of the box. Drop real Stockfish sources in and rebuild — the Dart side
doesn't change.

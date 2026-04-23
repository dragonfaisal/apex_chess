/// Typed `dart:ffi` bindings for `libstockfish_bridge`.
///
/// The native ABI lives in `src/native/stockfish_bridge.h`. Keep this file in
/// sync with that header; any change here is a binary-breaking change.
library;

import 'dart:ffi';

import 'package:ffi/ffi.dart';

/// Opaque `sf_engine*`.
final class SfEngine extends Opaque {}

// C signatures
typedef _CreateNative = Pointer<SfEngine> Function();
typedef _DestroyNative = Void Function(Pointer<SfEngine>);
typedef _WriteNative = Int32 Function(Pointer<SfEngine>, Pointer<Utf8>);
typedef _ReadLineNative =
    Pointer<Utf8> Function(Pointer<SfEngine>, Int32);
typedef _FreeStringNative = Void Function(Pointer<Utf8>);
typedef _VersionNative = Pointer<Utf8> Function();

// Dart signatures
typedef CreateDart = Pointer<SfEngine> Function();
typedef DestroyDart = void Function(Pointer<SfEngine>);
typedef WriteDart = int Function(Pointer<SfEngine>, Pointer<Utf8>);
typedef ReadLineDart = Pointer<Utf8> Function(Pointer<SfEngine>, int);
typedef FreeStringDart = void Function(Pointer<Utf8>);
typedef VersionDart = Pointer<Utf8> Function();

/// Typed view of the bridge's exported functions.
class StockfishBindings {
  StockfishBindings(DynamicLibrary lib)
      : create = lib.lookupFunction<_CreateNative, CreateDart>(
          'stockfish_create',
        ),
        destroy = lib.lookupFunction<_DestroyNative, DestroyDart>(
          'stockfish_destroy',
        ),
        write = lib.lookupFunction<_WriteNative, WriteDart>(
          'stockfish_write',
        ),
        readLine = lib.lookupFunction<_ReadLineNative, ReadLineDart>(
          'stockfish_read_line',
        ),
        freeString = lib.lookupFunction<_FreeStringNative, FreeStringDart>(
          'stockfish_free_string',
        ),
        version = lib.lookupFunction<_VersionNative, VersionDart>(
          'stockfish_bridge_version',
        );

  final CreateDart create;
  final DestroyDart destroy;
  final WriteDart write;
  final ReadLineDart readLine;
  final FreeStringDart freeString;
  final VersionDart version;
}

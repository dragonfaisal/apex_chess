/// Platform-specific loader for `libstockfish_bridge`.
library;

import 'dart:ffi';
import 'dart:io' show Platform;

/// The shared library name used by the bridge build on each platform.
///
///   * Android / Linux : `libstockfish_bridge.so`
///   * Windows         : `stockfish_bridge.dll`
///   * macOS / iOS     : statically linked into the host binary, so we use
///                        [DynamicLibrary.process].
DynamicLibrary openStockfishBridge() {
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('libstockfish_bridge.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('stockfish_bridge.dll');
  }
  if (Platform.isMacOS || Platform.isIOS) {
    // The bridge is statically linked into the runner on Apple platforms.
    // See ios/README.md / macos/README.md for the Xcode wiring.
    return DynamicLibrary.process();
  }
  throw UnsupportedError(
    'Stockfish bridge is not available on ${Platform.operatingSystem}',
  );
}

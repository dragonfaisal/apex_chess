/// Chess audio service with debouncing for PGN scrubbing.
///
/// Fire-and-forget. Errors never block the UI thread.
/// Debouncer limits playback to max 1 sound per 300ms.
library;

import 'package:audioplayers/audioplayers.dart';

enum ChessSoundType {
  move('move.mp3'),
  capture('capture.mp3'),
  check('dong.mp3'),
  checkmate('explosion.mp3'),
  select('confirmation.mp3'),
  error('error.mp3'),
  gameEnd('puzzleStormEnd.mp3');

  final String filename;
  const ChessSoundType(this.filename);
}

class ChessAudioService {
  final AudioPlayer _player = AudioPlayer();
  static const Duration _debounceInterval = Duration(milliseconds: 300);
  DateTime _lastPlayTime = DateTime(2000);

  Future<void> play(ChessSoundType sound) async {
    try {
      final now = DateTime.now();
      if (now.difference(_lastPlayTime) < _debounceInterval) return;
      _lastPlayTime = now;
      await _player.stop();
      await _player.play(AssetSource('sounds/${sound.filename}'));
    } catch (_) {}
  }

  Future<void> playImmediate(ChessSoundType sound) async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/${sound.filename}'));
      _lastPlayTime = DateTime.now();
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}

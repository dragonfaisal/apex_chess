/// Review Audio Controller — debounced, non-blocking audio for PGN scrubbing.
///
/// Architecture:
///   1. Receives [NavigationEvent]s from [ReviewController].
///   2. Debounces rapid events (100ms) to coalesce scrubbing.
///   3. On sequential +1/-1: play move sound + classification SFX if major.
///   4. On large jumps: skip intermediate sounds.
///   5. Global cooldown: max 1 heavy SFX (blunder/brilliant) per 350ms.
///   6. Always stop() before play() — zero overlap.
library;

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'review_controller.dart';

class ReviewAudioController {
  final AudioPlayer _movePlayer = AudioPlayer();
  final AudioPlayer _classificationPlayer = AudioPlayer();

  Timer? _debounceTimer;
  DateTime _lastHeavySfxTime = DateTime(2000);
  NavigationEvent? _pendingEvent;

  static const Duration _debounceInterval = Duration(milliseconds: 100);
  static const Duration _heavySfxCooldown = Duration(milliseconds: 350);

  /// Called by [ReviewController] on every ply change.
  void onNavigationEvent(NavigationEvent event) {
    _pendingEvent = event;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceInterval, _executePendingEvent);
  }

  Future<void> _executePendingEvent() async {
    final event = _pendingEvent;
    if (event == null) return;
    _pendingEvent = null;

    try {
      if (event.isSequential && event.moveAnalysis != null) {
        await _playMoveSound(event.moveAnalysis!);
        await _maybePlayClassificationSound(event.moveAnalysis!);
      }
    } catch (_) {
      // Audio errors never crash the app.
    }
  }

  Future<void> _playMoveSound(MoveAnalysis move) async {
    final san = move.san;
    String soundFile;

    // Precedence matters: a castle with check (`O-O+`) should still play
    // the castle SFX, not the generic check gong. Checkmate stays first
    // because terminal sound always wins.
    if (san.endsWith('#')) {
      soundFile = 'explosion.mp3';
    } else if (san.startsWith('O-O') || san.startsWith('0-0')) {
      soundFile = 'castle.mp3';
    } else if (san.endsWith('+')) {
      soundFile = 'dong.mp3';
    } else if (san.contains('x')) {
      soundFile = 'capture.mp3';
    } else {
      soundFile = 'move.mp3';
    }

    await _movePlayer.stop();
    await _movePlayer.play(AssetSource('sounds/$soundFile'));
  }

  Future<void> _maybePlayClassificationSound(MoveAnalysis move) async {
    final q = move.classification;
    if (!_isMajor(q)) return;

    final now = DateTime.now();
    if (now.difference(_lastHeavySfxTime) < _heavySfxCooldown) return;
    _lastHeavySfxTime = now;

    await Future<void>.delayed(const Duration(milliseconds: 120));

    String? sfxFile;
    switch (q) {
      case MoveQuality.blunder:
      case MoveQuality.mistake:
        sfxFile = 'error.mp3';
      case MoveQuality.brilliant:
        sfxFile = 'confirmation.mp3';
      default:
        break;
    }

    if (sfxFile != null) {
      await _classificationPlayer.stop();
      await _classificationPlayer.play(AssetSource('sounds/$sfxFile'));
    }
  }

  bool _isMajor(MoveQuality q) =>
      q == MoveQuality.blunder ||
      q == MoveQuality.mistake ||
      q == MoveQuality.brilliant;

  Future<void> dispose() async {
    _debounceTimer?.cancel();
    await _movePlayer.dispose();
    await _classificationPlayer.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final reviewAudioProvider = Provider<ReviewAudioController>((ref) {
  final controller = ReviewAudioController();

  // Wire up to ReviewController's navigation events.
  final reviewCtrl = ref.watch(reviewControllerProvider.notifier);
  reviewCtrl.onNavigation = controller.onNavigationEvent;

  ref.onDispose(() => controller.dispose());
  return controller;
});

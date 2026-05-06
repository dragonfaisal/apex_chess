/// Shared display model for player identity surfaces.
///
/// This is presentation-layer only. It normalizes names, platform labels,
/// side/result labels, and avatar fallbacks without fetching profile data.
library;

import 'package:flutter/foundation.dart';

enum PlayerIdentityPlatform {
  chessCom('Chess.com'),
  lichess('Lichess'),
  pgn('PGN'),
  unknown('Unknown');

  const PlayerIdentityPlatform(this.label);
  final String label;

  static PlayerIdentityPlatform fromWire(String? raw) {
    final value = raw?.trim().toLowerCase();
    return switch (value) {
      'chess.com' || 'chesscom' || 'chess_com' => chessCom,
      'lichess' || 'lichess.org' => lichess,
      'pgn' || 'local' => pgn,
      _ => unknown,
    };
  }
}

enum PlayerIdentitySide {
  white('White'),
  black('Black'),
  unknown('Side');

  const PlayerIdentitySide(this.label);
  final String label;
}

enum PlayerIdentityResult {
  won('Won'),
  lost('Lost'),
  draw('Draw'),
  unknown('Result');

  const PlayerIdentityResult(this.label);
  final String label;
}

enum PlayerIdentitySourceStatus {
  verified('Connected'),
  publicProfile('Public Account'),
  cached('Saved data'),
  serviceIssue('Service unavailable'),
  unknown('Apex Profile');

  const PlayerIdentitySourceStatus(this.label);
  final String label;
}

@immutable
class PlayerIdentityDisplay {
  const PlayerIdentityDisplay({
    required this.username,
    required this.normalizedUsername,
    required this.platform,
    required this.rating,
    required this.avatarUrl,
    required this.fallbackInitial,
    required this.fallbackColorSeed,
    required this.isConnectedUser,
    required this.isOpponent,
    required this.side,
    required this.result,
    required this.status,
    required this.isCached,
    required this.lastUpdated,
  });

  factory PlayerIdentityDisplay.fromRaw({
    required String? username,
    PlayerIdentityPlatform platform = PlayerIdentityPlatform.unknown,
    String? rating,
    String? avatarUrl,
    bool isConnectedUser = false,
    bool isOpponent = false,
    PlayerIdentitySide side = PlayerIdentitySide.unknown,
    PlayerIdentityResult result = PlayerIdentityResult.unknown,
    PlayerIdentitySourceStatus? status,
    bool isCached = false,
    DateTime? lastUpdated,
  }) {
    final safeName = _safeUsername(username);
    final normalized = normalizeUsername(safeName);
    return PlayerIdentityDisplay(
      username: safeName,
      normalizedUsername: normalized,
      platform: platform,
      rating: _cleanOptional(rating),
      avatarUrl: _cleanUrl(avatarUrl),
      fallbackInitial: fallbackInitialFor(safeName, side: side),
      fallbackColorSeed: normalized.hashCode,
      isConnectedUser: isConnectedUser,
      isOpponent: isOpponent,
      side: side,
      result: result,
      status:
          status ??
          (isConnectedUser
              ? PlayerIdentitySourceStatus.verified
              : PlayerIdentitySourceStatus.publicProfile),
      isCached: isCached,
      lastUpdated: lastUpdated,
    );
  }

  factory PlayerIdentityDisplay.connected({
    required String username,
    required PlayerIdentityPlatform platform,
    String? rating,
    String? avatarUrl,
    bool isCached = false,
    DateTime? lastUpdated,
  }) {
    return PlayerIdentityDisplay.fromRaw(
      username: username,
      platform: platform,
      rating: rating,
      avatarUrl: avatarUrl,
      isConnectedUser: true,
      status: isCached
          ? PlayerIdentitySourceStatus.cached
          : PlayerIdentitySourceStatus.verified,
      isCached: isCached,
      lastUpdated: lastUpdated,
    );
  }

  final String username;
  final String normalizedUsername;
  final PlayerIdentityPlatform platform;
  final String? rating;
  final String? avatarUrl;
  final String fallbackInitial;
  final int fallbackColorSeed;
  final bool isConnectedUser;
  final bool isOpponent;
  final PlayerIdentitySide side;
  final PlayerIdentityResult result;
  final PlayerIdentitySourceStatus status;
  final bool isCached;
  final DateTime? lastUpdated;

  String get displayUsername => username;
  String get platformLabel => platform.label;
  String get sideLabel => side.label;
  String get resultLabel => result.label;
  String get statusLabel =>
      isCached ? PlayerIdentitySourceStatus.cached.label : status.label;
  String get ratingLabel => rating == null ? 'Rating unavailable' : rating!;
  bool get hasAvatar => avatarUrl != null;
  bool get hasKnownRating => rating != null;

  PlayerIdentityDisplay copyWith({
    String? username,
    PlayerIdentityPlatform? platform,
    String? rating,
    String? avatarUrl,
    bool? isConnectedUser,
    bool? isOpponent,
    PlayerIdentitySide? side,
    PlayerIdentityResult? result,
    PlayerIdentitySourceStatus? status,
    bool? isCached,
    DateTime? lastUpdated,
  }) {
    return PlayerIdentityDisplay.fromRaw(
      username: username ?? this.username,
      platform: platform ?? this.platform,
      rating: rating ?? this.rating,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isConnectedUser: isConnectedUser ?? this.isConnectedUser,
      isOpponent: isOpponent ?? this.isOpponent,
      side: side ?? this.side,
      result: result ?? this.result,
      status: status ?? this.status,
      isCached: isCached ?? this.isCached,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  static String normalizeUsername(String raw) =>
      raw.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');

  static String fallbackInitialFor(
    String? username, {
    PlayerIdentitySide side = PlayerIdentitySide.unknown,
  }) {
    final raw = username?.trim() ?? '';
    for (final rune in raw.runes) {
      final ch = String.fromCharCode(rune);
      if (RegExp(r'[A-Za-z0-9]').hasMatch(ch)) return ch.toUpperCase();
    }
    return switch (side) {
      PlayerIdentitySide.white => 'W',
      PlayerIdentitySide.black => 'B',
      PlayerIdentitySide.unknown => '?',
    };
  }

  static String _safeUsername(String? raw) {
    final trimmed = raw?.trim();
    if (trimmed == null || trimmed.isEmpty) return 'Unknown';
    return trimmed.replaceAll(RegExp(r'\s+'), ' ');
  }

  static String? _cleanOptional(String? raw) {
    final trimmed = raw?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static String? _cleanUrl(String? raw) {
    final value = _cleanOptional(raw);
    if (value == null) return null;
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) return null;
    return value;
  }
}

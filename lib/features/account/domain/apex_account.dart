/// Persistent account identity — the Chess.com or Lichess handle the
/// user connected during onboarding. Everything else in the app
/// (Import, Opponent Forensics, Global Dashboard) prefills from here.
library;

enum AccountSource {
  chessCom('chess.com'),
  lichess('lichess');

  const AccountSource(this.wire);
  final String wire;

  static AccountSource? fromWire(String? s) {
    if (s == null) return null;
    for (final v in values) {
      if (v.wire == s) return v;
    }
    return null;
  }
}

class ApexAccount {
  const ApexAccount({required this.source, required this.username});
  final AccountSource source;
  final String username;

  ApexAccount copyWith({AccountSource? source, String? username}) =>
      ApexAccount(
        source: source ?? this.source,
        username: username ?? this.username,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApexAccount &&
          other.source == source &&
          other.username == username;

  @override
  int get hashCode => Object.hash(source, username);
}

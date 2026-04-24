/// SharedPreferences-backed store for the connected Chess.com / Lichess
/// account. Tiny key/value surface; the repo exists so consumers stay
/// off the raw `SharedPreferences` API and the keys live in one place.
library;

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/apex_account.dart';

class AccountRepository {
  AccountRepository({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;

  static const _sourceKey = 'apex.account.source';
  static const _usernameKey = 'apex.account.username';
  static const _onboardingKey = 'apex.account.onboarding_seen';

  Future<SharedPreferences> _get() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<ApexAccount?> read() async {
    final p = await _get();
    final source = AccountSource.fromWire(p.getString(_sourceKey));
    final username = p.getString(_usernameKey);
    if (source == null || username == null || username.isEmpty) return null;
    return ApexAccount(source: source, username: username);
  }

  Future<void> write(ApexAccount account) async {
    final p = await _get();
    await p.setString(_sourceKey, account.source.wire);
    await p.setString(_usernameKey, account.username);
  }

  Future<void> clear() async {
    final p = await _get();
    await p.remove(_sourceKey);
    await p.remove(_usernameKey);
  }

  /// Whether the user has already been shown the Connect Account
  /// onboarding at least once. Either connecting or skipping sets this
  /// flag — we never want to force a re-prompt.
  Future<bool> hasSeenOnboarding() async {
    final p = await _get();
    return p.getBool(_onboardingKey) ?? false;
  }

  Future<void> markOnboardingSeen() async {
    final p = await _get();
    await p.setBool(_onboardingKey, true);
  }
}

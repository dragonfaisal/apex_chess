/// Logout cascade — wipes every persisted scrap of the connected
/// account so the next launch is indistinguishable from a fresh
/// install.
///
/// Order matters:
///   1. **Hive boxes first** — close any open boxes and `deleteFromDisk`
///      so subsequent reads don't see stale archive / mistake-vault
///      entries from the previous account.
///   2. **SharedPreferences** — `clear()` removes every key in one
///      atomic call (account, onboarding flag, recent searches, academy
///      streak, …). This avoids the per-key dance and keeps the keys
///      list owned by each feature module rather than mirrored here.
///   3. **Provider invalidation** — handled by the caller so the UI
///      tree rebuilds against an empty state.
library;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../archives/data/archive_repository.dart';
import '../../mistake_vault/data/mistake_vault_repository.dart';

class LogoutService {
  const LogoutService();

  /// Atomically purge every persisted state surface tied to the
  /// previous account. Errors on any single step are swallowed — the
  /// goal is "best-effort wipe"; if a box is already absent the user
  /// still ends up at a clean slate.
  Future<void> wipeAll() async {
    await _wipeHive();
    await _wipePrefs();
  }

  Future<void> _wipeHive() async {
    for (final box in const [
      ArchiveRepository.boxName,
      MistakeVaultRepository.boxName,
    ]) {
      try {
        if (Hive.isBoxOpen(box)) {
          await Hive.box<String>(box).clear();
          await Hive.box<String>(box).close();
        }
        await Hive.deleteBoxFromDisk(box);
      } catch (_) {
        // Box never existed, or platform locked it — keep going so
        // the rest of the cascade still runs.
      }
    }
  }

  Future<void> _wipePrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {
      // Prefs are advisory; a corrupt platform file shouldn't strand
      // the user on a "logging out…" spinner forever.
    }
  }
}

/// Logout cascade — wipes every persisted scrap of the connected
/// account so the next launch is indistinguishable from a fresh
/// install.
///
/// Order matters:
///   1. **Hive boxes first** — clear each open box in-place. We
///      deliberately do NOT close or `deleteFromDisk` the archive /
///      mistake-vault boxes: those were opened at boot in `main()`
///      and other providers hold live references. Closing them would
///      throw `HiveError: Box has already been closed` on the next
///      read, which is exactly what produced the blank-screen crash
///      in Phase 5.1. `clear()` drops every entry but keeps the
///      handle alive.
///   2. **SharedPreferences** — `clear()` removes every key in one
///      atomic call (account, onboarding flag, recent searches,
///      academy streak, …). This avoids the per-key dance and keeps
///      the keys list owned by each feature module rather than
///      mirrored here.
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
    for (final name in const [
      ArchiveRepository.boxName,
      MistakeVaultRepository.boxName,
    ]) {
      try {
        // Open-if-needed, then clear in place. We cannot close or
        // delete-from-disk here — live repositories hold references
        // and the app would crash with "Box has already been closed".
        final box = Hive.isBoxOpen(name)
            ? Hive.box<String>(name)
            : await Hive.openBox<String>(name);
        await box.clear();
      } catch (_) {
        // Box lookup / open failed — the cascade is advisory, keep
        // going so prefs still get wiped.
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

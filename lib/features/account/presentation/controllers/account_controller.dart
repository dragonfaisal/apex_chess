/// Riverpod AsyncNotifier that exposes the connected account and the
/// mutators needed by the onboarding / switch-account flows.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/account_repository.dart';
import '../../domain/apex_account.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository();
});

/// Null when no account is connected yet — the UI uses that to decide
/// whether to show the Connect Account onboarding screen.
final accountControllerProvider =
    AsyncNotifierProvider<AccountController, ApexAccount?>(
  AccountController.new,
);

/// Tracks whether the first-launch onboarding screen has already been
/// presented. Set whenever the user connects or explicitly taps Skip;
/// never reset — the Switch Account flow navigates manually.
final onboardingSeenProvider = FutureProvider<bool>((ref) async {
  return ref.read(accountRepositoryProvider).hasSeenOnboarding();
});

class AccountController extends AsyncNotifier<ApexAccount?> {
  @override
  Future<ApexAccount?> build() async {
    final repo = ref.read(accountRepositoryProvider);
    return repo.read();
  }

  Future<void> connect(ApexAccount account) async {
    state = AsyncData(account);
    final repo = ref.read(accountRepositoryProvider);
    await repo.write(account);
    await repo.markOnboardingSeen();
    ref.invalidate(onboardingSeenProvider);
  }

  Future<void> disconnect() async {
    state = const AsyncData(null);
    await ref.read(accountRepositoryProvider).clear();
  }

  Future<void> markOnboardingSeen() async {
    await ref.read(accountRepositoryProvider).markOnboardingSeen();
    ref.invalidate(onboardingSeenProvider);
  }
}

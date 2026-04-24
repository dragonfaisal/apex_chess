import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/account/presentation/controllers/account_controller.dart';
import 'features/account/presentation/views/connect_account_screen.dart';
import 'features/archives/data/archive_repository.dart';
import 'features/home/presentation/views/home_screen.dart';
import 'shared_ui/themes/apex_theme.dart';
import 'shared_ui/widgets/quantum_shatter_loader.dart';

/// Boot sequence — defensive by design. A failure inside Hive init or
/// the blocking archive-box open used to abort before `runApp`, which
/// presented as a frozen themed blank screen on the next launch. We
/// now:
///   1. Wrap every init step in its own try/catch so a single failure
///      degrades cleanly instead of killing the boot.
///   2. Capture any uncaught framework/zone errors through
///      `FlutterError.onError` + `runZonedGuarded` — so we surface them
///      to `developer.log` instead of letting them bubble to a null
///      renderer (black/blue screen).
///   3. Always call `runApp` — even if Hive is wedged we at least
///      render the Connect Account onboarding so the user can recover.
Future<void> main() async {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    developer.log(
      'Uncaught Flutter error',
      name: 'apex_chess.boot',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await _bootstrapHive();
    runApp(const ProviderScope(child: ApexChessApp()));
  }, (error, stack) {
    developer.log(
      'Uncaught zone error',
      name: 'apex_chess.boot',
      error: error,
      stackTrace: stack,
    );
  });
}

/// Initialise Hive and open the archive box. Either step may fail on a
/// first launch after a logout-wipe (stale box file, restricted
/// filesystem on some emulators) — we catch both so the UI still gets
/// a chance to render.
Future<void> _bootstrapHive() async {
  try {
    await Hive.initFlutter();
  } catch (e, s) {
    developer.log('Hive.initFlutter failed',
        name: 'apex_chess.boot', error: e, stackTrace: s);
    return;
  }

  try {
    // Re-open is idempotent; if the box exists the call returns the
    // already-open handle. After a logout wipe the file is gone, and
    // `openBox` recreates an empty store — which is exactly what we
    // want for the fresh "connect account" flow.
    await Hive.openBox<String>(ArchiveRepository.boxName);
  } catch (e, s) {
    developer.log('Archive box open failed — archive feature will retry lazily',
        name: 'apex_chess.boot', error: e, stackTrace: s);
  }
}

class ApexChessApp extends StatelessWidget {
  const ApexChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apex Chess',
      debugShowCheckedModeBanner: false,
      theme: ApexTheme.dark,
      home: const _RootGate(),
    );
  }
}

/// Decides whether the first frame is [ConnectAccountScreen] or
/// [HomeScreen]. First launch with no stored onboarding flag shows the
/// connect flow; every subsequent launch jumps straight to Home. The
/// gate explicitly ignores the presence of a connected account for this
/// decision — a user may legitimately skip onboarding and still use the
/// app with per-screen username fields.
class _RootGate extends ConsumerWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seen = ref.watch(onboardingSeenProvider);
    return seen.when(
      loading: () => const _Splash(),
      // If prefs blow up (rare but possible on a corrupted store) send
      // the user to the safest surface — the connect screen — instead
      // of a Home that depends on downstream providers. This is the
      // Phase 5.2 fix for the "blank themed screen after logout" bug.
      error: (error, stack) {
        if (kDebugMode) {
          developer.log('onboardingSeenProvider error; falling back to Connect',
              name: 'apex_chess.boot', error: error, stackTrace: stack);
        }
        return _ConnectRoot(onComplete: () => _goHome(context));
      },
      data: (wasSeen) {
        if (wasSeen) return const HomeScreen();
        return _ConnectRoot(onComplete: () => _goHome(context));
      },
    );
  }

  static void _goHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
    );
  }
}

class _ConnectRoot extends StatelessWidget {
  const _ConnectRoot({required this.onComplete});
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return ConnectAccountScreen(allowSkip: true, onComplete: onComplete);
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: ApexGradients.spaceCanvas),
        child: const Center(child: QuantumShatterLoader(size: 180)),
      ),
    );
  }
}

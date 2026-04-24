import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/account/presentation/controllers/account_controller.dart';
import 'features/account/presentation/views/connect_account_screen.dart';
import 'features/archives/data/archive_repository.dart';
import 'features/home/presentation/views/home_screen.dart';
import 'shared_ui/themes/apex_theme.dart';
import 'shared_ui/widgets/quantum_shatter_loader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Hive must be initialised (chooses the per-platform path and
  // wires up the registry) and the archive box opened before the
  // first frame, or the Archived Intel screen will surface an
  // initialisation error rather than loading saved games.
  await Hive.initFlutter();
  await Hive.openBox<String>(ArchiveRepository.boxName);
  runApp(const ProviderScope(child: ApexChessApp()));
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
      error: (_, __) => const HomeScreen(),
      data: (wasSeen) {
        if (wasSeen) return const HomeScreen();
        return ConnectAccountScreen(
          allowSkip: true,
          onComplete: () {
            // Swap the gate contents for Home without leaving anything
            // on the nav stack — the user never sees a back arrow
            // pointing at the onboarding screen.
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
            );
          },
        );
      },
    );
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

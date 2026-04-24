import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/archives/data/archive_repository.dart';
import 'features/home/presentation/views/home_screen.dart';
import 'shared_ui/themes/apex_theme.dart';

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
      home: const HomeScreen(),
    );
  }
}

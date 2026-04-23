import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/home/presentation/views/home_screen.dart';
import 'shared_ui/themes/apex_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

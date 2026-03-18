import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const ProviderScope(child: MoneymorpheusApp()));
}

class MoneymorpheusApp extends StatelessWidget {
  const MoneymorpheusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'moneymorpheus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          background: baseBackgroundColor,
          surface: baseBackgroundColor,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

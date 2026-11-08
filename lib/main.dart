import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/library_provider.dart';
import 'providers/player_provider.dart';
import 'providers/profile_provider.dart';
import 'screens/main_shell.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ChordApp());
}

class ChordApp extends StatelessWidget {
  const ChordApp({super.key});

  @override
  Widget build(BuildContext context) {
    // The providers are placed ABOVE MaterialApp so that every screen,
    // dialog and bottom sheet (all of them live below MaterialApp) can use them.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MaterialApp(
        title: 'CHORD',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const MainShell(),
      ),
    );
  }
}

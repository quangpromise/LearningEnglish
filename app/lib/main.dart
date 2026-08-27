import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/navigation/root_shell.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: LearnEnglishMusicApp()));
}

class LearnEnglishMusicApp extends StatelessWidget {
  const LearnEnglishMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learn English Through Music',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgTop,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.blue,
          brightness: Brightness.dark,
          primary: AppColors.blue,
          secondary: AppColors.purple,
          surface: AppColors.bgMid,
        ),
        textTheme: GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme).apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
        fontFamily: GoogleFonts.manrope().fontFamily,
      ),
      home: const RootShell(),
    );
  }
}

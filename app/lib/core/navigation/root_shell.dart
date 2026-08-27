import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../../features/music_player/presentation/home_screen.dart';
import '../../features/pronunciation/presentation/pronunciation_screen.dart';
import '../../features/quiz/presentation/quiz_category_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/update/presentation/update_dialog.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _tab = 0;

  static const _screens = [
    HomeScreen(),
    QuizCategoryScreen(),
    PronunciationScreen(),
    ProfileScreen(),
  ];

  static const _icons = [Icons.home_rounded, Icons.extension_rounded, Icons.mic_rounded, Icons.person_rounded];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => showUpdateDialogIfAvailable(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgTop,
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xD90A0E1C),
            border: Border.all(color: AppColors.glassBorder),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 40, offset: const Offset(0, 20))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_icons.length, (i) {
              final active = i == _tab;
              return GestureDetector(
                onTap: () => setState(() => _tab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: active ? 76 : 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active ? Colors.white.withValues(alpha: 0.12) : Colors.transparent,
                    border: active ? Border.all(color: Colors.white.withValues(alpha: 0.35)) : null,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Icon(_icons[i], size: 22, color: active ? Colors.white : AppColors.textMuted),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

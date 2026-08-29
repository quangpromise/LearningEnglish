import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../../features/music_player/presentation/home_screen.dart';
import '../../features/pronunciation/presentation/pronunciation_screen.dart';
import '../../features/quiz/presentation/quiz_category_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/update/presentation/update_dialog.dart';

class RootShell extends ConsumerStatefulWidget {
  const RootShell({super.key});

  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<RootShell>
    with WidgetsBindingObserver {
  int _tab = 0;

  // Vocabulary theo chu de khong con la tab rieng - da chuyen thanh 1 the
  // truy cap nhanh ngay tren man Home (xem home_screen.dart).
  static const _screens = [
    HomeScreen(),
    QuizCategoryScreen(),
    PronunciationScreen(),
    ProfileScreen(),
  ];

  static const _icons = [
    Icons.home_rounded,
    Icons.extension_rounded,
    Icons.mic_rounded,
    Icons.person_rounded,
  ];

  Timer? _updateCheckTimer;
  Timer? _presenceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => showUpdateDialogIfAvailable(context),
    );
    // Ngoai kiem tra luc mo app/resume, kiem tra dinh ky moi 15 phut - phong
    // truong hop nguoi dung khong bao gio dua app xuong nen (didChange
    // AppLifecycleState.resumed se khong bao gio ban), ho van thay thong
    // bao neu ban build moi duoc publish trong luc dang dung app.
    _updateCheckTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      if (mounted) showUpdateDialogIfAvailable(context);
    });
    // "Dang online" duoc tinh o server bang last_seen_at trong vong 90s gan
    // nhat (xem my_friends() trong migration) - can heartbeat thuong xuyen
    // hon khoang do de ban be thay minh dang online chinh xac trong luc app
    // dang mo o foreground.
    ref.read(socialRepositoryProvider).updatePresence().catchError((_) {});
    _presenceTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      ref.read(socialRepositoryProvider).updatePresence().catchError((_) {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updateCheckTimer?.cancel();
    _presenceTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Truoc day chi kiem tra cap nhat 1 lan luc app moi mo - neu ban build
    // moi duoc publish trong luc app dang mo san, nguoi dung khong bao gio
    // thay thong bao tru khi tat han app roi mo lai. Kiem tra lai moi khi
    // app quay lai foreground.
    if (state == AppLifecycleState.resumed && mounted) {
      showUpdateDialogIfAvailable(context);
      ref.read(socialRepositoryProvider).updatePresence().catchError((_) {});
    }
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
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
                    color: active
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.transparent,
                    border: active
                        ? Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                          )
                        : null,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Icon(
                    _icons[i],
                    size: 22,
                    color: active ? Colors.white : AppColors.textMuted,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

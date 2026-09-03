import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/app_popup.dart';
import '../../../core/navigation/mini_app_bottom_nav.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../social/presentation/conversations_screen.dart';
import 'fitness_home_screen.dart';

/// Man goc cua khu vuc Fitness - CHI CON 1 man Home that su
/// (FitnessHomeScreen), moi tinh nang khac (Thu vien bai tap) va Tin nhan
/// deu mo popup (xem app_popup.dart) thay vi la tab rieng, nen thanh Menu
/// khong con nut Home. Ho so mo qua avatar tren AppTopBar cua
/// FitnessHomeScreen, thoat khoi Fitness qua app-switcher.
class FitnessShell extends ConsumerStatefulWidget {
  const FitnessShell({super.key});

  @override
  ConsumerState<FitnessShell> createState() => _FitnessShellState();
}

class _FitnessShellState extends ConsumerState<FitnessShell> {
  late final DateTime _openedAt;

  @override
  void initState() {
    super.initState();
    _openedAt = DateTime.now();
  }

  @override
  void dispose() {
    // Ghi nhan thoi gian dung Fitness (nguon 'fitness', tach voi tieng Anh)
    // cho bieu do "Hoat dong tuan nay" o man Ho so - giong het cach
    // PlayerScreen ghi nhan thoi gian nghe nhac.
    final elapsed = DateTime.now().difference(_openedAt).inSeconds;
    if (elapsed > 0) {
      ref
          .read(statsRepositoryProvider)
          .addPracticeSeconds(elapsed, source: 'fitness');
    }
    // Man nay bi go (kem ca khi thoat bang nut back he thong, khong chi qua
    // app-switcher) - tra currentAppSectionProvider ve Hoc Tieng Anh de tranh
    // "ket lai" o Fitness du man da khong con tren stack.
    if (ref.read(currentAppSectionProvider) == AppSection.fitness) {
      ref.read(currentAppSectionProvider.notifier).state =
          AppSection.learnEnglish;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(unreadMessageCountProvider).valueOrNull ?? 0;
    return Scaffold(
      backgroundColor: AppColors.bgTop,
      body: const FitnessHomeScreen(),
      bottomNavigationBar: MiniAppBottomNav(
        accentColor: AppColors.fitnessAccent,
        unreadCount: unread,
        onMessagesTap: () => openAppPopup(context, const ConversationsScreen()),
      ),
    );
  }
}

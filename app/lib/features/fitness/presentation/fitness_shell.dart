import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/mini_app_bottom_nav.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../social/presentation/conversations_screen.dart';
import 'muscle_group_categories_screen.dart';

/// Man hinh goc cua khu vuc Fitness - vao tu app-switcher tren Home. Co
/// thanh menu duoi rieng (giong RootShell nhung mau cam) voi 2 tab: Bai tap
/// (MuscleGroupCategoriesScreen) va Tin nhan (dung CHUNG
/// [ConversationsScreen] voi 2 khu vuc con lai). KHONG co tab/nut back rieng
/// - Ho so mo qua avatar tren AppTopBar, thoat khoi Fitness qua app-switcher.
class FitnessShell extends ConsumerStatefulWidget {
  const FitnessShell({super.key});

  @override
  ConsumerState<FitnessShell> createState() => _FitnessShellState();
}

class _FitnessShellState extends ConsumerState<FitnessShell> {
  int _tab = 0;
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

  static const _icons = [
    Icons.fitness_center_rounded,
    Icons.chat_bubble_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(unreadMessageCountProvider).valueOrNull ?? 0;
    return Scaffold(
      backgroundColor: AppColors.bgTop,
      body: IndexedStack(
        index: _tab,
        children: const [MuscleGroupCategoriesScreen(), ConversationsScreen()],
      ),
      bottomNavigationBar: MiniAppBottomNav(
        icons: _icons,
        currentIndex: _tab,
        accentColor: AppColors.fitnessAccent,
        badgeCounts: [0, unread],
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }
}

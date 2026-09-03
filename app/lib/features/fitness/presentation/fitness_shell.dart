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

  @override
  void initState() {
    super.initState();
    // Bat co "dang o Fitness" NGAY sau frame dau (khong lam trong initState
    // truc tiep - sua state cua 1 provider khac ngay luc build dang chay se
    // nem loi "Tried to modify a provider while the widget tree was building").
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(fitnessModeActiveProvider.notifier).state = true;
    });
  }

  @override
  void dispose() {
    // Doc ref truc tiep (khong qua context) vi dispose() chay sau khi
    // widget da bi go khoi cay, an toan de doc gia tri container o day.
    ref.read(fitnessModeActiveProvider.notifier).state = false;
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

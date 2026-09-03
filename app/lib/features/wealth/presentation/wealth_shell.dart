import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/app_popup.dart';
import '../../../core/navigation/mini_app_bottom_nav.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../social/presentation/conversations_screen.dart';
import 'wealth_home_screen.dart';

/// Man goc Quan ly tai san - CHI CON 1 man Home that su (WealthHomeScreen,
/// gom Chi tieu/Thu nhap/Dau tu thanh cac the danh muc), moi tinh nang khac
/// va Tin nhan deu mo popup (xem app_popup.dart) thay vi la tab rieng, nen
/// thanh Menu khong con nut Home. Ho so mo qua avatar tren AppTopBar cua
/// WealthHomeScreen, thoat khoi Wealth qua app-switcher.
class WealthShell extends ConsumerStatefulWidget {
  const WealthShell({super.key});

  @override
  ConsumerState<WealthShell> createState() => _WealthShellState();
}

class _WealthShellState extends ConsumerState<WealthShell> {
  @override
  void dispose() {
    // Xem giai thich trong FitnessShell.dispose(): tra ve Hoc Tieng Anh khi
    // man nay bi go (ke ca thoat qua nut back he thong), khong chi qua
    // app-switcher, de currentAppSectionProvider khong bi "ket" o Wealth.
    if (ref.read(currentAppSectionProvider) == AppSection.wealth) {
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
      body: const WealthHomeScreen(),
      bottomNavigationBar: MiniAppBottomNav(
        accentColor: AppColors.wealthAccent,
        unreadCount: unread,
        onMessagesTap: () => openAppPopup(context, const ConversationsScreen()),
      ),
    );
  }
}

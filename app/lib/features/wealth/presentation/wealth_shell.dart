import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/mini_app_bottom_nav.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../social/presentation/conversations_screen.dart';
import 'wealth_home_screen.dart';

/// Man goc Quan ly tai san (Wealth Management) - 2 tab: Home
/// (WealthHomeScreen, gom Chi tieu/Thu nhap/Dau tu thanh cac the danh muc -
/// xem file do) va Tin nhan (dung CHUNG [ConversationsScreen] voi 2 khu vuc
/// con lai). KHONG co tab/nut back rieng - Ho so mo qua avatar tren
/// AppTopBar, thoat khoi Wealth qua app-switcher.
///
/// MOI TAB CO 1 Navigator RIENG (giong RootShell/FitnessShell) de man con
/// (vd WealthDetailScreen tu WealthHomeScreen) khong che mat thanh Menu.
class WealthShell extends ConsumerStatefulWidget {
  const WealthShell({super.key});

  @override
  ConsumerState<WealthShell> createState() => _WealthShellState();
}

class _WealthShellState extends ConsumerState<WealthShell> {
  int _tab = 0;

  final _homeNavKey = GlobalKey<NavigatorState>();
  final _messagesNavKey = GlobalKey<NavigatorState>();

  List<GlobalKey<NavigatorState>> get _tabNavKeys => [
    _homeNavKey,
    _messagesNavKey,
  ];

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

  static const _icons = [
    Icons.account_balance_wallet_rounded,
    Icons.chat_bubble_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(unreadMessageCountProvider).valueOrNull ?? 0;
    return Scaffold(
      backgroundColor: AppColors.bgTop,
      body: NavigatorPopHandler(
        onPopWithResult: (result) {
          final nav = _tabNavKeys[_tab].currentState;
          if (nav != null && nav.canPop()) nav.pop(result);
        },
        child: IndexedStack(
          index: _tab,
          children: [
            Navigator(
              key: _homeNavKey,
              onGenerateRoute: (_) =>
                  MaterialPageRoute(builder: (_) => const WealthHomeScreen()),
            ),
            Navigator(
              key: _messagesNavKey,
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (_) => const ConversationsScreen(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MiniAppBottomNav(
        icons: _icons,
        currentIndex: _tab,
        accentColor: AppColors.wealthAccent,
        badgeCounts: [0, unread],
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }
}

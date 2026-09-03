import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/app_top_bar.dart';
import '../../../core/navigation/mini_app_bottom_nav.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../social/presentation/conversations_screen.dart';
import 'wealth_expense_tab.dart';
import 'wealth_income_tab.dart';
import 'wealth_investments_tab.dart';

/// Man goc Quan ly tai san (Wealth Management), Phase 1: Chi tieu/Thu nhap +
/// Dau tu (crypto + co phieu quoc te) + Tin nhan (dung CHUNG
/// [ConversationsScreen] voi 2 khu vuc con lai). KHONG co tab/nut back rieng
/// - Ho so mo qua avatar tren AppTopBar (giong moi man khac), thoat khoi
/// Wealth qua app-switcher (chon "Hoc Tieng Anh").
class WealthShell extends ConsumerStatefulWidget {
  const WealthShell({super.key});

  @override
  ConsumerState<WealthShell> createState() => _WealthShellState();
}

class _WealthShellState extends ConsumerState<WealthShell> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(wealthModeActiveProvider.notifier).state = true;
    });
  }

  @override
  void dispose() {
    ref.read(wealthModeActiveProvider.notifier).state = false;
    super.dispose();
  }

  static const _icons = [
    Icons.receipt_long_rounded,
    Icons.savings_rounded,
    Icons.trending_up_rounded,
    Icons.chat_bubble_rounded,
  ];

  Widget _buildBody() {
    if (_tab == 3) return const ConversationsScreen();
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppTopBar(accentColor: AppColors.wealthAccent),
            const SizedBox(height: 16),
            Expanded(
              child: switch (_tab) {
                0 => const WealthExpenseTab(),
                1 => const WealthIncomeTab(),
                _ => const WealthInvestmentsTab(),
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(unreadMessageCountProvider).valueOrNull ?? 0;
    return Scaffold(
      backgroundColor: AppColors.bgTop,
      body: _buildBody(),
      bottomNavigationBar: MiniAppBottomNav(
        icons: _icons,
        currentIndex: _tab,
        accentColor: AppColors.wealthAccent,
        badgeCounts: [0, 0, 0, unread],
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }
}

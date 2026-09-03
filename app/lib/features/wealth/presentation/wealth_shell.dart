import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/app_top_bar.dart';
import '../../../core/navigation/mini_app_bottom_nav.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../profile/presentation/profile_screen.dart';
import 'wealth_expense_tab.dart';
import 'wealth_income_tab.dart';
import 'wealth_investments_tab.dart';

/// Man goc Quan ly tai san (Wealth Management), Phase 1: Chi tieu/Thu nhap +
/// Dau tu (crypto + co phieu quoc te) + Ho so (dung CHUNG [ProfileScreen]
/// voi 2 khu vuc con lai). Co thanh menu duoi rieng (giong RootShell nhung
/// mau vang) thay cho TabBar tren dau truoc day - dong bo voi kieu "menu
/// bar rieng cho tung app" nhu Fitness.
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
    Icons.person_rounded,
  ];

  Widget _buildBody() {
    if (_tab == 3) return const ProfileScreen();
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppTopBar(
              showBackButton: true,
              accentColor: AppColors.wealthAccent,
            ),
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
    return Scaffold(
      backgroundColor: AppColors.bgTop,
      body: _buildBody(),
      bottomNavigationBar: MiniAppBottomNav(
        icons: _icons,
        currentIndex: _tab,
        accentColor: AppColors.wealthAccent,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }
}

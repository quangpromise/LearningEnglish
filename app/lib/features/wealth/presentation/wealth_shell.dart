import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_top_bar.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import 'wealth_expense_tab.dart';
import 'wealth_income_tab.dart';
import 'wealth_investments_tab.dart';

/// Man goc Quan ly tai san (Wealth Management), Phase 1: Chi tieu/Thu nhap +
/// Dau tu (crypto + co phieu quoc te). Vao tu AppSwitcherPill tren Home
/// (app_switcher_sheet.dart), giong het cach FitnessShell dat
/// fitnessModeActiveProvider de an nut noi AI Voice Chat.
class WealthShell extends ConsumerStatefulWidget {
  const WealthShell({super.key});

  @override
  ConsumerState<WealthShell> createState() => _WealthShellState();
}

class _WealthShellState extends ConsumerState<WealthShell>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(wealthModeActiveProvider.notifier).state = true;
    });
  }

  @override
  void dispose() {
    ref.read(wealthModeActiveProvider.notifier).state = false;
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTopBar(
              showBackButton: true,
              accentColor: AppColors.wealthAccent,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.06),
                    Colors.white.withValues(alpha: 0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              padding: const EdgeInsets.all(4),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: AppColors.wealthAccentGradient,
                  borderRadius: BorderRadius.circular(999),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textMuted,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                ),
                tabs: [
                  Tab(text: ref.tr('wealth_tab_expense')),
                  Tab(text: ref.tr('wealth_tab_income')),
                  Tab(text: ref.tr('wealth_tab_investments')),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  WealthExpenseTab(),
                  WealthIncomeTab(),
                  WealthInvestmentsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

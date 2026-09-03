import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_top_bar.dart';
import '../../../core/theme/app_theme.dart';
import 'wealth_detail_screen.dart';
import 'wealth_expense_tab.dart';
import 'wealth_income_tab.dart';
import 'wealth_investments_tab.dart';

/// Man Home cua khu vuc Quan ly tai san - theo dung mau Home cua Hoc Tieng
/// Anh/Fitness: 1 khung nhom danh muc voi cac the icon+ten (Chi tieu/Thu
/// nhap/Dau tu), thay vi 3 tab ngang hang o thanh Menu nhu truoc (da giai
/// phong Menu de danh cho thanh nhac dai + tab Tin nhan).
class WealthHomeScreen extends ConsumerWidget {
  const WealthHomeScreen({super.key});

  void _open(BuildContext context, Widget tab) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => WealthDetailScreen(child: tab)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppTopBar(accentColor: AppColors.wealthAccent),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: GlowBox(
                padding: const EdgeInsets.all(16),
                borderRadius: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ref.tr('wealth_home_category_manage'),
                      style: AppTextStyles.heading(size: 14),
                    ),
                    const SizedBox(height: 14),
                    // LayoutBuilder tinh be rong 1 the theo cong thuc "vua du
                    // 4 the/hang" - xem giai thich chi tiet trong
                    // home_screen.dart._CategorySection (Wrap+spaceBetween +
                    // width co dinh truoc day khong dam bao dung 4 the/hang).
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const spacing = 12.0;
                        const columns = 4;
                        final itemWidth =
                            (constraints.maxWidth - spacing * (columns - 1)) /
                            columns;
                        return Wrap(
                          spacing: spacing,
                          runSpacing: 14,
                          children: [
                            _WealthTile(
                              width: itemWidth,
                              icon: Icons.receipt_long_rounded,
                              label: ref.tr('wealth_tab_expense'),
                              onTap: () =>
                                  _open(context, const WealthExpenseTab()),
                            ),
                            _WealthTile(
                              width: itemWidth,
                              icon: Icons.savings_rounded,
                              label: ref.tr('wealth_tab_income'),
                              onTap: () =>
                                  _open(context, const WealthIncomeTab()),
                            ),
                            _WealthTile(
                              width: itemWidth,
                              icon: Icons.trending_up_rounded,
                              label: ref.tr('wealth_tab_investments'),
                              onTap: () =>
                                  _open(context, const WealthInvestmentsTab()),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WealthTile extends StatelessWidget {
  const _WealthTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.width,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.glassFill,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Icon(icon, color: AppColors.wealthAccent, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(size: 10.5, weight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

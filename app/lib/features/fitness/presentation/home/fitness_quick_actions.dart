import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'fitness_home_theme.dart';

/// 1 the trong hang "Tien ich nhanh".
class FitnessQuickAction {
  const FitnessQuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// Hang "Tien ich nhanh" - moi o chia DEU be ngang va hien het trong 1 hang,
/// KHONG cuon ngang: ban truoc cuon duoc nen 2 tinh nang cuoi (Thu vien bai
/// tap, Cong dong) bi khuat han khoi man hinh, nguoi dung khong biet chung
/// ton tai. Nhan tu dong thu nho lai (toi thieu 8dp) neu ten dai khong vua
/// o, thay vi bi cat bot chu.
class FitnessQuickActions extends StatelessWidget {
  const FitnessQuickActions({super.key, required this.actions});

  final List<FitnessQuickAction> actions;

  static const _gap = 6.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: FitnessHome.quickActionHeight,
      child: Row(
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            Expanded(child: _QuickCard(action: actions[i])),
            if (i != actions.length - 1) const SizedBox(width: _gap),
          ],
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({required this.action});

  final FitnessQuickAction action;

  @override
  Widget build(BuildContext context) {
    return FitnessPressable(
      onTap: action.onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: FitnessHome.quickFill,
          borderRadius: BorderRadius.circular(FitnessHome.quickRadius),
          border: Border.all(color: FitnessHome.quickBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, size: 18, color: FitnessHome.red),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              // FittedBox thay vi cho chu xuong dong: o chi cao 46dp, 1 nhan
              // 2 dong se lam tran the. Nhan dai (vd "Dinh duong") tu thu
              // nho lai vua o va luon nam gon tren 1 dong.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  action.label,
                  maxLines: 1,
                  style: AppTextStyles.body(size: 10, weight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

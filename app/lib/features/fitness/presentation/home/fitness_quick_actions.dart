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

/// Hang "Tien ich nhanh". Be rong tung the tinh sao cho DUNG 4 the vua khit
/// man hinh (giong anh thiet ke), phan con lai cuon ngang - nho vay khong
/// tinh nang nao bi mat loi vao khi so tien ich nhieu hon 4, va tren may
/// man hinh hep chu cung khong bi bop lai.
class FitnessQuickActions extends StatelessWidget {
  const FitnessQuickActions({super.key, required this.actions});

  final List<FitnessQuickAction> actions;

  static const _gap = 7.0;
  static const _visibleColumns = 4;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            (constraints.maxWidth - _gap * (_visibleColumns - 1)) /
            _visibleColumns;
        return SizedBox(
          height: FitnessHome.quickActionHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            clipBehavior: Clip.none,
            physics: actions.length <= _visibleColumns
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            itemCount: actions.length,
            separatorBuilder: (_, _) => const SizedBox(width: _gap),
            itemBuilder: (context, index) =>
                _QuickCard(action: actions[index], width: itemWidth),
          ),
        );
      },
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({required this.action, required this.width});

  final FitnessQuickAction action;
  final double width;

  @override
  Widget build(BuildContext context) {
    return FitnessPressable(
      onTap: action.onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          gradient: FitnessHome.quickFill,
          borderRadius: BorderRadius.circular(FitnessHome.quickRadius),
          border: Border.all(color: FitnessHome.quickBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, size: 19, color: FitnessHome.red),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                action.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.body(size: 10.5, weight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

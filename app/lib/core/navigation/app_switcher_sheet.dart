import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/fitness/presentation/fitness_shell.dart';
import '../../features/wealth/presentation/wealth_shell.dart';
import '../i18n/app_strings.dart';
import '../theme/app_theme.dart';

/// The/pill "the tren cua so" nam duoi loi chao Home (thay cho vi tri "Smart
/// Home Controller" trong app tham khao) - bam vao mo [showAppSwitcherSheet]
/// de chuyen sang 1 "app" khac trong cung 1 APK (Fitness da co, cac muc con
/// lai chi la placeholder cho tinh nang se lam sau).
class AppSwitcherPill extends ConsumerWidget {
  const AppSwitcherPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => showAppSwitcherSheet(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.school_rounded, size: 13, color: AppColors.blue),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              ref.tr('app_switcher_learn_english'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.muted(size: 12, weight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 3),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

void showAppSwitcherSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AppSwitcherSheet(),
  );
}

class _AppSwitcherSheet extends ConsumerWidget {
  const _AppSwitcherSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        color: Color(0xFF12172E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Text(
            ref.tr('app_switcher_title'),
            style: AppTextStyles.heading(size: 16),
          ),
          const SizedBox(height: 14),
          _AppSwitcherTile(
            icon: Icons.school_rounded,
            color: AppColors.blue,
            label: ref.tr('app_switcher_learn_english'),
            trailing: _CurrentBadge(text: ref.tr('app_switcher_current_badge')),
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 10),
          _AppSwitcherTile(
            icon: Icons.fitness_center_rounded,
            color: AppColors.teal,
            label: ref.tr('app_switcher_fitness'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const FitnessShell()));
            },
          ),
          const SizedBox(height: 10),
          _AppSwitcherTile(
            icon: Icons.account_balance_wallet_rounded,
            color: AppColors.amber,
            label: ref.tr('app_switcher_wealth'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const WealthShell()));
            },
          ),
        ],
      ),
    );
  }
}

class _AppSwitcherTile extends StatelessWidget {
  const _AppSwitcherTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.trailing,
  });
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlowBox(
        borderRadius: 18,
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body(weight: FontWeight.w800),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class _CurrentBadge extends StatelessWidget {
  const _CurrentBadge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.blue,
          fontWeight: FontWeight.w800,
          fontSize: 10.5,
        ),
      ),
    );
  }
}

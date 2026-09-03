import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/fitness/presentation/fitness_shell.dart';
import '../../features/wealth/presentation/wealth_shell.dart';
import '../i18n/app_strings.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';

/// Pill "chuyen doi ung dung" nam duoi loi chao (dat trong [AppTopBar],
/// hien tren CA 3 khu vuc: Hoc Tieng Anh/Fitness/Wealth) - bam vao XO
/// DANH SACH NGAY TAI CHO (dropdown noi, khong mo bottom sheet rieng) de
/// de bam hon va khong lam gian doan luong dang xem. Dung
/// CompositedTransformTarget/Follower de neo dropdown dung ngay duoi pill
/// bat ke pill dang nam o vi tri nao tren man hinh.
class AppSwitcherPill extends ConsumerStatefulWidget {
  const AppSwitcherPill({super.key});

  @override
  ConsumerState<AppSwitcherPill> createState() => _AppSwitcherPillState();
}

class _AppSwitcherPillState extends ConsumerState<AppSwitcherPill> {
  final _link = LayerLink();
  OverlayEntry? _entry;
  bool _open = false;

  void _toggle() {
    if (_entry != null) {
      _close();
    } else {
      _openDropdown();
    }
  }

  // SUA LOI GOC: truoc day 2 StateProvider<bool> rieng (fitness/wealth) duoc
  // bat/tat qua initState/dispose cua FitnessShell/WealthShell - thu tu
  // dispose(man cu)/initState(man moi) khong dam bao, nen tu lan chuyen thu 2
  // tro di 2 co co the desync (ca 2 cung true, hoac ca 2 cung false). Gio
  // CHI 1 nguon that (currentAppSectionProvider) va no duoc set THANG,
  // DONG BO, ngay tai noi bam - khong con phu thuoc lifecycle man hinh nao.
  void _select(AppSection section) {
    _close();
    final current = ref.read(currentAppSectionProvider);
    if (current == section) return;
    ref.read(currentAppSectionProvider.notifier).state = section;
    Navigator.of(context).popUntil((r) => r.isFirst);
    switch (section) {
      case AppSection.fitness:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const FitnessShell()));
      case AppSection.wealth:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const WealthShell()));
      case AppSection.learnEnglish:
        break;
    }
  }

  void _openDropdown() {
    final overlay = Overlay.of(context);
    _entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // Bat tap ngoai vung dropdown de dong lai - phu toan man hinh
          // nhung trong suot, khong lam toi nhu 1 modal that su.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _close,
            ),
          ),
          CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomLeft,
            followerAnchor: Alignment.topLeft,
            offset: const Offset(0, 8),
            child: _DropdownPanel(onSelect: (section) => _select(section)),
          ),
        ],
      ),
    );
    overlay.insert(_entry!);
    setState(() => _open = true);
  }

  void _close() {
    _entry?.remove();
    _entry = null;
    if (mounted) setState(() => _open = false);
  }

  @override
  void dispose() {
    _entry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hien dung "app" DANG DUNG - doc DUY NHAT 1 nguon that
    // (currentAppSectionProvider) thay vi 2 co bool rieng de (da gay loi
    // desync khi chuyen doi qua lai nhieu lan, xem _select() ben tren).
    final section = ref.watch(currentAppSectionProvider);
    final (icon, color, labelKey) = switch (section) {
      AppSection.fitness => (
        Icons.fitness_center_rounded,
        AppColors.fitnessAccent,
        'app_switcher_fitness',
      ),
      AppSection.wealth => (
        Icons.account_balance_wallet_rounded,
        AppColors.wealthAccent,
        'app_switcher_wealth',
      ),
      AppSection.learnEnglish => (
        Icons.school_rounded,
        AppColors.blue,
        'app_switcher_learn_english',
      ),
    };

    return CompositedTransformTarget(
      link: _link,
      child: GestureDetector(
        onTap: _toggle,
        // Vung cham lon hon chu/icon that su (them padding + nen mo) de de
        // bam hon - truoc day chi la 1 dong chu+icon nho, kho trung dich.
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  ref.tr(labelKey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.muted(size: 12, weight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 3),
              AnimatedRotation(
                turns: _open ? 0.5 : 0,
                duration: const Duration(milliseconds: 150),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownPanel extends ConsumerWidget {
  const _DropdownPanel({required this.onSelect});
  final ValueChanged<AppSection> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(currentAppSectionProvider);
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF12172E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AppSwitcherTile(
              icon: Icons.school_rounded,
              color: AppColors.blue,
              label: ref.tr('app_switcher_learn_english'),
              active: section == AppSection.learnEnglish,
              onTap: () => onSelect(AppSection.learnEnglish),
            ),
            const SizedBox(height: 6),
            _AppSwitcherTile(
              icon: Icons.fitness_center_rounded,
              color: AppColors.fitnessAccent,
              label: ref.tr('app_switcher_fitness'),
              active: section == AppSection.fitness,
              onTap: () => onSelect(AppSection.fitness),
            ),
            const SizedBox(height: 6),
            _AppSwitcherTile(
              icon: Icons.account_balance_wallet_rounded,
              color: AppColors.wealthAccent,
              label: ref.tr('app_switcher_wealth'),
              active: section == AppSection.wealth,
              onTap: () => onSelect(AppSection.wealth),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppSwitcherTile extends ConsumerWidget {
  const _AppSwitcherTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.active,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 15, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body(size: 13, weight: FontWeight.w700),
              ),
            ),
            if (active)
              _CurrentBadge(text: ref.tr('app_switcher_current_badge')),
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

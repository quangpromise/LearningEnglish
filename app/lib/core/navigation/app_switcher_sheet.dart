import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/fitness/presentation/fitness_shell.dart';
import '../../features/wealth/presentation/wealth_shell.dart';
import '../i18n/app_strings.dart';
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
            child: _DropdownPanel(
              onSelectLearnEnglish: () {
                _close();
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
              onSelectFitness: () {
                _close();
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const FitnessShell()));
              },
              onSelectWealth: () {
                _close();
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const WealthShell()));
              },
            ),
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
  const _DropdownPanel({
    required this.onSelectLearnEnglish,
    required this.onSelectFitness,
    required this.onSelectWealth,
  });
  final VoidCallback onSelectLearnEnglish;
  final VoidCallback onSelectFitness;
  final VoidCallback onSelectWealth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              onTap: onSelectLearnEnglish,
            ),
            const SizedBox(height: 6),
            _AppSwitcherTile(
              icon: Icons.fitness_center_rounded,
              color: AppColors.fitnessAccent,
              label: ref.tr('app_switcher_fitness'),
              onTap: onSelectFitness,
            ),
            const SizedBox(height: 6),
            _AppSwitcherTile(
              icon: Icons.account_balance_wallet_rounded,
              color: AppColors.wealthAccent,
              label: ref.tr('app_switcher_wealth'),
              onTap: onSelectWealth,
            ),
          ],
        ),
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
  });
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
          ],
        ),
      ),
    );
  }
}

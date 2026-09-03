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
              // BAT BUOC popUntil((r) => r.isFirst) TRUOC KHI push 1 khu
              // vuc moi (ke ca khi dang o Hoc Tieng Anh) - neu chi push
              // chong len, bam qua lai Fitness/Wealth nhieu lan se xep
              // CHONG nhieu FitnessShell/WealthShell trong CUNG 1 Navigator
              // stack, khien 2 co trang thai (fitnessModeActiveProvider/
              // wealthModeActiveProvider) cua nhieu instance de len nhau va
              // cung bao "true" mot luc (dung nut Assets Management +
              // Fitness deu hien "Current" nhu nhau). Luon quay ve goc roi
              // moi push dam bao CHI 1 khu vuc con nam trong stack tai 1
              // thoi diem.
              onSelectLearnEnglish: () {
                _close();
                if (!ref.read(fitnessModeActiveProvider) &&
                    !ref.read(wealthModeActiveProvider)) {
                  return; // da o Hoc Tieng Anh roi, khong lam gi them.
                }
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
              onSelectFitness: () {
                _close();
                if (ref.read(fitnessModeActiveProvider)) return;
                Navigator.of(context).popUntil((r) => r.isFirst);
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const FitnessShell()));
              },
              onSelectWealth: () {
                _close();
                if (ref.read(wealthModeActiveProvider)) return;
                Navigator.of(context).popUntil((r) => r.isFirst);
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
    // Hien dung "app" DANG DUNG (khong luon co dinh "Hoc Tieng Anh") - doc
    // 2 co trang thai da co san (bat/tat luc vao/thoat FitnessShell/
    // WealthShell) thay vi suy tu route, don gian va da dung dung o nhieu
    // noi khac (ScreenBackground, ai_fab_overlay...).
    final fitnessActive = ref.watch(fitnessModeActiveProvider);
    final wealthActive = ref.watch(wealthModeActiveProvider);
    final (icon, color, labelKey) = fitnessActive
        ? (
            Icons.fitness_center_rounded,
            AppColors.fitnessAccent,
            'app_switcher_fitness',
          )
        : wealthActive
        ? (
            Icons.account_balance_wallet_rounded,
            AppColors.wealthAccent,
            'app_switcher_wealth',
          )
        : (Icons.school_rounded, AppColors.blue, 'app_switcher_learn_english');

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
    final fitnessActive = ref.watch(fitnessModeActiveProvider);
    final wealthActive = ref.watch(wealthModeActiveProvider);
    final learnEnglishActive = !fitnessActive && !wealthActive;
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
              active: learnEnglishActive,
              onTap: onSelectLearnEnglish,
            ),
            const SizedBox(height: 6),
            _AppSwitcherTile(
              icon: Icons.fitness_center_rounded,
              color: AppColors.fitnessAccent,
              label: ref.tr('app_switcher_fitness'),
              active: fitnessActive,
              onTap: onSelectFitness,
            ),
            const SizedBox(height: 6),
            _AppSwitcherTile(
              icon: Icons.account_balance_wallet_rounded,
              color: AppColors.wealthAccent,
              label: ref.tr('app_switcher_wealth'),
              active: wealthActive,
              onTap: onSelectWealth,
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

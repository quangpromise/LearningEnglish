import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../i18n/app_strings.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';

/// 4 tab cua man goc GymTalk (xem root_shell.dart). Ho so van mo tu avatar
/// tren AppTopBar (ProfileScreen duoc thiet ke dang popup).
enum RootTab {
  today,
  train,
  learn,
  progress;

  /// Khu vuc (theme/nen/mac dinh Lap ke hoach...) tuong ung voi tab.
  AppSection get section =>
      this == RootTab.train ? AppSection.fitness : AppSection.learnEnglish;

  String get labelKey => switch (this) {
    RootTab.today => 'tab_today',
    RootTab.train => 'tab_train',
    RootTab.learn => 'tab_learn',
    RootTab.progress => 'tab_progress',
  };

  IconData get icon => switch (this) {
    RootTab.today => Icons.wb_sunny_outlined,
    RootTab.train => Icons.fitness_center_rounded,
    RootTab.learn => Icons.school_outlined,
    RootTab.progress => Icons.insights_rounded,
  };

  IconData get selectedIcon => switch (this) {
    RootTab.today => Icons.wb_sunny_rounded,
    RootTab.train => Icons.fitness_center_rounded,
    RootTab.learn => Icons.school_rounded,
    RootTab.progress => Icons.insights_rounded,
  };

  Color get accent =>
      this == RootTab.train ? AppColors.fitnessAccent : AppColors.blue;
}

/// Tab dang chon. Doi tab qua provider nay (AppSwitcherPill, khoi phuc sau
/// dang nhap...) - RootShell nghe thay doi de dong bo khu vuc + ghi thoi
/// gian dung Fitness.
final rootTabProvider = StateProvider<RootTab>((ref) => RootTab.today);

/// Thanh tab duoi cung - cao 64dp, nhan to, mau nhan theo tab dang chon.
class GymTalkTabBar extends ConsumerWidget {
  const GymTalkTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(rootTabProvider);
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.bgBottom,
        border: Border(top: BorderSide(color: AppColors.glassBorder)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (final tab in RootTab.values)
                Expanded(
                  child: _TabItem(
                    tab: tab,
                    selected: tab == current,
                    label: ref.tr(tab.labelKey),
                    onTap: () => ref.read(rootTabProvider.notifier).state = tab,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.tab,
    required this.selected,
    required this.label,
    required this.onTap,
  });
  final RootTab tab;
  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? tab.accent : AppColors.textMuted;
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? tab.accent.withValues(alpha: 0.18)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                selected ? tab.selectedIcon : tab.icon,
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(
                size: 12,
                weight: selected ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/fitness/presentation/programs_list_screen.dart';
import '../../features/srs/presentation/srs_review_screen.dart';
import '../../features/today/data/daily_progress_store.dart';
import '../../features/today/data/shell_presentation.dart';
import '../i18n/app_strings.dart';
import '../providers/app_providers.dart';
import '../theme/gt_tokens.dart';
import 'app_popup.dart';
import 'root_tabs.dart';

/// Thanh tab cua ban redesign (spec #70): 4 tab + nut Quick Start o giua,
/// nen kinh mo. Quick Start la hanh dong, khong phai tab.
class GtTabBar extends ConsumerWidget {
  const GtTabBar({super.key});

  /// Nut Quick Start noi len tren nen kinh bao nhieu dp.
  static const double raise = 18;

  /// Chieu cao phan kinh (chua tinh home indicator).
  static const double barHeight = 64;

  static Color activeColor(GtTokens t, RootTab tab) => switch (tab) {
    RootTab.today => t.tx,
    RootTab.train => t.red,
    RootTab.learn => t.blue,
    RootTab.progress => t.gold,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    final current = ref.watch(rootTabProvider);
    Widget tab(RootTab tab) => Expanded(
      child: _GtTabItem(
        tab: tab,
        selected: tab == current,
        color: tab == current ? activeColor(t, tab) : t.tx3,
        label: ref.tr(tab.labelKey),
        onTap: () => ref.read(rootTabProvider.notifier).state = tab,
      ),
    );
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    // Widget cao them [raise] (trong suot, Stack khong nhan cham o cho
    // trong) de nut Quick Start noi len khong bi ClipRect cua lop kinh cat.
    return SizedBox(
      height: raise + barHeight + safeBottom,
      child: Stack(
        children: [
          Positioned.fill(
            top: raise,
            child: ClipRect(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: t.glass,
                    border: Border(top: BorderSide(color: t.bd)),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: raise,
            height: barHeight,
            child: Row(
              children: [
                tab(RootTab.today),
                tab(RootTab.train),
                const Spacer(),
                tab(RootTab.learn),
                tab(RootTab.progress),
              ],
            ),
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(child: QuickStartButton()),
          ),
        ],
      ),
    );
  }
}

class _GtTabItem extends StatelessWidget {
  const _GtTabItem({
    required this.tab,
    required this.selected,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final RootTab tab;
  final bool selected;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    label: label,
    child: InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(selected ? tab.selectedIcon : tab.icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GtText.tabLabel(color, active: selected),
          ),
        ],
      ),
    ),
  );
}

/// Nut Quick Start 58dp noi len tren thanh tab: vao buoi tap hom nay, hoac
/// on the neu da tap / ngay nghi / chua co giao an (CONTEXT.md).
class QuickStartButton extends ConsumerWidget {
  const QuickStartButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    // Giu provider autoDispose song de luc cham doc duoc ket qua da tai,
    // khong bi huy giua chung roi roi vao nhanh "chua co giao an".
    ref.watch(todayWorkoutPlanProvider);
    return Semantics(
      button: true,
      label: ref.tr('tab_quick_start'),
      child: GestureDetector(
        onTap: () => _start(context, ref),
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: t.inv,
            shape: BoxShape.circle,
            border: Border.all(color: t.bg, width: 4),
          ),
          child: Icon(Icons.bolt_rounded, color: t.onInv, size: 32),
        ),
      ),
    );
  }

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    await DailyProgressStore.instance.ensureLoaded();
    final plan = await ref
        .read(todayWorkoutPlanProvider.future)
        .catchError((Object _) => null);
    if (!context.mounted) return;
    final target = quickStartTarget(
      hasPlan: plan != null,
      isRestDay: plan?.isRestDay ?? false,
      today: DailyProgressStore.instance.today,
    );
    switch (target) {
      case QuickStartTarget.todayWorkout:
        openAppPopup(
          context,
          ProgramsListScreen(initialProgramId: plan!.program.id),
        );
      case QuickStartTarget.review:
        openAppPopup(context, const SrsReviewScreen());
    }
  }
}

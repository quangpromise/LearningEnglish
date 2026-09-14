import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../data/planner_models.dart';
import 'planner_providers.dart';

/// Luoi thang (bam ten thang o man Lap ke hoach) - nhin ca thang, cham nho
/// = ngay co viec, bam 1 ngay de nhay toi ngay do tren timeline
/// (docs/research-planner-app-ux.md §2 va §7.2 muc I).
Future<void> showPlannerMonthSheet(
  BuildContext context, {
  required DateTime selected,
  required Gradient gradient,
  required Color glow,
  required String Function(DateTime) monthLabel,
  required List<String> weekdayLabels,
  required ValueChanged<DateTime> onPick,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _MonthSheet(
      selected: selected,
      gradient: gradient,
      glow: glow,
      monthLabel: monthLabel,
      weekdayLabels: weekdayLabels,
      onPick: onPick,
    ),
  );
}

class _MonthSheet extends StatefulWidget {
  const _MonthSheet({
    required this.selected,
    required this.gradient,
    required this.glow,
    required this.monthLabel,
    required this.weekdayLabels,
    required this.onPick,
  });

  final DateTime selected;
  final Gradient gradient;
  final Color glow;
  final String Function(DateTime) monthLabel;
  final List<String> weekdayLabels;
  final ValueChanged<DateTime> onPick;

  @override
  State<_MonthSheet> createState() => _MonthSheetState();
}

class _MonthSheetState extends State<_MonthSheet> {
  late DateTime _month = DateTime(widget.selected.year, widget.selected.month);

  void _shift(int delta) =>
      setState(() => _month = DateTime(_month.year, _month.month + delta));

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    // So o trong truoc ngay 1 (tuan bat dau Thu 2, giong date-strip).
    final lead = _month.weekday - 1;
    final cells = lead + daysInMonth;
    final rows = (cells / 7).ceil();
    final today = plannerDateOnly(DateTime.now());

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 26),
      decoration: const BoxDecoration(
        color: Color(0xEB0F1326),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                onPressed: () => _shift(-1),
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.textMuted,
                ),
              ),
              Expanded(
                child: Text(
                  widget.monthLabel(_month),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading(size: 16),
                ),
              ),
              IconButton(
                onPressed: () => _shift(1),
                icon: Icon(Icons.chevron_right_rounded, color: widget.glow),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (final w in widget.weekdayLabels)
                Expanded(
                  child: Center(
                    child: Text(
                      w,
                      style: AppTextStyles.muted(
                        size: 10,
                        weight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          for (var r = 0; r < rows; r++)
            Row(
              children: [
                for (var c = 0; c < 7; c++)
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final dayNum = r * 7 + c - lead + 1;
                        if (dayNum < 1 || dayNum > daysInMonth) {
                          return const SizedBox(height: 46);
                        }
                        final day = DateTime(_month.year, _month.month, dayNum);
                        return _DayCell(
                          day: day,
                          selected: day == plannerDateOnly(widget.selected),
                          isToday: day == today,
                          gradient: widget.gradient,
                          glow: widget.glow,
                          onTap: () {
                            widget.onPick(day);
                            Navigator.of(context).maybePop();
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DayCell extends ConsumerWidget {
  const _DayCell({
    required this.day,
    required this.selected,
    required this.isToday,
    required this.gradient,
    required this.glow,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final bool isToday;
  final Gradient gradient;
  final Color glow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final occs = ref.watch(plannerOccurrencesForDayProvider(day));
    final done = occs.where((o) => o.isDone).length;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          gradient: selected ? gradient : null,
          color: selected ? null : AppColors.glassFill,
          borderRadius: BorderRadius.circular(12),
          border: isToday && !selected
              ? Border.all(color: glow.withValues(alpha: 0.8))
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : AppColors.textPrimary,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 3),
            // Toi da 3 cham = so viec trong ngay; cham xanh = da xong.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < occs.length.clamp(0, 3); i++)
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? Colors.white
                          : i < done
                          ? PlannerTaskStatus.completed.color
                          : glow,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_language.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/widgets/pull_to_dismiss.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../planner/presentation/planner_accent.dart';
import '../../planner/presentation/planner_providers.dart'
    show plannerNowProvider;
import '../data/todo_models.dart';
import 'todo_providers.dart';
import 'todo_task_sheet.dart';

/// Mau nhan doi theo APP dang mo (xanh Hoc Tieng Anh / cam Fitness / vang
/// Quan ly tai san) - giong moi man khac trong app, thay vi bo mau vang co
/// dinh nhu ban dau.
Color _accent(WidgetRef ref) =>
    plannerAccentFor(ref.watch(currentAppSectionProvider)).$2;
Gradient _accentGradient(WidgetRef ref) =>
    plannerAccentFor(ref.watch(currentAppSectionProvider)).$1;

/// 2 mau TRANG THAI thi KHONG doi theo app: xong luon xanh luc, qua han
/// luon do - day la y nghia co dinh, doi theo app se lam nguoi dung phai
/// doc lai nhan chu moi biet.
const _green = Color(0xFF22C55E);
const _red = Color(0xFFEF4444);

const _monthsVi = [
  'tháng 1',
  'tháng 2',
  'tháng 3',
  'tháng 4',
  'tháng 5',
  'tháng 6',
  'tháng 7',
  'tháng 8',
  'tháng 9',
  'tháng 10',
  'tháng 11',
  'tháng 12',
];
const _monthsEn = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
const _weekdaysVi = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
const _weekdaysEn = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
const _weekdayFullVi = [
  'Thứ Hai',
  'Thứ Ba',
  'Thứ Tư',
  'Thứ Năm',
  'Thứ Sáu',
  'Thứ Bảy',
  'Chủ Nhật',
];

String _hhmm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// "Thứ Năm, 18 tháng 9 2026" / "Thursday, 18 September 2026" - lay NGAY
/// THAT tu du lieu, khong hardcode.
String _longDate(DateTime d, AppLanguage lang) {
  if (lang == AppLanguage.vi) {
    return '${_weekdayFullVi[d.weekday - 1]}, ${d.day} ${_monthsVi[d.month - 1]} ${d.year}';
  }
  return '${_weekdaysEn[d.weekday - 1].substring(0, 1)}${_weekdaysEn[d.weekday - 1].substring(1).toLowerCase()}, '
      '${d.day} ${_monthsEn[d.month - 1]} ${d.year}';
}

/// "Bay gio" dung chung cho ca man - doc qua provider nen moi phut trang
/// thai (Qua han/Chuyen tu hom qua) tu cap nhat ma khong can mo lai man.
DateTime _now(WidgetRef ref) =>
    ref.watch(plannerNowProvider).valueOrNull ?? DateTime.now();

class TodoScreen extends ConsumerWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appLanguageProvider);
    final selected = ref.watch(todoSelectedDateProvider);
    final tasks = ref.watch(todoTasksForSelectedDateProvider);
    final summary = ref.watch(todoDaySummaryProvider(selected));

    final accent = _accent(ref);
    return Container(
      // Nen toi pha MOT CHUT accent cua app dang mo - dung gradient thay vi
      // anh/blur vi spec yeu cau uu tien hieu nang Android (tranh
      // BackdropFilter va CustomPaint chay lien tuc).
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.alphaBlend(
              accent.withValues(alpha: 0.13),
              const Color(0xFF080B12),
            ),
            Color.alphaBlend(
              accent.withValues(alpha: 0.05),
              const Color(0xFF05070E),
            ),
            const Color(0xFF020306),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: _AddButton(
          gradient: _accentGradient(ref),
          glow: accent,
          onTap: () => showTodoTaskSheet(context, ref, day: selected),
        ),
        // Ca man la 1 ListView nen cu vuot xuong bi vung cuon "nuot", sheet
        // khong dong duoc - PullToDismiss bat overscroll o DAU danh sach de
        // dong. BAT BUOC di kem ClampingScrollPhysics: voi hieu ung bat kieu
        // iOS (mac dinh tren web iPhone) Flutter khong phat
        // OverscrollNotification ma chi nay noi dung len.
        body: SafeArea(
          child: PullToDismiss(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                PopupHeader(title: ref.tr('todo_title')),
                const SizedBox(height: 18),
                _HeroBlock(day: selected, summary: summary, lang: lang),
                const SizedBox(height: 18),
                _DateStrip(selected: selected),
                const SizedBox(height: 22),
                _SectionLabel(ref.tr('todo_tasks')),
                const SizedBox(height: 10),
                if (tasks.isEmpty)
                  _EmptyState(text: ref.tr('todo_empty'))
                else
                  for (final t in tasks) ...[
                    _TaskCard(task: t),
                    const SizedBox(height: 8),
                  ],
                const SizedBox(height: 22),
                _SectionLabel(ref.tr('todo_progress')),
                const SizedBox(height: 12),
                _ProgressBlock(summary: summary),
                const SizedBox(height: 22),
                _SectionLabel(ref.tr('todo_this_week')),
                const SizedBox(height: 12),
                const _WeekStrip(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTextStyles.body(
      size: 11,
      weight: FontWeight.w800,
      color: AppColors.textMuted,
    ).copyWith(letterSpacing: 1.6),
  );
}

/// Khoi tren cung: HOM NAY + ngay that + thanh tien do gon.
class _HeroBlock extends ConsumerWidget {
  const _HeroBlock({
    required this.day,
    required this.summary,
    required this.lang,
  });

  final DateTime day;
  final TodoDaySummary summary;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = _accent(ref);
    final isToday = todoDayKey(day) == todoDayKey(_now(ref));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isToday ? ref.tr('todo_today') : ref.tr('todo_tasks'),
          style: AppTextStyles.body(
            size: 12,
            weight: FontWeight.w800,
            color: accent,
          ).copyWith(letterSpacing: 2.4),
        ),
        const SizedBox(height: 6),
        Text(_longDate(day, lang), style: AppTextStyles.heading(size: 22)),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: TweenAnimationBuilder<double>(
            // Tien do chay MUOT tu gia tri cu sang gia tri moi khi tick xong
            // 1 viec, thay vi nhay 1 phat.
            tween: Tween(begin: 0, end: summary.ratio),
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => LinearProgressIndicator(
              value: v,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              color: accent,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${summary.completed} / ${summary.total} ${ref.tr('todo_completed_n')}',
          style: AppTextStyles.muted(size: 12),
        ),
      ],
    );
  }
}

/// Thanh chon ngay toi gian - 7 ngay quanh ngay dang xem.
class _DateStrip extends ConsumerWidget {
  const _DateStrip({required this.selected});
  final DateTime selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = _accent(ref);
    final lang = ref.watch(appLanguageProvider);
    final today = todoDayKey(_now(ref));
    final start = todoDayKey(selected).subtract(const Duration(days: 3));
    final names = lang == AppLanguage.vi ? _weekdaysVi : _weekdaysEn;

    return SizedBox(
      height: 62,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final d = start.add(Duration(days: i));
          final isSelected = d == todoDayKey(selected);
          final isToday = d == today;
          return GestureDetector(
            onTap: () => ref.read(todoSelectedDateProvider.notifier).state = d,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? accent.withValues(alpha: 0.14)
                    : Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? accent
                      : Colors.white.withValues(alpha: 0.08),
                  width: isSelected ? 1.4 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.28),
                          blurRadius: 16,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    names[d.weekday - 1],
                    style: AppTextStyles.muted(size: 10).copyWith(
                      color: isSelected ? accent : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${d.day}',
                    style: AppTextStyles.heading(size: 16)
                        .copyWith(color: isSelected ? accent : null),
                  ),
                  // Cham nho danh dau HOM NAY khi dang xem ngay khac - khong
                  // dua vao mau khong thoi.
                  if (isToday && !isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 1 dong viec - mong, ngang, de quet mat.
class _TaskCard extends ConsumerWidget {
  const _TaskCard({required this.task});
  final TodoTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = task.statusAt(_now(ref));
    final (accent, label) = switch (status) {
      TodoStatus.completed => (_green, ref.tr('todo_status_completed')),
      TodoStatus.overdue => (_red, ref.tr('todo_status_overdue')),
      TodoStatus.carriedOver => (_red, ref.tr('todo_status_carried')),
      TodoStatus.incomplete => (
        AppColors.textMuted,
        ref.tr('todo_status_incomplete'),
      ),
      TodoStatus.upcoming => (AppColors.textMuted, ''),
    };
    final done = status == TodoStatus.completed;

    return GestureDetector(
      onTap: () => showTodoTaskSheet(context, ref, existing: task),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: done ? 0.02 : 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: status == TodoStatus.upcoming
                ? Colors.white.withValues(alpha: 0.08)
                : accent.withValues(alpha: done ? 0.45 : 0.55),
          ),
          boxShadow: status == TodoStatus.upcoming
              ? null
              : [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.14),
                    blurRadius: 14,
                  ),
                ],
        ),
        child: Row(
          children: [
            // Vung cham >= 44dp cho o tick.
            GestureDetector(
              onTap: () =>
                  ref.read(todoTasksProvider.notifier).toggleDone(task.id),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 46,
                height: 46,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: done ? _green : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: done
                            ? _green
                            : Colors.white.withValues(alpha: 0.35),
                        width: 2,
                      ),
                      boxShadow: done
                          ? [
                              BoxShadow(
                                color: _green.withValues(alpha: 0.5),
                                blurRadius: 14,
                              ),
                            ]
                          : null,
                    ),
                    child: done
                        ? const Icon(
                            Icons.check_rounded,
                            size: 19,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(size: 14.5).copyWith(
                      decoration: done ? TextDecoration.lineThrough : null,
                      decorationColor: AppColors.textMuted,
                      color: done ? AppColors.textMuted : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        _hhmm(task.dueAt),
                        style: AppTextStyles.muted(size: 11.5),
                      ),
                      if (label.isNotEmpty) ...[
                        Text('  ·  ', style: AppTextStyles.muted(size: 11.5)),
                        // Trang thai co CHU ro rang, khong chi dua vao mau.
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body(
                              size: 11.5,
                              weight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 26),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
    ),
    child: Text(text, style: AppTextStyles.muted(size: 12.5)),
  );
}

/// Bao cao NGAY TREN CUNG 1 MAN - khong tach trang rieng.
class _ProgressBlock extends ConsumerWidget {
  const _ProgressBlock({required this.summary});
  final TodoDaySummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = _accent(ref);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 82,
            height: 82,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: summary.ratio),
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 82,
                    height: 82,
                    child: CircularProgressIndicator(
                      value: v,
                      strokeWidth: 7,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      color: accent,
                    ),
                  ),
                  Text(
                    '${(v * 100).round()}%',
                    style: AppTextStyles.heading(size: 18),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _CountRow(
                  color: _green,
                  value: summary.completed,
                  label: ref.tr('todo_completed_n'),
                ),
                const SizedBox(height: 7),
                _CountRow(
                  color: AppColors.textMuted,
                  value: summary.remaining,
                  label: ref.tr('todo_remaining_n'),
                ),
                const SizedBox(height: 7),
                _CountRow(
                  color: _red,
                  value: summary.overdue,
                  label: ref.tr('todo_overdue_n'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountRow extends StatelessWidget {
  const _CountRow({
    required this.color,
    required this.value,
    required this.label,
  });

  final Color color;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 9),
      Text(
        '$value',
        style: AppTextStyles.body(size: 14, weight: FontWeight.w800),
      ),
      const SizedBox(width: 6),
      Expanded(child: Text(label, style: AppTextStyles.muted(size: 12))),
    ],
  );
}

/// Dai "Tuan nay" gon - 7 cot, cao theo ti le hoan thanh cua tung ngay.
class _WeekStrip extends ConsumerWidget {
  const _WeekStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = _accent(ref);
    final lang = ref.watch(appLanguageProvider);
    final week = ref.watch(todoWeekSummaryProvider);
    final names = lang == AppLanguage.vi ? _weekdaysVi : _weekdaysEn;
    final today = todoDayKey(_now(ref));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final (day, s) in week)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 22,
                  height: 46,
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: FractionallySizedBox(
                    heightFactor: s.total == 0
                        ? 0.06
                        : (0.12 + s.ratio * 0.88).clamp(0.12, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: s.total == 0
                            ? Colors.white.withValues(alpha: 0.12)
                            : (s.overdue > 0 && s.ratio < 1 ? _red : _green),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  names[day.weekday - 1],
                  style: AppTextStyles.muted(size: 9.5).copyWith(
                    color: day == today ? accent : AppColors.textMuted,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Nut + toi gian, phat sang - KHONG phai thanh dieu huong duoi.
class _AddButton extends StatelessWidget {
  const _AddButton({
    required this.onTap,
    required this.gradient,
    required this.glow,
  });
  final VoidCallback onTap;
  final Gradient gradient;
  final Color glow;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        gradient: gradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: glow.withValues(alpha: 0.5), blurRadius: 26),
        ],
      ),
      child: const Icon(Icons.add_rounded, size: 28, color: Colors.white),
    ),
  );
}

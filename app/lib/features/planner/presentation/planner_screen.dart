import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_language.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/planner_models.dart';
import 'planner_accent.dart';
import 'planner_providers.dart';
import 'planner_settings_sheet.dart';
import 'planner_task_sheet.dart';
import 'planner_timeline.dart';

// Tu dinh dang ngay/thang (KHONG dung package intl - chua co san trong
// pubspec.yaml, tranh them dependency moi chi cho 2 chuoi ngay/thang).
const _monthNamesVi = [
  'Tháng 1',
  'Tháng 2',
  'Tháng 3',
  'Tháng 4',
  'Tháng 5',
  'Tháng 6',
  'Tháng 7',
  'Tháng 8',
  'Tháng 9',
  'Tháng 10',
  'Tháng 11',
  'Tháng 12',
];
const _monthNamesEn = [
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

String _monthLabel(DateTime d, AppLanguage lang) {
  final names = lang == AppLanguage.vi ? _monthNamesVi : _monthNamesEn;
  return lang == AppLanguage.vi
      ? '${names[d.month - 1]}, ${d.year}'
      : '${names[d.month - 1]} ${d.year}';
}

String _weekdayShort(DateTime d, AppLanguage lang) =>
    (lang == AppLanguage.vi ? _weekdaysVi : _weekdaysEn)[d.weekday - 1];

/// Icon nut chuong o thanh tren cung - phai khop CHINH XAC voi 4 icon dung
/// trong _ModeCard cua planner_settings_sheet.dart de nguoi dung nhan ra
/// ngay dang o kieu nhac nao ma khong can mo cai dat.
IconData _reminderModeIcon(ReminderMode mode) => switch (mode) {
  ReminderMode.both => Icons.notifications_active_rounded,
  ReminderMode.vibrateOnly => Icons.vibration_rounded,
  ReminderMode.soundOnly => Icons.volume_up_rounded,
  ReminderMode.off => Icons.notifications_off_rounded,
};

/// Man "Lap ke hoach" chinh - mo dang POPUP (bottom sheet 94%, giong moi
/// tinh nang khac trong app qua openAppPopup, xem app_popup.dart), CHAM RA
/// NGOAI se tu dong dong vi showModalBottomSheet mac dinh la dismissible.
/// Dung chung cho ca 3 mini-app, mo tu PlannerFabOverlay hoac tile rieng
/// trong 1 mini-app.
class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key, this.autoOpenAddSheet = false});

  final bool autoOpenAddSheet;

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  final _dateScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // Moi lan mo lai man Lap ke hoach LUON quay ve hom nay, khong giu ngay
    // da xem lan truoc (yeu cau: thoat man hinh quay lai luon hien ngay
    // hien tai) - dat lai state truoc khi doc de _openAddSheet dung dung
    // ngay hom nay.
    final now = DateTime.now();
    ref.read(plannerSelectedDateProvider.notifier).state = DateTime(
      now.year,
      now.month,
      now.day,
    );
    if (widget.autoOpenAddSheet) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openAddSheet());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerDateStrip());
  }

  @override
  void dispose() {
    _dateScroll.dispose();
    super.dispose();
  }

  /// Tra ve TAT CA cac ngay trong thang cua [center] - cho phep vuot ngang
  /// het thang thay vi chi 1 cua so +-10 ngay nhu truoc (yeu cau: "nen slide
  /// ngang duoc het cac ngay trong thang").
  List<DateTime> _dateWindow(DateTime center) {
    final daysInMonth = DateTime(center.year, center.month + 1, 0).day;
    return List.generate(
      daysInMonth,
      (i) => DateTime(center.year, center.month, i + 1),
    );
  }

  /// Cong/tru [delta] thang, giu nguyen ngay trong thang neu thang moi van
  /// co ngay do, khong thi ghim ve ngay cuoi thang moi (tranh DateTime tu
  /// "tran" sang thang ke tiep khi vd ngay 31 + thang khong co ngay 31).
  DateTime _addMonths(DateTime date, int delta) {
    final total = date.year * 12 + (date.month - 1) + delta;
    final year = total ~/ 12;
    final month = total % 12 + 1;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final day = date.day > daysInMonth ? daysInMonth : date.day;
    return DateTime(year, month, day);
  }

  void _centerDateStrip() {
    if (!_dateScroll.hasClients) return;
    final selected = ref.read(plannerSelectedDateProvider);
    // Uoc luong be rong trung binh 1 pill (~46px) nhan chi so ngay dang
    // chon trong thang, tru di do lech de pill khong dinh sat mep trai.
    final estOffset = (selected.day - 1) * 46.0 - 90;
    _dateScroll.jumpTo(
      estOffset.clamp(0, _dateScroll.position.maxScrollExtent),
    );
  }

  void _openAddSheet() {
    final date = ref.read(plannerSelectedDateProvider);
    final now = TimeOfDay.now();
    final start = DateTime(
      date.year,
      date.month,
      date.day,
      now.hour,
      now.minute,
    );
    showPlannerTaskSheet(context, initialStart: start);
  }

  @override
  Widget build(BuildContext context) {
    final section = ref.watch(currentAppSectionProvider);
    final (gradient, glow) = plannerAccentFor(section);
    final selectedDate = ref.watch(plannerSelectedDateProvider);
    final reminderMode = ref.watch(plannerReminderSettingsProvider).mode;
    final tasks = ref.watch(plannerTasksForSelectedDateProvider);
    final dates = _dateWindow(selectedDate);
    // Doi thang (qua mui ten hoac reset ve hom nay) lam thay doi toan bo
    // danh sach ngay trong _dateWindow - phai cuon lai ve dung vi tri ngay
    // dang chon, khong the dua vao vi tri cuon cu.
    ref.listen<DateTime>(plannerSelectedDateProvider, (prev, next) {
      if (prev == null || prev.year != next.year || prev.month != next.month) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _centerDateStrip());
      }
    });

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A0E1C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                _CircleIconButton(
                  icon: Icons.close_rounded,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: Text(
                    ref.tr('planner_title'),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading(size: 17),
                  ),
                ),
                _CircleIconButton(
                  // Icon doi theo dung 1 trong 4 kieu nhac dang chon trong
                  // cai dat (Ca hai/Chi rung/Chi chuong/Tat) - xem
                  // _ModeCard trong planner_settings_sheet.dart.
                  icon: _reminderModeIcon(reminderMode),
                  onTap: () => showPlannerSettingsSheet(context),
                ),
                const SizedBox(width: 8),
                _CircleIconButton(
                  icon: Icons.add_rounded,
                  gradient: gradient,
                  onTap: _openAddSheet,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MonthChevron(
                  icon: Icons.chevron_left_rounded,
                  onTap: () =>
                      ref.read(plannerSelectedDateProvider.notifier).state =
                          _addMonths(selectedDate, -1),
                ),
                const SizedBox(width: 8),
                Text(
                  _monthLabel(selectedDate, ref.watch(appLanguageProvider)),
                  style: AppTextStyles.body(size: 14, weight: FontWeight.w700),
                ),
                const SizedBox(width: 8),
                _MonthChevron(
                  icon: Icons.chevron_right_rounded,
                  color: glow,
                  onTap: () =>
                      ref.read(plannerSelectedDateProvider.notifier).state =
                          _addMonths(selectedDate, 1),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 78,
            child: ListView.builder(
              controller: _dateScroll,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: dates.length,
              itemBuilder: (context, i) {
                final d = dates[i];
                final isSelected =
                    d.year == selectedDate.year &&
                    d.month == selectedDate.month &&
                    d.day == selectedDate.day;
                final dist = (d.day - selectedDate.day).abs();
                return _DatePill(
                  date: d,
                  selected: isSelected,
                  distance: dist,
                  gradient: gradient,
                  glow: glow,
                  onTap: () =>
                      ref.read(plannerSelectedDateProvider.notifier).state =
                          DateTime(d.year, d.month, d.day),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [
                for (final st in PlannerTaskStatus.values)
                  _LegendItem(status: st),
              ],
            ),
          ),
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                ref.tr('planner_empty_day'),
                style: AppTextStyles.muted(size: 10.5),
              ),
            ),
          const SizedBox(height: 4),
          // LUON hien timeline 24 gio (ke ca ngay chua co viec nao) - moi
          // hang gio trong deu bam duoc de tao viec ngay (xem
          // planner_timeline.dart) thay vi thay the ca timeline bang 1 dong
          // chu "chua co viec" khien nguoi dung phai doi ngay khac moi tao
          // duoc ke hoach.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: PlannerTimeline(
                date: selectedDate,
                tasks: tasks,
                onAddAt: (hourStart) =>
                    showPlannerTaskSheet(context, initialStart: hourStart),
                onEditTask: (task) => showPlannerTaskSheet(
                  context,
                  initialStart: task.start,
                  editing: task,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.gradient,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: gradient,
          color: gradient == null ? AppColors.glassFill : null,
          border: gradient == null
              ? Border.all(color: AppColors.glassBorder)
              : null,
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}

class _MonthChevron extends StatelessWidget {
  const _MonthChevron({required this.icon, required this.onTap, this.color});

  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 20, color: color ?? AppColors.textMuted),
    );
  }
}

class _DatePill extends ConsumerWidget {
  const _DatePill({
    required this.date,
    required this.selected,
    required this.distance,
    required this.gradient,
    required this.glow,
    required this.onTap,
  });

  final DateTime date;
  final bool selected;
  final int distance;
  final Gradient gradient;
  final Color glow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appLanguageProvider);
    final width = selected ? 54.0 : (distance <= 2 ? 42.0 : 34.0);
    final opacity = selected ? 1.0 : (distance <= 2 ? 0.75 : 0.4);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(vertical: selected ? 12 : 9),
        decoration: BoxDecoration(
          gradient: selected ? gradient : null,
          color: selected ? null : AppColors.glassFill,
          borderRadius: BorderRadius.circular(16),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: glow.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Opacity(
          opacity: opacity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _weekdayShort(date, lang),
                style: TextStyle(
                  fontSize: selected ? 10 : 9,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? Colors.white.withValues(alpha: 0.8)
                      : AppColors.textMuted,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: selected ? 17 : 13,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : AppColors.textPrimary,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends ConsumerWidget {
  const _LegendItem({required this.status});

  final PlannerTaskStatus status;

  String get _key => switch (status) {
    PlannerTaskStatus.completed => 'planner_status_completed',
    PlannerTaskStatus.running => 'planner_status_running',
    PlannerTaskStatus.rejected => 'planner_status_rejected',
    PlannerTaskStatus.upcoming => 'planner_status_upcoming',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: status.color,
          ),
        ),
        const SizedBox(width: 5),
        Text(ref.tr(_key), style: AppTextStyles.muted(size: 10)),
      ],
    );
  }
}

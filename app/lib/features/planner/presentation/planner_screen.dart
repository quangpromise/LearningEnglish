import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_language.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/navigation/nav_keys.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/planner_models.dart';
import '../data/planner_notification_service.dart';
import 'planner_accent.dart';
import 'planner_overdue_sheet.dart';
import 'planner_providers.dart';
import 'planner_settings_sheet.dart';
import 'planner_task_sheet.dart';
import 'planner_timeline.dart';
import 'planner_undo.dart';

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

/// Bam thong bao nhac viec (payload `planner:<taskId>|<yyyy-MM-dd>`, xem
/// PlannerNotificationService) -> mo man Lap ke hoach dung ngay cua viec.
void openPlannerFromNotification(String payload) {
  final parts = payload
      .substring(PlannerNotificationService.payloadPrefix.length)
      .split('|');
  final date = parts.length > 1 ? DateTime.tryParse(parts[1]) : null;
  final navContext = rootNavigatorKey.currentContext;
  if (navContext == null) return;
  openAppPopup(navContext, PlannerScreen(initialDate: date));
}

/// Man "Lap ke hoach" chinh - mo dang POPUP (bottom sheet 94%, giong moi
/// tinh nang khac trong app qua openAppPopup, xem app_popup.dart), CHAM RA
/// NGOAI se tu dong dong vi showModalBottomSheet mac dinh la dismissible.
/// Dung chung cho ca 3 mini-app, mo tu PlannerFabOverlay, tile rieng trong
/// 1 mini-app, hoac bam thong bao nhac viec ([initialDate] = ngay cua viec).
class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({
    super.key,
    this.autoOpenAddSheet = false,
    this.initialDate,
  });

  final bool autoOpenAddSheet;
  final DateTime? initialDate;

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  final _dateScroll = ScrollController();

  /// ScaffoldMessenger RIENG cua popup - snackbar "Hoan tac" phai hien BEN
  /// TRONG sheet, neu dung messenger goc no se nam khuat sau sheet 94%.
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    // Moi lan mo lai man Lap ke hoach LUON quay ve hom nay (hoac ngay cua
    // thong bao vua bam), khong giu ngay da xem lan truoc - dat lai state
    // truoc khi doc de _openAddSheet dung dung ngay.
    final d = widget.initialDate ?? DateTime.now();
    ref.read(plannerSelectedDateProvider.notifier).state = DateTime(
      d.year,
      d.month,
      d.day,
    );
    if (widget.autoOpenAddSheet) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openAddSheet());
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _centerDateStrip(animate: false),
    );
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

  void _centerDateStrip({bool animate = true}) {
    if (!_dateScroll.hasClients) return;
    final selected = ref.read(plannerSelectedDateProvider);
    // Uoc luong be rong trung binh 1 pill (~46px) nhan chi so ngay dang
    // chon trong thang, tru di do lech de pill khong dinh sat mep trai.
    final estOffset = ((selected.day - 1) * 46.0 - 90).clamp(
      0.0,
      _dateScroll.position.maxScrollExtent,
    );
    if (animate) {
      _dateScroll.animateTo(
        estOffset,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _dateScroll.jumpTo(estOffset);
    }
  }

  void _selectDate(DateTime d) =>
      ref.read(plannerSelectedDateProvider.notifier).state = plannerDateOnly(d);

  void _openAddSheet() {
    final date = ref.read(plannerSelectedDateProvider);
    final now = TimeOfDay.now();
    showPlannerTaskSheet(
      context,
      initialStart: DateTime(
        date.year,
        date.month,
        date.day,
        now.hour,
        now.minute,
      ),
      messenger: _messengerKey.currentState,
    );
  }

  void _openEdit(PlannerOccurrence occ) => showPlannerTaskSheet(
    context,
    initialStart: occ.start,
    editing: occ.task,
    occurrence: occ,
    messenger: _messengerKey.currentState,
  );

  /// Chay [action] roi hien snackbar co nut "Hoan tac" tra ve dung trang
  /// thai truoc do (docs/research-planner-app-ux.md §7.3 muc 1).
  Future<void> _withUndo(String messageKey, Future<void> Function() action) =>
      runPlannerActionWithUndo(
        ref: ref,
        messenger: _messengerKey.currentState,
        messageKey: messageKey,
        action: action,
      );

  @override
  Widget build(BuildContext context) {
    final section = ref.watch(currentAppSectionProvider);
    final (gradient, glow) = plannerAccentFor(section);
    final selectedDate = ref.watch(plannerSelectedDateProvider);
    final reminderMode = ref.watch(plannerReminderSettingsProvider).mode;
    final lang = ref.watch(appLanguageProvider);
    final filter = ref.watch(plannerSectionFilterProvider);
    final inbox = ref.watch(plannerInboxProvider);
    final overdue = ref.watch(plannerOverdueProvider);
    final notifier = ref.read(plannerTasksProvider.notifier);
    final dates = _dateWindow(selectedDate);
    final today = plannerDateOnly(DateTime.now());
    // Doi ngay (qua date-strip, vuot timeline, mui ten thang) - cuon
    // date-strip de pill dang chon luon nam trong tam nhin.
    ref.listen<DateTime>(plannerSelectedDateProvider, (prev, next) {
      final monthChanged =
          prev == null || prev.year != next.year || prev.month != next.month;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _centerDateStrip(animate: !monthChanged),
      );
    });

    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _MonthChevron(
                      icon: Icons.chevron_left_rounded,
                      onTap: () => _selectDate(_addMonths(selectedDate, -1)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _monthLabel(selectedDate, lang),
                      style: AppTextStyles.body(
                        size: 14,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _MonthChevron(
                      icon: Icons.chevron_right_rounded,
                      color: glow,
                      onTap: () => _selectDate(_addMonths(selectedDate, 1)),
                    ),
                    if (selectedDate != today) ...[
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _selectDate(today),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: glow.withValues(alpha: 0.7),
                            ),
                          ),
                          child: Text(
                            ref.tr('planner_today'),
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: glow,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                    return _DatePill(
                      date: d,
                      selected: d == selectedDate,
                      // Pill cua 3 ngay dang hien tren timeline (ngay chon
                      // +-1) to hon + sang hon cac ngay khac.
                      distance: (d.difference(selectedDate).inHours / 24)
                          .round()
                          .abs(),
                      hasTasks: ref
                          .watch(plannerOccurrencesForDayProvider(d))
                          .isNotEmpty,
                      gradient: gradient,
                      glow: glow,
                      onTap: () => _selectDate(d),
                    );
                  },
                ),
              ),
              _FilterRow(
                filter: filter,
                onChanged: (f) =>
                    ref.read(plannerSectionFilterProvider.notifier).state = f,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 2, 20, 4),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    for (final st in PlannerTaskStatus.values)
                      _LegendItem(status: st),
                  ],
                ),
              ),
              if (overdue.isNotEmpty)
                _OverdueBanner(
                  count: overdue.length,
                  onTap: () => showPlannerOverdueSheet(
                    context,
                    messenger: _messengerKey.currentState,
                  ),
                ),
              if (inbox.isNotEmpty)
                _InboxStrip(
                  tasks: inbox,
                  onTap: (t) => showPlannerTaskSheet(
                    context,
                    initialStart: t.start,
                    editing: t,
                    messenger: _messengerKey.currentState,
                  ),
                ),
              const SizedBox(height: 2),
              // LUON hien timeline 24 gio (ke ca ngay chua co viec nao) - moi
              // o gio deu bam duoc de tao viec ngay (xem planner_timeline.dart).
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                  child: PlannerTimeline(
                    selectedDate: selectedDate,
                    onDateChanged: _selectDate,
                    gradient: gradient,
                    glow: glow,
                    dayLabel: (d) => _weekdayShort(d, lang),
                    onAddAt: (hourStart) => showPlannerTaskSheet(
                      context,
                      initialStart: hourStart,
                      messenger: _messengerKey.currentState,
                    ),
                    onEditOccurrence: _openEdit,
                    onToggleDone: (occ) => _withUndo(
                      occ.isDone
                          ? 'planner_undone_toast'
                          : 'planner_done_toast',
                      () => notifier.toggleDone(occ),
                    ),
                    onDropOccurrence: (occ, start) => _withUndo(
                      'planner_moved_toast',
                      () => notifier.moveOccurrence(occ, start),
                    ),
                    onDropInboxTask: (task, start) => _withUndo(
                      'planner_scheduled_toast',
                      () => notifier.scheduleFromInbox(task, start),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chip loc theo mini-app (provider loc da co tu truoc nhung chua co UI nao
/// ghi vao - docs/research-planner-app-ux.md §7.5 muc 8).
class _FilterRow extends ConsumerWidget {
  const _FilterRow({required this.filter, required this.onChanged});

  final Set<AppSection>? filter;
  final ValueChanged<Set<AppSection>?> onChanged;

  String _key(AppSection s) => switch (s) {
    AppSection.learnEnglish => 'planner_app_english',
    AppSection.fitness => 'planner_app_fitness',
    AppSection.wealth => 'planner_app_wealth',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget chip({
      required String label,
      required bool selected,
      required Color tint,
      IconData? icon,
      required VoidCallback onTap,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: selected
                ? tint.withValues(alpha: 0.18)
                : AppColors.glassFill,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? tint : AppColors.glassBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 12,
                  color: selected ? tint : AppColors.textMuted,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: selected ? tint : AppColors.textMuted,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
        children: [
          chip(
            label: ref.tr('planner_filter_all'),
            selected: filter == null,
            tint: Colors.white,
            onTap: () => onChanged(null),
          ),
          for (final s in AppSection.values)
            chip(
              label: ref.tr(_key(s)),
              icon: plannerSectionIcon(s),
              selected: filter?.contains(s) ?? false,
              tint: plannerSectionTint(s),
              onTap: () {
                final next = {...?filter};
                if (!next.remove(s)) next.add(s);
                onChanged(next.isEmpty ? null : next);
              },
            ),
        ],
      ),
    );
  }
}

class _OverdueBanner extends ConsumerWidget {
  const _OverdueBanner({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const color = Color(0xFFFFB547);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 2, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.45)),
        ),
        child: Row(
          children: [
            const Icon(Icons.history_rounded, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ref.tr('planner_overdue_banner').replaceAll('{n}', '$count'),
                style: AppTextStyles.body(size: 11.5, weight: FontWeight.w700),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: color),
          ],
        ),
      ),
    );
  }
}

/// Hang "Chua xep gio" (Inbox) - nhan giu 1 chip roi keo tha vao o gio bat
/// ky tren timeline de xep lich (tai dung DragTarget cua timeline).
class _InboxStrip extends ConsumerWidget {
  const _InboxStrip({required this.tasks, required this.onTap});

  final List<PlannerTask> tasks;
  final ValueChanged<PlannerTask> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget chip(PlannerTask t, {bool dragging = false}) {
      final tint = t.icon != PlannerTaskIcon.none
          ? t.icon.color
          : plannerSectionTint(t.appSection);
      return Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: dragging ? const Color(0xFF1A2040) : AppColors.glassFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tint.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              t.icon != PlannerTaskIcon.none
                  ? t.icon.iconData
                  : plannerSectionIcon(t.appSection),
              size: 12,
              color: tint,
            ),
            const SizedBox(width: 5),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 130),
              child: Text(
                t.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body(size: 11, weight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 0, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${ref.tr('planner_inbox_title')} · ${ref.tr('planner_inbox_hint')}',
            style: AppTextStyles.muted(size: 9.5, weight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 30,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final t in tasks)
                  LongPressDraggable<PlannerDragPayload>(
                    data: PlannerDragPayload.inbox(t),
                    feedback: Material(
                      color: Colors.transparent,
                      child: chip(t, dragging: true),
                    ),
                    childWhenDragging: Opacity(opacity: 0.3, child: chip(t)),
                    child: GestureDetector(
                      onTap: () => onTap(t),
                      child: chip(t),
                    ),
                  ),
              ],
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
    required this.hasTasks,
    required this.gradient,
    required this.glow,
    required this.onTap,
  });

  final DateTime date;
  final bool selected;
  final int distance;

  /// Cham nho duoi so ngay = ngay do co viec (§7.3 viec nho di kem).
  final bool hasTasks;
  final Gradient gradient;
  final Color glow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appLanguageProvider);
    // distance <= 1: 2 ngay ben canh cung dang hien tren timeline 3 cot.
    final width = selected ? 54.0 : (distance <= 1 ? 44.0 : 34.0);
    final opacity = selected ? 1.0 : (distance <= 1 ? 0.85 : 0.4);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(vertical: selected ? 9 : 7),
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
              const SizedBox(height: 3),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasTasks
                      ? (selected ? Colors.white : glow)
                      : Colors.transparent,
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
        const SizedBox(width: 4),
        Text(ref.tr(status.labelKey), style: AppTextStyles.muted(size: 9.5)),
      ],
    );
  }
}

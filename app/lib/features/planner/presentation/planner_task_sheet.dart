import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/planner_models.dart';
import '../data/planner_notification_service.dart';
import 'planner_accent.dart';
import 'planner_links.dart';
import 'planner_providers.dart';
import 'planner_undo.dart';

/// Bottom sheet them/sua 1 viec - mo tu nut "+", bam 1 o gio tren timeline,
/// bam 1 card (kem [occurrence] = lan xuat hien cu the, can cho viec lap lai)
/// hoac bam 1 chip trong hang "Chua xep gio".
///
/// [messenger] = ScaffoldMessenger cua man Lap ke hoach de hien snackbar
/// "Hoan tac" sau khi xoa/nhan ban (sheet nay da dong luc do).
Future<void> showPlannerTaskSheet(
  BuildContext context, {
  required DateTime initialStart,
  PlannerTask? editing,
  PlannerOccurrence? occurrence,
  ScaffoldMessengerState? messenger,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _PlannerTaskSheet(
      initialStart: initialStart,
      editing: editing,
      occurrence: occurrence,
      messenger: messenger,
    ),
  );
}

const _weekdayKeysVi = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

class _PlannerTaskSheet extends ConsumerStatefulWidget {
  const _PlannerTaskSheet({
    required this.initialStart,
    this.editing,
    this.occurrence,
    this.messenger,
  });

  final DateTime initialStart;
  final PlannerTask? editing;
  final PlannerOccurrence? occurrence;
  final ScaffoldMessengerState? messenger;

  @override
  ConsumerState<_PlannerTaskSheet> createState() => _PlannerTaskSheetState();
}

class _PlannerTaskSheetState extends ConsumerState<_PlannerTaskSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _notesCtrl;
  final _subtaskCtrl = TextEditingController();
  late List<PlannerSubtask> _subtasks;

  /// Cac buoc da tick cua lan xuat hien dang sua.
  late Set<String> _checked;
  late AppSection _section;
  late DateTime _date;
  late TimeOfDay _start;
  late TimeOfDay _end;
  late bool _reminder;
  late PlannerTaskIcon _icon;
  late bool _inbox;

  /// null = khong lap.
  PlannerRepeatFreq? _freq;
  late Set<int> _weekdays;
  DateTime? _until;

  /// null = theo cai dat chung.
  List<int>? _offsets;

  /// Trang thai chot cho lan xuat hien dang sua (null = Tu dong theo gio).
  PlannerTaskStatus? _settled;
  PlannerTaskStatus? _initialSettled;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _section = e?.appSection ?? ref.read(currentAppSectionProvider);
    _date = plannerDateOnly(e?.start ?? widget.initialStart);
    _start = TimeOfDay.fromDateTime(e?.start ?? widget.initialStart);
    _end = TimeOfDay.fromDateTime(
      e?.end ?? widget.initialStart.add(const Duration(minutes: 30)),
    );
    _reminder = e?.reminderEnabled ?? false;
    _icon = e?.icon ?? PlannerTaskIcon.none;
    _inbox = e?.inbox ?? false;
    _freq = e?.recurrence?.freq;
    _weekdays = {...?e?.recurrence?.weekdays};
    if (_weekdays.isEmpty) _weekdays = {_date.weekday};
    _until = e?.recurrence?.until;
    _offsets = e?.reminderOffsets == null ? null : [...e!.reminderOffsets!];
    _initialSettled =
        widget.occurrence?.settledStatus ??
        (e != null && !e.isRecurring
            ? e.occurrenceOn(e.start).settledStatus
            : null);
    _settled = _initialSettled;
    _subtasks = [...?e?.subtasks];
    final dayKey =
        widget.occurrence?.dayKey ??
        (e == null ? null : plannerDayKey(e.start));
    _checked = {...?e?.subtaskDone[dayKey]};
  }

  void _addSubtask() {
    final title = _subtaskCtrl.text.trim();
    if (title.isEmpty) return;
    setState(() {
      _subtasks.add(
        PlannerSubtask(
          id: '${DateTime.now().microsecondsSinceEpoch}',
          title: title,
        ),
      );
      _subtaskCtrl.clear();
    });
  }

  /// Luu trang thai tick cua checklist vao dung ngay cua lan xuat hien.
  Map<String, Set<String>> _subtaskDoneFor(DateTime start) {
    final key = widget.occurrence?.dayKey ?? plannerDayKey(start);
    final ids = _subtasks.map((s) => s.id).toSet();
    final all = {...?widget.editing?.subtaskDone};
    final checked = _checked.intersection(ids);
    if (checked.isEmpty) {
      all.remove(key);
    } else {
      all[key] = checked;
    }
    return all;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    _subtaskCtrl.dispose();
    super.dispose();
  }

  DateTime _combine(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  bool get _overnight =>
      _end.hour * 60 + _end.minute <= _start.hour * 60 + _start.minute;

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  Future<void> _pickDate({bool until = false}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: until ? (_until ?? _date) : _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (until) {
        _until = picked;
      } else {
        _date = picked;
      }
    });
  }

  PlannerRecurrence? _recurrence() => _freq == null
      ? null
      : PlannerRecurrence(
          freq: _freq!,
          weekdays: _freq == PlannerRepeatFreq.weekly
              ? (_weekdays.toList()..sort())
              : const [],
          until: _until,
        );

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    final start = _combine(_date, _start);
    var end = _combine(_date, _end);
    // Gio ket thuc <= gio bat dau = viec qua nua dem (vd Ngu 23:00-06:30).
    if (!end.isAfter(start)) end = end.add(const Duration(days: 1));
    final recurrence = _recurrence();
    final notifier = ref.read(plannerTasksProvider.notifier);
    final editing = widget.editing;
    final nav = Navigator.of(context);

    if (editing != null) {
      var updated = editing.copyWith(
        title: title,
        appSection: _section,
        start: start,
        end: end,
        reminderEnabled: _reminder,
        icon: _icon,
        notes: _notesCtrl.text.trim(),
        recurrence: recurrence,
        clearRecurrence: recurrence == null,
        reminderOffsets: _offsets,
        clearReminderOffsets: _offsets == null,
        inbox: _inbox,
        subtasks: _subtasks,
        subtaskDone: _subtaskDoneFor(start),
      );
      if (!updated.isRecurring) {
        updated = updated.copyWith(
          status: _settled ?? PlannerTaskStatus.upcoming,
        );
      }
      await notifier.update(updated);
      final occ = widget.occurrence;
      if (updated.isRecurring &&
          occ != null &&
          _settled != _initialSettled &&
          updated.occursOn(occ.day)) {
        await notifier.settle(updated.occurrenceOn(occ.day), _settled);
      }
    } else {
      await notifier.add(
        PlannerTask(
          id: '${DateTime.now().microsecondsSinceEpoch}',
          title: title,
          appSection: _section,
          start: start,
          end: end,
          status: recurrence == null
              ? (_settled ?? PlannerTaskStatus.upcoming)
              : PlannerTaskStatus.upcoming,
          reminderEnabled: _reminder,
          icon: _icon,
          notes: _notesCtrl.text.trim(),
          recurrence: recurrence,
          reminderOffsets: _offsets,
          inbox: _inbox,
          subtasks: _subtasks,
          subtaskDone: _subtaskDoneFor(start),
        ),
      );
    }
    nav.maybePop();
  }

  Future<void> _delete() async {
    final editing = widget.editing;
    if (editing == null) return;
    final occ = widget.occurrence ?? editing.occurrenceOn(editing.start);
    var wholeSeries = true;
    if (editing.isRecurring && widget.occurrence != null) {
      final choice = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF151A30),
          title: Text(
            ref.tr('planner_delete_recurring_title'),
            style: AppTextStyles.heading(size: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(ref.tr('planner_cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(ref.tr('planner_delete_this')),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                ref.tr('planner_delete_all'),
                style: const TextStyle(color: Color(0xFFFF6B9D)),
              ),
            ),
          ],
        ),
      );
      if (choice == null) return;
      wholeSeries = choice;
    }
    if (!mounted) return;
    final notifier = ref.read(plannerTasksProvider.notifier);
    Navigator.of(context).maybePop();
    await runPlannerActionWithUndo(
      ref: ref,
      messenger: widget.messenger,
      messageKey: 'planner_deleted_toast',
      action: () => notifier.deleteOccurrence(occ, wholeSeries: wholeSeries),
    );
  }

  Future<void> _duplicate() async {
    final editing = widget.editing;
    if (editing == null) return;
    final notifier = ref.read(plannerTasksProvider.notifier);
    final base = widget.occurrence;
    Navigator.of(context).maybePop();
    await runPlannerActionWithUndo(
      ref: ref,
      messenger: widget.messenger,
      messageKey: 'planner_duplicated_toast',
      action: () => notifier.add(
        PlannerTask(
          id: '${DateTime.now().microsecondsSinceEpoch}',
          title: editing.title,
          appSection: editing.appSection,
          start: base?.start ?? editing.start,
          end: base?.end ?? editing.end,
          reminderEnabled: editing.reminderEnabled,
          icon: editing.icon,
          notes: editing.notes,
          reminderOffsets: editing.reminderOffsets,
          inbox: editing.inbox,
        ),
      ),
    );
  }

  Widget _label(String key) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      ref.tr(key),
      style: AppTextStyles.muted(size: 11, weight: FontWeight.w800),
    ),
  );

  String _offsetLabel(int m) => switch (m) {
    0 => ref.tr('planner_offset_on_time'),
    60 => ref.tr('planner_offset_hour'),
    1440 => ref.tr('planner_offset_day'),
    _ => ref.tr('planner_offset_minutes').replaceAll('{n}', '$m'),
  };

  String _dateLabel(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final (gradient, glow) = plannerAccentFor(_section);
    final isEditing = widget.editing != null;
    final occ = widget.occurrence;
    final showSeriesNote =
        isEditing && widget.editing!.isRecurring && occ != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: Color(0xEB0F1326),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ref.tr(
                        isEditing ? 'planner_edit_title' : 'planner_add_title',
                      ),
                      style: AppTextStyles.heading(size: 18),
                    ),
                  ),
                  // Viec do mini-app tao -> mo thang man goc (buoi tap, on
                  // tu, gia han dich vu) - xem planner_links.dart.
                  if (plannerSourceOpenerFor(widget.editing?.source)
                      case final open?)
                    TextButton.icon(
                      onPressed: () {
                        final source = widget.editing!.source!;
                        Navigator.of(context).maybePop();
                        open(source);
                      },
                      icon: Icon(
                        Icons.open_in_new_rounded,
                        size: 16,
                        color: glow,
                      ),
                      label: Text(
                        ref.tr('planner_open_source'),
                        style: TextStyle(
                          color: glow,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleCtrl,
                autofocus: !isEditing,
                style: AppTextStyles.body(),
                decoration: _inputDecoration(ref.tr('planner_task_title_hint')),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (final s in AppSection.values) ...[
                    if (s != AppSection.values.first) const SizedBox(width: 8),
                    Expanded(
                      child: _SectionChip(
                        section: s,
                        selected: _section == s,
                        onTap: () => setState(() => _section = s),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              _label('planner_task_icon_label'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final ic in PlannerTaskIcon.values)
                    _TaskIconChip(
                      taskIcon: ic,
                      selected: _icon == ic,
                      onTap: () => setState(() => _icon = ic),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _inbox,
                onChanged: (v) => setState(() => _inbox = v),
                activeThumbColor: glow,
                title: Text(
                  ref.tr('planner_save_to_inbox'),
                  style: AppTextStyles.body(
                    size: 12.5,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
              if (!_inbox) ...[
                const SizedBox(height: 4),
                _Field(
                  label: ref.tr('planner_date'),
                  value: _dateLabel(_date),
                  onTap: () => _pickDate(),
                ),
                const SizedBox(height: 10),
              ],
              Row(
                children: [
                  Expanded(
                    child: _Field(
                      label: ref.tr('planner_start_time'),
                      value: _start.format(context),
                      onTap: () => _pickTime(true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Field(
                      label: ref.tr('planner_end_time'),
                      value: _end.format(context),
                      hint: _overnight
                          ? ref.tr('planner_overnight_hint')
                          : null,
                      onTap: () => _pickTime(false),
                    ),
                  ),
                ],
              ),
              if (!_inbox) ...[
                const SizedBox(height: 16),
                _label('planner_repeat_label'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Pill(
                      label: ref.tr('planner_repeat_none'),
                      selected: _freq == null,
                      color: glow,
                      onTap: () => setState(() => _freq = null),
                    ),
                    for (final f in PlannerRepeatFreq.values)
                      _Pill(
                        label: ref.tr(switch (f) {
                          PlannerRepeatFreq.daily => 'planner_repeat_daily',
                          PlannerRepeatFreq.weekly => 'planner_repeat_weekly',
                          PlannerRepeatFreq.monthly => 'planner_repeat_monthly',
                        }),
                        selected: _freq == f,
                        color: glow,
                        onTap: () => setState(() => _freq = f),
                      ),
                  ],
                ),
                if (_freq == PlannerRepeatFreq.weekly) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (var wd = 1; wd <= 7; wd++) ...[
                        if (wd > 1) const SizedBox(width: 5),
                        Expanded(
                          child: _WeekdayChip(
                            label: _weekdayKeysVi[wd - 1],
                            selected: _weekdays.contains(wd),
                            color: glow,
                            onTap: () => setState(() {
                              if (_weekdays.contains(wd)) {
                                if (_weekdays.length > 1) _weekdays.remove(wd);
                              } else {
                                _weekdays.add(wd);
                              }
                            }),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                if (_freq != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          label: ref.tr('planner_repeat_until'),
                          value: _until == null
                              ? ref.tr('planner_repeat_forever')
                              : _dateLabel(_until!),
                          onTap: () => _pickDate(until: true),
                        ),
                      ),
                      if (_until != null)
                        IconButton(
                          onPressed: () => setState(() => _until = null),
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                _label('planner_status_label'),
                if (showSeriesNote)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      ref
                          .tr('planner_edit_series_note')
                          .replaceAll('{d}', _dateLabel(occ.day)),
                      style: AppTextStyles.muted(size: 10.5),
                    ),
                  ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Pill(
                      label: ref.tr('planner_status_auto'),
                      selected: _settled == null,
                      color: PlannerTaskStatus.upcoming.color,
                      onTap: () => setState(() => _settled = null),
                    ),
                    for (final st in [
                      PlannerTaskStatus.completed,
                      PlannerTaskStatus.rejected,
                    ])
                      _Pill(
                        label: ref.tr(st.labelKey),
                        selected: _settled == st,
                        color: st.color,
                        onTap: () => setState(() => _settled = st),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _reminder,
                  onChanged: (v) => setState(() => _reminder = v),
                  activeThumbColor: glow,
                  title: Text(
                    ref.tr('planner_reminder_toggle'),
                    style: AppTextStyles.body(
                      size: 13,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
                if (_reminder) ...[
                  if (!PlannerNotificationService.isSupported)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        ref.tr('planner_reminder_web_notice'),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFFFB547),
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  _label('planner_reminder_offset_label'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Pill(
                        label: ref.tr('planner_reminder_follow_settings'),
                        selected: _offsets == null,
                        color: glow,
                        onTap: () => setState(() => _offsets = null),
                      ),
                      // Chon toi da 3 moc (vd truoc 1 ngay + truoc 15 phut).
                      for (final m in plannerReminderOffsetChoices)
                        _Pill(
                          label: _offsetLabel(m),
                          selected: _offsets?.contains(m) ?? false,
                          color: glow,
                          onTap: () => setState(() {
                            final next = [...?_offsets];
                            if (next.contains(m)) {
                              next.remove(m);
                            } else if (next.length < 3) {
                              next.add(m);
                            }
                            _offsets = next.isEmpty ? null : (next..sort());
                          }),
                        ),
                    ],
                  ),
                ],
              ],
              const SizedBox(height: 14),
              _label('planner_checklist_label'),
              for (final st in _subtasks)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() {
                          if (!_checked.remove(st.id)) _checked.add(st.id);
                        }),
                        child: Icon(
                          _checked.contains(st.id)
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank_rounded,
                          size: 22,
                          color: _checked.contains(st.id)
                              ? PlannerTaskStatus.completed.color
                              : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          st.title,
                          style: AppTextStyles.body(size: 13).copyWith(
                            decoration: _checked.contains(st.id)
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() {
                          _subtasks.remove(st);
                          _checked.remove(st.id);
                        }),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subtaskCtrl,
                      style: AppTextStyles.body(size: 13),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addSubtask(),
                      decoration: _inputDecoration(
                        ref.tr('planner_checklist_hint'),
                      ).copyWith(isDense: true),
                    ),
                  ),
                  IconButton(
                    onPressed: _addSubtask,
                    icon: Icon(Icons.add_circle_rounded, color: glow),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _notesCtrl,
                minLines: 2,
                maxLines: 5,
                style: AppTextStyles.body(size: 13),
                decoration: _inputDecoration(ref.tr('planner_notes_hint')),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (isEditing) ...[
                    _IconAction(
                      icon: Icons.delete_outline_rounded,
                      color: const Color(0xFFFF6B9D),
                      tooltip: ref.tr('planner_delete'),
                      onTap: _delete,
                    ),
                    const SizedBox(width: 8),
                    _IconAction(
                      icon: Icons.copy_rounded,
                      color: AppColors.textMuted,
                      tooltip: ref.tr('planner_duplicate'),
                      onTap: _duplicate,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: PillButton(
                      label: ref.tr('planner_save'),
                      accentGradient: gradient,
                      accentColor: glow,
                      onTap: _save,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.muted(),
    filled: true,
    fillColor: AppColors.glassFill,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: AppColors.glassBorder),
    ),
  );
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.7)),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}

class _SectionChip extends StatelessWidget {
  const _SectionChip({
    required this.section,
    required this.selected,
    required this.onTap,
  });

  final AppSection section;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = plannerSectionTint(section);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? tint.withValues(alpha: 0.18) : AppColors.glassFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? tint : AppColors.glassBorder),
        ),
        child: Icon(
          plannerSectionIcon(section),
          size: 18,
          color: selected ? tint : AppColors.textMuted,
        ),
      ),
    );
  }
}

class _TaskIconChip extends ConsumerWidget {
  const _TaskIconChip({
    required this.taskIcon,
    required this.selected,
    required this.onTap,
  });

  final PlannerTaskIcon taskIcon;
  final bool selected;
  final VoidCallback onTap;

  String get _key => switch (taskIcon) {
    PlannerTaskIcon.none => 'planner_task_icon_none',
    PlannerTaskIcon.work => 'planner_task_icon_work',
    PlannerTaskIcon.game => 'planner_task_icon_game',
    PlannerTaskIcon.relax => 'planner_task_icon_relax',
    PlannerTaskIcon.study => 'planner_task_icon_study',
    PlannerTaskIcon.sleep => 'planner_task_icon_sleep',
    PlannerTaskIcon.other => 'planner_task_icon_other',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // "Khong" (none) dung mau xam trung tinh - cac icon con lai dung dung
    // mau rieng cua PlannerTaskIcon de nguoi dung nhan dien nhanh.
    final tint = taskIcon == PlannerTaskIcon.none
        ? AppColors.textMuted
        : taskIcon.color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? tint.withValues(alpha: 0.18) : AppColors.glassFill,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? tint : AppColors.glassBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (taskIcon != PlannerTaskIcon.none) ...[
              Icon(
                taskIcon.iconData,
                size: 14,
                color: selected ? tint : AppColors.textMuted,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              ref.tr(_key),
              style: TextStyle(
                fontSize: 11.5,
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
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.value,
    required this.onTap,
    this.hint,
  });

  final String label;
  final String value;
  final String? hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTextStyles.muted(size: 10)),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTextStyles.body(size: 15, weight: FontWeight.w800),
            ),
            if (hint != null)
              Text(
                hint!,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFFFFB547),
                  decoration: TextDecoration.none,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.18) : AppColors.glassFill,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? color : AppColors.glassBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: selected ? color : AppColors.textMuted,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

class _WeekdayChip extends StatelessWidget {
  const _WeekdayChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.22) : AppColors.glassFill,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? color : AppColors.glassBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: selected ? color : AppColors.textMuted,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

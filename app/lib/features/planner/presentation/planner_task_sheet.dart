import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/planner_models.dart';
import 'planner_accent.dart';
import 'planner_providers.dart';

/// Bottom sheet them/sua 1 viec - mo tu FAB "Them viec" hoac bam vao 1 hang
/// gio trong hoac 1 the viec da co trong planner_timeline.dart.
Future<void> showPlannerTaskSheet(
  BuildContext context, {
  required DateTime initialStart,
  PlannerTask? editing,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) =>
        _PlannerTaskSheet(initialStart: initialStart, editing: editing),
  );
}

class _PlannerTaskSheet extends ConsumerStatefulWidget {
  const _PlannerTaskSheet({required this.initialStart, this.editing});

  final DateTime initialStart;
  final PlannerTask? editing;

  @override
  ConsumerState<_PlannerTaskSheet> createState() => _PlannerTaskSheetState();
}

class _PlannerTaskSheetState extends ConsumerState<_PlannerTaskSheet> {
  late final TextEditingController _titleCtrl;
  late AppSection _section;
  late TimeOfDay _start;
  late TimeOfDay _end;
  late PlannerTaskStatus _status;
  late bool _reminder;

  @override
  void initState() {
    super.initState();
    final editing = widget.editing;
    _titleCtrl = TextEditingController(text: editing?.title ?? '');
    _section = editing?.appSection ?? ref.read(currentAppSectionProvider);
    _start = TimeOfDay.fromDateTime(editing?.start ?? widget.initialStart);
    _end = TimeOfDay.fromDateTime(
      editing?.end ?? widget.initialStart.add(const Duration(minutes: 30)),
    );
    _status = editing?.status ?? PlannerTaskStatus.upcoming;
    _reminder = editing?.reminderEnabled ?? false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  DateTime _combine(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

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

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    final date = widget.editing?.start ?? widget.initialStart;
    var start = _combine(date, _start);
    var end = _combine(date, _end);
    if (!end.isAfter(start)) end = start.add(const Duration(minutes: 30));

    final notifier = ref.read(plannerTasksProvider.notifier);
    if (widget.editing != null) {
      notifier.update(
        widget.editing!.copyWith(
          title: title,
          appSection: _section,
          start: start,
          end: end,
          status: _status,
          reminderEnabled: _reminder,
        ),
      );
    } else {
      notifier.add(
        PlannerTask(
          id: '${DateTime.now().microsecondsSinceEpoch}',
          title: title,
          appSection: _section,
          start: start,
          end: end,
          status: _status,
          reminderEnabled: _reminder,
        ),
      );
    }
    Navigator.of(context).maybePop();
  }

  void _delete() {
    final editing = widget.editing;
    if (editing == null) return;
    ref.read(plannerTasksProvider.notifier).remove(editing.id);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final (gradient, glow) = plannerAccentFor(_section);
    final isEditing = widget.editing != null;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
        decoration: const BoxDecoration(
          color: Color(0xEB0F1326),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
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
            Text(
              ref.tr(isEditing ? 'planner_edit_title' : 'planner_add_title'),
              style: AppTextStyles.heading(size: 18),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              autofocus: !isEditing,
              style: AppTextStyles.body(),
              decoration: InputDecoration(
                hintText: ref.tr('planner_task_title_hint'),
                hintStyle: AppTextStyles.muted(),
                filled: true,
                fillColor: AppColors.glassFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.glassBorder),
                ),
              ),
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
            Row(
              children: [
                Expanded(
                  child: _TimeField(
                    label: ref.tr('planner_start_time'),
                    time: _start,
                    onTap: () => _pickTime(true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TimeField(
                    label: ref.tr('planner_end_time'),
                    time: _end,
                    onTap: () => _pickTime(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final st in PlannerTaskStatus.values)
                  _StatusChip(
                    status: st,
                    selected: _status == st,
                    onTap: () => setState(() => _status = st),
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
                style: AppTextStyles.body(size: 13, weight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (isEditing)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _delete,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFF6B9D)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(
                        ref.tr('planner_delete'),
                        style: const TextStyle(
                          color: Color(0xFFFF6B9D),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                if (isEditing) const SizedBox(width: 10),
                Expanded(
                  flex: 2,
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

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              time.format(context),
              style: AppTextStyles.body(size: 15, weight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends ConsumerWidget {
  const _StatusChip({
    required this.status,
    required this.selected,
    required this.onTap,
  });

  final PlannerTaskStatus status;
  final bool selected;
  final VoidCallback onTap;

  String get _key => switch (status) {
    PlannerTaskStatus.completed => 'planner_status_completed',
    PlannerTaskStatus.running => 'planner_status_running',
    PlannerTaskStatus.rejected => 'planner_status_rejected',
    PlannerTaskStatus.upcoming => 'planner_status_upcoming',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = status.color;
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
          ref.tr(_key),
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

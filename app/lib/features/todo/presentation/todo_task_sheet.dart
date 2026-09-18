import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/confirm_action.dart';
import '../data/todo_models.dart';
import 'todo_providers.dart';

const _gold = AppColors.wealthAccent;

/// Sheet them/sua 1 dau viec - CHI 3 truong: ten viec, ngay, gio. Khong them
/// truong nao khac (uu tien/nhan/lap lai...) de giu dung pham vi "To do
/// list"; nhung thu do da co ben Lap ke hoach.
Future<void> showTodoTaskSheet(
  BuildContext context,
  WidgetRef ref, {
  TodoTask? existing,
  DateTime? day,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TodoTaskSheet(existing: existing, day: day),
  );
}

class _TodoTaskSheet extends ConsumerStatefulWidget {
  const _TodoTaskSheet({this.existing, this.day});

  final TodoTask? existing;
  final DateTime? day;

  @override
  ConsumerState<_TodoTaskSheet> createState() => _TodoTaskSheetState();
}

class _TodoTaskSheetState extends ConsumerState<_TodoTaskSheet> {
  late final TextEditingController _title = TextEditingController(
    text: widget.existing?.title ?? '',
  );
  late DateTime _date = todoDayKey(
    widget.existing?.dueAt ?? widget.day ?? DateTime.now(),
  );
  late TimeOfDay _time = TimeOfDay.fromDateTime(
    widget.existing?.dueAt ?? DateTime.now().add(const Duration(hours: 1)),
  );
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  DateTime get _dueAt =>
      DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty || _saving) return;
    // Hoi truoc khi ghi (yeu cau nguoi dung 2026-09-19) - truoc day bam la
    // luu thang, khong co buoc nao de dung lai.
    if (!await confirmSave(context, ref)) return;
    if (!mounted) return;
    setState(() => _saving = true);
    try {
      final notifier = ref.read(todoTasksProvider.notifier);
      if (widget.existing == null) {
        await notifier.add(title: title, dueAt: _dueAt);
      } else {
        await notifier.update(widget.existing!.id, title: title, dueAt: _dueAt);
      }
      if (mounted) {
        showSuccessToast(context, ref.tr('toast_saved'));
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) showErrorToast(context, ref.tr('toast_failed'));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final task = widget.existing;
    if (task == null) return;
    if (!await confirmDeleteAction(context, ref, message: task.title)) return;
    if (!mounted) return;
    await ref.read(todoTasksProvider.notifier).remove(task.id);
    if (mounted) {
      showSuccessToast(context, ref.tr('toast_deleted'));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0B1020),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                ref.tr(isEdit ? 'todo_edit_task' : 'todo_new_task'),
                style: AppTextStyles.body(
                  size: 11,
                  weight: FontWeight.w800,
                  color: _gold,
                ).copyWith(letterSpacing: 2),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _title,
                autofocus: !isEdit,
                textCapitalization: TextCapitalization.sentences,
                style: AppTextStyles.body(size: 15),
                cursorColor: _gold,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  hintText: ref.tr('todo_title_hint'),
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _PickerField(
                      label: ref.tr('todo_date'),
                      value: '${_date.day}/${_date.month}/${_date.year}',
                      icon: Icons.calendar_today_rounded,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => _date = todoDayKey(picked));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PickerField(
                      label: ref.tr('todo_time'),
                      value:
                          '${_time.hour.toString().padLeft(2, '0')}:'
                          '${_time.minute.toString().padLeft(2, '0')}',
                      icon: Icons.schedule_rounded,
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _time,
                        );
                        if (picked != null) setState(() => _time = picked);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  if (isEdit) ...[
                    Expanded(
                      child: PillButton(
                        label: ref.tr('todo_delete'),
                        filled: false,
                        accentColor: AppColors.pink,
                        onTap: _saving ? null : _delete,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: PillButton(
                      label: ref.tr(isEdit ? 'wallet_save' : 'todo_create'),
                      accentGradient: AppColors.wealthAccentGradient,
                      accentColor: _gold,
                      onTap: _saving ? null : _save,
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
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.muted(size: 10.5)),
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(icon, size: 15, color: _gold),
              const SizedBox(width: 7),
              Text(
                value,
                style: AppTextStyles.body(size: 13.5, weight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

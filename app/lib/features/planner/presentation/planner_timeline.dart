import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/planner_models.dart';
import 'planner_accent.dart';
import 'planner_providers.dart';

/// Timeline theo gio trong ngay (00:00-23:00, cuon doc) - moi hang gio la 1
/// DragTarget de nhan task duoc keo tha tu hang khac (doi gio truc tiep,
/// GIU NGUYEN thoi luong ban dau). Khi >3 viec cung gio: chi hien 1 the day
/// du + nut "+N viec khac" xo list rut gon NGAY TAI CHO (khong mo popup con) -
/// dung theo quyet dinh da chot, xem docs/research-planner-app-ux.md.
///
/// LUU Y: day la nhom theo GIO BAT DAU (khong phai thuat toan chia cot theo
/// khoang thoi gian chong lan that su kieu Google Calendar) - don gian hoa co
/// chu dich cho v1, du dung cho phan lon truong hop vi cac mini-app tao viec
/// theo khung gio tron.
class PlannerTimeline extends ConsumerStatefulWidget {
  const PlannerTimeline({
    super.key,
    required this.date,
    required this.tasks,
    required this.onAddAt,
    required this.onEditTask,
  });

  final DateTime date;
  final List<PlannerTask> tasks;
  final void Function(DateTime hourStart) onAddAt;
  final void Function(PlannerTask task) onEditTask;

  @override
  ConsumerState<PlannerTimeline> createState() => _PlannerTimelineState();
}

class _PlannerTimelineState extends ConsumerState<PlannerTimeline> {
  final _expandedHours = <int>{};
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    // Cuon toi gio dau tien co viec (hoac 7h sang mac dinh) de nguoi dung
    // khong phai tu keo tu 00:00 moi lan mo man.
    final firstHour = widget.tasks.isEmpty ? 7 : widget.tasks.first.start.hour;
    _scroll = ScrollController(
      initialScrollOffset: (firstHour - 1).clamp(0, 20) * 74.0,
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Map<int, List<PlannerTask>> get _byHour {
    final map = <int, List<PlannerTask>>{};
    for (final t in widget.tasks) {
      map.putIfAbsent(t.start.hour, () => []).add(t);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final byHour = _byHour;
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: 24,
      itemBuilder: (context, hour) {
        final bucket = byHour[hour] ?? const <PlannerTask>[];
        return _HourRow(
          hour: hour,
          tasks: bucket,
          expanded: _expandedHours.contains(hour),
          onToggleExpand: () => setState(() {
            if (!_expandedHours.add(hour)) _expandedHours.remove(hour);
          }),
          onAdd: () {
            final hourStart = DateTime(
              widget.date.year,
              widget.date.month,
              widget.date.day,
              hour,
            );
            widget.onAddAt(hourStart);
          },
          onEditTask: widget.onEditTask,
          onDropTaskId: (taskId) {
            final hourStart = DateTime(
              widget.date.year,
              widget.date.month,
              widget.date.day,
              hour,
            );
            ref
                .read(plannerTasksProvider.notifier)
                .reschedule(taskId, hourStart);
          },
        );
      },
    );
  }
}

class _HourRow extends StatelessWidget {
  const _HourRow({
    required this.hour,
    required this.tasks,
    required this.expanded,
    required this.onToggleExpand,
    required this.onAdd,
    required this.onEditTask,
    required this.onDropTaskId,
  });

  final int hour;
  final List<PlannerTask> tasks;
  final bool expanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onAdd;
  final void Function(PlannerTask task) onEditTask;
  final void Function(String taskId) onDropTaskId;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 68),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0x12FFFFFF))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Text(
                '${hour.toString().padLeft(2, '0')}:00',
                style: AppTextStyles.muted(size: 10.5, weight: FontWeight.w700),
              ),
            ),
          ),
          Expanded(
            child: DragTarget<String>(
              onAcceptWithDetails: (details) => onDropTaskId(details.data),
              builder: (context, candidateData, rejectedData) {
                final hovering = candidateData.isNotEmpty;
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: tasks.isEmpty ? onAdd : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: hovering
                          ? Colors.white.withValues(alpha: 0.06)
                          : null,
                    ),
                    child: tasks.isEmpty
                        ? const SizedBox(height: 46)
                        : _TaskBucket(
                            tasks: tasks,
                            expanded: expanded,
                            onToggleExpand: onToggleExpand,
                            onEditTask: onEditTask,
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskBucket extends ConsumerWidget {
  const _TaskBucket({
    required this.tasks,
    required this.expanded,
    required this.onToggleExpand,
    required this.onEditTask,
  });

  final List<PlannerTask> tasks;
  final bool expanded;
  final VoidCallback onToggleExpand;
  final void Function(PlannerTask task) onEditTask;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tasks.length <= 3) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < tasks.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: _DraggableTaskCard(
                task: tasks[i],
                onTap: () => onEditTask(tasks[i]),
              ),
            ),
          ],
        ],
      );
    }
    final primary = tasks.first;
    final rest = tasks.sublist(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DraggableTaskCard(task: primary, onTap: () => onEditTask(primary)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onToggleExpand,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  '+${rest.length} ${ref.tr('planner_more_tasks')}',
                  style: AppTextStyles.muted(size: 10, weight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
        if (expanded) ...[
          const SizedBox(height: 6),
          for (final t in rest) ...[
            _MiniTaskRow(task: t, onTap: () => onEditTask(t)),
            const SizedBox(height: 6),
          ],
        ],
      ],
    );
  }
}

class _DraggableTaskCard extends StatelessWidget {
  const _DraggableTaskCard({required this.task, required this.onTap});

  final PlannerTask task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final card = _TaskCard(task: task, onTap: onTap);
    return LongPressDraggable<String>(
      data: task.id,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: 220, child: Opacity(opacity: 0.9, child: card)),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: card),
      child: card,
    );
  }
}

class _TaskCard extends ConsumerWidget {
  const _TaskCard({required this.task, required this.onTap});

  final PlannerTask task;
  final VoidCallback onTap;

  String get _statusKey => switch (task.status) {
    PlannerTaskStatus.completed => 'planner_status_completed',
    PlannerTaskStatus.running => 'planner_status_running',
    PlannerTaskStatus.rejected => 'planner_status_rejected',
    PlannerTaskStatus.upcoming => 'planner_status_upcoming',
  };

  String _fmt(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tint = plannerSectionTint(task.appSection);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(13, 9, 8, 9),
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 32,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: task.status.color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                plannerSectionIcon(task.appSection),
                size: 15,
                color: tint,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(
                      size: 12,
                      weight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${_fmt(task.start)} – ${_fmt(task.end)}',
                    style: AppTextStyles.muted(size: 9.5),
                  ),
                ],
              ),
            ),
            if (task.reminderEnabled)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.notifications_rounded,
                  size: 12,
                  color: Color(0xFFFFD66B),
                ),
              ),
            const SizedBox(width: 6),
            Text(
              ref.tr(_statusKey),
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                color: task.status.color,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniTaskRow extends StatelessWidget {
  const _MiniTaskRow({required this.task, required this.onTap});

  final PlannerTask task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.035),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: task.status.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body(size: 11, weight: FontWeight.w700),
              ),
            ),
            Text(
              '${task.start.hour.toString().padLeft(2, '0')}:${task.start.minute.toString().padLeft(2, '0')}',
              style: AppTextStyles.muted(size: 9.5),
            ),
          ],
        ),
      ),
    );
  }
}

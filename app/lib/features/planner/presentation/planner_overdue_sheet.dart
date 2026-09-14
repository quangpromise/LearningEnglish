import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/planner_models.dart';
import 'planner_accent.dart';
import 'planner_pull_to_dismiss.dart';
import 'planner_providers.dart';
import 'planner_undo.dart';

/// Sheet xu ly viec cua cac ngay truoc chua xong (nguon:
/// [plannerOverdueProvider]) - moi viec 4 lua chon: Xong / Lam hom nay /
/// Chua xep gio / Bo qua. Vuot phai = Xong, vuot trai = Lam hom nay.
/// Pattern chung "xu ly viec qua han" (docs/research-planner-app-ux.md §7.3
/// muc 3) - khong dung ten goi/giao dien rieng cua app nao.
Future<void> showPlannerOverdueSheet(
  BuildContext context, {
  ScaffoldMessengerState? messenger,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) =>
        PlannerPullToDismiss(child: _OverdueSheet(messenger: messenger)),
  );
}

class _OverdueSheet extends ConsumerWidget {
  const _OverdueSheet({this.messenger});

  final ScaffoldMessengerState? messenger;

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(plannerOverdueProvider);
    final notifier = ref.read(plannerTasksProvider.notifier);

    Future<void> act(String key, Future<void> Function() action) =>
        runPlannerActionWithUndo(
          ref: ref,
          messenger: messenger,
          messageKey: key,
          action: action,
        );

    Future<void> doToday(PlannerOccurrence o) {
      final now = DateTime.now();
      final start = DateTime(
        now.year,
        now.month,
        now.day,
        o.start.hour,
        o.start.minute,
      );
      return act(
        'planner_postponed_toast',
        () => notifier.moveOccurrence(o, start),
      );
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
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
            ref.tr('planner_overdue_title'),
            style: AppTextStyles.heading(size: 18),
          ),
          const SizedBox(height: 4),
          Text(
            ref.tr('planner_overdue_subtitle'),
            style: AppTextStyles.muted(),
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  ref.tr('planner_overdue_empty'),
                  style: AppTextStyles.body(weight: FontWeight.w700),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final o = items[i];
                  return Dismissible(
                    key: ValueKey('${o.task.id}-${o.dayKey}'),
                    background: _SwipeBg(
                      color: PlannerTaskStatus.completed.color,
                      icon: Icons.check_rounded,
                      alignLeft: true,
                    ),
                    secondaryBackground: const _SwipeBg(
                      color: Color(0xFF5B8CFF),
                      icon: Icons.today_rounded,
                      alignLeft: false,
                    ),
                    onDismissed: (dir) => dir == DismissDirection.startToEnd
                        ? act(
                            'planner_done_toast',
                            () =>
                                notifier.settle(o, PlannerTaskStatus.completed),
                          )
                        : doToday(o),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.glassFill,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                plannerSectionIcon(o.task.appSection),
                                size: 14,
                                color: plannerSectionTint(o.task.appSection),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  o.task.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.body(
                                    size: 13,
                                    weight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                _fmt(o.start),
                                style: AppTextStyles.muted(size: 10.5),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _ActionPill(
                                label: ref.tr('planner_action_done'),
                                color: PlannerTaskStatus.completed.color,
                                onTap: () => act(
                                  'planner_done_toast',
                                  () => notifier.settle(
                                    o,
                                    PlannerTaskStatus.completed,
                                  ),
                                ),
                              ),
                              _ActionPill(
                                label: ref.tr('planner_action_today'),
                                color: const Color(0xFF5B8CFF),
                                onTap: () => doToday(o),
                              ),
                              _ActionPill(
                                label: ref.tr('planner_action_inbox'),
                                color: const Color(0xFF8B93A7),
                                onTap: () => act(
                                  'planner_inbox_toast',
                                  () => notifier.sendToInbox(o),
                                ),
                              ),
                              _ActionPill(
                                label: ref.tr('planner_action_skip'),
                                color: PlannerTaskStatus.rejected.color,
                                onTap: () => act(
                                  'planner_skipped_toast',
                                  () => notifier.settle(
                                    o,
                                    PlannerTaskStatus.rejected,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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

class _SwipeBg extends StatelessWidget {
  const _SwipeBg({
    required this.color,
    required this.icon,
    required this.alignLeft,
  });

  final Color color;
  final IconData icon;
  final bool alignLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.6)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

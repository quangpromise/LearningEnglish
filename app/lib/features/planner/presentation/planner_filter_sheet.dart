import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import 'planner_accent.dart';
import 'planner_providers.dart';

/// Sheet nho chon nhanh chi hien viec cua (cac) mini-app nao tren timeline -
/// loi tat "Loc mini-app" o menu noi AssistiveTouch (planner_fab_overlay.dart).
Future<void> showPlannerFilterSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const _PlannerFilterSheet(),
  );
}

class _PlannerFilterSheet extends ConsumerWidget {
  const _PlannerFilterSheet();

  String _labelKey(AppSection s) => switch (s) {
    AppSection.learnEnglish => 'planner_app_english',
    AppSection.fitness => 'planner_app_fitness',
    AppSection.wealth => 'planner_app_wealth',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(plannerSectionFilterProvider);
    final notifier = ref.read(plannerSectionFilterProvider.notifier);

    return Container(
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
            ref.tr('planner_filter_sheet_title'),
            style: AppTextStyles.heading(size: 17),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () => notifier.state = null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.apps_rounded,
                    size: 18,
                    color: filter == null
                        ? AppColors.blue
                        : AppColors.textMuted,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ref.tr('planner_filter_all'),
                      style: AppTextStyles.body(
                        size: 13.5,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (filter == null)
                    const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: AppColors.blue,
                    ),
                ],
              ),
            ),
          ),
          for (final s in AppSection.values)
            InkWell(
              onTap: () {
                final current = filter ?? {...AppSection.values};
                final next = {...current};
                if (next.contains(s) &&
                    current.length == AppSection.values.length) {
                  // Tu "Tat ca" -> chi chon rieng section nay.
                  notifier.state = {s};
                } else if (next.contains(s)) {
                  next.remove(s);
                  notifier.state = next.isEmpty ? {s} : next;
                } else {
                  next.add(s);
                  notifier.state = next.length == AppSection.values.length
                      ? null
                      : next;
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      plannerSectionIcon(s),
                      size: 18,
                      color: plannerSectionTint(s),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        ref.tr(_labelKey(s)),
                        style: AppTextStyles.body(
                          size: 13.5,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (filter != null && filter.contains(s))
                      Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: plannerSectionTint(s),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

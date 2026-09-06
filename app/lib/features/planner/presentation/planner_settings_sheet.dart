import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/planner_models.dart';
import '../data/planner_notification_service.dart';
import 'planner_providers.dart';

Future<void> showPlannerSettingsSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _PlannerSettingsSheet(),
  );
}

class _PlannerSettingsSheet extends ConsumerWidget {
  const _PlannerSettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(plannerReminderSettingsProvider);
    final notifier = ref.read(plannerReminderSettingsProvider.notifier);

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
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
            ref.tr('planner_settings_title'),
            style: AppTextStyles.heading(size: 18),
          ),
          const SizedBox(height: 4),
          Text(
            ref.tr('planner_settings_subtitle'),
            style: AppTextStyles.muted(),
          ),
          const SizedBox(height: 18),

          Text(
            ref.tr('planner_ringtone_label'),
            style: AppTextStyles.muted(size: 11, weight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          GlowBox(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final r in RingtoneChoice.values)
                  _RingtoneRow(
                    choice: r,
                    selected: settings.ringtone == r,
                    previewMode: settings.mode,
                    onTap: () =>
                        notifier.update(settings.copyWith(ringtone: r)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Text(
            ref.tr('planner_lead_time_label'),
            style: AppTextStyles.muted(size: 11, weight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final l in ReminderLeadTime.values)
                _LeadPill(
                  lead: l,
                  selected: settings.leadTime == l,
                  onTap: () => notifier.update(settings.copyWith(leadTime: l)),
                ),
            ],
          ),
          const SizedBox(height: 18),

          Text(
            ref.tr('planner_mode_label'),
            style: AppTextStyles.muted(size: 11, weight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.7,
            children: [
              for (final m in ReminderMode.values)
                _ModeCard(
                  mode: m,
                  selected: settings.mode == m,
                  onTap: () => notifier.update(settings.copyWith(mode: m)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingtoneRow extends ConsumerWidget {
  const _RingtoneRow({
    required this.choice,
    required this.selected,
    required this.onTap,
    required this.previewMode,
  });

  final RingtoneChoice choice;
  final bool selected;
  final VoidCallback onTap;

  /// Kieu nhac (rung/chuong/ca hai/tat) DANG chon trong cai dat - truyen
  /// vao de nut "Nghe thu" phat DUNG nhu se nghe that (vd dang chon "Chi
  /// rung" thi bam nghe thu se khong phat am thanh, chi rung).
  final ReminderMode previewMode;

  String get _key => switch (choice) {
    RingtoneChoice.defaultSound => 'planner_ringtone_default',
    RingtoneChoice.cheerfulTone => 'planner_ringtone_cheerful',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(
              choice == RingtoneChoice.cheerfulTone
                  ? Icons.music_note_rounded
                  : Icons.notifications_rounded,
              size: 18,
              color: const Color(0xFF8FB0FF),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ref.tr(_key),
                style: AppTextStyles.body(size: 13.5, weight: FontWeight.w700),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (previewMode == ReminderMode.off) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ref.tr('planner_preview_mode_off'))),
                  );
                  return;
                }
                PlannerNotificationService.instance.preview(
                  ringtone: choice,
                  mode: previewMode,
                );
              },
              child: Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 17,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: selected ? AppColors.accentGradient : null,
                border: selected
                    ? null
                    : Border.all(color: AppColors.glassBorder),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadPill extends ConsumerWidget {
  const _LeadPill({
    required this.lead,
    required this.selected,
    required this.onTap,
  });

  final ReminderLeadTime lead;
  final bool selected;
  final VoidCallback onTap;

  String get _key => switch (lead) {
    ReminderLeadTime.onTime => 'planner_lead_on_time',
    ReminderLeadTime.min5 => 'planner_lead_5',
    ReminderLeadTime.min15 => 'planner_lead_15',
    ReminderLeadTime.min30 => 'planner_lead_30',
    ReminderLeadTime.hour1 => 'planner_lead_60',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.accentGradient : null,
          color: selected ? null : AppColors.glassFill,
          borderRadius: BorderRadius.circular(999),
          border: selected ? null : Border.all(color: AppColors.glassBorder),
        ),
        child: Text(
          ref.tr(_key),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.textMuted,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends ConsumerWidget {
  const _ModeCard({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final ReminderMode mode;
  final bool selected;
  final VoidCallback onTap;

  String get _key => switch (mode) {
    ReminderMode.both => 'planner_mode_both',
    ReminderMode.vibrateOnly => 'planner_mode_vibrate',
    ReminderMode.soundOnly => 'planner_mode_sound',
    ReminderMode.off => 'planner_mode_off',
  };

  IconData get _icon => switch (mode) {
    ReminderMode.both => Icons.notifications_active_rounded,
    ReminderMode.vibrateOnly => Icons.vibration_rounded,
    ReminderMode.soundOnly => Icons.volume_up_rounded,
    ReminderMode.off => Icons.notifications_off_rounded,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? const Color(0x335B8CFF) : AppColors.glassFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0x669B6BFF) : AppColors.glassBorder,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: selected ? AppColors.accentGradient : null,
                color: selected ? null : Colors.white.withValues(alpha: 0.06),
              ),
              child: Icon(
                _icon,
                size: 16,
                color: selected ? Colors.white : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              ref.tr(_key),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: selected
                    ? Colors.white
                    : AppColors.textMuted.withValues(alpha: 0.85),
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

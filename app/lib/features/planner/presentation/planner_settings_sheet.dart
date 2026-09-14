import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/device_alarm_sounds.dart';
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
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Color(0xEB0F1326),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
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
            // Ban web khong dat lich thong bao duoc - noi ro thay vi de nguoi
            // dung tuong da bat nhac (docs/research-planner-app-ux.md §7.5).
            if (!PlannerNotificationService.isSupported) ...[
              const SizedBox(height: 12),
              _Notice(text: ref.tr('planner_reminder_web_notice')),
            ],
            const SizedBox(height: 18),

            Text(
              ref.tr('planner_alarm_sound_label'),
              style: AppTextStyles.muted(size: 11, weight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            _AlarmSoundList(
              settings: settings,
              onSelect: (sound) => notifier.update(
                settings.copyWith(
                  ringtone: RingtoneChoice.deviceAlarm,
                  alarmSoundUri: sound.uri,
                  alarmSoundTitle: sound.title,
                ),
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
                    onTap: () =>
                        notifier.update(settings.copyWith(leadTime: l)),
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
            if (PlannerNotificationService.isSupported) ...[
              const SizedBox(height: 14),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    if (settings.mode == ReminderMode.off) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ref.tr('planner_preview_mode_off')),
                        ),
                      );
                      return;
                    }
                    PlannerNotificationService.instance.preview(settings);
                  },
                  icon: const Icon(
                    Icons.notifications_active_rounded,
                    size: 16,
                    color: Color(0xFF8FB0FF),
                  ),
                  label: Text(
                    ref.tr('planner_test_notification'),
                    style: AppTextStyles.body(
                      size: 12.5,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x22FFB547),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x55FFB547)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: Color(0xFFFFB547),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTextStyles.body(size: 11.5))),
        ],
      ),
    );
  }
}

/// Danh sach chuong BAO THUC co san tren may (doc qua kenh native, xem
/// device_alarm_sounds.dart) - thay 2 lua chon chuong co dinh truoc day.
/// Nut play phat thu ngay bang luong am thanh bao thuc; roi man thi tu tat.
class _AlarmSoundList extends ConsumerStatefulWidget {
  const _AlarmSoundList({required this.settings, required this.onSelect});

  final PlannerReminderSettings settings;
  final ValueChanged<DeviceAlarmSound> onSelect;

  @override
  ConsumerState<_AlarmSoundList> createState() => _AlarmSoundListState();
}

class _AlarmSoundListState extends ConsumerState<_AlarmSoundList> {
  late final Future<List<DeviceAlarmSound>> _sounds = DeviceAlarmSounds.list();
  String? _playingUri;

  @override
  void dispose() {
    if (_playingUri != null) DeviceAlarmSounds.stop();
    super.dispose();
  }

  void _togglePreview(DeviceAlarmSound sound) {
    if (_playingUri == sound.uri) {
      DeviceAlarmSounds.stop();
      setState(() => _playingUri = null);
    } else {
      DeviceAlarmSounds.play(sound.uri);
      setState(() => _playingUri = sound.uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!DeviceAlarmSounds.isSupported) {
      return _Notice(text: ref.tr('planner_alarm_sound_android_only'));
    }
    return FutureBuilder<List<DeviceAlarmSound>>(
      future: _sounds,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final sounds = snap.data ?? const <DeviceAlarmSound>[];
        if (sounds.isEmpty) {
          return _Notice(text: ref.tr('planner_alarm_sound_empty'));
        }
        final s = widget.settings;
        return GlowBox(
          padding: EdgeInsets.zero,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 280),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: sounds.length,
              itemBuilder: (context, i) {
                final sound = sounds[i];
                final selected =
                    s.ringtone == RingtoneChoice.deviceAlarm &&
                    s.alarmSoundUri == sound.uri;
                return _AlarmSoundRow(
                  sound: sound,
                  selected: selected,
                  playing: _playingUri == sound.uri,
                  onTap: () => widget.onSelect(sound),
                  onPreview: () => _togglePreview(sound),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _AlarmSoundRow extends ConsumerWidget {
  const _AlarmSoundRow({
    required this.sound,
    required this.selected,
    required this.playing,
    required this.onTap,
    required this.onPreview,
  });

  final DeviceAlarmSound sound;
  final bool selected;
  final bool playing;
  final VoidCallback onTap;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            const Icon(Icons.alarm_rounded, size: 18, color: Color(0xFF8FB0FF)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sound.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(
                      size: 13.5,
                      weight: FontWeight.w700,
                    ),
                  ),
                  if (sound.isDefault)
                    Text(
                      ref.tr('planner_alarm_sound_device_default'),
                      style: AppTextStyles.muted(size: 10),
                    ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onPreview,
              child: Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: playing ? 0.16 : 0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  playing ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  size: 17,
                  color: playing ? Colors.white : AppColors.textMuted,
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

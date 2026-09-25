import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/gymtalk_reminders.dart';

/// "Thu thach tuan Body + Brain" voi ban be: xep hang so ngay dat trong 7
/// ngay gan nhat (RPC friends_body_brain_week, migration 0074).
class FriendsChallengeCard extends ConsumerWidget {
  const FriendsChallengeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(friendsChallengeProvider);
    final entries = async.valueOrNull ?? const [];
    return GlowBox(
      border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: AppColors.amber),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  ref.tr('challenge_title'),
                  style: AppTextStyles.heading(size: 17),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            ref.tr('challenge_subtitle'),
            style: AppTextStyles.muted(size: 12),
          ),
          const SizedBox(height: 10),
          if (async.isLoading && entries.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.amber),
              ),
            )
          else if (async.hasError)
            Text(
              ref.tr('progress_load_error'),
              style: AppTextStyles.body(size: 13, color: AppColors.textMuted),
            )
          else if (entries.length <= 1)
            Text(
              ref.tr('challenge_no_friends'),
              style: AppTextStyles.body(size: 13, color: AppColors.textMuted),
            ),
          for (final e in entries.take(10))
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: e.isMe
                    ? AppColors.blue.withValues(alpha: 0.16)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      '#${e.rank}',
                      style: AppTextStyles.body(weight: FontWeight.w800),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      e.isMe ? ref.tr('challenge_me') : e.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(),
                    ),
                  ),
                  Text(
                    '${e.daysDone}/7',
                    style: AppTextStyles.body(
                      weight: FontWeight.w800,
                      color: AppColors.amber,
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

/// Bat/tat + chon gio nhac tap & hoc hang ngay (GymTalkReminders).
class ReminderSettingsCard extends ConsumerStatefulWidget {
  const ReminderSettingsCard({super.key});

  @override
  ConsumerState<ReminderSettingsCard> createState() =>
      _ReminderSettingsCardState();
}

class _ReminderSettingsCardState extends ConsumerState<ReminderSettingsCard> {
  ReminderSettings? _settings;

  @override
  void initState() {
    super.initState();
    GymTalkReminders.instance.loadSettings().then((s) {
      if (mounted) setState(() => _settings = s);
    });
  }

  Future<void> _update(ReminderSettings settings) async {
    setState(() => _settings = settings);
    await GymTalkReminders.instance.saveSettings(ref, settings);
  }

  Future<void> _pickTime(ReminderSettings current) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
    );
    if (picked == null || !mounted) return;
    await _update(
      ReminderSettings(
        enabled: current.enabled,
        hour: picked.hour,
        minute: picked.minute,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    if (settings == null) return const SizedBox.shrink();
    final time = TimeOfDay(
      hour: settings.hour,
      minute: settings.minute,
    ).format(context);
    return GlowBox(
      padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: settings.enabled,
            activeThumbColor: AppColors.blue,
            title: Text(
              ref.tr('remind_setting_title'),
              style: AppTextStyles.body(weight: FontWeight.w800),
            ),
            subtitle: Text(
              ref.tr('remind_setting_sub'),
              style: AppTextStyles.muted(),
            ),
            onChanged: (enabled) => _update(
              ReminderSettings(
                enabled: enabled,
                hour: settings.hour,
                minute: settings.minute,
              ),
            ),
          ),
          if (settings.enabled)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.schedule_rounded,
                color: AppColors.blue,
              ),
              title: Text(
                ref.tr('remind_setting_time'),
                style: AppTextStyles.body(),
              ),
              trailing: Text(time, style: AppTextStyles.heading(size: 18)),
              onTap: () => _pickTime(settings),
            ),
        ],
      ),
    );
  }
}

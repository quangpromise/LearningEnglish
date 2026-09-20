import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/football_models.dart';
import 'football_providers.dart';
import 'football_widgets.dart';

/// Bat/tat tung loai thong bao bong da (yeu cau muc 7 cua de bai).
///
/// Cai dat luu theo TAI KHOAN (bang football_notification_prefs) chu khong
/// luu tren may: worker `football-live` chay o server phai doc duoc de biet
/// co nen gui push hay khong. Doi may van giu nguyen lua chon.
class FootballNotificationSettingsView extends ConsumerWidget {
  const FootballNotificationSettingsView({super.key, required this.onBack});

  final VoidCallback onBack;

  Future<void> _save(WidgetRef ref, FootballNotificationPrefs next) async {
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) return;
    await ref
        .read(footballRepositoryProvider)
        .saveNotificationPrefs(userId, next);
    ref.invalidate(footballNotificationPrefsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(footballNotificationPrefsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PopupBackHeader(
          title: ref.tr('football_notifications'),
          onBack: onBack,
        ),
        const SizedBox(height: 12),
        Text(
          ref.tr('football_notifications_hint'),
          style: AppTextStyles.muted(size: 11.5),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: prefsAsync.when(
            loading: () => const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: FootballColors.electric,
                ),
              ),
            ),
            error: (_, _) => FootballEmptyState(
              message: ref.tr('football_load_error'),
              icon: Icons.wifi_off_rounded,
            ),
            data: (p) => ListView(
              children: [
                _Group(
                  label: ref.tr('football_notif_group_inplay'),
                  rows: [
                    _Row(
                      icon: Icons.sports_soccer_rounded,
                      color: AppColors.teal,
                      label: ref.tr('football_notif_goal'),
                      value: p.goal,
                      onChanged: (v) => _save(ref, p.copyWith(goal: v)),
                    ),
                    _Row(
                      icon: Icons.square_rounded,
                      color: const Color(0xFFFFD66B),
                      label: ref.tr('football_notif_yellow'),
                      value: p.yellowCard,
                      onChanged: (v) => _save(ref, p.copyWith(yellowCard: v)),
                    ),
                    _Row(
                      icon: Icons.square_rounded,
                      color: FootballColors.live,
                      label: ref.tr('football_notif_red'),
                      value: p.redCard,
                      onChanged: (v) => _save(ref, p.copyWith(redCard: v)),
                    ),
                    _Row(
                      icon: Icons.swap_horiz_rounded,
                      color: FootballColors.electric,
                      label: ref.tr('football_notif_subst'),
                      value: p.substitution,
                      onChanged: (v) => _save(ref, p.copyWith(substitution: v)),
                    ),
                  ],
                ),
                _Group(
                  label: ref.tr('football_notif_group_milestones'),
                  rows: [
                    _Row(
                      icon: Icons.play_circle_outline_rounded,
                      color: AppColors.purple,
                      label: ref.tr('football_notif_start'),
                      value: p.matchStarted,
                      onChanged: (v) => _save(ref, p.copyWith(matchStarted: v)),
                    ),
                    _Row(
                      icon: Icons.timelapse_rounded,
                      color: AppColors.purple,
                      label: ref.tr('football_notif_halftime'),
                      value: p.halfTime,
                      onChanged: (v) => _save(ref, p.copyWith(halfTime: v)),
                    ),
                    _Row(
                      icon: Icons.flag_rounded,
                      color: FootballColors.live,
                      label: ref.tr('football_notif_finish'),
                      value: p.matchFinished,
                      onChanged: (v) =>
                          _save(ref, p.copyWith(matchFinished: v)),
                    ),
                  ],
                ),
                _Group(
                  label: ref.tr('football_notif_group_prematch'),
                  rows: [
                    _Row(
                      icon: Icons.groups_rounded,
                      color: FootballColors.electric,
                      label: ref.tr('football_notif_lineup'),
                      sublabel: ref.tr('football_notif_lineup_sub'),
                      value: p.lineupAvailable,
                      onChanged: (v) =>
                          _save(ref, p.copyWith(lineupAvailable: v)),
                    ),
                    _Row(
                      icon: Icons.calendar_month_rounded,
                      color: AppColors.purple,
                      label: ref.tr('football_notif_reminder'),
                      sublabel: ref.tr('football_notif_reminder_sub'),
                      value: p.fixtureReminder,
                      onChanged: (v) =>
                          _save(ref, p.copyWith(fixtureReminder: v)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    ref.tr('football_notif_account_note'),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.muted(size: 10.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.label, required this.rows});

  final String label;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 2),
            child: Text(
              label.toUpperCase(),
              style: AppTextStyles.muted(size: 10).copyWith(letterSpacing: 0.7),
            ),
          ),
          GlowBox(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            borderRadius: 18,
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.onChanged,
    this.sublabel,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String? sublabel;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.body(
                    size: 12.5,
                    weight: FontWeight.w700,
                  ),
                ),
                if (sublabel != null) ...[
                  const SizedBox(height: 2),
                  Text(sublabel!, style: AppTextStyles.muted(size: 10.5)),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.teal,
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: AppColors.glassFill,
          ),
        ],
      ),
    );
  }
}

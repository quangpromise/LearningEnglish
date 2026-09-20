import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/sleep_repository.dart';
import 'home/fitness_home_theme.dart';

const _weekdayShort = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

/// Man "Giac ngu" - nhat ky do NGUOI DUNG TU GHI (gio di ngu / gio thuc
/// day), khong doc cam bien nao ca. Neu sau nay ghep duoc du lieu tu vong
/// deo tay thi them nguon moi trong [SleepRepository], UI giu nguyen.
class SleepScreen extends ConsumerStatefulWidget {
  const SleepScreen({super.key});

  @override
  ConsumerState<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends ConsumerState<SleepScreen> {
  Future<void> _logSleep() async {
    final bedAt = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 23, minute: 0),
      helpText: ref.tr('fitness_sleep_pick_bed'),
      builder: _pickerTheme,
    );
    if (bedAt == null || !mounted) return;
    final wakeAt = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
      helpText: ref.tr('fitness_sleep_pick_wake'),
      builder: _pickerTheme,
    );
    if (wakeAt == null || !mounted) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Gio di ngu thuoc dem HOM TRUOC khi no muon hon gio thuc day (vd 23:00
    // -> 07:00); neu nguoi dung ngu trua (13:00 -> 15:00) thi cung ngay.
    final wakeDateTime = today.add(
      Duration(hours: wakeAt.hour, minutes: wakeAt.minute),
    );
    final bedDay = bedAt.hour > wakeAt.hour
        ? today.subtract(const Duration(days: 1))
        : today;
    final bedDateTime = bedDay.add(
      Duration(hours: bedAt.hour, minutes: bedAt.minute),
    );

    await ref
        .read(sleepRepositoryProvider)
        .save(
          SleepEntry(date: today, bedAt: bedDateTime, wakeAt: wakeDateTime),
        );
    ref.invalidate(sleepHistoryProvider);
    ref.invalidate(_last7SleepProvider);
  }

  static Widget _pickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.dark(
          primary: FitnessHome.red,
          surface: FitnessHome.card,
        ),
      ),
      child: child!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(sleepHistoryProvider).valueOrNull ?? const [];
    final latest = history.isEmpty ? null : history.first;

    return FitnessScreenScaffold(
      title: ref.tr('fitness_sleep_title'),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 8),
        children: [
          FitnessCard(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
            child: Column(
              children: [
                Text(
                  ref.tr('fitness_sleep_last_night'),
                  style: FitnessHome.bodySecondary(size: 12.5),
                ),
                const SizedBox(height: 14),
                _SleepRing(minutes: latest?.minutes ?? 0),
                const SizedBox(height: 14),
                if (latest != null)
                  Text(
                    '${_hhmm(latest.bedAt)} → ${_hhmm(latest.wakeAt)}',
                    style: FitnessHome.bodySecondary(size: 12.5),
                  )
                else
                  Text(
                    ref.tr('fitness_sleep_empty'),
                    textAlign: TextAlign.center,
                    style: FitnessHome.bodySecondary(size: 12.5),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: PillButton(
                    label: ref.tr('fitness_sleep_log'),
                    accentColor: FitnessHome.red,
                    accentGradient: AppColors.fitnessAccentGradient,
                    onTap: _logSleep,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FitnessSectionHeader(title: ref.tr('fitness_sleep_week')),
          const SizedBox(height: 10),
          FitnessCard(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
            child: _WeekChart(
              minutes: ref.watch(_last7SleepProvider).valueOrNull ?? const [],
            ),
          ),
          const SizedBox(height: 14),
          FitnessSectionHeader(title: ref.tr('fitness_sleep_history')),
          const SizedBox(height: 10),
          if (history.isEmpty)
            FitnessCard(
              padding: const EdgeInsets.all(16),
              child: Text(
                ref.tr('fitness_sleep_empty'),
                style: FitnessHome.bodySecondary(size: 12.5),
              ),
            )
          else
            for (final entry in history.take(14))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FitnessCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.bedtime_rounded,
                        size: 18,
                        color: FitnessHome.red,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${entry.date.day}/${entry.date.month}',
                        style: FitnessHome.bodySecondary(size: 12.5),
                      ),
                      const Spacer(),
                      Text(
                        _duration(entry.minutes),
                        style: AppTextStyles.heading(size: 15),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  static String _hhmm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}';
}

String _duration(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '${h}h' : '${h}h${m.toString().padLeft(2, '0')}';
}

/// 7 ngay gan nhat - tach thanh provider rieng (khong tinh lai trong
/// build) de khong doc lai shared_preferences moi lan ve lai man hinh.
final _last7SleepProvider = FutureProvider.autoDispose<List<int>>(
  (ref) => ref.watch(sleepRepositoryProvider).getLast7Days(),
);

class _SleepRing extends StatelessWidget {
  const _SleepRing({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    final fraction = (minutes / kSleepGoalMinutes).clamp(0.0, 1.0);
    return SizedBox(
      width: 148,
      height: 148,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: fraction),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        builder: (context, value, _) => Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 8,
                backgroundColor: FitnessHome.divider,
                valueColor: const AlwaysStoppedAnimation(FitnessHome.red),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  minutes == 0 ? '--' : _duration(minutes),
                  style: AppTextStyles.heading(size: 30),
                ),
                Text(
                  '/ ${_duration(kSleepGoalMinutes)}',
                  style: FitnessHome.statUnit(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekChart extends StatelessWidget {
  const _WeekChart({required this.minutes});

  /// 7 gia tri, index 0 la 6 ngay truoc, index 6 la hom nay.
  final List<int> minutes;

  @override
  Widget build(BuildContext context) {
    if (minutes.length != 7) return const SizedBox(height: 92);
    final today = DateTime.now();
    final maxValue = minutes.fold<int>(
      kSleepGoalMinutes,
      (m, v) => v > m ? v : m,
    );
    return SizedBox(
      height: 92,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final daysAgo = 6 - i;
          final weekday = today.subtract(Duration(days: daysAgo)).weekday;
          final value = minutes[i];
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    value == 0 ? '' : (value / 60).toStringAsFixed(1),
                    style: FitnessHome.bodySecondary(size: 9),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOut,
                    height: 6 + 50 * (value / maxValue).clamp(0.0, 1.0),
                    decoration: BoxDecoration(
                      color: value >= kSleepGoalMinutes
                          ? FitnessHome.red
                          : FitnessHome.red.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _weekdayShort[weekday - 1],
                    style: FitnessHome.bodySecondary(size: 9.5),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

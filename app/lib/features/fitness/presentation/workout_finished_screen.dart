import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../planner/presentation/planner_links.dart';
import '../data/workout_model.dart';

/// Man tong ket sau khi hoan thanh buoi tap - port tu SessionFinishedContent
/// cua FitViet (Gate 4), rut gon con 3 chi so (thoi luong/tong kg/so set) +
/// nut chia se len Cong dong (Gate 40/41, Phase 6) - KHONG port calo uoc
/// luong (Gate 19, dua tren can nang gia dinh co dinh, chu dong bo qua).
class WorkoutFinishedScreen extends ConsumerStatefulWidget {
  const WorkoutFinishedScreen({
    super.key,
    required this.controller,
    this.wordsReviewed = 0,
  });

  /// Man nay NHAN QUYEN SO HUU controller tu WorkoutSessionScreen (man do
  /// khong dispose khi da chuyen sang day) va tu dispose khi dong.
  final WorkoutController controller;

  /// So the tu vung da on trong luc nghi cua buoi tap.
  final int wordsReviewed;

  @override
  ConsumerState<WorkoutFinishedScreen> createState() =>
      _WorkoutFinishedScreenState();
}

class _WorkoutFinishedScreenState extends ConsumerState<WorkoutFinishedScreen> {
  bool _shared = false;
  bool _sharing = false;
  bool _statsRefreshed = false;
  late final WorkoutOutbox _outbox = ref.read(workoutOutboxProvider);

  @override
  void initState() {
    super.initState();
    // Xong buoi tap -> tu tick "Hoan thanh" lan tap hom nay trong Lap ke
    // hoach (neu chuong trinh da duoc them vao ke hoach). KHONG tick khi
    // nguoi dung "Luu & ket thuc" som giua chung.
    final programId = widget.controller.programId;
    if (programId != null && widget.controller.completedAllSets) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => completeFitnessProgramToday(ref, programId),
      );
    }
    _outbox.addListener(_refreshStatsWhenSynced);
    // Khong invalidate provider ngay trong initState (dang build cay widget).
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _refreshStatsWhenSynced(),
    );
  }

  /// Buoi tap len server xong (co the tre neu dang mat mang) -> lam moi so
  /// lieu Trang chu Fitness/Thong ke dang mo ben duoi.
  void _refreshStatsWhenSynced() {
    if (!mounted ||
        _statsRefreshed ||
        widget.controller.syncState != WorkoutSyncState.synced) {
      return;
    }
    _statsRefreshed = true;
    ref
      ..invalidate(fitnessDashboardStatsProvider)
      ..invalidate(fitnessHistorySeriesProvider);
  }

  @override
  void dispose() {
    _outbox.removeListener(_refreshStatsWhenSynced);
    widget.controller.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    if (_shared || _sharing) return;
    setState(() => _sharing = true);
    try {
      final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
      if (userId == null) return;
      final profile = await ref.read(myProfileProvider.future);
      String? programTitle;
      final programId = widget.controller.programId;
      if (programId != null) {
        final programs = await ref.read(programListProvider.future);
        for (final p in programs) {
          if (p.id == programId) {
            programTitle = p.titleFor(ref.read(appLanguageProvider));
            break;
          }
        }
      }
      await ref
          .read(communityRepositoryProvider)
          .shareWorkout(
            userId: userId,
            displayName: profile.nameLabel,
            programTitle: programTitle,
            durationSeconds: widget.controller.elapsed.inSeconds,
            totalVolumeKg: widget.controller.totalVolumeKg,
          );
      ref.invalidate(fitnessCommunityFeedProvider);
      if (mounted) setState(() => _shared = true);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final duration = controller.elapsed;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return ScreenBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.fitnessAccent,
                size: 72,
              ),
              const SizedBox(height: 16),
              Text(
                ref.tr(
                  controller.completedAllSets
                      ? 'fitness_workout_finished_title'
                      : 'fitness_workout_ended_early',
                ),
                style: AppTextStyles.heading(size: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              _SyncStatus(controller: controller),
              const SizedBox(height: 18),
              GlowBox(
                padding: const EdgeInsets.all(18),
                borderRadius: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SummaryTile(
                      label: ref.tr('fitness_workout_duration'),
                      value:
                          '${minutes}p ${seconds.toString().padLeft(2, '0')}s',
                    ),
                    _SummaryTile(
                      label: ref.tr('fitness_workout_total_volume'),
                      value: '${controller.totalVolumeKg.toStringAsFixed(0)}kg',
                    ),
                    _SummaryTile(
                      label: ref.tr('fitness_workout_total_sets'),
                      value: '${controller.totalSetsLogged}',
                    ),
                    if (widget.wordsReviewed > 0)
                      _SummaryTile(
                        label: ref.tr('fitness_workout_words_reviewed'),
                        value: '${widget.wordsReviewed}',
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PillButton(
                label: ref.tr(
                  _shared ? 'fitness_workout_shared' : 'fitness_workout_share',
                ),
                accentColor: AppColors.fitnessAccent,
                filled: !_shared,
                icon: _shared
                    ? null
                    : const Icon(
                        Icons.ios_share_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                onTap: _shared ? null : _share,
              ),
              const SizedBox(height: 16),
              PillButton(
                label: ref.tr('fitness_workout_back_home'),
                accentColor: AppColors.fitnessAccent,
                filled: false,
                onTap: () {
                  // Toan bo luong Giao an/Tap luyen (danh sach -> chi tiet ->
                  // preview -> session -> man nay) deu la cac popup rieng
                  // (openAppPopup) CHONG LEN NHAU tren CUNG 1 Navigator goc
                  // (useRootNavigator: true, khong tao Navigator rieng) - can
                  // dong het ca chuoi de ve lai dung Home, khong chi 1 pop
                  // don le. r.isFirst = route dau tien (man Home thuc), giu
                  // dung quy uoc nhu ielts_result_screen/toeic_result_screen.
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.heading(size: 18)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.muted()),
      ],
    );
  }
}

/// Trang thai luu buoi tap len server (qua WorkoutOutbox) - de nguoi dung
/// biet khi dang mat mang va buoi tap chua duoc luu, kem nut thu lai.
class _SyncStatus extends ConsumerWidget {
  const _SyncStatus({required this.controller});
  final WorkoutController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outbox = ref.watch(workoutOutboxProvider);
    return ListenableBuilder(
      listenable: outbox,
      builder: (context, _) {
        final state = controller.syncState;
        final (icon, color, key) = switch (state) {
          WorkoutSyncState.synced => (
            Icons.cloud_done_rounded,
            AppColors.wealthUp,
            'fitness_workout_sync_synced',
          ),
          WorkoutSyncState.pending => (
            Icons.cloud_upload_rounded,
            AppColors.fitnessTextSecondary,
            'fitness_workout_sync_pending',
          ),
          WorkoutSyncState.failed => (
            Icons.cloud_off_rounded,
            AppColors.amber,
            'fitness_workout_sync_failed',
          ),
        };
        return Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          children: [
            Icon(icon, size: 18, color: color),
            Text(
              ref.tr(key),
              textAlign: TextAlign.center,
              style: AppTextStyles.body(size: 13, color: color),
            ),
            if (state == WorkoutSyncState.failed)
              TextButton(
                onPressed: outbox.retryNow,
                child: Text(ref.tr('fitness_workout_sync_retry')),
              ),
          ],
        );
      },
    );
  }
}

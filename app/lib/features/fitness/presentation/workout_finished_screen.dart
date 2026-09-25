import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/tts/app_tts.dart';
import '../../planner/presentation/planner_links.dart';
import '../../today/data/daily_progress_store.dart';
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
    this.coachLine,
  });

  /// Cau chuc mung cua giong HLV (null = tat giong HLV).
  final String? coachLine;

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
  bool _sharingImage = false;

  /// Vung "the ket qua" duoc chup thanh anh de chia se ra app khac.
  final _cardKey = GlobalKey();
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) completeFitnessProgramToday(ref, programId);
      });
    }
    final coachLine = widget.coachLine;
    if (coachLine != null) AppTts.instance.speak(coachLine);
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
      ..invalidate(fitnessHistorySeriesProvider)
      // Buoi tap hoan thanh duoc cong vao GymTalk XP (migration 0073).
      ..invalidate(myLearningXpProvider);
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

  /// Chup the ket qua (RepaintBoundary) thanh PNG roi mo bang chia se cua he
  /// thong (Zalo, Messenger, Instagram...).
  Future<void> _shareImage() async {
    if (_sharingImage) return;
    setState(() => _sharingImage = true);
    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) return;
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/gymtalk_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(data.buffer.asUint8List());
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: AppStrings.t('share_card_text', ref.read(appLanguageProvider)),
        ),
      );
    } catch (e) {
      debugPrint('share image failed: $e');
    } finally {
      if (mounted) setState(() => _sharingImage = false);
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
              RepaintBoundary(
                key: _cardKey,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgTop,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.fitness_center_rounded,
                            color: AppColors.fitnessAccent,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'GymTalk',
                            style: AppTextStyles.heading(size: 16),
                          ),
                          const Spacer(),
                          Text(
                            '🔥 ${DailyProgressStore.instance.bodyBrainStreak}'
                            ' · Body + Brain',
                            style: AppTextStyles.body(
                              size: 12,
                              color: AppColors.amber,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _summaryBox(controller, minutes, seconds),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              PillButton(
                label: ref.tr(
                  _sharingImage ? 'share_card_preparing' : 'share_card_button',
                ),
                accentColor: AppColors.fitnessAccent,
                filled: false,
                icon: const Icon(
                  Icons.image_outlined,
                  size: 16,
                  color: AppColors.fitnessAccent,
                ),
                onTap: _sharingImage ? null : _shareImage,
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
                onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryBox(WorkoutController controller, int minutes, int seconds) {
    return GlowBox(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryTile(
            label: ref.tr('fitness_workout_duration'),
            value: '${minutes}p ${seconds.toString().padLeft(2, '0')}s',
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
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    // Expanded: toi 4 o tren 1 hang (co them "Tu da on") - khong tran tren
    // man 360dp.
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: AppTextStyles.heading(size: 18)),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: AppTextStyles.muted(),
          ),
        ],
      ),
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

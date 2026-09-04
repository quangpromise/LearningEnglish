import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/workout_model.dart';

/// Man tong ket sau khi hoan thanh buoi tap - port tu SessionFinishedContent
/// cua FitViet (Gate 4), rut gon con 3 chi so (thoi luong/tong kg/so set) -
/// KHONG port calo uoc luong (Gate 19, dua tren can nang gia dinh co dinh,
/// da chu dong bo qua o Phase 2 nay) va KHONG co nut chia se Cong dong (Gate
/// 40/41, ngoai pham vi phase nay).
class WorkoutFinishedScreen extends ConsumerWidget {
  const WorkoutFinishedScreen({super.key, required this.controller});
  final WorkoutController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                ref.tr('fitness_workout_finished_title'),
                style: AppTextStyles.heading(size: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
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
                  ],
                ),
              ),
              const SizedBox(height: 32),
              PillButton(
                label: ref.tr('fitness_workout_back_home'),
                accentColor: AppColors.fitnessAccent,
                onTap: () {
                  // Toan bo luong Giao an/Tap luyen (danh sach -> chi tiet ->
                  // preview -> session -> man nay) deu push/pushReplacement
                  // TREN CUNG 1 Navigator goc voi popup mo tu FitnessHomeScreen
                  // (openAppPopup dung useRootNavigator: true, khong tao
                  // Navigator rieng) - can dong het ca chuoi lan luot ca
                  // chinh cai bottom sheet do de that su ve lai Home, khong
                  // chi 1 pop don le.
                  final navigator = Navigator.of(context);
                  navigator.popUntil((r) => r is ModalBottomSheetRoute);
                  navigator.pop();
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/ielts_attempt_repository.dart';

/// Danh sach cac lan lam bai IELTS truoc do - mirror toeic_history_screen.dart.
class IeltsHistoryScreen extends ConsumerWidget {
  const IeltsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(ieltsAttemptHistoryProvider);
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  ref.tr('toeic_history_title'),
                  style: AppTextStyles.heading(size: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: historyAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.blue),
                ),
                error: (_, _) => Center(
                  child: Text(
                    ref.tr('wealth_load_error'),
                    style: AppTextStyles.muted(),
                  ),
                ),
                data: (records) {
                  if (records.isEmpty) {
                    return Center(
                      child: Text(
                        ref.tr('toeic_history_empty'),
                        style: AppTextStyles.muted(),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: records.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) =>
                        _AttemptRow(record: records[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttemptRow extends ConsumerWidget {
  const _AttemptRow({required this.record});
  final IeltsAttemptRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExam = record.mode == 'exam';
    final d = record.createdAt;
    final dateLabel =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    return GlowBox(
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: (isExam ? AppColors.pink : AppColors.teal).withValues(
                alpha: 0.16,
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              isExam
                  ? ref.tr('toeic_mode_exam')
                  : ref.tr('toeic_mode_practice'),
              style: TextStyle(
                color: isExam ? AppColors.pink : AppColors.teal,
                fontWeight: FontWeight.w800,
                fontSize: 10.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateLabel,
                  style: AppTextStyles.body(
                    weight: FontWeight.w700,
                    size: 12.5,
                  ),
                ),
                Text(
                  '${record.listeningCorrect + record.readingCorrect}/'
                  '${record.listeningTotal + record.readingTotal} câu đúng',
                  style: AppTextStyles.muted(size: 10.5),
                ),
              ],
            ),
          ),
          Text(
            record.bandOverall?.toStringAsFixed(1) ?? '-',
            style: AppTextStyles.heading(size: 18)
                .copyWith(color: AppColors.wealthAccent),
          ),
        ],
      ),
    );
  }
}

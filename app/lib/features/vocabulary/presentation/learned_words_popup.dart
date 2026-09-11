import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/speaker_button.dart';
import '../data/vocabulary_data.dart';

/// Popup "Words Learned" - mo tu the thong ke cung ten o man Ho so
/// (_StatCard 'profile_words_learned'). CHI hien danh sach tu da duoc
/// nguoi dung tu bam "Đánh dấu đã học" o man Tu vung theo chu de
/// (xem learnedVocabWordsProvider) - khong lay/tron them du lieu tu bat ky
/// nguon nao khac (vd daily quiz).
class LearnedWordsPopup extends ConsumerWidget {
  const LearnedWordsPopup({super.key});

  Future<void> _unlearn(WidgetRef ref, VocabWord word) async {
    await ref.read(statsRepositoryProvider).unlearnWord(word.en);
    ref.invalidate(learnedWordsProvider);
    ref.invalidate(learnedVocabWordsProvider);
    ref.invalidate(myStatsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(learnedVocabWordsProvider);
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
                Expanded(
                  child: Text(
                    ref.tr('profile_words_learned'),
                    style: AppTextStyles.heading(size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: wordsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.blue),
                ),
                error: (_, _) =>
                    Center(child: Text(ref.tr('wealth_load_error'))),
                data: (words) => words.isEmpty
                    ? Center(
                        child: Text(
                          ref.tr('vocab_learned_empty'),
                          style: AppTextStyles.muted(),
                        ),
                      )
                    : ListView.separated(
                        itemCount: words.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final word = words[i];
                          return GlowBox(
                            borderRadius: 16,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            word.en,
                                            style: AppTextStyles.body(
                                              weight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            word.ipa,
                                            style: AppTextStyles.muted(
                                              size: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        word.vi,
                                        style: AppTextStyles.muted(size: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                // Dung SpeakerButton (vung bam co dinh
                                // 40x40) thay vi Icon boc GestureDetector
                                // tran nhu truoc - vung bam cu chi bang kich
                                // thuoc hinh hoc cua icon (~18-24px), rat kho
                                // bam trung tren dien thoai that (cung 1 loi
                                // da gap o man Tu vung theo chu de, xem
                                // doc-comment cua SpeakerButton).
                                Tooltip(
                                  message: ref.tr('vocab_unmark_learned'),
                                  child: SpeakerButton(
                                    icon: Icons.close_rounded,
                                    iconSize: 18,
                                    color: AppColors.textMuted,
                                    onTap: () => _unlearn(ref, word),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_language.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/theme/app_theme.dart';
import '../data/writing_paragraph_data.dart';

/// Bo 24 doan "Tong hop 12 thi" cu (kWritingParagraphs, moi doan tron nhieu
/// thi) - nay la 1 muc rieng trong man chon chu de Doan van (xem
/// WritingParagraphListScreen), chi hien khi Tu hoc hoac cap Nang cao vi
/// doan nao cung co thi kho (hoan thanh tiep dien...).
class WritingMixedParagraphListScreen extends ConsumerWidget {
  const WritingMixedParagraphListScreen({
    super.key,
    required this.onBack,
    required this.onOpenParagraph,
  });

  final VoidCallback onBack;
  final void Function(WritingParagraph paragraph) onOpenParagraph;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appLanguageProvider);
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PopupBackButton(onBack: onBack),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ref.tr('writing_mixed_title'),
                        style: AppTextStyles.heading(size: 18),
                      ),
                      Text(
                        ref.tr('writing_paragraph_pick_hint'),
                        style: AppTextStyles.muted(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                itemCount: kWritingParagraphs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final p = kWritingParagraphs[i];
                  final title = lang == AppLanguage.en ? p.titleEn : p.titleVi;
                  return GestureDetector(
                    onTap: () => onOpenParagraph(p),
                    child: GlowBox(
                      borderRadius: 18,
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.teal,
                                  AppColors.teal.withValues(alpha: 0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: AppTextStyles.body(
                                    weight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '${p.sentences.length} ${ref.tr('writing_sentence_count')}',
                                  style: AppTextStyles.muted(size: 11),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                    ),
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

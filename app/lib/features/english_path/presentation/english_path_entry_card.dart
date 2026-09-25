import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_language.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/english_path_progress.dart';
import '../data/english_path_providers.dart';
import 'english_path_screen.dart';

/// The mong o dau tab Hoc: English Level + Unit ke tiep, bam mo man Lo trinh.
class EnglishPathEntryCard extends ConsumerWidget {
  const EnglishPathEntryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final level = ref.watch(englishLevelProvider);
    final state = ref.watch(englishPathStoreProvider).state;
    final pack = ref.watch(contentPackProvider).valueOrNull;
    final lang = ref.watch(appLanguageProvider);
    final next = pack == null ? null : nextUnit(pack, level, state);
    final subtitle = next == null
        ? ref.tr('path_entry_subtitle_idle')
        : '${ref.tr('path_unit_label').replaceFirst('{n}', '${next.index}')}'
              ' · ${lang == AppLanguage.en ? next.titleEn : next.titleVi}'
              ' · ${(unitProgress(next, state) * 100).round()}%';
    return GestureDetector(
      onTap: () => openAppPopup(context, const EnglishPathScreen()),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.blue.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.blue.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(level.code, style: AppTextStyles.heading(size: 13)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref.tr('path_title'),
                    style: AppTextStyles.body(size: 13),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.muted(size: 11),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/ielts_models.dart';

/// Hien 1 bai doc Reading - copy gan nguyen ven ToeicPassageView, doi ten
/// truong `textsEn` -> `paragraphsEn` (moi doan la 1 phan tu, thuong bat
/// dau bang "A.", "B."... de ho tro cau hoi Matching Information).
class IeltsPassageView extends StatelessWidget {
  const IeltsPassageView({super.key, required this.passage});

  final IeltsPassage passage;

  @override
  Widget build(BuildContext context) {
    return GlowBox(
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            passage.titleEn,
            style: AppTextStyles.muted(
              size: 10,
              weight: FontWeight.w800,
            ).copyWith(letterSpacing: 0.6),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < passage.paragraphsEn.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            Text(
              passage.paragraphsEn[i],
              style: AppTextStyles.body(size: 13).copyWith(height: 1.6),
            ),
          ],
        ],
      ),
    );
  }
}

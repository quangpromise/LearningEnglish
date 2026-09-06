import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/toeic_models.dart';

/// Hien 1 doan van doc hieu Part 6/7 - don (1 text), doi (2 text) hoac ba
/// (3 text) deu render nhu nhau, ngan cach boi 1 duong ke va nhan "Van ban
/// N" khi co nhieu hon 1 doan.
class ToeicPassageView extends StatelessWidget {
  const ToeicPassageView({super.key, required this.passage});

  final ToeicPassage passage;

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
          for (var i = 0; i < passage.textsEn.length; i++) ...[
            if (i > 0) ...[
              const SizedBox(height: 12),
              const Divider(color: AppColors.glassBorder, height: 1),
              const SizedBox(height: 12),
              if (passage.textsEn.length > 1)
                Text(
                  'Văn bản ${i + 1}',
                  style: AppTextStyles.muted(size: 10, weight: FontWeight.w800),
                ),
              const SizedBox(height: 6),
            ] else
              const SizedBox(height: 8),
            Text(
              passage.textsEn[i],
              style: AppTextStyles.body(size: 13).copyWith(height: 1.6),
            ),
          ],
        ],
      ),
    );
  }
}

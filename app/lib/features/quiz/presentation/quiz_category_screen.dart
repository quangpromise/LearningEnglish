import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/theme/app_theme.dart';
import '../data/quiz_data.dart';
import 'quiz_question_screen.dart';

// Danh sach icon/mau CO DINH theo dung thu tu [kCategories] trong
// quiz_data.dart. QUAN TRONG: 2 danh sach nay phai co it nhat bang so luong
// phan tu cua kCategories - neu khong `_catIcons[i]`/`_catColors[i]` se nem
// RangeError ngay trong itemBuilder, khien Flutter (o che do release) render
// 1 o trong/xam thay vi loi do, nhin giong "man hinh trang xoa" (bug thuc te
// da gap khi them 5 chu de moi ma quen cap nhat 2 danh sach nay). Moi khi
// them chu de moi vao kCategories, PHAI them 1 dong tuong ung o day.
const _catIcons = [
  Icons.extension_rounded, // Choi chu
  Icons.psychology_alt_rounded, // Suy luan
  Icons.pets_rounded, // Dong vat
  Icons.home_rounded, // Cuoc song
  Icons.abc_rounded, // Bang chu cai
  Icons.directions_car_filled_rounded, // Trai cay & xe co
  Icons.eco_rounded, // Trai cay & rau cu
  Icons.local_shipping_rounded, // Phuong tien giao thong
  Icons.wb_sunny_rounded, // Thoi tiet & thien nhien
  Icons.chair_rounded, // Do vat trong nha
  Icons.palette_rounded, // Mau sac
];
const _catColors = [
  AppColors.blue,
  AppColors.teal,
  AppColors.pink,
  AppColors.amber,
  AppColors.purple,
  AppColors.blue,
  AppColors.teal,
  AppColors.pink,
  AppColors.amber,
  AppColors.purple,
  AppColors.blue,
];

class QuizCategoryScreen extends ConsumerWidget {
  const QuizCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ref.tr('quiz_title'),
                        style: AppTextStyles.heading(size: 20),
                      ),
                      Text(
                        ref.tr('quiz_subtitle'),
                        style: AppTextStyles.muted(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: GridView.builder(
                itemCount: kCategories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, i) {
                  final cat = kCategories[i];
                  final count = kRiddles.where((r) => r.category == cat).length;
                  return GestureDetector(
                    onTap: () {
                      final riddles = kRiddles
                          .where((r) => r.category == cat)
                          .toList();
                      openAppPopup(
                        context,
                        QuizQuestionScreen(
                          category: cat,
                          riddles: riddles.isEmpty ? kRiddles : riddles,
                        ),
                      );
                    },
                    child: GlowBox(
                      borderRadius: 22,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _catColors[i],
                                  _catColors[i].withValues(alpha: 0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              _catIcons[i],
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            categoryLabel(ref, cat),
                            style: AppTextStyles.body(weight: FontWeight.w800),
                          ),
                          Text(
                            '$count ${ref.tr('quiz_riddle_count')}',
                            style: AppTextStyles.muted(size: 11),
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

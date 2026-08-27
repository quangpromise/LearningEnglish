import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/quiz_data.dart';
import 'quiz_question_screen.dart';

const _catIcons = [
  Icons.extension_rounded,
  Icons.psychology_alt_rounded,
  Icons.pets_rounded,
  Icons.home_rounded,
  Icons.abc_rounded,
  Icons.directions_car_filled_rounded,
];
const _catColors = [
  AppColors.blue,
  AppColors.teal,
  AppColors.pink,
  AppColors.amber,
  AppColors.purple,
  AppColors.blue,
];

class QuizCategoryScreen extends StatelessWidget {
  const QuizCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đố vui tiếng Anh',
                      style: AppTextStyles.heading(size: 20),
                    ),
                    Text(
                      'Chọn chủ đề để bắt đầu thử thách',
                      style: AppTextStyles.muted(),
                    ),
                  ],
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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => QuizQuestionScreen(
                            category: cat,
                            riddles: riddles.isEmpty ? kRiddles : riddles,
                          ),
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
                            cat,
                            style: AppTextStyles.body(weight: FontWeight.w800),
                          ),
                          Text(
                            '$count câu đố',
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

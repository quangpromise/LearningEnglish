import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_language.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/phonics_data.dart';
import 'phonics_lesson_detail_screen.dart';

String phonicsLessonLabel(WidgetRef ref, PhonicsLesson lesson) =>
    ref.watch(appLanguageProvider) == AppLanguage.en
    ? lesson.titleEn
    : lesson.title;

/// Danh sach 12 bai hoc phat am co cau truc (am vi -> trong am -> ngu dieu
/// -> noi am) - xem docs/research-pronunciation-lessons.md. Vao tu man Menu,
/// canh Doc sach/Do vui. Dong thoi la khung duy nhat cho ca luong (danh
/// sach -> chi tiet 1 bai, ke ca chuyen bai truoc/sau), KHONG mo them popup
/// - xem giai thich chi tiet trong VocabularyTopicsScreen (cung nguyen tac).
class PhonicsLessonsScreen extends StatefulWidget {
  const PhonicsLessonsScreen({super.key});

  @override
  State<PhonicsLessonsScreen> createState() => _PhonicsLessonsScreenState();
}

class _PhonicsLessonsScreenState extends State<PhonicsLessonsScreen> {
  int? _activeIndex;

  @override
  Widget build(BuildContext context) {
    final index = _activeIndex;
    if (index != null) {
      return PhonicsLessonDetailScreen(
        lesson: kPhonicsLessons[index],
        index: index,
        onBack: () => setState(() => _activeIndex = null),
        onGoTo: (newIndex) => setState(() => _activeIndex = newIndex),
      );
    }
    return Consumer(builder: (context, ref, _) => _buildList(context, ref));
  }

  Widget _buildList(BuildContext context, WidgetRef ref) {
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
                        ref.tr('phonics_title'),
                        style: AppTextStyles.heading(size: 18),
                      ),
                      Text(
                        ref.tr('phonics_subtitle'),
                        style: AppTextStyles.muted(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: kPhonicsLessons.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final lesson = kPhonicsLessons[i];
                  return GestureDetector(
                    onTap: () => setState(() => _activeIndex = i),
                    child: GlowBox(
                      borderRadius: 18,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  lesson.color,
                                  lesson.color.withValues(alpha: 0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  phonicsLessonLabel(ref, lesson),
                                  style: AppTextStyles.body(
                                    weight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '${lesson.items.length} ${ref.tr('phonics_sound_count')}',
                                  style: AppTextStyles.muted(size: 11.5),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: lesson.color,
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

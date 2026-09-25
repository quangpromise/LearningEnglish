import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:math';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/nav_keys.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/tts/app_tts.dart';
import '../data/exercise_model.dart';
import '../../srs/data/srs_store.dart';
import '../data/exercise_tutorial.dart';
import '../data/workout_model.dart';
import 'exercise_photo_animator.dart';
import 'exercise_tutorial_player.dart';
import 'workout_session_screen.dart';
import '../data/exercise_i18n.dart';

/// Chi tiet 1 bai tap - huong dan tung buoc + thanh % tham gia cua tung
/// nhom co (an neu involvementPercents rong - day la tin hieu CHU DONG
/// "an the nay" tu du lieu goc FitViet, khong phai thieu du lieu, xem
/// exercise_model.dart).
class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
    required this.onBack,
  });
  final Exercise exercise;
  final VoidCallback onBack;

  /// Mo trinh phat huong dan doc toan man hinh (chi chay khi bam) - route
  /// ten kPronunciationRouteName vi co "Noi theo" dung mic (nut AI Voice
  /// Chat biet mic dang ban).
  void _openTutorial(BuildContext context, WidgetRef ref, {int chapter = 0}) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: kPronunciationRouteName),
        fullscreenDialog: true,
        builder: (_) => ExerciseTutorialPlayer(
          exercise: exercise,
          startChapter: chapter,
          onStartWorkout: () => _startWorkout(context, ref),
        ),
      ),
    );
  }

  /// "Tap bai nay": 1 buoi tap rieng chi gom bai nay (so set/rep goi y cua
  /// bai, muc ta goi y = muc nang nhat tung log).
  Future<void> _startWorkout(BuildContext context, WidgetRef ref) async {
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    var weight = kDefaultRecommendedWeightKg;
    if (userId != null) {
      try {
        weight =
            await ref
                .read(workoutRepositoryProvider)
                .getRecommendedWeight(userId, exercise.id) ??
            weight;
      } catch (_) {}
    }
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => WorkoutSessionScreen(
          blocks: [
            WorkoutExerciseBlock(
              exercise: exercise,
              targetSets: max(1, exercise.suggestedSetsMin),
              targetRepsMin: exercise.suggestedRepsMin,
              targetRepsMax: max(
                exercise.suggestedRepsMin,
                exercise.suggestedRepsMax,
              ),
              recommendedWeightKg: weight,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appLanguageProvider);
    final favoritesAsync = ref.watch(favoriteExerciseIdsProvider);
    final isFavorite =
        favoritesAsync.valueOrNull?.contains(exercise.id) ?? false;
    final muscles = exercise.displayedMuscles;
    final percents = exercise.involvementPercents;
    final showInvolvement =
        percents.isNotEmpty && percents.length == muscles.length;
    final tutorial = buildExerciseTutorial(
      exercise,
      boxes: SrsStore.instance.boxes,
    );

    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CircleBtn(icon: Icons.chevron_left_rounded, onTap: onBack),
                const Spacer(),
                _CircleBtn(
                  icon: isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  iconColor: isFavorite ? AppColors.pink : null,
                  onTap: () => ref
                      .read(favoriteExerciseIdsProvider.notifier)
                      .toggle(exercise.id),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Tong quan GIU anh 2 tu the (xem nhanh, khong ton data) + nut
            // mo video huong dan noi ben tren.
            Stack(
              children: [
                ExercisePhotoAnimator(assets: exercise.photoAssets),
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: _OverlayTag(label: ref.tr('tutorial_two_poses')),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: _PlayPill(
                    label: ref.tr('tutorial_open'),
                    onTap: () => _openTutorial(context, ref),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              exercise.nameFor(lang),
              style: AppTextStyles.heading(size: 20),
            ),
            Text(exercise.altNameFor(lang), style: AppTextStyles.muted()),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Tag(
                  label: ref.tr(exercise.difficulty.labelKey),
                  color: AppColors.amber,
                ),
                _Tag(
                  label: ref.tr(exercise.muscleGroup.labelKey),
                  color: AppColors.teal,
                ),
                _Tag(
                  label: exerciseEquipmentLabel(exercise.equipment, lang),
                  color: AppColors.purple,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              ref.tr('tutorial_chapters_title'),
              style: AppTextStyles.muted(size: 11, weight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: tutorial.chapters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) => _ChapterChip(
                  chapter: tutorial.chapters[i],
                  photos: exercise.photoAssets,
                  onTap: () => _openTutorial(context, ref, chapter: i),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  if (tutorial.keywords.isNotEmpty) ...[
                    Text(
                      ref.tr('tutorial_keywords_section'),
                      style: AppTextStyles.heading(size: 14),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final word in tutorial.keywords)
                          _KeywordChip(
                            en: word.en,
                            vi: word.vi,
                            onTap: () => AppTts.instance.speak(word.en),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                  ],
                  if (showInvolvement) ...[
                    Text(
                      ref.tr('fitness_involvement_title'),
                      style: AppTextStyles.heading(size: 14),
                    ),
                    const SizedBox(height: 12),
                    for (var i = 0; i < muscles.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _InvolvementBar(
                          // Ten nhom co trong file noi dung chi co tieng Viet
                          // -> phai qua exerciseMuscleLabel giong man Thu vien
                          // bai tap, neu khong se con "Xo · chinh" o ban tieng
                          // Anh.
                          label: exerciseMuscleLabel(muscles[i], lang),
                          percent: percents[i],
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    ref.tr('fitness_instructions_title'),
                    style: AppTextStyles.heading(size: 14),
                  ),
                  const SizedBox(height: 12),
                  for (
                    var i = 0;
                    i < exercise.instructionsFor(lang).length;
                    i++
                  )
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            margin: const EdgeInsets.only(top: 1),
                            decoration: const BoxDecoration(
                              color: AppColors.glassFill,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${i + 1}',
                              style: AppTextStyles.body(
                                size: 11,
                                weight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              exercise.instructionsFor(lang)[i],
                              style: AppTextStyles.body(size: 13.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            PillButton(
              label: ref.tr('tutorial_start_workout_short'),
              accentColor: AppColors.fitnessAccent,
              accentGradient: AppColors.fitnessAccentGradient,
              icon: const Icon(
                Icons.play_arrow_rounded,
                size: 20,
                color: Colors.white,
              ),
              onTap: () => _startWorkout(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nut do "Video huong dan" noi tren anh tong quan.
class _PlayPill extends StatelessWidget {
  const _PlayPill({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.fitnessAccent,
      shape: const StadiumBorder(),
      elevation: 6,
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.fitnessAccent,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.body(size: 13, weight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverlayTag extends StatelessWidget {
  const _OverlayTag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.body(
          size: 11,
          weight: FontWeight.w800,
          color: AppColors.teal,
        ),
      ),
    );
  }
}

/// 1 chuong video (anh thu nho + ten) - bam de mo dung doan.
class _ChapterChip extends ConsumerWidget {
  const _ChapterChip({
    required this.chapter,
    required this.photos,
    required this.onTap,
  });
  final TutorialChapter chapter;
  final List<String> photos;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = switch (chapter.kind) {
      TutorialChapterKind.overview => ref.tr('tutorial_chapter_overview'),
      TutorialChapterKind.step =>
        '${ref.tr('tutorial_step')} ${chapter.stepIndex + 1}',
      TutorialChapterKind.keywords => ref.tr('tutorial_chapter_keywords'),
    };
    final isKeywords = chapter.kind == TutorialChapterKind.keywords;
    final photo = chapter.stepIndex >= 1 ? photos.last : photos.first;
    return Material(
      color: AppColors.fitnessCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 96,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.fitnessCardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: isKeywords
                      ? Container(
                          color: AppColors.blue.withValues(alpha: 0.18),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.translate_rounded,
                            color: AppColors.blue,
                          ),
                        )
                      : Image.asset(photo, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body(size: 11.5, weight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeywordChip extends StatelessWidget {
  const _KeywordChip({required this.en, required this.vi, required this.onTap});
  final String en;
  final String vi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.blue.withValues(alpha: 0.08),
      shape: StadiumBorder(
        side: BorderSide(color: AppColors.blue.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.volume_up_rounded,
                size: 16,
                color: AppColors.blue,
              ),
              const SizedBox(width: 6),
              Text(en, style: AppTextStyles.body(weight: FontWeight.w800)),
              const SizedBox(width: 6),
              Text(vi, style: AppTextStyles.muted(size: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvolvementBar extends StatelessWidget {
  const _InvolvementBar({required this.label, required this.percent});
  final String label;
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.body(size: 12.5)),
            Text(
              '$percent%',
              style: AppTextStyles.body(size: 12.5, weight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 8,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            valueColor: const AlwaysStoppedAnimation(AppColors.fitnessAccent),
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.onTap, this.iconColor});
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: AppColors.glassFill,
          shape: BoxShape.circle,
          border: Border.fromBorderSide(
            BorderSide(color: AppColors.glassBorder),
          ),
        ),
        child: Icon(icon, size: 18, color: iconColor ?? AppColors.textPrimary),
      ),
    );
  }
}

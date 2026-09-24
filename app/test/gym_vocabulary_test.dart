import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/fitness/data/exercise_model.dart';
import 'package:learn_english_music/features/fitness/data/gym_vocabulary.dart';
import 'package:shared_preferences/shared_preferences.dart';

Exercise _exercise(int id, String nameEn, String group) => Exercise(
  id: id,
  nameVi: 'Bai $id',
  nameEn: nameEn,
  primaryMuscle: '',
  secondaryMuscles: const [],
  involvementPercents: const [],
  equipment: '',
  instructions: const ['Buoc 1'],
  instructionsEn: const ['Step 1'],
  suggestedSetsMin: 3,
  suggestedSetsMax: 4,
  suggestedRepsMin: 8,
  suggestedRepsMax: 12,
  suggestedRestSeconds: 60,
  muscleGroupCode: group,
  movementType: '',
  difficultyCode: 'BEGINNER',
  photoSlug: 'x',
);

void main() {
  test('bo tu: khong trung, du truong bat buoc', () {
    final keys = <String>{};
    for (final w in kGymWords) {
      expect(keys.add(w.key), isTrue, reason: 'trung tu ${w.en}');
      expect(w.vi, isNotEmpty);
      expect(w.ipa, startsWith('/'));
      expect(w.exampleEn, isNotEmpty);
      expect(w.exampleVi, isNotEmpty);
    }
    expect(kGymWords.length, greaterThanOrEqualTo(50));
  });

  test('uu tien ten bai tap, roi tu dung nhom co, roi tu chung', () {
    final words = pickGymWords(
      exercises: [_exercise(1, 'Back Squat', 'LEGS')],
      boxes: const {},
      count: 10,
    );
    expect(words.first.en, 'Back Squat');
    final legWords = words.skip(1).takeWhile(
      (w) => w.groups.contains(MuscleGroup.legs),
    );
    expect(legWords, isNotEmpty);
    // Khong lay tu cua nhom co khac (vd nguc) khi con tu chung.
    expect(words.any((w) => w.en == 'chest'), isFalse);
  });

  test('tu da thuoc xuong cuoi, tu chua thuoc len truoc', () {
    final boxes = {'back squat': kGymWordMaxBox, 'squat': 2};
    final words = pickGymWords(
      exercises: [_exercise(1, 'Back Squat', 'LEGS')],
      boxes: boxes,
      count: 200,
    );
    expect(words.last.en, 'Back Squat');
    final squat = words.indexWhere((w) => w.en == 'squat');
    final lunge = words.indexWhere((w) => w.en == 'lunge');
    expect(lunge, lessThan(squat));
  });

  test('khong trung tu khi 2 bai trung ten', () {
    final words = pickGymWords(
      exercises: [
        _exercise(1, 'Plank', 'CORE'),
        _exercise(2, 'Plank', 'CORE'),
      ],
      boxes: const {},
      count: 200,
      random: Random(1),
    );
    final keys = words.map((w) => w.key).toList();
    expect(keys.toSet().length, keys.length);
  });

  test('luu tien do Leitner', () async {
    SharedPreferences.setMockInitialValues({});
    final progress = await GymVocabProgress.load();
    final word = kGymWords.first;
    await progress.markKnown(word);
    await progress.markKnown(word);
    expect((await GymVocabProgress.load()).boxOf(word), 2);
    await progress.markLearning(word);
    expect((await GymVocabProgress.load()).boxOf(word), 0);
    for (var i = 0; i < 10; i++) {
      await progress.markKnown(word);
    }
    expect(progress.boxOf(word), kGymWordMaxBox);
  });
}

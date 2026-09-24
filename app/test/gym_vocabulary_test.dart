import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/fitness/data/exercise_model.dart';
import 'package:learn_english_music/features/fitness/data/gym_vocabulary.dart';
import 'package:learn_english_music/features/srs/data/srs_store.dart';
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
    final boxes = {'back squat': kSrsMasteredBox, 'squat': 2};
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

  test('SRS: nho -> len hop + gian han, quen -> ve hop 0 on hom nay', () async {
    SharedPreferences.setMockInitialValues({});
    final store = SrsStore.forTest();
    final now = DateTime(2026, 9, 24, 20);
    final word = kGymWords.first;
    await store.review(
      word.key,
      known: true,
      now: now,
      content: word.toSrsCard(now),
    );
    expect(store.boxOf(word.key), 1);
    expect(store.dueCount(now), 0);
    expect(store.dueCount(now.add(const Duration(days: 1))), 1);

    await store.review(word.key, known: true, now: now);
    expect(store.boxOf(word.key), 2);
    expect(store.dueCount(now.add(const Duration(days: 2))), 0);
    expect(store.dueCount(now.add(const Duration(days: 3))), 1);

    await store.review(word.key, known: false, now: now);
    expect(store.boxOf(word.key), 0);
    expect(store.dueCards(now).single.en, word.en);

    for (var i = 0; i < 10; i++) {
      await store.review(word.key, known: true, now: now);
    }
    expect(store.boxOf(word.key), kSrsMaxBox);

    // Doc lai tu may.
    final reloaded = SrsStore.forTest();
    await reloaded.ensureLoaded();
    expect(reloaded.boxOf(word.key), kSrsMaxBox);
    expect(reloaded.totalCards, 1);
  });

  test('SRS: them the khong ghi de the da co', () async {
    SharedPreferences.setMockInitialValues({});
    final store = SrsStore.forTest();
    final now = DateTime(2026, 9, 24);
    final card = kGymWords[1].toSrsCard(now);
    await store.addIfAbsent(card);
    await store.review(card.key, known: true, now: now);
    await store.addIfAbsent(card);
    expect(store.boxOf(card.key), 1);
  });
}

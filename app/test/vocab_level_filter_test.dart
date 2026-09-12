import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/learning_path/data/learning_path_models.dart';
import 'package:learn_english_music/features/vocabulary/data/vocab_level_filter.dart';
import 'package:learn_english_music/features/vocabulary/data/vocabulary_data.dart';

void main() {
  group('LearnerLevel tu persona', () {
    test('moi persona deu co cap hoc, Mat goc = Co ban', () {
      expect(LearningPersona.beginner.level, LearnerLevel.basic);
      for (final p in LearningPersona.values) {
        expect(LearnerLevel.values, contains(p.level), reason: p.name);
      }
    });
  });

  group('vocab_level_filter', () {
    test('Tu hoc (null) khong loc gi - giu nguyen chu de va tu', () {
      expect(topicsForLevel(kVocabTopics, null), same(kVocabTopics));
      for (final t in kVocabTopics) {
        expect(wordsForLevel(t, null), same(t.words), reason: t.nameEn);
      }
    });

    test('Co ban chi hien tu common', () {
      for (final t in kVocabTopics) {
        for (final w in wordsForLevel(t, LearnerLevel.basic)) {
          expect(
            w.frequency == null || w.frequency == VocabFrequency.common,
            isTrue,
            reason: '${t.nameEn}: ${w.en}',
          );
        }
      }
    });

    test('Nang cao an tu common', () {
      for (final t in kVocabTopics) {
        for (final w in wordsForLevel(t, LearnerLevel.advanced)) {
          expect(w.frequency, isNot(VocabFrequency.common), reason: w.en);
        }
      }
    });

    test('moi cap deu an chu de qua it tu, va van con chu de de hoc', () {
      for (final level in LearnerLevel.values) {
        final topics = topicsForLevel(kVocabTopics, level);
        expect(topics, isNotEmpty, reason: level.name);
        for (final t in topics) {
          expect(
            wordsForLevel(t, level).length,
            greaterThanOrEqualTo(kMinWordsPerTopicForLevel),
            reason: '${level.name}: ${t.nameEn}',
          );
        }
      }
    });

    test('Co ban xep chu de nhieu tu common len dau', () {
      final topics = topicsForLevel(kVocabTopics, LearnerLevel.basic);
      final counts = [
        for (final t in topics) wordsForLevel(t, LearnerLevel.basic).length,
      ];
      for (var i = 1; i < counts.length; i++) {
        expect(counts[i - 1], greaterThanOrEqualTo(counts[i]));
      }
    });
  });
}

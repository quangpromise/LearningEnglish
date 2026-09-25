import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/providers/app_providers.dart';
import 'package:learn_english_music/features/english_path/data/cefr_level.dart';
import 'package:learn_english_music/features/english_path/data/english_path_progress.dart';
import 'package:learn_english_music/features/english_path/data/english_path_providers.dart';
import 'package:learn_english_music/features/english_path/data/english_path_state.dart';
import 'package:learn_english_music/features/learning_path/data/learning_path_models.dart';
import 'package:learn_english_music/features/vocabulary/data/vocab_level_filter.dart';
import 'package:learn_english_music/features/vocabulary/data/vocabulary_data.dart';

/// ADR-0001: Learner Level chi la lop tuong thich suy ra tu English Level.
void main() {
  test('projects every CEFR stage onto the 3 legacy levels', () {
    expect(learnerLevelFor(CefrLevel.a1), LearnerLevel.basic);
    expect(learnerLevelFor(CefrLevel.a2), LearnerLevel.basic);
    expect(learnerLevelFor(CefrLevel.b1), LearnerLevel.intermediate);
    expect(learnerLevelFor(CefrLevel.b2), LearnerLevel.advanced);
    expect(learnerLevelFor(CefrLevel.c1), LearnerLevel.advanced);
  });

  test('a stored English Level decides the Learner Level', () {
    expect(
      projectLearnerLevel(
        englishLevel: CefrLevel.b2,
        persona: LearningPersona.beginner,
      ),
      LearnerLevel.advanced,
    );
  });

  test('self-study (no persona) never filters, even with an English Level', () {
    expect(projectLearnerLevel(englishLevel: null, persona: null), isNull);
    expect(
      projectLearnerLevel(englishLevel: CefrLevel.a1, persona: null),
      isNull,
    );
  });

  group('learnerLevelProvider regression', () {
    ProviderContainer container(LearningPersona? persona, CefrLevel? level) {
      final c = ProviderContainer(
        overrides: [
          learningPathChoiceProvider.overrideWith((ref) async => persona),
          englishPathStateProvider.overrideWithValue(
            EnglishPathState(level: level),
          ),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    Future<LearnerLevel?> read(ProviderContainer c) async {
      await c.read(learningPathChoiceProvider.future);
      return c.read(learnerLevelProvider);
    }

    test('without English Level every persona keeps its old level', () async {
      for (final persona in LearningPersona.values) {
        final level = await read(container(persona, null));
        expect(level, persona.level, reason: persona.name);
        // Bo loc tu vung nhan dung cap cu -> danh sach tu khong doi.
        final topic = kVocabTopics.first;
        expect(
          wordsForLevel(topic, level),
          wordsForLevel(topic, persona.level),
          reason: persona.name,
        );
      }
      expect(await read(container(null, null)), isNull);
    });

    test('a stored English Level drives the vocabulary filter', () async {
      final level = await read(
        container(LearningPersona.ieltsPrep, CefrLevel.a2),
      );
      expect(level, LearnerLevel.basic);
      for (final w in wordsForLevel(kVocabTopics.first, level)) {
        expect(
          w.frequency == null || w.frequency == VocabFrequency.common,
          isTrue,
          reason: w.en,
        );
      }
    });
  });
}

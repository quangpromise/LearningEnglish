import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/english_path/data/cefr_level.dart';
import 'package:learn_english_music/features/english_path/data/english_path_progress.dart';
import 'package:learn_english_music/features/learning_path/data/learning_path_models.dart';

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
        stored: CefrLevel.b2,
        persona: LearningPersona.beginner,
      ),
      LearnerLevel.advanced,
    );
    expect(
      projectLearnerLevel(stored: CefrLevel.a1, persona: null),
      LearnerLevel.basic,
    );
  });

  test('without a stored English Level nothing changes for consumers', () {
    // Hanh vi cu: Learner Level suy tu Persona, "Tu hoc" = null (khong loc).
    for (final persona in LearningPersona.values) {
      expect(
        projectLearnerLevel(stored: null, persona: persona),
        persona.level,
        reason: persona.name,
      );
    }
    expect(projectLearnerLevel(stored: null, persona: null), isNull);
  });
}

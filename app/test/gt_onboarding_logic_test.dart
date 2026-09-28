import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/learning_path/data/learning_path_models.dart';
import 'package:learn_english_music/features/onboarding/data/onboarding_mapping.dart';
import 'package:learn_english_music/features/today/data/program_recommendation.dart';

void main() {
  test('daily minutes -> sessions per week (15->3, 30->4, 45->4, 60->5)', () {
    expect(
      [for (final m in kOnboardingMinutes) sessionsPerWeekFor(m)],
      [3, 4, 4, 5],
    );
  });

  test('plan summary: speaking from 45 minutes', () {
    expect(includesSpeakingFor(30), isFalse);
    expect(includesSpeakingFor(45), isTrue);
  });

  group('setup answers', () {
    test('fat loss only -> loseFat', () {
      final a = setupAnswersFor({OnboardingGoal.loseFat}, 60);
      expect(a.goal, FitnessGoal.loseFat);
      expect(a.daysPerWeek, 5);
    });

    test('muscle wins over fat loss; no gym goal -> muscle', () {
      expect(
        setupAnswersFor({
          OnboardingGoal.loseFat,
          OnboardingGoal.buildMuscle,
        }, 30).goal,
        FitnessGoal.buildMuscle,
      );
      expect(
        setupAnswersFor({OnboardingGoal.conversation}, 15).goal,
        FitnessGoal.buildMuscle,
      );
    });
  });

  group('persona', () {
    test('exam is the stronger goal', () {
      expect(
        personaFor({OnboardingGoal.conversation, OnboardingGoal.exam}),
        LearningPersona.ieltsPrep,
      );
    });

    test('conversation -> daily conversation; none -> null', () {
      expect(
        personaFor({OnboardingGoal.conversation}),
        LearningPersona.dailyConversation,
      );
      expect(personaFor({OnboardingGoal.buildMuscle}), isNull);
    });
  });
}

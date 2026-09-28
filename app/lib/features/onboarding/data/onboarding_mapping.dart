import '../../fitness/data/program_model.dart';
import '../../learning_path/data/learning_path_models.dart';
import '../../today/data/program_recommendation.dart';

/// 4 muc tieu o buoc 1 onboarding (README §2, chon nhieu).
enum OnboardingGoal { buildMuscle, loseFat, conversation, exam }

/// Cac lua chon so phut moi ngay (README §3); 30 la mac dinh.
const kOnboardingMinutes = [15, 30, 45, 60];
const kDefaultOnboardingMinutes = 30;

/// So buoi tap/tuan theo so phut moi ngay (spec #70): 15->3, 30->4,
/// 45->4, 60->5.
int sessionsPerWeekFor(int minutes) => switch (minutes) {
  <= 15 => 3,
  <= 45 => 4,
  _ => 5,
};

/// Co luyen noi trong ke hoach (45 va 60 phut).
bool includesSpeakingFor(int minutes) => minutes >= 45;

/// Cau tra loi cho [recommendProgram]: Tang co thang Giam mo khi chon ca
/// hai (giao an tang co van co cardio); khong chon muc tieu gym nao ->
/// Tang co (mac dinh cua bang Thiet lap GymTalk).
GymTalkSetupAnswers setupAnswersFor(Set<OnboardingGoal> goals, int minutes) =>
    GymTalkSetupAnswers(
      goal:
          goals.contains(OnboardingGoal.loseFat) &&
              !goals.contains(OnboardingGoal.buildMuscle)
          ? FitnessGoal.loseFat
          : FitnessGoal.buildMuscle,
      difficulty: ProgramDifficulty.beginner,
      daysPerWeek: sessionsPerWeekFor(minutes),
      atHome: false,
    );

/// Persona khoi dau (spec #70): Thi chung chi -> ieltsPrep (muc tieu manh
/// hon thang), Giao tiep -> dailyConversation, khong chon -> null (giu
/// nguyen / tu hoc).
LearningPersona? personaFor(Set<OnboardingGoal> goals) {
  if (goals.contains(OnboardingGoal.exam)) return LearningPersona.ieltsPrep;
  if (goals.contains(OnboardingGoal.conversation)) {
    return LearningPersona.dailyConversation;
  }
  return null;
}

/// XP server cong cho 1 buoi tap da hoan thanh (migration 0073:
/// `workout_sessions.completed_at` -> +25).
const kWorkoutCompletedXp = 25;

/// Nut chinh o man buoi tap (README §9), theo trang thai that cua
/// `WorkoutController`.
enum SessionAction { completeSet, nextExercise, finishWorkout, skipRest }

/// Sieu hiep (PairedBlock): [setNumber]/[totalSets] la VONG; bai A
/// ([pairSubIndex] 0) chi chuyen sang bai B, chi bai B moi het vong.
SessionAction sessionAction({
  required bool resting,
  required int setNumber,
  required int totalSets,
  required bool isLastGroup,
  bool isPaired = false,
  int pairSubIndex = 0,
}) {
  if (resting) return SessionAction.skipRest;
  if (isPaired && pairSubIndex == 0) return SessionAction.completeSet;
  if (setNumber < totalSets) return SessionAction.completeSet;
  return isLastGroup ? SessionAction.finishWorkout : SessionAction.nextExercise;
}

/// 1 vach cua thanh tien do cac bai (xong = trang, dang tap = do, chua =
/// trang 25%).
enum SegmentState { done, current, todo }

List<SegmentState> exerciseSegments({
  required int count,
  required int currentIndex,
}) => [
  for (var i = 0; i < count; i++)
    i < currentIndex
        ? SegmentState.done
        : i == currentIndex
        ? SegmentState.current
        : SegmentState.todo,
];

/// XP that cua buoi (hien o Celebration): +25 khi buoi duoc luu hoan thanh
/// (co it nhat 1 hiep) + XP Rest Game da cong trong luc nghi.
int workoutXpEarned({required int setsLogged, required int restGameXp}) =>
    (setsLogged > 0 ? kWorkoutCompletedXp : 0) + restGameXp;

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/fitness/data/workout_presentation.dart';

void main() {
  group('primary button follows the session state', () {
    test('resting -> skip rest', () {
      expect(
        sessionAction(
          resting: true,
          setNumber: 2,
          totalSets: 4,
          isLastGroup: false,
        ),
        SessionAction.skipRest,
      );
    });

    test('sets left -> complete set', () {
      expect(
        sessionAction(
          resting: false,
          setNumber: 3,
          totalSets: 4,
          isLastGroup: true,
        ),
        SessionAction.completeSet,
      );
    });

    test('last set of an exercise -> next exercise', () {
      expect(
        sessionAction(
          resting: false,
          setNumber: 4,
          totalSets: 4,
          isLastGroup: false,
        ),
        SessionAction.nextExercise,
      );
    });

    test('superset: exercise A of the last round only moves to B', () {
      expect(
        sessionAction(
          resting: false,
          setNumber: 3,
          totalSets: 3,
          isLastGroup: true,
          isPaired: true,
          pairSubIndex: 0,
        ),
        SessionAction.completeSet,
      );
      expect(
        sessionAction(
          resting: false,
          setNumber: 3,
          totalSets: 3,
          isLastGroup: true,
          isPaired: true,
          pairSubIndex: 1,
        ),
        SessionAction.finishWorkout,
      );
      expect(
        sessionAction(
          resting: false,
          setNumber: 3,
          totalSets: 3,
          isLastGroup: false,
          isPaired: true,
          pairSubIndex: 1,
        ),
        SessionAction.nextExercise,
      );
    });

    test('last set of the last exercise -> finish workout', () {
      expect(
        sessionAction(
          resting: false,
          setNumber: 4,
          totalSets: 4,
          isLastGroup: true,
        ),
        SessionAction.finishWorkout,
      );
    });
  });

  test('exercise segments: done, current, todo', () {
    expect(exerciseSegments(count: 4, currentIndex: 1), [
      SegmentState.done,
      SegmentState.current,
      SegmentState.todo,
      SegmentState.todo,
    ]);
    expect(exerciseSegments(count: 0, currentIndex: 0), isEmpty);
  });

  test('real workout XP: +25 when saved with sets, plus Rest Game XP', () {
    expect(workoutXpEarned(setsLogged: 8, restGameXp: 6), 31);
    expect(workoutXpEarned(setsLogged: 0, restGameXp: 0), 0);
    expect(workoutXpEarned(setsLogged: 1, restGameXp: 0), kWorkoutCompletedXp);
  });
}

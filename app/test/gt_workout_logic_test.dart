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

  group('exercise slide position', () {
    int pos(int g, {bool paired = false, int round = 0, int sub = 0}) =>
        exerciseSlidePosition(
          groupIndex: g,
          paired: paired,
          roundIndex: round,
          subIndex: sub,
        );

    test('solo sets keep their position, the next exercise moves on', () {
      expect(pos(0), pos(0));
      expect(pos(1), greaterThan(pos(0)));
    });

    test('a superset always moves forward: A1 B1 A2 B2 A3 B3, then next', () {
      final seq = [
        for (var round = 0; round < 3; round++)
          for (var sub = 0; sub < 2; sub++)
            pos(0, paired: true, round: round, sub: sub),
        pos(1),
      ];
      for (var i = 1; i < seq.length; i++) {
        expect(seq[i], greaterThan(seq[i - 1]), reason: 'step $i');
      }
    });

    test('undo inside a superset moves back', () {
      expect(
        pos(0, paired: true, round: 1, sub: 0),
        lessThan(pos(0, paired: true, round: 1, sub: 1)),
      );
    });
  });
}

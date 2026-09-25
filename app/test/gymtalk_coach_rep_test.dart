import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/fitness/data/coach_script.dart';
import 'package:learn_english_music/features/fitness/data/exercise_model.dart';
import 'package:learn_english_music/features/fitness/data/rep_counter.dart';
import 'package:learn_english_music/features/learning_path/data/learning_path_models.dart';

Exercise _exercise(String nameEn, {List<String> steps = const []}) => Exercise(
  id: 1,
  nameVi: 'x',
  nameEn: nameEn,
  primaryMuscle: '',
  secondaryMuscles: const [],
  involvementPercents: const [],
  equipment: '',
  instructions: const [],
  instructionsEn: steps,
  suggestedSetsMin: 3,
  suggestedSetsMax: 4,
  suggestedRepsMin: 8,
  suggestedRepsMax: 12,
  suggestedRestSeconds: 60,
  muscleGroupCode: 'LEGS',
  movementType: '',
  difficultyCode: 'BEGINNER',
  photoSlug: 'x',
);

void main() {
  group('jointAngle', () {
    test('goc vuong va duoi thang', () {
      const a = PosePoint(0, 1), b = PosePoint(0, 0), c = PosePoint(1, 0);
      expect(jointAngle(a, b, c), closeTo(90, 1e-6));
      expect(
        jointAngle(const PosePoint(-1, 0), b, const PosePoint(1, 0)),
        closeTo(180, 1e-6),
      );
    });
  });

  group('RepCounter', () {
    List<RepEvent> feed(RepCounter c, List<double> angles) => [
      for (final a in angles) c.addAngle(a),
    ];

    test('dem 2 rep squat du sau', () {
      final counter = RepCounter(RepPattern.squat, smoothing: 1);
      final events = feed(counter, [170, 140, 95, 90, 150, 170, 120, 95, 165]);
      expect(counter.reps, 2);
      expect(events.where((e) => e == RepEvent.rep), hasLength(2));
    });

    test('rep chua du sau -> shallowRep', () {
      final counter = RepCounter(RepPattern.squat, smoothing: 1);
      final events = feed(counter, [170, 125, 120, 165]);
      expect(events.last, RepEvent.shallowRep);
      expect(counter.shallowReps, 1);
    });

    test('rung quanh 1 nguong khong dem nham', () {
      final counter = RepCounter(RepPattern.squat, smoothing: 1);
      feed(counter, [170, 158, 162, 158, 162, 170]);
      expect(counter.reps, 0);
    });

    test('chon mau theo ten bai', () {
      expect(
        RepPattern.forExercise(_exercise('Barbell Back Squat')),
        RepPattern.squat,
      );
      expect(
        RepPattern.forExercise(_exercise('Dumbbell Bicep Curl')),
        RepPattern.curl,
      );
      expect(
        RepPattern.forExercise(_exercise('Barbell Bench Press')),
        RepPattern.push,
      );
      expect(
        RepPattern.forExercise(_exercise('Romanian Deadlift')),
        RepPattern.hinge,
      );
      expect(RepPattern.forExercise(_exercise('Plank')), isNull);
    });

    test('repWord', () {
      expect(repWord(3), 'three');
      expect(repWord(25), '25');
    });
  });

  group('CoachScript', () {
    final exercise = _exercise(
      'Goblet Squat',
      steps: [
        'Hold the dumbbell close to your chest.',
        'Keep your chest up.',
        'Push the floor away and stand up tall with control.',
      ],
    );

    test('co ban: cau ngan, nhac ky thuat tu cau ngan nhat', () {
      final coach = CoachScript(level: LearnerLevel.basic, random: Random(1));
      expect(
        coach.exerciseIntro(exercise, sets: 3),
        'Next exercise: Goblet Squat. 3 sets.',
      );
      expect(
        coach.formCue(exercise, setNumber: 1),
        'Remember: Keep your chest up.',
      );
      expect(
        coach.setStart(setNumber: 3, totalSets: 3, repsMin: 8, repsMax: 12),
        'Last set. 8 to 12 reps.',
      );
    });

    test('trung cap: nhac ky thuat xoay vong theo set', () {
      final coach = CoachScript(random: Random(1));
      final first = coach.formCue(exercise, setNumber: 1);
      final second = coach.formCue(exercise, setNumber: 2);
      expect(first, isNot(second));
      expect(first, startsWith('Coach tip: '));
    });

    test('bai khong co huong dan -> khong nhac', () {
      expect(CoachScript().formCue(_exercise('X'), setNumber: 1), isNull);
    });

    test('ket thuc buoi co nhac so tu da on', () {
      final text = CoachScript(level: LearnerLevel.basic)
          .workoutDone(sets: 12, words: 5);
      expect(text, 'Great job! You did 12 sets and reviewed 5 words.');
    });
  });
}

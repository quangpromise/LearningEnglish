import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/tts/tutorial_voice.dart';
import 'package:learn_english_music/features/fitness/data/exercise_model.dart';
import 'package:learn_english_music/features/fitness/data/exercise_tutorial.dart';
import 'package:learn_english_music/features/fitness/data/gym_vocabulary.dart';

/// Doc bai tap giong het ExerciseRepository.getAllExercises().
List<Exercise> _loadExercises() {
  final raw = File('assets/fitness/exercises_seed.json').readAsStringSync();
  final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  return [
    for (final map in list)
      Exercise(
        id: map['id'] as int,
        nameVi: map['nameVi'] as String,
        nameEn: map['nameEn'] as String,
        primaryMuscle: map['primaryMuscle'] as String,
        secondaryMuscles: (map['secondaryMuscles'] as List).cast<String>(),
        involvementPercents: (map['involvementPercents'] as List).cast<int>(),
        equipment: map['equipment'] as String,
        instructions: (map['instructions'] as List).cast<String>(),
        instructionsEn: ((map['instructionsEn'] as List?) ?? const [])
            .cast<String>(),
        suggestedSetsMin: map['suggestedSetsMin'] as int,
        suggestedSetsMax: map['suggestedSetsMax'] as int,
        suggestedRepsMin: map['suggestedRepsMin'] as int,
        suggestedRepsMax: map['suggestedRepsMax'] as int,
        suggestedRestSeconds: map['suggestedRestSeconds'] as int,
        muscleGroupCode: map['muscleGroupCode'] as String,
        movementType: map['movementType'] as String,
        difficultyCode: map['difficultyCode'] as String,
        photoSlug: map['photoSlug'] as String,
      ),
  ];
}

void main() {
  test('ma bam khop scripts/generate_tutorial_audio.py (FNV-1a 32)', () {
    // Gia tri tinh bang fnv1a32() ben Python.
    expect(tutorialAudioKey(''), '811c9dc5');
    expect(tutorialAudioKey('Great job!'), '97c462c4');
    expect(tutorialAudioKey('Nice try!'), '346b48f4');
  });

  test('moi cau trinh phat doc deu co file audio Kokoro', () {
    final dir = Directory('assets/tutorial_audio');
    final manifest = (jsonDecode(
      File('${dir.path}/manifest.json').readAsStringSync(),
    ) as Map<String, dynamic>).cast<String, String>();

    final expected = <String>{
      for (final exercise in _loadExercises())
        for (final chapter in buildExerciseTutorial(exercise).chapters)
          if (chapter.kind != TutorialChapterKind.keywords) chapter.narration,
      for (final word in kGymWords) word.en,
      'Great job!',
      'Nice try!',
    };
    final missing = [
      for (final text in expected)
        if (manifest[tutorialAudioKey(text)] != text) text,
    ];
    expect(missing, isEmpty, reason: 'Chay lai generate_tutorial_audio.py');
    for (final key in manifest.keys) {
      expect(File('${dir.path}/$key.mp3').existsSync(), isTrue, reason: key);
    }
  });
}

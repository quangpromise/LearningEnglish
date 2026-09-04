import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'program_model.dart';

/// Doc thu vien chuong trinh tap (giao an) - noi dung TINH dong goi san
/// trong app (assets/fitness/programs_seed.json), dung y het pattern
/// ExerciseRepository.getAllExercises().
class ProgramRepository {
  List<Program>? _cached;

  Future<List<Program>> getAllPrograms() async {
    final cached = _cached;
    if (cached != null) return cached;
    final raw = await rootBundle.loadString(
      'assets/fitness/programs_seed.json',
    );
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    final programs = list.map((map) {
      final days = (map['days'] as List).cast<Map<String, dynamic>>().map((d) {
        final exercises = (d['exercises'] as List)
            .cast<Map<String, dynamic>>()
            .map(
              (e) => ProgramExerciseRef(
                exerciseId: e['exerciseId'] as int,
                targetSets: e['targetSets'] as int,
                targetRepsMin: e['targetRepsMin'] as int,
                targetRepsMax: e['targetRepsMax'] as int,
                orderIndex: e['orderIndex'] as int,
                supersetGroup: e['supersetGroup'] as String?,
              ),
            )
            .toList();
        return ProgramDay(
          dayOfWeek: d['dayOfWeek'] as int,
          exercises: exercises,
        );
      }).toList();
      return Program(
        id: map['id'] as int,
        titleVi: map['titleVi'] as String,
        level: map['level'] as String,
        equipment: map['equipment'] as String,
        sessionsPerWeek: map['sessionsPerWeek'] as int,
        durationWeeks: map['durationWeeks'] as int,
        tags: (map['tags'] as List).cast<String>(),
        days: days,
      );
    }).toList();
    _cached = programs;
    return programs;
  }

  Future<Program> getProgram(int id) async {
    final programs = await getAllPrograms();
    return programs.firstWhere((p) => p.id == id);
  }
}

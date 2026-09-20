import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/i18n/app_language.dart';
import 'package:learn_english_music/features/fitness/data/exercise_i18n.dart';

/// Chot chan cho phan noi dung Fitness co 2 ngon ngu.
///
/// Noi dung bai tap/giao an nam trong file JSON dong goi san chu khong phai
/// trong tu dien giao dien, nen khong co gi chan duoc viec them 1 bai moi
/// ma quen ban tieng Anh - luc do nguoi chon English se thay tieng Viet lot
/// vao giua. Bai test nay bat dung truong hop do.
void main() {
  final exercises = (jsonDecode(
    File('assets/fitness/exercises_seed.json').readAsStringSync(),
  ) as List).cast<Map<String, dynamic>>();
  final programs = (jsonDecode(
    File('assets/fitness/programs_seed.json').readAsStringSync(),
  ) as List).cast<Map<String, dynamic>>();

  group('noi dung bai tap', () {
    test('bai nao cung co ten tieng Anh', () {
      for (final e in exercises) {
        expect(
          (e['nameEn'] as String?)?.trim().isNotEmpty,
          isTrue,
          reason: 'bai id=${e['id']} (${e['nameVi']}) thieu nameEn',
        );
      }
    });

    test('huong dan tieng Anh du so buoc nhu tieng Viet', () {
      for (final e in exercises) {
        final vi = (e['instructions'] as List).length;
        final en = ((e['instructionsEn'] as List?) ?? const []).length;
        expect(
          en,
          vi,
          reason:
              'bai id=${e['id']} (${e['nameVi']}) co $vi buoc tieng Viet '
              'nhung $en buoc tieng Anh',
        );
      }
    });

    test('moi nhom co va thiet bi deu co ban tieng Anh', () {
      for (final e in exercises) {
        final muscles = <String>[
          e['primaryMuscle'] as String,
          ...(e['secondaryMuscles'] as List).cast<String>(),
        ];
        for (final m in muscles) {
          expect(
            exerciseMuscleLabel(m, AppLanguage.en),
            isNot(m),
            reason: 'nhom co "$m" chua co trong bang dich',
          );
        }
        final equipment = e['equipment'] as String;
        expect(
          exerciseEquipmentLabel(equipment, AppLanguage.en),
          isNot(equipment),
          reason: 'thiet bi "$equipment" chua co trong bang dich',
        );
      }
    });
  });

  test('giao an nao cung co ten tieng Anh', () {
    for (final p in programs) {
      expect(
        (p['titleEn'] as String?)?.trim().isNotEmpty,
        isTrue,
        reason: 'giao an id=${p['id']} (${p['titleVi']}) thieu titleEn',
      );
    }
  });
}

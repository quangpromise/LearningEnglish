import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/learning_path/data/learning_path_models.dart';

void main() {
  group('kPersonaRecommendations', () {
    test('co du danh sach goi y cho tat ca persona', () {
      expect(
        kPersonaRecommendations.keys.toSet(),
        LearningPersona.values.toSet(),
      );
    });

    test('moi persona co it nhat 3 tinh nang goi y, khong trung nhau', () {
      for (final entry in kPersonaRecommendations.entries) {
        expect(
          entry.value.length,
          greaterThanOrEqualTo(3),
          reason: entry.key.name,
        );
        expect(
          entry.value.toSet().length,
          entry.value.length,
          reason: entry.key.name,
        );
      }
    });

    test('phan tu dau tien (top pick) luon nam trong chinh danh sach do', () {
      for (final entry in kPersonaRecommendations.entries) {
        expect(
          entry.value,
          contains(entry.value.first),
          reason: entry.key.name,
        );
      }
    });
  });
}

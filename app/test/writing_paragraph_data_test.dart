import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/writing/data/writing_paragraph_data.dart';

void main() {
  group('kWritingParagraphs', () {
    test('id doan van la duy nhat', () {
      final ids = kWritingParagraphs.map((p) => p.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('co dung 24 doan, moi doan dung 6 cau (24x6=144 cau, "van ngan '
        'khong dai dong")', () {
      expect(kWritingParagraphs.length, 24);
      for (final p in kWritingParagraphs) {
        expect(p.sentences.length, 6, reason: p.id);
      }
    });

    test('id cau la duy nhat trong pham vi 1 doan', () {
      for (final p in kWritingParagraphs) {
        final ids = p.sentences.map((s) => s.id).toList();
        expect(ids.toSet().length, ids.length, reason: p.id);
      }
    });

    test('id cau la duy nhat tren toan bo kWritingParagraphs - dung lam key '
        'controller/scoring on dinh', () {
      final allIds = kWritingParagraphs
          .expand((p) => p.sentences.map((s) => s.id))
          .toList();
      expect(allIds.toSet().length, allIds.length);
    });

    test('titleVi/titleEn khong rong cho moi doan', () {
      for (final p in kWritingParagraphs) {
        expect(p.titleVi, isNotEmpty, reason: p.id);
        expect(p.titleEn, isNotEmpty, reason: p.id);
      }
    });

    test('vi/en/tenseLabel khong rong cho moi cau', () {
      for (final p in kWritingParagraphs) {
        for (final s in p.sentences) {
          expect(s.vi, isNotEmpty, reason: s.id);
          expect(s.en, isNotEmpty, reason: s.id);
          expect(s.tenseLabel, isNotEmpty, reason: s.id);
        }
      }
    });

    test('moi tenseLabel deu nam trong danh sach 12 thi co dinh '
        'kAllTenseLabels - tranh go nham/sai chinh ta ten thi', () {
      for (final p in kWritingParagraphs) {
        for (final s in p.sentences) {
          expect(kAllTenseLabels, contains(s.tenseLabel), reason: s.id);
        }
      }
    });

    test('ca 12 thi trong kAllTenseLabels deu xuat hien it nhat 1 lan trong '
        'toan bo kWritingParagraphs - tranh soan thieu sot 1 thi', () {
      final usedTenses = kWritingParagraphs
          .expand((p) => p.sentences.map((s) => s.tenseLabel))
          .toSet();
      for (final tense in kAllTenseLabels) {
        expect(usedTenses, contains(tense));
      }
    });

    test('kAllTenseLabels co dung 12 thi, khong trung nhau', () {
      expect(kAllTenseLabels.length, 12);
      expect(kAllTenseLabels.toSet().length, 12);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/quiz/data/quiz_data.dart';

void main() {
  group('kRiddles', () {
    test('moi cau thuoc 1 chu de co trong kCategories', () {
      for (final r in kRiddles) {
        expect(kCategories, contains(r.category), reason: r.en);
      }
    });

    test('moi chu de trong kCategories deu co ten tieng Anh', () {
      for (final c in kCategories) {
        expect(kCategoryNamesEn[c], isNotNull, reason: c);
      }
    });

    test('dung 3 phuong an nhieu, khong trung nhau va khong trung dap an', () {
      for (final r in kRiddles) {
        expect(r.distractors.length, 3, reason: r.en);
        final options = [
          r.answer,
          ...r.distractors,
        ].map((o) => o.toLowerCase()).toList();
        expect(options.toSet().length, 4, reason: r.en);
      }
    });

    test('cau hoi khong bi lap lai trong cung 1 chu de', () {
      for (final c in kCategories) {
        final questions = kRiddles
            .where((r) => r.category == c)
            .map((r) => r.en)
            .toList();
        expect(questions.toSet().length, questions.length, reason: c);
      }
    });

    test('Cuoc song / Bang chu cai / Trai cay & xe co co 20-30 cau', () {
      for (final c in ['Cuộc sống', 'Bảng chữ cái', 'Trái cây & xe cộ']) {
        final count = kRiddles.where((r) => r.category == c).length;
        expect(count, inInclusiveRange(20, 30), reason: c);
      }
    });
  });
}

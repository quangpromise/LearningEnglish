import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/toeic/data/toeic_models.dart';
import 'package:learn_english_music/features/toeic/data/toeic_scoring.dart';
import 'package:learn_english_music/features/toeic/data/toeic_test_data.dart';

void main() {
  group('kToeicTests', () {
    test('id de thi la duy nhat', () {
      final ids = kToeicTests.map((t) => t.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('moi de co dung 200 cau, dung ty le tung phan giong TOEIC that', () {
      const expectedPerPart = {
        ToeicPartNumber.p1: 6,
        ToeicPartNumber.p2: 25,
        ToeicPartNumber.p3: 39,
        ToeicPartNumber.p4: 30,
        ToeicPartNumber.p5: 30,
        ToeicPartNumber.p6: 16,
        ToeicPartNumber.p7: 54,
      };
      for (final test in kToeicTests) {
        expect(test.questions.length, 200, reason: test.id);
        for (final part in ToeicPartNumber.values) {
          expect(
            test.questionsForPart(part).length,
            expectedPerPart[part],
            reason: '${test.id} - $part',
          );
        }
      }
    });

    test('id cau hoi la duy nhat trong pham vi 1 de', () {
      for (final test in kToeicTests) {
        final ids = test.questions.map((q) => q.id).toList();
        expect(ids.toSet().length, ids.length, reason: test.id);
      }
    });

    test('options khong rong, correctIndex hop le, dung so luong phuong an '
        'theo tung phan (Part 2 co 3, cac phan con lai co 4)', () {
      for (final test in kToeicTests) {
        for (final q in test.questions) {
          expect(q.options, isNotEmpty, reason: q.id);
          expect(
            q.correctIndex,
            inInclusiveRange(0, q.options.length - 1),
            reason: q.id,
          );
          final expectedOptionCount = q.part == ToeicPartNumber.p2 ? 3 : 4;
          expect(q.options.length, expectedOptionCount, reason: q.id);
        }
      }
    });

    test('explanationVi khong rong cho moi cau', () {
      for (final test in kToeicTests) {
        for (final q in test.questions) {
          expect(q.explanationVi.trim(), isNotEmpty, reason: q.id);
        }
      }
    });

    test('moi audioScriptId cua cau hoi Part 1-4 deu ton tai trong '
        'audioScripts (khong co tham chieu mo coi), va nguoc lai khong co '
        'script nao khong duoc cau hoi nao dung toi', () {
      for (final test in kToeicTests) {
        final referencedIds = test.questions
            .map((q) => q.audioScriptId)
            .whereType<String>()
            .toSet();
        for (final id in referencedIds) {
          expect(
            test.audioScripts.containsKey(id),
            isTrue,
            reason: '${test.id} - thieu audioScript $id',
          );
        }
        for (final id in test.audioScripts.keys) {
          expect(
            referencedIds.contains(id),
            isTrue,
            reason: '${test.id} - audioScript $id khong co cau hoi nao dung',
          );
        }
      }
    });

    test('moi passageId cua cau hoi Part 6-7 deu ton tai trong passages '
        '(khong co tham chieu mo coi), va nguoc lai khong co passage nao '
        'khong duoc cau hoi nao dung toi', () {
      for (final test in kToeicTests) {
        final referencedIds = test.questions
            .map((q) => q.passageId)
            .whereType<String>()
            .toSet();
        for (final id in referencedIds) {
          expect(
            test.passages.containsKey(id),
            isTrue,
            reason: '${test.id} - thieu passage $id',
          );
        }
        for (final id in test.passages.keys) {
          expect(
            referencedIds.contains(id),
            isTrue,
            reason: '${test.id} - passage $id khong co cau hoi nao dung',
          );
        }
      }
    });

    test('Part 1 luon co illustration, Part 5 luon co promptEn', () {
      for (final test in kToeicTests) {
        for (final q in test.questionsForPart(ToeicPartNumber.p1)) {
          expect(q.illustration, isNotNull, reason: q.id);
        }
        for (final q in test.questionsForPart(ToeicPartNumber.p5)) {
          expect(q.promptEn, isNotNull, reason: q.id);
        }
      }
    });

    test('Part 3/4 - moi cau deu co audioScriptId, Part 6/7 - moi cau deu '
        'co passageId', () {
      for (final test in kToeicTests) {
        for (final part in [ToeicPartNumber.p3, ToeicPartNumber.p4]) {
          for (final q in test.questionsForPart(part)) {
            expect(q.audioScriptId, isNotNull, reason: q.id);
          }
        }
        for (final part in [ToeicPartNumber.p6, ToeicPartNumber.p7]) {
          for (final q in test.questionsForPart(part)) {
            expect(q.passageId, isNotNull, reason: q.id);
          }
        }
      }
    });
  });

  group('rawToScaledScore', () {
    test('0/0 tra ve diem toi thieu, khong chia cho 0', () {
      expect(rawToScaledScore(0, 0), kToeicMinScaledScore);
    });

    test('dung het / sai het cho diem bien', () {
      expect(rawToScaledScore(0, 100), kToeicMinScaledScore);
      expect(rawToScaledScore(100, 100), kToeicMaxScaledScore);
    });

    test('don dieu tang - dung nhieu hon khong bao gio cho diem thap hon', () {
      var previous = kToeicMinScaledScore;
      for (var correct = 0; correct <= 100; correct++) {
        final score = rawToScaledScore(correct, 100);
        expect(score, greaterThanOrEqualTo(previous));
        previous = score;
      }
    });

    test('luon la boi so cua 5 va nam trong [5, 495]', () {
      for (var correct = 0; correct <= 100; correct += 7) {
        final score = rawToScaledScore(correct, 100);
        expect(score % 5, 0);
        expect(
          score,
          inInclusiveRange(kToeicMinScaledScore, kToeicMaxScaledScore),
        );
      }
    });
  });
}

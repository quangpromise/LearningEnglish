import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/ielts/data/ielts_models.dart';
import 'package:learn_english_music/features/ielts/data/ielts_scoring.dart';
import 'package:learn_english_music/features/ielts/data/ielts_test_data.dart';

void main() {
  group('kIeltsTests', () {
    test('id de thi la duy nhat', () {
      final ids = kIeltsTests.map((t) => t.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('moi de co dung 40 cau Reading + 40 cau Listening theo dung so '
        'luong da soan', () {
      const expectedPerSection = {
        IeltsSectionNumber.r1: 13,
        IeltsSectionNumber.r2: 13,
        IeltsSectionNumber.r3: 14,
        IeltsSectionNumber.l1: 10,
        IeltsSectionNumber.l2: 10,
        IeltsSectionNumber.l3: 10,
        IeltsSectionNumber.l4: 10,
      };
      for (final test in kIeltsTests) {
        expect(test.readingQuestions.length, 40, reason: test.id);
        expect(test.listeningQuestions.length, 40, reason: test.id);
        for (final section in IeltsSectionNumber.values) {
          expect(
            test.questionsForSection(section).length,
            expectedPerSection[section],
            reason: '${test.id} - $section',
          );
        }
      }
    });

    test('id cau hoi la duy nhat trong pham vi 1 de', () {
      for (final test in kIeltsTests) {
        final ids = test.questions.map((q) => q.id).toList();
        expect(ids.toSet().length, ids.length, reason: test.id);
      }
    });

    test('cau multipleChoice: options khong rong, correctIndex hop le, '
        'khong dat acceptedAnswers', () {
      for (final test in kIeltsTests) {
        for (final q in test.questions) {
          if (q.answerType != IeltsAnswerType.multipleChoice) continue;
          expect(q.options, isNotEmpty, reason: q.id);
          expect(
            q.correctIndex,
            isNotNull,
            reason: '${q.id} thieu correctIndex',
          );
          expect(
            q.correctIndex,
            inInclusiveRange(0, q.options.length - 1),
            reason: q.id,
          );
          expect(
            q.acceptedAnswers,
            isEmpty,
            reason: '${q.id} la multipleChoice nhung lai co acceptedAnswers',
          );
        }
      }
    });

    test('cau shortAnswer: acceptedAnswers khong rong (moi phan tu khong '
        'rong sau trim), khong dat options/correctIndex', () {
      for (final test in kIeltsTests) {
        for (final q in test.questions) {
          if (q.answerType != IeltsAnswerType.shortAnswer) continue;
          expect(q.acceptedAnswers, isNotEmpty, reason: q.id);
          for (final a in q.acceptedAnswers) {
            expect(a.trim(), isNotEmpty, reason: q.id);
          }
          expect(
            q.options,
            isEmpty,
            reason: '${q.id} la shortAnswer nhung lai co options',
          );
          expect(
            q.correctIndex,
            isNull,
            reason: '${q.id} la shortAnswer nhung lai co correctIndex',
          );
        }
      }
    });

    test('explanationVi khong rong cho moi cau', () {
      for (final test in kIeltsTests) {
        for (final q in test.questions) {
          expect(q.explanationVi.trim(), isNotEmpty, reason: q.id);
        }
      }
    });

    test('moi audioScriptId cua cau Listening deu ton tai trong '
        'audioScripts (khong mo coi ca 2 chieu)', () {
      for (final test in kIeltsTests) {
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

    test('moi passageId cua cau Reading deu ton tai trong passages (khong '
        'mo coi ca 2 chieu)', () {
      for (final test in kIeltsTests) {
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

    test(
      'moi cau Reading co passageId, moi cau Listening co audioScriptId',
      () {
        for (final test in kIeltsTests) {
          for (final q in test.readingQuestions) {
            expect(q.passageId, isNotNull, reason: q.id);
          }
          for (final q in test.listeningQuestions) {
            expect(q.audioScriptId, isNotNull, reason: q.id);
          }
        }
      },
    );
  });

  group('rawToBandScore', () {
    test('0/0 tra ve band toi thieu, khong chia cho 0', () {
      expect(rawToBandScore(0, 0), kIeltsMinBand);
    });

    test('0/40 -> 0.0, 40/40 -> 9.0', () {
      expect(rawToBandScore(0, 40), 0.0);
      expect(rawToBandScore(40, 40), 9.0);
    });

    test('don dieu tang', () {
      var previous = kIeltsMinBand;
      for (var correct = 0; correct <= 40; correct++) {
        final band = rawToBandScore(correct, 40);
        expect(band, greaterThanOrEqualTo(previous));
        previous = band;
      }
    });

    test('luon la boi so cua 0.5 va nam trong [0, 9]', () {
      for (var correct = 0; correct <= 40; correct += 3) {
        final band = rawToBandScore(correct, 40);
        expect((band * 2) % 1, 0);
        expect(band, inInclusiveRange(kIeltsMinBand, kIeltsMaxBand));
      }
    });
  });

  group('isShortAnswerCorrect', () {
    test('khop khong phan biet hoa/thuong va khoang trang thua', () {
      expect(isShortAnswerCorrect('  Grant ', ['grant']), isTrue);
      expect(isShortAnswerCorrect('GRANT', ['grant']), isTrue);
    });

    test('khop 1 trong nhieu dap an chap nhan duoc', () {
      expect(isShortAnswerCorrect('twelve', ['12', 'twelve']), isTrue);
      expect(isShortAnswerCorrect('12', ['12', 'twelve']), isTrue);
    });

    test('bo dau cau cuoi cau khi so sanh', () {
      expect(isShortAnswerCorrect('heuristics.', ['heuristics']), isTrue);
    });

    test('khong khop tra ve false', () {
      expect(isShortAnswerCorrect('wrong', ['grant']), isFalse);
    });
  });
}

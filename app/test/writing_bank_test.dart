import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/learning_path/data/learning_path_models.dart';
import 'package:learn_english_music/features/writing/data/writing_bank.dart';
import 'package:learn_english_music/features/writing/data/writing_grammar.dart';
import 'package:learn_english_music/features/writing/data/writing_scoring.dart';

void main() {
  final allParagraphs = [for (final t in kWritingTopics) ...t.paragraphs];

  group('kWritingTopics - ngan hang Doan van theo cap', () {
    test('id chu de va id bai la duy nhat', () {
      final topicIds = kWritingTopics.map((t) => t.id).toList();
      expect(topicIds.toSet().length, topicIds.length);
      final ids = allParagraphs.map((p) => p.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('moi chu de co dung 8 bai cho moi cap (24 bai/chu de)', () {
      for (final t in kWritingTopics) {
        for (final level in LearnerLevel.values) {
          expect(
            t.paragraphsFor(level).length,
            8,
            reason: '${t.id} ${level.name}',
          );
        }
        expect(t.paragraphsFor(null).length, 24, reason: t.id);
      }
    });

    test('so cau moi bai nam trong khoang cho phep cua cap', () {
      for (final p in allParagraphs) {
        final (min, max) = kSentencesPerParagraphByLevel[p.level]!;
        expect(p.sentences.length, inInclusiveRange(min, max), reason: p.id);
      }
    });

    test('do dai cau (so tu) hop voi cap', () {
      for (final p in allParagraphs) {
        final (min, max) = kWordsPerSentenceByLevel[p.level]!;
        for (final s in p.sentences) {
          final words = s.en.split(RegExp(r'\s+')).length;
          expect(words, inInclusiveRange(min, max), reason: '${p.id}: ${s.en}');
        }
      }
    });

    test('chi dung cau truc ngu phap duoc phep o cap do - khong soan cau '
        'qua kho vao cap duoi', () {
      for (final p in allParagraphs) {
        final allowed = kGrammarLabelsByLevel[p.level]!;
        for (final s in p.sentences) {
          expect(allowed, contains(s.tenseLabel), reason: '${p.id}: ${s.en}');
        }
      }
    });

    test('vi/en/tieu de khong rong, cau tieng Anh khong chua chu so (bi '
        'bo khi cham diem)', () {
      for (final p in allParagraphs) {
        expect(p.titleVi, isNotEmpty, reason: p.id);
        expect(p.titleEn, isNotEmpty, reason: p.id);
        for (final s in p.sentences) {
          expect(s.vi, isNotEmpty, reason: p.id);
          expect(s.en, isNotEmpty, reason: p.id);
          expect(s.en, isNot(matches(RegExp(r'\d'))), reason: s.en);
        }
      }
    });

    test('go dung dap an chinh hoac cach viet khac deu duoc 100 diem', () {
      for (final p in allParagraphs) {
        for (final s in p.sentences) {
          for (final answer in [s.en, ...s.alternatives]) {
            final result = scoreSentenceBest(
              targetEn: s.en,
              alternatives: s.alternatives,
              userInput: answer,
            );
            expect(result.score, 100, reason: answer);
          }
        }
      }
    });
  });

  group('scoreSentenceBest', () {
    test('lay ket qua cao nhat giua dap an chinh va cach viet khac', () {
      final result = scoreSentenceBest(
        targetEn: 'My mother is a teacher.',
        alternatives: ['My mom is a teacher.'],
        userInput: 'My mom is a teacher',
      );
      expect(result.score, 100);
      expect(result.targetText, 'My mom is a teacher.');
    });

    test('khong co cach viet khac thi giong scoreSentence', () {
      final a = scoreSentenceBest(
        targetEn: 'I love summer.',
        userInput: 'I like summer',
      );
      final b = scoreSentence(
        targetEn: 'I love summer.',
        userInput: 'I like summer',
      );
      expect(a.score, b.score);
    });
  });
}

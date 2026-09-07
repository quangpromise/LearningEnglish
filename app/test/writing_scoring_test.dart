import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/writing/data/writing_scoring.dart';

void main() {
  group('normalizeWritingText', () {
    test('ha chu thuong, bo dau cau, mo rong contraction', () {
      expect(normalizeWritingText("Hello, World!"), ['hello', 'world']);
      expect(normalizeWritingText("I'm fine"), ['i', 'am', 'fine']);
    });
  });

  group('writingLcsMatch', () {
    test('khop hoan toan -> tat ca true', () {
      final result = writingLcsMatch(['a', 'b', 'c'], ['a', 'b', 'c']);
      expect(result, [true, true, true]);
    });

    test('thieu 1 tu o giua van khop duoc phan con lai', () {
      final result = writingLcsMatch(['a', 'b', 'c'], ['a', 'c']);
      expect(result, [true, false, true]);
    });
  });

  group('levenshteinDistance', () {
    test('chuoi giong het -> 0', () {
      expect(levenshteinDistance('apple', 'apple'), 0);
    });

    test('sai 1 ky tu -> 1, thieu 1 ky tu -> 1, sai 2 ky tu -> 2', () {
      expect(levenshteinDistance('aplle', 'apple'), 1);
      expect(levenshteinDistance('aple', 'apple'), 1);
      expect(levenshteinDistance('aplee', 'apple'), 2);
    });

    test('khong phan biet hoa/thuong', () {
      expect(levenshteinDistance('Apple', 'apple'), 0);
    });
  });

  group('scoreVocabAnswer', () {
    test('go dung y het (khong phan biet hoa/thuong, thua khoang trang) -> correct', () {
      expect(scoreVocabAnswer('mother', 'mother'), VocabAnswerResult.correct);
      expect(
        scoreVocabAnswer('  Mother  ', 'mother'),
        VocabAnswerResult.correct,
      );
    });

    test('go gan dung (loi chinh ta nhe, Levenshtein <= 2) -> closeTypo', () {
      expect(scoreVocabAnswer('mothr', 'mother'), VocabAnswerResult.closeTypo);
    });

    test('go sai han (khac han, Levenshtein > 2) -> wrong', () {
      expect(scoreVocabAnswer('umbrella', 'mother'), VocabAnswerResult.wrong);
    });

    test('go rong -> wrong, khong crash', () {
      expect(scoreVocabAnswer('', 'mother'), VocabAnswerResult.wrong);
    });
  });

  group('scoreSentence', () {
    test('dich dung y het -> 100 diem', () {
      final result = scoreSentence(
        targetEn: 'I have lived in Hanoi for three years.',
        userInput: 'I have lived in Hanoi for three years.',
      );
      expect(result.score, 100);
      expect(result.wordResults, everyElement(isTrue));
    });

    test('thieu vai tu -> diem giam theo ty le, khong crash', () {
      final result = scoreSentence(
        targetEn: 'I have lived in Hanoi for three years.',
        userInput: 'I lived Hanoi.',
      );
      expect(result.score, greaterThan(0));
      expect(result.score, lessThan(100));
    });

    test('khong go gi -> 0 diem', () {
      final result = scoreSentence(
        targetEn: 'I have lived in Hanoi for three years.',
        userInput: '',
      );
      expect(result.score, 0);
    });

    test('cau dich rong -> 0 diem, khong chia cho 0', () {
      final result = scoreSentence(targetEn: '', userInput: 'anything');
      expect(result.score, 0);
    });
  });
}

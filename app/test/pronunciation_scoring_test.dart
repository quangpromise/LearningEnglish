import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/pronunciation/data/pronunciation_scoring.dart';

void main() {
  group('normalizeForScoring', () {
    test(
      'ha chu thuong, bo dau cau, giu apostrophe cho tu KHONG phai '
      'contraction (khac "it\'s"/"don\'t"... - nhung tu do bi MO RONG, '
      'xem test nhom duoi)',
      () {
        expect(
          normalizeForScoring("Hello, World! Mai's umbrella."),
          ['hello', 'world', "mai's", 'umbrella'],
        );
      },
    );

    test('mo rong contraction ve dang day du', () {
      expect(normalizeForScoring("I'm fine"), ['i', 'am', 'fine']);
      expect(normalizeForScoring("don't stop"), ['do', 'not', 'stop']);
    });
  });

  group('lcsMatch', () {
    test('khop hoan toan -> tat ca true', () {
      final result = lcsMatch(['a', 'b', 'c'], ['a', 'b', 'c']);
      expect(result, [true, true, true]);
    });

    test('thieu 1 tu o giua van khop duoc phan con lai (LCS, khong phai vi tri tuyet doi)', () {
      final result = lcsMatch(['a', 'b', 'c'], ['a', 'c']);
      expect(result, [true, false, true]);
    });

    test('khong noi gi -> tat ca false', () {
      final result = lcsMatch(['a', 'b'], []);
      expect(result, [false, false]);
    });
  });

  group('scorePronunciation', () {
    test('noi dung y het target -> 100 diem', () {
      final result = scorePronunciation(
        targetEn: 'Now I am standing in the rain',
        recognized: 'Now I am standing in the rain',
      );
      expect(result.score, 100);
      expect(result.wordResults, everyElement(isTrue));
    });

    test(
      'target la CAU TUY CHINH khong nam trong bat ky bai hat nao van cham '
      'diem dung - day chinh la bug tung bi phat hien: truyen targetEn qua '
      'constructor truoc day bi PronunciationScreen.initState() ghi de bang '
      '1 dong lyric ngau nhien nen chi so nay khong bao gio phan anh dung '
      'cau nguoi dung thuc su duoc giao luyen (xem '
      'docs/architecture-multimedia-platform.md §A.5). scorePronunciation '
      'la ham thuan, khong co state nao co the ghi de - chung minh viec sua '
      'da tach dung logic cham diem ra khoi moi hanh vi "tu doi cau".',
      () {
        final result = scorePronunciation(
          targetEn: 'A completely custom sentence nobody sings',
          recognized: 'A completely custom sentence nobody sings',
        );
        expect(result.score, 100);
        expect(result.targetWords, [
          'a',
          'completely',
          'custom',
          'sentence',
          'nobody',
          'sings',
        ]);
      },
    );

    test('target rong -> 0 diem, khong chia cho 0', () {
      final result = scorePronunciation(targetEn: '', recognized: 'anything');
      expect(result.score, 0);
    });

    test('khong noi gi -> 0 diem', () {
      final result = scorePronunciation(
        targetEn: 'Some target sentence',
        recognized: '',
      );
      expect(result.score, 0);
    });
  });
}

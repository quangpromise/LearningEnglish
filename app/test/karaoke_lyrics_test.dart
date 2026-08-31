import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/music_player/data/songs_data.dart';
import 'package:learn_english_music/features/music_player/presentation/karaoke_lyrics.dart';

void main() {
  group('buildKaraokeLines', () {
    test('tu dau tien bat dau dung tai moc thoi gian that cua dong', () {
      final lines = buildKaraokeLines(const [
        LyricLine(9.6, 'Cold hands, sore feet', 'x'),
        LyricLine(14.4, 'Walking on abandoned streets', 'y'),
      ]);
      expect(lines.first.words.first.start, 9.6);
      expect(lines[1].words.first.start, 14.4);
    });

    test('cac tu noi tiep nhau lien mach, khong chong lan/ho', () {
      final line = buildKaraokeLines(const [
        LyricLine(0, 'One two three four five', 'x'),
        LyricLine(10, 'next', 'y'),
      ]).first;
      for (var i = 0; i < line.words.length; i++) {
        expect(line.words[i].end, greaterThan(line.words[i].start));
        if (i > 0) {
          expect(line.words[i].start, closeTo(line.words[i - 1].end, 1e-9));
        }
      }
      expect(line.end, closeTo(line.words.last.end, 1e-9));
    });

    test('tu nhieu am tiet duoc chia nhieu thoi gian hon tu 1 am tiet', () {
      final line = buildKaraokeLines(const [
        LyricLine(0, 'a abandoned', 'x'),
        LyricLine(10, 'next', 'y'),
      ]).first;
      final short = line.words[0].end - line.words[0].start;
      final long = line.words[1].end - line.words[1].start;
      expect(long, greaterThan(short));
    });

    test('khoang lang dai (nhac dao) khong lam vet quet bo cham lê thê', () {
      // Dong ngan nhung 40 giay sau moi toi dong ke tiep: hieu ung phai
      // ket thuc som chu khong keo dai het 40 giay.
      final line = buildKaraokeLines(const [
        LyricLine(0, 'Hold on', 'x'),
        LyricLine(40, 'next', 'y'),
      ]).first;
      expect(line.end, lessThan(8));
    });

    test('dong bi hat don dap thi quet vua het khoang trong, khong tran', () {
      final line = buildKaraokeLines(const [
        LyricLine(0, 'This is a very long and wordy line of lyrics', 'x'),
        LyricLine(2, 'next', 'y'),
      ]).first;
      expect(line.end, lessThanOrEqualTo(2.0 + 1e-9));
    });

    test('voi du lieu bai hat that: khong dong nao tran sang dong sau', () {
      for (final song in kSongs) {
        final lines = buildKaraokeLines(song.lyrics);
        expect(lines.length, song.lyrics.length, reason: song.title);
        for (var i = 0; i + 1 < lines.length; i++) {
          expect(
            lines[i].end,
            lessThanOrEqualTo(lines[i + 1].start + 1e-6),
            reason: '${song.title} dong $i',
          );
        }
      }
    });
  });

  group('KaraokeWord.progressAt', () {
    const word = KaraokeWord('hello', 2, 4);

    test('0 truoc khi toi, 1 sau khi qua', () {
      expect(word.progressAt(1.9), 0);
      expect(word.progressAt(4.1), 1);
    });

    test('chay tuyen tinh o giua', () {
      expect(word.progressAt(3), closeTo(0.5, 1e-9));
    });

    test('tu co do dai 0 giay khong lam chia cho 0', () {
      const zero = KaraokeWord('x', 5, 5);
      expect(zero.progressAt(5), 1);
    });
  });
}

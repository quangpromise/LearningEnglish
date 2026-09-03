import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/attribution/data/attribution_data.dart';
import 'package:learn_english_music/features/music_player/data/songs_data.dart';

void main() {
  group('kSongAttributions', () {
    test('phu dung 1-1 voi kSongs - khong thieu, khong du, khong trung', () {
      final songTitles = kSongs.map((s) => s.title).toSet();
      final attributionTitles = kSongAttributions
          .map((a) => a.songTitle)
          .toSet();
      expect(
        attributionTitles,
        songTitles,
        reason:
            'Moi bai trong kSongs phai co dung 1 dong ghi cong tuong ung - '
            'them bai moi vao songs_data.dart ma quen them ghi cong se lam '
            'test nay do (§A.7 cua tai lieu kien truc: khong duoc de lot '
            'bai nao khong co ghi cong hien trong app).',
      );
      expect(kSongAttributions.length, kSongs.length);
    });

    test('moi dong ghi cong co du thong tin de hien thi', () {
      for (final a in kSongAttributions) {
        expect(a.creator, isNotEmpty, reason: a.songTitle);
        expect(a.licenseId, isNotEmpty, reason: a.songTitle);
        expect(a.licenseUrl, startsWith('https://'), reason: a.songTitle);
        expect(a.sourceUrl, startsWith('https://'), reason: a.songTitle);
      }
    });
  });
}

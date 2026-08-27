import 'dart:async';

import 'package:just_audio/just_audio.dart';

/// AudioPlayer DUY NHẤT cho toàn app — trước đây mỗi PlayerScreen tự tạo
/// 1 AudioPlayer riêng, nên nếu người dùng thoát 1 bài rồi mở bài khác
/// NGAY LẬP TỨC (trong lúc màn hình cũ còn đang chuyển cảnh ~300ms và chưa
/// kịp dispose), 2 AudioPlayer tồn tại song song và phát đè lên nhau.
/// Dùng chung 1 player + "generation token" để loại bỏ hoàn toàn khả năng
/// đó, thay vì chỉ chặn bằng timing.
class NowPlayingService {
  NowPlayingService._();
  static final NowPlayingService instance = NowPlayingService._();

  final AudioPlayer player = AudioPlayer();
  int _generation = 0;

  /// Dừng bài đang phát (nếu có) rồi phát bài mới. Trả về "generation" -
  /// nếu trong lúc await mà có lượt play() khác gọi sau, generation hiện
  /// tại sẽ khác đi, dùng [isCurrent] để tự biết mình đã bị thay thế.
  Future<int> play(String url) async {
    final myGeneration = ++_generation;
    await player.stop();
    if (!isCurrent(myGeneration)) return myGeneration;
    await player.setUrl(url);
    if (!isCurrent(myGeneration)) return myGeneration;
    // Ep vi tri ve 0 truoc khi phat: dung chung 1 player cho nhieu bai, neu
    // khong seek lai, "position" co the con giu gia tri cua bai TRUOC trong
    // 1 khoang ngan sau setUrl(), khien dong loi bai hat nhay thang toi vi
    // tri sai hoan toan ngay tu dau (vd bai truoc dang o phut 2, bai moi
    // ngan hon nen moi dong loi deu bi coi la "da qua").
    await player.seek(Duration.zero);
    if (!isCurrent(myGeneration)) return myGeneration;
    // KHONG await Future cua play(): just_audio's play() tra ve 1 Future CHI
    // hoan tat khi phat xong/bi tam dung, khong phai ngay khi bat dau phat.
    // Neu await, ham play() nay (va moi thu goi no) se bi treo cho toi khi
    // het bai - day chinh la ly do truoc day phai bam dung/phat lai moi
    // "unblock" duoc (bam dung lam Future cua play() hoan tat som).
    unawaited(player.play());
    // Nhung van can XAC NHAN playback thuc su da bat dau (playing == true)
    // truoc khi tra ve - vi ban than lenh play() o tren la "ban roi quen",
    // neu no loi ngam (nguon chua san sang, mang chap chon...) thi khong ai
    // biet, vi tri phat dung yen o 0 mai mai (giong het trieu chung "loi
    // khong dong bo") cho toi khi nguoi dung tu bam nut Play/Pause (goi
    // player.play() truc tiep) moi thuc su chay - day la nguyen nhan that
    // su cua bug "phai bam phat lai moi chay", KHONG phai do stream lyric.
    try {
      await player.playingStream
          .firstWhere((playing) => playing)
          .timeout(const Duration(seconds: 3));
    } catch (_) {
      if (isCurrent(myGeneration)) {
        unawaited(player.play());
      }
    }
    return myGeneration;
  }

  bool isCurrent(int generation) => generation == _generation;

  /// Gọi khi rời màn phát nhạc — chỉ dừng nếu không có bài nào khác đã
  /// giành quyền phát trong lúc đó (generation vẫn là của màn hình đang đóng).
  void stopIfCurrent(int generation) {
    if (isCurrent(generation)) player.stop();
  }
}

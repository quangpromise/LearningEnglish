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
    await player.play();
    return myGeneration;
  }

  bool isCurrent(int generation) => generation == _generation;

  /// Gọi khi rời màn phát nhạc — chỉ dừng nếu không có bài nào khác đã
  /// giành quyền phát trong lúc đó (generation vẫn là của màn hình đang đóng).
  void stopIfCurrent(int generation) {
    if (isCurrent(generation)) player.stop();
  }
}

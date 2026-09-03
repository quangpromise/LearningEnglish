import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/music_player/data/songs_data.dart';
import '../../features/stats/data/stats_repository.dart';

/// AudioPlayer + hang doi (playlist) DUY NHAT cho toan app - phat lien tuc
/// ngay ca khi nguoi dung roi PlayerScreen (mini-player + thong bao he
/// thong/man hinh khoa van dieu khien duoc), giong Spotify. Dung
/// ConcatenatingAudioSource cua just_audio thay vi tu quan ly "bai ke tiep"
/// bang tay nhu truoc - duoc loi ca next/previous/shuffle THAT (giu nguyen
/// chi so logic, chi doi THU TU phat) va tu dong chuyen bai khi 1 bai ket
/// thuc, khong can code rieng.
class NowPlayingService {
  NowPlayingService._() {
    _initStatsTracking();
  }
  static final NowPlayingService instance = NowPlayingService._();

  final AudioPlayer player = AudioPlayer();

  List<Song> _queue = [];
  List<Song> get queue => _queue;
  bool get hasQueue => _queue.isNotEmpty;

  final _queueController = StreamController<List<Song>>.broadcast();

  /// Phat ra moi khi hang doi doi (bai moi/xoa het) - dung cho GlobalMediaBar
  /// biet luc nao can hien/an chinh no.
  Stream<List<Song>> get queueStream => _queueController.stream;

  Stream<int?> get currentIndexStream => player.currentIndexStream;
  int? get currentIndex => player.currentIndex;
  bool get shuffleEnabled => player.shuffleModeEnabled;

  /// Anh dai dien dung chung cho MOI bai hat trong thong bao/man hinh khoa -
  /// app chua co anh bia rieng tung bai, dung logo app thay the (dung yeu
  /// cau "kem logo ung dung" o thong bao).
  static final _artUri = Uri.parse('asset:///assets/icon/app_icon_square.png');

  /// Bat dau phat 1 hang doi bai hat moi tu vi tri [startIndex] - goi khi
  /// nguoi dung bam vao 1 bai o Home (khong goi lai khi chi mo lai
  /// PlayerScreen cho phien dang phat san, xem PlayerScreen).
  Future<void> setQueueAndPlay(List<Song> songs, int startIndex) async {
    // QUAN TRONG: gan _queue TRUOC bat ky await nao - PlayerScreen.initState()
    // goi ham nay KHONG await (fire-and-forget) roi doc _service.queue[_index]
    // NGAY SAU DO trong cung frame (xem _prepareLyrics()), dua vao viec ham
    // async chi chay dong bo (khong nhuong lai control cho caller) cho toi
    // await DAU TIEN. Neu dat 1 await nao truoc dong nay, _queue se van la
    // gia tri CU (rong luc app moi mo) tai thoi diem PlayerScreen doc no,
    // gay RangeError (danh sach rong) va man hinh phat nhac trang xoa.
    _queue = songs;
    _queueController.add(_queue);
    // Ep lai audio session ve che do "music" (loa ngoai) truoc khi phat -
    // sau khi dung mic (luyen phat am/speech_to_text), Android co the giu
    // nguyen audio mode cho ghi am/goi thoai, khien nhac phat ra qua loa
    // THOAI (earpiece) rat nho hoac nhu khong nghe duoc gi du file hoan toan
    // binh thuong. Xem giai thich chi tiet trong pronunciation_screen.dart.
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      // Xin lai audio focus - configure() khong tu lam viec nay (xem chu
      // thich tuong tu trong app_tts.dart._ensureMusicSession).
      await session.setActive(true);
    } catch (_) {}
    final source = ConcatenatingAudioSource(
      children: songs
          .map(
            (s) => AudioSource.uri(
              Uri.parse(s.audioUrl),
              tag: MediaItem(
                id: s.title,
                title: s.title,
                artist: s.artist,
                artUri: _artUri,
              ),
            ),
          )
          .toList(),
    );
    // Tat shuffle moi lan bat dau 1 hang doi moi - tranh mang theo trang thai
    // shuffle cua phien nghe truoc sang 1 danh sach bai hoan toan khac.
    if (player.shuffleModeEnabled) {
      await player.setShuffleModeEnabled(false);
    }
    await player.setAudioSource(source, initialIndex: startIndex);
    await player.play();
  }

  Future<void> next() => player.seekToNext();
  Future<void> previous() => player.seekToPrevious();

  /// Bat/tat phat ngau nhien - khi bat, xao lai THU TU phat ngay lap tuc
  /// (giong nut shuffle cua Spotify), chi so logic (dung cho lyric/tieu de)
  /// khong doi.
  Future<void> toggleShuffle() async {
    final enable = !player.shuffleModeEnabled;
    if (enable) await player.shuffle();
    await player.setShuffleModeEnabled(enable);
  }

  void clearQueue() {
    _queue = [];
    _queueController.add(_queue);
    player.stop();
  }

  // --- Ghi nhan "hoc xong 1 bai" cho thong ke, hoat dong CA KHI PlayerScreen
  // da dong (nguoi dung dang xem man hinh khac, chi con mini-player) - truoc
  // day logic nay nam trong PlayerScreen nen chi ghi nhan duoc neu man hinh
  // van con mo luc bai ket thuc. ---

  Duration _trackedPosition = Duration.zero;
  Duration? _trackedDuration;
  int? _trackedIndex;

  void _initStatsTracking() {
    player.positionStream.listen((p) {
      _trackedPosition = p;
      _trackedDuration = player.duration;
      _trackedIndex = player.currentIndex;
    });
    player.currentIndexStream.listen((newIndex) {
      final prevIndex = _trackedIndex;
      final dur = _trackedDuration;
      // Chi tinh la "hoc xong" neu vi tri dung lai GAN sat cuoi bai truoc do
      // (bai tu ket thuc) - phan biet voi nguoi dung tu bam Bai tiep theo bo
      // qua giua chung, vi luc do vi tri con cach xa duration.
      if (prevIndex != null &&
          newIndex != null &&
          newIndex != prevIndex &&
          prevIndex < _queue.length &&
          dur != null &&
          dur.inMilliseconds > 0 &&
          _trackedPosition.inMilliseconds >= dur.inMilliseconds - 1500) {
        StatsRepository(Supabase.instance.client)
            .recordSongCompleted(_queue[prevIndex].title)
            .catchError((_) {});
      }
      _trackedIndex = newIndex;
    });
  }
}

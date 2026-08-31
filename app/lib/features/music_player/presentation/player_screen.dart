import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/audio/now_playing_service.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../grammar/presentation/grammar_screen.dart';
import '../../translation/presentation/word_popup_sheet.dart';
import '../data/songs_data.dart';
import 'karaoke_lyrics.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({
    super.key,
    required this.queue,
    required this.startIndex,
  });

  /// Danh sách bài hát sẽ phát nối tiếp nhau (tự động chuyển bài khi 1 bài
  /// kết thúc) - vd toàn bộ danh sách/kết quả tìm kiếm ở Home, bắt đầu từ
  /// bài người dùng vừa bấm.
  final List<Song> queue;
  final int startIndex;

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with SingleTickerProviderStateMixin {
  // Dung chung 1 AudioPlayer cho toan app (xem now_playing_service.dart) -
  // truoc day moi PlayerScreen tu tao AudioPlayer rieng, nen thoat 1 bai roi
  // mo bai khac ngay lap tuc (trong luc man hinh cu con dang chuyen canh,
  // chua kip dispose) khien 2 AudioPlayer ton tai song song, phat de len nhau.
  AudioPlayer get _player => NowPlayingService.instance.player;
  int? _myGeneration;
  late int _index;
  Song get _song => widget.queue[_index];
  int _currentLine = 0;
  bool _bilingual = true;
  String? _error;
  bool _completedRecorded = false;
  StreamSubscription<PlayerState>? _stateSub;
  late List<GlobalKey> _lineKeys;

  /// Lyric da duoc chia xuong tung tu kem moc thoi gian rieng (xem
  /// karaoke_lyrics.dart) de chay hieu ung to sang tung chu theo giong hat.
  late List<KaraokeLine> _karaoke;

  /// Vi tri phat hien tai (giay), cap nhat MOI KHUNG HINH. Dung
  /// ValueNotifier thay vi setState vi chi RIENG dong lyric dang hat can ve
  /// lai o ~60fps - neu setState ca man hinh moi khung hinh thi anh bia,
  /// nut bam, danh sach... deu bi build lai vo ich.
  final ValueNotifier<double> _positionSeconds = ValueNotifier<double>(0);
  Ticker? _ticker;
  late final DateTime _openedAt;
  bool _disposed = false;

  bool get _isCurrentOwner =>
      _myGeneration != null &&
      NowPlayingService.instance.isCurrent(_myGeneration!);

  @override
  void initState() {
    super.initState();
    _openedAt = DateTime.now();
    _index = widget.startIndex;
    _prepareLyrics();
    // Doc _player.position moi khung hinh thay vi Timer.periodic 250ms:
    // hieu ung karaoke quet chu ben trong TUNG TU nen can vi tri muot, moc
    // 250ms mot lan se thay chu nhay giat theo tung nac.
    _ticker = createTicker(_onTick)..start();
    _loadAndPlay();
  }

  void _prepareLyrics() {
    _lineKeys = List.generate(_song.lyrics.length, (_) => GlobalKey());
    _karaoke = buildKaraokeLines(_song.lyrics);
  }

  /// Chay moi khung hinh: cap nhat vi tri phat cho hieu ung karaoke, va doi
  /// dong dang hat khi vuot qua moc thoi gian cua dong ke tiep.
  void _onTick(Duration _) {
    if (!_isCurrentOwner) return;
    final seconds = _player.position.inMilliseconds / 1000.0;
    // ValueNotifier tu bo qua khi gia tri khong doi, nen luc dang tam dung
    // se khong co listener nao bi danh thuc.
    _positionSeconds.value = seconds;
    var line = 0;
    for (var i = 0; i < _karaoke.length; i++) {
      if (seconds >= _karaoke[i].start) line = i;
    }
    if (line != _currentLine && mounted) {
      setState(() => _currentLine = line);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToCurrentLine(),
      );
    }
  }

  /// Chuyen sang bai ke tiep trong hang doi khi bai hien tai vua ket thuc -
  /// dung lai cung 1 man hinh (khong push man moi) de tao cam giac "nghe
  /// lien tuc nhieu bai" thay vi phai tu quay lai Home chon bai tiep.
  void _playNextInQueue() {
    if (_index + 1 >= widget.queue.length) return;
    setState(() {
      _index++;
      _currentLine = 0;
      _completedRecorded = false;
      _error = null;
      _prepareLyrics();
    });
    _loadAndPlay();
  }

  void _scrollToCurrentLine([int retriesLeft = 5]) {
    final key = _lineKeys[_currentLine];
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.42,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    } else if (retriesLeft > 0) {
      // ListView.builder chỉ build các item gần vùng hiển thị — nếu dòng
      // hiện tại nhảy xa (mới mở bài, hoặc seek), context của nó chưa tồn
      // tại ngay khi frame này build xong. Thử lại vài lần ở frame sau.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToCurrentLine(retriesLeft - 1),
      );
    }
  }

  Future<void> _loadAndPlay() async {
    final song = _song;
    try {
      _myGeneration = await NowPlayingService.instance.play(song.audioUrl);
    } catch (e) {
      if (mounted) {
        setState(() => _error = ref.tr('player_load_error'));
      }
    }
    // Man hinh co the da bi dong, hoac 1 bai khac da giat quyen phat trong
    // luc await o tren dang cho - neu khong chan lai, timer duoc tao sau day
    // se lang nghe nham player dang phat bai KHAC.
    if (_disposed || !_isCurrentOwner) return;
    _stateSub?.cancel();
    // Cuon lan dau ngay khi vua vao bai: neu dong dau tien (_currentLine=0)
    // trung voi dong tinh duoc tu vi tri hien tai, nhanh "line != _currentLine"
    // trong _onTick se KHONG bao gio dung (vi ca 2 deu la 0) nen
    // _scrollToCurrentLine chua bao gio duoc goi - day la ly do truoc day
    // phai tam dung/phat lai (lam _currentLine doi tam thoi) thi cuon moi
    // bat dau chay.
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentLine());
    _stateSub = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed &&
          !_completedRecorded &&
          _isCurrentOwner) {
        _completedRecorded = true;
        ref
            .read(statsRepositoryProvider)
            .recordSongCompleted(song.title)
            .then((_) => ref.invalidate(myStatsProvider))
            .catchError((_) {});
        _playNextInQueue();
      }
      // Moi lan nguoi dung bam tiep tuc phat (hoac tu dong resume), dam bao
      // vi tri hien tai duoc cuon dung vao khung hinh - phong khi lan dau
      // tien bi bo lo do ListView chua kip layout xong.
      if (state.playing && _isCurrentOwner && mounted) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToCurrentLine(),
        );
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    final elapsed = DateTime.now().difference(_openedAt).inSeconds;
    if (elapsed > 0) {
      ref.read(statsRepositoryProvider).addPracticeSeconds(elapsed);
    }
    _ticker?.dispose();
    _positionSeconds.dispose();
    _stateSub?.cancel();
    // Player la singleton dung chung toan app - KHONG duoc dispose() no o
    // day. Chi dung phat neu khong co man hinh nao khac da giat quyen
    // (vd nguoi dung mo bai khac) trong luc man hinh nay dang dong.
    if (_myGeneration != null) {
      NowPlayingService.instance.stopIfCurrent(_myGeneration!);
    }
    super.dispose();
  }

  void _onWordTap(String word) {
    final lyrics = _song.lyrics;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => WordPopupSheet(
        word: word,
        sentenceEn: lyrics[_currentLine].en,
        sentenceVi: lyrics[_currentLine].vi,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lyrics = _song.lyrics;
    final favoritesAsync = ref.watch(favoriteSongTitlesProvider);
    final isFavorite =
        favoritesAsync.valueOrNull?.contains(_song.title) ?? false;
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CircleBtn(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
                Text(
                  widget.queue.length > 1
                      ? '${ref.tr('player_now_playing')} · ${_index + 1}/${widget.queue.length}'
                      : ref.tr('player_now_playing'),
                  style: AppTextStyles.muted(size: 11)
                      .copyWith(letterSpacing: 1),
                ),
                Row(
                  children: [
                    _CircleBtn(
                      icon: isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      iconColor: isFavorite ? AppColors.pink : null,
                      onTap: () async {
                        final repo = ref.read(favoritesRepositoryProvider);
                        if (isFavorite) {
                          await repo.removeFavorite(_song.title);
                        } else {
                          await repo.addFavorite(_song.title);
                        }
                        ref.invalidate(favoriteSongTitlesProvider);
                      },
                    ),
                    const SizedBox(width: 8),
                    _CircleBtn(
                      icon: Icons.menu_book_rounded,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => GrammarScreen(
                            sentence: LyricLine(
                              lyrics[_currentLine].startSeconds,
                              lyrics[_currentLine].en,
                              lyrics[_currentLine].vi,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purple.withValues(alpha: 0.4),
                    blurRadius: 60,
                    offset: const Offset(0, 24),
                  ),
                ],
              ),
              child: const Icon(
                Icons.music_note_rounded,
                color: Colors.white,
                size: 56,
              ),
            ),
            const SizedBox(height: 16),
            Text(_song.title, style: AppTextStyles.heading(size: 19)),
            Text(_song.artist, style: AppTextStyles.muted()),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: AppTextStyles.muted().copyWith(color: AppColors.amber),
              ),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: KaraokeLyricsView(
                lines: _karaoke,
                activeIndex: _currentLine,
                positionSeconds: _positionSeconds,
                lineKeys: _lineKeys,
                bilingual: _bilingual,
                onSeekToLine: (i) => _player.seek(
                  Duration(
                    milliseconds: (lyrics[i].startSeconds * 1000).round(),
                  ),
                ),
                onWordTap: _onWordTap,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ref.tr('player_bilingual_toggle'),
                  style: AppTextStyles.muted(),
                ),
                const SizedBox(width: 10),
                Switch(
                  value: _bilingual,
                  activeTrackColor: AppColors.purple,
                  onChanged: (v) => setState(() => _bilingual = v),
                ),
              ],
            ),
            StreamBuilder<PlayerState>(
              stream: _player.playerStateStream,
              builder: (context, snapshot) {
                final playing = snapshot.data?.playing ?? false;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => _player.seek(
                        Duration(
                          seconds: (_player.position.inSeconds - 10).clamp(
                            0,
                            1 << 30,
                          ),
                        ),
                      ),
                      icon: const Icon(
                        Icons.replay_10_rounded,
                        color: AppColors.textPrimary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => playing ? _player.pause() : _player.play(),
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          gradient: AppColors.accentGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blue.withValues(alpha: 0.5),
                              blurRadius: 40,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Icon(
                          playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () => _player.seek(
                        Duration(seconds: _player.position.inSeconds + 10),
                      ),
                      icon: const Icon(
                        Icons.forward_10_rounded,
                        color: AppColors.textPrimary,
                        size: 26,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.onTap, this.iconColor});
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Icon(icon, size: 18, color: iconColor ?? AppColors.textPrimary),
      ),
    );
  }
}

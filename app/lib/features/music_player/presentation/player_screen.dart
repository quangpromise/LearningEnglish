import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/audio/now_playing_service.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../grammar/presentation/grammar_screen.dart';
import '../../translation/presentation/word_popup_sheet.dart';
import '../data/songs_data.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key, required this.song});
  final Song song;

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  // Dung chung 1 AudioPlayer cho toan app (xem now_playing_service.dart) -
  // truoc day moi PlayerScreen tu tao AudioPlayer rieng, nen thoat 1 bai roi
  // mo bai khac ngay lap tuc (trong luc man hinh cu con dang chuyen canh,
  // chua kip dispose) khien 2 AudioPlayer ton tai song song, phat de len nhau.
  AudioPlayer get _player => NowPlayingService.instance.player;
  int? _myGeneration;
  int _currentLine = 0;
  bool _bilingual = true;
  String? _error;
  bool _completedRecorded = false;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _stateSub;
  late final List<GlobalKey> _lineKeys;
  late final DateTime _openedAt;
  bool _disposed = false;

  bool get _isCurrentOwner =>
      _myGeneration != null &&
      NowPlayingService.instance.isCurrent(_myGeneration!);

  @override
  void initState() {
    super.initState();
    _openedAt = DateTime.now();
    _lineKeys = List.generate(widget.song.lyrics.length, (_) => GlobalKey());
    _loadAndPlay();
  }

  void _scrollToCurrentLine([int retriesLeft = 5]) {
    final key = _lineKeys[_currentLine];
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
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
    try {
      _myGeneration = await NowPlayingService.instance.play(
        widget.song.audioUrl,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Không tải được nhạc. Kiểm tra kết nối mạng.');
      }
    }
    // Man hinh co the da bi dong, hoac 1 bai khac da giat quyen phat trong
    // luc await o tren dang cho - neu khong chan lai, subscription duoc tao
    // sau day se lang nghe nham player dang phat bai KHAC.
    if (_disposed || !_isCurrentOwner) return;
    _positionSub = _player.positionStream.listen((pos) {
      final lyrics = widget.song.lyrics;
      var line = 0;
      for (var i = 0; i < lyrics.length; i++) {
        if (pos.inMilliseconds / 1000 >= lyrics[i].startSeconds) line = i;
      }
      if (line != _currentLine && mounted) {
        setState(() => _currentLine = line);
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToCurrentLine(),
        );
      }
    });
    _stateSub = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed &&
          !_completedRecorded) {
        _completedRecorded = true;
        ref
            .read(statsRepositoryProvider)
            .recordSongCompleted(widget.song.title)
            .then((_) => ref.invalidate(myStatsProvider))
            .catchError((_) {});
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
    _positionSub?.cancel();
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
    final lyrics = widget.song.lyrics;
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
    final lyrics = widget.song.lyrics;
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
                  'ĐANG PHÁT',
                  style: AppTextStyles.muted(size: 11)
                      .copyWith(letterSpacing: 1),
                ),
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
            Text(widget.song.title, style: AppTextStyles.heading(size: 19)),
            Text(widget.song.artist, style: AppTextStyles.muted()),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: AppTextStyles.muted().copyWith(color: AppColors.amber),
              ),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                // Build sẵn nhiều dòng ở ngoài vùng hiển thị (không chỉ dòng
                // đang thấy) để khi bài mới mở/seek xa, dòng đích đã có
                // context sẵn cho Scrollable.ensureVisible thay vì null.
                scrollCacheExtent: const ScrollCacheExtent.pixels(2000),
                itemCount: lyrics.length,
                itemBuilder: (context, i) {
                  final line = lyrics[i];
                  final isCurrent = i == _currentLine;
                  return GestureDetector(
                    key: _lineKeys[i],
                    onTap: () => _player.seek(
                      Duration(
                        milliseconds: (line.startSeconds * 1000).round(),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: AnimatedScale(
                        scale: isCurrent ? 1.12 : 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        child: AnimatedOpacity(
                          opacity: isCurrent ? 1 : 0.3,
                          duration: const Duration(milliseconds: 300),
                          child: Column(
                            children: [
                              Wrap(
                                alignment: WrapAlignment.center,
                                children: line.en.split(' ').map((w) {
                                  return GestureDetector(
                                    onTap: isCurrent
                                        ? () => _onWordTap(
                                            w.replaceAll(
                                              RegExp('[^a-zA-Z]'),
                                              '',
                                            ),
                                          )
                                        : null,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      child: isCurrent
                                          ? ShaderMask(
                                              shaderCallback: (rect) =>
                                                  AppColors.accentGradient
                                                      .createShader(rect),
                                              child: Text(
                                                w,
                                                style: AppTextStyles.heading(
                                                  size: 21,
                                                ),
                                              ),
                                            )
                                          : Text(
                                              w,
                                              style: AppTextStyles.heading(
                                                size: 15,
                                              ),
                                            ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              if (_bilingual)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    line.vi,
                                    style: AppTextStyles.muted(
                                      size: isCurrent ? 13 : 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Song ngữ Anh – Việt', style: AppTextStyles.muted()),
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
  const _CircleBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

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
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

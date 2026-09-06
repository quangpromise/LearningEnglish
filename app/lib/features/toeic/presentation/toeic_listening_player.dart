import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/tts/app_tts.dart';

/// 1 doan audio can doc (text + pitch) - pitch null nghia la giong mac dinh.
typedef ToeicAudioSegment = ({String text, double? pitch});

/// Phat TTS tuan tu cho 1 nhom cau hoi Listening (Part 1-4), dung lai dung
/// pattern token-huy cua story_screen.dart's _playFrom. PHAI duoc dat trong
/// 1 `ValueKey(groupKey)` boi man goi (xem toeic_exam_screen.dart) - nho vay
/// khi 2-3 cau hoi lien tiep dung CHUNG 1 audioScriptId (Part 3/4), widget
/// nay KHONG bi remount/phat lai tu dau, dung mo phong "chi nghe 1 lan cho
/// ca nhom" giong thi that.
class ToeicListeningPlayer extends StatefulWidget {
  const ToeicListeningPlayer({
    super.key,
    required this.segments,
    required this.autoPlay,
    required this.allowReplay,
  });

  final List<ToeicAudioSegment> segments;

  /// true (che do Thi thu): tu dong phat ngay khi widget duoc tao (nhom
  /// moi). false (Luyen tap): nguoi dung tu bam de phat.
  final bool autoPlay;

  /// false (Thi thu): AN nut "Nghe lai" sau khi da phat xong - giong luat
  /// thi that chi nghe duoc 1 lan.
  final bool allowReplay;

  @override
  State<ToeicListeningPlayer> createState() => _ToeicListeningPlayerState();
}

class _ToeicListeningPlayerState extends State<ToeicListeningPlayer> {
  int _token = 0;
  bool _playing = false;
  bool _playedOnce = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay) _play();
  }

  @override
  void dispose() {
    _token++;
    AppTts.instance.stopSpeaking();
    super.dispose();
  }

  Future<void> _play() async {
    final token = ++_token;
    setState(() => _playing = true);
    for (final seg in widget.segments) {
      if (!mounted || token != _token) return;
      await AppTts.instance.speakAndWait(seg.text, pitch: seg.pitch);
    }
    if (!mounted || token != _token) return;
    setState(() {
      _playing = false;
      _playedOnce = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final canTapPlay = !_playing && (widget.allowReplay || !_playedOnce);
    return Material(
      type: MaterialType.transparency,
      child: GlowBox(
        borderRadius: 999,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            GestureDetector(
              onTap: canTapPlay ? _play : null,
              child: Icon(
                _playing
                    ? Icons.graphic_eq_rounded
                    : (_playedOnce && !widget.allowReplay
                          ? Icons.volume_off_rounded
                          : Icons.play_circle_fill_rounded),
                size: 30,
                color: canTapPlay ? AppColors.blue : AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _playing
                    ? 'Đang phát âm thanh...'
                    : (_playedOnce
                          ? (widget.allowReplay
                                ? 'Đã phát xong - bấm để nghe lại'
                                : 'Chỉ nghe được 1 lần, giống thi thật')
                          : 'Bấm để nghe'),
                style: AppTextStyles.muted(size: 11.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

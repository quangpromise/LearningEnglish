import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/tts/app_tts.dart';

/// 1 doan audio can doc (text + pitch) - copy nguyen ven kieu du lieu cua
/// ToeicAudioSegment.
typedef IeltsAudioSegment = ({String text, double? pitch});

/// Phat TTS tuan tu cho 1 nhom cau hoi Listening - copy gan nguyen ven
/// ToeicListeningPlayer (cung pattern token-huy, cung 2 co `autoPlay`/
/// `allowReplay` theo che do). PHAI duoc dat trong 1 `ValueKey(groupKey)`
/// boi man goi de khong bi phat lai khi van con trong cung 1 nhom cau hoi.
class IeltsListeningPlayer extends StatefulWidget {
  const IeltsListeningPlayer({
    super.key,
    required this.segments,
    required this.autoPlay,
    required this.allowReplay,
  });

  final List<IeltsAudioSegment> segments;
  final bool autoPlay;
  final bool allowReplay;

  @override
  State<IeltsListeningPlayer> createState() => _IeltsListeningPlayerState();
}

class _IeltsListeningPlayerState extends State<IeltsListeningPlayer> {
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

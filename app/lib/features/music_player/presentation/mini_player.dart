import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/audio/now_playing_service.dart';
import '../../../core/theme/app_theme.dart';
import '../data/songs_data.dart';
import 'player_screen.dart';

/// Thanh mini-player kieu Spotify - hien phia tren thanh tab khi co bai dang
/// phat nhung nguoi dung da back ra khoi PlayerScreen, cho biet ten bai +
/// thoi gian con lai + dieu khien nhanh (bai truoc/phat-tam dung/bai sau)
/// ma khong can mo lai man hinh day du. Bam vao thanh nay se mo lai
/// PlayerScreen cho dung phien dang phat (xem PlayerScreen voi queue=null).
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final service = NowPlayingService.instance;
    return StreamBuilder<List<Song>>(
      stream: service.queueStream,
      initialData: service.queue,
      builder: (context, queueSnap) {
        final queue = queueSnap.data ?? const <Song>[];
        if (queue.isEmpty) return const SizedBox.shrink();
        return StreamBuilder<int?>(
          stream: service.currentIndexStream,
          initialData: service.currentIndex,
          builder: (context, indexSnap) {
            final index = indexSnap.data;
            if (index == null || index < 0 || index >= queue.length) {
              return const SizedBox.shrink();
            }
            final song = queue[index];
            return GestureDetector(
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const PlayerScreen())),
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xEB0F1326),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.glassBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/icon/app_icon_square.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.body(
                                  weight: FontWeight.w700,
                                ),
                              ),
                              StreamBuilder<Duration>(
                                stream: service.player.positionStream,
                                initialData: service.player.position,
                                builder: (context, posSnap) {
                                  final pos = posSnap.data ?? Duration.zero;
                                  final dur =
                                      service.player.duration ?? Duration.zero;
                                  final remaining = dur - pos;
                                  return Text(
                                    remaining.isNegative
                                        ? '0:00'
                                        : _fmt(remaining),
                                    style: AppTextStyles.muted(size: 11.5),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: queue.length > 1 ? service.previous : null,
                          icon: const Icon(
                            Icons.skip_previous_rounded,
                            color: AppColors.textPrimary,
                            size: 22,
                          ),
                        ),
                        StreamBuilder<PlayerState>(
                          stream: service.player.playerStateStream,
                          initialData: service.player.playerState,
                          builder: (context, snap) {
                            final playing = snap.data?.playing ?? false;
                            return GestureDetector(
                              onTap: () => playing
                                  ? service.player.pause()
                                  : service.player.play(),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  gradient: AppColors.accentGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  playing
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          onPressed: queue.length > 1 ? service.next : null,
                          icon: const Icon(
                            Icons.skip_next_rounded,
                            color: AppColors.textPrimary,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    StreamBuilder<Duration>(
                      stream: service.player.positionStream,
                      initialData: service.player.position,
                      builder: (context, posSnap) {
                        final pos = posSnap.data ?? Duration.zero;
                        final dur = service.player.duration;
                        final progress = (dur != null && dur.inMilliseconds > 0)
                            ? (pos.inMilliseconds / dur.inMilliseconds).clamp(
                                0.0,
                                1.0,
                              )
                            : 0.0;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 3,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.08,
                            ),
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.blue,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

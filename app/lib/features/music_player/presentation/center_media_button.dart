import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/audio/now_playing_service.dart';
import '../../../core/theme/app_theme.dart';
import '../data/songs_data.dart';
import 'player_screen.dart';

/// Thanh nhac dang phat DAI, NAM SAN NGAY TRONG thanh Menu duoi (khong con
/// noi/chong len nhu truoc) - chiem het khoang trong con lai giua cac icon
/// tab (dung [Expanded] tu noi goi). Luon hien MAC DINH ke ca khi chua co
/// bai nao dang phat (trang thai rut gon, cham vao se tu phat bai dau tien)
/// - dap ung yeu cau "mac dinh o Menubar" thay vi chi hien khi co nhac. Mau
/// vien/icon nhan theo [accentColor] cua tung "app" (Hoc Tieng Anh/Fitness/
/// Wealth) de dong bo voi phan con lai cua thanh Menu do.
class CenterMediaButton extends StatelessWidget {
  const CenterMediaButton({super.key, required this.accentColor});
  final Color accentColor;

  static String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final service = NowPlayingService.instance;
    return StreamBuilder<List<Song>>(
      stream: service.queueStream,
      initialData: service.queue,
      builder: (context, queueSnap) {
        final queue = queueSnap.data ?? const <Song>[];
        return Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: accentColor.withValues(alpha: 0.45)),
          ),
          child: queue.isEmpty
              ? _IdleBar(accentColor: accentColor)
              : _PlayingBar(accentColor: accentColor, queue: queue),
        );
      },
    );
  }
}

/// Trang thai chua co bai nao dang phat - van chiem dung vi tri (khong bien
/// mat) de thanh Menu khong bi "nhay" khi bat dau phat nhac; cham vao tu
/// phat luon bai dau tien roi mo popup Dang phat.
class _IdleBar extends StatelessWidget {
  const _IdleBar({required this.accentColor});
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await NowPlayingService.instance.setQueueAndPlay(kSongs, 0);
        if (context.mounted) _openPlayerPopup(context);
      },
      child: Row(
        children: [
          const SizedBox(width: 6),
          Icon(Icons.music_note_rounded, size: 16, color: accentColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Chưa phát nhạc',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.muted(size: 11.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayingBar extends StatelessWidget {
  const _PlayingBar({required this.accentColor, required this.queue});
  final Color accentColor;
  final List<Song> queue;

  @override
  Widget build(BuildContext context) {
    final service = NowPlayingService.instance;
    return Row(
      children: [
        _Btn(
          icon: Icons.unfold_more_rounded,
          color: accentColor,
          onTap: () => _openPlayerPopup(context),
        ),
        _Btn(
          icon: Icons.skip_previous_rounded,
          color: AppColors.textPrimary,
          onTap: queue.length > 1 ? service.previous : null,
        ),
        StreamBuilder<PlayerState>(
          stream: service.player.playerStateStream,
          initialData: service.player.playerState,
          builder: (context, snap) {
            final playing = snap.data?.playing ?? false;
            return _Btn(
              icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: accentColor,
              onTap: () =>
                  playing ? service.player.pause() : service.player.play(),
            );
          },
        ),
        Expanded(
          child: StreamBuilder<int?>(
            stream: service.currentIndexStream,
            initialData: service.currentIndex,
            builder: (context, indexSnap) {
              final index = indexSnap.data;
              final title = (index != null && index < queue.length)
                  ? queue[index].title
                  : '';
              return StreamBuilder<Duration>(
                stream: service.player.positionStream,
                initialData: service.player.position,
                builder: (context, posSnap) {
                  final pos = posSnap.data ?? Duration.zero;
                  final dur = service.player.duration ?? Duration.zero;
                  final remaining = dur - pos;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body(
                          size: 11,
                          weight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        remaining.isNegative
                            ? '-0:00'
                            : '-${CenterMediaButton._fmt(remaining)}',
                        style: AppTextStyles.muted(size: 9.5),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        _Btn(
          icon: Icons.skip_next_rounded,
          color: AppColors.textPrimary,
          onTap: queue.length > 1 ? service.next : null,
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

/// Mo PlayerScreen dang POPUP (bottom sheet gan full man hinh, boc goc tren)
/// thay vi day sang 1 man hinh rieng. useRootNavigator: true - nut nay nam
/// trong Navigator LONG cua tung tab (xem root_shell.dart/fitness_shell.dart/
/// wealth_shell.dart), phai neo vao Navigator GOC de popup phu duoc toan bo
/// man hinh (ke ca de len thanh Menu) thay vi bi gioi han trong vung than
/// (body) cua Navigator long.
void _openPlayerPopup(BuildContext context) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.94,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: const PlayerScreen(),
      ),
    ),
  );
}

class _Btn extends StatelessWidget {
  const _Btn({required this.icon, required this.onTap, required this.color});
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Icon(
          icon,
          size: 20,
          color: onTap != null ? color : color.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}

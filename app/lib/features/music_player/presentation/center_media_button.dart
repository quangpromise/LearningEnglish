import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/audio/now_playing_service.dart';
import '../../../core/theme/app_theme.dart';
import '../data/songs_data.dart';
import 'player_screen.dart';

/// Thanh nhac dang phat DAI, NAM SAN NGAY TRONG thanh Menu duoi - thiet ke
/// lai theo kieu "media widget" cua iOS/macOS (anh bia nho + ten bai/ca si +
/// thanh tien trinh chay, prev/play/next 1 ben, nut mo rong 1 ben). Luon
/// hien MAC DINH ke ca khi chua co bai nao dang phat (trang thai rut gon,
/// cham vao se tu phat bai dau tien). Mau vien/icon nhan theo [accentColor]
/// cua tung "app" (Hoc Tieng Anh/Fitness/Wealth).
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
          // Full size nhu pill Menu CU (truoc day la 1 Container rieng boc
          // ngoai icon Home/Tin nhan + thanh nhac, cao ~64 do padding doc
          // 10+10 quanh icon 44) - gio thanh nhac La CHINH NO 1 pill day du
          // (khong con bi boc trong 1 Container trang tri khac gay long
          // nhau/lech kich thuoc), nen mang nguyen mau nen kinh + do bong
          // cua pill Menu cu, chi doi vien sang mau accent cua tung app.
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xD90A0E1C),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: accentColor.withValues(alpha: 0.55)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
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
        _Btn(
          icon: Icons.skip_next_rounded,
          color: AppColors.textPrimary,
          onTap: queue.length > 1 ? service.next : null,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: StreamBuilder<int?>(
            stream: service.currentIndexStream,
            initialData: service.currentIndex,
            builder: (context, indexSnap) {
              final index = indexSnap.data;
              final song = (index != null && index < queue.length)
                  ? queue[index]
                  : null;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _openPlayerPopup(context),
                child: Row(
                  children: [
                    // Anh bia thu nho - app chua co anh bia rieng tung bai
                    // nen dung khoi mau cua bai hat (song.color, da dung
                    // cung mau nay o danh sach "Goi y cho ban") + icon nhac
                    // thay the, giong vi tri "album art" trong widget tham
                    // khao.
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: song?.color ?? accentColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.music_note_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song?.title ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body(
                              size: 12,
                              weight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            song?.artist ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.muted(size: 10),
                          ),
                          const SizedBox(height: 4),
                          // Thanh tien trinh chay + thoi gian - dung
                          // StreamBuilder rieng (khong bao Column ngoai
                          // cung) de CHI phan nay rebuild moi giay thay vi
                          // ca ten bai/anh bia.
                          StreamBuilder<Duration>(
                            stream: service.player.positionStream,
                            initialData: service.player.position,
                            builder: (context, posSnap) {
                              final pos = posSnap.data ?? Duration.zero;
                              final dur =
                                  service.player.duration ?? Duration.zero;
                              final ratio = dur.inMilliseconds > 0
                                  ? (pos.inMilliseconds / dur.inMilliseconds)
                                        .clamp(0.0, 1.0)
                                  : 0.0;
                              final remaining = dur - pos;
                              return Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(999),
                                      child: LinearProgressIndicator(
                                        value: ratio,
                                        minHeight: 3,
                                        backgroundColor: Colors.white
                                            .withValues(alpha: 0.14),
                                        color: accentColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    remaining.isNegative
                                        ? '-0:00'
                                        : '-${CenterMediaButton._fmt(remaining)}',
                                    style: AppTextStyles.muted(size: 9),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 4),
        // Nut mo rong - dung icon 2 mui ten cheo huong ra ngoai (giong nut
        // "phong to man hinh"), giong het cach cham vao anh bia/ten bai
        // (Row ben tren) cung mo popup Dang phat - 2 cach lam CUNG 1 viec.
        _Btn(
          icon: Icons.open_in_full_rounded,
          color: accentColor,
          onTap: () => _openPlayerPopup(context),
        ),
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

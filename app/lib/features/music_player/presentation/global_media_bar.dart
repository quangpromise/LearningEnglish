import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/audio/now_playing_service.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/songs_data.dart';
import 'player_screen.dart';

/// Thanh nhac dang phat TOAN CUC (thay the MiniPlayer cu) - noi tren MOI
/// "app" (Hoc Tieng Anh/Fitness/Wealth), khong rieng RootShell, vi nhac hoc
/// tieng Anh co the tiep tuc phat trong luc dang xem Fitness/Wealth. Dat
/// trong Stack cua MaterialApp.builder (xem main.dart, cung tang voi
/// AiFabOverlay) thay vi la 1 phan cua tung Scaffold rieng le - chi 1 noi
/// duy nhat, tu dong xuat hien tren MOI man hinh cua ca 3 khu vuc.
///
/// Thiet ke theo anh tham khao nguoi dung gui: the bo tron noi len, avatar +
/// ten bai + nut mo rong/yeu thich o hang tren, thanh tien do voi nhan thoi
/// gian 2 dau, hang nut dieu khien (lui/phat-tam dung/toi) o giua.
class GlobalMediaBar extends ConsumerWidget {
  const GlobalMediaBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            final favoritesAsync = ref.watch(favoriteSongTitlesProvider);
            final isFavorite =
                favoritesAsync.valueOrNull?.contains(song.title) ?? false;
            // Noi "nong" ngay tren thanh menu duoi (44 la chieu cao icon cua
            // ca RootShell lan MiniAppBottomNav + ~30 padding/vien) - cong
            // gia tri nay de the "chen" mot phan vao vung nut, dung y "noi
            // giua cac nut" nguoi dung mo ta thay vi xep gon ben tren.
            return Positioned(
              left: 16,
              right: 16,
              bottom: 78,
              child: SafeArea(
                top: false,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PlayerScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    decoration: BoxDecoration(
                      color: const Color(0xF20F1326),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: AppColors.glassBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 30,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: song.color,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.music_note_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    song.artist,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.body(
                                      size: 13,
                                      weight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    song.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.muted(size: 11.5),
                                  ),
                                ],
                              ),
                            ),
                            _RoundIconBtn(
                              icon: Icons.open_in_full_rounded,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PlayerScreen(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            _RoundIconBtn(
                              icon: isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              iconColor: isFavorite ? AppColors.pink : null,
                              onTap: () => ref
                                  .read(favoriteSongTitlesProvider.notifier)
                                  .toggle(song.title),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        StreamBuilder<Duration>(
                          stream: service.player.positionStream,
                          initialData: service.player.position,
                          builder: (context, posSnap) {
                            final pos = posSnap.data ?? Duration.zero;
                            final dur =
                                service.player.duration ?? Duration.zero;
                            final progress = dur.inMilliseconds > 0
                                ? (pos.inMilliseconds / dur.inMilliseconds)
                                      .clamp(0.0, 1.0)
                                : 0.0;
                            final remaining = dur - pos;
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _fmt(pos),
                                      style: AppTextStyles.muted(size: 10.5),
                                    ),
                                    Text(
                                      remaining.isNegative
                                          ? '-0:00'
                                          : '-${_fmt(remaining)}',
                                      style: AppTextStyles.muted(size: 10.5),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 4,
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.12,
                                    ),
                                    valueColor: const AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _WhiteCircleBtn(
                              icon: Icons.skip_previous_rounded,
                              size: 44,
                              iconSize: 20,
                              onTap: queue.length > 1 ? service.previous : null,
                            ),
                            const SizedBox(width: 14),
                            StreamBuilder<PlayerState>(
                              stream: service.player.playerStateStream,
                              initialData: service.player.playerState,
                              builder: (context, snap) {
                                final playing = snap.data?.playing ?? false;
                                return _WhiteCircleBtn(
                                  icon: playing
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  size: 52,
                                  iconSize: 24,
                                  onTap: () => playing
                                      ? service.player.pause()
                                      : service.player.play(),
                                );
                              },
                            ),
                            const SizedBox(width: 14),
                            _WhiteCircleBtn(
                              icon: Icons.skip_next_rounded,
                              size: 44,
                              iconSize: 20,
                              onTap: queue.length > 1 ? service.next : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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

class _RoundIconBtn extends StatelessWidget {
  const _RoundIconBtn({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 14, color: iconColor ?? Colors.white),
      ),
    );
  }
}

class _WhiteCircleBtn extends StatelessWidget {
  const _WhiteCircleBtn({
    required this.icon,
    required this.onTap,
    required this.size,
    required this.iconSize,
  });
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: onTap != null
              ? Colors.white
              : Colors.white.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: iconSize, color: Colors.black),
      ),
    );
  }
}

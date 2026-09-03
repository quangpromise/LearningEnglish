import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/audio/now_playing_service.dart';
import '../../../core/theme/app_theme.dart';
import '../data/songs_data.dart';
import 'player_screen.dart';

/// Nut nhac dang phat - 1 khoi VUONG-BO-TRON GON (khong phai the ngang) NOI
/// CAO HAN HAN cac icon menu khac de KHONG de len chung, nam CHINH GIUA
/// thanh menu duoi. Xep 2 tang de giu be ngang hep: hang tren la nut mo
/// rong (collapse/expand, mo PlayerScreen dang popup), hang duoi la 3 nut
/// lui/phat-tam dung/toi bai - rieng nut phat-tam dung co them thoi gian
/// CON LAI cua bai hat ngay ben duoi (theo yeu cau). Chi hien khi co bai
/// dang phat. Dat rieng 1 file de dung CHUNG cho ca thanh menu Hoc Tieng
/// Anh (root_shell.dart) lan Fitness/Assets Management
/// (mini_app_bottom_nav.dart).
class CenterMediaButton extends StatelessWidget {
  const CenterMediaButton({super.key});

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
        if (queue.isEmpty) return const SizedBox(width: 66, height: 66);
        return Container(
          width: 72,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.bgTop, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.blue.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Btn(
                icon: Icons.unfold_more_rounded,
                size: 15,
                onTap: () => _openPlayerPopup(context),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _Btn(
                    icon: Icons.skip_previous_rounded,
                    size: 16,
                    onTap: queue.length > 1 ? service.previous : null,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StreamBuilder<PlayerState>(
                        stream: service.player.playerStateStream,
                        initialData: service.player.playerState,
                        builder: (context, snap) {
                          final playing = snap.data?.playing ?? false;
                          return _Btn(
                            icon: playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 18,
                            onTap: () => playing
                                ? service.player.pause()
                                : service.player.play(),
                          );
                        },
                      ),
                      StreamBuilder<Duration>(
                        stream: service.player.positionStream,
                        initialData: service.player.position,
                        builder: (context, posSnap) {
                          final pos = posSnap.data ?? Duration.zero;
                          final dur = service.player.duration ?? Duration.zero;
                          final remaining = dur - pos;
                          return Text(
                            remaining.isNegative
                                ? '-0:00'
                                : '-${_fmt(remaining)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  _Btn(
                    icon: Icons.skip_next_rounded,
                    size: 16,
                    onTap: queue.length > 1 ? service.next : null,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Mo PlayerScreen dang POPUP (bottom sheet gan full man hinh, boc goc tren)
/// thay vi day sang 1 man hinh rieng - theo yeu cau, giu cam giac "noi
/// tren" nhat quan voi cach CenterMediaButton cung dang hien thi.
void _openPlayerPopup(BuildContext context) {
  showModalBottomSheet(
    context: context,
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
  const _Btn({required this.icon, required this.onTap, required this.size});
  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: Icon(
          icon,
          size: size,
          color: onTap != null
              ? Colors.white
              : Colors.white.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/audio/now_playing_service.dart';
import '../../../core/theme/app_theme.dart';
import '../data/songs_data.dart';
import 'player_screen.dart';

/// Nut nhac dang phat - 1 khoi TRON GON, NOI CAO HON cac icon menu khac,
/// nam CHINH GIUA thanh menu duoi (giong y minh hoa "hexagon vi" nguoi
/// dung gui: 1 khoi noi bat nam giua Search/Statistics), NHUNG van du 4
/// tinh nang: lui bai/phat-tam dung/toi bai/mo rong (collapse) - thu nho
/// kich thuoc tung nut de vua trong 1 khoi gon thay vi the ngang day du.
/// Chi hien khi co bai dang phat. Dat rieng 1 file de dung CHUNG cho ca
/// thanh menu Hoc Tieng Anh (root_shell.dart) lan Fitness/Assets Management
/// (mini_app_bottom_nav.dart).
class CenterMediaButton extends StatelessWidget {
  const CenterMediaButton({super.key});

  @override
  Widget build(BuildContext context) {
    final service = NowPlayingService.instance;
    return StreamBuilder<List<Song>>(
      stream: service.queueStream,
      initialData: service.queue,
      builder: (context, queueSnap) {
        final queue = queueSnap.data ?? const <Song>[];
        if (queue.isEmpty) return const SizedBox(height: 56);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.bgTop, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.blue.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Btn(
                icon: Icons.skip_previous_rounded,
                size: 18,
                onTap: queue.length > 1 ? service.previous : null,
              ),
              StreamBuilder<PlayerState>(
                stream: service.player.playerStateStream,
                initialData: service.player.playerState,
                builder: (context, snap) {
                  final playing = snap.data?.playing ?? false;
                  return _Btn(
                    icon: playing
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 20,
                    onTap: () => playing
                        ? service.player.pause()
                        : service.player.play(),
                  );
                },
              ),
              _Btn(
                icon: Icons.skip_next_rounded,
                size: 18,
                onTap: queue.length > 1 ? service.next : null,
              ),
              Container(
                width: 1,
                height: 22,
                color: Colors.white.withValues(alpha: 0.35),
              ),
              _Btn(
                icon: Icons.unfold_more_rounded,
                size: 16,
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const PlayerScreen())),
              ),
            ],
          ),
        );
      },
    );
  }
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
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

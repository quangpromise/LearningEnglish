import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/music_player/data/songs_data.dart';
import '../../features/music_player/presentation/player_screen.dart';
import '../audio/now_playing_service.dart';
import '../i18n/app_strings.dart';
import '../theme/gt_tokens.dart';
import 'app_popup.dart';

/// Nguoi dung bat/tat mini player (luu tren may). Mac dinh bat.
class MiniPlayerVisibility extends StateNotifier<bool> {
  MiniPlayerVisibility() : super(true) {
    _load();
  }

  static const prefKey = 'gt_mini_player_visible';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool(prefKey);
      if (saved != null && mounted) state = saved;
    } catch (_) {}
  }

  Future<void> set(bool visible) async {
    state = visible;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefKey, visible);
    } catch (_) {}
  }
}

final miniPlayerVisibleProvider =
    StateNotifierProvider<MiniPlayerVisibility, bool>(
      (ref) => MiniPlayerVisibility(),
    );

/// Mini player kinh mo noi phia tren thanh tab (spec #70): bia 44, ten bai,
/// "Ca si · Co loi song ngu", nut phat/tam dung, vach tien trinh 2px. An khi
/// chua co bai nao trong hang doi hoac nguoi dung da tat.
class GtMiniPlayer extends ConsumerWidget {
  const GtMiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(miniPlayerVisibleProvider)) return const SizedBox.shrink();
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
            final i = indexSnap.data;
            final song = i != null && i < queue.length ? queue[i] : queue.first;
            return _Bar(song: song, player: service.player);
          },
        );
      },
    );
  }
}

class _Bar extends ConsumerWidget {
  const _Bar({required this.song, required this.player});
  final Song song;
  final AudioPlayer player;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: t.glass,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: t.bd),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: InkWell(
                  onTap: () => openAppPopup(context, const PlayerScreen()),
                  onLongPress: () => _confirmHide(context, ref),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: song.color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.music_note_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GtText.body(
                                  t.tx,
                                  weight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '${song.artist} · ${ref.tr('mini_player_bilingual')}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GtText.body(t.tx2, size: 12),
                              ),
                            ],
                          ),
                        ),
                        StreamBuilder<PlayerState>(
                          stream: player.playerStateStream,
                          initialData: player.playerState,
                          builder: (context, snap) {
                            final playing = snap.data?.playing ?? false;
                            return IconButton(
                              tooltip: ref.tr(
                                playing
                                    ? 'mini_player_pause'
                                    : 'mini_player_play',
                              ),
                              onPressed: playing ? player.pause : player.play,
                              icon: Icon(
                                playing
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 30,
                                color: t.tx,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: StreamBuilder<Duration>(
                  stream: player.positionStream,
                  builder: (context, snap) {
                    final total = player.duration?.inMilliseconds ?? 0;
                    final pos = snap.data?.inMilliseconds ?? 0;
                    return LinearProgressIndicator(
                      value: total > 0 ? (pos / total).clamp(0.0, 1.0) : 0,
                      minHeight: 2,
                      color: t.tx,
                      backgroundColor: Colors.transparent,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmHide(BuildContext context, WidgetRef ref) async {
    final hide = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      builder: (context) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.visibility_off_rounded),
          title: Text(ref.tr('mini_player_hide')),
          subtitle: Text(ref.tr('mini_player_hide_sub')),
          onTap: () => Navigator.of(context).pop(true),
        ),
      ),
    );
    if (hide == true) ref.read(miniPlayerVisibleProvider.notifier).set(false);
  }
}

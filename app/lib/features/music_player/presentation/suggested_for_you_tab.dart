import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/now_playing_service.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/songs_data.dart';

/// Tab "Goi y cho ban" trong PlayerScreen - danh sach cac bai khac (uu tien
/// cung trinh do voi bai dang phat) de nghe tiep, bam vao 1 bai se doi luon
/// hang doi + phat ngay (dung chung NowPlayingService voi tab "Dang phat",
/// nen tab do tu dong cap nhat theo vi PlayerScreen da lang nghe
/// currentIndexStream san).
class SuggestedForYouTab extends ConsumerWidget {
  const SuggestedForYouTab({super.key, required this.currentSong});
  final Song currentSong;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final others = kSongs.where((s) => s.title != currentSong.title).toList();
    final sameLevel = others
        .where((s) => s.level == currentSong.level)
        .toList();
    final rest = others.where((s) => s.level != currentSong.level).toList();
    final suggestions = [...sameLevel, ...rest];

    if (suggestions.isEmpty) {
      return Center(
        child: Text(
          ref.tr('player_suggested_empty'),
          style: AppTextStyles.muted(),
        ),
      );
    }

    return ListView.separated(
      itemCount: suggestions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final song = suggestions[i];
        final index = kSongs.indexWhere((s) => s.title == song.title);
        return GestureDetector(
          onTap: () =>
              NowPlayingService.instance.setQueueAndPlay(kSongs, index),
          child: GlowBox(
            borderRadius: 18,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: song.color,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.music_note_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body(weight: FontWeight.w800),
                      ),
                      Text(
                        '${song.artist} · ${song.level}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.muted(size: 11.5),
                      ),
                    ],
                  ),
                ),
                Text(song.duration, style: AppTextStyles.muted(size: 11.5)),
                const SizedBox(width: 8),
                const Icon(
                  Icons.play_circle_fill_rounded,
                  color: AppColors.blue,
                  size: 28,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/now_playing_service.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/songs_data.dart';

const _kLevelOrder = ['Cơ bản', 'Trung cấp', 'Nâng cao'];

Color _levelColor(String level) => switch (level) {
  'Cơ bản' => AppColors.teal,
  'Trung cấp' => AppColors.amber,
  _ => AppColors.pink,
};

String _levelLabel(WidgetRef ref, String level) => switch (level) {
  'Cơ bản' => ref.tr('song_level_basic'),
  'Trung cấp' => ref.tr('song_level_intermediate'),
  'Nâng cao' => ref.tr('song_level_advanced'),
  _ => level,
};

/// Tab "Goi y cho ban" trong PlayerScreen - gom toan bo tinh nang duyet
/// nhac (tim kiem, loc theo trinh do, chi xem yeu thich) TRUOC DAY nam o
/// man "Nghe nhac" rieng tren Home (da bo tile do khoi Home theo yeu cau -
/// duyet nhac gio la 1 phan cua trai nghiem "dang phat", khong con la 1 loi
/// vao rieng). Bam vao 1 bai se DOI LUON hang doi + phat ngay (dung chung
/// NowPlayingService voi tab "Dang phat" ben canh, tu dong dong bo).
class SuggestedForYouTab extends ConsumerStatefulWidget {
  const SuggestedForYouTab({super.key, required this.currentSong});
  final Song currentSong;

  @override
  ConsumerState<SuggestedForYouTab> createState() => _SuggestedForYouTabState();
}

class _SuggestedForYouTabState extends ConsumerState<SuggestedForYouTab> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _favoritesOnly = false;
  String? _levelFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favoriteTitles =
        ref.watch(favoriteSongTitlesProvider).valueOrNull ?? <String>{};
    final query = _query.trim().toLowerCase();

    var songs = kSongs
        .where((s) => s.title != widget.currentSong.title)
        .toList();
    if (_levelFilter != null) {
      songs = songs.where((s) => s.level == _levelFilter).toList();
    }
    if (_favoritesOnly) {
      songs = songs.where((s) => favoriteTitles.contains(s.title)).toList();
    }
    if (query.isNotEmpty) {
      songs = songs
          .where(
            (s) =>
                s.title.toLowerCase().contains(query) ||
                s.artist.toLowerCase().contains(query),
          )
          .toList();
    } else {
      // Mac dinh: uu tien bai CUNG trinh do voi bai dang phat len truoc.
      songs.sort((a, b) {
        final aSame = a.level == widget.currentSong.level ? 0 : 1;
        final bSame = b.level == widget.currentSong.level ? 0 : 1;
        return aSame.compareTo(bSame);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlowBox(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          borderRadius: 999,
          child: Row(
            children: [
              const Icon(Icons.search, size: 18, color: AppColors.textMuted),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  style: AppTextStyles.body(),
                  cursorColor: AppColors.purple,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: ref.tr('home_search_hint'),
                    hintStyle: AppTextStyles.muted(),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _favoritesOnly = !_favoritesOnly),
                child: Icon(
                  _favoritesOnly
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 18,
                  color: _favoritesOnly ? AppColors.pink : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 32,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _LevelChip(
                label: ref.tr('wealth_filter_all'),
                selected: _levelFilter == null,
                color: AppColors.blue,
                onTap: () => setState(() => _levelFilter = null),
              ),
              for (final level in _kLevelOrder)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _LevelChip(
                    label: _levelLabel(ref, level),
                    selected: _levelFilter == level,
                    color: _levelColor(level),
                    onTap: () => setState(() => _levelFilter = level),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: songs.isEmpty
              ? Center(
                  child: Text(
                    ref.tr('player_suggested_empty'),
                    style: AppTextStyles.muted(),
                  ),
                )
              : ListView.separated(
                  itemCount: songs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final song = songs[i];
                    return GestureDetector(
                      onTap: () => NowPlayingService.instance.setQueueAndPlay(
                        kSongs,
                        kSongs.indexWhere((s) => s.title == song.title),
                      ),
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
                                    style: AppTextStyles.body(
                                      weight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    '${song.artist} · ${song.duration}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.muted(size: 11.5),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => ref
                                  .read(favoriteSongTitlesProvider.notifier)
                                  .toggle(song.title),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                child: Icon(
                                  favoriteTitles.contains(song.title)
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  size: 16,
                                  color: favoriteTitles.contains(song.title)
                                      ? AppColors.pink
                                      : AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.22) : AppColors.glassFill,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? color : AppColors.glassBorder),
        ),
        child: Text(
          label,
          style: AppTextStyles.body(
            size: 12,
            weight: FontWeight.w700,
            color: selected ? color : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

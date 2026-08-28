import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../social/presentation/friends_screen.dart';
import '../data/songs_data.dart';
import 'player_screen.dart';

String _levelLabel(WidgetRef ref, String level) => switch (level) {
  'Cơ bản' => ref.tr('song_level_basic'),
  'Trung cấp' => ref.tr('song_level_intermediate'),
  'Nâng cao' => ref.tr('song_level_advanced'),
  _ => level,
};

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _favoritesOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openQueue(List<Song> queue, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerScreen(queue: queue, startIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final favoritesAsync = ref.watch(favoriteSongTitlesProvider);
    final favoriteTitles = favoritesAsync.valueOrNull ?? <String>{};
    var filteredSongs = query.isEmpty
        ? kSongs
        : kSongs
              .where(
                (s) =>
                    s.title.toLowerCase().contains(query) ||
                    s.artist.toLowerCase().contains(query),
              )
              .toList();
    if (_favoritesOnly) {
      filteredSongs = filteredSongs
          .where((s) => favoriteTitles.contains(s.title))
          .toList();
    }
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ref.tr('home_greeting'), style: AppTextStyles.muted()),
                    Text('Quang', style: AppTextStyles.heading(size: 20)),
                  ],
                ),
                Row(
                  children: [
                    const _MessagesButton(),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _favoritesOnly = !_favoritesOnly),
                      child: _IconCircle(
                        icon: _favoritesOnly
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        iconColor: _favoritesOnly ? AppColors.pink : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            GlowBox(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              borderRadius: 999,
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
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
                  if (query.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (query.isEmpty && !_favoritesOnly)
              GlowBox(
                light: true,
                borderRadius: 26,
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(18),
                      ),
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
                            ref.tr('home_try_listening'),
                            style: TextStyle(
                              color: AppColors.purple,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                              letterSpacing: 0.6,
                            ),
                          ),
                          Text(
                            kSongs.first.title,
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: 0.87),
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '${kSongs.first.artist} · ${kSongs.first.duration}',
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openQueue(kSongs, 0),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: AppColors.accentGradient,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (query.isEmpty && !_favoritesOnly) const SizedBox(height: 22),
            Text(
              _favoritesOnly
                  ? ref.tr('home_favorites_title')
                  : (query.isEmpty
                        ? ref.tr('home_suggested_for_you')
                        : ref.tr('home_search_results')),
              style: AppTextStyles.heading(size: 16),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filteredSongs.isEmpty
                  ? Center(
                      child: Text(
                        _favoritesOnly
                            ? ref.tr('home_no_favorites')
                            : ref.tr('home_no_results'),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.muted(),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredSongs.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final song = filteredSongs[i];
                        final isFavorite = favoriteTitles.contains(song.title);
                        return GestureDetector(
                          onTap: () => _openQueue(filteredSongs, i),
                          child: GlowBox(
                            padding: const EdgeInsets.all(12),
                            borderRadius: 20,
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: song.color.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.music_note_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        song.title,
                                        style: AppTextStyles.body(
                                          weight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        '${song.artist} · ${song.duration}',
                                        style: AppTextStyles.muted(),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final repo = ref.read(
                                      favoritesRepositoryProvider,
                                    );
                                    if (isFavorite) {
                                      await repo.removeFavorite(song.title);
                                    } else {
                                      await repo.addFavorite(song.title);
                                    }
                                    ref.invalidate(favoriteSongTitlesProvider);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    child: Icon(
                                      isFavorite
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      size: 18,
                                      color: isFavorite
                                          ? AppColors.pink
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        (song.level == 'Cơ bản'
                                                ? AppColors.teal
                                                : AppColors.amber)
                                            .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    _levelLabel(ref, song.level),
                                    style: TextStyle(
                                      color: song.level == 'Cơ bản'
                                          ? AppColors.teal
                                          : AppColors.amber,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
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
        ),
      ),
    );
  }
}

/// Nút tin nhắn kiểu Facebook: chấm đỏ (kèm số nếu <10) nổi ở góc khi có
/// tin nhắn chưa đọc, tự cập nhật realtime qua [unreadMessageCountProvider].
class _MessagesButton extends ConsumerWidget {
  const _MessagesButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadMessageCountProvider).valueOrNull ?? 0;
    return GestureDetector(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const FriendsScreen())),
      child: Tooltip(
        message: ref.tr('home_messages_tooltip'),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const _IconCircle(icon: Icons.chat_bubble_rounded),
            if (unread > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.pink,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.bgTop, width: 2),
                  ),
                  child: Text(
                    unread > 9 ? '9+' : '$unread',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.icon, this.iconColor});
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Icon(icon, size: 18, color: iconColor ?? AppColors.textPrimary),
    );
  }
}

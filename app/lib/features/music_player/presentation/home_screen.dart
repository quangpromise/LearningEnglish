import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/songs_data.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final filteredSongs = query.isEmpty
        ? kSongs
        : kSongs
              .where(
                (s) =>
                    s.title.toLowerCase().contains(query) ||
                    s.artist.toLowerCase().contains(query),
              )
              .toList();
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
                    Text('Xin chào', style: AppTextStyles.muted()),
                    Text('Quang', style: AppTextStyles.heading(size: 20)),
                  ],
                ),
                const _IconCircle(icon: Icons.notifications_none_rounded),
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
                        hintText: 'Tìm bài hát, ca sĩ...',
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
            if (query.isEmpty)
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
                            'GỢI Ý NGHE THỬ',
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
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PlayerScreen(song: kSongs.first),
                        ),
                      ),
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
            if (query.isEmpty) const SizedBox(height: 22),
            Text(
              query.isEmpty ? 'Gợi ý cho bạn' : 'Kết quả tìm kiếm',
              style: AppTextStyles.heading(size: 16),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filteredSongs.isEmpty
                  ? Center(
                      child: Text(
                        'Không tìm thấy bài hát nào',
                        style: AppTextStyles.muted(),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredSongs.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final song = filteredSongs[i];
                        return GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PlayerScreen(song: song),
                            ),
                          ),
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
                                    song.level,
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

class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.icon});
  final IconData icon;

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
      child: Icon(icon, size: 18, color: AppColors.textPrimary),
    );
  }
}

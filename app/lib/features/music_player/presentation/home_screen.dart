import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'player_screen.dart';

class Song {
  const Song({required this.title, required this.artist, required this.duration, required this.level, required this.color});
  final String title;
  final String artist;
  final String duration;
  final String level;
  final Color color;
}

const kSongs = [
  Song(title: 'Golden Hour', artist: 'Mara Lane', duration: '3:42', level: 'Cơ bản', color: AppColors.blue),
  Song(title: 'Paper Boats', artist: 'The Wandering Few', duration: '4:05', level: 'Trung cấp', color: AppColors.purple),
  Song(title: 'City Lights', artist: 'Noah Rivers', duration: '3:20', level: 'Cơ bản', color: AppColors.teal),
  Song(title: 'Sunny Afternoon', artist: 'Clara Voss', duration: '3:42', level: 'Cơ bản', color: AppColors.pink),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              borderRadius: 999,
              child: Row(
                children: [
                  const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                  const SizedBox(width: 10),
                  Text('Tìm bài hát, ca sĩ...', style: AppTextStyles.muted()),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GlowBox(
              light: true,
              borderRadius: 26,
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(gradient: AppColors.accentGradient, borderRadius: BorderRadius.circular(18)),
                    child: const Icon(Icons.music_note_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ĐANG HỌC DỞ', style: TextStyle(color: AppColors.purple, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.6)),
                        Text('Sunny Afternoon', style: TextStyle(color: Colors.black.withValues(alpha: 0.87), fontWeight: FontWeight.w800, fontSize: 15)),
                        Text('Clara Voss · Câu 14/22', style: TextStyle(color: Colors.black.withValues(alpha: 0.5), fontWeight: FontWeight.w600, fontSize: 12)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlayerScreen(song: Song(title: 'Sunny Afternoon', artist: 'Clara Voss', duration: '3:42', level: 'Cơ bản', color: AppColors.pink)))),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(gradient: AppColors.accentGradient, borderRadius: BorderRadius.circular(999)),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text('Gợi ý cho bạn', style: AppTextStyles.heading(size: 16)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: kSongs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final song = kSongs[i];
                  return GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlayerScreen(song: song))),
                    child: GlowBox(
                      padding: const EdgeInsets.all(12),
                      borderRadius: 20,
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(color: song.color.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(14)),
                            child: const Icon(Icons.music_note_rounded, color: Colors.white),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(song.title, style: AppTextStyles.body(weight: FontWeight.w800)),
                                Text('${song.artist} · ${song.duration}', style: AppTextStyles.muted()),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (song.level == 'Cơ bản' ? AppColors.teal : AppColors.amber).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              song.level,
                              style: TextStyle(color: song.level == 'Cơ bản' ? AppColors.teal : AppColors.amber, fontWeight: FontWeight.w800, fontSize: 10),
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
      decoration: BoxDecoration(color: AppColors.glassFill, shape: BoxShape.circle, border: Border.all(color: AppColors.glassBorder)),
      child: Icon(icon, size: 18, color: AppColors.textPrimary),
    );
  }
}

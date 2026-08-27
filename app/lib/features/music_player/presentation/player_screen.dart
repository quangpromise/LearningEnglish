import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../grammar/presentation/grammar_screen.dart';
import '../../translation/presentation/word_popup_sheet.dart';
import 'home_screen.dart';

class LyricLine {
  const LyricLine(this.en, this.vi);
  final String en;
  final String vi;
}

const kLyrics = [
  LyricLine("I used to run from every storm", "Tôi từng trốn chạy khỏi mọi cơn giông"),
  LyricLine("Now I'm standing in the rain", "Giờ tôi đứng lặng giữa cơn mưa"),
  LyricLine("Learning how to feel the warmth", "Học cách cảm nhận hơi ấm"),
];

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.song});
  final Song song;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  int _currentLine = 1;
  bool _playing = false;
  bool _bilingual = true;

  void _onWordTap(String word) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => WordPopupSheet(
        word: word,
        sentenceEn: kLyrics[_currentLine].en,
        sentenceVi: kLyrics[_currentLine].vi,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CircleBtn(icon: Icons.chevron_left_rounded, onTap: () => Navigator.of(context).pop()),
                Text('ĐANG PHÁT', style: AppTextStyles.muted(size: 11).copyWith(letterSpacing: 1)),
                _CircleBtn(
                  icon: Icons.menu_book_rounded,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GrammarScreen(sentence: kLyrics[_currentLine]))),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: AppColors.purple.withValues(alpha: 0.4), blurRadius: 60, offset: const Offset(0, 24))],
              ),
              child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 56),
            ),
            const SizedBox(height: 16),
            Text(widget.song.title, style: AppTextStyles.heading(size: 19)),
            Text(widget.song.artist, style: AppTextStyles.muted()),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: kLyrics.length,
                itemBuilder: (context, i) {
                  final line = kLyrics[i];
                  final isCurrent = i == _currentLine;
                  return GestureDetector(
                    onTap: () => setState(() => _currentLine = i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Opacity(
                        opacity: isCurrent ? 1 : 0.3,
                        child: Column(
                          children: [
                            Wrap(
                              alignment: WrapAlignment.center,
                              children: line.en.split(' ').map((w) {
                                return GestureDetector(
                                  onTap: isCurrent ? () => _onWordTap(w.replaceAll(RegExp('[^a-zA-Z]'), '')) : null,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    child: isCurrent
                                        ? ShaderMask(
                                            shaderCallback: (rect) => AppColors.accentGradient.createShader(rect),
                                            child: Text(w, style: AppTextStyles.heading(size: 21)),
                                          )
                                        : Text(w, style: AppTextStyles.heading(size: 15)),
                                  ),
                                );
                              }).toList(),
                            ),
                            if (_bilingual)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(line.vi, style: AppTextStyles.muted(size: isCurrent ? 13 : 12)),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Song ngữ Anh – Việt', style: AppTextStyles.muted()),
                const SizedBox(width: 10),
                Switch(value: _bilingual, activeTrackColor: AppColors.purple, onChanged: (v) => setState(() => _bilingual = v)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.skip_previous_rounded, color: AppColors.textPrimary, size: 28)),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => setState(() => _playing = !_playing),
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppColors.blue.withValues(alpha: 0.5), blurRadius: 40, offset: const Offset(0, 16))],
                    ),
                    child: Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 30),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(onPressed: () {}, icon: const Icon(Icons.skip_next_rounded, color: AppColors.textPrimary, size: 28)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: AppColors.glassFill, shape: BoxShape.circle, border: Border.all(color: AppColors.glassBorder)),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

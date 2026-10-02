import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/music_player/data/songs_data.dart';
import 'package:learn_english_music/features/music_player/presentation/karaoke_lyrics.dart';

final _lines = buildKaraokeLines(const [
  LyricLine(0, 'Cold hands sore feet', 'Tay lạnh chân đau'),
  LyricLine(4, 'Walking on abandoned streets', 'Đi trên phố vắng'),
  LyricLine(8, 'Hold on tight', 'Giữ thật chặt'),
  LyricLine(12, 'Never let go', 'Đừng buông tay'),
  LyricLine(16, 'The end', 'Hết'),
]);

Future<void> _pump(WidgetTester tester, {required bool reduce}) async {
  final position = ValueNotifier<double>(4.3);
  addTearDown(position.dispose);
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
          child: Scaffold(
            body: KaraokeLyricsView(
              lines: _lines,
              // Dang hat dong 2, giua tu dau tien.
              activeIndex: 1,
              positionSeconds: position,
              lineKeys: [for (final _ in _lines) GlobalKey()],
              bilingual: true,
              onSeekToLine: (_) {},
              onWordTap: (_) {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _inLyrics(Type type) => find.descendant(
  of: find.byType(KaraokeLyricsView),
  matching: find.byType(type),
);

bool _anyBlur(WidgetTester tester) =>
    _inLyrics(ImageFiltered).evaluate().isNotEmpty;

bool _anyGlow(WidgetTester tester) => tester
    .widgetList<Text>(_inLyrics(Text))
    .any((t) => t.style?.shadows?.isNotEmpty ?? false);

bool _anyMoved(WidgetTester tester) => tester
    .widgetList<Transform>(_inLyrics(Transform))
    .any((t) => t.transform != Matrix4.identity());

void main() {
  testWidgets('normal motion: lines zoom and blur, words lift and glow', (
    tester,
  ) async {
    await _pump(tester, reduce: false);
    expect(_anyBlur(tester), isTrue);
    expect(_anyGlow(tester), isTrue);
    expect(_anyMoved(tester), isTrue);
  });

  testWidgets('reduced motion: no zoom, blur, lift or glow; colour sweep '
      'stays', (tester) async {
    await _pump(tester, reduce: true);
    expect(_anyBlur(tester), isFalse);
    expect(_anyGlow(tester), isFalse);
    expect(_anyMoved(tester), isFalse);
    for (final s in tester.widgetList<AnimatedScale>(
      _inLyrics(AnimatedScale),
    )) {
      expect(s.scale, 1);
    }
    // Tu dang hat van duoc to dan theo vi tri nhac.
    expect(_inLyrics(ShaderMask), findsWidgets);
  });
}

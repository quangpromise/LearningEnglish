import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/english_path/data/content_pack.dart';
import 'package:learn_english_music/features/english_path/data/rest_game.dart';
import 'package:learn_english_music/features/english_path/presentation/rest_game_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

PracticeItem _meaning(String word, String right) => PracticeItem(
  id: 'u-$word',
  unitId: 'u',
  type: PracticeItemType.meaning,
  prompt: word,
  options: [right, 'sai 1', 'sai 2', 'sai 3'],
  answerIndex: 0,
  sourceIds: const ['cefrj'],
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Rest Game card: answer, feedback, next item, done', (
    tester,
  ) async {
    final session = RestGameSession([
      _meaning('jump', 'nhảy'),
      _meaning('lift', 'nâng'),
    ]);
    final answered = <(String, bool)>[];
    var usedCards = false;
    var toggledListening = false;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RestGameCard(
                session: session,
                words: const {},
                onAnswered: (item, correct) => answered.add((item.id, correct)),
                onUseCards: () => usedCards = true,
                listeningEnabled: true,
                onToggleListening: () => toggledListening = true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('jump'), findsOneWidget);
    expect(find.text('0/2'), findsOneWidget);
    await tester.tap(find.text('nhảy'));
    await tester.pump();
    expect(answered, [('u-jump', true)]);
    // Van hien cau vua tra loi trong luc cho sang cau sau.
    expect(find.text('jump'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.text('lift'), findsOneWidget);
    await tester.tap(find.text('sai 2'));
    await tester.pump(const Duration(milliseconds: 1200));
    expect(answered.last, ('u-lift', false));
    expect(find.text('2/2'), findsOneWidget);
    expect(find.textContaining('1/2'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.style_rounded));
    expect(usedCards, isTrue);
    await tester.tap(find.byIcon(Icons.headphones_rounded));
    expect(toggledListening, isTrue);
  });
}

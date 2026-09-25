import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/english_path/data/cefr_level.dart';
import 'package:learn_english_music/features/english_path/data/content_pack.dart';
import 'package:learn_english_music/features/english_path/data/english_path_state.dart';
import 'package:learn_english_music/features/english_path/data/rest_game.dart';

List<PracticeItem> _items(String prefix, {int each = 12}) => [
  for (final type in PracticeItemType.values)
    for (var i = 0; i < each; i++)
      PracticeItem(
        id: '$prefix-${type.name}-$i',
        unitId: prefix,
        type: type,
        prompt: 'w$i',
        options: type == PracticeItemType.wordScramble
            ? ['w$i']
            : const ['right', 'x', 'y', 'z'],
        answerIndex: 0,
        sourceIds: const ['cefrj'],
      ),
];

List<PracticeItem> _plan(
  int seconds, {
  List<PracticeItem>? unit,
  List<PracticeItem>? review,
  bool listening = true,
}) => planRestGame(
  restSeconds: seconds,
  unitItems: unit ?? _items('unit'),
  reviewItems: review ?? _items('review'),
  listeningEnabled: listening,
  random: Random(7),
);

void main() {
  group('planRestGame', () {
    test('short rest (< 45 s): only Meaning or Scramble, at most 2 items', () {
      for (final s in [30, 44]) {
        final plan = _plan(s);
        expect(plan.length, inInclusiveRange(1, 2), reason: '$s s');
        expect(
          plan.map((i) => i.type).toSet().difference(kQuickRestFormats),
          isEmpty,
        );
      }
    });

    test('long rest (>= 45 s) rotates every available format', () {
      final plan = _plan(120);
      expect(plan.map((i) => i.type).toSet(), kRestGameFormats);
      // Khong 2 cau lien tiep cung dang khi con dang khac.
      for (var i = 1; i < plan.length; i++) {
        expect(plan[i].type, isNot(plan[i - 1].type));
      }
    });

    test('fits the rest time budget', () {
      for (final s in [45, 60, 90, 120]) {
        final plan = _plan(s);
        final seconds = plan.fold<int>(
          0,
          (sum, i) => sum + kRestFormatSeconds[i.type]!,
        );
        expect(seconds, lessThanOrEqualTo(s), reason: '$s s');
        expect(plan, isNotEmpty);
      }
    });

    test('about 70% current unit and 30% review', () {
      final plan = _plan(120);
      final review = plan.where((i) => i.unitId == 'review').length;
      expect(plan.length, greaterThanOrEqualTo(8));
      expect(review, (plan.length * 0.3).round());
    });

    test('all from the unit when there is nothing to review', () {
      final plan = _plan(90, review: const []);
      expect(plan.every((i) => i.unitId == 'unit'), isTrue);
    });

    test('never picks Listening when it is turned off', () {
      final plan = _plan(120, listening: false);
      expect(
        plan.map((i) => i.type),
        isNot(contains(PracticeItemType.listening)),
      );
    });

    test('uses what the pack has (tracer pack: Meaning only)', () {
      final meaningOnly = _items('unit')
          .where((i) => i.type == PracticeItemType.meaning)
          .toList();
      final plan = _plan(90, unit: meaningOnly, review: const []);
      expect(plan, isNotEmpty);
      expect(plan.every((i) => i.type == PracticeItemType.meaning), isTrue);
    });

    test('empty when there is nothing to play', () {
      expect(_plan(90, unit: const [], review: const []), isEmpty);
    });

    test('Listening never opens a session', () {
      for (var seed = 0; seed < 20; seed++) {
        final plan = planRestGame(
          restSeconds: 120,
          unitItems: _items('unit'),
          reviewItems: _items('review'),
          listeningEnabled: true,
          random: Random(seed),
        );
        expect(plan.first.type, isNot(PracticeItemType.listening));
      }
    });

    test('skips items already played in this rest', () {
      final first = _plan(60);
      final again = planRestGame(
        restSeconds: 60,
        unitItems: _items('unit'),
        reviewItems: _items('review'),
        listeningEnabled: false,
        random: Random(7),
        exclude: {for (final i in first) i.id},
      );
      expect(
        again.map((i) => i.id).toSet().intersection({
          for (final i in first) i.id,
        }),
        isEmpty,
      );
    });

    test('never repeats an item', () {
      final plan = _plan(120);
      expect(plan.map((i) => i.id).toSet().length, plan.length);
    });
  });

  group('restGameSources', () {
    PracticeItem item(String id, String unit, String word) => PracticeItem(
      id: id,
      unitId: unit,
      type: PracticeItemType.meaning,
      prompt: word,
      options: const ['a', 'b'],
      answerIndex: 0,
      sourceIds: const ['cefrj'],
      wordEn: word,
    );
    PathUnit unit(String id, int index, List<PracticeItem> items) => PathUnit(
      id: id,
      index: index,
      titleEn: id,
      titleVi: id,
      words: const [],
      items: items,
    );
    final pack = ContentPack(
      schemaVersion: 1,
      packVersion: 'pv',
      contentHash: 'h',
      approval: null,
      sources: const [],
      stages: [
        PathStage(
          stage: CefrLevel.a1,
          units: [
            unit('u1', 1, [
              item('u1-a', 'u1', 'run'),
              item('u1-b', 'u1', 'jump'),
            ]),
            unit('u2', 2, [item('u2-a', 'u2', 'lift')]),
          ],
        ),
        PathStage(
          stage: CefrLevel.a2,
          units: [
            unit('v1', 1, [item('v1-a', 'v1', 'squat')]),
          ],
        ),
      ],
    );

    test('current unit is the next unit of the English Level', () {
      final src = restGameSources(pack, CefrLevel.a1, const EnglishPathState());
      expect(src.unit.map((i) => i.id), ['u1-a', 'u1-b']);
      expect(src.review, isEmpty);
    });

    test('review = previously wrong items + SRS-due words of the stage', () {
      final state = const EnglishPathState().recordWrong('v1-a');
      final src = restGameSources(
        pack,
        CefrLevel.a1,
        state,
        dueWords: {'lift', 'squat'},
      );
      expect(src.review.map((i) => i.id).toSet(), {'v1-a', 'u2-a'});
    });

    test('falls back to the last unit when the stage is finished', () {
      var s = const EnglishPathState();
      for (final id in ['u1-a', 'u1-b']) {
        s = s.recordCorrect('u1', id);
      }
      s = s.recordCorrect('u2', 'u2-a');
      final src = restGameSources(pack, CefrLevel.a1, s);
      expect(src.unit.map((i) => i.id), ['u2-a']);
    });
  });

  group('RestGameSession', () {
    test('records answers and closes with only what was answered', () {
      final session = RestGameSession(_plan(120));
      expect(session.answer(0), isTrue);
      expect(session.answer(1), isFalse);
      final results = session.close();
      expect(results.map((r) => r.correct), [true, false]);
      expect(session.isClosed, isTrue);
      expect(session.current, isNull);
    });

    test('ignores answers after the rest ended', () {
      final session = RestGameSession(_plan(120))..close();
      expect(session.answer(0), isFalse);
      expect(session.close(), isEmpty);
    });

    test('is done after the last planned item', () {
      final plan = _plan(30);
      final session = RestGameSession(plan);
      for (final _ in plan) {
        session.answer(0);
      }
      expect(session.isDone, isTrue);
      expect(session.current, isNull);
    });
  });
}

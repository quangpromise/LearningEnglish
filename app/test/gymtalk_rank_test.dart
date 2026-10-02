import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/english_path/data/cefr_level.dart';
import 'package:learn_english_music/features/fitness/data/body_level.dart';
import 'package:learn_english_music/features/today/data/gymtalk_rank.dart';

void main() {
  test('rank is the lower of Body Level and English Level', () {
    final r = gymTalkRank(BodyLevel.pro, CefrLevel.a2);
    expect(r.tier, 1);
    expect(r.limitedBy, RankSide.english);

    final b = gymTalkRank(BodyLevel.rookie, CefrLevel.c1);
    expect(b.tier, 0);
    expect(b.limitedBy, RankSide.body);
  });

  test('balanced when both ladders are on the same rung', () {
    final r = gymTalkRank(BodyLevel.athlete, CefrLevel.b1);
    expect(r.tier, 2);
    expect(r.limitedBy, RankSide.balanced);
  });

  test('ladders pair rung by rung: Rookie-A1 ... Beast-C1', () {
    for (var i = 0; i < BodyLevel.values.length; i++) {
      final r = gymTalkRank(BodyLevel.values[i], CefrLevel.values[i]);
      expect(r.tier, i);
    }
    expect(BodyLevel.values.length, CefrLevel.values.length);
  });

  group('rank rise from a new English Level (#121)', () {
    test(
      'passing a Level Test that lifts the lower ladder raises the rank',
      () {
        expect(
          rankRiseFromEnglish(BodyLevel.athlete, CefrLevel.a2, CefrLevel.b1),
          (from: 1, to: 2),
        );
      },
    );

    test('no rise when Body Level is the lower ladder', () {
      expect(
        rankRiseFromEnglish(BodyLevel.regular, CefrLevel.a2, CefrLevel.b1),
        isNull,
      );
    });

    test('no rise without a known Body Level or a level change', () {
      expect(rankRiseFromEnglish(null, CefrLevel.a2, CefrLevel.b1), isNull);
      expect(
        rankRiseFromEnglish(BodyLevel.beast, CefrLevel.c1, CefrLevel.c1),
        isNull,
      );
    });
  });
}

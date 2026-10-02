import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/theme/gt_tokens.dart';
import 'package:learn_english_music/core/widgets/gt_celebration.dart';
import 'package:learn_english_music/features/english_path/data/cefr_level.dart';
import 'package:learn_english_music/features/fitness/data/body_level.dart';
import 'package:learn_english_music/features/today/data/milestone_store.dart';
import 'package:learn_english_music/features/today/data/milestones.dart';
import 'package:learn_english_music/features/today/presentation/milestone_watcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _delay = Duration(milliseconds: 900);
const _today = '2026-10-02';
const _before = '2026-09-01';
const _known = MilestoneRecord(
  streak: 0,
  streakOn: _before,
  bodyLevel: 0,
  rank: 0,
);

MilestoneInputs _inputs({
  int? streak,
  BodyLevel? body,
  CefrLevel? english = CefrLevel.a1,
  String? syncedOn = _today,
}) => (streak: streak, syncedOn: syncedOn, body: body, english: english);

Widget _watcher({
  String? userId = 'u1',
  required int visit,
  bool onScreen = true,
  required MilestoneInputs inputs,
}) => ProviderScope(
  child: MaterialApp(
    theme: ThemeData(extensions: const [GtTokens.dark]),
    home: Scaffold(
      body: GtMilestoneWatcher(
        userId: userId,
        visit: visit,
        onScreen: onScreen,
        inputs: inputs,
        delay: _delay,
        clock: () => DateTime(2026, 10, 2, 9),
      ),
    ),
  ),
);

/// Cho het [_delay] + doc/ghi ban ghi + dialog vao.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump(_delay + const Duration(milliseconds: 50));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

/// Mo watcher (visit 0) roi "quay lai Hom nay" (visit 1) voi so lieu moi.
Future<void> _arrive(
  WidgetTester tester,
  MilestoneInputs inputs, {
  String? userId = 'u1',
}) async {
  await tester.pumpWidget(
    _watcher(userId: userId, visit: 0, inputs: _inputs()),
  );
  await tester.pumpWidget(_watcher(userId: userId, visit: 1, inputs: inputs));
  await _settle(tester);
}

/// Dong Celebration dang hien; man sau (neu co) vao sau 220 ms.
Future<void> _close(WidgetTester tester) async {
  await tester.tap(find.text('Tuyệt vời'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump();
}

String _title(WidgetTester tester) =>
    tester.widget<GtCelebration>(find.byType(GtCelebration)).title;

/// Dong lan luot moi Celebration, tra ve tieu de theo thu tu hien.
Future<List<String>> _showAll(WidgetTester tester) async {
  final titles = <String>[];
  while (find.byType(GtCelebration).evaluate().isNotEmpty &&
      titles.length < 6) {
    expect(find.byType(GtCelebration), findsOneWidget);
    titles.add(_title(tester));
    await _close(tester);
  }
  return titles;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('the record is kept per account', () async {
    await MilestoneStore.save('a', const MilestoneRecord(streak: 30));
    expect(await MilestoneStore.load('a'), const MilestoneRecord(streak: 30));
    expect(await MilestoneStore.load('b'), const MilestoneRecord());
  });

  testWidgets('first time on this device: baseline only, no Celebration', (
    tester,
  ) async {
    await _arrive(tester, _inputs(streak: 12, body: BodyLevel.regular));
    expect(find.byType(GtCelebration), findsNothing);
    expect(
      await MilestoneStore.load('u1'),
      const MilestoneRecord(streak: 7, streakOn: _today, bodyLevel: 1, rank: 0),
    );
  });

  testWidgets('a 7-day streak: Celebration with a tick, no XP', (tester) async {
    await MilestoneStore.save('u1', _known);
    await _arrive(tester, _inputs(streak: 7, body: BodyLevel.rookie));
    expect(find.byType(GtCelebration), findsOneWidget);
    expect(find.text('Chuỗi 7 ngày!'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.textContaining('XP'), findsNothing);
    await _close(tester);
    expect(find.byType(GtCelebration), findsNothing);
  });

  testWidgets('several milestones are shown one after another', (tester) async {
    await MilestoneStore.save('u1', _known);
    await _arrive(
      tester,
      _inputs(streak: 35, body: BodyLevel.regular, english: CefrLevel.a2),
    );
    expect(_title(tester), 'Chuỗi 30 ngày!');
    expect(find.byType(GtRankUpCard), findsNothing);
    await _close(tester);
    // Len Body Level keo Rank len: 1 man, the Rank gop vao (#121).
    expect(_title(tester), 'Lên Body Level!');
    expect(find.byType(GtRankUpCard), findsOneWidget);
    await _close(tester);
    expect(find.byType(GtCelebration), findsNothing);
    expect(
      await MilestoneStore.load('u1'),
      const MilestoneRecord(
        streak: 30,
        streakOn: _today,
        bodyLevel: 1,
        rank: 1,
      ),
    );
  });

  testWidgets('a rank-up on its own still gets its own Celebration', (
    tester,
  ) async {
    await MilestoneStore.save(
      'u1',
      const MilestoneRecord(
        streak: 0,
        streakOn: _before,
        bodyLevel: 1,
        rank: 0,
      ),
    );
    // English Level len (vd sau Placement), Body Level giu nguyen.
    await _arrive(
      tester,
      _inputs(body: BodyLevel.regular, english: CefrLevel.a2),
    );
    expect(await _showAll(tester), ['Lên GymTalk Rank!']);
  });

  testWidgets('a batch cut short is finished by the next watcher', (
    tester,
  ) async {
    await MilestoneStore.save('u1', _known);
    final inputs = _inputs(
      streak: 35,
      body: BodyLevel.regular,
      english: CefrLevel.a2,
    );
    await _arrive(tester, inputs);
    expect(_title(tester), 'Chuỗi 30 ngày!');
    // Dang xuat / Hom nay bi huy giua chung.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 300));
    await _arrive(tester, inputs);
    expect(_title(tester), 'Lên Body Level!');
    expect(find.byType(GtRankUpCard), findsOneWidget);
    expect(await _showAll(tester), ['Lên Body Level!']);
  });

  testWidgets('covered before the check: nothing until the next visit', (
    tester,
  ) async {
    await MilestoneStore.save('u1', _known);
    final inputs = _inputs(streak: 7, body: BodyLevel.rookie);
    await tester.pumpWidget(_watcher(visit: 0, inputs: _inputs()));
    await tester.pumpWidget(_watcher(visit: 1, inputs: inputs));
    await tester.pump(const Duration(milliseconds: 400));
    // Nguoi dung mo popup / doi tab truoc khi kiem.
    await tester.pumpWidget(
      _watcher(visit: 1, onScreen: false, inputs: inputs),
    );
    await _settle(tester);
    expect(find.byType(GtCelebration), findsNothing);
    expect(await MilestoneStore.load('u1'), _known);
    await tester.pumpWidget(_watcher(visit: 2, inputs: inputs));
    await _settle(tester);
    expect(await _showAll(tester), ['Chuỗi 7 ngày!']);
  });

  testWidgets('stale data offline does not lower the mark', (tester) async {
    await MilestoneStore.save(
      'u1',
      const MilestoneRecord(streak: 7, streakOn: _before),
    );
    // Mat mang: du lieu tren may thieu ngay lam o may khac -> chuoi 0.
    await _arrive(tester, _inputs(streak: 0, syncedOn: null));
    expect(
      await MilestoneStore.load('u1'),
      const MilestoneRecord(streak: 7, streakOn: _before),
    );
    // Lan dong bo thanh cong cuoi la hom qua (app mo qua nua dem): van cu.
    await tester.pumpWidget(
      _watcher(visit: 1, inputs: _inputs(streak: 1, syncedOn: '2026-10-01')),
    );
    await _settle(tester);
    expect((await MilestoneStore.load('u1')).streak, 7);
    // Dong bo lai, chuoi 10: khong chuc mung lap moc 7.
    await tester.pumpWidget(_watcher(visit: 1, inputs: _inputs(streak: 10)));
    await _settle(tester);
    expect(find.byType(GtCelebration), findsNothing);
  });

  testWidgets('unknown inputs leave their part of the record alone', (
    tester,
  ) async {
    await MilestoneStore.save(
      'u1',
      const MilestoneRecord(streak: 7, streakOn: _before),
    );
    // Chuoi chua dong bo xong, English Level chua tai: chi Body Level biet.
    await _arrive(tester, _inputs(body: BodyLevel.regular, english: null));
    expect(find.byType(GtCelebration), findsNothing);
    expect(
      await MilestoneStore.load('u1'),
      const MilestoneRecord(streak: 7, streakOn: _before, bodyLevel: 1),
    );
  });

  testWidgets('signed out: nothing is checked until someone signs in', (
    tester,
  ) async {
    await MilestoneStore.save('u1', _known);
    await _arrive(tester, _inputs(streak: 7), userId: null);
    expect(find.byType(GtCelebration), findsNothing);
    expect(await MilestoneStore.load('u1'), _known);
    await tester.pumpWidget(_watcher(visit: 1, inputs: _inputs(streak: 7)));
    await _settle(tester);
    expect(await _showAll(tester), ['Chuỗi 7 ngày!']);
  });

  testWidgets('before Today is first shown nothing is checked', (tester) async {
    await MilestoneStore.save('u1', _known);
    await tester.pumpWidget(_watcher(visit: 0, inputs: _inputs()));
    await tester.pumpWidget(_watcher(visit: 0, inputs: _inputs(streak: 7)));
    await _settle(tester);
    expect(find.byType(GtCelebration), findsNothing);
    expect(await MilestoneStore.load('u1'), _known);
  });

  testWidgets('news during a Celebration is checked right after it', (
    tester,
  ) async {
    await MilestoneStore.save('u1', _known);
    await _arrive(tester, _inputs(streak: 7, body: BodyLevel.rookie));
    expect(_title(tester), 'Chuỗi 7 ngày!');
    // Body Level tai xong trong luc dang chuc mung.
    await tester.pumpWidget(
      _watcher(visit: 1, inputs: _inputs(streak: 7, body: BodyLevel.regular)),
    );
    await tester.pump(_delay + const Duration(milliseconds: 50));
    expect(_title(tester), 'Chuỗi 7 ngày!');
    await _close(tester);
    await _settle(tester);
    expect(await _showAll(tester), ['Lên Body Level!']);
  });
}

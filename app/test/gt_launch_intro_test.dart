import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/theme/gt_haptics.dart';
import 'package:learn_english_music/core/theme/gt_tokens.dart';
import 'package:learn_english_music/core/widgets/gt_launch_intro.dart';
import 'package:learn_english_music/core/widgets/launch_intro_timeline.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Man "Hom nay" gia ben duoi lop phu; [target] = vong Daily Rings 164dp;
/// [onAppTap] = cham vao app ben duoi.
Widget _app(
  Widget intro, {
  bool reduce = false,
  bool target = false,
  VoidCallback? onAppTap,
}) => MaterialApp(
  theme: ThemeData(extensions: const [GtTokens.dark]),
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
      child: Scaffold(
        body: Stack(
          children: [
            const Center(child: Text('Hôm nay')),
            if (onAppTap != null)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onAppTap,
                ),
              ),
            if (target)
              Positioned(
                left: 20,
                top: 100,
                child: SizedBox(
                  key: gtLaunchRingTarget,
                  width: 164,
                  height: 164,
                ),
              ),
            Positioned.fill(child: intro),
          ],
        ),
      ),
    ),
  ),
);

GtLaunchRingPainter _ring(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .map((c) => c.painter)
    .whereType<GtLaunchRingPainter>()
    .single;

double _opacityOf(WidgetTester tester, String text) => tester
    .widget<Opacity>(
      find.ancestor(of: find.text(text), matching: find.byType(Opacity)).first,
    )
    .opacity;

void main() {
  late List<String> buzzes;

  setUp(() {
    GtHaptics.resetForTest();
    SharedPreferences.setMockInitialValues({});
    buzzes = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            buzzes.add('${call.arguments}');
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  /// Dung intro + khung dau (dong ho cua intro bat dau tu khung nay).
  Future<void> start(
    WidgetTester tester,
    LaunchIntroVariant? variant,
    VoidCallback onDone, {
    bool reduce = false,
    bool target = false,
    VoidCallback? onAppTap,
  }) async {
    await tester.pumpWidget(
      _app(
        GtLaunchIntro(variant: variant, onDone: onDone),
        reduce: reduce,
        target: target,
        onAppTap: onAppTap,
      ),
    );
    await tester.pump();
  }

  testWidgets('full: GymTalk and both authors, one light tick, then gone', (
    tester,
  ) async {
    var done = 0;
    await start(tester, LaunchIntroVariant.full, () => done++);
    expect(find.text('Quang Promise'), findsOneWidget);
    expect(find.text('Tùng Micky'), findsOneWidget);
    expect(find.text('Train your body. Train your English.'), findsOneWidget);
    expect(_opacityOf(tester, 'Quang Promise'), 0);
    await tester.pump(const Duration(milliseconds: 700));
    expect(buzzes, isEmpty);
    // Vong khep luc ~794 ms: 1 nhip rung nhe.
    await tester.pump(const Duration(milliseconds: 150));
    expect(buzzes, ['HapticFeedbackType.lightImpact']);
    await tester.pump(const Duration(milliseconds: 1200));
    expect(_opacityOf(tester, 'Quang Promise'), greaterThan(0.95));
    expect(_opacityOf(tester, 'Tùng Micky'), greaterThan(0.95));
    expect(done, 0);
    await tester.pump(const Duration(milliseconds: 500));
    expect(done, 1);
    expect(buzzes, hasLength(1));
  });

  testWidgets('short: no authors, gone in under a second', (tester) async {
    var done = 0;
    await start(tester, LaunchIntroVariant.short, () => done++);
    expect(find.text('Quang Promise'), findsNothing);
    expect(find.text('Train your body. Train your English.'), findsNothing);
    await tester.pump(const Duration(milliseconds: 900));
    expect(done, 0);
    expect(buzzes, ['HapticFeedbackType.lightImpact']);
    await tester.pump(const Duration(milliseconds: 100));
    expect(done, 1);
  });

  testWidgets('a tap skips: gone about 170 ms later, no tick', (tester) async {
    var done = 0;
    await start(tester, LaunchIntroVariant.full, () => done++);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byType(GtLaunchIntro));
    await tester.pump(const Duration(milliseconds: 100));
    expect(done, 0);
    await tester.pump(const Duration(milliseconds: 100));
    expect(done, 1);
    await tester.pump(const Duration(seconds: 1));
    expect(buzzes, isEmpty);
  });

  testWidgets('reduced motion: a still frame, one tick, then a quick fade', (
    tester,
  ) async {
    var done = 0;
    await start(tester, LaunchIntroVariant.full, () => done++, reduce: true);
    expect(_opacityOf(tester, 'Quang Promise'), 1);
    await tester.pump(const Duration(milliseconds: 350));
    expect(buzzes, ['HapticFeedbackType.lightImpact']);
    await tester.pump(const Duration(milliseconds: 500));
    expect(done, 0);
    await tester.pump(const Duration(milliseconds: 100));
    expect(done, 1);
  });

  testWidgets('still deciding which version: holds the first frame', (
    tester,
  ) async {
    var done = 0;
    await start(tester, null, () => done++);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Quang Promise'), findsNothing);
    await tester.pump(const Duration(seconds: 3));
    expect(done, 0);
    expect(buzzes, isEmpty);
  });

  testWidgets('the ring flies into the Daily Rings card on Today', (
    tester,
  ) async {
    await start(tester, LaunchIntroVariant.full, () {}, target: true);
    await tester.pump(const Duration(milliseconds: 2150));
    await tester.pump(const Duration(milliseconds: 260));
    final ring = _ring(tester);
    // Tam + co vong Daily Rings (ban kinh 64 trong khung 164).
    expect(ring.center.dx, closeTo(20 + 82, 2));
    expect(ring.center.dy, closeTo(100 + 82, 2));
    expect(ring.radius, closeTo(64, 1));
  });

  testWidgets('no Daily Rings card on screen: the ring stays and fades', (
    tester,
  ) async {
    await start(tester, LaunchIntroVariant.full, () {});
    await tester.pump(const Duration(milliseconds: 2150));
    final before = _ring(tester).center;
    await tester.pump(const Duration(milliseconds: 260));
    expect(_ring(tester).center, before);
    expect(_ring(tester).opacity, lessThan(0.05));
  });

  testWidgets('while it leaves, taps go through to the app', (tester) async {
    var appTaps = 0;
    var done = 0;
    await start(
      tester,
      LaunchIntroVariant.full,
      () => done++,
      onAppTap: () => appTaps++,
    );
    await tester.pump(const Duration(milliseconds: 2200));
    await tester.tapAt(const Offset(400, 300));
    expect(appTaps, 1);
    // Khong bi tinh la bo qua: van xong dung luc.
    await tester.pump(const Duration(milliseconds: 300));
    expect(done, 1);
  });

  testWidgets('gate: a new build plays the full version, then lets Today go', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [launchIntroActiveProvider.overrideWith((ref) => true)],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _app(const GtLaunchIntroGate(currentBuild: 'b1')),
      ),
    );
    await tester.pump();
    // Giu khung dau toi khi logo giai ma xong (trong test: het 600 ms).
    expect(find.text('Quang Promise'), findsNothing);
    await tester.pump(const Duration(milliseconds: 650));
    await tester.pump();
    expect(find.text('Quang Promise'), findsOneWidget);
    expect(container.read(launchIntroActiveProvider), isTrue);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(find.byType(GtLaunchIntro), findsNothing);
    expect(container.read(launchIntroActiveProvider), isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(kLaunchIntroSeenBuildKey), 'b1');
  });

  testWidgets('gate: the same build again plays the short version', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({kLaunchIntroSeenBuildKey: 'b1'});
    await tester.pumpWidget(
      ProviderScope(child: _app(const GtLaunchIntroGate(currentBuild: 'b1'))),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 650));
    await tester.pump();
    expect(find.byType(GtLaunchIntro), findsOneWidget);
    expect(find.text('Quang Promise'), findsNothing);
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump();
    expect(find.byType(GtLaunchIntro), findsNothing);
  });
}

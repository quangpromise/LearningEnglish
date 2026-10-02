import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/theme/gt_haptics.dart';
import 'package:learn_english_music/core/theme/gt_tokens.dart';
import 'package:learn_english_music/core/widgets/gt_switchers.dart';
import 'package:learn_english_music/features/fitness/presentation/gt_set_tick.dart';

Widget _app(Widget child, {bool reduce = false}) => MaterialApp(
  theme: ThemeData(extensions: const [GtTokens.dark]),
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
      child: Scaffold(
        body: Padding(padding: const EdgeInsets.all(40), child: child),
      ),
    ),
  ),
);

double _tickScale(WidgetTester tester) => tester
    .widget<Transform>(
      find.descendant(
        of: find.byType(GtSetTick),
        matching: find.byType(Transform),
      ),
    )
    .transform
    .getMaxScaleOnAxis();

void main() {
  late List<Object?> haptics;

  setUp(() {
    GtHaptics.resetForTest();
    haptics = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            haptics.add(call.arguments);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('set tick', () {
    testWidgets('tap: ticks at once, bounces, buzzes lightly, reports once', (
      tester,
    ) async {
      var ticks = 0;
      await tester.pumpWidget(
        _app(
          GtSetTick(
            done: false,
            active: true,
            onTap: () => ticks++,
            label: 'Tick',
          ),
        ),
      );
      expect(_tickScale(tester), 1);
      await tester.tap(find.byType(GtSetTick));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 30));
      expect(_tickScale(tester), lessThan(1));
      // O da tick ngay luc cham (truoc khi controller ghi hiep).
      final semantics = tester.widget<Semantics>(
        find
            .descendant(
              of: find.byType(GtSetTick),
              matching: find.byType(Semantics),
            )
            .first,
      );
      expect(semantics.properties.checked, isTrue);
      // Cham lai khi dang nay: khong bao lan 2.
      await tester.tap(find.byType(GtSetTick), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(_tickScale(tester), 1);
      expect(ticks, 1);
      expect(haptics, ['HapticFeedbackType.lightImpact']);
    });

    testWidgets('an inactive tick ignores taps', (tester) async {
      var ticks = 0;
      await tester.pumpWidget(
        _app(
          GtSetTick(
            done: false,
            active: false,
            onTap: () => ticks++,
            label: 'Tick',
          ),
        ),
      );
      await tester.tap(find.byType(GtSetTick), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(ticks, 0);
      expect(haptics, isEmpty);
    });

    testWidgets('reduced motion: no bounce, still ticks and buzzes', (
      tester,
    ) async {
      var ticks = 0;
      await tester.pumpWidget(
        _app(
          GtSetTick(
            done: false,
            active: true,
            onTap: () => ticks++,
            label: 'Tick',
          ),
          reduce: true,
        ),
      );
      await tester.tap(find.byType(GtSetTick));
      await tester.pump();
      expect(_tickScale(tester), 1);
      expect(tester.hasRunningAnimations, isFalse);
      expect(ticks, 1);
      expect(haptics, hasLength(1));
    });
  });

  group('shared axis switcher', () {
    Widget axis(int position, {bool reduce = false}) => _app(
      GtSharedAxisSwitcher(
        position: position,
        child: SizedBox(width: 200, height: 40, child: Text('page $position')),
      ),
      reduce: reduce,
    );

    testWidgets('forward: old page leaves left, new page comes from right', (
      tester,
    ) async {
      await tester.pumpWidget(axis(0));
      final home = tester.getTopLeft(find.text('page 0')).dx;
      await tester.pumpWidget(axis(1));
      await tester.pump(const Duration(milliseconds: 60));
      expect(tester.getTopLeft(find.text('page 0')).dx, lessThan(home));
      expect(tester.getTopLeft(find.text('page 1')).dx, greaterThan(home));
      await tester.pumpAndSettle();
      expect(find.text('page 0'), findsNothing);
      expect(tester.getTopLeft(find.text('page 1')).dx, home);
    });

    testWidgets('backward: the other way round', (tester) async {
      await tester.pumpWidget(axis(3));
      final home = tester.getTopLeft(find.text('page 3')).dx;
      await tester.pumpWidget(axis(2));
      await tester.pump(const Duration(milliseconds: 60));
      expect(tester.getTopLeft(find.text('page 3')).dx, greaterThan(home));
      expect(tester.getTopLeft(find.text('page 2')).dx, lessThan(home));
      await tester.pumpAndSettle();
    });

    testWidgets('reduced motion: switches at once', (tester) async {
      await tester.pumpWidget(axis(0, reduce: true));
      await tester.pumpWidget(axis(1, reduce: true));
      await tester.pump();
      expect(find.text('page 0'), findsNothing);
      expect(find.text('page 1'), findsOneWidget);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('fade + scale switcher', () {
    Widget swap(bool resting, {bool reduce = false}) => _app(
      GtFadeScaleSwitcher(
        switchKey: resting,
        child: Text(resting ? 'rest' : 'sets'),
      ),
      reduce: reduce,
    );

    testWidgets('cross-fades the sets table and the rest view', (tester) async {
      await tester.pumpWidget(swap(false));
      await tester.pumpWidget(swap(true));
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.text('sets'), findsOneWidget);
      expect(find.text('rest'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('sets'), findsNothing);
      expect(find.text('rest'), findsOneWidget);
    });

    testWidgets('reduced motion: swaps at once', (tester) async {
      await tester.pumpWidget(swap(false, reduce: true));
      await tester.pumpWidget(swap(true, reduce: true));
      await tester.pump();
      expect(find.text('sets'), findsNothing);
      expect(find.text('rest'), findsOneWidget);
    });
  });
}

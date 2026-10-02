import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/navigation/gt_fade_indexed_stack.dart';

Widget _tabs(
  int index, {
  bool reduce = false,
  List<ScrollController>? controllers,
  List<int>? taps,
  Map<int, bool>? ticking,
}) => MaterialApp(
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
      child: GtFadeIndexedStack(
        index: index,
        children: [
          for (var t = 0; t < 2; t++)
            Builder(
              builder: (context) {
                ticking?[t] = TickerMode.valuesOf(context).enabled;
                return ListView(
                  controller: controllers?[t],
                  children: [
                    for (var i = 0; i < 40; i++)
                      GestureDetector(
                        onTap: () => taps?.add(t),
                        child: SizedBox(height: 50, child: Text('tab$t row$i')),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    ),
  ),
);

/// Do mo dang ve (khong phai dich) cua tab [t].
double _opacity(WidgetTester tester, int t) => tester
    .renderObject<RenderAnimatedOpacity>(
      find
          .descendant(
            of: find.byType(GtFadeIndexedStack),
            matching: find.byType(AnimatedOpacity),
          )
          .at(t),
    )
    .opacity
    .value;

void main() {
  testWidgets('cross-fades between tabs and keeps each scroll position', (
    tester,
  ) async {
    final controllers = [ScrollController(), ScrollController()];
    addTearDown(() {
      for (final c in controllers) {
        c.dispose();
      }
    });
    await tester.pumpWidget(_tabs(0, controllers: controllers));
    controllers[0].jumpTo(300);
    await tester.pumpWidget(_tabs(1, controllers: controllers));
    await tester.pump(const Duration(milliseconds: 60));
    expect(_opacity(tester, 0), inExclusiveRange(0, 1));
    expect(_opacity(tester, 1), inExclusiveRange(0, 1));
    await tester.pumpAndSettle();
    expect(_opacity(tester, 0), 0);
    expect(_opacity(tester, 1), 1);

    await tester.pumpWidget(_tabs(0, controllers: controllers));
    await tester.pumpAndSettle();
    expect(controllers[0].offset, 300);
    expect(_opacity(tester, 0), 1);
  });

  testWidgets('hidden tabs take no taps and pause their tickers', (
    tester,
  ) async {
    final taps = <int>[];
    final ticking = <int, bool>{};
    await tester.pumpWidget(_tabs(0, taps: taps, ticking: ticking));
    // Tab 1 nam tren cung trong Stack nhung dang an.
    await tester.tap(find.text('tab0 row1'));
    expect(taps, [0]);
    expect(ticking, {0: true, 1: false});
  });

  testWidgets('reduced motion: tabs switch at once', (tester) async {
    await tester.pumpWidget(_tabs(0, reduce: true));
    await tester.pumpWidget(_tabs(1, reduce: true));
    expect(_opacity(tester, 0), 0);
    expect(_opacity(tester, 1), 1);
    expect(tester.hasRunningAnimations, isFalse);
  });
}

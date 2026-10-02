import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/widgets/gt_reduced_motion_tabs.dart';

class _Tabs extends StatefulWidget {
  const _Tabs();

  @override
  State<_Tabs> createState() => _TabsState();
}

class _TabsState extends State<_Tabs>
    with TickerProviderStateMixin, GtReducedMotionTabs<_Tabs> {
  @override
  int get tabCount => 2;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      TabBar(
        controller: tabController,
        tabs: const [
          Tab(text: 'A'),
          Tab(text: 'B'),
        ],
      ),
      Expanded(
        child: TabBarView(
          controller: tabController,
          children: const [Text('page A'), Text('page B')],
        ),
      ),
    ],
  );
}

Widget _app({bool reduce = false}) => MaterialApp(
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
      child: const Scaffold(body: _Tabs()),
    ),
  ),
);

TabController _controller(WidgetTester tester) =>
    tester.state<_TabsState>(find.byType(_Tabs)).tabController;

double _pageLeft(WidgetTester tester, String text) =>
    tester.getTopLeft(find.text(text)).dx;

void main() {
  testWidgets('tabs slide normally', (tester) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.text('B'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    // Trang B dang truot vao tu ben phai.
    expect(_pageLeft(tester, 'page B'), greaterThan(0));
    await tester.pumpAndSettle();
    expect(_controller(tester).index, 1);
    expect(_pageLeft(tester, 'page B'), 0);
  });

  testWidgets('reduced motion: switching tabs is instant', (tester) async {
    await tester.pumpWidget(_app(reduce: true));
    await tester.tap(find.text('B'));
    await tester.pump();
    expect(_controller(tester).index, 1);
    expect(_pageLeft(tester, 'page B'), 0);
    await tester.pumpAndSettle();
  });

  testWidgets('turning reduced motion on keeps the selected tab', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(_app(reduce: true));
    await tester.pump();
    expect(_controller(tester).index, 1);
    expect(_controller(tester).animationDuration, Duration.zero);
    expect(_pageLeft(tester, 'page B'), 0);
    await tester.tap(find.text('A'));
    await tester.pump();
    expect(_controller(tester).index, 0);
    expect(_pageLeft(tester, 'page A'), 0);
    await tester.pumpAndSettle();
  });
}

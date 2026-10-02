import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/navigation/app_popup.dart';
import 'package:learn_english_music/core/widgets/gt_when_on_screen.dart';

Widget _host({required int value, required bool onScreen}) => Directionality(
  textDirection: TextDirection.ltr,
  child: GtWhenOnScreen<int>(
    value: value,
    onScreen: onScreen,
    builder: (context, v, visit) => Text('$v/$visit'),
  ),
);

void main() {
  testWidgets('shows the value at once and counts the first visit', (
    tester,
  ) async {
    await tester.pumpWidget(_host(value: 1, onScreen: true));
    expect(find.text('1/0'), findsOneWidget);
    await tester.pump(kGtOnScreenSettle);
    expect(find.text('1/1'), findsOneWidget);
  });

  testWidgets('updates at once while on screen', (tester) async {
    await tester.pumpWidget(_host(value: 1, onScreen: true));
    await tester.pump(kGtOnScreenSettle);
    await tester.pumpWidget(_host(value: 2, onScreen: true));
    expect(find.text('2/1'), findsOneWidget);
  });

  testWidgets('holds the value while hidden, releases it after coming back', (
    tester,
  ) async {
    await tester.pumpWidget(_host(value: 1, onScreen: true));
    await tester.pump(kGtOnScreenSettle);
    await tester.pumpWidget(_host(value: 1, onScreen: false));
    await tester.pumpWidget(_host(value: 5, onScreen: false));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('1/1'), findsOneWidget);
    await tester.pumpWidget(_host(value: 5, onScreen: true));
    // Popup con dang truot xuong: chua cap nhat.
    expect(find.text('1/1'), findsOneWidget);
    await tester.pump(kGtOnScreenSettle);
    expect(find.text('5/2'), findsOneWidget);
  });

  testWidgets('covered again before settling: no visit, no update', (
    tester,
  ) async {
    await tester.pumpWidget(_host(value: 1, onScreen: false));
    await tester.pumpWidget(_host(value: 2, onScreen: true));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(_host(value: 3, onScreen: false));
    await tester.pump(kGtOnScreenSettle);
    expect(find.text('1/0'), findsOneWidget);
  });

  testWidgets('removed while arriving leaves no pending timer', (tester) async {
    await tester.pumpWidget(_host(value: 1, onScreen: true));
    await tester.pumpWidget(const SizedBox());
    // flutter_test bao loi neu con Timer chua chay khi ket thuc test.
  });

  testWidgets('a popup over the home route takes it off screen', (
    tester,
  ) async {
    final current = <bool?>[];
    late BuildContext home;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            home = context;
            current.add(ModalRoute.isCurrentOf(context));
            return const Scaffold();
          },
        ),
      ),
    );
    expect(current.last, isTrue);
    openAppPopup<void>(home, const SizedBox());
    await tester.pumpAndSettle();
    expect(current.last, isFalse);
    Navigator.of(home).pop();
    await tester.pump();
    expect(current.last, isTrue);
    // Home "hien lai" ngay luc sheet bat dau lui; sheet lui xong trong
    // kGtOnScreenSettle (neu framework doi thoi luong, test nay bao ngay).
    expect(find.byType(BottomSheet), findsOneWidget);
    await tester.pump(kGtOnScreenSettle);
    await tester.pump();
    expect(find.byType(BottomSheet), findsNothing);
  });
}

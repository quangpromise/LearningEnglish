import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/navigation/gt_tab_bar.dart';
import 'package:learn_english_music/core/navigation/root_tabs.dart';
import 'package:learn_english_music/core/theme/gt_tokens.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('tab bar: 4 tabs around a Quick Start button', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: ThemeData(extensions: const [GtTokens.dark]),
          home: const Scaffold(bottomNavigationBar: GtTabBar()),
        ),
      ),
    );

    for (final label in ['Hôm nay', 'Tập', 'Học', 'Tiến độ']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.byType(QuickStartButton), findsOneWidget);
    expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);

    await tester.tap(find.text('Học'));
    await tester.pump();
    expect(container.read(rootTabProvider), RootTab.learn);
  });

  test('active colours follow the area accents', () {
    const t = GtTokens.dark;
    expect(GtTabBar.activeColor(t, RootTab.today), t.tx);
    expect(GtTabBar.activeColor(t, RootTab.train), t.red);
    expect(GtTabBar.activeColor(t, RootTab.learn), t.blue);
    expect(GtTabBar.activeColor(t, RootTab.progress), t.gold);
  });
}

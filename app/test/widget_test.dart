import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learn_english_music/main.dart';

void main() {
  testWidgets('App renders home screen with bottom nav', (WidgetTester tester) async {
    await tester.pumpWidget(const LearnEnglishMusicApp());
    await tester.pump();

    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    expect(find.text('Xin chào'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/theme/app_theme.dart';
import 'package:learn_english_music/core/theme/gt_tokens.dart';

/// Man goc khong co Scaffold (vd dang nhap) van dung duoc TextField: ban
/// debug tung bao "No Material widget found" (agent test APK debug).
void main() {
  testWidgets('TextField in a root ScreenBackground has a Material ancestor', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [GtTokens.dark]),
        home: const ScreenBackground(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: TextField(decoration: InputDecoration(hintText: 'Email')),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.enterText(find.byType(TextField), 'a@b.c');
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('a@b.c'), findsOneWidget);
  });
}

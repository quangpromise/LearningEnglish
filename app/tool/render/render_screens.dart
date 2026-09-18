// Bo chup anh man hinh de TU KIEM THIET KE - khong nam trong test/ nen
// `flutter test` cua CI khong chay file nay. Chay tay:
//   flutter test tool/render/render_screens.dart
// Anh ra o tool/render/out/*.png.
//
// Luu y quan trong: TUYET DOI khong dung pumpAndSettle o day - man Home co
// hieu ung song am nhap nhay chay mai mai nen pumpAndSettle se treo vinh vien
// (da tung lam treo CI). Chi pump theo tung khoang thoi gian co dinh.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:learn_english_music/core/theme/app_theme.dart';
import 'package:learn_english_music/features/music_player/presentation/home_screen.dart';
import 'package:learn_english_music/features/wealth/presentation/wealth_home_screen.dart';

/// Kich thuoc khung chup - lay theo dung khung anh thiet ke goc (390 rong).
const _size = Size(390, 844);

Future<void> _loadFonts() async {
  // MaterialIcons lay tu cache cua Flutter SDK - khong nap thi moi icon ve
  // thanh 1 o vuong rong va anh chup vo dung de doi chieu thiet ke.
  for (final entry in {
    'SpaceGrotesk': 'assets/fonts/SpaceGrotesk.ttf',
    'Manrope': 'assets/fonts/Manrope.ttf',
    'MaterialIcons':
        'D:/dev/flutter/bin/cache/artifacts/material_fonts/'
        'materialicons-regular.otf',
  }.entries) {
    if (!File(entry.value).existsSync()) continue;
    final bytes = await File(entry.value).readAsBytes();
    final loader = FontLoader(entry.key)
      ..addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  }
}

/// Doc file anh that trong assets/ thay vi tra ve o trong - neu khong thi
/// anh minh hoa (hero, dong xu vang) se bien mat khoi anh chup va ta lai
/// ket luan sai ve thiet ke (da tung mac dung loi nay o ban mockup web).
void _serveRealAssets() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (ByteData? message) async {
        final key = utf8Decode(message!);
        final file = File(key);
        if (!file.existsSync()) return null;
        final bytes = await file.readAsBytes();
        return ByteData.view(bytes.buffer);
      });
}

String utf8Decode(ByteData data) =>
    const Utf8Decoder().convert(data.buffer.asUint8List());

/// Sao y theme that trong main.dart - neu dung ThemeData mac dinh thi chu se
/// ra font/mau khac voi app that va ta lai so sanh sai.
ThemeData _appTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.bgTop,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.blue,
    brightness: Brightness.dark,
    primary: AppColors.blue,
    secondary: AppColors.purple,
    surface: AppColors.bgMid,
  ),
  textTheme: ThemeData.dark().textTheme.apply(
    fontFamily: 'Manrope',
    bodyColor: AppColors.textPrimary,
    displayColor: AppColors.textPrimary,
    decoration: TextDecoration.none,
  ),
  fontFamily: 'Manrope',
);

Future<void> _shoot(WidgetTester tester, String name, Widget screen) async {
  tester.view.physicalSize = _size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final key = GlobalKey();
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _appTheme(),
        home: RepaintBoundary(
          key: key,
          child: MediaQuery(
            data: const MediaQueryData(size: _size, devicePixelRatio: 3),
            child: screen,
          ),
        ),
      ),
    ),
  );
  // Vai nhip co dinh cho anh/gradient ve xong, KHONG pumpAndSettle.
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }

  final boundary =
      key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 3);
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  final out = File('tool/render/out/$name.png');
  out.parent.createSync(recursive: true);
  out.writeAsBytesSync(png!.buffer.asUint8List());
  // ignore: avoid_print
  print('WROTE ${out.path} (${png.lengthInBytes} bytes)');
}

void main() {
  setUpAll(() async {
    await _loadFonts();
    // Cac provider o Home doc Supabase.instance.client ngay khi dung => chua
    // initialize thi man hinh nem loi va anh chup chi ra khung do. Khoi tao
    // voi URL gia: client khong ket noi cho den khi co truy van that, du de
    // dung bo cuc; cac o du lieu se rong/dang tai - dung cho viec soi thiet ke.
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'http://127.0.0.1:1',
      anonKey: 'render-harness',
    );
  });

  setUp(_serveRealAssets);

  testWidgets('wealth home', (tester) async {
    await _shoot(tester, 'wealth_home', const WealthHomeScreen());
  });

  testWidgets('english home', (tester) async {
    await _shoot(tester, 'english_home', const HomeScreen());
  });
}

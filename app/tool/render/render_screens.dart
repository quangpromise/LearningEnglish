// Bo chup anh man hinh de TU KIEM THIET KE - khong nam trong test/ nen
// `flutter test` cua CI khong chay file nay. Chay tay:
//   flutter test tool/render/render_screens.dart
// Anh ra o tool/render/out/*.png.
//
// Luu y quan trong: TUYET DOI khong dung pumpAndSettle o day - man Home co
// hieu ung song am nhap nhay chay mai mai nen pumpAndSettle se treo vinh vien
// (da tung lam treo CI). Chi pump theo tung khoang thoi gian co dinh.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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

/// Doc file anh that trong assets/ thay vi tra ve o trong.
///
/// NGUYEN NHAN moi anh tung hong trong bo chup nay: `Image.asset` khong doc
/// thang file - no goi `AssetManifest.loadFromAssetBundle()` de chon bien the
/// theo do phan giai, tuc la phai co 'AssetManifest.bin'. File do do Flutter
/// SINH RA luc build nen khong ton tai trong cay nguon; handler cu tra null
/// -> AssetImage nem loi -> anh ve thanh khoi hong. Gio ta TU SINH manifest
/// (moi asset 1 bien the dpr 1.0) bang dung StandardMessageCodec ma Flutter
/// dung de doc lai.
ByteData _buildAssetManifest() {
  final assets = <String>[];
  for (final dir in ['assets']) {
    final d = Directory(dir);
    if (!d.existsSync()) continue;
    for (final f in d.listSync(recursive: true)) {
      if (f is File) assets.add(f.path.replaceAll(r'\', '/'));
    }
  }
  final manifest = <Object?, Object?>{
    for (final a in assets)
      a: <Object?>[
        <Object?, Object?>{'asset': a, 'dpr': 1.0},
      ],
  };
  return const StandardMessageCodec().encodeMessage(manifest)!;
}

/// Supabase.initialize doc SharedPreferences ngay khi khoi tao. Trong test
/// khong co plugin that nen phai mock CHANNEL (khong dung
/// SharedPreferences.setMockInitialValues - ham do chi duoc phep goi trong
/// test/ nen analyzer cua CI se bao loi).
void _mockSharedPrefs() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/shared_preferences'),
        (call) async => call.method == 'getAll' ? <String, Object>{} : null,
      );
}

void _serveRealAssets() {
  final manifest = _buildAssetManifest();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (ByteData? message) async {
        final key = utf8Decode(message!);
        if (key == 'AssetManifest.bin' || key == 'AssetManifest.bin.json') {
          // ignore: avoid_print
          print('ASSET-REQ manifest: $key');
          return manifest;
        }
        final file = File(key);
        // ignore: avoid_print
        print('ASSET-REQ $key -> ${file.existsSync() ? 'OK' : 'THIEU'}');
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
        // Scaffold la BAT BUOC: cac man that luon nam trong Scaffold, va
        // InkWell (vd dai Nap/Rut) doi 1 Material to tien - thieu no thi
        // Flutter thay bang ErrorWidget to DO KIN ca the, de tuong nham la
        // loi thiet ke cua app.
        home: Scaffold(
          backgroundColor: Colors.black,
          body: RepaintBoundary(
            key: key,
            child: MediaQuery(
              data: const MediaQueryData(size: _size, devicePixelRatio: 3),
              child: screen,
            ),
          ),
        ),
      ),
    ),
  );
  // Giai ma anh la viec BAT DONG BO THAT, khong chay duoc duoi dong ho gia
  // cua widget test - day la ly do Image.asset ve ra khoang trong du bytes da
  // nap OK. Cho dong ho THAT chay 1 nhip trong runAsync de cac codec hoan tat.
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 220)),
    );
    await tester.pump(const Duration(milliseconds: 60));
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
  // Chieu cao THAT cua noi dung - de doi chieu voi so do tu anh thiet ke goc
  // ma khong phai uoc luong bang mat.
  final scroll = find.byType(SingleChildScrollView);
  if (scroll.evaluate().isNotEmpty) {
    final box = tester.renderObject<RenderBox>(scroll.first);
    final inner = box.getMaxIntrinsicHeight(box.size.width);
    // ignore: avoid_print
    print('CHIEU-CAO $name: khung=${box.size.height} noi-dung=$inner');
  }
}

void main() {
  setUpAll(() async {
    _mockSharedPrefs();
    await _loadFonts();
    // Cac provider o Home doc Supabase.instance.client ngay khi dung => chua
    // initialize thi man hinh nem loi va anh chup chi ra khung do. Khoi tao
    // voi URL gia: client khong ket noi cho den khi co truy van that, du de
    // dung bo cuc; cac o du lieu se rong/dang tai - dung cho viec soi thiet ke.
    await Supabase.initialize(
      url: 'http://127.0.0.1:1',
      // ignore: deprecated_member_use
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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// Nhat ky crash + ly do tien trinh app bi tat gan day - doc qua kenh native
/// "app/crash_log" (CrashLogApplication.kt + MainActivity.kt). Dung de chan
/// doan loi "Ung dung da dung" khi app o nen/khoa man hinh tren may that ma
/// nguoi dung khong xem duoc logcat: mo man Ho so -> "Nhat ky loi" -> chup
/// man hinh/sao chep gui dev. Chi co tren Android.
class CrashReport {
  const CrashReport({required this.crash, required this.exits});

  /// Stack trace loi Java/Kotlin gan nhat (null = chua crash lan nao).
  final String? crash;

  /// Toi da 5 lan tien trinh bi ket thuc gan nhat (Android 11+).
  final List<Map<String, String>> exits;

  /// Co dau hieu tat BAT THUONG (crash/ANR/bi he thong kill) khong.
  bool get hasProblem =>
      crash != null ||
      exits.any(
        (e) =>
            (e['reason'] ?? '').startsWith('CRASH') ||
            (e['reason'] ?? '').startsWith('ANR') ||
            (e['reason'] ?? '').startsWith('SIGNALED') ||
            (e['reason'] ?? '').startsWith('EXCESSIVE'),
      );

  String format() {
    final b = StringBuffer();
    b.writeln('=== Lý do app bị tắt gần đây ===');
    if (exits.isEmpty) b.writeln('(không có dữ liệu - cần Android 11+)');
    for (final e in exits) {
      b.writeln('- ${e['time']} | ${e['reason']}');
      if ((e['description'] ?? '').isNotEmpty) {
        b.writeln('  ${e['description']}');
      }
      b.writeln('  process=${e['process']} importance=${e['importance']}');
      if ((e['trace'] ?? '').isNotEmpty) b.writeln(e['trace']);
    }
    b.writeln();
    b.writeln('=== Crash Java/Kotlin gần nhất ===');
    b.writeln(crash ?? '(không có)');
    return b.toString();
  }
}

class CrashDiagnostics {
  CrashDiagnostics._();

  static const _channel = MethodChannel('app/crash_log');

  static bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<CrashReport?> read() async {
    if (!isSupported) return null;
    try {
      final m = await _channel.invokeMapMethod<String, dynamic>('read');
      if (m == null) return null;
      return CrashReport(
        crash: m['crash'] as String?,
        exits: [
          for (final e in (m['exits'] as List<dynamic>? ?? const []))
            (e as Map).map((k, v) => MapEntry('$k', '$v')),
        ],
      );
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  static Future<void> clear() async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod('clear');
    } on PlatformException {
      // Bo qua.
    }
  }
}

/// Dong chu nho trong man Ho so: "Nhat ky loi" (do/cam neu lan truoc app bi
/// tat bat thuong) - bam de xem, sao chep, xoa.
class CrashLogButton extends StatefulWidget {
  const CrashLogButton({super.key});

  @override
  State<CrashLogButton> createState() => _CrashLogButtonState();
}

class _CrashLogButtonState extends State<CrashLogButton> {
  late Future<CrashReport?> _report = CrashDiagnostics.read();

  Future<void> _open(CrashReport report) async {
    final text = report.format();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF151A30),
        title: Text('Nhật ký lỗi', style: AppTextStyles.heading(size: 16)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              text,
              style: const TextStyle(
                fontSize: 10.5,
                fontFamily: 'monospace',
                color: Colors.white70,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await CrashDiagnostics.clear();
              if (ctx.mounted) Navigator.of(ctx).pop();
              setState(() => _report = CrashDiagnostics.read());
            },
            child: const Text('Xoá'),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.maybeOf(context)
                  ?.showSnackBar(const SnackBar(content: Text('Đã sao chép')));
            },
            child: const Text('Sao chép'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!CrashDiagnostics.isSupported) return const SizedBox.shrink();
    return FutureBuilder<CrashReport?>(
      future: _report,
      builder: (context, snap) {
        final report = snap.data;
        if (report == null) return const SizedBox.shrink();
        final problem = report.hasProblem;
        return Center(
          child: TextButton(
            onPressed: () => _open(report),
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: Text(
              problem
                  ? '⚠ App đã bị tắt bất thường - bấm xem nhật ký lỗi'
                  : 'Nhật ký lỗi',
              style: AppTextStyles.muted(size: 9.5).copyWith(
                color: problem ? AppColors.amber : null,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Nut "Cho phep chay nen" (man Ho so) - mo hop thoai CHUAN cua Android bo
/// toi uu pin cho app, de may Nubia/ZTE, Xiaomi, OPPO... khong tu tat app khi
/// o nen/khoa man hinh. Tu kiem tra lai khi quay ve app tu hop thoai.
class BackgroundRunButton extends StatefulWidget {
  const BackgroundRunButton({super.key});

  @override
  State<BackgroundRunButton> createState() => _BackgroundRunButtonState();
}

class _BackgroundRunButtonState extends State<BackgroundRunButton>
    with WidgetsBindingObserver {
  static const _channel = MethodChannel('app/battery');
  bool? _ignoring;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    if (!CrashDiagnostics.isSupported) return;
    try {
      final v = await _channel.invokeMethod<bool>('isIgnoring');
      if (mounted) setState(() => _ignoring = v);
    } on PlatformException {
      // Bo qua.
    } on MissingPluginException {
      // Bo qua.
    }
  }

  @override
  Widget build(BuildContext context) {
    final ignoring = _ignoring;
    if (!CrashDiagnostics.isSupported || ignoring == null) {
      return const SizedBox.shrink();
    }
    if (ignoring) {
      return Center(
        child: Text(
          'Chạy nền: đã cho phép ✓',
          style: AppTextStyles.muted(size: 9)
              .copyWith(color: Colors.greenAccent),
        ),
      );
    }
    return Center(
      child: TextButton.icon(
        onPressed: () => _channel.invokeMethod('request'),
        style: TextButton.styleFrom(
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        ),
        icon: const Icon(
          Icons.battery_saver_rounded,
          size: 15,
          color: AppColors.amber,
        ),
        label: Text(
          'Cho phép chạy nền (tránh app bị tắt khi khoá máy)',
          style: AppTextStyles.body(
            size: 11,
            weight: FontWeight.w700,
          ).copyWith(color: AppColors.amber),
        ),
      ),
    );
  }
}

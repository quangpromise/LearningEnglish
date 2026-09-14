import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 1 chuong bao thuc co san tren may (Android RingtoneManager.TYPE_ALARM).
class DeviceAlarmSound {
  const DeviceAlarmSound({
    required this.uri,
    required this.title,
    this.isDefault = false,
  });

  final String uri;
  final String title;

  /// Chuong bao thuc MAC DINH hien tai cua may (dat trong app Dong ho/Cai dat).
  final bool isDefault;
}

/// Doc danh sach chuong bao thuc THAT SU co tren may qua kenh native
/// "planner/alarm_sounds" (MainActivity.kt) - khong kem file am thanh nao
/// vao app, khong them package moi. Chi co tren Android; web/iOS tra ve
/// danh sach rong (iOS khong cho app doc chuong he thong).
class DeviceAlarmSounds {
  DeviceAlarmSounds._();

  static const _channel = MethodChannel('planner/alarm_sounds');

  static bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<List<DeviceAlarmSound>> list() async {
    if (!isSupported) return const [];
    try {
      final raw = await _channel.invokeListMethod<Map<dynamic, dynamic>>(
        'list',
      );
      final seen = <String>{};
      final result = <DeviceAlarmSound>[];
      for (final m in raw ?? const <Map<dynamic, dynamic>>[]) {
        final uri = m['uri'] as String?;
        final title = m['title'] as String?;
        if (uri == null || title == null || title.isEmpty) continue;
        final isDefault = m['isDefault'] == '1';
        // Chuong mac dinh cung nam lai trong danh sach day du - bo ban trung
        // (so theo ten, vi uri mac dinh co the la dang "settings/..." khac uri
        // cua cung file trong media).
        if (!isDefault && seen.contains(title)) continue;
        seen.add(title);
        result.add(
          DeviceAlarmSound(uri: uri, title: title, isDefault: isDefault),
        );
      }
      return result;
    } on PlatformException {
      return const [];
    } on MissingPluginException {
      return const [];
    }
  }

  static Future<void> play(String uri) async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod('play', {'uri': uri});
    } on PlatformException {
      // May khong phat duoc uri nay (file da bi xoa...) - bo qua.
    }
  }

  static Future<void> stop() async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod('stop');
    } on PlatformException {
      // Bo qua.
    }
  }
}

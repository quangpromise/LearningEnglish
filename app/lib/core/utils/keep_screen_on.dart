import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Giu man hinh sang (Android: co FLAG_KEEP_SCREEN_ON cua Window, xem
/// MainActivity.kt kenh "app/keep_screen_on"). Nen tang chua cai kenh nay
/// (iOS, web, desktop) thi bo qua im lang - chi mat tinh nang, khong loi.
class KeepScreenOn {
  KeepScreenOn._();

  static const _channel = MethodChannel('app/keep_screen_on');

  static Future<void> enable() => _call('enable');

  static Future<void> disable() => _call('disable');

  static Future<void> _call(String method) async {
    try {
      await _channel.invokeMethod<void>(method);
    } on MissingPluginException {
      // Nen tang khong ho tro.
    } catch (e) {
      debugPrint('KeepScreenOn.$method failed: $e');
    }
  }
}

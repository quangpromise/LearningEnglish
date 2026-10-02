import 'dart:async';

import 'package:flutter/foundation.dart';

/// Tieng mo nhe o 3-2-1 cuoi gio nghi (woodblock VCSL, CC0).
const kRestTickAsset = 'audio/rest_tick.wav';

/// Chuong het gio nghi ("Pleasing Bell" - Spring Spring, CC0).
const kRestBellAsset = 'audio/rest_end_bell.wav';

/// 1 am ngan nap san, phat lai tu dau moi lan.
abstract interface class SfxPlayer {
  /// Nap [asset] (duong dan duoi `assets/`). [duckOthers]: ha nho nhac dang
  /// phat trong luc keu.
  Future<void> load(String asset, {required bool duckOthers});

  /// Phat tu dau (dang keu thi cat va keu lai).
  Future<void> replay();

  Future<void> dispose();
}

/// Am bao gio nghi (#131): tieng mo o 3-2-1 va chuong khi het gio, cung luc
/// voi rung. Ca 2 file CC0 - nguon + giay phep o ATTRIBUTION.md, tao bang
/// scripts/make_rest_sounds.py.
class RestSounds {
  RestSounds({required SfxPlayer Function() player})
    : _tick = player(),
      _bell = player() {
    // Nap san de bam la keu. Tieng mo tron chung voi nhac (3 nhip ma ha nhac
    // 3 lan thi nhac nhap nho); chuong ha nhac 1 chut cho nghe ro.
    _guard(_tick.load(kRestTickAsset, duckOthers: false));
    _guard(_bell.load(kRestBellAsset, duckOthers: true));
  }

  final SfxPlayer _tick;
  final SfxPlayer _bell;
  bool _disposed = false;

  /// Cong tac "Am bao gio nghi" trong cai dat buoi tap.
  bool enabled = true;

  /// 3-2-1 cuoi gio nghi.
  void tick() => _play(_tick);

  /// Het gio nghi (tu nhien - bo qua nghi thi khong goi).
  void end() => _play(_bell);

  void _play(SfxPlayer sound) {
    if (!enabled || _disposed) return;
    _guard(sound.replay());
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _guard(_tick.dispose());
    _guard(_bell.dispose());
  }

  /// Am chi la phu tro (da co rung): loi phat (thiet bi, giai ma...) khong
  /// duoc lam hong buoi tap.
  static void _guard(Future<void> future) => unawaited(
    future.catchError((Object e) => debugPrint('Rest sound failed: $e')),
  );
}

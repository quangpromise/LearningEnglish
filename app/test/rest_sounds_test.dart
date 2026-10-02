import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/fitness/data/rest_sounds.dart';

/// Am gia: ghi lai cac lan nap / phat / huy.
class _FakeSfx implements SfxPlayer {
  _FakeSfx(this.log, {this.fail = false});

  final List<String> log;
  final bool fail;
  String? _asset;

  @override
  Future<void> load(String asset) async {
    _asset = asset;
    log.add('load $asset');
    if (fail) throw Exception('no audio device');
  }

  @override
  Future<void> replay() async {
    log.add('play $_asset');
    if (fail) throw Exception('decode failed');
  }

  @override
  Future<void> dispose() async => log.add('dispose $_asset');
}

void main() {
  late List<String> log;
  setUp(() => log = []);

  RestSounds sounds({bool fail = false}) =>
      RestSounds(player: () => _FakeSfx(log, fail: fail));

  Iterable<String> played() => log.where((l) => l.startsWith('play'));

  test('both sounds are preloaded when the workout starts', () async {
    sounds();
    await pumpEventQueue();
    expect(log, ['load $kRestTickAsset', 'load $kRestBellAsset']);
  });

  test('tick() plays the woodblock, end() plays the bell', () async {
    sounds()
      ..tick()
      ..end();
    await pumpEventQueue();
    expect(played(), ['play $kRestTickAsset', 'play $kRestBellAsset']);
  });

  test(
    'disabled (the settings switch): tick() and end() stay silent',
    () async {
      sounds()
        ..enabled = false
        ..tick()
        ..end();
      await pumpEventQueue();
      expect(played(), isEmpty);
    },
  );

  test('a sound that fails never breaks the workout', () async {
    // Loi bat dong bo khong duoc xu ly se lam test nay fail.
    sounds(fail: true)
      ..tick()
      ..end();
    await pumpEventQueue();
    expect(played(), hasLength(2));
  });

  test('dispose releases both; later cues do nothing', () async {
    sounds()
      ..dispose()
      ..end()
      ..dispose();
    await pumpEventQueue();
    expect(log.where((l) => l.startsWith('dispose')), [
      'dispose $kRestTickAsset',
      'dispose $kRestBellAsset',
    ]);
    expect(played(), isEmpty);
  });

  test('3-2-1 ticks only on real 1-second steps down to 3, 2, 1', () {
    bool tick(int? previous, int second) =>
        isRestCountdownTick(previous: previous, second: second);
    expect([tick(4, 3), tick(3, 2), tick(2, 1)], [true, true, true]);
    // Het gio (0), con xa, lan dau, hay vua quay lai tu nen (40 -> 2).
    expect(
      [tick(1, 0), tick(5, 4), tick(null, 3), tick(40, 2), tick(3, 3)],
      [false, false, false, false, false],
    );
  });

  test('the sound files ship with the app: short mono WAV', () {
    for (final asset in [kRestTickAsset, kRestBellAsset]) {
      final bytes = File('assets/$asset').readAsBytesSync();
      expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF', reason: asset);
      // fmt: so kenh (byte 22) = 1, 44.1 kHz, duoi 100 KB.
      expect(bytes[22], 1, reason: asset);
      expect(
        bytes[24] | bytes[25] << 8 | bytes[26] << 16 | bytes[27] << 24,
        44100,
        reason: asset,
      );
      expect(bytes.length, lessThan(100 * 1024), reason: asset);
    }
  });
}

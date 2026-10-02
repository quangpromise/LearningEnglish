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
  Future<void> load(String asset, {required bool duckOthers}) async {
    _asset = asset;
    log.add('load $asset duck=$duckOthers');
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

  test('preloads the tick and the bell; only the bell ducks music', () async {
    sounds();
    await pumpEventQueue();
    expect(log, [
      'load $kRestTickAsset duck=false',
      'load $kRestBellAsset duck=true',
    ]);
  });

  test('3-2-1 plays the tick, the end of rest plays the bell', () async {
    sounds()
      ..tick()
      ..end();
    await pumpEventQueue();
    expect(played(), ['play $kRestTickAsset', 'play $kRestBellAsset']);
  });

  test('switched off in the workout settings: silent', () async {
    sounds()
      ..enabled = false
      ..tick()
      ..end();
    await pumpEventQueue();
    expect(played(), isEmpty);
  });

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

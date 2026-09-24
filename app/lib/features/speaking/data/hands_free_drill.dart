import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../fitness/data/gym_vocabulary.dart';
import '../../srs/data/srs_store.dart';

/// 1 cau/tu can nghe va nhac lai.
@immutable
class DrillItem {
  const DrillItem({required this.text, this.hint = ''});

  /// Noi dung tieng Anh (may doc + cham diem).
  final String text;

  /// Nghia tieng Viet (chi hien tren man hinh).
  final String hint;
}

/// Chon noi dung cho 1 luot luyen: the SRS den han truoc (on dung tu dang
/// hoc), roi cau vi du cua tu vung gym (cau ngan, dung ngu canh phong tap).
List<DrillItem> buildDrillItems({
  required List<SrsCard> dueCards,
  int count = 12,
  Random? random,
}) {
  final items = <DrillItem>[];
  final seen = <String>{};
  void add(String text, String hint) {
    final t = text.trim();
    if (t.isEmpty || !seen.add(t.toLowerCase())) return;
    items.add(DrillItem(text: t, hint: hint));
  }

  for (final card in dueCards.take(count ~/ 2)) {
    add(card.en, card.vi);
  }
  final examples = [...kGymWords]..shuffle(random ?? Random());
  for (final word in examples) {
    if (items.length >= count) break;
    add(word.exampleEn, word.exampleVi);
  }
  return items;
}

enum DrillPhase { idle, speaking, listening, finished }

/// Diem toi thieu de coi la noi dat (giong Tu moi moi ngay).
const kDrillPassScore = 70;

/// Vong lap "nghe va nhac lai" RANH TAY (dung khi chay bo/dap xe, khong can
/// nhin man hinh): may doc cau -> nghe nguoi dung noi -> cham diem -> khen
/// hoac cho nghe lai 1 lan -> cau tiep theo.
///
/// Tach khoi widget va nhan cac ham doc/nghe/cham qua tham so de test duoc
/// ma khong can mic/TTS that.
class HandsFreeDrillController extends ChangeNotifier {
  HandsFreeDrillController({
    required this.items,
    required this.speak,
    required this.listen,
    required this.score,
    this.onScored,
    this.maxAttempts = 2,
    Random? random,
  }) : _random = random ?? Random();

  final List<DrillItem> items;

  /// Doc 1 cau va CHO doc xong.
  final Future<void> Function(String text) speak;

  /// Nghe 1 lan, tra ve chuoi nhan dien duoc (rong neu khong nghe thay).
  final Future<String> Function() listen;

  /// Diem 0-100 cua [recognized] so voi [target].
  final int Function(String target, String recognized) score;

  /// Moi lan cham diem (ghi thong ke, vong "Noi").
  final void Function(int score)? onScored;

  final int maxAttempts;
  final Random _random;

  DrillPhase phase = DrillPhase.idle;
  int index = 0;
  int? lastScore;
  String lastRecognized = '';
  int passed = 0;
  bool _disposed = false;

  /// Tang moi lan dung/bat dau lai - vong lap dang chay kiem tra sau moi
  /// buoc cho (await) de tu thoat khi da bi dung.
  int _runId = 0;

  bool get running =>
      phase == DrillPhase.speaking || phase == DrillPhase.listening;

  DrillItem? get current => index < items.length ? items[index] : null;

  static const _praise = ['Great!', 'Nice job!', 'Perfect!', 'Well done!'];

  void _set(DrillPhase value) {
    phase = value;
    if (!_disposed) notifyListeners();
  }

  /// Bat dau (hoac tiep tuc tu cau hien tai).
  Future<void> start() async {
    if (running || items.isEmpty) return;
    if (phase == DrillPhase.finished) {
      index = 0;
      passed = 0;
    }
    final runId = ++_runId;
    bool stopped() => runId != _runId || _disposed;

    while (index < items.length) {
      final item = items[index];
      _set(DrillPhase.speaking);
      await speak(item.text);
      if (stopped()) return;
      for (var attempt = 0; attempt < maxAttempts; attempt++) {
        _set(DrillPhase.listening);
        final heard = await listen();
        if (stopped()) return;
        final points = score(item.text, heard);
        lastRecognized = heard;
        lastScore = points;
        onScored?.call(points);
        _set(DrillPhase.speaking);
        if (points >= kDrillPassScore) {
          passed++;
          await speak(_praise[_random.nextInt(_praise.length)]);
          break;
        }
        if (attempt < maxAttempts - 1) {
          await speak('Almost. Listen again. ${item.text}');
        } else {
          await speak('Good try. Next one.');
        }
        if (stopped()) return;
      }
      if (stopped()) return;
      index++;
      lastScore = null;
      lastRecognized = '';
    }
    _set(DrillPhase.finished);
    await speak(
      'Great job! You practiced ${items.length} phrases '
      'and nailed $passed of them.',
    );
  }

  /// Tam dung: vong lap dang cho se tu thoat; noi dung dang doc/nghe do man
  /// hinh tu dung (TTS/STT).
  void pause() {
    _runId++;
    if (phase != DrillPhase.finished) _set(DrillPhase.idle);
  }

  /// Bo qua cau hien tai.
  void skip() {
    final wasRunning = running;
    pause();
    if (index < items.length) index++;
    lastScore = null;
    lastRecognized = '';
    if (index >= items.length) {
      _set(DrillPhase.finished);
    } else if (!_disposed) {
      notifyListeners();
    }
    if (wasRunning && index < items.length) start();
  }

  @override
  void dispose() {
    _disposed = true;
    _runId++;
    super.dispose();
  }
}

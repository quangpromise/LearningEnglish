import 'dart:math';

import 'cefr_level.dart';
import 'content_pack.dart';
import 'english_path_progress.dart';
import 'english_path_state.dart';

/// Rest Game (CONTEXT.md): mini-game hoc trong Rest Break, spec #45.
///
/// 4 dang choi duoc 1 tay. Nghi < [kLongRestSeconds] chi ra dang nhanh.
const kRestGameFormats = {
  PracticeItemType.meaning,
  PracticeItemType.listening,
  PracticeItemType.gapFill,
  PracticeItemType.wordScramble,
};
const kQuickRestFormats = {
  PracticeItemType.meaning,
  PracticeItemType.wordScramble,
};
const kLongRestSeconds = 45;
const kShortRestMaxItems = 2;

/// Thoi gian trung binh (giay) de lam xong 1 cau moi dang - uoc so cau vua
/// thoi gian nghi.
const kRestFormatSeconds = {
  PracticeItemType.meaning: 8,
  PracticeItemType.listening: 10,
  PracticeItemType.gapFill: 12,
  PracticeItemType.wordScramble: 15,
};

/// XP cho moi cau Rest Game tra loi dung (spec #45).
const kRestGameXpPerCorrect = 2;

/// Ti le cau on (SRS den han / cau tung sai) trong 1 phien.
const kRestReviewShare = 0.3;

/// Len ke hoach cau hoi cho 1 lan nghi [restSeconds] giay: xoay vong cac
/// dang co san (bat dau bang Meaning - cau Listening khong bao gio mo dau,
/// de nguoi tap kip thay nut tat tieng), ~70% tu Unit hien tai va ~30% cau
/// on, khong vuot thoi gian. [exclude]: item da choi trong lan nghi nay.
List<PracticeItem> planRestGame({
  required int restSeconds,
  required List<PracticeItem> unitItems,
  required List<PracticeItem> reviewItems,
  required bool listeningEnabled,
  required Random random,
  Set<String> exclude = const {},
}) {
  final short = restSeconds < kLongRestSeconds;
  final allowed = {...(short ? kQuickRestFormats : kRestGameFormats)}
    ..removeWhere((t) => t == PracticeItemType.listening && !listeningEnabled);

  List<PracticeItem> pool(List<PracticeItem> src) =>
      [...src.where((i) => allowed.contains(i.type) && !exclude.contains(i.id))]
        ..shuffle(random);
  final unit = pool(unitItems);
  final review = pool(reviewItems);
  final formats = [
    for (final t in PracticeItemType.values)
      if (allowed.contains(t) &&
          (unit.any((i) => i.type == t) || review.any((i) => i.type == t)))
        t,
  ];
  if (formats.isEmpty) return const [];

  PracticeItem? take(List<PracticeItem> from, PracticeItemType type) {
    final i = from.indexWhere((x) => x.type == type);
    return i < 0 ? null : from.removeAt(i);
  }

  final plan = <PracticeItem>[];
  var reviewCount = 0;
  var budget = restSeconds;
  var misses = 0;
  var k = 0;
  while (misses < formats.length) {
    if (short && plan.length >= kShortRestMaxItems) break;
    final type = formats[k++ % formats.length];
    final cost = kRestFormatSeconds[type]!;
    if (cost > budget) {
      misses++;
      continue;
    }
    // Uu tien cau on khi so cau on con duoi 30% (lam tron) cua phien.
    final wantReview =
        reviewCount < ((plan.length + 1) * kRestReviewShare).round();
    final first = wantReview ? review : unit;
    final second = wantReview ? unit : review;
    var item = take(first, type);
    final fromReview = item != null ? wantReview : !wantReview;
    item ??= take(second, type);
    if (item == null) {
      misses++;
      continue;
    }
    misses = 0;
    if (fromReview) reviewCount++;
    plan.add(item);
    budget -= cost;
  }
  return plan;
}

class RestGameAnswer {
  const RestGameAnswer(this.item, this.correct);
  final PracticeItem item;
  final bool correct;
}

/// 1 phien Rest Game: tra loi lan luot; [close] khi het gio nghi tra ve cac
/// cau DA tra loi va bo qua moi cau tra loi sau do.
class RestGameSession {
  RestGameSession(this.plan);

  final List<PracticeItem> plan;
  final List<RestGameAnswer> _answers = [];
  bool _closed = false;

  bool get isClosed => _closed;
  bool get isDone => _answers.length >= plan.length;
  List<RestGameAnswer> get answers => List.unmodifiable(_answers);

  PracticeItem? get current => _closed || isDone ? null : plan[_answers.length];

  /// Tra ve dung/sai; sau khi dong thi luon false va khong ghi nhan.
  bool answer(int option) {
    final item = current;
    if (item == null) return false;
    final correct = option == item.answerIndex;
    _answers.add(RestGameAnswer(item, correct));
    return correct;
  }

  List<RestGameAnswer> close() {
    if (_closed) return const [];
    _closed = true;
    return answers;
  }
}

/// Nguon cau cho Rest Game: Unit dang hoc (Unit ke tiep cua English Level;
/// Stage da xong het thi on Unit cuoi) va cau on = cau tung sai + cau cua
/// tu vung den han SRS ([dueWords], chu thuong) trong Stage hien tai.
({List<PracticeItem> unit, List<PracticeItem> review}) restGameSources(
  ContentPack pack,
  CefrLevel level,
  EnglishPathState state, {
  Set<String> dueWords = const {},
}) {
  final units = unitsOf(pack, level);
  final current =
      nextUnit(pack, level, state) ?? (units.isEmpty ? null : units.last);
  final unitItems = current?.items ?? const <PracticeItem>[];
  final unitIds = {for (final i in unitItems) i.id};
  final review = <PracticeItem>[
    for (final stage in pack.stages)
      for (final u in stage.units)
        for (final i in u.items)
          if (!unitIds.contains(i.id) &&
              (state.wrongItems.contains(i.id) ||
                  (stage.stage == level &&
                      dueWords.contains(i.wordEn?.toLowerCase()))))
            i,
  ];
  return (unit: unitItems, review: review);
}

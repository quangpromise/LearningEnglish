import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Muc tieu moi ngay cho 3 vong o man Hom nay.
const kDailyTrainGoal = 1;
const kDailyLearnGoal = 10;
const kDailySpeakGoal = 5;

/// So lieu 1 ngay cua 3 vong Tap - Hoc - Noi + Daily Quest (spec #70).
@immutable
class DayProgress {
  const DayProgress({
    this.workouts = 0,
    this.wordsReviewed = 0,
    this.speakAttempts = 0,
    this.restDay = false,
    this.handsFree = false,
    this.trainerChat = false,
    this.chestOpened = false,
    this.rewarded = const {},
  });

  factory DayProgress.fromJson(Map<String, dynamic> json) => DayProgress(
    workouts: (json['w'] as num?)?.toInt() ?? 0,
    wordsReviewed: (json['l'] as num?)?.toInt() ?? 0,
    speakAttempts: (json['s'] as num?)?.toInt() ?? 0,
    restDay: json['r'] as bool? ?? false,
    handsFree: json['hf'] as bool? ?? false,
    trainerChat: json['tc'] as bool? ?? false,
    chestOpened: json['co'] as bool? ?? false,
    rewarded: {for (final k in (json['rk'] as List?) ?? const []) k.toString()},
  );

  /// Gop 2 ban cua cung 1 ngay (dong bo nhieu may): bo dem lay MAX, co
  /// lay OR, khoa thuong lay hop - khong bao gio lam giam, gop lai nhieu
  /// lan van ra cung ket qua.
  static DayProgress merge(DayProgress a, DayProgress b) => DayProgress(
    workouts: max(a.workouts, b.workouts),
    wordsReviewed: max(a.wordsReviewed, b.wordsReviewed),
    speakAttempts: max(a.speakAttempts, b.speakAttempts),
    restDay: a.restDay || b.restDay,
    handsFree: a.handsFree || b.handsFree,
    trainerChat: a.trainerChat || b.trainerChat,
    chestOpened: a.chestOpened || b.chestOpened,
    rewarded: {...a.rewarded, ...b.rewarded},
  );

  /// So buoi tap da ket thuc (luu) trong ngay.
  final int workouts;

  /// So lan on/danh gia the tu vung (the nghi, on tap SRS, tu moi moi ngay).
  final int wordsReviewed;

  /// So lan luyen phat am duoc cham diem.
  final int speakAttempts;

  /// Ngay nghi theo giao an dang theo -> vong Tap tinh la xong.
  final bool restDay;

  /// Da xong 1 luot "Nghe va nhac lai" ranh tay (quest).
  final bool handsFree;

  /// Da tro chuyen voi PT AI du so luot (quest).
  final bool trainerChat;

  /// Da mo Quest Chest hom nay.
  final bool chestOpened;

  /// Khoa phan thuong XP da cong hom nay (vd `quest_review`, `chest`) -
  /// moi khoa chi cong 1 lan/ngay.
  final Set<String> rewarded;

  double get trainRatio =>
      restDay ? 1 : (workouts / kDailyTrainGoal).clamp(0.0, 1.0).toDouble();
  double get learnRatio =>
      (wordsReviewed / kDailyLearnGoal).clamp(0.0, 1.0).toDouble();
  double get speakRatio =>
      (speakAttempts / kDailySpeakGoal).clamp(0.0, 1.0).toDouble();

  bool get trainDone => restDay || workouts >= kDailyTrainGoal;
  bool get learnDone => wordsReviewed >= kDailyLearnGoal;
  bool get speakDone => speakAttempts >= kDailySpeakGoal;

  /// Ngay tinh vao chuoi "Body + Brain": xong vong Hoc VA (xong vong Tap
  /// hoac ngay nghi theo giao an). Vong Noi khong bat buoc de chuoi khong
  /// qua kho giu.
  bool get bodyBrainDone => learnDone && trainDone;

  DayProgress copyWith({
    int? workouts,
    int? wordsReviewed,
    int? speakAttempts,
    bool? restDay,
    bool? handsFree,
    bool? trainerChat,
    bool? chestOpened,
    Set<String>? rewarded,
  }) => DayProgress(
    workouts: workouts ?? this.workouts,
    wordsReviewed: wordsReviewed ?? this.wordsReviewed,
    speakAttempts: speakAttempts ?? this.speakAttempts,
    restDay: restDay ?? this.restDay,
    handsFree: handsFree ?? this.handsFree,
    trainerChat: trainerChat ?? this.trainerChat,
    chestOpened: chestOpened ?? this.chestOpened,
    rewarded: rewarded ?? this.rewarded,
  );

  /// Them 1 khoa thuong (idempotent).
  DayProgress withRewarded(String key) =>
      rewarded.contains(key) ? this : copyWith(rewarded: {...rewarded, key});

  Map<String, dynamic> toJson() => {
    'w': workouts,
    'l': wordsReviewed,
    's': speakAttempts,
    'r': restDay,
    if (handsFree) 'hf': true,
    if (trainerChat) 'tc': true,
    if (chestOpened) 'co': true,
    if (rewarded.isNotEmpty) 'rk': [...rewarded]..sort(),
  };

  @override
  bool operator ==(Object other) =>
      other is DayProgress &&
      other.workouts == workouts &&
      other.wordsReviewed == wordsReviewed &&
      other.speakAttempts == speakAttempts &&
      other.restDay == restDay &&
      other.handsFree == handsFree &&
      other.trainerChat == trainerChat &&
      other.chestOpened == chestOpened &&
      other.rewarded.length == rewarded.length &&
      other.rewarded.containsAll(rewarded);

  @override
  int get hashCode => Object.hash(
    workouts,
    wordsReviewed,
    speakAttempts,
    restDay,
    handsFree,
    trainerChat,
    chestOpened,
    Object.hashAllUnordered(rewarded),
  );
}

/// Dem tien do 3 vong Tap - Hoc - Noi theo tung ngay, luu tren may
/// (SharedPreferences, giu 60 ngay). Singleton de cac noi ghi nhan (man tap,
/// the tu, luyen phat am...) goi truc tiep ma khong can WidgetRef; man Hom
/// nay/Tien do nghe thay doi qua ChangeNotifier.
///
/// Chi la so lieu dong luc CA NHAN tren 1 may - thong ke chinh thuc (XP,
/// buoi tap) van nam tren Supabase.
class DailyProgressStore extends ChangeNotifier {
  DailyProgressStore._({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static final DailyProgressStore instance = DailyProgressStore._();

  @visibleForTesting
  factory DailyProgressStore.forTest({DateTime Function()? clock}) =>
      DailyProgressStore._(clock: clock);

  static const _prefKey = 'daily_progress_v1';
  static const _keepDays = 60;

  final DateTime Function() _clock;
  final Map<String, DayProgress> _days = {};
  Future<void>? _loading;
  bool _loaded = false;

  /// Da doc xong du lieu da luu - truoc do [today] chi la ngay rong.
  bool get isLoaded => _loaded;

  int _revision = 0;

  /// Tang moi khi so lieu den tu NGOAI may nay (dong bo tai khoan, doi tai
  /// khoan) - man Hom nay coi do la moc moi, khong chuc mung nhu vua lam.
  int get revision => _revision;

  /// Khoa ngay 'yyyy-mm-dd' (theo gio may) - cung dung lam tien to khoa
  /// thuong tren server.
  static String keyOf(DateTime d) => _keyOf(d);

  static String _keyOf(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Future<void> ensureLoaded() => _loading ??= _load();

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw != null) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        for (final e in decoded.entries) {
          final json = Map<String, dynamic>.from(e.value as Map);
          _days.putIfAbsent(e.key, () => DayProgress.fromJson(json));
        }
      }
    } catch (e) {
      debugPrint('DailyProgressStore load failed: $e');
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _writeChain = Future.value();

  /// Xep hang cac lan ghi - 2 lan cong lien tiep khong de mat nhau.
  Future<void> _save() => _writeChain = _writeChain.then((_) => _write());

  Future<void> _write() async {
    // Chi giu [_keepDays] ngay gan nhat.
    final cutoff = _keyOf(_clock().subtract(const Duration(days: _keepDays)));
    _days.removeWhere((key, _) => key.compareTo(cutoff) < 0);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefKey,
        jsonEncode({for (final e in _days.entries) e.key: e.value.toJson()}),
      );
    } catch (e) {
      debugPrint('DailyProgressStore save failed: $e');
    }
  }

  // ---------------------------------------------------------------------
  // Dong bo tai khoan (xem gymtalk_sync_service.dart)
  // ---------------------------------------------------------------------

  /// {"YYYY-MM-DD": {...}} de day len Supabase.
  Map<String, dynamic> exportJson() => {
    for (final e in _days.entries) e.key: e.value.toJson(),
  };

  /// Gop so lieu tu server theo tung ngay bang [DayProgress.merge].
  /// Tra ve true neu du lieu tren may thay doi.
  Future<bool> mergeRemote(Map<String, dynamic> remote) async {
    await ensureLoaded();
    var changed = false;
    for (final e in remote.entries) {
      if (e.value is! Map) continue;
      final incoming = DayProgress.fromJson(
        Map<String, dynamic>.from(e.value as Map),
      );
      final local = _days[e.key] ?? const DayProgress();
      final merged = DayProgress.merge(local, incoming);
      if (merged != local || !_days.containsKey(e.key)) {
        _days[e.key] = merged;
        changed = true;
      }
    }
    if (changed) {
      _revision++;
      notifyListeners();
      await _save();
    }
    return changed;
  }

  /// Xoa sach so lieu tren may (doi sang tai khoan khac).
  Future<void> clearLocal() async {
    await ensureLoaded();
    _days.clear();
    _revision++;
    notifyListeners();
    await _save();
  }

  DayProgress dayOf(DateTime date) =>
      _days[_keyOf(date)] ?? const DayProgress();

  DayProgress get today => dayOf(_clock());

  Future<void> _update(DayProgress Function(DayProgress) change) async {
    await ensureLoaded();
    final key = _keyOf(_clock());
    _days[key] = change(_days[key] ?? const DayProgress());
    notifyListeners();
    await _save();
  }

  Future<void> addWorkout() =>
      _update((d) => d.copyWith(workouts: d.workouts + 1));

  Future<void> addWordsReviewed([int count = 1]) =>
      _update((d) => d.copyWith(wordsReviewed: d.wordsReviewed + count));

  Future<void> addSpeakAttempt() =>
      _update((d) => d.copyWith(speakAttempts: d.speakAttempts + 1));

  /// Man Hom nay goi khi biet hom nay la ngay nghi theo giao an.
  Future<void> markRestDay(bool restDay) async {
    await ensureLoaded();
    if (today.restDay == restDay) return;
    await _update((d) => d.copyWith(restDay: restDay));
  }

  /// Man Ranh tay goi khi xong 1 luot co it nhat 1 cau dat (quest).
  Future<void> markHandsFreeDone() async {
    await ensureLoaded();
    if (today.handsFree) return;
    await _update((d) => d.copyWith(handsFree: true));
  }

  /// Man PT AI goi khi nguoi dung da noi du so luot (quest).
  Future<void> markTrainerChatDone() async {
    await ensureLoaded();
    if (today.trainerChat) return;
    await _update((d) => d.copyWith(trainerChat: true));
  }

  /// Ghi nhan phan thuong [key] cua ngay [day] da duoc tra (va, voi ruong,
  /// danh dau da mo). Kiem tra va ghi DONG BO (khong await o giua) -> 2 lan
  /// goi song song chi 1 lan tra ve true. Ngay truyen vao (khong doc lai
  /// dong ho) de lan nhan thuong vat qua nua dem van ghi dung ngay.
  Future<bool> markRewarded(
    DateTime day,
    String key, {
    bool openChest = false,
  }) async {
    await ensureLoaded();
    final dayKey = _keyOf(day);
    final current = _days[dayKey] ?? const DayProgress();
    if (current.rewarded.contains(key)) return false;
    final next = current.withRewarded(key);
    _days[dayKey] = openChest ? next.copyWith(chestOpened: true) : next;
    notifyListeners();
    await _save();
    return true;
  }

  /// [count] ngay gan nhat, phan tu CUOI la hom nay.
  List<(DateTime, DayProgress)> lastDays(int count) {
    final now = _clock();
    final today = DateTime(now.year, now.month, now.day);
    return [
      for (var i = count - 1; i >= 0; i--)
        (
          today.subtract(Duration(days: i)),
          dayOf(today.subtract(Duration(days: i))),
        ),
    ];
  }

  /// Chuoi ngay lien tiep dat "Body + Brain". Hom nay chua xong van giu
  /// chuoi tu hom qua (con ca ngay de hoan thanh).
  int get bodyBrainStreak {
    final now = _clock();
    var cursor = DateTime(now.year, now.month, now.day);
    if (!dayOf(cursor).bodyBrainDone) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while (dayOf(cursor).bodyBrainDone && streak < _keepDays) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }
}

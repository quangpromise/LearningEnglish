import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Muc tieu moi ngay cho 3 vong o man Hom nay.
const kDailyTrainGoal = 1;
const kDailyLearnGoal = 10;
const kDailySpeakGoal = 5;

/// So lieu 1 ngay cua 3 vong Tap - Hoc - Noi.
@immutable
class DayProgress {
  const DayProgress({
    this.workouts = 0,
    this.wordsReviewed = 0,
    this.speakAttempts = 0,
    this.restDay = false,
  });

  factory DayProgress.fromJson(Map<String, dynamic> json) => DayProgress(
    workouts: (json['w'] as num?)?.toInt() ?? 0,
    wordsReviewed: (json['l'] as num?)?.toInt() ?? 0,
    speakAttempts: (json['s'] as num?)?.toInt() ?? 0,
    restDay: json['r'] as bool? ?? false,
  );

  /// So buoi tap da ket thuc (luu) trong ngay.
  final int workouts;

  /// So lan on/danh gia the tu vung (the nghi, on tap SRS, tu moi moi ngay).
  final int wordsReviewed;

  /// So lan luyen phat am duoc cham diem.
  final int speakAttempts;

  /// Ngay nghi theo giao an dang theo -> vong Tap tinh la xong.
  final bool restDay;

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
  }) => DayProgress(
    workouts: workouts ?? this.workouts,
    wordsReviewed: wordsReviewed ?? this.wordsReviewed,
    speakAttempts: speakAttempts ?? this.speakAttempts,
    restDay: restDay ?? this.restDay,
  );

  Map<String, dynamic> toJson() => {
    'w': workouts,
    'l': wordsReviewed,
    's': speakAttempts,
    'r': restDay,
  };
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
    notifyListeners();
  }

  Future<void> _save() async {
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

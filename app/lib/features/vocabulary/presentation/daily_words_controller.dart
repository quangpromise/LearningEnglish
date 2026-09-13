import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/daily_quiz_notifications.dart';
import '../../../core/utils/vn_time.dart';
import '../data/daily_words_repository.dart';

class DailyWordsState {
  const DailyWordsState({
    required this.words,
    required this.learnedTodayEnLower,
    required this.intervalMinutes,
    required this.mode,
    required this.active,
    required this.expired,
    required this.loaded,
  });

  final List<DailyWordEntry> words;
  final Set<String> learnedTodayEnLower;

  /// null = chua chon so phut nhac lai (khong co gia tri mac dinh).
  final int? intervalMinutes;

  /// null = chua chon cach on (Quiz/Writing).
  final DailyStudyMode? mode;
  final bool active;

  /// Danh sach con lai tu ngay hom truoc (da qua nua dem VN) - man Ho so chi
  /// hien 2 nut "Ket thuc hoc"/"Hoc lai" (xem _DailyWordsSection).
  final bool expired;
  final bool loaded;

  /// Du ca so phut lan cach on de bam "Bat dau hoc".
  bool get canStart =>
      words.isNotEmpty && intervalMinutes != null && mode != null;

  /// Chi dung de HIEN THI tien do (vd "3/12 tu da hoc" o Ho so) - KHONG
  /// dung de loc cau hoi (moi lan on luon hoi du danh sach).
  List<DailyWordEntry> get pending => words
      .where((w) => !learnedTodayEnLower.contains(w.en.toLowerCase()))
      .toList();

  static const empty = DailyWordsState(
    words: [],
    learnedTodayEnLower: {},
    intervalMinutes: null,
    mode: null,
    active: false,
    expired: false,
    loaded: false,
  );

  DailyWordsState copyWith({
    List<DailyWordEntry>? words,
    Set<String>? learnedTodayEnLower,
    int? Function()? intervalMinutes,
    DailyStudyMode? Function()? mode,
    bool? active,
    bool? expired,
    bool? loaded,
  }) {
    return DailyWordsState(
      words: words ?? this.words,
      learnedTodayEnLower: learnedTodayEnLower ?? this.learnedTodayEnLower,
      intervalMinutes: intervalMinutes != null
          ? intervalMinutes()
          : this.intervalMinutes,
      mode: mode != null ? mode() : this.mode,
      active: active ?? this.active,
      expired: expired ?? this.expired,
      loaded: loaded ?? this.loaded,
    );
  }
}

/// Quan ly danh sach "tu hoc hom nay" (KHONG gioi han so tu) + bat/tat nhac
/// on dinh ky theo cach on da chon (Quiz hoac Writing).
///
/// - Moi lan on (thong bao nhac hoac bam "Bat dau hoc") hoi DU CA danh sach
///   - xem DailyQuizPopupScreen.
/// - Sang NGAY MOI THEO GIO VIET NAM: tat nhac nhung GIU danh sach tu, danh
///   dau [DailyWordsState.expired] - nguoi dung tu chon "Hoc lai" (on tiep
///   dung cac tu do) hoac "Ket thuc hoc" (ghi het vao Tu da hoc). Vua kiem
///   tra luc khoi tao (mo lai app), vua dat 1 Timer bat dung luc nua dem VN.
class DailyWordsController extends StateNotifier<DailyWordsState> {
  DailyWordsController() : super(DailyWordsState.empty) {
    _restore();
  }

  Timer? _midnightTimer;

  Future<void> _restore() async {
    final words = await DailyWordsRepository.loadWords();
    final learned = await DailyWordsRepository.loadLearnedToday();
    final interval = await DailyWordsRepository.loadIntervalMinutes();
    final mode = await DailyWordsRepository.loadMode();
    final active = await DailyWordsRepository.loadActive();
    final expired = await DailyWordsRepository.loadExpired();
    state = state.copyWith(
      words: words,
      learnedTodayEnLower: learned,
      intervalMinutes: () => interval,
      mode: () => mode,
      active: active,
      expired: expired,
      loaded: true,
    );
    final rolledOver = await _rolloverIfNewDay();
    // App vua duoc MO LAI trong luc nhac van con active tu truoc (cung ngay)
    // - Timer tu mo man on o foreground KHONG song sot qua lan dong app (khac
    // voi thong bao he thong da dat san), phai tu bat lai o day.
    if (!rolledOver && state.active && state.intervalMinutes != null) {
      DailyQuizNotifications.instance.scheduleForegroundAutoOpen(
        intervalMinutes: state.intervalMinutes!,
      );
    }
    _scheduleMidnightReset();
  }

  /// Dat 1 lan Timer bat dung luc nua dem gio VN tiep theo - can thiet vi
  /// _restore() chi chay 1 lan luc mo app, app mo xuyen qua nua dem se khong
  /// tu biet sang ngay moi neu khong co co che chu dong nay.
  void _scheduleMidnightReset() {
    _midnightTimer?.cancel();
    final delay = nextVnMidnightInstant().difference(DateTime.now());
    _midnightTimer = Timer(delay.isNegative ? Duration.zero : delay, () {
      _rolloverIfNewDay().then((_) => _scheduleMidnightReset());
    });
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    super.dispose();
  }

  /// Them 1 tu (vd tu nut "Luu" o popup tra tu) - bo qua neu da co (trung
  /// khong phan biet hoa/thuong). Khong con gioi han so tu.
  Future<void> addWord(DailyWordEntry entry) async {
    await _rolloverIfNewDay();
    final lower = entry.en.toLowerCase();
    if (state.words.any((w) => w.en.toLowerCase() == lower)) return;
    final updated = [...state.words, entry];
    state = state.copyWith(words: updated);
    await DailyWordsRepository.saveWords(updated);
    if (state.active) await _rescheduleReminders();
  }

  /// Nhan danh sach tu chon hang loat o man chi tiet chu de:
  /// - Chua co phien nao dang chay/con lai tu hom truoc -> THAY danh sach va
  ///   bo chon so phut + cach on (bat nguoi dung tu chon lai, khong mac dinh).
  /// - Dang hoc hoac con danh sach hom truoc -> GOP them (bo trung), khong
  ///   lam mat tu dang hoc.
  Future<void> setWords(List<DailyWordEntry> words) async {
    await _rolloverIfNewDay();
    if (state.active || state.expired) {
      final existing = state.words.map((w) => w.en.toLowerCase()).toSet();
      final merged = [
        ...state.words,
        for (final w in words)
          if (existing.add(w.en.toLowerCase())) w,
      ];
      state = state.copyWith(words: merged);
      await DailyWordsRepository.saveWords(merged);
      if (state.active) await _rescheduleReminders();
      return;
    }
    state = state.copyWith(
      words: words,
      learnedTodayEnLower: {},
      intervalMinutes: () => null,
      mode: () => null,
    );
    await DailyWordsRepository.saveWords(words);
    await DailyWordsRepository.saveLearnedToday({});
    await DailyWordsRepository.saveIntervalMinutes(null);
    await DailyWordsRepository.saveMode(null);
  }

  Future<void> removeWord(String en) async {
    final lower = en.toLowerCase();
    final updated = state.words
        .where((w) => w.en.toLowerCase() != lower)
        .toList();
    state = state.copyWith(words: updated);
    await DailyWordsRepository.saveWords(updated);
    if (state.active) await _rescheduleReminders();
  }

  Future<void> setIntervalMinutes(int minutes) async {
    state = state.copyWith(intervalMinutes: () => minutes);
    await DailyWordsRepository.saveIntervalMinutes(minutes);
    if (state.active) await _rescheduleReminders();
  }

  Future<void> setMode(DailyStudyMode mode) async {
    state = state.copyWith(mode: () => mode);
    await DailyWordsRepository.saveMode(mode);
  }

  /// Danh dau 1 tu la DA TUNG tra loi dung it nhat 1 lan hom nay - chi dung
  /// de hien thi tien do o Ho so.
  Future<void> markLearned(String en) async {
    final lower = en.toLowerCase();
    final updated = {...state.learnedTodayEnLower, lower};
    state = state.copyWith(learnedTodayEnLower: updated);
    await DailyWordsRepository.saveLearnedToday(updated);
  }

  Future<void> start() async {
    if (!state.canStart) return;
    state = state.copyWith(active: true, expired: false);
    await DailyWordsRepository.saveActive(true);
    await DailyWordsRepository.saveExpired(false);
    await _rescheduleReminders();
  }

  /// "Hoc lai" danh sach con lai tu hom truoc - on tiep dung cac tu do voi
  /// so phut + cach on cu. Tra ve true neu da bat nhac lai ngay (du cau
  /// hinh); false = phien cu chua tung chon du so phut/cach on, chi go trang
  /// thai "hom truoc" de nguoi dung chon roi bam "Bat dau hoc" nhu binh
  /// thuong.
  Future<bool> relearn() async {
    state = state.copyWith(expired: false, learnedTodayEnLower: {});
    await DailyWordsRepository.saveExpired(false);
    await DailyWordsRepository.saveLearnedToday({});
    if (!state.canStart) return false;
    await start();
    return true;
  }

  /// Bam "Ket thuc hoc" - XOA danh sach + tat nhac, tro ve trang thai "chua
  /// chon tu nao". Viec ghi cac tu vao thong ke "Tu da hoc" do noi goi lam
  /// (can statsRepository, xem _DailyWordsSection) TRUOC khi goi ham nay.
  Future<void> stop() async {
    state = state.copyWith(
      active: false,
      expired: false,
      words: [],
      learnedTodayEnLower: {},
      intervalMinutes: () => null,
      mode: () => null,
    );
    await DailyWordsRepository.saveActive(false);
    await DailyWordsRepository.saveExpired(false);
    await DailyWordsRepository.saveWords([]);
    await DailyWordsRepository.saveLearnedToday({});
    await DailyWordsRepository.saveIntervalMinutes(null);
    await DailyWordsRepository.saveMode(null);
    await DailyQuizNotifications.instance.cancelReminders();
    DailyQuizNotifications.instance.cancelForegroundAutoOpen();
  }

  Future<void> _rescheduleReminders() async {
    final interval = state.intervalMinutes;
    if (state.words.isEmpty || interval == null) {
      await stop();
      return;
    }
    await DailyQuizNotifications.instance.scheduleReminders(
      intervalMinutes: interval,
    );
    // Ngoai thong bao he thong (chi hien de nguoi dung TU CHAM), bat them
    // Timer tu dong DAY man on len khi den han NEU dang mo san app.
    DailyQuizNotifications.instance.scheduleForegroundAutoOpen(
      intervalMinutes: interval,
    );
  }

  /// Sang ngay moi (gio VN): tat nhac nhung GIU danh sach tu, chuyen sang
  /// trang thai [DailyWordsState.expired] neu con tu. Tra ve true neu vua
  /// chuyen ngay.
  Future<bool> _rolloverIfNewDay() async {
    final savedDate = await DailyWordsRepository.loadDate();
    final today = todayVnIso();
    if (savedDate == today) return false;
    await DailyWordsRepository.saveDate(today);
    final expired = state.words.isNotEmpty;
    await DailyWordsRepository.saveActive(false);
    await DailyWordsRepository.saveExpired(expired);
    await DailyWordsRepository.saveLearnedToday({});
    await DailyQuizNotifications.instance.cancelReminders();
    DailyQuizNotifications.instance.cancelForegroundAutoOpen();
    state = state.copyWith(
      active: false,
      expired: expired,
      learnedTodayEnLower: {},
    );
    return true;
  }
}

final dailyWordsControllerProvider =
    StateNotifierProvider<DailyWordsController, DailyWordsState>(
      (ref) => DailyWordsController(),
    );

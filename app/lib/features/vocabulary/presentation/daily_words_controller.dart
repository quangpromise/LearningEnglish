import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/daily_quiz_notifications.dart';
import '../../../core/utils/vn_time.dart';
import '../data/daily_words_repository.dart';

const kMaxDailyWords = 10;

class DailyWordsState {
  const DailyWordsState({
    required this.words,
    required this.learnedTodayEnLower,
    required this.intervalMinutes,
    required this.active,
    required this.loaded,
  });

  final List<DailyWordEntry> words;
  final Set<String> learnedTodayEnLower;
  final int intervalMinutes;
  final bool active;
  final bool loaded;

  /// Chi dung de HIEN THI tien do (vd "3/10 tu da hoc" o Ho so) - KHONG con
  /// dung de loc cau hoi trong quiz nua (quiz luon hoi du ca 10 tu moi lan,
  /// xem DailyQuizPopupScreen).
  List<DailyWordEntry> get pending => words
      .where((w) => !learnedTodayEnLower.contains(w.en.toLowerCase()))
      .toList();

  static const empty = DailyWordsState(
    words: [],
    learnedTodayEnLower: {},
    intervalMinutes: DailyWordsRepository.defaultIntervalMinutes,
    active: false,
    loaded: false,
  );

  DailyWordsState copyWith({
    List<DailyWordEntry>? words,
    Set<String>? learnedTodayEnLower,
    int? intervalMinutes,
    bool? active,
    bool? loaded,
  }) {
    return DailyWordsState(
      words: words ?? this.words,
      learnedTodayEnLower: learnedTodayEnLower ?? this.learnedTodayEnLower,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      active: active ?? this.active,
      loaded: loaded ?? this.loaded,
    );
  }
}

/// Quan ly danh sach "10 tu hoc hom nay" + bat/tat nhac quiz dinh ky.
///
/// - Quiz moi lan mo (thong bao nhac hoac bam "Bat dau hoc") hoi DU CA danh
///   sach da chon, khong loc bot tu da tra loi dung truoc do - xem
///   DailyQuizPopupScreen.
/// - CHI tu dong ket thuc (huy nhac + reset danh sach) khi SANG NGAY MOI
///   THEO GIO VIET NAM (khong con tu dong ket thuc khi da tra loi dung het
///   10 tu) - vua kiem tra luc khoi tao (mo lai app), vua dat 1 Timer bat
///   dung luc nua dem VN de ket thuc ngay ca khi app dang mo xuyen qua thoi
///   diem do.
class DailyWordsController extends StateNotifier<DailyWordsState> {
  DailyWordsController() : super(DailyWordsState.empty) {
    _restore();
  }

  Timer? _midnightTimer;

  Future<void> _restore() async {
    final savedDate = await DailyWordsRepository.loadDate();
    final today = todayVnIso();
    if (savedDate != today) {
      // Sang ngay moi (gio VN) - danh sach hom qua khong con y nghia, reset
      // het va huy moi nhac cu con sot lai (neu co).
      await DailyWordsRepository.saveDate(today);
      await DailyWordsRepository.saveWords([]);
      await DailyWordsRepository.saveLearnedToday({});
      await DailyWordsRepository.saveActive(false);
      await DailyQuizNotifications.instance.cancelReminders();
      state = state.copyWith(
        words: [],
        learnedTodayEnLower: {},
        active: false,
        loaded: true,
      );
    } else {
      final words = await DailyWordsRepository.loadWords();
      final learned = await DailyWordsRepository.loadLearnedToday();
      final interval = await DailyWordsRepository.loadIntervalMinutes();
      final active = await DailyWordsRepository.loadActive();
      state = state.copyWith(
        words: words,
        learnedTodayEnLower: learned,
        intervalMinutes: interval,
        active: active,
        loaded: true,
      );
    }
    _scheduleMidnightReset();
  }

  /// Dat 1 lan Timer bat dung luc nua dem gio VN tiep theo de tu dong reset
  /// - can thiet vi _restore() chi chay 1 lan luc tao controller (luc mo
  /// app), neu app cu mo xuyen qua nua dem se khong tu biet ma reset neu
  /// khong co co che chu dong nay.
  void _scheduleMidnightReset() {
    _midnightTimer?.cancel();
    final delay = nextVnMidnightInstant().difference(DateTime.now());
    _midnightTimer = Timer(delay.isNegative ? Duration.zero : delay, () {
      _resetIfNewDay().then((_) => _scheduleMidnightReset());
    });
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    super.dispose();
  }

  /// Them 1 tu (vd tu nut "Luu" o popup tra tu) - bo qua neu da co (trung
  /// khong phan biet hoa/thuong) hoac da du 10 tu. Tra ve true neu them
  /// thanh cong (hoac da co san).
  Future<bool> addWord(DailyWordEntry entry) async {
    await _resetIfNewDay();
    final lower = entry.en.toLowerCase();
    if (state.words.any((w) => w.en.toLowerCase() == lower)) return true;
    if (state.words.length >= kMaxDailyWords) return false;
    final updated = [...state.words, entry];
    state = state.copyWith(words: updated);
    await DailyWordsRepository.saveWords(updated);
    if (state.active) await _rescheduleReminders();
    return true;
  }

  /// Thay the toan bo danh sach (vd tu man chi tiet chu de, chon hang loat) -
  /// gioi han toi da 10 tu.
  Future<void> setWords(List<DailyWordEntry> words) async {
    await _resetIfNewDay();
    final capped = words.take(kMaxDailyWords).toList();
    state = state.copyWith(words: capped);
    await DailyWordsRepository.saveWords(capped);
    if (state.active) await _rescheduleReminders();
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
    state = state.copyWith(intervalMinutes: minutes);
    await DailyWordsRepository.saveIntervalMinutes(minutes);
    if (state.active) await _rescheduleReminders();
  }

  /// Danh dau 1 tu la DA TUNG tra loi dung it nhat 1 lan hom nay - chi dung
  /// de hien thi tien do o Ho so va ghi vao thong ke "Tu da hoc" (goi rieng
  /// o noi mo quiz). KHONG anh huong den viec quiz co hoi lai tu nay o cac
  /// lan sau hay khong (luon hoi du danh sach) va KHONG tu dong ket thuc
  /// nhac khi tat ca da duoc danh dau.
  Future<void> markLearned(String en) async {
    final lower = en.toLowerCase();
    final updated = {...state.learnedTodayEnLower, lower};
    state = state.copyWith(learnedTodayEnLower: updated);
    await DailyWordsRepository.saveLearnedToday(updated);
  }

  Future<void> start() async {
    if (state.words.isEmpty) return;
    state = state.copyWith(active: true);
    await DailyWordsRepository.saveActive(true);
    await _rescheduleReminders();
  }

  Future<void> stop() async {
    state = state.copyWith(active: false);
    await DailyWordsRepository.saveActive(false);
    await DailyQuizNotifications.instance.cancelReminders();
  }

  Future<void> _rescheduleReminders() async {
    if (state.words.isEmpty) {
      await stop();
      return;
    }
    await DailyQuizNotifications.instance.scheduleReminders(
      intervalMinutes: state.intervalMinutes,
    );
  }

  Future<void> _resetIfNewDay() async {
    final savedDate = await DailyWordsRepository.loadDate();
    final today = todayVnIso();
    if (savedDate == today) return;
    await DailyWordsRepository.saveDate(today);
    await DailyWordsRepository.saveWords([]);
    await DailyWordsRepository.saveLearnedToday({});
    await DailyWordsRepository.saveActive(false);
    await DailyQuizNotifications.instance.cancelReminders();
    state = state.copyWith(words: [], learnedTodayEnLower: {}, active: false);
  }
}

final dailyWordsControllerProvider =
    StateNotifierProvider<DailyWordsController, DailyWordsState>(
      (ref) => DailyWordsController(),
    );

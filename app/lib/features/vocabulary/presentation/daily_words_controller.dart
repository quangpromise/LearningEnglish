import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/daily_quiz_notifications.dart';
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

String _todayIso() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

/// Quan ly danh sach "10 tu hoc hom nay" + bat/tat nhac quiz dinh ky. Tu
/// dong reset ve rong moi khi sang ngay moi (so sanh ngay luu voi ngay
/// hom nay khi khoi tao).
class DailyWordsController extends StateNotifier<DailyWordsState> {
  DailyWordsController() : super(DailyWordsState.empty) {
    _restore();
  }

  Future<void> _restore() async {
    final savedDate = await DailyWordsRepository.loadDate();
    final today = _todayIso();
    if (savedDate != today) {
      // Sang ngay moi - danh sach hom qua khong con y nghia, reset het va
      // huy moi nhac cu con sot lai (neu co).
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
      return;
    }
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

  /// Danh dau 1 tu la DA HOC (tra loi dung trong quiz nhac) - chi luc nay
  /// moi tinh vao thong ke "Tu da hoc" o Ho so (goi rieng o noi mo quiz,
  /// khong lam trong controller nay de tranh phu thuoc Supabase o day).
  Future<void> markLearned(String en) async {
    final lower = en.toLowerCase();
    final updated = {...state.learnedTodayEnLower, lower};
    state = state.copyWith(learnedTodayEnLower: updated);
    await DailyWordsRepository.saveLearnedToday(updated);
    if (state.pending.isEmpty) await stop();
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
    if (state.pending.isEmpty) {
      await stop();
      return;
    }
    await DailyQuizNotifications.instance.scheduleReminders(
      intervalMinutes: state.intervalMinutes,
    );
  }

  Future<void> _resetIfNewDay() async {
    final savedDate = await DailyWordsRepository.loadDate();
    final today = _todayIso();
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

import 'package:shared_preferences/shared_preferences.dart';

import 'workout_model.dart';

/// Cach hoc trong gio nghi: Rest Game (mac dinh) hoac the tu (kieu cu).
enum RestLearnMode { miniGame, cards }

/// Tuy chon man dang tap cua nguoi dung, luu tren may: thoi gian nghi mac
/// dinh, bat/tat the "Hoc khi nghi" va giong HLV tieng Anh.
class WorkoutPrefs {
  const WorkoutPrefs({
    required this.restSeconds,
    required this.learnWhileResting,
    this.coachVoice = true,
    this.restLearnMode = RestLearnMode.miniGame,
    this.restListening = true,
  });

  static const _restKey = 'fitness_rest_seconds';
  static const _learnKey = 'fitness_learn_while_resting';
  static const _coachKey = 'fitness_coach_voice';
  static const _modeKey = 'fitness_rest_learn_mode';
  static const _listeningKey = 'fitness_rest_listening';

  final int restSeconds;
  final bool learnWhileResting;

  /// Giong HLV doc cau nhac tieng Anh luc bat dau/het gio nghi.
  final bool coachVoice;

  final RestLearnMode restLearnMode;

  /// Cho phep dang Listening trong Rest Game (tat khi khong deo tai nghe -
  /// khong phat tieng ra loa giua phong gym).
  final bool restListening;

  static Future<WorkoutPrefs> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rest = prefs.getInt(_restKey);
      return WorkoutPrefs(
        restSeconds: kRestDurationOptions.contains(rest)
            ? rest!
            : kDefaultRestSeconds,
        learnWhileResting: prefs.getBool(_learnKey) ?? true,
        coachVoice: prefs.getBool(_coachKey) ?? true,
        restLearnMode: RestLearnMode.values.firstWhere(
          (m) => m.name == prefs.getString(_modeKey),
          orElse: () => RestLearnMode.miniGame,
        ),
        restListening: prefs.getBool(_listeningKey) ?? true,
      );
    } catch (_) {
      return const WorkoutPrefs(
        restSeconds: kDefaultRestSeconds,
        learnWhileResting: true,
      );
    }
  }

  static Future<void> saveRestSeconds(int seconds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_restKey, seconds);
    } catch (_) {}
  }

  static Future<void> saveCoachVoice(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_coachKey, enabled);
    } catch (_) {}
  }

  static Future<void> saveRestLearnMode(RestLearnMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_modeKey, mode.name);
    } catch (_) {}
  }

  static Future<void> saveRestListening(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_listeningKey, enabled);
    } catch (_) {}
  }

  static Future<void> saveLearnWhileResting(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_learnKey, enabled);
    } catch (_) {}
  }
}

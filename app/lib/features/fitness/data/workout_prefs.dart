import 'package:shared_preferences/shared_preferences.dart';

import 'workout_model.dart';

/// Tuy chon man dang tap cua nguoi dung, luu tren may: thoi gian nghi mac
/// dinh va bat/tat the "Hoc khi nghi".
class WorkoutPrefs {
  const WorkoutPrefs({
    required this.restSeconds,
    required this.learnWhileResting,
  });

  static const _restKey = 'fitness_rest_seconds';
  static const _learnKey = 'fitness_learn_while_resting';

  final int restSeconds;
  final bool learnWhileResting;

  static Future<WorkoutPrefs> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rest = prefs.getInt(_restKey);
      return WorkoutPrefs(
        restSeconds: kRestDurationOptions.contains(rest)
            ? rest!
            : kDefaultRestSeconds,
        learnWhileResting: prefs.getBool(_learnKey) ?? true,
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

  static Future<void> saveLearnWhileResting(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_learnKey, enabled);
    } catch (_) {}
  }
}

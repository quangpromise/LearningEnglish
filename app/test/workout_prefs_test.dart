import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/fitness/data/workout_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('rest timer sounds: on by default, the switch is kept (#131)', () async {
    expect((await WorkoutPrefs.load()).restSounds, isTrue);
    await WorkoutPrefs.saveRestSounds(false);
    expect((await WorkoutPrefs.load()).restSounds, isFalse);
    await WorkoutPrefs.saveRestSounds(true);
    expect((await WorkoutPrefs.load()).restSounds, isTrue);
  });
}

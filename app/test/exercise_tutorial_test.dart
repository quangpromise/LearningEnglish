import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/fitness/data/exercise_model.dart';
import 'package:learn_english_music/features/fitness/data/exercise_tutorial.dart';

const _goblet = Exercise(
  id: 144,
  nameVi: 'Squat ôm tạ ấm (Goblet Squat)',
  nameEn: 'Goblet Squat',
  primaryMuscle: 'Đùi trước · chính',
  secondaryMuscles: ['Bắp chân', 'Mông', 'Đùi sau', 'Vai'],
  involvementPercents: [45, 14, 14, 14, 13],
  equipment: 'Tạ ấm',
  instructions: [
    'Đứng thẳng, ôm tạ ấm sát ngực bằng hai tay, chân rộng bằng vai.',
    'Squat xuống giữa hai chân tới khi đùi sau chạm bắp chân.',
    'Dùng khuỷu tay đẩy nhẹ gối ra ngoài ở đáy, sau đó đứng thẳng dậy.',
  ],
  instructionsEn: [
    'Stand tall holding a kettlebell against your chest, feet apart.',
    'Squat down until your hamstrings touch your calves.',
    'Use your elbows to push your knees out, then stand back up.',
  ],
  suggestedSetsMin: 3,
  suggestedSetsMax: 3,
  suggestedRepsMin: 12,
  suggestedRepsMax: 15,
  suggestedRestSeconds: 60,
  muscleGroupCode: 'LEGS',
  movementType: 'COMPOUND',
  difficultyCode: 'BEGINNER',
  photoSlug: 'goblet_squat',
);

void main() {
  group('splitPhrases', () {
    test('chia tai dau cau, ghep lai dung nguyen van', () {
      const text = 'Stand tall, hold it close. Then go down!';
      final phrases = splitPhrases(text);
      expect(phrases, ['Stand tall, ', 'hold it close. ', 'Then go down!']);
      expect(phrases.join(), text);
    });

    test('khong co dau cau -> 1 cum', () {
      expect(splitPhrases('Squat down'), ['Squat down']);
    });
  });

  test('phraseStartTimes tang dan, bo qua phan dau "Step one."', () {
    final times = phraseStartTimes(
      lead: 'Step one. ',
      phrases: ['aaaa ', 'bbbbb'],
      totalSeconds: 20,
    );
    expect(times.first, closeTo(20 * 10 / 20, 1e-9));
    expect(times.last, greaterThan(times.first));
  });

  group('buildExerciseTutorial', () {
    final tutorial = buildExerciseTutorial(_goblet);

    test('tong quan -> 3 buoc -> tu khoa', () {
      final kinds = tutorial.chapters.map((c) => c.kind).toList();
      expect(kinds.first, TutorialChapterKind.overview);
      expect(kinds.where((k) => k == TutorialChapterKind.step), hasLength(3));
      expect(kinds.last, TutorialChapterKind.keywords);
    });

    test('tong quan doc ten + nhom co tieng Anh (bo hau to vai tro)', () {
      final overview = tutorial.chapters.first.narration;
      expect(overview, startsWith("Today's exercise: the Goblet Squat."));
      expect(overview, contains('quads'));
      expect(overview, isNot(contains('primary')));
    });

    test('buoc: doc "Step one." + cau, co ban dich va cau Noi theo', () {
      final step = tutorial.chapters[1];
      expect(step.narration, startsWith('Step one. Stand tall'));
      expect(step.vi, startsWith('Đứng thẳng'));
      expect(step.practiceText, _goblet.instructionsEn.first);
      expect(step.displayText, _goblet.instructionsEn.first);
    });

    test('tu khoa: uu tien tu co trong cau huong dan, khong trung ten bai', () {
      final keys = tutorial.keywords.map((w) => w.key).toList();
      expect(keys, hasLength(3));
      expect(keys, isNot(contains('goblet squat')));
      final text = _goblet.instructionsEn.join(' ').toLowerCase();
      expect(keys.every(text.contains), isTrue);
    });
  });
}

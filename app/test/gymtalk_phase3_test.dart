import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/fitness/data/program_model.dart';
import 'package:learn_english_music/features/speaking/data/hands_free_drill.dart';
import 'package:learn_english_music/features/srs/data/srs_store.dart';
import 'package:learn_english_music/features/today/data/program_recommendation.dart';

Program _program(
  int id, {
  required String level,
  required String equipment,
  required int sessions,
  required List<String> tags,
  String titleEn = '',
}) => Program(
  id: id,
  titleVi: 'P$id',
  titleEn: titleEn,
  level: level,
  equipment: equipment,
  sessionsPerWeek: sessions,
  durationWeeks: 8,
  tags: tags,
  days: const [],
);

// Giong 3 giao an trong assets/fitness/programs_seed.json.
final _programs = [
  _program(
    1,
    level: 'Trung cấp',
    equipment: 'Phòng gym',
    sessions: 4,
    tags: ['Tăng cơ', 'Phòng gym'],
    titleEn: 'Full-body muscle gain, 8 weeks',
  ),
  _program(
    2,
    level: 'Mới bắt đầu',
    equipment: 'Phòng gym',
    sessions: 3,
    tags: ['Tăng cơ', 'Phòng gym'],
    titleEn: 'Basic strength 5x5',
  ),
  _program(
    3,
    level: 'Mọi trình độ',
    equipment: 'Tại nhà',
    sessions: 3,
    tags: ['Giảm mỡ', 'Tại nhà'],
    titleEn: 'Fat loss at home, 30 days',
  ),
];

GymTalkSetupAnswers _answers({
  FitnessGoal goal = FitnessGoal.buildMuscle,
  ProgramDifficulty difficulty = ProgramDifficulty.beginner,
  int days = 3,
  bool atHome = false,
}) => GymTalkSetupAnswers(
  goal: goal,
  difficulty: difficulty,
  daysPerWeek: days,
  atHome: atHome,
);

void main() {
  group('recommendProgram', () {
    test('tap tai nha -> giao an tai nha', () {
      expect(recommendProgram(_programs, _answers(atHome: true))?.id, 3);
    });

    test('giam mo o phong gym van uu tien giao an giam mo', () {
      final p = recommendProgram(
        _programs,
        _answers(goal: FitnessGoal.loseFat),
      );
      expect(p?.id, 3);
    });

    test('tang co, trung cap, 4 buoi -> giao an tang co 8 tuan', () {
      final p = recommendProgram(
        _programs,
        _answers(difficulty: ProgramDifficulty.intermediate, days: 4),
      );
      expect(p?.id, 1);
    });

    test('tang suc manh, moi bat dau -> 5x5', () {
      final p = recommendProgram(
        _programs,
        _answers(goal: FitnessGoal.getStronger),
      );
      expect(p?.id, 2);
    });

    test('danh sach rong -> null', () {
      expect(recommendProgram(const [], _answers()), isNull);
    });
  });

  group('buildDrillItems', () {
    test('the den han truoc, khong trung, du so luong', () {
      final now = DateTime(2026, 9, 24);
      final items = buildDrillItems(
        dueCards: [
          SrsCard(key: 'dumbbell', en: 'dumbbell', vi: 'tạ đơn', due: now),
        ],
        count: 8,
        random: Random(1),
      );
      expect(items.first.text, 'dumbbell');
      expect(items, hasLength(8));
      expect(items.map((i) => i.text).toSet(), hasLength(8));
    });
  });

  group('HandsFreeDrillController', () {
    test('dat -> khen roi sang cau sau; chua dat -> cho nghe lai', () async {
      final spoken = <String>[];
      final heard = ['hello world', 'wrong', 'wrong'];
      final scores = <int>[];
      final drill = HandsFreeDrillController(
        items: const [
          DrillItem(text: 'hello world'),
          DrillItem(text: 'brace your core'),
        ],
        speak: (text) async => spoken.add(text),
        listen: () async => heard.removeAt(0),
        score: (target, said) => target == said ? 100 : 20,
        onScored: scores.add,
        random: Random(0),
      );
      await drill.start();

      expect(drill.phase, DrillPhase.finished);
      expect(drill.passed, 1);
      expect(scores, [100, 20, 20]);
      // Cau 2 duoc doc lai 1 lan sau lan dau chua dat.
      expect(
        spoken.where((s) => s.contains('Listen again. brace your core')),
        hasLength(1),
      );
      expect(spoken.last, contains('nailed 1 of them'));
      drill.dispose();
    });

    test('tam dung giua chung thi vong lap dung lai', () async {
      late HandsFreeDrillController drill;
      final spoken = <String>[];
      drill = HandsFreeDrillController(
        items: const [
          DrillItem(text: 'one'),
          DrillItem(text: 'two'),
        ],
        speak: (text) async => spoken.add(text),
        listen: () async {
          drill.pause();
          return 'one';
        },
        score: (_, _) => 100,
      );
      await drill.start();
      expect(drill.phase, DrillPhase.idle);
      expect(drill.index, 0);
      expect(spoken, ['one']);
      drill.dispose();
    });

    test('bo qua cau cuoi -> hoan thanh', () {
      final drill = HandsFreeDrillController(
        items: const [DrillItem(text: 'one')],
        speak: (_) async {},
        listen: () async => '',
        score: (_, _) => 0,
      );
      drill.skip();
      expect(drill.phase, DrillPhase.finished);
      drill.dispose();
    });
  });
}

import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import 'exercise_model.dart';

/// 1 tu/cum tu tieng Anh dung trong phong gym - noi dung HOC (luon giu cap
/// Anh-Viet, khong dich theo ngon ngu giao dien), hien o the "Hoc khi nghi"
/// giua cac set va the "Tu khoi dong" o man xem truoc buoi tap.
class GymWord {
  const GymWord({
    required this.en,
    required this.ipa,
    required this.vi,
    required this.exampleEn,
    required this.exampleVi,
    this.groups = const {},
  });

  /// Tao the tu chinh TEN BAI TAP dang tap (vd "Barbell Bench Press") - vua
  /// tap vua hoc dung ten dong tac bang tieng Anh. Khong co IPA (ten ghep
  /// nhieu tu), vi du lay tu buoc huong dan dau tien cua bai.
  factory GymWord.fromExercise(Exercise exercise) => GymWord(
    en: exercise.nameEn,
    ipa: '',
    vi: exercise.nameVi,
    exampleEn: exercise.instructionsEn.isNotEmpty
        ? exercise.instructionsEn.first
        : '',
    exampleVi: exercise.instructions.isNotEmpty
        ? exercise.instructions.first
        : '',
    groups: {exercise.muscleGroup},
  );

  final String en;

  /// IPA giong Anh-My; rong voi tu tao tu ten bai tap.
  final String ipa;
  final String vi;
  final String exampleEn;
  final String exampleVi;

  /// Nhom co lien quan - tap RONG nghia la tu chung, hop voi moi buoi tap.
  final Set<MuscleGroup> groups;

  /// Khoa luu tien do (khong phan biet hoa thuong).
  String get key => en.toLowerCase();
}

/// Bo tu vung gym tuyen chon (A2-B1): tu chung/khau lenh cua HLV, dung cu,
/// dong tu chuyen dong va ten nhom co.
const kGymWords = <GymWord>[
  // Tu chung + khau lenh HLV hay noi.
  GymWord(
    en: 'rep',
    ipa: '/rep/',
    vi: 'lần lặp (1 lần thực hiện động tác)',
    exampleEn: 'Do ten reps with good form.',
    exampleVi: 'Làm 10 lần với kỹ thuật chuẩn.',
  ),
  GymWord(
    en: 'set',
    ipa: '/set/',
    vi: 'hiệp (một nhóm lần lặp liên tiếp)',
    exampleEn: 'I do three sets of twelve.',
    exampleVi: 'Tôi tập 3 hiệp, mỗi hiệp 12 lần.',
  ),
  GymWord(
    en: 'rest',
    ipa: '/rest/',
    vi: 'nghỉ',
    exampleEn: 'Rest for one minute between sets.',
    exampleVi: 'Nghỉ 1 phút giữa các hiệp.',
  ),
  GymWord(
    en: 'warm up',
    ipa: '/wɔːrm ʌp/',
    vi: 'khởi động',
    exampleEn: 'Always warm up before you lift.',
    exampleVi: 'Luôn khởi động trước khi nâng tạ.',
  ),
  GymWord(
    en: 'cool down',
    ipa: '/kuːl daʊn/',
    vi: 'thả lỏng sau buổi tập',
    exampleEn: 'Walk slowly to cool down.',
    exampleVi: 'Đi bộ chậm để thả lỏng.',
  ),
  GymWord(
    en: 'stretch',
    ipa: '/stretʃ/',
    vi: 'giãn cơ',
    exampleEn: 'Stretch your legs after running.',
    exampleVi: 'Giãn cơ chân sau khi chạy.',
  ),
  GymWord(
    en: 'form',
    ipa: '/fɔːrm/',
    vi: 'kỹ thuật, tư thế thực hiện',
    exampleEn: 'Good form is more important than heavy weight.',
    exampleVi: 'Kỹ thuật đúng quan trọng hơn tạ nặng.',
  ),
  GymWord(
    en: 'range of motion',
    ipa: '/reɪndʒ əv ˈmoʊʃən/',
    vi: 'biên độ chuyển động',
    exampleEn: 'Use a full range of motion.',
    exampleVi: 'Thực hiện hết biên độ chuyển động.',
  ),
  GymWord(
    en: 'brace your core',
    ipa: '/breɪs jʊr kɔːr/',
    vi: 'siết chặt cơ bụng (giữ thân ổn định)',
    exampleEn: 'Brace your core before you lift the bar.',
    exampleVi: 'Siết cơ bụng trước khi nâng thanh tạ.',
  ),
  GymWord(
    en: 'inhale',
    ipa: '/ɪnˈheɪl/',
    vi: 'hít vào',
    exampleEn: 'Inhale as you lower the weight.',
    exampleVi: 'Hít vào khi hạ tạ xuống.',
  ),
  GymWord(
    en: 'exhale',
    ipa: '/eksˈheɪl/',
    vi: 'thở ra',
    exampleEn: 'Exhale as you push up.',
    exampleVi: 'Thở ra khi đẩy lên.',
  ),
  GymWord(
    en: 'posture',
    ipa: '/ˈpɑːstʃər/',
    vi: 'tư thế',
    exampleEn: 'Keep a good posture all the time.',
    exampleVi: 'Luôn giữ tư thế đúng.',
  ),
  GymWord(
    en: 'grip',
    ipa: '/ɡrɪp/',
    vi: 'cách cầm, độ bám tay',
    exampleEn: 'Use a shoulder-width grip.',
    exampleVi: 'Cầm tạ rộng bằng vai.',
  ),
  GymWord(
    en: 'neutral spine',
    ipa: '/ˈnuːtrəl spaɪn/',
    vi: 'cột sống giữ thẳng tự nhiên',
    exampleEn: 'Keep a neutral spine during the lift.',
    exampleVi: 'Giữ cột sống thẳng tự nhiên khi nâng tạ.',
  ),
  GymWord(
    en: 'spotter',
    ipa: '/ˈspɑːtər/',
    vi: 'người đứng hỗ trợ, canh tạ',
    exampleEn: 'Ask a spotter when you bench heavy.',
    exampleVi: 'Nhờ người canh tạ khi đẩy ngực nặng.',
  ),
  GymWord(
    en: 'personal best',
    ipa: '/ˈpɜːrsənəl best/',
    vi: 'kỷ lục cá nhân',
    exampleEn: 'I set a new personal best today!',
    exampleVi: 'Hôm nay tôi lập kỷ lục cá nhân mới!',
  ),
  GymWord(
    en: 'progressive overload',
    ipa: '/prəˈɡresɪv ˈoʊvərloʊd/',
    vi: 'tăng tải dần theo thời gian',
    exampleEn: 'Progressive overload helps you get stronger.',
    exampleVi: 'Tăng tải dần giúp bạn khỏe hơn.',
  ),
  GymWord(
    en: 'tempo',
    ipa: '/ˈtempoʊ/',
    vi: 'nhịp độ động tác',
    exampleEn: 'Keep a slow tempo on the way down.',
    exampleVi: 'Giữ nhịp chậm khi hạ xuống.',
  ),
  GymWord(
    en: 'sore',
    ipa: '/sɔːr/',
    vi: 'đau mỏi (cơ)',
    exampleEn: 'My legs are sore after yesterday.',
    exampleVi: 'Chân tôi mỏi nhừ sau buổi hôm qua.',
  ),
  GymWord(
    en: 'recovery',
    ipa: '/rɪˈkʌvəri/',
    vi: 'sự phục hồi',
    exampleEn: 'Sleep is important for recovery.',
    exampleVi: 'Giấc ngủ quan trọng cho việc phục hồi.',
  ),
  GymWord(
    en: 'hydrate',
    ipa: '/ˈhaɪdreɪt/',
    vi: 'bổ sung nước',
    exampleEn: 'Remember to hydrate between sets.',
    exampleVi: 'Nhớ uống nước giữa các hiệp.',
  ),
  GymWord(
    en: 'workout',
    ipa: '/ˈwɜːrkaʊt/',
    vi: 'buổi tập',
    exampleEn: 'That was a hard workout.',
    exampleVi: 'Đó là một buổi tập vất vả.',
  ),
  GymWord(
    en: 'routine',
    ipa: '/ruːˈtiːn/',
    vi: 'giáo án, lịch tập cố định',
    exampleEn: 'I follow a four-day routine.',
    exampleVi: 'Tôi theo giáo án 4 buổi mỗi tuần.',
  ),
  GymWord(
    en: 'to failure',
    ipa: '/tə ˈfeɪljər/',
    vi: 'đến khi kiệt sức, không làm thêm được',
    exampleEn: 'Do the last set to failure.',
    exampleVi: 'Hiệp cuối làm đến khi không nổi nữa.',
  ),

  // Dung cu.
  GymWord(
    en: 'barbell',
    ipa: '/ˈbɑːrbel/',
    vi: 'tạ đòn',
    exampleEn: 'Load two plates on the barbell.',
    exampleVi: 'Lắp hai bánh tạ vào tạ đòn.',
  ),
  GymWord(
    en: 'dumbbell',
    ipa: '/ˈdʌmbel/',
    vi: 'tạ đơn',
    exampleEn: 'Pick up a pair of dumbbells.',
    exampleVi: 'Cầm lên một cặp tạ đơn.',
  ),
  GymWord(
    en: 'kettlebell',
    ipa: '/ˈketlbel/',
    vi: 'tạ ấm',
    exampleEn: 'Swing the kettlebell to chest height.',
    exampleVi: 'Vung tạ ấm lên ngang ngực.',
  ),
  GymWord(
    en: 'bench',
    ipa: '/bentʃ/',
    vi: 'ghế tập',
    exampleEn: 'Lie flat on the bench.',
    exampleVi: 'Nằm thẳng trên ghế tập.',
  ),
  GymWord(
    en: 'rack',
    ipa: '/ræk/',
    vi: 'giá đỡ tạ',
    exampleEn: 'Put the bar back on the rack.',
    exampleVi: 'Đặt thanh tạ trở lại giá.',
  ),
  GymWord(
    en: 'plate',
    ipa: '/pleɪt/',
    vi: 'bánh tạ',
    exampleEn: 'Add a small plate on each side.',
    exampleVi: 'Thêm một bánh tạ nhỏ mỗi bên.',
  ),
  GymWord(
    en: 'cable machine',
    ipa: '/ˈkeɪbəl məˈʃiːn/',
    vi: 'máy kéo cáp',
    exampleEn: 'The cable machine is free now.',
    exampleVi: 'Máy cáp đang trống rồi.',
  ),
  GymWord(
    en: 'resistance band',
    ipa: '/rɪˈzɪstəns bænd/',
    vi: 'dây kháng lực',
    exampleEn: 'Use a resistance band to warm up.',
    exampleVi: 'Dùng dây kháng lực để khởi động.',
  ),
  GymWord(
    en: 'treadmill',
    ipa: '/ˈtredmɪl/',
    vi: 'máy chạy bộ',
    exampleEn: 'I run on the treadmill for ten minutes.',
    exampleVi: 'Tôi chạy máy 10 phút.',
    groups: {MuscleGroup.cardio},
  ),
  GymWord(
    en: 'pull-up bar',
    ipa: '/ˈpʊl ʌp bɑːr/',
    vi: 'xà đơn',
    exampleEn: 'Hang from the pull-up bar.',
    exampleVi: 'Treo người trên xà đơn.',
    groups: {MuscleGroup.back, MuscleGroup.arms},
  ),

  // Dong tu chuyen dong.
  GymWord(
    en: 'squat',
    ipa: '/skwɑːt/',
    vi: 'ngồi xuống (gánh đùi)',
    exampleEn: 'Squat until your thighs are parallel to the floor.',
    exampleVi: 'Ngồi xuống đến khi đùi song song mặt sàn.',
    groups: {MuscleGroup.legs},
  ),
  GymWord(
    en: 'lunge',
    ipa: '/lʌndʒ/',
    vi: 'bước chùng chân',
    exampleEn: 'Lunge forward with your right leg.',
    exampleVi: 'Bước chùng chân phải về phía trước.',
    groups: {MuscleGroup.legs},
  ),
  GymWord(
    en: 'hip hinge',
    ipa: '/hɪp hɪndʒ/',
    vi: 'gập người tại hông',
    exampleEn: 'A deadlift starts with a hip hinge.',
    exampleVi: 'Deadlift bắt đầu bằng động tác gập hông.',
    groups: {MuscleGroup.legs, MuscleGroup.back},
  ),
  GymWord(
    en: 'press',
    ipa: '/pres/',
    vi: 'đẩy (tạ) lên',
    exampleEn: 'Press the dumbbells over your head.',
    exampleVi: 'Đẩy tạ đơn lên qua đầu.',
    groups: {MuscleGroup.chest, MuscleGroup.shoulders},
  ),
  GymWord(
    en: 'push',
    ipa: '/pʊʃ/',
    vi: 'đẩy',
    exampleEn: 'Push the floor away from you.',
    exampleVi: 'Đẩy mạnh sàn ra xa người.',
    groups: {MuscleGroup.chest},
  ),
  GymWord(
    en: 'pull',
    ipa: '/pʊl/',
    vi: 'kéo',
    exampleEn: 'Pull your elbows down and back.',
    exampleVi: 'Kéo khuỷu tay xuống và ra sau.',
    groups: {MuscleGroup.back},
  ),
  GymWord(
    en: 'row',
    ipa: '/roʊ/',
    vi: 'kéo (tạ) về phía thân, như chèo thuyền',
    exampleEn: 'Row the bar to your belly.',
    exampleVi: 'Kéo thanh tạ về phía bụng.',
    groups: {MuscleGroup.back},
  ),
  GymWord(
    en: 'curl',
    ipa: '/kɜːrl/',
    vi: 'cuộn tạ (gập khuỷu tay)',
    exampleEn: 'Curl the weight up slowly.',
    exampleVi: 'Cuộn tạ lên từ từ.',
    groups: {MuscleGroup.arms},
  ),
  GymWord(
    en: 'extend',
    ipa: '/ɪkˈstend/',
    vi: 'duỗi thẳng',
    exampleEn: 'Extend your arms fully.',
    exampleVi: 'Duỗi thẳng hoàn toàn hai tay.',
    groups: {MuscleGroup.arms},
  ),
  GymWord(
    en: 'raise',
    ipa: '/reɪz/',
    vi: 'nâng lên',
    exampleEn: 'Raise your arms to shoulder height.',
    exampleVi: 'Nâng tay lên ngang vai.',
    groups: {MuscleGroup.shoulders},
  ),
  GymWord(
    en: 'lower',
    ipa: '/ˈloʊər/',
    vi: 'hạ xuống',
    exampleEn: 'Lower the bar to your chest.',
    exampleVi: 'Hạ thanh tạ xuống ngực.',
  ),
  GymWord(
    en: 'hold',
    ipa: '/hoʊld/',
    vi: 'giữ nguyên',
    exampleEn: 'Hold this position for two seconds.',
    exampleVi: 'Giữ tư thế này 2 giây.',
  ),
  GymWord(
    en: 'squeeze',
    ipa: '/skwiːz/',
    vi: 'siết (cơ)',
    exampleEn: 'Squeeze your glutes at the top.',
    exampleVi: 'Siết cơ mông ở điểm cao nhất.',
  ),
  GymWord(
    en: 'crunch',
    ipa: '/krʌntʃ/',
    vi: 'gập bụng',
    exampleEn: 'Do twenty crunches on the mat.',
    exampleVi: 'Gập bụng 20 lần trên thảm.',
    groups: {MuscleGroup.core},
  ),
  GymWord(
    en: 'plank',
    ipa: '/plæŋk/',
    vi: 'tư thế plank (chống tay giữ thân thẳng)',
    exampleEn: 'Hold a plank for thirty seconds.',
    exampleVi: 'Giữ plank 30 giây.',
    groups: {MuscleGroup.core},
  ),
  GymWord(
    en: 'twist',
    ipa: '/twɪst/',
    vi: 'xoay người',
    exampleEn: 'Twist your body to the left.',
    exampleVi: 'Xoay người sang trái.',
    groups: {MuscleGroup.core},
  ),
  GymWord(
    en: 'jump',
    ipa: '/dʒʌmp/',
    vi: 'nhảy',
    exampleEn: 'Jump as high as you can.',
    exampleVi: 'Nhảy cao hết mức có thể.',
    groups: {MuscleGroup.cardio, MuscleGroup.functional},
  ),
  GymWord(
    en: 'sprint',
    ipa: '/sprɪnt/',
    vi: 'chạy nước rút',
    exampleEn: 'Sprint for twenty seconds, then walk.',
    exampleVi: 'Chạy nước rút 20 giây rồi đi bộ.',
    groups: {MuscleGroup.cardio},
  ),

  // Nhom co + the luc.
  GymWord(
    en: 'chest',
    ipa: '/tʃest/',
    vi: 'ngực',
    exampleEn: 'Today is chest day.',
    exampleVi: 'Hôm nay là ngày tập ngực.',
    groups: {MuscleGroup.chest},
  ),
  GymWord(
    en: 'shoulder',
    ipa: '/ˈʃoʊldər/',
    vi: 'vai',
    exampleEn: 'Keep your shoulders down and relaxed.',
    exampleVi: 'Giữ vai hạ xuống và thả lỏng.',
    groups: {MuscleGroup.shoulders},
  ),
  GymWord(
    en: 'biceps',
    ipa: '/ˈbaɪseps/',
    vi: 'cơ tay trước (bắp tay)',
    exampleEn: 'Curls work your biceps.',
    exampleVi: 'Bài cuộn tạ tác động lên cơ tay trước.',
    groups: {MuscleGroup.arms},
  ),
  GymWord(
    en: 'triceps',
    ipa: '/ˈtraɪseps/',
    vi: 'cơ tay sau',
    exampleEn: 'Dips are great for your triceps.',
    exampleVi: 'Bài dips rất tốt cho cơ tay sau.',
    groups: {MuscleGroup.arms},
  ),
  GymWord(
    en: 'forearm',
    ipa: '/ˈfɔːrɑːrm/',
    vi: 'cẳng tay',
    exampleEn: 'My forearms get tired when I hold heavy weights.',
    exampleVi: 'Cẳng tay tôi mỏi khi cầm tạ nặng.',
    groups: {MuscleGroup.arms},
  ),
  GymWord(
    en: 'lats',
    ipa: '/læts/',
    vi: 'cơ xô (lưng rộng)',
    exampleEn: 'Pull-ups build wide lats.',
    exampleVi: 'Hít xà giúp cơ xô rộng ra.',
    groups: {MuscleGroup.back},
  ),
  GymWord(
    en: 'lower back',
    ipa: '/ˈloʊər bæk/',
    vi: 'lưng dưới',
    exampleEn: "Don't round your lower back.",
    exampleVi: 'Đừng cong lưng dưới.',
    groups: {MuscleGroup.back},
  ),
  GymWord(
    en: 'abs',
    ipa: '/æbz/',
    vi: 'cơ bụng',
    exampleEn: 'Planks make your abs stronger.',
    exampleVi: 'Plank giúp cơ bụng khỏe hơn.',
    groups: {MuscleGroup.core},
  ),
  GymWord(
    en: 'core',
    ipa: '/kɔːr/',
    vi: 'nhóm cơ lõi (bụng, lưng dưới)',
    exampleEn: 'A strong core protects your back.',
    exampleVi: 'Cơ lõi khỏe giúp bảo vệ lưng.',
    groups: {MuscleGroup.core},
  ),
  GymWord(
    en: 'glutes',
    ipa: '/ɡluːts/',
    vi: 'cơ mông',
    exampleEn: 'Hip thrusts target the glutes.',
    exampleVi: 'Hip thrust tác động vào cơ mông.',
    groups: {MuscleGroup.legs},
  ),
  GymWord(
    en: 'quads',
    ipa: '/kwɑːdz/',
    vi: 'cơ đùi trước',
    exampleEn: 'Squats burn my quads.',
    exampleVi: 'Squat làm đùi trước tôi nóng rát.',
    groups: {MuscleGroup.legs},
  ),
  GymWord(
    en: 'hamstrings',
    ipa: '/ˈhæmstrɪŋz/',
    vi: 'cơ đùi sau',
    exampleEn: 'Stretch your hamstrings after deadlifts.',
    exampleVi: 'Giãn cơ đùi sau sau khi deadlift.',
    groups: {MuscleGroup.legs},
  ),
  GymWord(
    en: 'calves',
    ipa: '/kævz/',
    vi: 'bắp chân',
    exampleEn: 'Rise onto your toes to train your calves.',
    exampleVi: 'Nhón gót để tập bắp chân.',
    groups: {MuscleGroup.legs},
  ),
  GymWord(
    en: 'heart rate',
    ipa: '/hɑːrt reɪt/',
    vi: 'nhịp tim',
    exampleEn: 'My heart rate is high after running.',
    exampleVi: 'Nhịp tim tôi cao sau khi chạy.',
    groups: {MuscleGroup.cardio},
  ),
  GymWord(
    en: 'endurance',
    ipa: '/ɪnˈdʊrəns/',
    vi: 'sức bền',
    exampleEn: 'Cardio improves your endurance.',
    exampleVi: 'Cardio cải thiện sức bền.',
    groups: {MuscleGroup.cardio, MuscleGroup.fullBody},
  ),
  GymWord(
    en: 'balance',
    ipa: '/ˈbæləns/',
    vi: 'thăng bằng',
    exampleEn: 'Stand on one leg to train your balance.',
    exampleVi: 'Đứng một chân để luyện thăng bằng.',
    groups: {MuscleGroup.functional, MuscleGroup.fullBody},
  ),
];

/// Hop Leitner toi da - tu o hop nay coi nhu "da thuoc", it khi hien lai.
const kGymWordMaxBox = 4;

/// Chon [count] tu cho buoi tap co cac nhom co [groups].
///
/// Uu tien: (1) ten chinh cac bai tap hom nay [exercises], (2) tu thuoc
/// dung nhom co, (3) tu chung. Trong moi muc, tu o hop Leitner THAP hon
/// (chua thuoc/chua gap) len truoc. [random] chi dung de tron thu tu giua
/// cac tu cung muc uu tien + cung hop, cho moi buoi mot chut khac nhau.
List<GymWord> pickGymWords({
  required Iterable<Exercise> exercises,
  required Map<String, int> boxes,
  int count = 5,
  Random? random,
}) {
  final groups = exercises.map((e) => e.muscleGroup).toSet();
  final seen = <String>{};
  final candidates = <({GymWord word, int tier})>[];

  void add(GymWord word, int tier) {
    if (word.en.trim().isEmpty || !seen.add(word.key)) return;
    candidates.add((word: word, tier: tier));
  }

  for (final exercise in exercises) {
    add(GymWord.fromExercise(exercise), 0);
  }
  for (final word in kGymWords) {
    if (word.groups.isEmpty) {
      add(word, 2);
    } else if (word.groups.any(groups.contains)) {
      add(word, 1);
    }
  }

  if (random != null) candidates.shuffle(random);
  // List.sort khong on dinh -> so sanh them chi so goc de giu thu tu da tron.
  final indexed = candidates.indexed.toList()
    ..sort((a, b) {
      final boxA = boxes[a.$2.word.key] ?? 0;
      final boxB = boxes[b.$2.word.key] ?? 0;
      // Tu da thuoc (hop cao nhat) xuong cuoi bat ke muc uu tien.
      final masteredA = boxA >= kGymWordMaxBox ? 1 : 0;
      final masteredB = boxB >= kGymWordMaxBox ? 1 : 0;
      if (masteredA != masteredB) return masteredA - masteredB;
      if (a.$2.tier != b.$2.tier) return a.$2.tier - b.$2.tier;
      if (boxA != boxB) return boxA - boxB;
      return a.$1 - b.$1;
    });
  return indexed.take(count).map((e) => e.$2.word).toList();
}

/// Tien do hoc tu gym theo kieu hop Leitner (0..[kGymWordMaxBox]) - luu
/// tren may (SharedPreferences) vi chi la thu tu uu tien hien the, khong can
/// dong bo nhieu thiet bi. Day la ban toi gian; SRS co lich on theo ngay se
/// thay the o giai doan sau.
class GymVocabProgress {
  GymVocabProgress._(this._boxes);

  static const _prefKey = 'fitness_gym_vocab_boxes';

  final Map<String, int> _boxes;
  Map<String, int> get boxes => Map.unmodifiable(_boxes);

  static Future<GymVocabProgress> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw == null) return GymVocabProgress._({});
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return GymVocabProgress._({
        for (final e in decoded.entries)
          if (e.value is int) e.key: e.value as int,
      });
    } catch (_) {
      // Du lieu hong/khong doc duoc -> bat dau lai, khong chan buoi tap.
      return GymVocabProgress._({});
    }
  }

  int boxOf(GymWord word) => _boxes[word.key] ?? 0;

  /// "Da nho" -> len 1 hop.
  Future<void> markKnown(GymWord word) {
    _boxes[word.key] = min(boxOf(word) + 1, kGymWordMaxBox);
    return _save();
  }

  /// "Chua nho" -> ve hop 0 de hien lai som.
  Future<void> markLearning(GymWord word) {
    _boxes[word.key] = 0;
    return _save();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, jsonEncode(_boxes));
    } catch (_) {}
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_language.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';

/// Thu vien bai tap the duc tai nha co ban - noi dung TU BIEN SOAN (khong
/// sao chep tu bat ky app/nguon nao khac), chi dung kien thuc pho thong ve
/// cac dong tac bodyweight quen thuoc. Day la tinh nang doc lap voi phan
/// hoc tieng Anh, gop chung 1 app cho tien dung.
/// Kieu chuyen dong dac trung cua bai tap - dung de chon animation minh hoa
/// dung dang tac (xem exercise_animation.dart), thay vi 1 animation chung
/// chung cho moi bai.
enum ExerciseMovement {
  squat, // gap goi len xuong (squat, wall sit...)
  lunge, // buoc chan truoc/sau, gap goi so le
  pushUp, // chong tay, day nguoi len xuong
  plank, // giu than nguoi thang, gan nhu tinh
  crunch, // gap bung, nang vai/dau khoi san
  twist, // xoay than tren sang 2 ben
  jump, // bat nhay tai cho
  raise, // nang tay/chan len xuong (khong gap nguoi)
  bridge, // nang hong len xuong khi nam ngua
  climber, // luan phien keo goi len nguc (mountain climber kieu)
  kick, // da chan ra sau/ngang
}

class Exercise {
  const Exercise({
    required this.name,
    required this.nameEn,
    required this.instructionsVi,
    required this.sets,
    required this.movement,
    this.reps,
    this.workSeconds,
    this.restSeconds = 20,
  }) : assert(
         reps != null || workSeconds != null,
         'Phai co it nhat reps hoac workSeconds',
       );

  final String name;
  final String nameEn;
  final String instructionsVi;
  final int sets;
  final ExerciseMovement movement;

  /// So lan lap moi hiep - null neu bai tap tinh theo thoi gian.
  final int? reps;

  /// So giay tap moi hiep - null neu bai tap tinh theo so lan lap.
  final int? workSeconds;

  /// So giay nghi giua cac hiep.
  final int restSeconds;

  bool get isTimeBased => workSeconds != null;
}

class MuscleGroup {
  const MuscleGroup({
    required this.name,
    required this.nameEn,
    required this.icon,
    required this.color,
    required this.exercises,
  });

  final String name;
  final String nameEn;
  final IconData icon;
  final Color color;
  final List<Exercise> exercises;
}

const kMuscleGroups = <MuscleGroup>[
  MuscleGroup(
    name: 'Tay',
    nameEn: 'Arms',
    icon: Icons.fitness_center_rounded,
    color: AppColors.blue,
    exercises: [
      Exercise(
        name: 'Chống đẩy',
        nameEn: 'Push-up',
        instructionsVi:
            'Chống 2 tay rộng bằng vai, giữ thân người thẳng như 1 tấm ván, '
            'hạ ngực gần sát sàn rồi đẩy thẳng tay trở lại vị trí ban đầu.',
        sets: 3,
        movement: ExerciseMovement.pushUp,
        reps: 12,
      ),
      Exercise(
        name: 'Gập tay sau ghế',
        nameEn: 'Tricep dips',
        instructionsVi:
            'Ngồi trên mép ghế, 2 tay chống xuống mép ghế phía sau lưng, '
            'hạ người xuống bằng cách gập khuỷu tay rồi đẩy người lên lại.',
        sets: 3,
        movement: ExerciseMovement.pushUp,
        reps: 10,
      ),
      Exercise(
        name: 'Chạm vai plank',
        nameEn: 'Plank shoulder taps',
        instructionsVi:
            'Giữ tư thế plank cao (chống thẳng 2 tay), luân phiên dùng 1 tay '
            'chạm vào vai đối diện trong khi vẫn giữ hông ổn định không lắc.',
        sets: 3,
        movement: ExerciseMovement.plank,
        reps: 20,
      ),
      Exercise(
        name: 'Xoay tay',
        nameEn: 'Arm circles',
        instructionsVi:
            'Đứng thẳng, dang 2 tay ngang vai, xoay tròn cánh tay theo vòng '
            'tròn nhỏ liên tục, đổi chiều xoay giữa hiệp.',
        sets: 3,
        movement: ExerciseMovement.raise,
        workSeconds: 30,
      ),
      Exercise(
        name: 'Chống đẩy kim cương',
        nameEn: 'Diamond push-up',
        instructionsVi:
            'Chống đẩy với 2 bàn tay chụm lại thành hình kim cương ngay dưới '
            'ngực - động tác này tập trung nhiều hơn vào cơ tay sau.',
        sets: 3,
        movement: ExerciseMovement.pushUp,
        reps: 8,
      ),
      Exercise(
        name: 'Chống đẩy nghiêng',
        nameEn: 'Incline push-up',
        instructionsVi:
            'Chống 2 tay lên 1 bề mặt cao (ghế, bàn, bậc thang), thân người '
            'thẳng, hạ ngực xuống gần mép rồi đẩy lên - dễ hơn chống đẩy sàn.',
        sets: 3,
        movement: ExerciseMovement.pushUp,
        reps: 15,
      ),
      Exercise(
        name: 'Kéo tư thế Superman',
        nameEn: 'Superman pull',
        instructionsVi:
            'Nằm sấp, đồng thời nâng 2 tay, ngực và 2 chân khỏi sàn, giữ '
            '2 giây rồi hạ xuống - tập cơ lưng dưới và vai kết hợp với tay.',
        sets: 3,
        movement: ExerciseMovement.raise,
        reps: 12,
      ),
      Exercise(
        name: 'Chuyển plank sang chống đẩy',
        nameEn: 'Plank to push-up',
        instructionsVi:
            'Bắt đầu ở plank chống cẳng tay, lần lượt chống thẳng từng tay '
            'lên để chuyển sang tư thế chống đẩy cao, rồi hạ lại từng tay.',
        sets: 3,
        movement: ExerciseMovement.pushUp,
        reps: 10,
      ),
      Exercise(
        name: 'Chống đẩy nhện',
        nameEn: 'Spiderman push-up',
        instructionsVi:
            'Khi hạ người xuống trong chống đẩy, đưa 1 gối ra ngoài chạm về '
            'phía khuỷu tay cùng bên, đẩy lên rồi đổi bên ở lần lặp kế tiếp.',
        sets: 3,
        movement: ExerciseMovement.pushUp,
        reps: 10,
      ),
      Exercise(
        name: 'Chống đẩy vỗ tay',
        nameEn: 'Clap push-up',
        instructionsVi:
            'Hạ người xuống như chống đẩy thường, sau đó đẩy thật mạnh để 2 '
            'tay rời khỏi sàn và vỗ vào nhau trên không trước khi tiếp đất.',
        sets: 3,
        movement: ExerciseMovement.pushUp,
        reps: 8,
      ),
      Exercise(
        name: 'Giữ plank cẳng tay so le tay',
        nameEn: 'Staggered plank hold',
        instructionsVi:
            'Vào tư thế plank chống cẳng tay, đặt 2 khuỷu tay lệch nhau 1 '
            'chút thay vì song song, giữ thân người thẳng và siết chặt tay.',
        sets: 3,
        movement: ExerciseMovement.plank,
        workSeconds: 30,
      ),
      Exercise(
        name: 'Đấm bốc tại chỗ',
        nameEn: 'Shadow boxing punches',
        instructionsVi:
            'Đứng tấn thấp, luân phiên đấm thẳng 2 tay về phía trước thật '
            'nhanh và dứt khoát, thu tay về sát người sau mỗi cú đấm.',
        sets: 3,
        movement: ExerciseMovement.raise,
        workSeconds: 30,
      ),
      Exercise(
        name: 'Chống đẩy chữ T',
        nameEn: 'T push-up',
        instructionsVi:
            'Chống đẩy 1 cái, sau đó xoay thân người sang 1 bên, nâng 1 tay '
            'thẳng lên trần tạo hình chữ T, giữ thăng bằng rồi đổi bên.',
        sets: 3,
        movement: ExerciseMovement.pushUp,
        reps: 8,
      ),
      Exercise(
        name: 'Co duỗi cổ tay',
        nameEn: 'Wrist curls',
        instructionsVi:
            'Quỳ chống 2 tay xuống sàn, các ngón tay hướng về phía gối, nhẹ '
            'nhàng đung đưa trọng lượng cơ thể ra trước sau để làm nóng cổ tay.',
        sets: 3,
        movement: ExerciseMovement.raise,
        workSeconds: 20,
      ),
    ],
  ),
  MuscleGroup(
    name: 'Bụng',
    nameEn: 'Abs',
    icon: Icons.self_improvement_rounded,
    color: AppColors.teal,
    exercises: [
      Exercise(
        name: 'Gập bụng',
        nameEn: 'Crunches',
        instructionsVi:
            'Nằm ngửa, gối co, tay đặt sau đầu, dùng lực cơ bụng nâng phần '
            'vai trên khỏi sàn rồi hạ xuống từ từ, không kéo cổ bằng tay.',
        sets: 3,
        movement: ExerciseMovement.crunch,
        reps: 15,
      ),
      Exercise(
        name: 'Plank giữ thẳng người',
        nameEn: 'Plank',
        instructionsVi:
            'Chống 2 khuỷu tay và mũi chân xuống sàn, giữ toàn bộ cơ thể '
            'thành 1 đường thẳng từ đầu đến gót chân, siết chặt cơ bụng.',
        sets: 3,
        movement: ExerciseMovement.plank,
        workSeconds: 30,
      ),
      Exercise(
        name: 'Nâng chân',
        nameEn: 'Leg raises',
        instructionsVi:
            'Nằm ngửa, 2 chân duỗi thẳng khép lại, dùng cơ bụng dưới nâng '
            'chân lên vuông góc với sàn rồi hạ xuống chậm rãi, không chạm sàn.',
        sets: 3,
        movement: ExerciseMovement.raise,
        reps: 12,
      ),
      Exercise(
        name: 'Gập bụng đạp xe',
        nameEn: 'Bicycle crunches',
        instructionsVi:
            'Nằm ngửa, luân phiên đưa khuỷu tay chạm đầu gối đối diện theo '
            'chuyển động đạp xe đạp trên không, giữ phần lưng dưới ép sàn.',
        sets: 3,
        movement: ExerciseMovement.twist,
        reps: 20,
      ),
      Exercise(
        name: 'Leo núi',
        nameEn: 'Mountain climbers',
        instructionsVi:
            'Vào tư thế plank cao, luân phiên co gối kéo về phía ngực thật '
            'nhanh như đang chạy tại chỗ theo phương ngang.',
        sets: 3,
        movement: ExerciseMovement.climber,
        workSeconds: 30,
      ),
      Exercise(
        name: 'Đá chân bướm',
        nameEn: 'Flutter kicks',
        instructionsVi:
            'Nằm ngửa, nâng nhẹ 2 chân duỗi thẳng khỏi sàn, đá lên xuống '
            'luân phiên liên tục như đang bơi, giữ lưng dưới ép sát sàn.',
        sets: 3,
        movement: ExerciseMovement.raise,
        workSeconds: 30,
      ),
      Exercise(
        name: 'Xoay người kiểu Nga',
        nameEn: 'Russian twist',
        instructionsVi:
            'Ngồi nghiêng người ra sau 1 góc, 2 chân nâng nhẹ khỏi sàn, xoay '
            'thân trên qua trái rồi qua phải luân phiên, tay có thể chắp lại.',
        sets: 3,
        movement: ExerciseMovement.twist,
        reps: 20,
      ),
      Exercise(
        name: 'Bọ chết',
        nameEn: 'Dead bug',
        instructionsVi:
            'Nằm ngửa, tay và gối co vuông góc lên trần, luân phiên duỗi '
            'thẳng 1 tay và chân đối diện gần chạm sàn rồi thu về, đổi bên.',
        sets: 3,
        movement: ExerciseMovement.raise,
        reps: 12,
      ),
      Exercise(
        name: 'Gập bụng chạm gót',
        nameEn: 'Heel touches',
        instructionsVi:
            'Nằm ngửa, gối co và mở rộng, nâng nhẹ vai khỏi sàn, luân phiên '
            'nghiêng người sang 2 bên để tay chạm vào gót chân cùng bên.',
        sets: 3,
        movement: ExerciseMovement.crunch,
        reps: 20,
      ),
      Exercise(
        name: 'Plank chạm chân',
        nameEn: 'Plank toe taps',
        instructionsVi:
            'Giữ tư thế plank cao, đưa 1 chân sang ngang chạm mũi chân xuống '
            'sàn rồi thu về, đổi chân liên tục trong khi giữ hông ổn định.',
        sets: 3,
        movement: ExerciseMovement.plank,
        workSeconds: 30,
      ),
      Exercise(
        name: 'Gập bụng chữ V',
        nameEn: 'V-ups',
        instructionsVi:
            'Nằm ngửa duỗi thẳng tay chân, đồng thời nâng thân trên và 2 '
            'chân lên tạo hình chữ V, tay chạm mũi chân rồi hạ xuống từ từ.',
        sets: 3,
        movement: ExerciseMovement.crunch,
        reps: 10,
      ),
      Exercise(
        name: 'Plank xoay hông',
        nameEn: 'Plank hip dips',
        instructionsVi:
            'Từ plank chống cẳng tay, hạ hông nghiêng chạm nhẹ xuống sàn bên '
            'trái rồi bên phải luân phiên, giữ phần thân trên ổn định.',
        sets: 3,
        movement: ExerciseMovement.twist,
        reps: 16,
      ),
      Exercise(
        name: 'Plank co gối chéo',
        nameEn: 'Cross-body mountain climbers',
        instructionsVi:
            'Ở tư thế plank cao, kéo gối chéo về phía khuỷu tay đối diện '
            'thay vì kéo thẳng, luân phiên 2 bên với nhịp độ vừa phải.',
        sets: 3,
        movement: ExerciseMovement.climber,
        workSeconds: 30,
      ),
      Exercise(
        name: 'Giữ tư thế con thuyền',
        nameEn: 'Boat hold',
        instructionsVi:
            'Ngồi thăng bằng trên xương chậu, nâng 2 chân và ngả nhẹ thân '
            'trên ra sau tạo hình chữ V, giữ tay song song sàn và giữ nguyên.',
        sets: 3,
        movement: ExerciseMovement.plank,
        workSeconds: 25,
      ),
      Exercise(
        name: 'Gập bụng chạm ngón chân',
        nameEn: 'Toe touch crunches',
        instructionsVi:
            'Nằm ngửa, nâng thẳng 2 chân vuông góc sàn, gập bụng nâng vai '
            'lên và vươn tay chạm vào mũi chân rồi hạ xuống chậm rãi.',
        sets: 3,
        movement: ExerciseMovement.crunch,
        reps: 15,
      ),
    ],
  ),
  MuscleGroup(
    name: 'Chân',
    nameEn: 'Legs',
    icon: Icons.directions_run_rounded,
    color: AppColors.amber,
    exercises: [
      Exercise(
        name: 'Squat',
        nameEn: 'Squats',
        instructionsVi:
            'Đứng rộng bằng vai, hạ thấp hông xuống như đang ngồi ghế, giữ '
            'lưng thẳng và đầu gối không vượt quá mũi chân, rồi đứng lên.',
        sets: 3,
        movement: ExerciseMovement.squat,
        reps: 15,
      ),
      Exercise(
        name: 'Chùng chân',
        nameEn: 'Lunges',
        instructionsVi:
            'Bước 1 chân dài về phía trước, hạ gối sau gần chạm sàn, giữ '
            'thân người thẳng, rồi đẩy người trở về đứng thẳng, đổi chân.',
        sets: 3,
        movement: ExerciseMovement.lunge,
        reps: 12,
      ),
      Exercise(
        name: 'Nâng hông',
        nameEn: 'Glute bridge',
        instructionsVi:
            'Nằm ngửa, gối co, bàn chân đặt sàn, siết mông nâng hông lên cao '
            'tạo đường thẳng từ vai đến gối, giữ 1 giây rồi hạ xuống.',
        sets: 3,
        movement: ExerciseMovement.bridge,
        reps: 15,
      ),
      Exercise(
        name: 'Nhón gót',
        nameEn: 'Calf raises',
        instructionsVi:
            'Đứng thẳng, từ từ nhón cao gót chân lên hết cỡ bằng mũi chân, '
            'giữ 1 giây rồi hạ gót xuống chậm rãi.',
        sets: 3,
        movement: ExerciseMovement.raise,
        reps: 20,
      ),
      Exercise(
        name: 'Ngồi tựa tường',
        nameEn: 'Wall sit',
        instructionsVi:
            'Tựa lưng vào tường, hạ người xuống như đang ngồi ghế vô hình '
            'với gối vuông góc 90 độ, giữ nguyên tư thế trong suốt hiệp tập.',
        sets: 3,
        movement: ExerciseMovement.squat,
        workSeconds: 30,
      ),
      Exercise(
        name: 'Squat bật nhảy',
        nameEn: 'Jump squat',
        instructionsVi:
            'Hạ thấp người xuống tư thế squat rồi bật nhảy thẳng lên cao '
            'hết sức, tiếp đất nhẹ nhàng bằng cả bàn chân rồi squat tiếp.',
        sets: 3,
        movement: ExerciseMovement.jump,
        reps: 12,
      ),
      Exercise(
        name: 'Bước lên bậc',
        nameEn: 'Step-up',
        instructionsVi:
            'Dùng 1 bậc thang hoặc ghế thấp chắc chắn, bước 1 chân lên trên '
            'rồi đưa chân kia lên theo, sau đó bước xuống lần lượt, đổi chân.',
        sets: 3,
        movement: ExerciseMovement.lunge,
        reps: 15,
      ),
      Exercise(
        name: 'Chùng chân ngang',
        nameEn: 'Side lunge',
        instructionsVi:
            'Bước 1 chân rộng sang ngang, hạ thấp hông về phía chân đó trong '
            'khi chân kia vẫn duỗi thẳng, rồi đẩy người trở về giữa, đổi bên.',
        sets: 3,
        movement: ExerciseMovement.lunge,
        reps: 12,
      ),
      Exercise(
        name: 'Chùng chân đi bộ',
        nameEn: 'Walking lunges',
        instructionsVi:
            'Bước dài về phía trước hạ thành tư thế chùng chân, sau đó bước '
            'tiếp chân sau lên trước để di chuyển liên tục thay vì lùi lại.',
        sets: 3,
        movement: ExerciseMovement.lunge,
        reps: 16,
      ),
      Exercise(
        name: 'Squat chân sau nâng cao',
        nameEn: 'Bulgarian split squat',
        instructionsVi:
            'Đặt mu bàn chân sau lên ghế thấp phía sau, hạ thấp gối trước '
            'xuống gần vuông góc rồi đẩy lên, giữ thân người thẳng đứng.',
        sets: 3,
        movement: ExerciseMovement.lunge,
        reps: 10,
      ),
      Exercise(
        name: 'Đá chân ra sau',
        nameEn: 'Donkey kicks',
        instructionsVi:
            'Quỳ chống 2 tay và gối, giữ gối co 90 độ, đá 1 chân thẳng lên '
            'trần bằng lực cơ mông, hạ xuống chậm rồi lặp lại, đổi bên.',
        sets: 3,
        movement: ExerciseMovement.kick,
        reps: 15,
      ),
      Exercise(
        name: 'Squat chân hẹp',
        nameEn: 'Narrow squat',
        instructionsVi:
            'Đứng 2 chân sát gần nhau hơn vai, hạ thấp hông xuống giữ lưng '
            'thẳng như squat thường - tập trung nhiều hơn vào đùi trước.',
        sets: 3,
        movement: ExerciseMovement.squat,
        reps: 15,
      ),
      Exercise(
        name: 'Squat chân rộng',
        nameEn: 'Sumo squat',
        instructionsVi:
            'Đứng 2 chân rộng hơn vai, mũi chân hướng chéo ra ngoài, hạ thấp '
            'hông thẳng xuống rồi đứng lên, siết cơ đùi trong và mông.',
        sets: 3,
        movement: ExerciseMovement.squat,
        reps: 15,
      ),
      Exercise(
        name: 'Nâng hông 1 chân',
        nameEn: 'Single-leg glute bridge',
        instructionsVi:
            'Nằm ngửa, 1 chân co bàn chân đặt sàn, chân kia duỗi thẳng lên '
            'trần, siết mông nâng hông lên bằng lực của chân trụ, đổi bên.',
        sets: 3,
        movement: ExerciseMovement.bridge,
        reps: 10,
      ),
      Exercise(
        name: 'Nhảy dây tại chỗ',
        nameEn: 'Jump rope (no rope)',
        instructionsVi:
            'Bật nhảy nhẹ liên tục tại chỗ bằng mũi chân như đang nhảy dây '
            'thật, tay xoay tròn nhẹ nhàng theo nhịp, giữ đầu gối hơi chùng.',
        sets: 3,
        movement: ExerciseMovement.jump,
        workSeconds: 30,
      ),
    ],
  ),
  MuscleGroup(
    name: 'Toàn thân',
    nameEn: 'Full body',
    icon: Icons.sports_gymnastics_rounded,
    color: AppColors.pink,
    exercises: [
      Exercise(
        name: 'Nhảy dang tay chân',
        nameEn: 'Jumping jacks',
        instructionsVi:
            'Bật nhảy đồng thời dang rộng 2 chân và đưa 2 tay lên cao qua '
            'đầu, sau đó nhảy trở lại tư thế đứng thẳng ban đầu liên tục.',
        sets: 3,
        movement: ExerciseMovement.jump,
        workSeconds: 30,
      ),
      Exercise(
        name: 'Burpee',
        nameEn: 'Burpees',
        instructionsVi:
            'Từ tư thế đứng, hạ người xuống chống tay, bật chân ra sau về '
            'tư thế plank, chống đẩy 1 cái, thu chân về rồi bật nhảy lên cao.',
        sets: 3,
        movement: ExerciseMovement.jump,
        reps: 10,
      ),
      Exercise(
        name: 'Chạy nâng cao gối',
        nameEn: 'High knees',
        instructionsVi:
            'Chạy tại chỗ với tốc độ nhanh, cố gắng nâng đầu gối lên cao '
            'ngang hông ở mỗi bước, giữ nhịp thở đều.',
        sets: 3,
        movement: ExerciseMovement.climber,
        workSeconds: 30,
      ),
      Exercise(
        name: 'Nhảy hình sao',
        nameEn: 'Star jumps',
        instructionsVi:
            'Từ tư thế ngồi xổm thấp, bật nhảy thật cao đồng thời dang rộng '
            'tay chân thành hình ngôi sao trên không rồi tiếp đất nhẹ nhàng.',
        sets: 3,
        movement: ExerciseMovement.jump,
        reps: 15,
      ),
      Exercise(
        name: 'Bò kiểu gấu',
        nameEn: 'Bear crawl',
        instructionsVi:
            'Chống 2 tay và mũi chân xuống sàn, nâng gối cách sàn vài cm, '
            'bò về phía trước bằng cách luân phiên di chuyển tay và chân đối '
            'diện.',
        sets: 3,
        movement: ExerciseMovement.plank,
        workSeconds: 30,
      ),
      Exercise(
        name: 'Plank nhảy dang chân',
        nameEn: 'Plank jacks',
        instructionsVi:
            'Giữ tư thế plank cao, bật nhảy nhẹ để dang rộng 2 chân ra rồi '
            'nhảy khép lại liên tục, giữ thân người ổn định không lắc hông.',
        sets: 3,
        movement: ExerciseMovement.jump,
        workSeconds: 30,
      ),
      Exercise(
        name: 'Squat kết hợp đẩy tay',
        nameEn: 'Squat to press',
        instructionsVi:
            'Hạ người xuống tư thế squat, khi đứng lên đồng thời đẩy 2 tay '
            'thẳng lên cao qua đầu, rồi hạ tay xuống khi squat lại lần sau.',
        sets: 3,
        movement: ExerciseMovement.squat,
        reps: 12,
      ),
      Exercise(
        name: 'Sâu đo',
        nameEn: 'Inchworm',
        instructionsVi:
            'Đứng thẳng, cúi gập người xuống chạm sàn, dùng tay bò dần ra '
            'trước tới tư thế plank, giữ 1 giây rồi bò tay ngược lại đứng lên.',
        sets: 3,
        movement: ExerciseMovement.plank,
        reps: 10,
      ),
      Exercise(
        name: 'Squat kết hợp bật lùi',
        nameEn: 'Squat thrust',
        instructionsVi:
            'Từ tư thế đứng, cúi người chống tay xuống sàn, bật 2 chân ra '
            'sau về plank rồi thu chân về ngay và đứng thẳng lên, không nhảy.',
        sets: 3,
        movement: ExerciseMovement.squat,
        reps: 12,
      ),
      Exercise(
        name: 'Nhảy tách chân trước sau',
        nameEn: 'Split jumps',
        instructionsVi:
            'Đứng ở tư thế chùng chân, bật nhảy lên cao và đổi chân trước '
            'sau ngay trên không, tiếp đất nhẹ nhàng ở tư thế chùng chân mới.',
        sets: 3,
        movement: ExerciseMovement.jump,
        reps: 12,
      ),
      Exercise(
        name: 'Leo núi chéo chậm',
        nameEn: 'Slow cross climbers',
        instructionsVi:
            'Ở tư thế plank cao, đưa từng gối chéo về phía khuỷu tay đối '
            'diện thật chậm và có kiểm soát, giữ hông không võng xuống.',
        sets: 3,
        movement: ExerciseMovement.climber,
        reps: 16,
      ),
      Exercise(
        name: 'Plank xoay người',
        nameEn: 'Plank rotation',
        instructionsVi:
            'Từ plank cao, xoay thân người mở sang 1 bên đưa 1 tay thẳng '
            'lên trần thành tư thế chữ T nghiêng, trở về rồi đổi bên.',
        sets: 3,
        movement: ExerciseMovement.twist,
        reps: 10,
      ),
      Exercise(
        name: 'Halo lắc gối',
        nameEn: 'Squat and reach',
        instructionsVi:
            'Hạ người xuống squat thấp, chạm 2 tay xuống sàn giữa 2 chân, '
            'sau đó đứng lên và vươn thẳng 2 tay cao qua đầu hết cỡ.',
        sets: 3,
        movement: ExerciseMovement.squat,
        reps: 12,
      ),
    ],
  ),
  MuscleGroup(
    name: 'Ngực',
    nameEn: 'Chest',
    icon: Icons.favorite_rounded,
    color: AppColors.purple,
    exercises: [
      Exercise(
        name: 'Chống đẩy tay rộng',
        nameEn: 'Wide push-up',
        instructionsVi:
            'Chống đẩy với 2 tay đặt rộng hơn vai khá nhiều, hạ ngực gần sát '
            'sàn để kéo giãn cơ ngực nhiều hơn rồi đẩy thẳng tay trở lại.',
        sets: 3,
        movement: ExerciseMovement.pushUp,
        reps: 12,
      ),
      Exercise(
        name: 'Chống đẩy vỗ ngực',
        nameEn: 'Archer push-up',
        instructionsVi:
            'Chống đẩy với 2 tay đặt rộng, khi hạ người dồn trọng lượng '
            'sang 1 bên tay và duỗi thẳng tay còn lại, đổi bên ở lần sau.',
        sets: 3,
        movement: ExerciseMovement.pushUp,
        reps: 8,
      ),
      Exercise(
        name: 'Ép tay trước ngực',
        nameEn: 'Isometric chest squeeze',
        instructionsVi:
            'Đứng thẳng, 2 tay chắp lại ép chặt vào nhau trước ngực ở độ '
            'cao ngang vai, giữ lực ép liên tục trong suốt thời gian tập.',
        sets: 3,
        movement: ExerciseMovement.plank,
        workSeconds: 20,
      ),
      Exercise(
        name: 'Chống đẩy nảy nhẹ',
        nameEn: 'Pulse push-up',
        instructionsVi:
            'Hạ người xuống nửa chừng của động tác chống đẩy rồi nảy nhẹ '
            'lên xuống vài cm liên tục thay vì đẩy hẳn lên, giữ core chắc.',
        sets: 3,
        movement: ExerciseMovement.pushUp,
        reps: 10,
      ),
      Exercise(
        name: 'Chống đẩy vỗ tay thấp',
        nameEn: 'Decline push-up',
        instructionsVi:
            'Đặt 2 chân lên bề mặt cao (ghế, bậc thang), 2 tay chống sàn, hạ '
            'ngực xuống rồi đẩy lên - dồn tải nhiều hơn vào phần ngực trên.',
        sets: 3,
        movement: ExerciseMovement.pushUp,
        reps: 10,
      ),
      Exercise(
        name: 'Chống đẩy lệch tay',
        nameEn: 'Staggered hand push-up',
        instructionsVi:
            'Đặt 1 tay hơi cao hơn tay kia khi chống đẩy để tạo lực bất '
            'đối xứng lên ngực, hoàn thành hết hiệp rồi đổi vị trí 2 tay.',
        sets: 3,
        movement: ExerciseMovement.pushUp,
        reps: 10,
      ),
      Exercise(
        name: 'Mở rộng ngực nằm sấp',
        nameEn: 'Prone chest opener',
        instructionsVi:
            'Nằm sấp, 2 tay dang ngang thành hình chữ T, nâng nhẹ ngực và '
            'tay khỏi sàn, ép 2 bả vai lại gần nhau rồi hạ xuống.',
        sets: 3,
        movement: ExerciseMovement.raise,
        reps: 12,
      ),
      Exercise(
        name: 'Chống đẩy giữ đáy',
        nameEn: 'Push-up hold at bottom',
        instructionsVi:
            'Hạ người xuống vị trí thấp nhất của chống đẩy, ngực cách sàn '
            'vài cm, giữ nguyên tư thế đó rồi mới đẩy lên hoàn thành 1 lần.',
        sets: 3,
        movement: ExerciseMovement.pushUp,
        reps: 8,
      ),
      Exercise(
        name: 'Chống đẩy chân nâng cao',
        nameEn: 'Feet-elevated push-up',
        instructionsVi:
            'Gác 2 chân lên ghế hoặc bậc cao phía sau, giữ thân thẳng, hạ '
            'ngực xuống gần sàn rồi đẩy lên - khó hơn chống đẩy sàn thường.',
        sets: 3,
        movement: ExerciseMovement.pushUp,
        reps: 8,
      ),
    ],
  ),
  MuscleGroup(
    name: 'Lưng',
    nameEn: 'Back',
    icon: Icons.accessibility_new_rounded,
    color: AppColors.teal,
    exercises: [
      Exercise(
        name: 'Superman',
        nameEn: 'Superman hold',
        instructionsVi:
            'Nằm sấp, đồng thời nâng 2 tay, ngực và 2 chân khỏi sàn thành '
            'hình vòng cung, giữ nguyên tư thế rồi hạ xuống nhẹ nhàng.',
        sets: 3,
        movement: ExerciseMovement.raise,
        workSeconds: 25,
      ),
      Exercise(
        name: 'Bơi ếch trên cạn',
        nameEn: 'Swimmers',
        instructionsVi:
            'Nằm sấp, duỗi thẳng tay chân, luân phiên nâng tay này và chân '
            'đối diện lên khỏi sàn liên tục như đang bơi, giữ nhịp đều.',
        sets: 3,
        movement: ExerciseMovement.raise,
        workSeconds: 30,
      ),
      Exercise(
        name: 'Kéo bả vai',
        nameEn: 'Scapular retraction',
        instructionsVi:
            'Đứng thẳng, 2 tay duỗi thẳng ra trước ngang vai, kéo 2 bả vai '
            'ép sát vào nhau ra sau rồi thả lỏng, lặp lại chậm rãi.',
        sets: 3,
        movement: ExerciseMovement.raise,
        reps: 15,
      ),
      Exercise(
        name: 'Nằm sấp nâng tay chữ Y',
        nameEn: 'Prone Y-raise',
        instructionsVi:
            'Nằm sấp, đưa 2 tay chếch lên thành hình chữ Y, nâng tay và '
            'ngực nhẹ khỏi sàn, giữ 1 giây rồi hạ xuống từ từ.',
        sets: 3,
        movement: ExerciseMovement.raise,
        reps: 12,
      ),
      Exercise(
        name: 'Nằm sấp nâng tay chữ W',
        nameEn: 'Prone W-raise',
        instructionsVi:
            'Nằm sấp, co khuỷu tay gần thân tạo hình chữ W, nâng tay và '
            'ngực khỏi sàn bằng cách ép bả vai lại, giữ rồi hạ xuống.',
        sets: 3,
        movement: ExerciseMovement.raise,
        reps: 12,
      ),
      Exercise(
        name: 'Superman xen kẽ tay chân',
        nameEn: 'Alternating superman',
        instructionsVi:
            'Nằm sấp, luân phiên nâng 1 tay và chân đối diện lên cao rồi hạ '
            'xuống, đổi bên liên tục thay vì nâng cả 4 chi cùng lúc.',
        sets: 3,
        movement: ExerciseMovement.raise,
        reps: 16,
      ),
      Exercise(
        name: 'Chó chim',
        nameEn: 'Bird dog',
        instructionsVi:
            'Quỳ chống 2 tay và gối, duỗi thẳng đồng thời 1 tay và chân đối '
            'diện ra xa hết cỡ, giữ thăng bằng vài giây rồi đổi bên.',
        sets: 3,
        movement: ExerciseMovement.raise,
        reps: 12,
      ),
      Exercise(
        name: 'Cây cầu nâng cao',
        nameEn: 'Bridge pull',
        instructionsVi:
            'Nằm ngửa, gối co bàn chân đặt sàn, nâng hông cao hết mức có '
            'thể thành cây cầu, siết chặt lưng dưới và mông rồi hạ xuống.',
        sets: 3,
        movement: ExerciseMovement.bridge,
        reps: 12,
      ),
      Exercise(
        name: 'Xoay lưng nằm sấp',
        nameEn: 'Prone trunk rotation',
        instructionsVi:
            'Nằm sấp, tay đan sau đầu, nâng nhẹ ngực khỏi sàn và xoay luân '
            'phiên thân trên sang trái rồi sang phải một cách có kiểm soát.',
        sets: 3,
        movement: ExerciseMovement.twist,
        reps: 12,
      ),
    ],
  ),
  MuscleGroup(
    name: 'Vai',
    nameEn: 'Shoulders',
    icon: Icons.airline_seat_flat_rounded,
    color: AppColors.amber,
    exercises: [
      Exercise(
        name: 'Chống đẩy chữ Pike',
        nameEn: 'Pike push-up',
        instructionsVi:
            'Vào tư thế chữ V ngược (hông đẩy cao, tay và chân gần thẳng), '
            'gập khuỷu tay hạ đỉnh đầu gần chạm sàn rồi đẩy lên lại.',
        sets: 3,
        movement: ExerciseMovement.pushUp,
        reps: 10,
      ),
      Exercise(
        name: 'Đi bộ bằng tay',
        nameEn: 'Walkouts',
        instructionsVi:
            'Đứng thẳng, cúi gập người đặt tay xuống sàn, bò tay ra xa dần '
            'tới tư thế plank rồi bò tay ngược lại trở về đứng thẳng.',
        sets: 3,
        movement: ExerciseMovement.plank,
        reps: 10,
      ),
      Exercise(
        name: 'Giữ tư thế chữ T',
        nameEn: 'T-hold',
        instructionsVi:
            'Nằm sấp, dang 2 tay thẳng sang ngang thành hình chữ T, nâng '
            'tay và ngực khỏi sàn, giữ nguyên tư thế trong suốt hiệp tập.',
        sets: 3,
        movement: ExerciseMovement.plank,
        workSeconds: 20,
      ),
      Exercise(
        name: 'Xoay vai lùi',
        nameEn: 'Backward shoulder rolls',
        instructionsVi:
            'Đứng thẳng, đặt đầu ngón tay lên vai, xoay tròn khuỷu tay ra '
            'sau thành vòng tròn lớn liên tục để làm nóng khớp vai.',
        sets: 3,
        movement: ExerciseMovement.raise,
        workSeconds: 20,
      ),
      Exercise(
        name: 'Plank đi bộ vai',
        nameEn: 'Plank shoulder walk',
        instructionsVi:
            'Từ plank chống cẳng tay, lần lượt chống thẳng từng tay lên rồi '
            'hạ lại xuống cẳng tay, luân phiên liên tục để tập vai và tay.',
        sets: 3,
        movement: ExerciseMovement.plank,
        reps: 12,
      ),
      Exercise(
        name: 'Chống đẩy Pike chân cao',
        nameEn: 'Elevated pike push-up',
        instructionsVi:
            'Đặt 2 chân lên ghế thấp, giữ tư thế chữ V ngược, gập khuỷu tay '
            'hạ đầu gần chạm sàn rồi đẩy lên - khó hơn pike push-up thường.',
        sets: 3,
        movement: ExerciseMovement.pushUp,
        reps: 8,
      ),
      Exercise(
        name: 'Nâng tay hình chữ I',
        nameEn: 'Prone I-raise',
        instructionsVi:
            'Nằm sấp, duỗi thẳng 2 tay qua đầu thành hình chữ I, nâng tay '
            'và ngực nhẹ khỏi sàn, giữ 1 giây rồi hạ xuống chậm rãi.',
        sets: 3,
        movement: ExerciseMovement.raise,
        reps: 12,
      ),
      Exercise(
        name: 'Vòng tay số 8',
        nameEn: 'Figure-8 arm swings',
        instructionsVi:
            'Đứng thẳng, dang 1 tay ra vẽ liên tục hình số 8 trên không '
            'trung với biên độ lớn, đổi tay giữa hiệp để tập đều 2 bên vai.',
        sets: 3,
        movement: ExerciseMovement.raise,
        workSeconds: 25,
      ),
    ],
  ),
];

/// Ten nhom co theo ngon ngu giao dien hien tai - giong topicLabel() ben
/// vocabulary_data.dart.
String fitnessGroupLabel(WidgetRef ref, MuscleGroup group) =>
    ref.watch(appLanguageProvider) == AppLanguage.en
    ? group.nameEn
    : group.name;

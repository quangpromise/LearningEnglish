import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_language.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';

/// Thu vien bai tap the duc tai nha co ban - noi dung TU BIEN SOAN (khong
/// sao chep tu bat ky app/nguon nao khac), chi dung kien thuc pho thong ve
/// cac dong tac bodyweight quen thuoc. Day la tinh nang doc lap voi phan
/// hoc tieng Anh, gop chung 1 app cho tien dung.
class Exercise {
  const Exercise({
    required this.name,
    required this.nameEn,
    required this.instructionsVi,
    required this.sets,
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
        reps: 12,
      ),
      Exercise(
        name: 'Gập tay sau ghế',
        nameEn: 'Tricep dips',
        instructionsVi:
            'Ngồi trên mép ghế, 2 tay chống xuống mép ghế phía sau lưng, '
            'hạ người xuống bằng cách gập khuỷu tay rồi đẩy người lên lại.',
        sets: 3,
        reps: 10,
      ),
      Exercise(
        name: 'Chạm vai plank',
        nameEn: 'Plank shoulder taps',
        instructionsVi:
            'Giữ tư thế plank cao (chống thẳng 2 tay), luân phiên dùng 1 tay '
            'chạm vào vai đối diện trong khi vẫn giữ hông ổn định không lắc.',
        sets: 3,
        reps: 20,
      ),
      Exercise(
        name: 'Xoay tay',
        nameEn: 'Arm circles',
        instructionsVi:
            'Đứng thẳng, dang 2 tay ngang vai, xoay tròn cánh tay theo vòng '
            'tròn nhỏ liên tục, đổi chiều xoay giữa hiệp.',
        sets: 3,
        workSeconds: 30,
      ),
      Exercise(
        name: 'Chống đẩy kim cương',
        nameEn: 'Diamond push-up',
        instructionsVi:
            'Chống đẩy với 2 bàn tay chụm lại thành hình kim cương ngay dưới '
            'ngực - động tác này tập trung nhiều hơn vào cơ tay sau.',
        sets: 3,
        reps: 8,
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
        reps: 15,
      ),
      Exercise(
        name: 'Plank giữ thẳng người',
        nameEn: 'Plank',
        instructionsVi:
            'Chống 2 khuỷu tay và mũi chân xuống sàn, giữ toàn bộ cơ thể '
            'thành 1 đường thẳng từ đầu đến gót chân, siết chặt cơ bụng.',
        sets: 3,
        workSeconds: 30,
      ),
      Exercise(
        name: 'Nâng chân',
        nameEn: 'Leg raises',
        instructionsVi:
            'Nằm ngửa, 2 chân duỗi thẳng khép lại, dùng cơ bụng dưới nâng '
            'chân lên vuông góc với sàn rồi hạ xuống chậm rãi, không chạm sàn.',
        sets: 3,
        reps: 12,
      ),
      Exercise(
        name: 'Gập bụng đạp xe',
        nameEn: 'Bicycle crunches',
        instructionsVi:
            'Nằm ngửa, luân phiên đưa khuỷu tay chạm đầu gối đối diện theo '
            'chuyển động đạp xe đạp trên không, giữ phần lưng dưới ép sàn.',
        sets: 3,
        reps: 20,
      ),
      Exercise(
        name: 'Leo núi',
        nameEn: 'Mountain climbers',
        instructionsVi:
            'Vào tư thế plank cao, luân phiên co gối kéo về phía ngực thật '
            'nhanh như đang chạy tại chỗ theo phương ngang.',
        sets: 3,
        workSeconds: 30,
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
        reps: 15,
      ),
      Exercise(
        name: 'Chùng chân',
        nameEn: 'Lunges',
        instructionsVi:
            'Bước 1 chân dài về phía trước, hạ gối sau gần chạm sàn, giữ '
            'thân người thẳng, rồi đẩy người trở về đứng thẳng, đổi chân.',
        sets: 3,
        reps: 12,
      ),
      Exercise(
        name: 'Nâng hông',
        nameEn: 'Glute bridge',
        instructionsVi:
            'Nằm ngửa, gối co, bàn chân đặt sàn, siết mông nâng hông lên cao '
            'tạo đường thẳng từ vai đến gối, giữ 1 giây rồi hạ xuống.',
        sets: 3,
        reps: 15,
      ),
      Exercise(
        name: 'Nhón gót',
        nameEn: 'Calf raises',
        instructionsVi:
            'Đứng thẳng, từ từ nhón cao gót chân lên hết cỡ bằng mũi chân, '
            'giữ 1 giây rồi hạ gót xuống chậm rãi.',
        sets: 3,
        reps: 20,
      ),
      Exercise(
        name: 'Ngồi tựa tường',
        nameEn: 'Wall sit',
        instructionsVi:
            'Tựa lưng vào tường, hạ người xuống như đang ngồi ghế vô hình '
            'với gối vuông góc 90 độ, giữ nguyên tư thế trong suốt hiệp tập.',
        sets: 3,
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
        workSeconds: 30,
      ),
      Exercise(
        name: 'Burpee',
        nameEn: 'Burpees',
        instructionsVi:
            'Từ tư thế đứng, hạ người xuống chống tay, bật chân ra sau về '
            'tư thế plank, chống đẩy 1 cái, thu chân về rồi bật nhảy lên cao.',
        sets: 3,
        reps: 10,
      ),
      Exercise(
        name: 'Chạy nâng cao gối',
        nameEn: 'High knees',
        instructionsVi:
            'Chạy tại chỗ với tốc độ nhanh, cố gắng nâng đầu gối lên cao '
            'ngang hông ở mỗi bước, giữ nhịp thở đều.',
        sets: 3,
        workSeconds: 30,
      ),
      Exercise(
        name: 'Nhảy hình sao',
        nameEn: 'Star jumps',
        instructionsVi:
            'Từ tư thế ngồi xổm thấp, bật nhảy thật cao đồng thời dang rộng '
            'tay chân thành hình ngôi sao trên không rồi tiếp đất nhẹ nhàng.',
        sets: 3,
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
        workSeconds: 30,
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

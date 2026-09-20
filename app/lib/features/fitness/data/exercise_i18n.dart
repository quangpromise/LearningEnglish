/// Xem doc ben duoi.
library;

import '../../../core/i18n/app_language.dart';

/// Dich phan NOI DUNG bai tap sang tieng Anh.
///
/// Khac [AppStrings] (chuoi giao dien: nut, tieu de, thong bao), day la du
/// lieu tinh nam trong `assets/fitness/exercises_seed.json` - von chi co
/// tieng Viet. Thay vi nhet 155 bai vao tu dien giao dien, o day chi map
/// nhung gia tri LAP DI LAP LAI: 17 ten nhom co va 50 loai thiet bi. Ten
/// bai tap khong can map vi file noi dung da co san truong `nameEn`.
///
/// CHUA dich: 466 dong huong dan tung buoc (`instructions`) - nguoi dung
/// chon tieng Anh van thay huong dan tieng Viet o man chi tiet bai tap.
/// Ten nhom co. Cac gia tri trong file noi dung xuat hien o 2 dang: rieng
/// le ("Vai truoc") o `secondaryMuscles`, va kem hau to ("Nguc · chinh") o
/// `primaryMuscle` - [exerciseMuscleLabel] tu tach o dau ' · '.
const _muscleEn = <String, String>{
  'Ngực': 'Chest',
  'Lưng': 'Back',
  'Lưng trên': 'Upper back',
  'Lưng giữa': 'Mid back',
  'Lưng dưới': 'Lower back',
  'Xô': 'Lats',
  'Cầu vai': 'Traps',
  'Vai': 'Shoulders',
  'Vai trước': 'Front delts',
  'Vai giữa': 'Side delts',
  'Vai sau': 'Rear delts',
  'Tay trước': 'Biceps',
  'Tay sau': 'Triceps',
  'Cẳng tay': 'Forearms',
  'Bụng': 'Abs',
  'Mông': 'Glutes',
  'Đùi trước': 'Quads',
  'Đùi sau': 'Hamstrings',
  'Bắp chân': 'Calves',
  'Háng': 'Hip adductors',
  'Toàn thân': 'Full body',
  // Hau to cua `primaryMuscle`.
  'chính': 'primary',
  'phụ': 'secondary',
};

const _equipmentEn = <String, String>{
  'Không thiết bị': 'No equipment',
  'Tạ đòn': 'Barbell',
  'Tạ đòn + ghế': 'Barbell + bench',
  'Tạ đòn + ghế nghiêng': 'Barbell + incline bench',
  'Tạ đòn + ghế dốc': 'Barbell + decline bench',
  'Tạ đòn + giá đỡ': 'Barbell + rack',
  'Tạ đòn + tay cầm chữ T': 'Barbell + T-bar handle',
  'Tạ đơn': 'Dumbbells',
  'Tạ đơn + ghế': 'Dumbbells + bench',
  'Tạ đơn + ghế nghiêng': 'Dumbbells + incline bench',
  'Tạ đơn + ghế dốc': 'Dumbbells + decline bench',
  'Tạ ấm': 'Kettlebell',
  'Tạ cầm tay nặng': 'Heavy carry handles',
  'Thanh EZ': 'EZ bar',
  'Thanh EZ + ghế': 'EZ bar + bench',
  'Thanh đòn cố định': 'Fixed barbell',
  'Ghế Scott + thanh EZ': 'Preacher bench + EZ bar',
  'Máy cáp': 'Cable machine',
  'Máy cáp + dây thừng': 'Cable machine + rope',
  'Máy cáp + ghế': 'Cable machine + bench',
  'Máy tập': 'Machine',
  'Máy đạp đùi': 'Leg press machine',
  'Máy GHR': 'Glute-ham raise machine',
  'Máy chạy bộ': 'Treadmill',
  'Máy elliptical': 'Elliptical',
  'Máy chèo thuyền': 'Rowing machine',
  'Máy leo cầu thang': 'Stair climber',
  'Xe đạp tập': 'Exercise bike',
  'Xe đạp nằm': 'Recumbent bike',
  'Dây nhảy': 'Jump rope',
  'Dây kháng lực': 'Resistance band',
  'Dây/khăn hỗ trợ': 'Strap or towel',
  'Gậy hoặc khăn dài': 'Stick or long towel',
  'Bóng tập': 'Exercise ball',
  'Bục/ghế': 'Box or bench',
  'Ghế': 'Bench',
  'Ghế/bục': 'Bench or box',
  'Ghế dốc': 'Decline bench',
  'Ghế ưỡn lưng': 'Back extension bench',
  'Xà đơn': 'Pull-up bar',
  'Xà kép': 'Parallel bars',
  'Khung kéo tạ': 'Trap bar',
  'Bánh xe tập bụng': 'Ab wheel',
  'Dụng cụ cuốn cổ tay': 'Wrist roller',
  'Đĩa tạ': 'Weight plate',
  'Xe đẩy tạ': 'Sled',
  'Lốp xe tải': 'Tractor tyre',
  'Bao cát': 'Sandbag',
  'Đá tạ': 'Atlas stone',
  'Giàn yoke': 'Yoke',
};

/// Nhan nhom co theo ngon ngu giao dien. Gia tri la nhieu phan ngan cach
/// bang ' · ' (vd "Nguc · chinh") thi dich TUNG PHAN roi ghep lai. Phan nao
/// chua co trong bang thi giu nguyen tieng Viet - hien sai ngon ngu van hon
/// la hien o trong.
String exerciseMuscleLabel(String vi, AppLanguage lang) {
  if (lang != AppLanguage.en) return vi;
  return vi
      .split(' · ')
      .map((part) => _muscleEn[part.trim()] ?? part)
      .join(' · ');
}

/// Nhan thiet bi theo ngon ngu giao dien.
String exerciseEquipmentLabel(String vi, AppLanguage lang) =>
    lang == AppLanguage.en ? (_equipmentEn[vi] ?? vi) : vi;

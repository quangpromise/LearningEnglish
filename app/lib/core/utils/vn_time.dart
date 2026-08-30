/// Tinh toan thoi gian theo GIO VIET NAM (UTC+7) co dinh - khong phu thuoc
/// mui gio dat tren thiet bi (nguoi dung o nuoc ngoai van tinh ngay/gio theo
/// VN cho tinh nang "hoc hom nay", dung voi ky vong cua nguoi dung Viet).
library;

const _vnOffset = Duration(hours: 7);

/// DateTime co CAC TRUONG (year/month/day/hour...) THEO GIO VIET NAM - LUU Y:
/// object nay bi "gan nhan" UTC nhung gia tri cac truong la gio VN, CHI dung
/// de doc year/month/day, KHONG dung de tinh khoang cach thoi gian tuyet doi
/// (dung [nextVnMidnightInstant] cho viec do).
DateTime _vnWallClockNow() => DateTime.now().toUtc().add(_vnOffset);

/// Ngay hom nay theo gio Viet Nam, dang chuoi 'yyyy-MM-dd' - dung de so sanh
/// phat hien sang ngay moi (vd DailyWordsController).
String todayVnIso() {
  final n = _vnWallClockNow();
  return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
}

/// Thoi diem TUYET DOI (dung de so sanh voi DateTime.now() hoac tinh
/// Duration) cua nua dem tiep theo THEO GIO VIET NAM - dung de: (1) dat
/// Timer tu dong reset/ket thuc dung luc sang ngay moi VN, (2) gioi han
/// khong dat lich thong bao nhac qua qua thoi diem nay.
DateTime nextVnMidnightInstant() {
  final vnNow = _vnWallClockNow();
  final vnMidnightTomorrowFields = DateTime.utc(
    vnNow.year,
    vnNow.month,
    vnNow.day + 1,
  );
  return vnMidnightTomorrowFields.subtract(_vnOffset);
}

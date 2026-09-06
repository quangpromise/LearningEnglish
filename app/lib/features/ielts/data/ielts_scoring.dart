/// Quy doi diem tho (so cau dung/40) sang thang diem IELTS 0-9 (buoc 0.5) -
/// CONG THUC XAP XI TUYEN TINH tu viet, KHONG PHAI bang quy doi chinh thuc
/// cua IELTS/British Council/IDP/Cambridge (bang that thay doi nhe theo
/// tung ky thi, khong duoc cong bo day du duoi dang 1 bo so lieu chinh thuc
/// duy nhat). Chi de nguoi dung co cam nhan tuong doi, khong dung de dam
/// bao do chinh xac tuyet doi - xem disclaimer trong ielts_result_screen.dart.
library;

const double kIeltsMinBand = 0.0;
const double kIeltsMaxBand = 9.0;

/// [correct] / [total] -> band 0.0-9.0, lam tron ve boi so cua 0.5.
double rawToBandScore(int correct, int total) {
  if (total <= 0) return kIeltsMinBand;
  final ratio = (correct / total).clamp(0.0, 1.0);
  final raw = kIeltsMinBand + ratio * (kIeltsMaxBand - kIeltsMinBand);
  final rounded = (raw * 2).round() / 2;
  return rounded.clamp(kIeltsMinBand, kIeltsMaxBand);
}

/// Chuan hoa 1 cau tra loi tu do: bo khoang trang dau/cuoi, ha chu thuong,
/// bo dau cau cuoi cau - CO CHU DICH don gian (khong fuzzy-match chinh
/// ta/dong nghia phuc tap) de giu logic minh bach, de nguoi dung hieu vi
/// sao dung/sai.
String _normalizeShortAnswer(String s) =>
    s.trim().toLowerCase().replaceAll(RegExp(r'[.,!?;:]+$'), '');

/// So sanh cau tra loi tu do cua nguoi dung voi danh sach dap an chap nhan
/// duoc (co the co nhieu dang chap nhan, vd ['12', 'twelve']).
bool isShortAnswerCorrect(String userInput, List<String> accepted) => accepted
    .any((a) => _normalizeShortAnswer(a) == _normalizeShortAnswer(userInput));

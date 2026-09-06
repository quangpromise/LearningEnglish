/// Quy doi diem tho (so cau dung) sang thang diem TOEIC 5-495/phan
/// (10-990 tong) - CONG THUC XAP XI TUYEN TINH tu viet, KHONG PHAI bang quy
/// doi chinh thuc cua ETS (bang that la phi tuyen, doc quyen, khong cong bo
/// day du). Chi de nguoi dung co cam nhan tuong doi ve muc diem, khong dung
/// de bao dam do chinh xac tuyet doi - xem toeic_result_screen.dart hien
/// disclaimer ro rang canh diem so.
library;

const int kToeicMinScaledScore = 5;
const int kToeicMaxScaledScore = 495;

/// [correct] / [total] -> diem quy doi 5-495, lam tron den boi so cua 5
/// (giong buoc nhay that cua thang diem TOEIC).
int rawToScaledScore(int correct, int total) {
  if (total <= 0) return kToeicMinScaledScore;
  final ratio = (correct / total).clamp(0.0, 1.0);
  final raw =
      kToeicMinScaledScore +
      ratio * (kToeicMaxScaledScore - kToeicMinScaledScore);
  final rounded = (raw / 5).round() * 5;
  return rounded.clamp(kToeicMinScaledScore, kToeicMaxScaledScore);
}

import 'dart:math';

/// Khoang cach on (ngay) theo hop Leitner: hop 0 on ngay trong hom, hop 1
/// sau 1 ngay, ... hop 5 sau 35 ngay.
const kSrsIntervalsDays = [0, 1, 3, 7, 16, 35];

/// Hop tu duoc coi la "da thuoc" (xep cuoi khi chon tu moi cho buoi tap).
const kSrsMasteredBox = 4;

/// Hop cao nhat (= so phan tu [kSrsIntervalsDays] - 1).
const kSrsMaxBox = 5;

/// 3 muc cham the (spec #70): Quen / Kho / Nho.
enum SrsGrade { forgot, hard, know }

/// Hop moi va so ngay toi lan on ke tiep (tinh tu hom nay):
/// - quen: ve hop 0, on lai ngay trong phien;
/// - kho: giu hop, on lai ngay mai;
/// - nho: len 1 hop, cach theo khoang cua hop moi.
({int box, int days}) nextSchedule(int box, SrsGrade grade) => switch (grade) {
  SrsGrade.forgot => (box: 0, days: 0),
  SrsGrade.hard => (box: box, days: 1),
  SrsGrade.know => () {
    final next = min(box + 1, kSrsMaxBox);
    return (box: next, days: kSrsIntervalsDays[next]);
  }(),
};

/// API cu `review(known:)` = Nho / Quen.
SrsGrade gradeFromKnown({required bool known}) =>
    known ? SrsGrade.know : SrsGrade.forgot;

/// Nhan khoang cach tren nut cham ("Hom nay" / "3 ngay"); [days] la mau
/// co `{n}`.
String intervalLabel(int n, {required String today, required String days}) =>
    n == 0 ? today : days.replaceFirst('{n}', '$n');

/// Hang doi phien on sau khi cham the o [index]: quen -> dua the xuong cuoi
/// de gap lai 1 lan trong phien (khong lap vo han neu quen tiep).
List<T> requeueAfterGrade<T>(
  List<T> queue, {
  required int index,
  required SrsGrade grade,
}) {
  if (grade != SrsGrade.forgot) return queue;
  final card = queue[index];
  if (queue.where((c) => c == card).length > 1) return queue;
  return [...queue, card];
}

/// Huong the bay ra sau khi cham (spec #96, quyet dinh #19): Quen sang
/// trai, Kho xuong duoi, Nho sang phai (vector don vi; quang duong do man
/// hinh quyet dinh).
({double dx, double dy}) flyDirection(SrsGrade grade) => switch (grade) {
  SrsGrade.forgot => (dx: -1, dy: 0),
  SrsGrade.hard => (dx: 0, dy: 1),
  SrsGrade.know => (dx: 1, dy: 0),
};

/// Nhan 1 lan cham khi con the va the hien tai da lat XONG (nut da sang).
/// Bam nhanh nhieu lan: lan dau doi sang the ke tiep (chua lat) nen cac lan
/// sau bi bo qua - khong bao gio cham nham the ke tiep.
bool acceptsGrade({
  required int index,
  required int length,
  required bool revealed,
}) => revealed && index >= 0 && index < length;

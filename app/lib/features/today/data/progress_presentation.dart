/// 1 cot cua bieu do "Tuan nay" o tab Tien do (README §8).
typedef WeekColumn = ({DateTime day, int learnMin, int trainMin});

/// 7 cot (6 ngay truoc -> hom nay) gop giay hoc tieng Anh va giay tap
/// (RPC `my_weekly_activity` nguon 'english' / 'fitness') thanh phut. Khoa
/// ngay co gio van duoc tinh theo ngay; ngay ngoai cua so bi bo qua.
List<WeekColumn> weeklyChart({
  required Map<DateTime, int> learnSeconds,
  required Map<DateTime, int> trainSeconds,
  required DateTime today,
}) {
  DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);
  Map<DateTime, int> byDay(Map<DateTime, int> src) {
    final out = <DateTime, int>{};
    for (final e in src.entries) {
      final k = dayOf(e.key);
      out[k] = (out[k] ?? 0) + e.value;
    }
    return out;
  }

  final learn = byDay(learnSeconds);
  final train = byDay(trainSeconds);
  final end = dayOf(today);
  return [
    for (var i = 6; i >= 0; i--)
      () {
        final day = DateTime(end.year, end.month, end.day - i);
        return (
          day: day,
          learnMin: (learn[day] ?? 0) ~/ 60,
          trainMin: (train[day] ?? 0) ~/ 60,
        );
      }(),
  ];
}

int weeklyTotalMinutes(List<WeekColumn> cols) =>
    cols.fold(0, (sum, c) => sum + c.learnMin + c.trainMin);

({int hours, int minutes}) splitHoursMinutes(int totalMinutes) =>
    (hours: totalMinutes ~/ 60, minutes: totalMinutes % 60);

/// Px moi phut: 1.6 theo thiet ke, thu nho de ngay cao nhat vua [plotHeight].
double chartScale({required int maxDayMinutes, required double plotHeight}) {
  const designScale = 1.6;
  if (maxDayMinutes <= 0) return designScale;
  final fit = plotHeight / maxDayMinutes;
  return fit < designScale ? fit : designScale;
}

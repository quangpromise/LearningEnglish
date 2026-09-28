import 'body_level.dart';

/// % khoi luong tuan nay so voi tuan truoc (lam tron); null khi tuan truoc
/// chua tap (khong co gi de so).
int? volumeChangePercent(double thisWeekKg, double lastWeekKg) {
  if (lastWeekKg <= 0) return null;
  return ((thisWeekKg - lastWeekKg) / lastWeekKg * 100).round();
}

/// Tan, 1 chu so thap phan khi duoi 10 tan ("7.5"), so nguyen tu 10 tan.
String formatTonnes(double kg) {
  final t = kg / 1000;
  if (t == 0) return '0';
  return t >= 10 ? t.toStringAsFixed(0) : t.toStringAsFixed(1);
}

/// Tien do tu bac hien tai toi bac ke tiep (0..1) - theo dieu kien CHAM
/// hon trong 2 dieu kien (so buoi, chuoi tuan) vi phai du ca hai
/// (ADR-0002). Beast = 1.
double bodyLevelProgress(BodyStats stats) {
  final current = bodyLevelFor(stats);
  if (current == BodyLevel.beast) return 1;
  final next = BodyLevel.values[current.index + 1];
  double part(int have, int from, int to) =>
      to <= from ? 1 : ((have - from) / (to - from)).clamp(0.0, 1.0);
  final workouts = part(
    stats.totalWorkouts,
    current.minWorkouts,
    next.minWorkouts,
  );
  final weeks = part(
    stats.bestWeekStreak,
    current.minWeekStreak,
    next.minWeekStreak,
  );
  return workouts < weeks ? workouts : weeks;
}

/// Thanh vach "buoi tap tuan nay": [goal] vach, [done] vach dau to mau.
List<bool> sessionSegments({required int done, required int goal}) => [
  for (var i = 0; i < goal; i++) i < done,
];

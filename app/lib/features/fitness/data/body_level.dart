/// Body Level (CONTEXT.md): bac gym tinh theo DO DEU DAN, khong theo muc
/// ta (ADR-0002). Moc lay theo spec #45; khong bao gio tut vi tinh tu tong
/// so buoi va chuoi tuan DAI NHAT tung dat.
enum BodyLevel {
  rookie(0, 0),
  regular(6, 2),
  athlete(20, 4),
  pro(45, 8),
  beast(90, 16);

  const BodyLevel(this.minWorkouts, this.minWeekStreak);

  final int minWorkouts;
  final int minWeekStreak;
}

/// So buoi toi thieu trong 1 tuan (Thu Hai -> Chu Nhat) de tuan do duoc
/// tinh vao chuoi tuan.
const kWorkoutsPerStreakWeek = 2;

class BodyStats {
  const BodyStats(
    this.totalWorkouts,
    this.bestWeekStreak,
    this.currentWeekStreak,
  );

  final int totalWorkouts;
  final int bestWeekStreak;

  /// Chuoi tuan hien tai - tuan nay chua du buoi thi khong lam dut chuoi.
  final int currentWeekStreak;
}

DateTime _weekStart(DateTime d) {
  final day = DateTime(d.year, d.month, d.day);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}

/// So tuan giua 2 ngay Thu Hai (lam tron de khong lech vi doi gio mua he).
int _weeksBetween(DateTime a, DateTime b) =>
    (b.difference(a).inHours / (24 * 7)).round();

/// Thong ke tu thoi diem hoan thanh cua moi buoi tap (gio may).
BodyStats computeBodyStats(List<DateTime> completed, {required DateTime now}) {
  final perWeek = <DateTime, int>{};
  for (final c in completed) {
    final w = _weekStart(c.toLocal());
    perWeek[w] = (perWeek[w] ?? 0) + 1;
  }
  final counted =
      perWeek.entries
          .where((e) => e.value >= kWorkoutsPerStreakWeek)
          .map((e) => e.key)
          .toList()
        ..sort();

  var best = 0;
  var run = 0;
  DateTime? prev;
  for (final w in counted) {
    run = prev != null && _weeksBetween(prev, w) == 1 ? run + 1 : 1;
    if (run > best) best = run;
    prev = w;
  }

  final thisWeek = _weekStart(now);
  var current = 0;
  if (prev != null) {
    final gap = _weeksBetween(prev, thisWeek);
    // Chuoi ket thuc o tuan nay hoac tuan truoc (tuan nay dang do dang).
    if (gap == 0 || gap == 1) current = run;
  }
  return BodyStats(completed.length, best, current);
}

BodyLevel bodyLevelFor(BodyStats stats) {
  var level = BodyLevel.rookie;
  for (final l in BodyLevel.values) {
    if (stats.totalWorkouts >= l.minWorkouts &&
        stats.bestWeekStreak >= l.minWeekStreak) {
      level = l;
    }
  }
  return level;
}

/// Bac ke tiep va con thieu bao nhieu buoi / tuan; null khi da la Beast.
({BodyLevel level, int workoutsNeeded, int weeksNeeded})? nextBodyTarget(
  BodyStats stats,
) {
  final current = bodyLevelFor(stats);
  if (current == BodyLevel.beast) return null;
  final next = BodyLevel.values[current.index + 1];
  int missing(int need, int have) => need > have ? need - have : 0;
  return (
    level: next,
    workoutsNeeded: missing(next.minWorkouts, stats.totalWorkouts),
    weeksNeeded: missing(next.minWeekStreak, stats.bestWeekStreak),
  );
}

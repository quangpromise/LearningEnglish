import '../../fitness/data/program_model.dart';
import 'daily_progress_store.dart';
import 'shell_presentation.dart';

/// 1 o trong dai chuoi 7 ngay (T2-CN) o the Daily Rings (spec #70).
enum StreakCell { done, missed, today, todayDone, future }

/// Trang thai 7 ngay cua TUAN hien tai: ngay qua da xong Body + Brain = done,
/// chua xong = missed; hom nay = today (todayDone khi da xong); sau hom nay
/// = future.
List<StreakCell> weekStreakStrip(
  DayProgress Function(DateTime day) dayOf,
  DateTime now,
) {
  final today = DateTime(now.year, now.month, now.day);
  final monday = DateTime(
    today.year,
    today.month,
    today.day - (today.weekday - 1),
  );
  return [
    for (var i = 0; i < 7; i++)
      () {
        final day = DateTime(monday.year, monday.month, monday.day + i);
        final done = dayOf(day).bodyBrainDone;
        if (day.isAfter(today)) return StreakCell.future;
        if (day == today) return done ? StreakCell.todayDone : StreakCell.today;
        return done ? StreakCell.done : StreakCell.missed;
      }(),
  ];
}

/// Trang thai the buoi tap hom nay - thay `_PrimaryAction` cu.
enum TodayCardState { loading, error, noPlan, restDay, done, start }

TodayCardState todayCardState({
  required bool loading,
  required bool error,
  required bool hasPlan,
  required bool isRestDay,
  required DayProgress today,
}) {
  if (loading) return TodayCardState.loading;
  if (error) return TodayCardState.error;
  if (!hasPlan) return TodayCardState.noPlan;
  if (isRestDay) return TodayCardState.restDay;
  if (today.workouts >= kDailyTrainGoal) return TodayCardState.done;
  return TodayCardState.start;
}

/// Buoi thu may trong tuan (chi dem ngay tap) cho ngay [weekday] (1=T2).
({int session, int total})? sessionOfWeek(Program program, int weekday) {
  final training = [
    for (final d in program.days)
      if (!d.isRestDay) d.dayOfWeek,
  ]..sort();
  final i = training.indexOf(weekday);
  if (i < 0) return null;
  return (session: i + 1, total: training.length);
}

/// Thoi luong uoc tinh (~1,7 phut/hiep ke ca nghi), lam tron 5, toi thieu 10.
int estimatedMinutes(int totalSets) {
  final rounded = ((totalSets * 1.7) / 5).round() * 5;
  return rounded < 10 ? 10 : rounded;
}

/// % tong Daily Rings (so nguyen 0-100) o giua vong tron.
int ringsPercent(DayProgress day) => (dailyRingsProgress(day) * 100).round();

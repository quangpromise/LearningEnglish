import 'daily_progress_store.dart';

/// Noi Quick Start (nut giua thanh tab) dua nguoi dung toi (CONTEXT.md).
enum QuickStartTarget { todayWorkout, review }

/// Co giao an, khong phai ngay nghi, hom nay chua tap -> buoi tap hom nay;
/// nguoc lai (ke ca chua co giao an) -> on the (spec #70, quyet dinh #12).
/// Chon giao an nam o the buoi tap cua man Hom nay.
QuickStartTarget quickStartTarget({
  required bool hasPlan,
  required bool isRestDay,
  required DayProgress today,
}) {
  if (!hasPlan || isRestDay || today.workouts >= kDailyTrainGoal) {
    return QuickStartTarget.review;
  }
  return QuickStartTarget.todayWorkout;
}

/// % hoan thanh Daily Rings hom nay (trung binh 3 vong) - vong quanh avatar
/// o top bar (ADR-0005: khong con "cap XP").
double dailyRingsProgress(DayProgress day) =>
    (day.trainRatio + day.learnRatio + day.speakRatio) / 3;

/// Chu cai dau cua ten dau va ten cuoi, vd "Nguyễn Văn Tùng" -> "NT".
String nameInitials(String name) {
  final parts = name
      .split(RegExp(r'\s+'))
      .map((p) => p.replaceAll(RegExp(r'[^\p{L}\p{N}]', unicode: true), ''))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  String head(String p) => String.fromCharCode(p.runes.first);
  final first = head(parts.first);
  if (parts.length == 1) return first.toUpperCase();
  return (first + head(parts.last)).toUpperCase();
}

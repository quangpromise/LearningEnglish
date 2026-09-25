import 'daily_progress_store.dart';

/// Noi Quick Start (nut giua thanh tab) dua nguoi dung toi (CONTEXT.md).
enum QuickStartTarget { todayWorkout, review, choosePlan }

/// Chua co giao an -> chon giao an; ngay tap chua tap -> buoi tap hom nay;
/// da tap / ngay nghi -> on the (spec #70).
QuickStartTarget quickStartTarget({
  required bool hasPlan,
  required bool isRestDay,
  required DayProgress today,
}) {
  if (!hasPlan) return QuickStartTarget.choosePlan;
  if (isRestDay || today.workouts >= kDailyTrainGoal) {
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
  final first = parts.first.characters.first;
  if (parts.length == 1) return first.toUpperCase();
  return (first + parts.last.characters.first).toUpperCase();
}

/// Moc chuoi Body + Brain duoc chuc mung (spec #96, ADR-0008).
const kStreakMilestones = [7, 30, 100, 365];

enum MilestoneKind { streak, bodyLevel, rank }

/// 1 Milestone can Celebration. [value]: so ngay chuoi / chi so Body Level
/// (BodyLevel.index) / bac GymTalk Rank moi.
typedef Milestone = ({MilestoneKind kind, int value});

/// Moc da chuc mung (hoac moc goc) tren may nay, theo tai khoan. null = chi
/// so do chua tung duoc ghi nhan (lan dau / may moi / chua tai xong).
class MilestoneRecord {
  const MilestoneRecord({this.streak, this.bodyLevel, this.rank});

  /// Moc chuoi cao nhat da dat (0, 7, 30, 100, 365).
  final int? streak;
  final int? bodyLevel;
  final int? rank;

  factory MilestoneRecord.fromJson(Map<String, dynamic> json) =>
      MilestoneRecord(
        streak: (json['streak'] as num?)?.toInt(),
        bodyLevel: (json['body'] as num?)?.toInt(),
        rank: (json['rank'] as num?)?.toInt(),
      );

  Map<String, dynamic> toJson() => {
    'streak': ?streak,
    'body': ?bodyLevel,
    'rank': ?rank,
  };

  @override
  bool operator ==(Object other) =>
      other is MilestoneRecord &&
      other.streak == streak &&
      other.bodyLevel == bodyLevel &&
      other.rank == rank;

  @override
  int get hashCode => Object.hash(streak, bodyLevel, rank);

  @override
  String toString() =>
      'MilestoneRecord(streak: $streak, body: $bodyLevel, rank: $rank)';
}

/// Moc chuoi cao nhat <= [streak] (0 neu chua toi moc dau).
int streakMarkFor(int streak) =>
    kStreakMilestones.lastWhere((m) => m <= streak, orElse: () => 0);

/// Phat hien Milestone moi (spec #96 quyet dinh #11):
/// - chi so chua co trong ban ghi -> chi lap moc goc, KHONG chuc mung bu;
/// - chuoi vuot moc -> chuc mung tung moc vua vuot (tang dan); chuoi dut
///   (tut duoi moc) -> ha moc trong ban ghi, dat lai thi chuc mung lai;
/// - Body Level / Rank chi chuc mung khi TANG; tut roi len lai khong chuc
///   mung lai.
/// Gia tri dau vao null = chua biet -> giu nguyen phan do cua ban ghi.
/// Thu tu hien: chuoi -> Body Level -> Rank (len Body Level thuong keo
/// Rank len theo).
({List<Milestone> celebrate, MilestoneRecord record}) detectMilestones(
  MilestoneRecord record, {
  int? streak,
  int? bodyLevel,
  int? rank,
}) {
  final celebrate = <Milestone>[];

  var nextStreak = record.streak;
  if (streak != null) {
    final reached = streakMarkFor(streak);
    final known = record.streak;
    if (known != null && reached > known) {
      for (final m in kStreakMilestones) {
        if (m > known && m <= reached) {
          celebrate.add((kind: MilestoneKind.streak, value: m));
        }
      }
    }
    nextStreak = reached;
  }

  int? rise(MilestoneKind kind, int? known, int? now) {
    if (now == null) return known;
    if (known == null) return now;
    if (now > known) {
      celebrate.add((kind: kind, value: now));
      return now;
    }
    return known;
  }

  final nextBody = rise(MilestoneKind.bodyLevel, record.bodyLevel, bodyLevel);
  final nextRank = rise(MilestoneKind.rank, record.rank, rank);
  return (
    celebrate: celebrate,
    record: MilestoneRecord(
      streak: nextStreak,
      bodyLevel: nextBody,
      rank: nextRank,
    ),
  );
}

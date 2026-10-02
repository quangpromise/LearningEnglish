/// Moc chuoi Body + Brain duoc chuc mung (spec #96, ADR-0008).
const kStreakMilestones = [7, 30, 100, 365];

enum MilestoneKind { streak, bodyLevel, rank }

/// 1 Milestone can Celebration. [value]: so ngay chuoi / chi so Body Level
/// (BodyLevel.index) / bac GymTalk Rank moi.
typedef Milestone = ({MilestoneKind kind, int value});

/// Moc da chuc mung (hoac moc goc) tren may nay, theo tai khoan. null = chi
/// so do chua tung duoc ghi nhan (lan dau / may moi / chua tai xong).
class MilestoneRecord {
  const MilestoneRecord({
    this.streak,
    this.streakOn,
    this.bodyLevel,
    this.rank,
  });

  /// Moc chuoi cao nhat da dat (0, 7, 30, 100, 365).
  final int? streak;

  /// Ngay ghi [streak] ('yyyy-mm-dd'): chuoi tut trong CHINH ngay do (vd bo
  /// co ngay nghi sau khi doi giao an) khong ha moc - len lai khong chuc
  /// mung lan 2.
  final String? streakOn;
  final int? bodyLevel;
  final int? rank;

  MilestoneRecord copyWith({
    int? streak,
    String? streakOn,
    int? bodyLevel,
    int? rank,
  }) => MilestoneRecord(
    streak: streak ?? this.streak,
    streakOn: streakOn ?? this.streakOn,
    bodyLevel: bodyLevel ?? this.bodyLevel,
    rank: rank ?? this.rank,
  );

  factory MilestoneRecord.fromJson(Map<String, dynamic> json) =>
      MilestoneRecord(
        streak: (json['streak'] as num?)?.toInt(),
        streakOn: json['streak_on'] as String?,
        bodyLevel: (json['body'] as num?)?.toInt(),
        rank: (json['rank'] as num?)?.toInt(),
      );

  Map<String, dynamic> toJson() => {
    'streak': ?streak,
    'streak_on': ?streakOn,
    'body': ?bodyLevel,
    'rank': ?rank,
  };

  @override
  bool operator ==(Object other) =>
      other is MilestoneRecord &&
      other.streak == streak &&
      other.streakOn == streakOn &&
      other.bodyLevel == bodyLevel &&
      other.rank == rank;

  @override
  int get hashCode => Object.hash(streak, streakOn, bodyLevel, rank);

  @override
  String toString() =>
      'MilestoneRecord(streak: $streak on $streakOn, body: $bodyLevel, '
      'rank: $rank)';
}

/// Moc chuoi cao nhat <= [streak] (0 neu chua toi moc dau).
int streakMarkFor(int streak) =>
    kStreakMilestones.lastWhere((m) => m <= streak, orElse: () => 0);

/// Moc chuoi ma CHINH lan gop du lieu tu may khac lam vuot qua ([rise]: chuoi
/// truoc / sau cac lan gop hom nay); 0 neu lan gop khong vuot moc nao.
int syncedStreakMark(({int from, int to})? rise) {
  if (rise == null) return 0;
  final reached = streakMarkFor(rise.to);
  return reached > streakMarkFor(rise.from) ? reached : 0;
}

/// Ket qua 1 lan kiem. [celebrate]: theo thu tu hien - chuoi -> Body Level
/// -> Rank (len Body Level thuong keo Rank len theo). [base]: ban ghi chi
/// gom phan KHONG chuc mung (moc goc, ha moc, so lieu den tu dong bo) - luu
/// ngay; moi Milestone ghi them bang [applyMilestone] ngay truoc khi hien,
/// de bi ngat giua chung thi lan kiem sau hien tiep phan con lai.
typedef MilestoneCheck = ({List<Milestone> celebrate, MilestoneRecord base});

/// Phat hien Milestone moi (spec #96 quyet dinh #11); [today] la khoa ngay
/// 'yyyy-mm-dd' hien tai:
/// - chi so chua co trong ban ghi -> chi lap moc goc, KHONG chuc mung bu;
/// - chuoi vuot moc -> chuc mung MOC CAO NHAT vua vuot (0 -> 35 ngay: chi
///   "Chuoi 30 ngay"); chuoi dut (tut duoi moc, khac ngay ghi moc) -> ha
///   moc, dat lai thi chuc mung lai;
/// - moc chuoi <= [quietStreakMark] (do du lieu vua gop tu may khac vuot
///   qua - xem [syncedStreakMark]): ghi nhan, khong chuc mung;
/// - Body Level / Rank chi chuc mung khi TANG; tut roi len lai khong chuc
///   mung lai. Ca 2 tinh tu moi may (Body Level do server tinh), nen moc dat
///   o may khac duoc chuc mung 1 lan o may nay (ban ghi theo may, spec #96).
/// Gia tri dau vao null = chua biet -> giu nguyen phan do cua ban ghi.
MilestoneCheck detectMilestones(
  MilestoneRecord record, {
  required String today,
  int? streak,
  int? bodyLevel,
  int? rank,
  int quietStreakMark = 0,
}) {
  final celebrate = <Milestone>[];
  var base = record;

  if (streak != null) {
    final reached = streakMarkFor(streak);
    final known = record.streak;
    if (known != null && reached > known && reached > quietStreakMark) {
      celebrate.add((kind: MilestoneKind.streak, value: reached));
    } else if (known == null ||
        reached > known ||
        (reached < known && record.streakOn != today)) {
      base = base.copyWith(streak: reached, streakOn: today);
    }
  }

  void rise(
    MilestoneKind kind,
    int? known,
    int? now,
    MilestoneRecord Function(int value) write,
  ) {
    if (now == null || (known != null && now <= known)) return;
    if (known == null) {
      base = write(now);
    } else {
      celebrate.add((kind: kind, value: now));
    }
  }

  rise(
    MilestoneKind.bodyLevel,
    record.bodyLevel,
    bodyLevel,
    (v) => base.copyWith(bodyLevel: v),
  );
  rise(MilestoneKind.rank, record.rank, rank, (v) => base.copyWith(rank: v));
  return (celebrate: celebrate, base: base);
}

/// Ghi nhan Milestone [m] (da chuc mung) vao ban ghi.
MilestoneRecord applyMilestone(
  MilestoneRecord record,
  Milestone m, {
  required String today,
}) => switch (m.kind) {
  MilestoneKind.streak => record.copyWith(streak: m.value, streakOn: today),
  MilestoneKind.bodyLevel => record.copyWith(bodyLevel: m.value),
  MilestoneKind.rank => record.copyWith(rank: m.value),
};

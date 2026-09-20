/// Model cho tinh nang Football Center.
///
/// Du lieu KHONG lay truc tiep tu API-Football/Highlightly - app chi doc cac
/// bang `football_*` tren Supabase da duoc 2 Edge Function dong bo san (xem
/// supabase/migrations/0070_football.sql). Nho vay app khong giu API key nao,
/// va nhieu nguoi dung cung xem cung khong ton them quota.
library;

/// 1 giai dau. `slug` la khoa on dinh ('premier-league') dung de tra chuoi
/// i18n; `name` la ten tieng Anh tu nha cung cap.
class FootballCompetition {
  const FootballCompetition({
    required this.id,
    required this.slug,
    required this.name,
    this.countryName,
    this.logoUrl,
    this.currentSeason,
  });

  final int id;
  final String slug;
  final String name;
  final String? countryName;
  final String? logoUrl;
  final int? currentSeason;

  factory FootballCompetition.fromRow(Map<String, dynamic> row) {
    return FootballCompetition(
      id: (row['id'] as num).toInt(),
      slug: row['slug'] as String? ?? '',
      name: row['name'] as String? ?? '',
      countryName: row['country_name'] as String?,
      logoUrl: row['logo_url'] as String?,
      currentSeason: (row['current_season'] as num?)?.toInt(),
    );
  }
}

/// Doi bong - ban rut gon dung o moi cho (hang BXH, the tran dau).
class FootballTeam {
  const FootballTeam({required this.id, required this.name, this.logoUrl});

  final int id;
  final String name;
  final String? logoUrl;

  /// Chu viet tat hien trong huy hieu khi KHONG tai duoc logo. Day khong phai
  /// giai phap tam: logo CLB la nhan hieu rieng cua CLB, khong nha cung cap
  /// du lieu nao cap quyen su dung lai, nen app phai luon co duong lui nay
  /// (xem docs/research-football-standings-source.md).
  ///
  /// "Manchester United" -> "MU", "Liverpool" -> "LIV", "Real Madrid" -> "RM".
  String get initials {
    final words = name
        .split(RegExp(r'[\s-]+'))
        .where((w) => w.isNotEmpty && !_ignoredWords.contains(w.toLowerCase()))
        .toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words.first
          .substring(0, words.first.length.clamp(0, 3))
          .toUpperCase();
    }
    return words.take(3).map((w) => w[0]).join().toUpperCase();
  }

  static const _ignoredWords = {'fc', 'afc', 'cf', 'sc', 'ac', 'club', 'the'};

  factory FootballTeam.fromRow(Map<String, dynamic> row) {
    return FootballTeam(
      id: (row['id'] as num).toInt(),
      name: row['name'] as String? ?? '',
      logoUrl: row['logo_url'] as String?,
    );
  }
}

/// Trang thai tran - gop cac ma ngan cua nha cung cap thanh 3 nhom app quan tam.
enum FixtureState { upcoming, live, finished, postponed }

/// 1 tran dau.
class FootballFixture {
  const FootballFixture({
    required this.id,
    required this.competitionId,
    required this.kickoffAt,
    required this.state,
    this.statusShort,
    this.round,
    this.elapsed,
    this.homeTeam,
    this.awayTeam,
    this.homeGoals,
    this.awayGoals,
    this.venue,
  });

  final int id;
  final int competitionId;

  /// LUON la UTC khi doc tu server. Hien thi phai goi [kickoffLocal].
  final DateTime kickoffAt;
  final FixtureState state;
  final String? statusShort;
  final String? round;
  final int? elapsed;
  final FootballTeam? homeTeam;
  final FootballTeam? awayTeam;
  final int? homeGoals;
  final int? awayGoals;
  final String? venue;

  /// Gio hien cho nguoi dung - doi sang mui gio cua may, dung yeu cau
  /// "timezone hien thi theo timezone cua nguoi dung".
  DateTime get kickoffLocal => kickoffAt.toLocal();

  bool get isLive => state == FixtureState.live;
  bool get hasScore => homeGoals != null && awayGoals != null;
  String get scoreLabel => hasScore ? '$homeGoals - $awayGoals' : '-';

  static FixtureState _stateOf(String? short) {
    switch (short) {
      case '1H':
      case '2H':
      case 'HT':
      case 'ET':
      case 'BT':
      case 'P':
      case 'LIVE':
        return FixtureState.live;
      case 'FT':
      case 'AET':
      case 'PEN':
        return FixtureState.finished;
      case 'PST':
      case 'CANC':
      case 'SUSP':
      case 'ABD':
        return FixtureState.postponed;
      default:
        return FixtureState.upcoming;
    }
  }

  factory FootballFixture.fromRow(Map<String, dynamic> row) {
    final home = row['home'] as Map<String, dynamic>?;
    final away = row['away'] as Map<String, dynamic>?;
    return FootballFixture(
      id: (row['id'] as num).toInt(),
      competitionId: (row['competition_id'] as num?)?.toInt() ?? 0,
      kickoffAt: DateTime.parse(row['kickoff_at'] as String).toUtc(),
      state: _stateOf(row['status_short'] as String?),
      statusShort: row['status_short'] as String?,
      round: row['round'] as String?,
      elapsed: (row['elapsed'] as num?)?.toInt(),
      homeTeam: home == null ? null : FootballTeam.fromRow(home),
      awayTeam: away == null ? null : FootballTeam.fromRow(away),
      homeGoals: (row['home_goals'] as num?)?.toInt(),
      awayGoals: (row['away_goals'] as num?)?.toInt(),
      venue: row['venue'] as String?,
    );
  }
}

/// 1 hang trong bang xep hang.
class FootballStandingRow {
  const FootballStandingRow({
    required this.position,
    required this.team,
    required this.played,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.points,
    this.groupLabel = '',
    this.form,
  });

  final int position;
  final FootballTeam team;
  final int played;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;
  final int points;
  final String groupLabel;

  /// Chuoi 5 ky tu W/D/L, tran CU NHAT dung truoc. Null = chua du du lieu.
  final String? form;

  /// Hieu so - tinh tai cho, khong luu trong DB (2 nha cung cap deu khong tra).
  int get goalDifference => goalsFor - goalsAgainst;

  factory FootballStandingRow.fromRow(Map<String, dynamic> row) {
    return FootballStandingRow(
      position: (row['position'] as num?)?.toInt() ?? 0,
      team: FootballTeam.fromRow(row['team'] as Map<String, dynamic>),
      played: (row['played'] as num?)?.toInt() ?? 0,
      wins: (row['wins'] as num?)?.toInt() ?? 0,
      draws: (row['draws'] as num?)?.toInt() ?? 0,
      losses: (row['losses'] as num?)?.toInt() ?? 0,
      goalsFor: (row['goals_for'] as num?)?.toInt() ?? 0,
      goalsAgainst: (row['goals_against'] as num?)?.toInt() ?? 0,
      points: (row['points'] as num?)?.toInt() ?? 0,
      groupLabel: row['group_label'] as String? ?? '',
      form: row['form'] as String?,
    );
  }
}

/// 1 su kien trong tran (ban thang, the, thay nguoi).
class FootballMatchEvent {
  const FootballMatchEvent({
    required this.eventKey,
    required this.type,
    this.detail,
    this.elapsed,
    this.elapsedExtra,
    this.teamName,
    this.playerName,
    this.assistName,
  });

  final String eventKey;
  final String type;
  final String? detail;
  final int? elapsed;
  final int? elapsedExtra;
  final String? teamName;
  final String? playerName;
  final String? assistName;

  bool get isGoal => type.toLowerCase() == 'goal';
  bool get isRedCard =>
      type.toLowerCase() == 'card' &&
      (detail ?? '').toLowerCase().contains('red');
  bool get isYellowCard =>
      type.toLowerCase() == 'card' &&
      (detail ?? '').toLowerCase().contains('yellow');
  bool get isSubstitution => type.toLowerCase() == 'subst';

  /// "27'" hoac "90+3'".
  String get minuteLabel {
    if (elapsed == null) return '';
    final extra = elapsedExtra;
    return extra != null && extra > 0 ? "$elapsed+$extra'" : "$elapsed'";
  }

  factory FootballMatchEvent.fromRow(Map<String, dynamic> row) {
    return FootballMatchEvent(
      eventKey: row['event_key'] as String? ?? '',
      type: row['type'] as String? ?? '',
      detail: row['detail'] as String?,
      elapsed: (row['elapsed'] as num?)?.toInt(),
      elapsedExtra: (row['elapsed_extra'] as num?)?.toInt(),
      teamName: row['team_name'] as String?,
      playerName: row['player_name'] as String?,
      assistName: row['assist_name'] as String?,
    );
  }
}

/// Doi hinh ra san cua 1 doi trong 1 tran.
class FootballLineup {
  const FootballLineup({
    required this.teamId,
    this.formation,
    this.starters = const [],
    this.substitutes = const [],
    this.coachName,
  });

  final int teamId;
  final String? formation;
  final List<FootballPlayer> starters;
  final List<FootballPlayer> substitutes;
  final String? coachName;

  factory FootballLineup.fromRow(Map<String, dynamic> row) {
    List<FootballPlayer> parse(Object? raw) => (raw as List? ?? const [])
        .map((e) => FootballPlayer.fromJson(e as Map<String, dynamic>))
        .toList();
    return FootballLineup(
      teamId: (row['team_id'] as num).toInt(),
      formation: row['formation'] as String?,
      starters: parse(row['starters']),
      substitutes: parse(row['substitutes']),
      coachName: row['coach_name'] as String?,
    );
  }
}

/// 1 cau thu trong doi hinh. Nha cung cap dat ten truong khong dong nhat giua
/// cac endpoint nen doc theo nhieu kha nang roi lay cai dau tien co gia tri.
class FootballPlayer {
  const FootballPlayer({required this.name, this.number, this.position});

  final String name;
  final int? number;
  final String? position;

  factory FootballPlayer.fromJson(Map<String, dynamic> json) {
    return FootballPlayer(
      name: (json['name'] ?? json['player'] ?? '') as String,
      number: (json['number'] ?? json['shirtNumber'] ?? json['jersey']) is num
          ? ((json['number'] ?? json['shirtNumber'] ?? json['jersey']) as num)
                .toInt()
          : null,
      position: (json['position'] ?? json['pos']) as String?,
    );
  }
}

/// Thong ke cua 1 doi trong 1 tran. Giu nguyen danh sach chi so cua nha cung
/// cap (moi ben tra 1 bo khac nhau) thay vi ep ve cac cot co dinh.
class FootballTeamStats {
  const FootballTeamStats({required this.teamId, required this.entries});

  final int teamId;
  final List<FootballStatEntry> entries;

  factory FootballTeamStats.fromRow(Map<String, dynamic> row) {
    return FootballTeamStats(
      teamId: (row['team_id'] as num).toInt(),
      entries: (row['stats'] as List? ?? const [])
          .map((e) => FootballStatEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FootballStatEntry {
  const FootballStatEntry({required this.name, required this.value});

  final String name;

  /// Giu dang chuoi: co chi so la so ("14"), co chi so la phan tram ("56%"),
  /// co chi so la so thuc (xG "2.05") - ep het ve num se mat thong tin.
  final String value;

  /// Phan so de ve thanh so sanh 2 cot; null neu khong doc duoc ra so.
  double? get numeric {
    final cleaned = value.replaceAll('%', '').trim();
    return double.tryParse(cleaned);
  }

  factory FootballStatEntry.fromJson(Map<String, dynamic> json) {
    final raw = json['value'] ?? json['displayValue'];
    return FootballStatEntry(
      name:
          (json['displayName'] ?? json['name'] ?? json['type'] ?? '') as String,
      value: raw == null ? '-' : '$raw',
    );
  }
}

/// Bat/tat tung loai thong bao. Mac dinh PHAI khop y het cot `default` trong
/// migration 0070 va DEFAULT_PREFS ben Edge Function football-live - lech 1
/// trong 3 cho la nguoi dung nhan thong bao khac voi cai ho thay tren man
/// cai dat.
class FootballNotificationPrefs {
  const FootballNotificationPrefs({
    this.goal = true,
    this.yellowCard = true,
    this.redCard = true,
    this.substitution = false,
    this.matchStarted = true,
    this.halfTime = false,
    this.matchFinished = true,
    this.lineupAvailable = true,
    this.fixtureReminder = true,
  });

  final bool goal;
  final bool yellowCard;
  final bool redCard;
  final bool substitution;
  final bool matchStarted;
  final bool halfTime;
  final bool matchFinished;
  final bool lineupAvailable;
  final bool fixtureReminder;

  FootballNotificationPrefs copyWith({
    bool? goal,
    bool? yellowCard,
    bool? redCard,
    bool? substitution,
    bool? matchStarted,
    bool? halfTime,
    bool? matchFinished,
    bool? lineupAvailable,
    bool? fixtureReminder,
  }) {
    return FootballNotificationPrefs(
      goal: goal ?? this.goal,
      yellowCard: yellowCard ?? this.yellowCard,
      redCard: redCard ?? this.redCard,
      substitution: substitution ?? this.substitution,
      matchStarted: matchStarted ?? this.matchStarted,
      halfTime: halfTime ?? this.halfTime,
      matchFinished: matchFinished ?? this.matchFinished,
      lineupAvailable: lineupAvailable ?? this.lineupAvailable,
      fixtureReminder: fixtureReminder ?? this.fixtureReminder,
    );
  }

  Map<String, dynamic> toRow(String userId) => {
    'user_id': userId,
    'goal': goal,
    'yellow_card': yellowCard,
    'red_card': redCard,
    'substitution': substitution,
    'match_started': matchStarted,
    'half_time': halfTime,
    'match_finished': matchFinished,
    'lineup_available': lineupAvailable,
    'fixture_reminder': fixtureReminder,
  };

  factory FootballNotificationPrefs.fromRow(Map<String, dynamic> row) {
    return FootballNotificationPrefs(
      goal: row['goal'] as bool? ?? true,
      yellowCard: row['yellow_card'] as bool? ?? true,
      redCard: row['red_card'] as bool? ?? true,
      substitution: row['substitution'] as bool? ?? false,
      matchStarted: row['match_started'] as bool? ?? true,
      halfTime: row['half_time'] as bool? ?? false,
      matchFinished: row['match_finished'] as bool? ?? true,
      lineupAvailable: row['lineup_available'] as bool? ?? true,
      fixtureReminder: row['fixture_reminder'] as bool? ?? true,
    );
  }
}

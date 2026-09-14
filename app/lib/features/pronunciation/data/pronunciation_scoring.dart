// Chấm điểm phát âm — logic THUẦN (không phụ thuộc widget/State/mic), tách
// ra khỏi `pronunciation_screen.dart` để test được độc lập (xem
// `pronunciation_scoring_test.dart`) mà không cần mock `speech_to_text`.

// Bo may nhan dien giong noi cua Android thuong "danh may lai" contraction
// theo cach rieng (vd nguoi dung noi "I'm" nhung tra ve "I am") - neu khong
// quy ve cung 1 dang, ca cau se bi lech vi tri va diem luon gan 0% du doc
// dung.
const _contractions = {
  "i'm": 'i am',
  "it's": 'it is',
  "don't": 'do not',
  "can't": 'cannot',
  "won't": 'will not',
  "didn't": 'did not',
  "doesn't": 'does not',
  "isn't": 'is not',
  "aren't": 'are not',
  "wasn't": 'was not',
  "weren't": 'were not',
  "haven't": 'have not',
  "hasn't": 'has not',
  "hadn't": 'had not',
  "you're": 'you are',
  "they're": 'they are',
  "we're": 'we are',
  "i've": 'i have',
  "you've": 'you have',
  "we've": 'we have',
  "they've": 'they have',
  "i'll": 'i will',
  "you'll": 'you will',
  "he'll": 'he will',
  "she'll": 'she will',
  "we'll": 'we will',
  "they'll": 'they will',
  "let's": 'let us',
  "that's": 'that is',
  "who's": 'who is',
  "what's": 'what is',
  "there's": 'there is',
  "here's": 'here is',
};

List<String> normalizeForScoring(String s) {
  final words = s
      .toLowerCase()
      .replaceAll(RegExp(r"[^a-z' ]"), '')
      .split(' ')
      .where((w) => w.isNotEmpty);
  final expanded = <String>[];
  for (final w in words) {
    final mapped = _contractions[w];
    if (mapped != null) {
      expanded.addAll(mapped.split(' '));
    } else {
      expanded.add(w);
    }
  }
  return expanded;
}

/// So khop bang Longest Common Subsequence thay vi doi vi tri tuyet doi -
/// chiu duoc truong hop nguoi noi dung nhung may nhan dien them/bot/doi cho
/// 1 tu (vd nghe nham 1 tu) ma khong lam sai lech toan bo cau con lai.
List<bool> lcsMatch(List<String> target, List<String> said) {
  final n = target.length, m = said.length;
  final dp = List.generate(n + 1, (_) => List.filled(m + 1, 0));
  for (var i = 1; i <= n; i++) {
    for (var j = 1; j <= m; j++) {
      dp[i][j] = target[i - 1] == said[j - 1]
          ? dp[i - 1][j - 1] + 1
          : (dp[i - 1][j] >= dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1]);
    }
  }
  final matched = List.filled(n, false);
  var i = n, j = m;
  while (i > 0 && j > 0) {
    if (target[i - 1] == said[j - 1]) {
      matched[i - 1] = true;
      i--;
      j--;
    } else if (dp[i - 1][j] >= dp[i][j - 1]) {
      i--;
    } else {
      j--;
    }
  }
  return matched;
}

class PronunciationScore {
  const PronunciationScore({
    required this.score,
    required this.targetWords,
    required this.wordResults,
  });

  /// 0-100.
  final int score;
  final List<String> targetWords;

  /// Cung do dai voi [targetWords] - true = tu do duoc nhan dien dung.
  final List<bool> wordResults;
}

/// Muc giong nhau 0..1 giua 2 tu theo chu cai (1 - khoang cach Levenshtein /
/// do dai tu dai hon). Duoi [_minWordSimilarity] coi nhu 2 tu khac han (0) -
/// tranh "noi bua 1 tu bat ky" van duoc diem nho.
double wordSimilarity(String a, String b) {
  if (a == b) return 1;
  if (a.isEmpty || b.isEmpty) return 0;
  var prev = List<int>.generate(b.length + 1, (j) => j);
  for (var i = 1; i <= a.length; i++) {
    final cur = List<int>.filled(b.length + 1, 0)..[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      final del = prev[j] + 1, ins = cur[j - 1] + 1, sub = prev[j - 1] + cost;
      cur[j] = del < ins ? (del < sub ? del : sub) : (ins < sub ? ins : sub);
    }
    prev = cur;
  }
  final longest = a.length > b.length ? a.length : b.length;
  final sim = 1 - prev[b.length] / longest;
  return sim < _minWordSimilarity ? 0 : sim;
}

const _minWordSimilarity = 0.34;

/// Nguong coi 1 tu la "doc dung" (to xanh trong man Luyen phat am).
const kWordCorrectSimilarity = 0.8;

/// Ghep tu mau voi tu nguoi dung noi sao cho TONG muc giong nhau lon nhat
/// (quy hoach dong kieu LCS nhung cho diem tung phan thay vi dung/sai tuyet
/// doi) - tra ve muc giong nhau 0..1 cua tung tu mau. Cho phep 1 tu mau khop
/// voi 2 tu lien nhau duoc ghep lai, vi may nhan dien hay tach 1 tu (vd
/// "sibling" -> "see bling").
List<double> alignWordSimilarities(List<String> target, List<String> said) {
  final n = target.length, m = said.length;
  final dp = List.generate(n + 1, (_) => List<double>.filled(m + 1, 0));
  // 0 = bo qua tu mau, 1 = bo qua tu noi, 2 = khop 1-1, 3 = khop voi 2 tu noi.
  final move = List.generate(n + 1, (_) => List<int>.filled(m + 1, 0));
  for (var i = 1; i <= n; i++) {
    for (var j = 1; j <= m; j++) {
      var best = dp[i - 1][j];
      var mv = 0;
      if (dp[i][j - 1] > best) {
        best = dp[i][j - 1];
        mv = 1;
      }
      final one = dp[i - 1][j - 1] + wordSimilarity(target[i - 1], said[j - 1]);
      if (one > best) {
        best = one;
        mv = 2;
      }
      if (j >= 2) {
        final two =
            dp[i - 1][j - 2] +
            wordSimilarity(target[i - 1], said[j - 2] + said[j - 1]);
        if (two > best) {
          best = two;
          mv = 3;
        }
      }
      dp[i][j] = best;
      move[i][j] = mv;
    }
  }
  final sims = List<double>.filled(n, 0);
  var i = n, j = m;
  while (i > 0 && j > 0) {
    switch (move[i][j]) {
      case 0:
        i--;
      case 1:
        j--;
      case 2:
        sims[i - 1] = wordSimilarity(target[i - 1], said[j - 1]);
        i--;
        j--;
      default:
        sims[i - 1] = wordSimilarity(target[i - 1], said[j - 2] + said[j - 1]);
        i--;
        j -= 2;
    }
  }
  return sims;
}

/// Diem = trung binh muc giong nhau cua tung tu mau (0-100%) - tu doc gan
/// dung van duoc diem mot phan (truoc day so khop dung/sai tuyet doi nen bai
/// 1 tu chi co 0% hoac 100%).
PronunciationScore scorePronunciation({
  required String targetEn,
  required String recognized,
}) {
  final target = normalizeForScoring(targetEn);
  final said = normalizeForScoring(recognized);
  final sims = alignWordSimilarities(target, said);
  final total = sims.fold<double>(0, (a, b) => a + b);
  final score = target.isEmpty ? 0 : ((total / target.length) * 100).round();
  return PronunciationScore(
    score: score,
    targetWords: target,
    wordResults: [for (final v in sims) v >= kWordCorrectSimilarity],
  );
}

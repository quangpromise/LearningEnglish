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

PronunciationScore scorePronunciation({
  required String targetEn,
  required String recognized,
}) {
  final target = normalizeForScoring(targetEn);
  final said = normalizeForScoring(recognized);
  final results = lcsMatch(target, said);
  final correct = results.where((r) => r).length;
  final score = target.isEmpty ? 0 : ((correct / target.length) * 100).round();
  return PronunciationScore(
    score: score,
    targetWords: target,
    wordResults: results,
  );
}

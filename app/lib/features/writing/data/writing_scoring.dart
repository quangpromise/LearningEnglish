// Cham diem Luyen Viet — logic THUAN (khong phu thuoc widget/State), tach
// rieng de test doc lap (xem writing_scoring_test.dart). Feature nay TU CHUA
// ban sao rieng cua thuat toan normalize/LCS (thay vi import tu
// pronunciation_scoring.dart) - dung quy uoc da co cua du an: moi feature tu
// chua code rieng (xem cach TOEIC/IELTS copy doc lap thay vi dung chung 1
// module), tranh phu thuoc cheo giua 2 feature do 2 nhom khac nhau code.

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

List<String> normalizeWritingText(String s) {
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

/// So khop bang Longest Common Subsequence - chiu duoc nguoi dung go
/// thieu/thua/doi cho 1 tu ma khong lam sai lech toan bo cac tu con lai.
List<bool> writingLcsMatch(List<String> target, List<String> typed) {
  final n = target.length, m = typed.length;
  final dp = List.generate(n + 1, (_) => List.filled(m + 1, 0));
  for (var i = 1; i <= n; i++) {
    for (var j = 1; j <= m; j++) {
      dp[i][j] = target[i - 1] == typed[j - 1]
          ? dp[i - 1][j - 1] + 1
          : (dp[i - 1][j] >= dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1]);
    }
  }
  final matched = List.filled(n, false);
  var i = n, j = m;
  while (i > 0 && j > 0) {
    if (target[i - 1] == typed[j - 1]) {
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

/// So sanh 2 chuoi khong phan biet hoa/thuong, tra ve so buoc bien doi it
/// nhat (them/xoa/doi 1 ky tu) de bien chuoi nay thanh chuoi kia - dung de
/// phat hien loi go nham chinh ta gan dung (vd "aple" gan voi "apple").
int levenshteinDistance(String a, String b) {
  final s = a.toLowerCase();
  final t = b.toLowerCase();
  if (s == t) return 0;
  final n = s.length, m = t.length;
  if (n == 0) return m;
  if (m == 0) return n;
  var prev = List.generate(m + 1, (j) => j);
  for (var i = 1; i <= n; i++) {
    final curr = List.filled(m + 1, 0);
    curr[0] = i;
    for (var j = 1; j <= m; j++) {
      final cost = s[i - 1] == t[j - 1] ? 0 : 1;
      final del = prev[j] + 1;
      final ins = curr[j - 1] + 1;
      final sub = prev[j - 1] + cost;
      curr[j] = [del, ins, sub].reduce((a, b) => a < b ? a : b);
    }
    prev = curr;
  }
  return prev[m];
}

/// Ket qua cham 1 tu vung don le - "closeTypo" (gan dung, chi sai chinh ta
/// nhe) tach rieng khoi "wrong" (sai han) de hien phan hoi khac nhau.
enum VocabAnswerResult { correct, closeTypo, wrong }

VocabAnswerResult scoreVocabAnswer(String userInput, String correctEn) {
  final normalizedInput = userInput.trim().toLowerCase().replaceAll(
    RegExp(r'\s+'),
    ' ',
  );
  final normalizedCorrect = correctEn.trim().toLowerCase().replaceAll(
    RegExp(r'\s+'),
    ' ',
  );
  if (normalizedInput.isEmpty) return VocabAnswerResult.wrong;
  if (normalizedInput == normalizedCorrect) return VocabAnswerResult.correct;
  final distance = levenshteinDistance(normalizedInput, normalizedCorrect);
  return distance <= 2 ? VocabAnswerResult.closeTypo : VocabAnswerResult.wrong;
}

class SentenceScore {
  const SentenceScore({
    required this.targetWords,
    required this.wordResults,
    required this.score,
    this.targetText = '',
  });

  /// Cau dap an (nguyen van, chua normalize) da dung de cham - khi cau co
  /// nhieu cach viet dung, day la cach GAN nhat voi cau nguoi dung go.
  final String targetText;

  final List<String> targetWords;

  /// Cung do dai voi [targetWords] - true = tu do nguoi dung go trung khop.
  final List<bool> wordResults;

  /// 0-100.
  final int score;
}

SentenceScore scoreSentence({
  required String targetEn,
  required String userInput,
}) {
  final target = normalizeWritingText(targetEn);
  final typed = normalizeWritingText(userInput);
  final results = writingLcsMatch(target, typed);
  final correct = results.where((r) => r).length;
  final score = target.isEmpty ? 0 : ((correct / target.length) * 100).round();
  return SentenceScore(
    targetWords: target,
    wordResults: results,
    score: score,
    targetText: targetEn,
  );
}

/// Cham voi dap an chinh + cac cach viet dung khac, lay ket qua CAO NHAT
/// (bang diem thi uu tien dap an chinh vi dung truoc trong danh sach).
SentenceScore scoreSentenceBest({
  required String targetEn,
  List<String> alternatives = const [],
  required String userInput,
}) {
  var best = scoreSentence(targetEn: targetEn, userInput: userInput);
  for (final alt in alternatives) {
    final s = scoreSentence(targetEn: alt, userInput: userInput);
    if (s.score > best.score) best = s;
  }
  return best;
}

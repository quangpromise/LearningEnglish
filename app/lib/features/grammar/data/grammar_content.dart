/// Nội dung "bài tập nhanh" cho màn Ngữ pháp. Vì việc phân tích ngữ pháp
/// đúng cho MỌI câu bất kỳ trong lyric đòi hỏi NLP thật (ngoài phạm vi app
/// này — xem agent `grammar-researcher` trong CLAUDE.md), ta nhận diện thì
/// của câu bằng heuristic đơn giản (regex) rồi chọn bộ bài tập tương ứng,
/// thay vì hiển thị cố định 1 ví dụ "Present Continuous" cho MỌI câu như
/// trước đây.
class GrammarQuizQuestion {
  const GrammarQuizQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });
  final String prompt;
  final List<String> options;
  final int correctIndex;
}

class WordBlock {
  const WordBlock(this.label, this.word);
  final String label;
  final String word;
}

class GrammarPoint {
  const GrammarPoint({
    required this.tag,
    required this.formula,
    required this.explanation,
    required this.quizzes,
  });
  final String tag;
  final String formula;
  final String explanation;
  final List<GrammarQuizQuestion> quizzes;
}

const _presentContinuous = GrammarPoint(
  tag: 'PRESENT CONTINUOUS',
  formula: 'S + am/is/are + V-ing',
  explanation:
      'Diễn tả một hành động đang xảy ra ngay tại thời điểm nói, hoặc một '
      'việc đang diễn ra trong giai đoạn hiện tại (chưa chắc đúng ngay '
      'lúc nói).',
  quizzes: [
    GrammarQuizQuestion(
      prompt: 'Chọn câu đúng dùng thì hiện tại tiếp diễn:',
      options: [
        'She stand in the rain now.',
        'She is standing in the rain now.',
        'She stood in the rain now.',
      ],
      correctIndex: 1,
    ),
    GrammarQuizQuestion(
      prompt: 'Câu nào đúng ngữ pháp?',
      options: [
        'They is playing football.',
        'They plays football.',
        'They are playing football.',
      ],
      correctIndex: 2,
    ),
  ],
);

const _pastContinuous = GrammarPoint(
  tag: 'PAST CONTINUOUS',
  formula: 'S + was/were + V-ing',
  explanation:
      'Diễn tả một hành động đang xảy ra tại 1 thời điểm cụ thể trong quá '
      'khứ, thường bị 1 hành động khác (ở thì quá khứ đơn) xen vào.',
  quizzes: [
    GrammarQuizQuestion(
      prompt: 'Chọn câu đúng dùng thì quá khứ tiếp diễn:',
      options: [
        'I was walking home when it started to rain.',
        'I walking home when it started to rain.',
        'I am walking home when it started to rain.',
      ],
      correctIndex: 0,
    ),
    GrammarQuizQuestion(
      prompt: 'Câu nào đúng ngữ pháp?',
      options: [
        'They was singing all night.',
        'They were singing all night.',
        'They sang singing all night.',
      ],
      correctIndex: 1,
    ),
  ],
);

const _pastSimple = GrammarPoint(
  tag: 'PAST SIMPLE',
  formula: 'S + V-ed (hoặc động từ bất quy tắc ở cột 2)',
  explanation:
      'Diễn tả một hành động đã xảy ra và kết thúc hoàn toàn trong quá khứ, '
      'thường đi kèm mốc thời gian xác định (yesterday, last night...).',
  quizzes: [
    GrammarQuizQuestion(
      prompt: 'Chọn câu đúng dùng thì quá khứ đơn:',
      options: [
        'She holded the world with her intent.',
        'She held the world with her intent.',
        'She holds the world with her intent.',
      ],
      correctIndex: 1,
    ),
    GrammarQuizQuestion(
      prompt: 'Câu nào đúng ngữ pháp?',
      options: [
        'We didn\'t knew the answer.',
        'We not knew the answer.',
        'We didn\'t know the answer.',
      ],
      correctIndex: 2,
    ),
  ],
);

const _futureSimple = GrammarPoint(
  tag: 'FUTURE SIMPLE',
  formula: 'S + will + V (nguyên mẫu)',
  explanation:
      'Diễn tả một dự đoán, quyết định tức thời, hoặc lời hứa về tương lai.',
  quizzes: [
    GrammarQuizQuestion(
      prompt: 'Chọn câu đúng dùng thì tương lai đơn:',
      options: [
        'I will finding a way back home.',
        'I will find a way back home.',
        'I finds a way back home.',
      ],
      correctIndex: 1,
    ),
    GrammarQuizQuestion(
      prompt: 'Câu nào đúng ngữ pháp?',
      options: [
        'She will comes tomorrow.',
        'She will come tomorrow.',
        'She wills come tomorrow.',
      ],
      correctIndex: 1,
    ),
  ],
);

const _presentSimple = GrammarPoint(
  tag: 'PRESENT SIMPLE',
  formula: 'S + V(-s/-es với ngôi thứ 3 số ít)',
  explanation:
      'Diễn tả một sự thật hiển nhiên, thói quen, hoặc điều lặp đi lặp lại.',
  quizzes: [
    GrammarQuizQuestion(
      prompt: 'Chọn câu đúng dùng thì hiện tại đơn:',
      options: ['He love music.', 'He loves music.', 'He is love music.'],
      correctIndex: 1,
    ),
    GrammarQuizQuestion(
      prompt: 'Câu nào đúng ngữ pháp?',
      options: [
        'The words you stole doesn\'t save your soul.',
        'The words you stole don\'t saves your soul.',
        'The words you stole won\'t save your soul.',
      ],
      correctIndex: 2,
    ),
  ],
);

final _pastIrregularVerbs = RegExp(
  r'\b(was|were|went|held|felt|knew|held|took|came|saw|said|got|made|left|'
  r'found|thought|told|became|shook|held|stood|stood|stole)\b',
  caseSensitive: false,
);

/// Nhận diện thì của [sentence] bằng heuristic regex đơn giản, kèm word
/// block trích ra được từ chính câu (chỉ áp dụng được cho 2 thì tiếp diễn,
/// nơi cấu trúc S + to-be + V-ing dễ tách bằng regex một cách đáng tin cậy).
class DetectedGrammar {
  const DetectedGrammar(this.point, this.wordBlocks);
  final GrammarPoint point;
  final List<WordBlock> wordBlocks;
}

DetectedGrammar detectGrammar(String sentence) {
  final s = sentence.trim();

  final presentContinuousMatch = RegExp(
    r'^(.*?)\b(am|is|are)\b\s+(\w+ing)\b(.*)$',
    caseSensitive: false,
  ).firstMatch(s);
  if (presentContinuousMatch != null) {
    return DetectedGrammar(
      _presentContinuous,
      _wordBlocksFromMatch(presentContinuousMatch, "To be"),
    );
  }

  final pastContinuousMatch = RegExp(
    r'^(.*?)\b(was|were)\b\s+(\w+ing)\b(.*)$',
    caseSensitive: false,
  ).firstMatch(s);
  if (pastContinuousMatch != null) {
    return DetectedGrammar(
      _pastContinuous,
      _wordBlocksFromMatch(pastContinuousMatch, "To be"),
    );
  }

  if (RegExp(r'\bwill\b', caseSensitive: false).hasMatch(s)) {
    return const DetectedGrammar(_futureSimple, []);
  }

  if (RegExp(r'\w+ed\b', caseSensitive: false).hasMatch(s) ||
      _pastIrregularVerbs.hasMatch(s)) {
    return const DetectedGrammar(_pastSimple, []);
  }

  return const DetectedGrammar(_presentSimple, []);
}

List<WordBlock> _wordBlocksFromMatch(RegExpMatch m, String beLabel) {
  final subject = m.group(1)?.trim() ?? '';
  final be = m.group(2)?.trim() ?? '';
  final ving = m.group(3)?.trim() ?? '';
  final rest = m.group(4)?.trim() ?? '';
  return [
    WordBlock('Chủ ngữ', subject.isEmpty ? 'S' : subject),
    WordBlock(beLabel, be),
    WordBlock('V-ing', ving),
    if (rest.isNotEmpty) WordBlock('Phần còn lại', rest),
  ];
}

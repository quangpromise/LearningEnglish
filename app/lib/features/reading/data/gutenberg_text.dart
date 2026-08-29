/// Cat bo phan header/footer phap ly cua Project Gutenberg (khong phai noi
/// dung sach) truoc khi hien thi de doc, va tach thanh cac doan van. File
/// asset goc van giu nguyen day du header/footer (dung yeu cau giay phep
/// Gutenberg) - chi man doc luot bo phan nay cho de doc.
final _startMarker = RegExp(
  r'\*\*\*\s*START OF (THE|THIS) PROJECT GUTENBERG EBOOK[^\n]*\*\*\*',
  caseSensitive: false,
);
final _endMarker = RegExp(
  r'\*\*\*\s*END OF (THE|THIS) PROJECT GUTENBERG EBOOK[^\n]*\*\*\*',
  caseSensitive: false,
);

List<String> parseBookParagraphs(String raw) {
  var text = raw;
  final startMatch = _startMarker.firstMatch(text);
  if (startMatch != null) text = text.substring(startMatch.end);
  final endMatch = _endMarker.firstMatch(text);
  if (endMatch != null) text = text.substring(0, endMatch.start);

  return text
      .split(RegExp(r'\n\s*\n'))
      .map((p) => p.replaceAll(RegExp(r'\s+'), ' ').trim())
      .where((p) => p.isNotEmpty)
      .toList();
}

/// Tach 1 doan van thanh tung cau (dung de lam ngu canh cho popup dich tu).
List<String> splitSentences(String paragraph) {
  final sentences = paragraph.split(RegExp(r'(?<=[.!?])\s+'));
  return sentences.where((s) => s.trim().isNotEmpty).toList();
}

/// Tach 1 cau thanh tung "token" - hoac la 1 tu (chi chu cai/dau nhay) hoac
/// la khoang trang/dau cau - de biet token nao co the cham vao tra tu.
final _tokenRe = RegExp(r"[A-Za-z']+|[^A-Za-z']+");

List<String> tokenizeSentence(String sentence) =>
    _tokenRe.allMatches(sentence).map((m) => m[0]!).toList();

bool isWordToken(String token) => RegExp(r"^[A-Za-z']+$").hasMatch(token);

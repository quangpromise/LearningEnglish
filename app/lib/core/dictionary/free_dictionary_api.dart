import 'dart:convert';

import 'package:http/http.dart' as http;

class DictionaryEntry {
  const DictionaryEntry({
    required this.ipa,
    required this.partOfSpeech,
    required this.definition,
  });
  final String ipa;
  final String partOfSpeech;
  final String definition;
}

const _posLabels = {
  'noun': 'Danh từ',
  'verb': 'Động từ',
  'adjective': 'Tính từ',
  'adverb': 'Trạng từ',
  'pronoun': 'Đại từ',
  'preposition': 'Giới từ',
  'conjunction': 'Liên từ',
  'interjection': 'Thán từ',
  'determiner': 'Từ hạn định',
  'exclamation': 'Thán từ',
};

String posLabel(String pos) => _posLabels[pos.toLowerCase()] ?? pos;

final _htmlTag = RegExp(r'<[^>]*>');

/// Tra định nghĩa tiếng Anh miễn phí, không cần API key, qua Wiktionary REST
/// API (hạ tầng Wikimedia — ổn định, nhanh hơn hẳn dictionaryapi.dev, vốn
/// đã ngừng hoạt động ổn định — API đó từng trả lỗi 522/timeout ~20s).
class FreeDictionaryApi {
  FreeDictionaryApi._();

  // Cache trong phiên làm việc: nhiều từ trong lyric lặp lại nhiều lần
  // (vd "the", "you"...), tra lại không cần gọi mạng lần nữa -> tức thời.
  static final Map<String, DictionaryEntry?> _cache = {};

  static Future<DictionaryEntry?> lookup(String word) async {
    final key = word.toLowerCase();
    if (_cache.containsKey(key)) return _cache[key];

    final uri = Uri.parse(
      'https://en.wiktionary.org/api/rest_v1/page/definition/${Uri.encodeComponent(key)}',
    );
    final http.Response res;
    try {
      res = await http.get(uri).timeout(const Duration(seconds: 6));
    } catch (_) {
      return null;
    }
    if (res.statusCode != 200) {
      _cache[key] = null;
      return null;
    }

    final data = jsonDecode(res.body);
    final entry = data is Map<String, dynamic> ? _firstDefinition(data) : null;
    _cache[key] = entry;
    return entry;
  }

  static DictionaryEntry? _firstDefinition(Map<String, dynamic> data) {
    final enBlocks = data['en'];
    if (enBlocks is! List) return null;
    for (final block in enBlocks) {
      final m = block as Map<String, dynamic>;
      final pos = m['partOfSpeech']?.toString() ?? '';
      final defs = m['definitions'];
      if (defs is! List) continue;
      for (final d in defs) {
        final raw = (d as Map<String, dynamic>)['definition']?.toString() ?? '';
        final text = raw.replaceAll(_htmlTag, '').trim();
        if (text.isNotEmpty) {
          return DictionaryEntry(ipa: '', partOfSpeech: pos, definition: text);
        }
      }
    }
    return null;
  }
}

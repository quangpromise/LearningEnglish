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

/// Tra định nghĩa/IPA tiếng Anh miễn phí, không cần API key.
/// https://dictionaryapi.dev/ — mã nguồn mở, dữ liệu từ Wiktionary.
class FreeDictionaryApi {
  FreeDictionaryApi._();

  static Future<DictionaryEntry?> lookup(String word) async {
    final uri = Uri.parse(
      'https://api.dictionaryapi.dev/api/v2/entries/en/${Uri.encodeComponent(word)}',
    );
    final http.Response res;
    try {
      res = await http.get(uri).timeout(const Duration(seconds: 8));
    } catch (_) {
      return null;
    }
    if (res.statusCode != 200) return null;

    final data = jsonDecode(res.body);
    if (data is! List || data.isEmpty) return null;
    final entry = data.first as Map<String, dynamic>;

    var ipa = '';
    final phonetics = entry['phonetics'];
    if (phonetics is List) {
      for (final p in phonetics) {
        final text = (p as Map<String, dynamic>)['text'];
        if (text is String && text.isNotEmpty) {
          ipa = text;
          break;
        }
      }
    }
    if (ipa.isEmpty && entry['phonetic'] is String) {
      ipa = entry['phonetic'] as String;
    }

    var pos = '';
    var definition = '';
    final meanings = entry['meanings'];
    if (meanings is List && meanings.isNotEmpty) {
      final firstMeaning = meanings.first as Map<String, dynamic>;
      pos = firstMeaning['partOfSpeech']?.toString() ?? '';
      final defs = firstMeaning['definitions'];
      if (defs is List && defs.isNotEmpty) {
        definition =
            (defs.first as Map<String, dynamic>)['definition']?.toString() ??
            '';
      }
    }
    return DictionaryEntry(ipa: ipa, partOfSpeech: pos, definition: definition);
  }
}

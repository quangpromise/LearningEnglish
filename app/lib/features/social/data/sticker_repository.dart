import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/env.dart';

/// 1 sticker tu GIPHY - [previewUrl] la ban nho/nhe de hien luoi chon (fixed
/// width ~200px), [sendUrl] la ban dung de gui that trong tin nhan (kich
/// thuoc lon hon 1 chut, van la webp/gif nhe vi sticker von la anh nen
/// trong suot, khong phai video).
class StickerResult {
  const StickerResult({required this.previewUrl, required this.sendUrl});
  final String previewUrl;
  final String sendUrl;
}

/// Sticker vui nhon kieu Zalo/Messenger - dung GIPHY Stickers API (mien phi,
/// dang ky tai developers.giphy.com) thay vi tu ve/mua bo sticker rieng.
/// KHONG dung nguyen sticker cua Zalo/Facebook - do la tai san co ban quyen
/// rieng cua ho, xem quy tac ban quyen trong CLAUDE.md.
class StickerRepository {
  static const _base = 'https://api.giphy.com/v1/stickers';

  Future<List<StickerResult>> trending() => _fetch('$_base/trending');

  Future<List<StickerResult>> search(String query) {
    if (query.trim().isEmpty) return trending();
    return _fetch('$_base/search?q=${Uri.encodeQueryComponent(query.trim())}');
  }

  Future<List<StickerResult>> _fetch(String urlWithoutKey) async {
    if (Env.giphyApiKey.isEmpty) return [];
    final sep = urlWithoutKey.contains('?') ? '&' : '?';
    final uri = Uri.parse(
      '$urlWithoutKey${sep}api_key=${Env.giphyApiKey}&limit=30&rating=g',
    );
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return [];
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final data = json['data'] as List? ?? [];
      return data.map((item) {
        final images = (item as Map<String, dynamic>)['images'] as Map;
        final preview = images['fixed_width_small'] ?? images['fixed_width'];
        final full = images['original'] ?? images['fixed_width'];
        return StickerResult(
          previewUrl: preview['url'] as String,
          sendUrl: full['url'] as String,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }
}

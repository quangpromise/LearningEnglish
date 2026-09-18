import 'dart:convert';

import 'package:http/http.dart' as http;

/// 1 session token kem THOI DIEM HET HAN - can ca 2 de tu gia han TRUOC khi
/// token chet (xem SpatiusLiveAvatarState._scheduleTokenRefresh).
class SpatiusSessionToken {
  const SpatiusSessionToken({required this.token, this.expiresAt});

  final String token;

  /// null = proxy ban cu chua tra ve `expiresAt`. Khi do KHONG gia han truoc
  /// duoc, chi con duong phan ung khi SDK bao sessionTokenExpired.
  final DateTime? expiresAt;
}

/// Doi 1 session token ngan han cho Spatius AvatarKit (AvatarSDK.setSessionToken)
/// qua 1 serverless proxy TU VIET (tuong tu anam_vercel_server/) - CHUA co
/// endpoint REST cong khai cua Spatius de doi thang tu app luc viet code nay
/// (SPATIUS_API_KEY phai nam server-side, xem docs.spatius.ai va
/// voice_chat_config.dart/kSpatiusVercelProxyUrl). Proxy tu viet tra ve JSON
/// `{"sessionToken": "...", "expiresAt": <unix giay>}`.
class SpatiusSessionApi {
  SpatiusSessionApi._();

  static Future<SpatiusSessionToken> fetchSessionTokenFromProxy(
    String proxyUrl,
  ) async {
    final res = await http
        .get(Uri.parse(proxyUrl))
        .timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception(
        'Spatius proxy request failed (${res.statusCode}): ${res.body}',
      );
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final token = data['sessionToken'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Spatius proxy response missing sessionToken');
    }
    final expiresAt = data['expiresAt'];
    return SpatiusSessionToken(
      token: token,
      // Uu tien doc han NGAY TRONG token: session token cua Spatius la 1 JWT
      // co san truong `exp`, nen KHONG phu thuoc vao viec proxy da deploy ban
      // moi (co tra `expiresAt`) hay chua - ban proxy dang chay tren Vercel
      // hom nay van dung duoc ngay. `expiresAt` cua proxy chi la duong lui
      // neu sau nay Spatius doi sang token khong phai JWT.
      expiresAt:
          expiryFromJwt(token) ??
          (expiresAt is num
              ? DateTime.fromMillisecondsSinceEpoch(expiresAt.toInt() * 1000)
              : null),
    );
  }

  /// Doc `exp` (unix giay) tu phan payload cua JWT. KHONG xac thuc chu ky -
  /// o day chi can biet khi nao token het han de hen gio gia han, con viec
  /// tin hay khong la do Spatius quyet dinh phia server.
  static DateTime? expiryFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final exp = (payload as Map<String, dynamic>)['exp'];
      if (exp is! num) return null;
      return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
    } catch (_) {
      // Khong phai JWT / payload la o dang khac - bo qua, dung `expiresAt`
      // cua proxy neu co.
      return null;
    }
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;

/// Doi 1 session token ngan han cho Spatius AvatarKit (AvatarSDK.setSessionToken)
/// qua 1 serverless proxy TU VIET (tuong tu anam_vercel_server/) - CHUA co
/// endpoint REST cong khai cua Spatius de doi thang tu app luc viet code nay
/// (SPATIUS_API_KEY phai nam server-side, xem docs.spatius.ai va
/// voice_chat_config.dart/kSpatiusVercelProxyUrl). Proxy tu viet chi can tra
/// ve JSON {"sessionToken": "..."}.
class SpatiusSessionApi {
  SpatiusSessionApi._();

  static Future<String> fetchSessionTokenFromProxy(String proxyUrl) async {
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
    return token;
  }
}

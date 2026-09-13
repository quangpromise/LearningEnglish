import 'dart:convert';

import 'package:http/http.dart' as http;

/// Goi REST API cua Anam.ai de doi 1 API key that lay 1 "session token" ngan
/// han - AnamLiveAvatar dung session token nay de mo ket noi WebRTC toi
/// avatar (khong dua thang API key vao WebView). Xem
/// https://anam.ai/docs/javascript-sdk/examples/custom-tts va
/// voice_chat_config.dart (kUseAnamAvatar) de biet ly do/canh bao bao mat.
class AnamSessionApi {
  AnamSessionApi._();

  static const _endpoint = 'https://api.anam.ai/v1/auth/session-token';

  /// [enableAudioPassthrough] PHAI bat de avatar chi lipsync theo audio ta tu
  /// gui vao (qua createAgentAudioInputStream ben JS), thay vi tu dung
  /// LLM/TTS rieng cua Anam de tra loi.
  static Future<String> fetchSessionToken({
    required String apiKey,
    required String avatarId,
    required String avatarModel,
  }) async {
    final res = await http
        .post(
          Uri.parse(_endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'personaConfig': {
              'avatarId': avatarId,
              'avatarModel': avatarModel,
              'enableAudioPassthrough': true,
            },
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception(
        'Anam session-token request failed (${res.statusCode}): ${res.body}',
      );
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final token = data['sessionToken'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Anam session-token response missing sessionToken');
    }
    return token;
  }

  /// Doi session token qua serverless function Vercel (xem
  /// anam_vercel_server/api/main.py) thay vi goi thang API key trong app -
  /// day la cach dung nen sau khi da deploy (xem kAnamVercelProxyUrl trong
  /// voice_chat_config.dart), vi API key that CHI nam tren Vercel, khong
  /// con bi nhung vao APK nua.
  ///
  /// [avatarId] (dung de tu dong doi avatar Nam/Nu theo giong Gemini dang
  /// chon - xem GeminiGenderRouter) duoc gui qua query param cho proxy -
  /// PHAI tu cap nhat anam_vercel_server/api/main.py de doc query param nay
  /// va dua vao personaConfig.avatarId khi goi Anam that, proxy hien tai (neu
  /// chua sua) se bo qua va luon dung avatarId co dinh cau hinh san server-side.
  static Future<String> fetchSessionTokenFromProxy(
    String proxyUrl, {
    String? avatarId,
  }) async {
    var uri = Uri.parse(proxyUrl);
    if (avatarId != null && avatarId.isNotEmpty) {
      uri = uri.replace(
        queryParameters: {...uri.queryParameters, 'avatarId': avatarId},
      );
    }
    final res = await http.get(uri).timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception(
        'Vercel proxy request failed (${res.statusCode}): ${res.body}',
      );
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final token = data['sessionToken'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Vercel proxy response missing sessionToken');
    }
    return token;
  }
}

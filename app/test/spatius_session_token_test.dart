import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/ai_voice_chat/data/spatius_session_api.dart';

String _jwt(Map<String, dynamic> payload) {
  String seg(Map<String, dynamic> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  return '${seg({'alg': 'HS256', 'typ': 'JWT'})}.${seg(payload)}.chuky_gia';
}

void main() {
  group('SpatiusSessionApi.expiryFromJwt', () {
    test('doc dung exp tu payload JWT', () {
      // Cung dang token that cua Spatius (da kiem tra tu endpoint that:
      // {"iss":"ConsoleService","exp":...,"app_id":...,"user_id":...}).
      final exp = DateTime.utc(2026, 9, 18, 12);
      final token = _jwt({
        'iss': 'ConsoleService',
        'exp': exp.millisecondsSinceEpoch ~/ 1000,
        'app_id': 'app_test',
      });

      expect(SpatiusSessionApi.expiryFromJwt(token), exp.toLocal());
    });

    test('token khong phai JWT -> null (de roi ve expiresAt cua proxy)', () {
      expect(SpatiusSessionApi.expiryFromJwt('khong-phai-jwt'), isNull);
      expect(SpatiusSessionApi.expiryFromJwt('a.b'), isNull);
      expect(SpatiusSessionApi.expiryFromJwt(''), isNull);
    });

    test('payload khong co exp / exp sai kieu -> null', () {
      expect(SpatiusSessionApi.expiryFromJwt(_jwt({'iss': 'x'})), isNull);
      expect(
        SpatiusSessionApi.expiryFromJwt(_jwt({'exp': 'khong-phai-so'})),
        isNull,
      );
    });

    test('payload khong phai base64 hop le -> null, khong nem loi', () {
      expect(
        SpatiusSessionApi.expiryFromJwt('aaa.!!!khong-base64!!!.bbb'),
        isNull,
      );
    });
  });
}

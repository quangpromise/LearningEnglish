/// Gioi tinh cua giong Gemini Live dang chon - dung de tu dong doi avatar
/// Nam/Nu tuong ung (Anam hoac Spatius, xem
/// AiVoiceChatScreen._currentAnamAvatarId/_currentSpatiusAvatarId).
enum GeminiGender { male, female }

/// Anh xa ten 1 trong 30 giong dung san cua Gemini Live (xem
/// gemini_voices.dart/kGeminiVoices) sang [GeminiGender].
///
/// CANH BAO: Google KHONG cong bo chinh thuc gioi tinh cho tung giong -
/// [_maleVoices] duoi day chi gom 4 giong nguoi dung da tu nghe va xac nhan
/// ('Puck', 'Charon' = Nam; 'Aoede', 'Fenrir' = Nu, tuc Aoede/Fenrir nam
/// trong nhanh "khong phai male" ben duoi) cong them suy doan hop ly tu ten/
/// mo ta cho cac giong con lai (CHUA duoc nguoi dung tu nghe xac nhan) - NEU
/// avatar hien sai gioi so voi giong dang nghe, sua truc tiep trong danh
/// sach nay.
class GeminiGenderRouter {
  GeminiGenderRouter._();

  static const _maleVoices = <String>{
    'Puck',
    'Charon',
    'Orus',
    'Iapetus',
    'Umbriel',
    'Algenib',
    'Rasalgethi',
    'Alnilam',
    'Schedar',
    'Achird',
    'Zubenelgenubi',
    'Sadaltager',
    'Enceladus',
  };

  static GeminiGender fromVoiceName(String voiceName) {
    return _maleVoices.contains(voiceName)
        ? GeminiGender.male
        : GeminiGender.female;
  }
}

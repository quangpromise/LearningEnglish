import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 1 giong noi dung san (prebuilt) Gemini Live ho tro - xem
/// https://ai.google.dev/gemini-api/docs/speech-generation. [style] la mo ta
/// ngan Google dat cho giong do, giup nguoi dung chon nhanh khong can nghe
/// thu tung cai.
class GeminiVoice {
  const GeminiVoice(this.name, this.style);
  final String name;
  final String style;
}

/// Toan bo 30 giong dung san Gemini Live ho tro tinh den luc viet code nay -
/// khong phai danh sach do chon loc, Google co the them/bot giong theo thoi
/// gian.
const kGeminiVoices = [
  GeminiVoice('Zephyr', 'Bright'),
  GeminiVoice('Puck', 'Upbeat'),
  GeminiVoice('Charon', 'Informative'),
  GeminiVoice('Kore', 'Firm'),
  GeminiVoice('Fenrir', 'Excitable'),
  GeminiVoice('Leda', 'Youthful'),
  GeminiVoice('Orus', 'Firm'),
  GeminiVoice('Aoede', 'Breezy'),
  GeminiVoice('Callirrhoe', 'Easy-going'),
  GeminiVoice('Autonoe', 'Bright'),
  GeminiVoice('Enceladus', 'Breathy'),
  GeminiVoice('Iapetus', 'Clear'),
  GeminiVoice('Umbriel', 'Easy-going'),
  GeminiVoice('Algieba', 'Smooth'),
  GeminiVoice('Despina', 'Smooth'),
  GeminiVoice('Erinome', 'Clear'),
  GeminiVoice('Algenib', 'Gravelly'),
  GeminiVoice('Rasalgethi', 'Informative'),
  GeminiVoice('Laomedeia', 'Upbeat'),
  GeminiVoice('Achernar', 'Soft'),
  GeminiVoice('Alnilam', 'Firm'),
  GeminiVoice('Schedar', 'Even'),
  GeminiVoice('Gacrux', 'Mature'),
  GeminiVoice('Pulcherrima', 'Forward'),
  GeminiVoice('Achird', 'Friendly'),
  GeminiVoice('Zubenelgenubi', 'Casual'),
  GeminiVoice('Vindemiatrix', 'Gentle'),
  GeminiVoice('Sadachbia', 'Lively'),
  GeminiVoice('Sadaltager', 'Knowledgeable'),
  GeminiVoice('Sulafat', 'Warm'),
];

const kDefaultGeminiVoiceName = 'Puck';

/// Luu/doc giong da chon tren may (SharedPreferences) - ap dung cho lan ket
/// noi Gemini Live moi tiep theo (doi giong giua chung 1 phien dang mo
/// khong co tac dung, vi setup chi gui 1 lan luc bat dau ket noi).
class GeminiVoicePrefs {
  GeminiVoicePrefs._();

  static const _key = 'ai_voice_chat_voice_name';

  static Future<String> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved != null && kGeminiVoices.any((v) => v.name == saved)) {
      return saved;
    }
    return kDefaultGeminiVoiceName;
  }

  static Future<void> save(String voiceName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, voiceName);
  }
}

/// Giong Gemini Live dang chon - dung CHUNG cho toan app (man Ho so va man
/// AI Voice Chat deu doc/ghi qua day) thay vi moi man tu giu 1 bien rieng.
/// Truoc day AiVoiceChatScreen va man Ho so moi noi tu load/luu doc lap -
/// doi giong o Ho so khong lam AiVoiceChatScreen (dang song san trong tab,
/// initState chi chay 1 lan luc mo app) biet ma cap nhat, phai khoi dong lai
/// app moi thay hieu luc. Dung ValueNotifier de ca 2 noi cung nghe 1 nguon,
/// doi ngay lap tuc bat ke doi tu dau.
class GeminiVoiceSelection extends ValueNotifier<String> {
  GeminiVoiceSelection._() : super(kDefaultGeminiVoiceName);

  static final instance = GeminiVoiceSelection._();

  /// Goi 1 lan luc khoi dong app (xem main.dart) de ap lai giong da luu tu
  /// lan truoc.
  Future<void> restoreSaved() async {
    value = await GeminiVoicePrefs.load();
  }

  Future<void> select(String voiceName) async {
    value = voiceName;
    await GeminiVoicePrefs.save(voiceName);
  }
}

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'learning_path_models.dart';

/// Luu/doc persona nguoi dung da chon o khao sat "Goi y lo trinh hoc" -
/// bang `user_learning_path_choice` (migration 0042), 1 dong/user, mirror
/// dung pattern cua LessonProgressRepository
/// (story/data/lesson_progress_repository.dart).
///
/// Kem 1 BAN SAO tren may (SharedPreferences, key rieng theo user): truoc
/// day chi doc tu Supabase, loi mang luc mo app bi nuot thanh "chua chon"
/// -> ban tay goi y tren Home + bo loc theo cap hoc bien mat cho toi lan mo
/// app sau. Gio ghi ban sao moi khi doc/luu thanh cong, va dung no khi goi
/// server that bai.
class LearningPathRepository {
  LearningPathRepository(this._supabase);
  final SupabaseClient _supabase;

  /// Gia tri luu trong cot `persona` khi nguoi dung chon "Tu hoc".
  static const _noneValue = 'none';

  static String _cacheKey(String userId) => 'learning_path_choice_$userId';

  /// Gia tri tho cua cot `persona`: ten 1 LearningPersona, 'none' (Tu hoc),
  /// hoac null (chua tung tuong tac voi khao sat).
  Future<String?> _fetchRaw(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final row = await _supabase
          .from('user_learning_path_choice')
          .select('persona')
          .eq('user_id', userId)
          .maybeSingle();
      final raw = row?['persona'] as String?;
      if (raw == null) {
        await prefs.remove(_cacheKey(userId));
      } else {
        await prefs.setString(_cacheKey(userId), raw);
      }
      return raw;
    } catch (_) {
      // Mat mang / bang chua migrate - dung ban sao tren may (neu co) thay
      // vi coi nhu chua chon gi.
      return prefs.getString(_cacheKey(userId));
    }
  }

  Future<void> _writeCache(String userId, String raw) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey(userId), raw);
  }

  Future<LearningPersona?> fetchChoice() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;
    final raw = await _fetchRaw(userId);
    // Chuoi khong khop ten enum nao ('none' = Tu hoc) -> null.
    return LearningPersona.values.asNameMap()[raw];
  }

  /// Da tung tuong tac voi khao sat chua (chon 1 persona HOAC bam "Tu hoc")
  /// - khac [fetchChoice] (tra ve null cho CA HAI truong hop "chua tung mo
  /// khao sat" LAN "da bam Tu hoc"), dung rieng de biet KHI NAO an goi y
  /// ban tay tro vao nut khao sat o Home (chi hien cho nguoi CHUA TUNG tuong
  /// tac, an ngay sau khi ho chon 1 gia tri BAT KY, ke ca Tu hoc).
  Future<bool> hasInteracted() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;
    return await _fetchRaw(userId) != null;
  }

  Future<void> choosePersona(LearningPersona persona) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    // Ghi ban sao tren may TRUOC - ke ca khi luu len server that bai, lua
    // chon van co hieu luc ngay tren may nay.
    await _writeCache(userId, persona.name);
    try {
      await _supabase.from('user_learning_path_choice').upsert({
        'user_id': userId,
        'persona': persona.name,
      }, onConflict: 'user_id');
    } catch (_) {
      // KHONG duoc de loi luu (vd bang chua migrate) chan nguoi dung -
      // man khao sat van phai dong lai binh thuong (xem
      // learning_path_survey_screen.dart._choose, bug that da gap: cho
      // await nay xong moi Navigator.pop() khien nut "khong bam duoc" neu
      // luu that bai).
    }
  }

  /// Nguoi dung chon "Tu hoc" - tat het highlight/goi y tren Home. Luu
  /// chuoi 'none' (khong khop ten enum nao) thay vi xoa dong - tai dung
  /// DUOC policy insert/update da co san (khong can them policy delete +
  /// migration moi); fetchChoice() da san sang tra ve null cho bat ky
  /// chuoi nao khong khop ten LearningPersona (xem catch (_) o tren).
  Future<void> turnOff() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    await _writeCache(userId, _noneValue);
    try {
      await _supabase.from('user_learning_path_choice').upsert({
        'user_id': userId,
        'persona': _noneValue,
      }, onConflict: 'user_id');
    } catch (_) {
      // Xem ly do bo qua loi o choosePersona() ben tren.
    }
  }
}

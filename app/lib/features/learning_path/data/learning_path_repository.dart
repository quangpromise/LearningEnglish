import 'package:supabase_flutter/supabase_flutter.dart';

import 'learning_path_models.dart';

/// Luu/doc persona nguoi dung da chon o khao sat "Goi y lo trinh hoc" -
/// bang `user_learning_path_choice` (migration 0042), 1 dong/user, mirror
/// dung pattern cua LessonProgressRepository
/// (story/data/lesson_progress_repository.dart).
class LearningPathRepository {
  LearningPathRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<LearningPersona?> fetchChoice() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;
    try {
      final row = await _supabase
          .from('user_learning_path_choice')
          .select('persona')
          .eq('user_id', userId)
          .maybeSingle();
      final persona = row?['persona'] as String?;
      if (persona == null) return null;
      return LearningPersona.values.byName(persona);
    } catch (_) {
      // Bang co the chua duoc migrate len server (vd moi them, chua chay
      // migration) - coi nhu chua chon persona nao thay vi de loi lam vo
      // FutureProvider (Home van hoat dong binh thuong, chi khong highlight).
      return null;
    }
  }

  /// Da tung tuong tac voi khao sat chua (chon 1 persona HOAC bam "Tu hoc")
  /// - khac [fetchChoice] (tra ve null cho CA HAI truong hop "chua tung mo
  /// khao sat" LAN "da bam Tu hoc"), dung rieng de biet KHI NAO an goi y
  /// ban tay tro vao nut khao sat o Home (chi hien cho nguoi CHUA TUNG tuong
  /// tac, an ngay sau khi ho chon 1 gia tri BAT KY, ke ca Tu hoc).
  Future<bool> hasInteracted() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;
    try {
      final row = await _supabase
          .from('user_learning_path_choice')
          .select('user_id')
          .eq('user_id', userId)
          .maybeSingle();
      return row != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> choosePersona(LearningPersona persona) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
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
    try {
      await _supabase.from('user_learning_path_choice').upsert({
        'user_id': userId,
        'persona': 'none',
      }, onConflict: 'user_id');
    } catch (_) {
      // Xem ly do bo qua loi o choosePersona() ben tren.
    }
  }

  /// Tap hop cac step_index da danh dau hoan thanh cho 1 persona - bang
  /// `user_learning_path_progress` (migration 0051). Loi (vd chua migrate)
  /// tra ve set rong thay vi nem loi - man Lo trinh hoc van hien duoc, chi
  /// khong co buoc nao duoc tick san.
  Future<Set<int>> fetchProgress(LearningPersona persona) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return const {};
    try {
      final rows = await _supabase
          .from('user_learning_path_progress')
          .select('step_index')
          .eq('user_id', userId)
          .eq('persona_id', persona.name);
      return (rows as List).map((r) => r['step_index'] as int).toSet();
    } catch (_) {
      return const {};
    }
  }

  /// Danh dau 1 buoc la da hoan thanh - khong nem loi ra ngoai (cung pattern
  /// voi choosePersona()/turnOff() o tren), UI khong can try/catch.
  Future<void> markStepCompleted(LearningPersona persona, int stepIndex) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await _supabase.from('user_learning_path_progress').upsert({
        'user_id': userId,
        'persona_id': persona.name,
        'step_index': stepIndex,
      }, onConflict: 'user_id,persona_id,step_index');
    } catch (_) {
      // Xem ly do bo qua loi o choosePersona() ben tren.
    }
  }

  /// Bo danh dau hoan thanh 1 buoc (cho phep nguoi dung sua nham).
  Future<void> unmarkStepCompleted(
    LearningPersona persona,
    int stepIndex,
  ) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await _supabase
          .from('user_learning_path_progress')
          .delete()
          .eq('user_id', userId)
          .eq('persona_id', persona.name)
          .eq('step_index', stepIndex);
    } catch (_) {
      // Xem ly do bo qua loi o choosePersona() ben tren.
    }
  }
}

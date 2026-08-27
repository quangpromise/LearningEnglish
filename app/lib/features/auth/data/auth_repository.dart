import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/env.dart';

class AuthRepository {
  AuthRepository(this._supabase);

  final SupabaseClient _supabase;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  User? get currentUser => _supabase.auth.currentUser;

  /// Đăng nhập bằng Google mail: lấy ID token qua `google_sign_in`, sau đó
  /// đưa cho Supabase Auth xác thực & tạo/khôi phục tài khoản tương ứng.
  Future<void> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      serverClientId: Env.googleWebClientId,
      scopes: ['email', 'profile'],
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return; // người dùng huỷ đăng nhập

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) {
      throw Exception(
        'Không lấy được ID token từ Google — kiểm tra lại GOOGLE_WEB_CLIENT_ID.',
      );
    }

    await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: googleAuth.accessToken,
    );
  }

  /// Đăng ký tài khoản mới bằng email + mật khẩu, kèm username hiển thị.
  /// Supabase mặc định yêu cầu xác nhận email trước khi đăng nhập được —
  /// nếu dự án đã tắt "Confirm email" trong Dashboard thì đăng nhập ngay.
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _supabase.auth.signOut();
  }
}

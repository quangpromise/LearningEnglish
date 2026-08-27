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

    await _supabase.auth
        .signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: googleAuth.accessToken,
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception(
            'Kết nối tới máy chủ quá lâu — kiểm tra mạng và thử lại.',
          ),
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
    await _supabase.auth
        .signUp(email: email, password: password, data: {'username': username})
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception(
            'Kết nối tới máy chủ quá lâu — kiểm tra mạng và thử lại.',
          ),
        );
  }

  /// Đăng nhập bằng email HOẶC username. Nếu không phải định dạng email,
  /// tra email tương ứng qua RPC `email_for_username` rồi mới đăng nhập —
  /// Supabase Auth chỉ xác thực bằng email nên cần bước tra trung gian này.
  Future<void> signInWithIdentifier({
    required String identifier,
    required String password,
  }) async {
    var email = identifier.trim();
    if (!email.contains('@')) {
      final resolved = await _supabase.rpc(
        'email_for_username',
        params: {'p_username': email},
      );
      if (resolved is! String || resolved.isEmpty) {
        throw Exception('Không tìm thấy tài khoản với tên người dùng này.');
      }
      email = resolved;
    }
    await _supabase.auth
        .signInWithPassword(email: email, password: password)
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception(
            'Kết nối tới máy chủ quá lâu — kiểm tra mạng và thử lại.',
          ),
        );
  }

  /// Đổi mật khẩu cho tài khoản đang đăng nhập (chỉ áp dụng cho tài khoản
  /// đăng ký bằng email — tài khoản Google không có mật khẩu để đổi).
  Future<void> changePassword(String newPassword) async {
    await _supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  /// Gửi email đặt lại mật khẩu (quên mật khẩu). Chấp nhận cả username -
  /// tra email tương ứng qua RPC giống lúc đăng nhập. Link trong email sẽ
  /// mở lại app qua deep link `learnenglishmusic://reset-callback/` (xem
  /// AndroidManifest.xml), Supabase SDK tự bắt link này và phát sự kiện
  /// AuthChangeEvent.passwordRecovery cho _AuthGate xử lý (main.dart).
  Future<void> sendPasswordResetEmail(String identifier) async {
    var email = identifier.trim();
    if (!email.contains('@')) {
      final resolved = await _supabase.rpc(
        'email_for_username',
        params: {'p_username': email},
      );
      if (resolved is! String || resolved.isEmpty) {
        throw Exception('Không tìm thấy tài khoản với tên người dùng này.');
      }
      email = resolved;
    }
    await _supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'learnenglishmusic://reset-callback/',
    );
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _supabase.auth.signOut();
  }
}

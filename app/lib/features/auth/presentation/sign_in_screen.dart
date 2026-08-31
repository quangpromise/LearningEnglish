import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';

enum _Mode { signIn, signUp }

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  _Mode _mode = _Mode.signIn;
  bool _loading = false;
  String? _error;
  String? _info;

  final _emailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _loading = true;
      _error = null;
      _info = null;
    });
    try {
      await action();
    } on AuthApiException catch (e) {
      setState(() => _error = _messageForAuthError(e));
    } catch (e) {
      setState(() => _error = 'Thất bại: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Supabase mac dinh yeu cau xac nhan email truoc khi dang nhap duoc -
  /// neu bat "Confirm email" trong Dashboard, tai khoan vua dang ky se bi
  /// tu choi dang nhap voi ma loi nay cho toi khi bam link trong email. Ma
  /// loi goc bi che sau exception mac dinh nen phai bat theo `e.code`.
  String _messageForAuthError(AuthApiException e) {
    switch (e.code) {
      case 'email_not_confirmed':
        return 'Tài khoản chưa xác nhận email. Vui lòng kiểm tra hộp thư '
            '(kể cả mục spam) và bấm vào link xác nhận trước khi đăng nhập.';
      case 'invalid_credentials':
        return 'Email/tên người dùng hoặc mật khẩu không đúng.';
      case 'user_already_exists':
        return 'Email này đã được đăng ký. Hãy đăng nhập hoặc dùng "Quên mật khẩu".';
      default:
        return 'Thất bại: ${e.message}';
    }
  }

  Future<void> _resendConfirmation() {
    final identifier = _emailCtrl.text.trim();
    if (identifier.isEmpty || !identifier.contains('@')) {
      setState(
        () => _error = 'Nhập email đã đăng ký để gửi lại link xác nhận.',
      );
      return Future.value();
    }
    return _run(() async {
      await ref
          .read(authRepositoryProvider)
          .resendConfirmationEmail(identifier);
      if (mounted) {
        setState(() => _info = 'Đã gửi lại email xác nhận. Kiểm tra hộp thư.');
      }
    });
  }

  Future<void> _signInWithGoogle() =>
      _run(() => ref.read(authRepositoryProvider).signInWithGoogle());

  Future<void> _forgotPassword() {
    final identifier = _emailCtrl.text.trim();
    if (identifier.isEmpty) {
      setState(
        () => _error =
            'Nhập email hoặc tên người dùng trước khi bấm quên mật khẩu.',
      );
      return Future.value();
    }
    return _run(() async {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(identifier);
      if (mounted) {
        setState(
          () => _info = 'Đã gửi email đặt lại mật khẩu (nếu tài khoản tồn tại). Mở email trên điện thoại này và bấm vào link để đặt mật khẩu mới.',
        );
      }
    });
  }

  Future<void> _submitEmailForm() {
    final identifier = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final username = _usernameCtrl.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      setState(
        () => _error = _mode == _Mode.signIn
            ? 'Vui lòng nhập email/tên người dùng và mật khẩu.'
            : 'Vui lòng nhập email và mật khẩu.',
      );
      return Future.value();
    }
    if (_mode == _Mode.signUp && username.isEmpty) {
      setState(() => _error = 'Vui lòng nhập tên người dùng.');
      return Future.value();
    }

    if (_mode == _Mode.signIn) {
      return _run(
        () => ref
            .read(authRepositoryProvider)
            .signInWithIdentifier(identifier: identifier, password: password),
      );
    }
    return _run(() async {
      await ref
          .read(authRepositoryProvider)
          .signUpWithEmail(
            email: identifier,
            password: password,
            username: username,
          );
      if (mounted) {
        setState(() {
          _info = 'Đăng ký thành công! Nếu dự án yêu cầu xác nhận email, hãy kiểm tra hộp thư trước khi đăng nhập.';
          _mode = _Mode.signIn;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSignUp = _mode == _Mode.signUp;
    return ScreenBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/icon/app_icon_square.png',
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'GymTalk',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading(size: 22),
            ),
            const SizedBox(height: 6),
            Text(ref.tr('auth_tagline'), style: AppTextStyles.muted()),
            const SizedBox(height: 24),
            GlowBox(
              borderRadius: 999,
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: _ModeTab(
                      label: ref.tr('auth_tab_signin'),
                      active: !isSignUp,
                      onTap: () => setState(() {
                        _mode = _Mode.signIn;
                        _error = null;
                        _info = null;
                      }),
                    ),
                  ),
                  Expanded(
                    child: _ModeTab(
                      label: ref.tr('auth_tab_signup'),
                      active: isSignUp,
                      onTap: () => setState(() {
                        _mode = _Mode.signUp;
                        _error = null;
                        _info = null;
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (isSignUp) ...[
              _AuthField(
                key: const ValueKey('auth_field_username'),
                controller: _usernameCtrl,
                label: ref.tr('auth_username'),
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 12),
            ],
            _AuthField(
              key: const ValueKey('auth_field_email'),
              controller: _emailCtrl,
              label: isSignUp
                  ? ref.tr('auth_email')
                  : ref.tr('auth_email_or_username'),
              icon: Icons.mail_outline_rounded,
              keyboardType: isSignUp
                  ? TextInputType.emailAddress
                  : TextInputType.text,
            ),
            const SizedBox(height: 12),
            _AuthField(
              key: const ValueKey('auth_field_password'),
              controller: _passwordCtrl,
              label: ref.tr('auth_password'),
              icon: Icons.lock_outline_rounded,
              obscure: true,
            ),
            if (!isSignUp) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _loading ? null : _forgotPassword,
                  child: Text(
                    ref.tr('auth_forgot_password'),
                    style: AppTextStyles.body(
                      size: 12,
                      weight: FontWeight.w700,
                      color: AppColors.blue,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            if (_error != null) ...[
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: AppTextStyles.body(size: 12, color: AppColors.pink),
              ),
              if (_error!.contains('chưa xác nhận email')) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _loading ? null : _resendConfirmation,
                  child: Text(
                    'Gửi lại email xác nhận',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body(
                      size: 12,
                      weight: FontWeight.w700,
                      color: AppColors.blue,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],
            if (_info != null) ...[
              Text(
                _info!,
                textAlign: TextAlign.center,
                style: AppTextStyles.body(size: 12, color: AppColors.teal),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: PillButton(
                label: _loading
                    ? ref.tr('auth_processing')
                    : (isSignUp
                          ? ref.tr('auth_create_account')
                          : ref.tr('auth_signin_button')),
                onTap: _loading ? null : _submitEmailForm,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Divider(color: AppColors.glassBorder)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(ref.tr('auth_or'), style: AppTextStyles.muted()),
                ),
                Expanded(child: Divider(color: AppColors.glassBorder)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: PillButton(
                filled: false,
                label: _loading
                    ? ref.tr('auth_google_processing')
                    : ref.tr('auth_google_signin'),
                icon: const Icon(
                  Icons.g_mobiledata_rounded,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
                onTap: _loading ? null : _signInWithGoogle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: active ? AppColors.accentGradient : null,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.body(
            size: 13,
            weight: FontWeight.w800,
            color: active ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _AuthField extends StatefulWidget {
  const _AuthField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;

  @override
  State<_AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<_AuthField> {
  late bool _obscured = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return GlowBox(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: widget.controller,
        obscureText: _obscured,
        keyboardType: widget.keyboardType,
        style: AppTextStyles.body(),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(widget.icon, size: 18, color: AppColors.textMuted),
          hintText: widget.label,
          hintStyle: AppTextStyles.muted(),
          suffixIcon: widget.obscure
              ? IconButton(
                  onPressed: () => setState(() => _obscured = !_obscured),
                  icon: Icon(
                    _obscured
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    } catch (e) {
      setState(() => _error = 'Thất bại: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() =>
      _run(() => ref.read(authRepositoryProvider).signInWithGoogle());

  Future<void> _submitEmailForm() {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final username = _usernameCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Vui lòng nhập email và mật khẩu.');
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
            .signInWithEmail(email: email, password: password),
      );
    }
    return _run(() async {
      await ref
          .read(authRepositoryProvider)
          .signUpWithEmail(
            email: email,
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
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.music_note_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Learn English\nThrough Music',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading(size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              'Đăng nhập để lưu tiến độ & điểm thưởng',
              style: AppTextStyles.muted(),
            ),
            const SizedBox(height: 24),
            GlowBox(
              borderRadius: 999,
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: _ModeTab(
                      label: 'Đăng nhập',
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
                      label: 'Đăng ký',
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
                controller: _usernameCtrl,
                label: 'Tên người dùng',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 12),
            ],
            _AuthField(
              controller: _emailCtrl,
              label: 'Email',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            _AuthField(
              controller: _passwordCtrl,
              label: 'Mật khẩu',
              icon: Icons.lock_outline_rounded,
              obscure: true,
            ),
            const SizedBox(height: 18),
            if (_error != null) ...[
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: AppTextStyles.body(size: 12, color: AppColors.pink),
              ),
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
                    ? 'Đang xử lý...'
                    : (isSignUp ? 'Tạo tài khoản' : 'Đăng nhập'),
                onTap: _loading ? null : _submitEmailForm,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Divider(color: AppColors.glassBorder)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('hoặc', style: AppTextStyles.muted()),
                ),
                Expanded(child: Divider(color: AppColors.glassBorder)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: PillButton(
                filled: false,
                label: _loading ? 'Đang đăng nhập...' : 'Đăng nhập bằng Google',
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

class _AuthField extends StatelessWidget {
  const _AuthField({
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
  Widget build(BuildContext context) {
    return GlowBox(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: AppTextStyles.body(),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, size: 18, color: AppColors.textMuted),
          hintText: label,
          hintStyle: AppTextStyles.muted(),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';

/// Hiện khi app được mở qua deep link "quên mật khẩu" từ email (xem
/// _AuthGate trong main.dart) — bắt người dùng đặt mật khẩu mới trước khi
/// vào app, thay vì âm thầm đăng nhập bằng session tạm của link recovery.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _newPasswordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _newPasswordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final newPassword = _newPasswordCtrl.text;
    final confirm = _confirmCtrl.text;
    if (newPassword.length < 6) {
      setState(() => _error = ref.tr('change_password_short'));
      return;
    }
    if (newPassword != confirm) {
      setState(() => _error = ref.tr('change_password_mismatch'));
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).changePassword(newPassword);
      ref.read(passwordRecoveryHandledProvider.notifier).state = true;
    } catch (e) {
      if (mounted) {
        setState(() => _error = '${ref.tr('change_password_failed')} $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                ref.tr('reset_password_title'),
                style: AppTextStyles.heading(size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                ref.tr('reset_password_subtitle'),
                style: AppTextStyles.muted(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _PasswordField(
                controller: _newPasswordCtrl,
                label: ref.tr('change_password_new'),
              ),
              const SizedBox(height: 12),
              _PasswordField(
                controller: _confirmCtrl,
                label: ref.tr('change_password_confirm'),
              ),
              const SizedBox(height: 16),
              if (_error != null) ...[
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(size: 12, color: AppColors.pink),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: PillButton(
                  label: _loading
                      ? ref.tr('processing_ellipsis')
                      : ref.tr('reset_password_confirm_button'),
                  onTap: _loading ? null : _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({required this.controller, required this.label});
  final TextEditingController controller;
  final String label;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return GlowBox(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: widget.controller,
        obscureText: _obscured,
        style: AppTextStyles.body(),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: const Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: AppColors.textMuted,
          ),
          hintText: widget.label,
          hintStyle: AppTextStyles.muted(),
          suffixIcon: IconButton(
            onPressed: () => setState(() => _obscured = !_obscured),
            icon: Icon(
              _obscured
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              size: 18,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

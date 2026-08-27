import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';

Future<void> showChangePasswordSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _ChangePasswordSheet(),
  );
}

class _ChangePasswordSheet extends ConsumerStatefulWidget {
  const _ChangePasswordSheet();

  @override
  ConsumerState<_ChangePasswordSheet> createState() =>
      _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
  final _newPasswordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _success;

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
      setState(() => _error = 'Mật khẩu cần ít nhất 6 ký tự.');
      return;
    }
    if (newPassword != confirm) {
      setState(() => _error = 'Mật khẩu nhập lại không khớp.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });
    try {
      await ref.read(authRepositoryProvider).changePassword(newPassword);
      if (mounted) setState(() => _success = 'Đổi mật khẩu thành công!');
    } catch (e) {
      if (mounted) setState(() => _error = 'Thất bại: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
      decoration: const BoxDecoration(
        color: Color(0xEB0F1326),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Đổi mật khẩu', style: AppTextStyles.heading(size: 18)),
          const SizedBox(height: 4),
          Text(
            'Chỉ áp dụng cho tài khoản đăng ký bằng email.',
            style: AppTextStyles.muted(),
          ),
          const SizedBox(height: 16),
          _PasswordField(controller: _newPasswordCtrl, label: 'Mật khẩu mới'),
          const SizedBox(height: 12),
          _PasswordField(
            controller: _confirmCtrl,
            label: 'Nhập lại mật khẩu mới',
          ),
          const SizedBox(height: 16),
          if (_error != null) ...[
            Text(
              _error!,
              style: AppTextStyles.body(size: 12, color: AppColors.pink),
            ),
            const SizedBox(height: 12),
          ],
          if (_success != null) ...[
            Text(
              _success!,
              style: AppTextStyles.body(size: 12, color: AppColors.teal),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: PillButton(
              label: _loading ? 'Đang xử lý...' : 'Xác nhận đổi mật khẩu',
              onTap: _loading ? null : _submit,
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({required this.controller, required this.label});
  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GlowBox(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        obscureText: true,
        style: AppTextStyles.body(),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: const Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: AppColors.textMuted,
          ),
          hintText: label,
          hintStyle: AppTextStyles.muted(),
        ),
      ),
    );
  }
}

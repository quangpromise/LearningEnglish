import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
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
      _success = null;
    });
    try {
      await ref.read(authRepositoryProvider).changePassword(newPassword);
      if (mounted) {
        setState(() => _success = ref.tr('change_password_success'));
      }
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
          Text(
            ref.tr('change_password_title'),
            style: AppTextStyles.heading(size: 18),
          ),
          const SizedBox(height: 4),
          Text(
            ref.tr('change_password_subtitle'),
            style: AppTextStyles.muted(),
          ),
          const SizedBox(height: 16),
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
              label: _loading
                  ? ref.tr('processing_ellipsis')
                  : ref.tr('change_password_confirm_button'),
              onTap: _loading ? null : _submit,
            ),
          ),
        ],
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

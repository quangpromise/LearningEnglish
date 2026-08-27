import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } catch (e) {
      setState(() => _error = 'Đăng nhập thất bại: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(gradient: AppColors.accentGradient, borderRadius: BorderRadius.circular(28)),
                child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 20),
              Text('Learn English\nThrough Music', textAlign: TextAlign.center, style: AppTextStyles.heading(size: 22)),
              const SizedBox(height: 8),
              Text('Đăng nhập để lưu tiến độ & điểm thưởng', style: AppTextStyles.muted()),
              const SizedBox(height: 32),
              if (_error != null) ...[
                Text(_error!, style: AppTextStyles.body(size: 12, color: AppColors.pink)),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: PillButton(
                  label: _loading ? 'Đang đăng nhập...' : 'Đăng nhập bằng Google',
                  icon: const Icon(Icons.g_mobiledata_rounded, color: Colors.white, size: 22),
                  onTap: _loading ? null : _signIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

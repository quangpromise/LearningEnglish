import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env.dart';
import 'core/navigation/root_shell.dart';
import 'core/providers/app_providers.dart';
import 'core/theme/app_theme.dart';
import 'core/tts/app_tts.dart';
import 'features/ai_voice_chat/data/gemini_voices.dart';
import 'features/auth/presentation/reset_password_screen.dart';
import 'features/auth/presentation/sign_in_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Env.isConfigured) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
    );
  }

  await AppTts.instance.restoreSavedVoice();
  await GeminiVoiceSelection.instance.restoreSaved();

  runApp(const ProviderScope(child: LearnEnglishMusicApp()));
}

class LearnEnglishMusicApp extends StatelessWidget {
  const LearnEnglishMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learn English Through Music',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgTop,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.blue,
          brightness: Brightness.dark,
          primary: AppColors.blue,
          secondary: AppColors.purple,
          surface: AppColors.bgMid,
        ),
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Manrope',
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
          decoration: TextDecoration.none,
        ),
        fontFamily: 'Manrope',
      ),
      home: Env.isConfigured ? const _AuthGate() : const _MissingConfigScreen(),
    );
  }
}

/// Hiện SignInScreen khi chưa đăng nhập, RootShell khi đã đăng nhập.
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final session = Supabase.instance.client.auth.currentSession;

    // Cac provider "cua toi" (ho so, stats, ban be...) la FutureProvider,
    // Riverpod mac dinh cache ket qua cho ca vong doi app. Neu khong lam
    // moi khi doi trang thai dang nhap, doi tai khoan tren cung may se
    // hien du lieu CU cua tai khoan truoc do. invalidate het moi khi thuc
    // su co su kien dang nhap/dang xuat (khong invalidate voi cac event
    // khac nhu tokenRefreshed de tranh goi lai API khong can thiet).
    ref.listen<AsyncValue<AuthState>>(authStateProvider, (previous, next) {
      final event = next.value?.event;
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.signedOut) {
        invalidateUserScopedProviders(ref);
      }
    });

    if (authState.isLoading && session == null) {
      return const ScreenBackground(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Link "quên mật khẩu" trong email tạo 1 session tạm (recovery) - nếu
    // vào thẳng RootShell như đăng nhập bình thường, người dùng sẽ không
    // bao giờ được yêu cầu đặt mật khẩu mới. Chặn lại ở đây cho tới khi họ
    // hoàn tất (passwordRecoveryHandledProvider) rồi mới cho vào app.
    final recoveryHandled = ref.watch(passwordRecoveryHandledProvider);
    if (authState.value?.event == AuthChangeEvent.passwordRecovery &&
        !recoveryHandled) {
      return const ResetPasswordScreen();
    }

    final signedIn = session != null;
    return signedIn ? const RootShell() : const SignInScreen();
  }
}

class _MissingConfigScreen extends StatelessWidget {
  const _MissingConfigScreen();

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Thiếu cấu hình Supabase/Google.\n'
            'Chạy app kèm --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=... '
            '--dart-define=GOOGLE_WEB_CLIENT_ID=...\n\nXem docs/setup-supabase.md.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body(size: 13),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env.dart';
import 'core/navigation/root_shell.dart';
import 'core/providers/app_providers.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/sign_in_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Env.isConfigured) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
  }

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

    if (authState.isLoading && session == null) {
      return const ScreenBackground(
        child: Center(child: CircularProgressIndicator()),
      );
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

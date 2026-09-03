import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:just_audio_platform_interface/just_audio_platform_interface.dart';
import 'package:just_audio_platform_interface/method_channel_just_audio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/audio/audio_service_diagnostics.dart';
import 'core/config/env.dart';
import 'core/navigation/ai_fab_overlay.dart';
import 'core/navigation/nav_keys.dart';
import 'core/navigation/root_shell.dart';
import 'core/notifications/chat_push.dart';
import 'core/notifications/daily_quiz_notifications.dart';
import 'core/providers/app_providers.dart';
import 'core/theme/app_theme.dart';
import 'core/tts/app_tts.dart';
import 'features/ai_voice_chat/data/gemini_voices.dart';
import 'features/auth/presentation/reset_password_screen.dart';
import 'features/auth/presentation/sign_in_screen.dart';
import 'features/music_player/presentation/global_media_bar.dart';
import 'features/onboarding/data/onboarding_repository.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';

/// Chay 1 buoc khoi dong voi gioi han thoi gian + bo qua moi loi - dam bao
/// KHONG buoc nao trong main() co the lam app "dung yen vinh vien o man hinh
/// splash" (man hinh nen cua Android hien truoc khi runApp() duoc goi). Da
/// tung gap dung 1 lan vi JustAudioBackground.init() treo (xem comment o
/// duoi) - ap dung CHO CA CAC BUOC KHAC de phong truong hop buoc nao do (vd
/// Supabase.initialize() mat mang, Firebase.initializeApp() timeout...) cung
/// co the treo tuong tu ma chua tung bi bat qua try/catch rieng.
Future<void> _runStartupStep(
  Future<void> Function() step, {
  Duration timeout = const Duration(seconds: 8),
}) async {
  try {
    await step().timeout(timeout);
  } catch (_) {}
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Env.isConfigured) {
    await _runStartupStep(
      () => Supabase.initialize(
        url: Env.supabaseUrl,
        publishableKey: Env.supabaseAnonKey,
      ),
      timeout: const Duration(seconds: 10),
    );
  }

  await _runStartupStep(() => AppTts.instance.restoreSavedVoice());
  await _runStartupStep(() => GeminiVoiceSelection.instance.restoreSaved());
  // Nhac hoc hen gio + push chat deu dua tren flutter_local_notifications/
  // Firebase Messaging thiet ke cho mobile - tren web, lich hen gio khong
  // duoc trinh duyet ho tro va Firebase can cau hinh rieng (VAPID key,
  // service worker) chua lam trong ban web nay. Bo qua hoan toan tren web
  // thay vi de plugin nem loi luc khoi dong lam trang trang xoa (ca app web
  // khong load duoc) - xem docs/research-ios-distribution.md.
  if (!kIsWeb) {
    await _runStartupStep(() => DailyQuizNotifications.instance.init());
    // KHONG await/timeout ngan o day: ChatPush.init() (Firebase.initializeApp
    // + tao notification channel + dang ky FCM background handler) co the
    // mat vai chuc giay tren mang cham, va viec gan 1 timeout ngan (vd 8s) se
    // BO NGANG qua trinh nay giua chung neu chua kip xong - lam push tin
    // nhan mat hoat dong hoan toan du khong co loi nao xay ra that su. Chay
    // ngam KHONG chan runApp(), khong anh huong toi thoi gian khoi dong.
    unawaited(ChatPush.instance.init());
    // Thong bao he thong + man hinh khoa cho bai dang phat (giong Spotify).
    // JustAudioBackground.init() doi JustAudioPlatform.instance sang 1 native
    // service rieng NGAY LUC goi; neu viec bind service do that bai/timeout
    // (R8 xoa mat class audio_service, mang cham, OEM chan foreground
    // service...), truoc day buoc doi nay KHONG bao gio duoc hoan tac, khien
    // MOI AudioPlayer() tao ra sau do (ke ca AudioPlayer chinh trong
    // NowPlayingService) deu bi hong vinh vien theo - day CHINH LA nguyen
    // nhan "khong tai duoc nhac" du link/mang hoan toan binh thuong, tai dien
    // nhieu lan trong du an. FIX DUNG GOC (thay vi tat han tinh nang): neu
    // init that bai/timeout, CHU DONG dat lai JustAudioPlatform.instance ve
    // ban mac dinh (MethodChannelJustAudio, khong qua audio_service) - dam
    // bao AudioPlayer van hoat dong binh thuong (chi mat thong bao/man hinh
    // khoa cho LAN MO APP DO), thay vi de no o trang thai hong vinh vien.
    try {
      await JustAudioBackground.init(
        androidNotificationChannelId: 'com.learnenglishmusic.audio',
        androidNotificationChannelName: 'Đang phát nhạc',
        androidNotificationOngoing: true,
        // Icon nho tren thanh trang thai/thong bao PHAI la hinh trang/trong
        // suot don gian (xem giai thich chi tiet trong chat_push.dart) -
        // truoc day dung thang "mipmap/ic_launcher" (icon app day mau) cho
        // CHINH thong bao "dang phat nhac" nay, co the la 1 phan nguyen nhan
        // khien viec dung notification/service that bai tren 1 so may.
        androidNotificationIcon: 'drawable/ic_stat_notify',
        preloadArtwork: true,
        // Nang tu 5s len 15s: 5s co the qua ngan tren may cham, cat ngang
        // qua trinh bind foreground service dung luc no sap thanh cong that
        // su (khong phai truong hop treo VO HAN nhu bug goc da tung gap) -
        // van giu timeout (khong bo han) de tranh treo splash vinh vien neu
        // that su rơi vao truong hop treo that.
      ).timeout(const Duration(seconds: 15));
      AudioServiceDiagnostics.recordSuccess();
    } catch (e) {
      AudioServiceDiagnostics.recordFailure(e);
      JustAudioPlatform.instance = MethodChannelJustAudio();
    }
  }

  runApp(const ProviderScope(child: LearnEnglishMusicApp()));
}

class LearnEnglishMusicApp extends StatelessWidget {
  const LearnEnglishMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      navigatorObservers: [topRouteObserver],
      title: 'GymTalk',
      debugShowCheckedModeBanner: false,
      // Nut noi "AI Voice Chat" + thanh nhac dang phat (GlobalMediaBar) chong
      // len TREN CUNG moi man hinh (bao gom ca man hinh push tu Navigator,
      // khong chi cac tab cua RootShell) - hien tren CA 3 khu vuc (Hoc Tieng
      // Anh/Fitness/Wealth) vi nhac co the tiep tuc phat du dang xem khu vuc
      // nao. Xem ai_fab_overlay.dart / global_media_bar.dart.
      builder: (context, child) => Stack(
        children: [?child, const GlobalMediaBar(), const AiFabOverlay()],
      ),
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
      // Dang ky/huy dang ky token FCM dung luc dang nhap/dang xuat - xem
      // ChatPush (khong lam gi neu chua cau hinh Firebase project).
      if (event == AuthChangeEvent.signedIn) {
        ChatPush.instance.registerCurrentUser();
      } else if (event == AuthChangeEvent.signedOut) {
        ChatPush.instance.unregister();
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
    if (!signedIn) return const SignInScreen();

    // Hien carousel gioi thieu tinh nang dung 1 lan cho MOI tai khoan, ngay
    // sau khi dang nhap/dang ky thanh cong lan dau - truoc khi vao
    // RootShell. Dung FutureProvider.family thay vi setState de tu dong
    // invalidate va chuyen man khi markSeen() xong (xem OnboardingScreen).
    final userId = session.user.id;
    final seenAsync = ref.watch(onboardingSeenProvider(userId));
    return seenAsync.when(
      data: (seen) => seen
          ? const RootShell()
          : OnboardingScreen(
              userId: userId,
              onDone: () => ref.invalidate(onboardingSeenProvider(userId)),
            ),
      loading: () => const ScreenBackground(
        child: Center(child: CircularProgressIndicator()),
      ),
      // Loi doc SharedPreferences (hau nhu khong bao gio xay ra) - uu tien
      // cho vao app thay vi ket nguoi dung o man cho vo han.
      error: (_, _) => const RootShell(),
    );
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

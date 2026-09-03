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
import 'features/fitness/presentation/fitness_shell.dart';
import 'features/onboarding/data/onboarding_repository.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/social/data/social_repository.dart';
import 'features/social/presentation/incoming_message_banner.dart';
import 'features/wealth/presentation/wealth_shell.dart';

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
      // Nut noi "AI Voice Chat" chong len TREN CUNG moi man hinh (bao gom
      // ca man hinh push tu Navigator, khong chi cac tab cua RootShell) -
      // xem ai_fab_overlay.dart. Nut nhac dang phat (CenterMediaButton)
      // KHONG con o day - da chuyen vao giua thanh menu duoi cua tung khu
      // vuc (root_shell.dart / mini_app_bottom_nav.dart) thay vi noi rieng
      // tren toan man hinh.
      builder: (context, child) =>
          Stack(children: [?child, const AiFabOverlay()]),
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
        // Khoi phuc dung Fitness/Wealth neu nguoi dung vua sign out tu 1
        // trong 2 khu vuc do (xem pendingRestoreAppSectionProvider) - khong
        // thi mac dinh RootShell (Hoc Tieng Anh) la du, khong lam gi them.
        // addPostFrameCallback vi luc nay RootShell (route "/") co the chua
        // kip mount xong trong cung frame voi su kien dang nhap.
        final pending = ref.read(pendingRestoreAppSectionProvider);
        if (pending != null && pending != AppSection.learnEnglish) {
          ref.read(pendingRestoreAppSectionProvider.notifier).state = null;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(currentAppSectionProvider.notifier).state = pending;
            final nav = rootNavigatorKey.currentState;
            if (nav == null) return;
            switch (pending) {
              case AppSection.fitness:
                nav.push(
                  MaterialPageRoute(builder: (_) => const FitnessShell()),
                );
              case AppSection.wealth:
                nav.push(
                  MaterialPageRoute(builder: (_) => const WealthShell()),
                );
              case AppSection.learnEnglish:
                break;
            }
          });
        }
      } else if (event == AuthChangeEvent.signedOut) {
        ChatPush.instance.unregister();
      }
    });

    // Popup thong bao tin nhan moi kieu Messenger - dat o _AuthGate (LUON
    // mount khi da dang nhap, bat ke dang o Hoc Tieng Anh/Fitness/Wealth)
    // thay vi trong RootShell nhu truoc - truoc day banner nay CHI hien khi
    // dang o Hoc Tieng Anh, Fitness/Wealth khong bao gio thay tin nhan moi
    // trong luc app dang mo (chi thay qua push notification he thong khi
    // app o nen).
    ref.listen(newIncomingMessageProvider, (previous, next) async {
      try {
        final message = next.valueOrNull;
        if (message == null) return;
        // await ref.read(...future) thay vi ref.read(provider).valueOrNull -
        // myFriendsProvider la autoDispose va gio it khi co man nao "watch"
        // lien tuc no (Tin nhan chi con mo dang popup, khong con la tab
        // luon mount nhu truoc), nen thuong bi dispose giua cac lan mo
        // popup. Doc cache dong bo (.valueOrNull) tra ve null moi lan nhu
        // vay, khien khong tim duoc nguoi gui va banner bi bo qua AM THAM.
        // await ban future dam bao luon co du lieu that truoc khi quyet
        // dinh co hien banner hay khong.
        final friends = await ref.read(myFriendsProvider.future);
        SocialUser? sender;
        for (final f in friends) {
          if (f.id == message.senderId) {
            sender = f;
            break;
          }
        }
        // KHONG bo qua banner chi vi khong khop duoc voi danh sach ban be
        // (vd danh sach chua kip lam moi) - van hien banner voi thong tin
        // toi thieu (id) thay vi im lang mat luon thong bao that su.
        sender ??= SocialUser(
          id: message.senderId,
          username: null,
          displayName: null,
          avatarUrl: null,
        );
        // Dung context CUA NAVIGATOR GOC (khong dung `context` cua chinh
        // _AuthGate) - dam bao luon la 1 context nam trong Overlay dang
        // hoat dong, tranh moi kha nang be gay do vi tri Widget nay nam o
        // trong cay (giong bai hoc rut ra tu loi nut AI Voice Chat).
        final overlayContext = rootNavigatorKey.currentContext;
        if (overlayContext == null || !overlayContext.mounted) return;
        showIncomingMessageBanner(
          overlayContext,
          sender: sender,
          preview: message.previewText,
          messageId: message.id,
        );
      } catch (e, st) {
        // KHONG de 1 loi bat ngo (vd parse tin nhan la) lam "chet" ca
        // listener nay cho phan con lai cua phien - ghi log de con chan
        // doan tiep neu van con loi ke sau khi fix nay.
        debugPrint('Loi hien banner tin nhan moi: $e\n$st');
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

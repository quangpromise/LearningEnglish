import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifications/chat_push.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../../features/menu/presentation/menu_screen.dart';
import '../../features/music_player/presentation/home_screen.dart';
import '../../features/music_player/presentation/mini_player.dart';
import '../../features/pronunciation/presentation/pronunciation_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/social/data/social_repository.dart';
import '../../features/social/presentation/incoming_message_banner.dart';
import '../../features/update/presentation/update_dialog.dart';

class RootShell extends ConsumerStatefulWidget {
  const RootShell({super.key});

  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<RootShell>
    with WidgetsBindingObserver {
  int _tab = 0;

  // Vocabulary va Grammar khong phai tab rieng - da chuyen thanh the truy
  // cap nhanh ngay tren man Home (xem home_screen.dart). Reading va Quiz
  // cung khong con la tab rieng - gom vao man Menu (tab cuoi cung) de
  // thanh dieu huong duoi khong bi qua nhieu icon. AI Voice Chat cung
  // khong con la tab rieng - da chuyen thanh nut noi (xem ai_fab_overlay.dart)
  // hien tren MOI man hinh cua app thay vi chiem 1 cho co dinh o thanh tab.
  //
  // Khong con la list const: PronunciationScreen can biet no co dang la tab
  // dang active hay khong (qua [isActive]) de tu doi cau luyen moi moi lan
  // nguoi dung quay lai tab nay - IndexedStack giu nguyen state cua tat ca
  // tab, initState() chi chay 1 lan duy nhat luc mo app nen khong tu doi cau
  // duoc neu khong co co che nay.
  List<Widget> _buildScreens() => [
    const HomeScreen(),
    PronunciationScreen(isActive: _tab == 1),
    const ProfileScreen(),
    const MenuScreen(),
  ];

  static const _icons = [
    Icons.home_rounded,
    Icons.mic_rounded,
    Icons.person_rounded,
    Icons.menu_rounded,
  ];

  static const _pronunciationTabIndex = 1;

  void _setTab(int i) {
    setState(() => _tab = i);
    ref.read(pronunciationTabActiveProvider.notifier).state =
        i == _pronunciationTabIndex;
  }

  Timer? _updateCheckTimer;
  Timer? _presenceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => showUpdateDialogIfAvailable(context),
    );
    // Ngoai kiem tra luc mo app/resume, kiem tra dinh ky moi 15 phut - phong
    // truong hop nguoi dung khong bao gio dua app xuong nen (didChange
    // AppLifecycleState.resumed se khong bao gio ban), ho van thay thong
    // bao neu ban build moi duoc publish trong luc dang dung app.
    _updateCheckTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      if (mounted) showUpdateDialogIfAvailable(context);
    });
    // "Dang online" duoc tinh o server bang last_seen_at trong vong 90s gan
    // nhat (xem my_friends() trong migration) - can heartbeat thuong xuyen
    // hon khoang do de ban be thay minh dang online chinh xac trong luc app
    // dang mo o foreground.
    ref.read(socialRepositoryProvider).updatePresence().catchError((_) {});
    _presenceTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      ref.read(socialRepositoryProvider).updatePresence().catchError((_) {});
    });
    ChatPush.instance.registerIfSignedInAndNotYet();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updateCheckTimer?.cancel();
    _presenceTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Truoc day chi kiem tra cap nhat 1 lan luc app moi mo - neu ban build
    // moi duoc publish trong luc app dang mo san, nguoi dung khong bao gio
    // thay thong bao tru khi tat han app roi mo lai. Kiem tra lai moi khi
    // app quay lai foreground.
    if (state == AppLifecycleState.resumed && mounted) {
      showUpdateDialogIfAvailable(context);
      ref.read(socialRepositoryProvider).updatePresence().catchError((_) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Bam pop-up thong bao tin nhan moi kieu Messenger - hoat dong tren
    // BAT KY tab nao dang mo, chi khi app dang chay (khong phai push
    // notification he thong, xem ghi chu trong incoming_message_banner.dart).
    ref.listen(newIncomingMessageProvider, (previous, next) {
      final message = next.valueOrNull;
      if (message == null) return;
      final friends = ref.read(myFriendsProvider).valueOrNull ?? const [];
      SocialUser? sender;
      for (final f in friends) {
        if (f.id == message.senderId) {
          sender = f;
          break;
        }
      }
      if (sender == null) return;
      showIncomingMessageBanner(
        context,
        sender: sender,
        preview: message.content,
      );
    });

    return Scaffold(
      backgroundColor: AppColors.bgTop,
      body: IndexedStack(index: _tab, children: _buildScreens()),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xD90A0E1C),
                border: Border.all(color: AppColors.glassBorder),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_icons.length, (i) {
                  final active = i == _tab;
                  return GestureDetector(
                    onTap: () => _setTab(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      width: active ? 76 : 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: active
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.transparent,
                        border: active
                            ? Border.all(
                                color: Colors.white.withValues(alpha: 0.35),
                              )
                            : null,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Icon(
                        _icons[i],
                        size: 22,
                        color: active ? Colors.white : AppColors.textMuted,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

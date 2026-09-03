import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifications/chat_push.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../../features/music_player/presentation/center_media_button.dart';
import '../../features/music_player/presentation/home_screen.dart';
import '../../features/social/data/social_repository.dart';
import '../../features/social/presentation/conversations_screen.dart';
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

  // Vocabulary, Grammar va Phonics (bai hoc phat am IPA) khong phai tab
  // rieng - da chuyen thanh the truy cap nhanh ngay tren man Home (xem
  // home_screen.dart). Da bo han tab Menu - Reading/Quiz/Fitness/Crypto/
  // Attribution (truoc gom trong Menu) gio vao thang tu Home theo nhom danh
  // muc, khong con man Menu rieng. AI Voice Chat khong phai tab rieng - da
  // chuyen thanh nut noi (xem ai_fab_overlay.dart) hien tren MOI man hinh
  // cua app thay vi chiem 1 cho co dinh o thanh tab. Tin nhan truoc la 1 nut
  // rieng o header Home, gio chuyen thanh 1 tab canh Ho so cho de tim hon.
  //
  // "Luyen phat am" (PronunciationScreen) KHONG con la tab rieng - da chuyen
  // thanh 1 the truy cap nhanh trong nhom "Nghe noi" tren Home (dung 1 cho
  // MotORBIT voi Phonics), giai phong 1 vi tri o thanh Menu cho thanh nhac
  // dai (CenterMediaButton) chiem khoang giua.
  //
  // Da bo tab Ho so - vao qua nut xo xuong canh avatar tren Home
  // (profile_quick_popup.dart) thay vi chiem 1 cho co dinh tren thanh tab.
  //
  // MOI TAB CO 1 Navigator RIENG (persistent-tab pattern) - man con (vd
  // PhonicsLessonsScreen tu Home) duoc push VAO NAVIGATOR CUA TAB DO thay vi
  // Navigator goc, nen Scaffold ngoai cung (voi bottomNavigationBar =
  // thanh Menu + CenterMediaButton) KHONG BAO GIO bi che - dap ung yeu cau
  // "Menu bar nen dai dien o TAT CA man hinh cua app". [NavigatorPopHandler]
  // dam bao nut back he thong tra ve dung Navigator cua tab dang mo thay vi
  // luon roi ve Navigator goc (mac dinh cua Flutter).
  final _homeNavKey = GlobalKey<NavigatorState>();
  final _messagesNavKey = GlobalKey<NavigatorState>();

  List<GlobalKey<NavigatorState>> get _tabNavKeys => [
    _homeNavKey,
    _messagesNavKey,
  ];

  List<Widget> _buildScreens() => [
    Navigator(
      key: _homeNavKey,
      onGenerateRoute: (_) =>
          MaterialPageRoute(builder: (_) => const HomeScreen()),
    ),
    Navigator(
      key: _messagesNavKey,
      onGenerateRoute: (_) =>
          MaterialPageRoute(builder: (_) => const ConversationsScreen()),
    ),
  ];

  static const _icons = [Icons.home_rounded, Icons.chat_bubble_rounded];

  static const _messagesTabIndex = 1;

  void _setTab(int i) => setState(() => _tab = i);

  Timer? _updateCheckTimer;
  Timer? _presenceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showUpdateDialogIfAvailable(context);
    });
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
        preview: message.previewText,
        messageId: message.id,
      );
    });

    return Scaffold(
      backgroundColor: AppColors.bgTop,
      body: NavigatorPopHandler(
        onPopWithResult: (result) {
          final nav = _tabNavKeys[_tab].currentState;
          if (nav != null && nav.canPop()) nav.pop(result);
        },
        child: IndexedStack(index: _tab, children: _buildScreens()),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
            children: [
              _TabIcon(
                icon: _icons[0],
                active: _tab == 0,
                onTap: () => _setTab(0),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: const CenterMediaButton(accentColor: AppColors.blue),
              ),
              const SizedBox(width: 6),
              Builder(
                builder: (context) {
                  final unread =
                      ref.watch(unreadMessageCountProvider).valueOrNull ?? 0;
                  return _TabIcon(
                    icon: _icons[_messagesTabIndex],
                    active: _tab == _messagesTabIndex,
                    badge: unread,
                    onTap: () => _setTab(_messagesTabIndex),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 1 nut icon tab (Home/Tin nhan) o 2 dau thanh Menu - tach rieng thanh
/// widget de con lai o giua danh cho CenterMediaButton (Expanded).
class _TabIcon extends StatelessWidget {
  const _TabIcon({
    required this.icon,
    required this.active,
    required this.onTap,
    this.badge = 0,
  });
  final IconData icon;
  final bool active;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.transparent,
          border: active
              ? Border.all(color: Colors.white.withValues(alpha: 0.35))
              : null,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              size: 22,
              color: active ? Colors.white : AppColors.textMuted,
            ),
            if (badge > 0)
              Positioned(
                right: -4,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  constraints: const BoxConstraints(
                    minWidth: 15,
                    minHeight: 15,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.pink,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xD90A0E1C),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    badge > 9 ? '9+' : '$badge',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

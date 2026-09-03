import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifications/chat_push.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import 'app_popup.dart';
import '../../features/music_player/presentation/center_media_button.dart';
import '../../features/music_player/presentation/home_screen.dart';
import '../../features/social/data/social_repository.dart';
import '../../features/social/presentation/conversations_screen.dart';
import '../../features/social/presentation/incoming_message_banner.dart';
import '../../features/update/presentation/update_dialog.dart';

/// Man goc cua Hoc Tieng Anh - CHI CON 1 man hinh that su (HomeScreen), moi
/// tinh nang khac (Phonics, Story, Vocabulary, Grammar, Reading, Quiz, Luyen
/// phat am...) va Tin nhan gio deu mo len dang POPUP tu Home (xem
/// app_popup.dart) thay vi la tab/man rieng - nen thanh Menu KHONG CON nut
/// Home nua (Home la man duy nhat, luon nam duoi popup), chi con thanh nhac
/// dai + 1 nut Tin nhan (mo popup).
class RootShell extends ConsumerStatefulWidget {
  const RootShell({super.key});

  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<RootShell>
    with WidgetsBindingObserver {
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
    // BAT KY man hinh nao dang mo, chi khi app dang chay (khong phai push
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

    final unread = ref.watch(unreadMessageCountProvider).valueOrNull ?? 0;

    return Scaffold(
      backgroundColor: AppColors.bgTop,
      body: const HomeScreen(),
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
              const Expanded(
                child: CenterMediaButton(accentColor: AppColors.blue),
              ),
              const SizedBox(width: 6),
              _MessagesButton(
                unread: unread,
                onTap: () => openAppPopup(context, const ConversationsScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Nut Tin nhan duy nhat con lai o thanh Menu - mo popup thay vi chuyen tab
/// (khong con khai niem "tab dang active" vi Home la man duy nhat).
class _MessagesButton extends StatelessWidget {
  const _MessagesButton({required this.unread, required this.onTap});
  final int unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.chat_bubble_rounded,
              size: 22,
              color: AppColors.textMuted,
            ),
            if (unread > 0)
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
                    unread > 9 ? '9+' : '$unread',
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

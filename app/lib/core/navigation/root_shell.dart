import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifications/chat_push.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../../features/music_player/presentation/center_media_button.dart';
import '../../features/music_player/presentation/home_screen.dart';
import '../../features/social/data/social_repository.dart';
import '../../features/social/presentation/incoming_message_banner.dart';
import '../../features/update/presentation/update_dialog.dart';

/// Man goc cua Hoc Tieng Anh - CHI CON 1 man hinh that su (HomeScreen), moi
/// tinh nang khac (Phonics, Story, Vocabulary, Grammar, Reading, Quiz, Luyen
/// phat am...) va Tin nhan gio deu mo len dang POPUP tu Home (xem
/// app_popup.dart) thay vi la tab/man rieng. Nut Tin nhan da chuyen len
/// headpage (AppTopBar, ngay sau dong "Hello, ten" - xem home_screen.dart)
/// nen thanh Menu duoi khong con icon nao, chi con thanh nhac dai chiem het
/// chieu rong.
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

    return Scaffold(
      backgroundColor: AppColors.bgTop,
      body: const HomeScreen(),
      // Khong con boc them 1 Container trang tri rieng nhu truoc (Menu
      // truoc day can no de xep icon Home/Tin nhan CANH thanh nhac) - gio
      // Menu CHI CON thanh nhac, boc 2 lop pill long nhau tao khoang trong
      // thua/lech kich thuoc so voi Menu cu. CenterMediaButton tu ve pill
      // day du (full size nhu Menu cu) o day, chi con Padding le ngoai.
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: CenterMediaButton(accentColor: AppColors.blue),
      ),
    );
  }
}

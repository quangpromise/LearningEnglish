import 'package:flutter/material.dart';

/// Navigator key toan cuc - can thiet de dieu huong khi bam vao thong bao
/// nhac quiz (flutter_local_notifications goi callback khong co BuildContext,
/// ke ca khi app dang o trang thai bi tat hoan toan va duoc mo lai tu
/// thong bao).
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Ten route dat cho AiVoiceChatScreen (xem ai_fab_overlay.dart) - dung voi
/// [topRouteObserver] de biet chinh xac man hinh do co dang mo hay khong,
/// on dinh hon nhieu so voi tu doi 1 Riverpod state trong initState/dispose
/// cua chinh man hinh do (de bi lo dong bo neu dispose khong chay dung luc
/// mong doi).
const kAiVoiceChatRouteName = '/ai-voice-chat';

/// Theo doi route dang hien tren cung cua Navigator goc - dung de an nut
/// noi AI Voice Chat CHINH XAC khi dang o man hinh do, khong phu thuoc vao
/// timing cua initState/dispose ben trong man hinh duoc push.
class TopRouteObserver extends NavigatorObserver {
  final ValueNotifier<String?> currentRouteName = ValueNotifier(null);

  void _update(Route<dynamic>? route) {
    currentRouteName.value = route?.settings.name;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _update(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _update(previousRoute);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _update(previousRoute);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _update(newRoute);
}

final topRouteObserver = TopRouteObserver();

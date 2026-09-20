import '../../../core/navigation/app_popup.dart';
import '../../../core/navigation/nav_keys.dart';
import 'football_center_screen.dart';

/// Mo Football Center khi nguoi dung bam vao thong bao bong da.
///
/// Dat o day (khong phai trong chat_push.dart) de tang thong bao KHONG phai
/// biet chi tiet man hinh cua tinh nang - giong cach planner dang lam voi
/// openPlannerFromNotification.
///
/// Dung rootNavigatorKey.currentContext chu khong phai context cua widget
/// nao: ham nay duoc goi tu callback cua flutter_local_notifications, khong
/// co BuildContext nao ca (ke ca khi app vua khoi dong lai tu thong bao).
void openFootballFromNotification(String fixtureId) {
  final navContext = rootNavigatorKey.currentContext;
  if (navContext == null) return;
  // fixtureId hong/rong (payload cu, du lieu la) -> van mo duoc man goc thay
  // vi khong lam gi ca, nguoi dung bam thong bao ma khong thay phan ung se
  // tuong app hong.
  final id = int.tryParse(fixtureId);
  openAppPopup(navContext, FootballCenterScreen(initialFixtureId: id));
}

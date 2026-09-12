import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../features/vocabulary/presentation/daily_quiz_popup_screen.dart';
import '../navigation/nav_keys.dart';
import '../utils/vn_time.dart';

/// Nhac hoc "10 tu hom nay" bang thong bao he thong dat lich truoc - hoat
/// dong ca khi app da bi dong/khoa may, vi lich duoc AlarmManager (Android)
/// giu san chu khong phu thuoc tien trinh app con song. Xem
/// docs/research-notifications.md de biet ly do chon package nay thay vi
/// Timer trong app, va cac gioi han quyen lien quan.
class DailyQuizNotifications {
  DailyQuizNotifications._();
  static final instance = DailyQuizNotifications._();

  static const _channelId = 'daily_quiz_reminder';
  static const _channelName = 'Nhắc học từ vựng';
  static const _channelDesc =
      'Thông báo nhắc làm quiz cho các từ đang học hôm nay';
  static const _idBase = 9000;
  static const _maxScheduled = 48;

  // Do lech co y giua thong bao he thong (AlarmManager) va Timer trong tien
  // trinh app (xem scheduleForegroundAutoOpen) - ca 2 cung nham 1 thoi diem
  // "den han", nhung THONG BAO duoc dat tre hon [_foregroundGraceDelay] de
  // Timer trong app (chinh xac hon, chay ngay lap tuc khi den han NEU app
  // dang mo) co co hoi chay TRUOC va HUY thong bao tuong ung (xem
  // _maybeAutoOpenQuiz) truoc khi no kip hien - tranh vua tu mo man Quiz
  // VUA hien them 1 thong bao thua khi app dang mo san. Neu app dang o
  // nen/khoa may (Timer khong chay dung luc), thong bao van hien binh
  // thuong sau do nhu 1 phuong an du phong.
  static const _foregroundGraceDelay = Duration(seconds: 20);

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Thong bao he thong (scheduleReminders o tren) chi TU MO man Quiz khi
  // nguoi dung CHAM vao no - neu dang mo san app luc den han, thong bao van
  // hien nhung de bi bo qua/luot tat vi khong "bat buoc" nhu 1 alarm that.
  // Timer rieng nay (chay TRONG tien trinh app, KHONG thay the notification
  // o tren - notification van can de bao khi app o nen/da dong) tu dong
  // DAY man Quiz len ngay khi den han, NEU app dang o foreground (resumed) -
  // giong cam giac 1 alarm bat thang man hinh, khong can nguoi dung tu bam.
  Timer? _foregroundTimer;
  bool _quizShowing = false;

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();

    // Xem giai thich chi tiet trong chat_push.dart: icon nho tren thanh trang
    // thai PHAI la hinh trang/trong suot don gian, khong phai icon app day mau.
    const androidInit = AndroidInitializationSettings(
      '@drawable/ic_stat_notify',
    );
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onTap,
    );

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    try {
      await androidImpl?.requestNotificationsPermission();
      await androidImpl?.requestExactAlarmsPermission();
    } catch (_) {
      // Thiet bi/OS cu khong ho tro 1 trong 2 quyen nay - bo qua, thong bao
      // van hoat dong (chi khong chinh xac tuyet doi ve gio neu thieu quyen
      // exact alarm).
    }

    _initialized = true;

    // Truong hop app dang BI DONG HOAN TOAN (vd dang o man hinh khoa lau,
    // tien trinh da bi he thong don) va nguoi dung bam vao thong bao -
    // plugin se KHOI DONG LAI app tu dau NHUNG onDidReceiveNotificationResponse
    // o tren KHONG duoc goi cho chinh lan bam gay khoi dong nay (chi goi cho
    // cac lan bam trong luc app DA dang chay san) - phai tu kiem tra rieng
    // qua getNotificationAppLaunchDetails() moi biet duoc, day chinh la
    // nguyen nhan loi "bam thong bao tu man hinh khoa chi mo app chu chua
    // vao man Quiz". Push sau addPostFrameCallback vi luc ham init() nay
    // chay (truoc runApp() trong main.dart), rootNavigatorKey chua gan voi
    // Navigator nao ca - phai doi frame dau tien duoc ve xong.
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _pushQuiz());
    }
  }

  static void _onTap(NotificationResponse response) {
    instance._pushQuiz();
  }

  /// Dat lich thong bao moi [intervalMinutes] phut, tu bay gio den het ngay
  /// hom nay (khong lap sang ngay mai) - toi da [_maxScheduled] thong bao de
  /// tranh dat qua nhieu alarm cung luc.
  Future<void> scheduleReminders({required int intervalMinutes}) async {
    await cancelReminders();
    if (intervalMinutes <= 0) return;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    final now = DateTime.now();
    // Gioi han theo NUA DEM GIO VIET NAM (khong phai gio thiet bi) - dung
    // yeu cau "het ngay gio Viet Nam thi tu dong ket thuc".
    final endOfDay = nextVnMidnightInstant();
    var occurrence = now.add(Duration(minutes: intervalMinutes));
    var count = 0;
    while (occurrence.isBefore(endOfDay) && count < _maxScheduled) {
      // TZDateTime.from doi theo THOI DIEM tuyet doi cua DateTime goc, nen
      // dung tz.UTC lam Location khong lam sai gio bao thuc te - khong can
      // them package do mui gio thiet bi (flutter_timezone) chi de tinh
      // "bay gio + X phut". Cong them _foregroundGraceDelay CHI cho thoi
      // diem HIEN THONG BAO THUC SU (khong doi "occurrence" dung de tinh
      // vong lap/lan ke tiep) - xem doc _foregroundGraceDelay o tren.
      final scheduled = tz.TZDateTime.from(
        occurrence.add(_foregroundGraceDelay),
        tz.UTC,
      );
      await _scheduleOne(_idBase + count, scheduled, details);
      occurrence = occurrence.add(Duration(minutes: intervalMinutes));
      count++;
    }
  }

  Future<void> _scheduleOne(
    int id,
    tz.TZDateTime scheduled,
    NotificationDetails details,
  ) async {
    const title = 'Đến giờ ôn từ vựng!';
    const body = 'Chạm để làm quiz nhanh cho các từ bạn đang học hôm nay';
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduled,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {
      // He thong tu choi exact alarm (thieu quyen "Alarms & reminders") -
      // thu lai kieu khong chinh xac tuyet doi, thong bao van hien nhung co
      // the tre vai phut so voi lich dat.
      try {
        await _plugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduled,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } catch (_) {}
    }
  }

  Future<void> cancelReminders() async {
    for (var i = 0; i < _maxScheduled; i++) {
      await _plugin.cancel(id: _idBase + i);
    }
  }

  /// Bat Timer trong tien trinh app, cu moi [intervalMinutes] phut lai kiem
  /// tra + tu day man Quiz len NEU app dang o foreground luc do (xem
  /// _maybeAutoOpenQuiz) - goi CUNG LUC voi scheduleReminders() o tren (xem
  /// DailyWordsController._rescheduleReminders), KHONG thay the no.
  void scheduleForegroundAutoOpen({required int intervalMinutes}) {
    _foregroundTimer?.cancel();
    if (intervalMinutes <= 0) return;
    // Chi so lan "tick" - khop VOI DUNG count dang dung o scheduleReminders
    // o tren (ca 2 cung bat dau tu 0, cung dat lai ve 0 moi lan ham nay
    // duoc goi lai) de biet chinh xac ID thong bao nao dang "cho" ung voi
    // lan den han hien tai, phuc vu huy no o _maybeAutoOpenQuiz.
    var tick = 0;
    _foregroundTimer = Timer.periodic(Duration(minutes: intervalMinutes), (_) {
      _maybeAutoOpenQuiz(occurrenceIndex: tick);
      tick++;
    });
  }

  void cancelForegroundAutoOpen() {
    _foregroundTimer?.cancel();
    _foregroundTimer = null;
  }

  void _maybeAutoOpenQuiz({required int occurrenceIndex}) {
    // Bo qua khi app dang o nen/da khoa may - thong bao he thong o tren se
    // lo viec nhac trong truong hop nay, TU MO man Quiz luc do se khong ai
    // thay va co the gay loi dieu huong khi nguoi dung mo lai app sau.
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    // Huy truoc thong bao he thong TUONG UNG cua dung lan den han nay (con
    // dang doi them _foregroundGraceDelay nua moi thuc su hien, xem
    // scheduleReminders) - vi app dang mo san va sap tu day man Quiz len
    // ngay day, khong can thong bao do hien nua (tranh hien CHONG 2 lan).
    _plugin.cancel(id: _idBase + occurrenceIndex);
    _pushQuiz();
  }

  /// Day man Quiz len TRUC TIEP (khong qua route Navigator.push binh
  /// thuong tu widget nao) - dung chung cho ca 2 duong: bam vao thong bao
  /// he thong (_onTap) VA tu dong bat khi den han luc app dang mo
  /// (_maybeAutoOpenQuiz). Co _quizShowing de tranh day CHONG 2 lan cung 1
  /// man (vd nguoi dung dang lam quiz tu lan nhac truoc, chua kip dong, thi
  /// lan nhac tiep theo lai bam/den han).
  Future<void> _pushQuiz() async {
    if (_quizShowing) return;
    final nav = rootNavigatorKey.currentState;
    if (nav == null) return;
    _quizShowing = true;
    await nav.push(
      MaterialPageRoute(builder: (_) => const DailyQuizPopupScreen()),
    );
    _quizShowing = false;
  }
}

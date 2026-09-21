import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

import 'heart_rate_model.dart';
import 'ppg_analyzer.dart';

/// Thoi gian do 1 lan (giay).
const kHeartRateMeasureSeconds = 30;

/// Nhan biet "ngon tay da che kin ong kinh + den flash" bang SAC DO chu
/// khong bang do sang.
///
/// Do sang tuyet doi khong dung duoc lam moc: anh sang xuyen qua dau ngon
/// tay ra mau do tham, ma do sang (luma) cua mau do von da thap - do do
/// 255,0,0 chi cho luma ~76 - lai con phu thuoc vao muc phoi sang may tu
/// chon va vao viec nguoi dung an manh hay nhe. Dat nguong luma kieu gi
/// cung sai voi mot nhom may nao do (da thu 90 roi 55, deu bao nham).
///
/// Nguoc lai, SAC thi rat ro rang: da nguoi duoc den flash roi xuyen qua
/// cho ra mau do bao hoa, tuc kenh V (Cr) cao hon han kenh U (Cb). Canh
/// bat ky thu gi khac - mat ban, tran nha, khong khi - deu trung tinh hon
/// nhieu. Hieu so nay gan nhu khong doi theo muc phoi sang.
///
/// Muc 30 tung dat o day la qua chat: may thu nghiem do duoc dung 31, tuc
/// sat nguong, nen chi khoang mot nua so khung hinh lot qua va lan do bi
/// loai oan. Canh trung tinh chi cho vai don vi, nen 12 van phan biet duoc
/// thoai mai.
const _kCoveredMinRedness = 12.0;

/// San toi tuyet doi: neu khung hinh gan nhu den thi den flash khong bat
/// duoc (hoac ong kinh bi bit hoan toan), luc do sac mau khong con y nghia.
const _kCoveredMinBrightness = 12.0;

/// Thoi gian bo dau moi lan do. Ngay sau khi bat torch, camera con dang tu
/// dong can bang sang/trang: do sang khung hinh nhay bac rat manh trong
/// 1-2 giay dau va se lam hong phan phan tich neu dua vao. Doan nay van
/// tinh vao thanh tien do de nguoi dung khong phai cho them.
const _kWarmUpMs = 3000;

/// Con bat lai den trong bao lau neu khung hinh van chua ra mau ngon tay.
/// Du rong de cuu duoc lan do, nhung van con thua thoi gian cho 1 doan tin
/// hieu dai hon [_kMinCoveredMs] o phan con lai.
const _kTorchRetryUntilMs = 12000;

/// Doan lien tuc co ngon tay phai dai it nhat bao nhieu thi moi phan tich.
/// Thay cho luat "phai co ngon tay o X% tong so khung hinh" truoc day: cai
/// dang can khong phai la ti le tren ca lan do, ma la co du 1 doan tin
/// hieu sach de dem nhip hay khong.
const _kMinCoveredMs = 10000;

/// Hop dong do nhip tim - man hinh CHI biet den giao dien nay, khong biet
/// dang do bang camera hay bang thiet bi deo. Nho vay sau nay ghep vong deo
/// tay chi can them 1 lop hien thuc moi, khong sua UI.
abstract class HeartRateService {
  /// Tien do 0..1 cua lan do dang chay.
  ValueListenable<double> get progress;

  /// Tin hieu PPG thoi gian thuc (da chuan hoa) de ve duong song khi dang
  /// do - rong khi chua du du lieu.
  ValueListenable<List<double>> get liveWaveform;

  /// true khi he thong tin rang ong kinh dang bi che dung cach. UI dung co
  /// nay de nhac "Dat ngon tay len camera".
  ValueListenable<bool> get sensorCovered;

  /// Vai con so tho ve khung hinh dang thu (do sang, sac do). Hien duoi
  /// dang dong chu nho khi dang do, de nguoi dung thay ngay may CO dang
  /// nhan du lieu hay khong thay vi cho het 30 giay moi biet.
  ValueListenable<String> get signalInfo;

  /// Chay tron 1 lan do. Luon tra ve ket qua (thanh cong HOAC ly do that
  /// bai) - KHONG BAO GIO bia ra 1 con so khi tin hieu khong dat.
  Future<HeartRateResult> measure();

  /// Dung giua chung (nguoi dung bam huy hoac roi man hinh).
  Future<void> cancel();

  Future<void> dispose();
}

/// Do nhip tim bang camera sau + den flash (phuong phap PPG: anh sang xuyen
/// qua dau ngon tay, luong mau moi nhip lam do sang khung hinh thay doi rat
/// nho theo chu ky - xem ppg_analyzer.dart cho phan xu ly tin hieu).
///
/// Han che da biet, CO Y de nguyen thay vi che giau:
///  - Do chinh xac phu thuoc manh vao viec nguoi dung giu yen tay. Neu tin
///    hieu nhieu, [measure] tra ve [HeartRateFailure.signalTooNoisy] de man
///    hinh bao "Khong do duoc" chu khong doan bua.
///  - Day KHONG phai thiet bi y te. Ket qua chi de tham khao khi tap.
class CameraHeartRateService implements HeartRateService {
  CameraHeartRateService();

  CameraController? _controller;
  Completer<HeartRateResult>? _completer;
  final _samples = <PpgSample>[];

  /// Sac do cua tung khung hinh, cung chi so voi [_samples].
  final _redness = <double>[];
  Stopwatch? _clock;
  Timer? _noFrameTimer;
  Timer? _timeoutTimer;
  Timer? _torchTimer;
  bool _cancelled = false;
  bool _finishing = false;
  bool _finishScheduled = false;
  bool _measuring = false;

  /// Buoc gan nhat trong quy trinh mo camera - de khi hong thi man bao loi
  /// noi duoc no ket o dau, thay vi de doan.
  String _stage = 'chua bat dau';
  String _cameraInfo = 'cam ?';
  String _torchInfo = 'den ?';

  final _progress = ValueNotifier<double>(0);
  final _liveWaveform = ValueNotifier<List<double>>(const []);
  final _covered = ValueNotifier<bool>(false);
  final _signalInfo = ValueNotifier<String>('');

  @override
  ValueListenable<double> get progress => _progress;
  @override
  ValueListenable<List<double>> get liveWaveform => _liveWaveform;
  @override
  ValueListenable<bool> get sensorCovered => _covered;
  @override
  ValueListenable<String> get signalInfo => _signalInfo;

  @override
  Future<HeartRateResult> measure() async {
    _cancelled = false;
    _finishing = false;
    _finishScheduled = false;
    _measuring = false;
    _stage = 'chuan bi';
    _cameraInfo = 'cam ?';
    _torchInfo = 'den ?';
    _samples.clear();
    _redness.clear();
    _progress.value = 0;
    _liveWaveform.value = const [];
    _covered.value = false;
    // Co san 1 dong chu tu day, de khi camera khong chay thi man hinh noi
    // duoc no dang ket o buoc nao thay vi im lang.
    _signalInfo.value = 'dang mo camera...';

    final completer = Completer<HeartRateResult>();
    _completer = completer;

    // Bat dong ho canh gio NGAY, truoc ca khi dong vao camera. Buoc mo
    // camera cung co the treo (da gap: tu lan do thu hai tro di,
    // startImageStream khong bao gio tra ve, man hinh dung yen va phai tat
    // han app) - dat canh gio sau buoc do thi chinh no cung khong chay.
    _startWatchdogs();

    try {
      final controller = await _ensureCameraRunning();
      _stage = 'dang do';
      _clock = Stopwatch()..start();
      _measuring = true;
      unawaited(_enableTorchAndLock(controller));
    } catch (error) {
      await _stopCamera();
      if (!completer.isCompleted) {
        completer.complete(
          HeartRateResult.failed(
            HeartRateFailure.cameraUnavailable,
            debugInfo: 'ket o buoc "$_stage" · $_cameraInfo · $error',
          ),
        );
      }
    }
    return completer.future;
  }

  /// Mo camera va luong khung hinh NEU chua chay, va chi khi do.
  ///
  /// Doi lan thu 3 sua loi "do lai thi khong nhan duoc du lieu". Hai lan
  /// truoc deu di theo huong "dong cho sach roi mo lai cho chuan" va deu
  /// khong an. Lan nay bo han viec dong/mo lai: camera va luong khung hinh
  /// chay lien tuc suot thoi gian o man hinh nay, giua cac lan do chi bat
  /// tat viec LAY MAU va den flash. Khong con buoc dong/mo thi cung khong
  /// con cho de ket.
  ///
  /// Doi lai camera mo lau hon - chap nhan duoc vi day la man hinh chuyen
  /// de do nhip tim, va [dispose] van dong han camera khi roi man hinh.
  Future<CameraController> _ensureCameraRunning() async {
    final existing = _controller;
    if (existing != null &&
        existing.value.isInitialized &&
        existing.value.isStreamingImages &&
        !existing.value.hasError) {
      _stage = 'dung lai camera dang mo';
      return existing;
    }
    // Co controller nhung khong dung duoc nua - bo han roi lam lai tu dau.
    if (existing != null) await _stopCamera();

    _stage = 'tim camera';
    final cameras = await availableCameras();
    final back = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    _cameraInfo =
        'cam ${back.name}'
        '${cameras.length > 1 ? '/${cameras.length}' : ''}';
    final controller = CameraController(
      back,
      // Do phan giai THAP nhat co the: ta chi can do sang trung binh, anh
      // cang nho thi moi khung hinh cang nhanh (nhieu mau/giay hon) va it
      // ton CPU - quan trong vi phai xu ly lien tuc 30 giay.
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    _stage = 'khoi tao camera';
    await controller.initialize();
    _controller = controller;
    // Mo luong khung hinh TRUOC khi bat den. Bat den truoc roi moi mo luong
    // thi phien chup bi dung lai de cau hinh lai, va tren nhieu may Android
    // den tat theo - luc do ta quay phim dau ngon tay trong bong toi.
    _stage = 'mo luong hinh';
    await controller.startImageStream(_onFrame);
    return controller;
  }

  /// Ket thuc 1 lan do nhung GIU camera lai: tat den, dung dong ho, thoi
  /// lay mau. Camera chi bi dong han o [dispose].
  Future<void> _stopMeasuring() async {
    _measuring = false;
    _cancelWatchdogs();
    _clock?.stop();
    _clock = null;
    final controller = _controller;
    if (controller == null) return;
    try {
      await controller.setFlashMode(FlashMode.off);
    } catch (_) {
      // Camera co the da bi he thong thu hoi (goi den, khoa may).
    }
  }

  /// Hai cai phanh cho truong hop luong khung hinh khong chay.
  ///
  /// Truoc day [_finish] chi duoc goi tu trong [_onFrame], nghia la neu
  /// camera khong tra ve khung hinh nao (bi thu hoi, mo that bai, hoac
  /// luong dung giua chung) thi man hinh dung nguyen o mot muc phan tram
  /// va cho mai - khong bao loi, khong tu thoat.
  void _startWatchdogs() {
    _cancelWatchdogs();
    _noFrameTimer = Timer(const Duration(seconds: 9), () {
      if (_samples.isNotEmpty) return;
      final completer = _completer;
      if (completer == null || completer.isCompleted) return;
      _stopMeasuring();
      completer.complete(
        HeartRateResult.failed(
          HeartRateFailure.cameraUnavailable,
          debugInfo:
              'khong nhan duoc khung hinh · ket o buoc "$_stage" · '
              '$_cameraInfo · $_torchInfo',
        ),
      );
    });
    // Du rong de luong khung hinh cham van kip ve dich; chi de cuu truong
    // hop luong tat han giua chung.
    _timeoutTimer = Timer(
      const Duration(seconds: kHeartRateMeasureSeconds + 15),
      () => _finish(),
    );
  }

  void _cancelWatchdogs() {
    _noFrameTimer?.cancel();
    _noFrameTimer = null;
    _timeoutTimer?.cancel();
    _torchTimer?.cancel();
    _torchTimer = null;
    _timeoutTimer = null;
  }

  /// Bat den flash roi khoa phoi sang + lay net.
  ///
  /// Den flash duoc bat HAI lan, cach nhau mot nhip: lan dau ngay sau khi
  /// luong khung hinh chay, lan sau de bat lai neu may tu tat den luc cau
  /// hinh lai phien chup. Khong co den thi khong co gi de do - anh sang
  /// phai xuyen qua dau ngon tay thi moi thay duoc luong mau.
  ///
  /// Khoa phoi sang cung quan trong khong kem: de che do tu dong thi camera
  /// lien tuc chinh lai do phoi sang de bu chinh cai thay doi rat nho ma ta
  /// dang can do, lam nhip dap bi san phang. Khoa SAU khi den da sang, neu
  /// khong se khoa nham vao muc phoi sang cua luc con toi.
  ///
  /// May nao khong ho tro khoa thi bo qua lang le (van do duoc, chi kem
  /// chinh xac hon); rieng den flash hong thi ghi lai de man bao loi noi ro.
  Future<void> _enableTorchAndLock(CameraController controller) async {
    // Mo khoa TRUOC da. Camera bay gio duoc dung lai qua nhieu lan do, nen
    // neu khong mo khoa thi lan do thu hai van bi dinh o muc phoi sang da
    // khoa tu lan truoc - do voi the tay khac han thi muc do khong con dung.
    for (final unlock in <Future<void> Function()>[
      () => controller.setExposureMode(ExposureMode.auto),
      () => controller.setFocusMode(FocusMode.auto),
    ]) {
      try {
        await unlock();
      } catch (_) {
        // Thiet bi khong cho doi muc nay - bo qua.
      }
    }
    _torchInfo = await _tryTorch(controller);
    _startTorchKeepAlive();
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (_controller != controller) return;
    for (final lock in <Future<void> Function()>[
      () => controller.setExposureMode(ExposureMode.locked),
      () => controller.setFocusMode(FocusMode.locked),
    ]) {
      try {
        await lock();
      } catch (_) {
        // Thiet bi khong cho khoa muc nay - van do tiep duoc.
      }
    }
  }

  /// Bat den, nhung BAT BUOC di qua trang thai "tat" truoc.
  ///
  /// Goi thang setFlashMode(torch) co the khong lam gi ca: neu phia Android
  /// con nho che do den cua lan do truoc van la "torch" thi lenh nay bi coi
  /// la khong co gi thay doi va bi bo qua, trong khi den thuc te da tat theo
  /// camera cu. Dung la trieu chung da gap - lan do dau tien sau khi mo app
  /// thi duoc, lan thu hai thi khung hinh van ve nhung toi om, phai tat han
  /// app moi do lai duoc. Doi qua "off" roi "torch" buoc no phai thuc su
  /// doi trang thai.
  Future<String> _tryTorch(CameraController controller) async {
    try {
      await controller.setFlashMode(FlashMode.off);
      await controller.setFlashMode(FlashMode.torch);
      return 'den ok';
    } catch (error) {
      return 'den loi: $error';
    }
  }

  /// Bat lai den moi 2 giay chung nao khung hinh van chua ra mau cua dau
  /// ngon tay. Tu chua lanh cho moi kieu quai chieu cua tung dong may, thay
  /// vi doan xem may nao tat den vao luc nao. Dung ngay khi da co tin hieu,
  /// va dung han sau [_kTorchRetryUntilMs] de khong pha giua chung phep do.
  void _startTorchKeepAlive() {
    _torchTimer?.cancel();
    _torchTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      final controller = _controller;
      final clock = _clock;
      if (controller == null ||
          clock == null ||
          _covered.value ||
          clock.elapsedMilliseconds > _kTorchRetryUntilMs) {
        timer.cancel();
        return;
      }
      _torchInfo = await _tryTorch(controller);
    });
  }

  void _onFrame(CameraImage image) {
    final clock = _clock;
    final completer = _completer;
    // Luong khung hinh chay suot thoi gian o man hinh nay, ke ca giua cac
    // lan do - chi lay mau khi dang thuc su do.
    if (!_measuring) return;
    if (clock == null || completer == null || completer.isCompleted) return;

    final brightness = _meanLuma(image);
    final redness = _meanRedness(image);
    _covered.value =
        brightness >= _kCoveredMinBrightness && redness >= _kCoveredMinRedness;
    _samples.add(PpgSample(clock.elapsedMilliseconds, brightness));
    _redness.add(redness);
    // Cap nhat cach quang - moi khung hinh 1 lan se ve lai chu lien tuc,
    // vua nhay mat vua ton CPU dung luc dang can CPU cho viec do.
    if (_samples.length % 8 == 0) {
      _signalInfo.value = 'sang ${brightness.round()} · do ${redness.round()}';
    }

    final elapsed = clock.elapsedMilliseconds / 1000;
    _progress.value = (elapsed / kHeartRateMeasureSeconds).clamp(0.0, 1.0);

    // Duong song truc tiep: chi ve 3 giay gan nhat cho muot, tinh nhe bang
    // cach tru di trung binh cua chinh doan do.
    if (_samples.length > 8) {
      final tail = _samples
          .where((s) => clock.elapsedMilliseconds - s.elapsedMs <= 3000)
          .map((s) => s.brightness)
          .toList();
      if (tail.length > 4) {
        final mean = tail.reduce((a, b) => a + b) / tail.length;
        var maxAbs = 0.0;
        for (final v in tail) {
          final d = (v - mean).abs();
          if (d > maxAbs) maxAbs = d;
        }
        if (maxAbs > 0) {
          _liveWaveform.value = tail.map((v) => (v - mean) / maxAbs).toList();
        }
      }
    }

    if (elapsed >= kHeartRateMeasureSeconds && !_finishScheduled) {
      _finishScheduled = true;
      // Ra HAN khoi luong khung hinh roi moi dong camera. Goi
      // stopImageStream/dispose ngay trong ham nhan khung hinh la tu dong
      // cua so khi dang dung tren no: plugin camera ket lai o trang thai do,
      // va lan do sau khong con khung hinh nao nua.
      Timer.run(_finish);
    }
  }

  Future<void> _finish() async {
    final completer = _completer;
    if (completer == null || completer.isCompleted || _finishing) return;
    // Co the bi goi ca tu khung hinh cuoi lan tu dong ho canh gio, ma giua
    // chung co await - khong chan thi 2 luong cung chay 1 luc.
    _finishing = true;
    // Bo doan khoi dong den flash.
    final kept = <int>[
      for (var i = 0; i < _samples.length; i++)
        if (_samples[i].elapsedMs >= _kWarmUpMs) i,
    ];
    // Chi phan tich DOAN LIEN TUC DAI NHAT co ngon tay, chu khong phai ca
    // 30 giay. Nguoi dung thuong loay hoay chinh lai the tay vai giay dau;
    // tinh ca doan do vao se vua lam hong tin hieu vua keo ti le "co ngon
    // tay" xuong duoi nguong va bi loai oan (da gap: che 49%, thieu dung
    // 1% so voi nguong cu).
    final run = _longestCoveredRun(kept);
    final samples = [
      for (final i in run)
        PpgSample(
          _samples[i].elapsedMs - _samples[run.first].elapsedMs,
          _samples[i].brightness,
        ),
    ];
    final covered = kept.where(_isCovered).length;
    final debugInfo = _describeSignal(kept, covered, samples);
    await _stopMeasuring();
    if (_cancelled) {
      if (!completer.isCompleted) {
        completer.complete(
          const HeartRateResult.failed(HeartRateFailure.cancelled),
        );
      }
      return;
    }
    if (samples.length < 30 || samples.last.elapsedMs < _kMinCoveredMs) {
      completer.complete(
        HeartRateResult.failed(
          HeartRateFailure.fingerNotDetected,
          debugInfo: debugInfo,
        ),
      );
      return;
    }
    final analysis = analyzePpg(samples);
    if (analysis.bpm == null) {
      completer.complete(
        HeartRateResult.failed(
          analysis.failure ?? HeartRateFailure.signalTooNoisy,
          debugInfo: debugInfo,
        ),
      );
      return;
    }
    completer.complete(
      HeartRateResult.success(
        HeartRateMeasurement(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          bpm: analysis.bpm!,
          timestamp: DateTime.now(),
          durationSeconds: kHeartRateMeasureSeconds,
          source: HeartRateSource.camera,
          waveform: _downsample(analysis.waveform, 120),
        ),
      ),
    );
  }

  @override
  Future<void> cancel() async {
    _cancelled = true;
    await _stopMeasuring();
    final completer = _completer;
    if (completer != null && !completer.isCompleted) {
      completer.complete(
        const HeartRateResult.failed(HeartRateFailure.cancelled),
      );
    }
  }

  Future<void> _stopCamera() async {
    _cancelWatchdogs();
    final controller = _controller;
    _controller = null;
    _clock?.stop();
    _clock = null;
    if (controller == null) return;
    // MOI buoc mot khoi try rieng. Truoc day ca ba nam chung 1 khoi: chi
    // can stopImageStream nem loi la hai buoc sau bi nhay qua - den flash
    // khong duoc tat (dung trieu chung "flash van sang" ma nguoi dung thay)
    // va luong khung hinh cua plugin ket lai o trang thai do, nen lan do sau
    // khong con khung hinh nao va phai tat han app.
    try {
      await controller.stopImageStream();
    } catch (_) {
      // Luong co the da dung san - khong sao, cac buoc duoi van phai chay.
    }
    try {
      // Tat den flash TRUOC khi dispose - vai may giu nguyen den sang neu
      // controller bi huy khi torch dang bat.
      await controller.setFlashMode(FlashMode.off);
    } catch (_) {
      // Camera co the da bi he thong thu hoi (goi den, khoa may).
    }
    try {
      await controller.dispose();
    } catch (_) {
      // Da bi huy roi.
    }
  }

  @override
  Future<void> dispose() async {
    await cancel();
    await _stopCamera();
    _progress.dispose();
    _liveWaveform.dispose();
    _covered.dispose();
    _signalInfo.dispose();
  }

  /// Khung hinh [i] co dang bi ngon tay che dung cach khong.
  bool _isCovered(int i) =>
      _samples[i].brightness >= _kCoveredMinBrightness &&
      _redness[i] >= _kCoveredMinRedness;

  /// Doan lien tuc dai nhat (tinh bang thoi gian) co ngon tay, trong so cac
  /// khung hinh [kept]. Cho phep vai khung hinh le bi truot nguong ma khong
  /// cat doi ca doan - mot cai chop mat cua bo do sang khong dang de vut di
  /// 15 giay tin hieu tot.
  List<int> _longestCoveredRun(List<int> kept) {
    const toleranceMs = 400;
    var best = const <int>[];
    var current = <int>[];
    var lastCoveredMs = 0;
    for (final i in kept) {
      if (_isCovered(i)) {
        current.add(i);
        lastCoveredMs = _samples[i].elapsedMs;
        continue;
      }
      if (current.isEmpty) continue;
      if (_samples[i].elapsedMs - lastCoveredMs <= toleranceMs) {
        // Truot nguong trong chop mat - van tinh la 1 doan.
        current.add(i);
        continue;
      }
      if (_duration(current) > _duration(best)) best = current;
      current = <int>[];
    }
    return _duration(current) > _duration(best) ? current : best;
  }

  int _duration(List<int> run) => run.length < 2
      ? 0
      : _samples[run.last].elapsedMs - _samples[run.first].elapsedMs;

  /// Vai con so tho ve lan do vua roi, de man bao loi hien ra cho nguoi
  /// dung chup man hinh gui lai - may thu nghiem khong cam USB debug duoc
  /// nen day la cach duy nhat biet phep do hong o dau.
  String _describeSignal(List<int> kept, int covered, List<PpgSample> run) {
    if (kept.isEmpty) return 'khong nhan duoc khung hinh nao';
    var minLuma = 255.0;
    var maxLuma = 0.0;
    var sumLuma = 0.0;
    var sumRed = 0.0;
    for (final i in kept) {
      final luma = _samples[i].brightness;
      minLuma = math.min(minLuma, luma);
      maxLuma = math.max(maxLuma, luma);
      sumLuma += luma;
      sumRed += _redness[i];
    }
    final seconds =
        (_samples[kept.last].elapsedMs - _samples[kept.first].elapsedMs) / 1000;
    final fps = seconds <= 0 ? 0 : kept.length / seconds;
    return 'sang ${(sumLuma / kept.length).round()} '
        '(${minLuma.round()}-${maxLuma.round()}) · '
        'do ${(sumRed / kept.length).round()} · '
        'che ${(100 * covered / kept.length).round()}% · '
        '${fps.round()} khung/giay · '
        'doan do ${(run.isEmpty ? 0 : run.last.elapsedMs / 1000).toStringAsFixed(1)}s · '
        '$_cameraInfo · $_torchInfo · $_stage';
  }

  /// Muc "do" trung binh cua khung hinh: kenh V (Cr) tru kenh U (Cb).
  ///
  /// Canh trung tinh cho ra gan 0; da nguoi duoc den flash roi xuyen qua
  /// cho ra so duong lon. Dai luong nay gan nhu khong doi khi may thay muc
  /// phoi sang, nen dang tin hon nhieu so voi do sang tuyet doi.
  static double _meanRedness(CameraImage image) {
    if (image.planes.length < 2) return 0;
    if (image.planes.length >= 3) {
      // Android YUV_420_888: plane 1 = U (Cb), plane 2 = V (Cr).
      return _meanOfPlane(image.planes[2]) - _meanOfPlane(image.planes[1]);
    }
    // iOS bi-planar: 1 plane chua U va V xen ke nhau.
    return _meanOfPlane(image.planes[1], offset: 1) -
        _meanOfPlane(image.planes[1]);
  }

  /// Trung binh 1 kenh mau, ton trong buoc nhay giua 2 diem anh (chroma co
  /// the duoc luu xen ke nen buoc nhay la 2 chu khong phai 1).
  static double _meanOfPlane(Plane plane, {int offset = 0}) {
    final bytes = plane.bytes;
    final step = math.max(1, plane.bytesPerPixel ?? 1);
    var sum = 0;
    var count = 0;
    for (var i = offset; i < bytes.length; i += step * 4) {
      sum += bytes[i];
      count++;
    }
    return count == 0 ? 0 : sum / count;
  }

  /// Trung binh kenh sang (plane Y cua YUV420). Lay mau CACH QUANG (moi 4
  /// diem anh tren moi 4 dong) thay vi duyet het - du chinh xac cho gia tri
  /// trung binh ma nhanh hon nhieu lan, giup giu duoc toc do khung hinh.
  static double _meanLuma(CameraImage image) {
    final plane = image.planes.first;
    final bytes = plane.bytes;
    final rowStride = plane.bytesPerRow;
    final width = image.width;
    final height = image.height;
    var sum = 0;
    var count = 0;
    for (var y = 0; y < height; y += 4) {
      final rowStart = y * rowStride;
      for (var x = 0; x < width; x += 4) {
        final index = rowStart + x;
        if (index >= bytes.length) break;
        sum += bytes[index];
        count++;
      }
    }
    return count == 0 ? 0 : sum / count;
  }

  static List<double> _downsample(List<double> input, int maxPoints) {
    if (input.length <= maxPoints) return input;
    final step = input.length / maxPoints;
    return List<double>.generate(
      maxPoints,
      (i) => input[(i * step).floor().clamp(0, input.length - 1)],
    );
  }
}

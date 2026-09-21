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
  bool _cancelled = false;
  bool _finishing = false;
  bool _finishScheduled = false;
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
    // Tra camera cua lan do truoc ve he thong TRUOC khi mo lan moi, va cho
    // mot nhip cho he dieu hanh nha han thiet bi ra. Khong lam vay thi tu
    // lan do thu hai tro di camera khong mo lai duoc.
    await _stopCamera();
    await Future<void>.delayed(const Duration(milliseconds: 300));

    _cancelled = false;
    _finishing = false;
    _finishScheduled = false;
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
      final cameras = await availableCameras();
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        // Do phan giai THAP nhat co the: ta chi can do sang trung binh, anh
        // cang nho thi moi khung hinh cang nhanh (nhieu mau/giay hon) va it
        // ton CPU - quan trong vi phai xu ly lien tuc 30 giay.
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller.initialize();
      _controller = controller;
      _cameraInfo =
          'cam ${back.name}'
          '${cameras.length > 1 ? '/${cameras.length}' : ''}';
      _clock = Stopwatch()..start();
      // Bat luong khung hinh TRUOC khi bat den. Bat den truoc roi moi mo
      // luong thi phien chup bi dung lai de cau hinh lai, va tren nhieu may
      // Android den tat theo - luc do ta quay phim dau ngon tay trong bong
      // toi, khong co gi de do.
      await controller.startImageStream(_onFrame);
      unawaited(_enableTorchAndLock(controller));
    } catch (error) {
      await _stopCamera();
      if (!completer.isCompleted) {
        completer.complete(
          HeartRateResult.failed(
            HeartRateFailure.cameraUnavailable,
            debugInfo: '$_cameraInfo · $error',
          ),
        );
      }
    }
    return completer.future;
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
      _stopCamera();
      completer.complete(
        HeartRateResult.failed(
          HeartRateFailure.cameraUnavailable,
          debugInfo: 'khong nhan duoc khung hinh · $_cameraInfo · $_torchInfo',
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
    _torchInfo = await _tryTorch(controller);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (_controller != controller) return;
    final second = await _tryTorch(controller);
    if (second != 'den ok') _torchInfo = second;
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

  Future<String> _tryTorch(CameraController controller) async {
    try {
      await controller.setFlashMode(FlashMode.torch);
      return 'den ok';
    } catch (error) {
      return 'den loi: $error';
    }
  }

  void _onFrame(CameraImage image) {
    final clock = _clock;
    final completer = _completer;
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
    await _stopCamera();
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
    await _stopCamera();
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
    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
      // Tat den flash TRUOC khi dispose - vai may giu nguyen den sang neu
      // controller bi huy khi torch dang bat.
      await controller.setFlashMode(FlashMode.off);
    } catch (_) {
      // Camera co the da bi he thong thu hoi (goi den, khoa may) - khong co
      // gi de lam them ngoai viec dispose ben duoi.
    }
    await controller.dispose();
  }

  @override
  Future<void> dispose() async {
    await cancel();
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
        '$_cameraInfo · $_torchInfo';
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

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
const _kCoveredMinRedness = 30.0;

/// San toi tuyet doi: neu khung hinh gan nhu den thi den flash khong bat
/// duoc (hoac ong kinh bi bit hoan toan), luc do sac mau khong con y nghia.
const _kCoveredMinBrightness = 12.0;

/// Thoi gian bo dau moi lan do. Ngay sau khi bat torch, camera con dang tu
/// dong can bang sang/trang: do sang khung hinh nhay bac rat manh trong
/// 1-2 giay dau va se lam hong phan phan tich neu dua vao. Doan nay van
/// tinh vao thanh tien do de nguoi dung khong phai cho them.
const _kWarmUpMs = 3000;

/// Ti le khung hinh phai dat nguong che ong kinh thi lan do moi duoc coi la
/// co ngon tay. Duoi muc nay tra ve [HeartRateFailure.fingerNotDetected].
const _kMinCoveredRatio = 0.5;

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
  bool _cancelled = false;

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
    _samples.clear();
    _redness.clear();
    _progress.value = 0;
    _liveWaveform.value = const [];
    _covered.value = false;
    _signalInfo.value = '';

    final completer = Completer<HeartRateResult>();
    _completer = completer;

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
      await controller.setFlashMode(FlashMode.torch);
      await _lockCameraAdjustments(controller);
      _clock = Stopwatch()..start();
      await controller.startImageStream(_onFrame);
    } catch (error) {
      await _stopCamera();
      if (!completer.isCompleted) {
        completer.complete(
          HeartRateResult.failed(
            HeartRateFailure.cameraUnavailable,
            debugInfo: '$error',
          ),
        );
      }
    }
    return completer.future;
  }

  /// Khoa phoi sang + lay net cua camera.
  ///
  /// Day la sua loi quan trong nhat cua phep do: neu de che do tu dong,
  /// camera lien tuc chinh lai do phoi sang de bu chinh cai thay doi rat nho
  /// ma ta dang can do. Ket qua la nhip dap bi "san phang" hoac bi nhan
  /// chim trong cac buoc nhay cua bo tu dong phoi sang - va man hinh bao
  /// "tin hieu qua nhieu" du nguoi dung lam dung.
  ///
  /// Doi mot nhip cho den flash on dinh TRUOC khi khoa, neu khong se khoa
  /// nham vao muc phoi sang cua luc chua bat den. May nao khong ho tro thi
  /// bo qua lang le (van do duoc, chi kem chinh xac hon).
  Future<void> _lockCameraAdjustments(CameraController controller) async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
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

    if (elapsed >= kHeartRateMeasureSeconds) _finish();
  }

  Future<void> _finish() async {
    final completer = _completer;
    if (completer == null || completer.isCompleted) return;
    // Bo doan khoi dong den flash, va doi goc thoi gian ve 0 de phan tich
    // khong phai biet den chuyen nay.
    final kept = <int>[
      for (var i = 0; i < _samples.length; i++)
        if (_samples[i].elapsedMs >= _kWarmUpMs) i,
    ];
    final samples = [
      for (final i in kept)
        PpgSample(_samples[i].elapsedMs - _kWarmUpMs, _samples[i].brightness),
    ];
    final covered = kept
        .where(
          (i) =>
              _samples[i].brightness >= _kCoveredMinBrightness &&
              _redness[i] >= _kCoveredMinRedness,
        )
        .length;
    final debugInfo = _describeSignal(samples, kept, covered);
    await _stopCamera();
    if (_cancelled) {
      if (!completer.isCompleted) {
        completer.complete(
          const HeartRateResult.failed(HeartRateFailure.cancelled),
        );
      }
      return;
    }
    if (samples.isEmpty || covered < samples.length * _kMinCoveredRatio) {
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

  /// Vai con so tho ve lan do vua roi, de man bao loi hien ra cho nguoi
  /// dung chup man hinh gui lai - may thu nghiem khong cam USB debug duoc
  /// nen day la cach duy nhat biet phep do hong o dau.
  String _describeSignal(List<PpgSample> samples, List<int> kept, int covered) {
    if (samples.isEmpty) return 'khong nhan duoc khung hinh nao';
    var minLuma = 255.0;
    var maxLuma = 0.0;
    var sumLuma = 0.0;
    for (final s in samples) {
      minLuma = math.min(minLuma, s.brightness);
      maxLuma = math.max(maxLuma, s.brightness);
      sumLuma += s.brightness;
    }
    final redness =
        kept.map((i) => _redness[i]).reduce((a, b) => a + b) / kept.length;
    final seconds = samples.last.elapsedMs / 1000;
    final fps = seconds <= 0 ? 0 : samples.length / seconds;
    return 'sang ${(sumLuma / samples.length).round()} '
        '(${minLuma.round()}-${maxLuma.round()}) · '
        'do ${redness.round()} · '
        'che ${(100 * covered / samples.length).round()}% · '
        '${fps.round()} khung/giay';
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

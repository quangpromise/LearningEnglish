import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

import 'heart_rate_model.dart';
import 'ppg_analyzer.dart';

/// Thoi gian do 1 lan (giay).
const kHeartRateMeasureSeconds = 30;

/// Do sang trung binh toi thieu de coi la "ngon tay da che kin ong kinh +
/// den flash". Khi ngon tay ap sat, anh sang flash xuyen qua da lam khung
/// hinh sang deu va do ruc; khi ong kinh de ho, khung hinh toi hon nhieu.
/// Nguong nay do tren kenh luma (0-255).
const _kCoveredMinBrightness = 90.0;

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
  Stopwatch? _clock;
  bool _cancelled = false;

  final _progress = ValueNotifier<double>(0);
  final _liveWaveform = ValueNotifier<List<double>>(const []);
  final _covered = ValueNotifier<bool>(false);

  @override
  ValueListenable<double> get progress => _progress;
  @override
  ValueListenable<List<double>> get liveWaveform => _liveWaveform;
  @override
  ValueListenable<bool> get sensorCovered => _covered;

  @override
  Future<HeartRateResult> measure() async {
    _cancelled = false;
    _samples.clear();
    _progress.value = 0;
    _liveWaveform.value = const [];
    _covered.value = false;

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
      _clock = Stopwatch()..start();
      await controller.startImageStream(_onFrame);
    } catch (_) {
      await _stopCamera();
      if (!completer.isCompleted) {
        completer.complete(
          const HeartRateResult.failed(HeartRateFailure.cameraUnavailable),
        );
      }
    }
    return completer.future;
  }

  void _onFrame(CameraImage image) {
    final clock = _clock;
    final completer = _completer;
    if (clock == null || completer == null || completer.isCompleted) return;

    final brightness = _meanLuma(image);
    _covered.value = brightness >= _kCoveredMinBrightness;
    _samples.add(PpgSample(clock.elapsedMilliseconds, brightness));

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
    final samples = List<PpgSample>.from(_samples);
    await _stopCamera();
    if (_cancelled) {
      if (!completer.isCompleted) {
        completer.complete(
          const HeartRateResult.failed(HeartRateFailure.cancelled),
        );
      }
      return;
    }
    final analysis = analyzePpg(samples);
    if (analysis.bpm == null) {
      completer.complete(
        HeartRateResult.failed(
          analysis.failure ?? HeartRateFailure.signalTooNoisy,
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

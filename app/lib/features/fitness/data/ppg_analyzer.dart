import 'dart:math' as math;

import 'heart_rate_model.dart';

/// 1 mau sang do duoc tu 1 khung hinh camera.
class PpgSample {
  const PpgSample(this.elapsedMs, this.brightness);

  /// Mili giay tinh tu luc bat dau do.
  final int elapsedMs;

  /// Do sang trung binh cua vung anh lay mau (0-255).
  final double brightness;
}

/// Ket qua phan tich tin hieu PPG - tach RIENG khoi camera de co the kiem
/// thu bang du lieu gia lap (xem test/ppg_analyzer_test.dart), va de sau nay
/// thay nguon tin hieu (vong deo tay) ma khong phai viet lai phan xu ly.
class PpgAnalysis {
  const PpgAnalysis({required this.bpm, required this.waveform, this.failure});

  final int? bpm;

  /// Tin hieu da khu trend + chuan hoa ve [-1, 1] - dung ve bieu do.
  final List<double> waveform;
  final HeartRateFailure? failure;
}

/// Nhip tim sinh ly chap nhan duoc. Ngoai khoang nay coi nhu do sai (nguoi
/// dung bo tay ra, ong kinh bi ho sang...) chu KHONG hien ra nhu 1 ket qua.
const kMinPlausibleBpm = 40;
const kMaxPlausibleBpm = 200;

/// Camera tra khung hinh voi khoang cach KHONG deu (co the tut tu 30 xuong
/// 15-20 khung/giay khi may nong). Toan bo phan xu ly ben duoi gia dinh mau
/// cach deu nhau, nen truoc het phai noi suy ve luoi thoi gian deu nay.
const _kResampleHz = 30.0;
const _kResampleStepMs = 1000 / _kResampleHz;

/// Cua so khu trend (mili giay) - dai hon 1 chu ky tim cham nhat de duong
/// trung binh truot bam theo do troi cua nen chu khong "an" mat chinh nhip
/// dap.
const _detrendWindowMs = 750;

/// Do tuong quan toi thieu cua tin hieu voi chinh no sau dung 1 chu ky.
/// Nhip tim that lap lai rat giong nhau qua tung nhip nen he so nay cao;
/// rung tay va nhieu camera thi gan 0.
const _kMinAutocorrelation = 0.35;

/// Muc tuong quan (so voi dinh cao nhat) de con chap nhan 1 chu ky NGAN
/// hon. Dinh o dung 1 chu ky thuong thap hon dinh o 2 chu ky mot chut -
/// do phai noi suy giua 2 khung hinh nen dinh nhon bi lam tu - nen khong
/// the doi hai no cao ngang bang, neu khong se do ra dung 1 NUA nhip tim
/// that. Nguoc lai de qua thap thi buou phu trong 1 nhip se bi nham thanh
/// nhip rieng, cho ra so gap doi.
const _kOctaveTolerance = 0.85;

/// Khoang nhip tim DO THU - rong hon khoang sinh ly mot chut de con phan
/// biet duoc "do ra 1 con so nhung vo ly" ([HeartRateFailure.outOfRange])
/// voi "khong tim thay nhip nao" (bao nhieu).
const _kSearchMinBpm = 35;
const _kSearchMaxBpm = 220;

/// Phan tich chuoi mau do sang thanh nhip tim.
///
/// Cac buoc: (1) noi suy ve luoi thoi gian deu, (2) khu trend bang trung
/// binh truot, (3) chuan hoa, (4) TU TUONG QUAN de tim chu ky lap lai,
/// (5) do lai tu tuong quan o do tre le quanh dinh de ra chu ky chinh xac
/// hon do phan giai khung hinh.
///
/// Vi sao tu tuong quan chu khong phai dem dinh: 1 nhip tim that co 2 buou
/// (dinh tam thu + goc song dicrotic notch cach do 250-400ms), nen dem dinh
/// rat de tinh nham thanh 2 nhip, cho ra chuoi khoang cach so le va bi loai
/// voi ly do "tin hieu qua nhieu" DU NGUOI DUNG DAT TAY DUNG - day la loi
/// da gap tren may that. Tu tuong quan so ca doan tin hieu voi chinh no nen
/// buou phu khong lam hong ket qua.
PpgAnalysis analyzePpg(List<PpgSample> samples) {
  const noisy = PpgAnalysis(
    bpm: null,
    waveform: [],
    failure: HeartRateFailure.signalTooNoisy,
  );
  if (samples.length < 30) return noisy;

  final durationMs = samples.last.elapsedMs - samples.first.elapsedMs;
  // Duoi ~5 giay thi khong du chu ky de tu tuong quan co nghia.
  if (durationMs < 5000) return noisy;

  // (1) Noi suy ve luoi deu 30 mau/giay.
  final uniform = _resample(samples, durationMs);
  if (uniform.length < 64) return noisy;

  // (2) Khu trend bang trung binh truot.
  final window = (_detrendWindowMs / _kResampleStepMs).round();
  final detrended = _detrend(uniform, window);

  // (3) Chuan hoa ve [-1, 1].
  final peakAbs = detrended.fold<double>(0, (m, v) => math.max(m, v.abs()));
  if (peakAbs < 0.05) {
    // Duong tin hieu gan nhu phang - ong kinh khong duoc che kin, hoac den
    // flash khong bat duoc.
    return noisy;
  }
  final waveform = detrended.map((v) => v / peakAbs).toList();
  final mean = waveform.reduce((a, b) => a + b) / waveform.length;

  PpgAnalysis reject(HeartRateFailure failure) =>
      PpgAnalysis(bpm: null, waveform: waveform, failure: failure);

  // (4) Tu tuong quan, chi quet cac do tre ung voi khoang nhip tim do thu.
  final minLag = (60 * _kResampleHz / _kSearchMaxBpm).floor();
  final maxLag = (60 * _kResampleHz / _kSearchMinBpm).ceil();
  if (maxLag + 2 >= waveform.length) {
    return reject(HeartRateFailure.signalTooNoisy);
  }

  final correlation = <int, double>{};
  for (var lag = math.max(1, minLag - 1); lag <= maxLag + 1; lag++) {
    correlation[lag] = _autocorrelation(waveform, mean, lag.toDouble());
  }

  // Chi nhan DINH CUC BO that su. Tin hieu bi troi nen hoac rung cham co do
  // tuong quan cao nhung giam deu, khong co dinh - truong hop do phai bao
  // nhieu chu khong lay dai luong lon nhat o bien.
  //
  // (5) Moi dinh tim duoc se do lai o do tre LE (buoc 0.05 mau) quanh vi tri
  // tho.
  // O 30 khung/giay, chu ky that gan nhu khong bao gio roi dung vao 1 mau:
  // khong tinh lai o do tre le thi vua lam tron so do tho, vua danh gia
  // THAP nhung dinh nam giua 2 mau - va dinh bi danh gia thap chinh la
  // nhip that, khien thuat toan chon nham boi so cua no (do ra 42 thay vi
  // 84 bpm).
  final candidates = <_Peak>[
    for (var lag = minLag; lag <= maxLag; lag++)
      if ((correlation[lag - 1] ?? -2) <= correlation[lag]! &&
          (correlation[lag + 1] ?? -2) <= correlation[lag]!)
        _refinePeak(waveform, mean, lag),
  ];
  if (candidates.isEmpty) return reject(HeartRateFailure.signalTooNoisy);

  final best = candidates.map((p) => p.value).reduce((a, b) => math.max(a, b));
  if (best < _kMinAutocorrelation) {
    return reject(HeartRateFailure.signalTooNoisy);
  }
  // Lay chu ky NGAN NHAT dat gan muc cao nhat: tin hieu tuan hoan cung tu
  // tuong quan manh o boi so cua chu ky (2, 3 lan chu ky), lay cai ngan
  // nhat moi ra dung nhip tim thay vi mot nua nhip tim.
  final periodSamples = candidates
      .firstWhere((p) => p.value >= _kOctaveTolerance * best)
      .periodSamples;

  final bpm = (60 * _kResampleHz / periodSamples).round();
  if (bpm < kMinPlausibleBpm || bpm > kMaxPlausibleBpm) {
    return reject(HeartRateFailure.outOfRange);
  }
  return PpgAnalysis(bpm: bpm, waveform: waveform);
}

/// Noi suy tuyen tinh chuoi mau khong deu ve luoi [_kResampleHz].
List<double> _resample(List<PpgSample> samples, int durationMs) {
  final start = samples.first.elapsedMs;
  final count = (durationMs / _kResampleStepMs).floor() + 1;
  final out = List<double>.filled(count, 0);
  var cursor = 0;
  for (var i = 0; i < count; i++) {
    final t = start + i * _kResampleStepMs;
    while (cursor < samples.length - 2 && samples[cursor + 1].elapsedMs < t) {
      cursor++;
    }
    final a = samples[cursor];
    final b = samples[cursor + 1];
    final span = b.elapsedMs - a.elapsedMs;
    final ratio = span <= 0 ? 0.0 : ((t - a.elapsedMs) / span).clamp(0.0, 1.0);
    out[i] = a.brightness + (b.brightness - a.brightness) * ratio;
  }
  return out;
}

/// Tru di trung binh truot +-[window] mau. Dung tong tich luy nen chi phi
/// khong doi theo do dai cua so.
List<double> _detrend(List<double> input, int window) {
  final prefix = List<double>.filled(input.length + 1, 0);
  for (var i = 0; i < input.length; i++) {
    prefix[i + 1] = prefix[i] + input[i];
  }
  return List<double>.generate(input.length, (i) {
    final lo = math.max(0, i - window);
    final hi = math.min(input.length, i + window + 1);
    return input[i] - (prefix[hi] - prefix[lo]) / (hi - lo);
  });
}

/// He so tuong quan (Pearson) giua tin hieu va chinh no doi di [lag] mau.
/// [lag] co the la so le - phan doi duoc noi suy tuyen tinh giua 2 mau.
double _autocorrelation(List<double> w, double mean, double lag) {
  final base = lag.floor();
  final frac = lag - base;
  final n = w.length - base - 1;
  if (n < 16) return 0;
  var sxy = 0.0;
  var sxx = 0.0;
  var syy = 0.0;
  for (var i = 0; i < n; i++) {
    final a = w[i] - mean;
    final shifted = w[i + base] + (w[i + base + 1] - w[i + base]) * frac;
    final b = shifted - mean;
    sxy += a * b;
    sxx += a * a;
    syy += b * b;
  }
  if (sxx <= 0 || syy <= 0) return 0;
  return sxy / math.sqrt(sxx * syy);
}

/// Do lai tu tuong quan o cac do tre le quanh [lag] va tra ve dinh that.
_Peak _refinePeak(List<double> w, double mean, int lag) {
  var bestPeriod = lag.toDouble();
  var bestValue = _autocorrelation(w, mean, bestPeriod);
  for (var step = -19; step <= 19; step++) {
    final candidate = lag + step * 0.05;
    if (candidate < 1) continue;
    final value = _autocorrelation(w, mean, candidate);
    if (value > bestValue) {
      bestValue = value;
      bestPeriod = candidate;
    }
  }
  return _Peak(bestPeriod, bestValue);
}

/// 1 dinh cua duong tu tuong quan.
class _Peak {
  const _Peak(this.periodSamples, this.value);

  /// Chu ky (don vi: mau) - so le, khong bi lam tron ve mau.
  final double periodSamples;

  /// Do tuong quan tai dinh.
  final double value;
}

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

/// Cua so khu trend (mili giay) - dai hon 1 chu ky tim nhanh nhat (300ms)
/// de duong trung binh truot bam theo do troi cua nen chu khong "an" mat
/// chinh nhip dap.
const _detrendWindowMs = 750;

/// Khoang cach toi thieu giua 2 dinh = 200 bpm.
const _minPeakGapMs = 300;

/// Phan tich chuoi mau do sang thanh nhip tim.
///
/// Cac buoc: (1) khu trend bang trung binh truot, (2) chuan hoa, (3) tim
/// dinh cuc bo vuot nguong, (4) lay TRUNG VI khoang cach giua cac dinh
/// (trung vi chu khong phai trung binh - 1 dinh gia do rung tay se keo lech
/// han trung binh), (5) kiem tra chat luong tin hieu truoc khi tra ve so.
PpgAnalysis analyzePpg(List<PpgSample> samples) {
  if (samples.length < 30) {
    return const PpgAnalysis(
      bpm: null,
      waveform: [],
      failure: HeartRateFailure.signalTooNoisy,
    );
  }

  // (1) Khu trend.
  final detrended = <double>[];
  for (var i = 0; i < samples.length; i++) {
    final t = samples[i].elapsedMs;
    var sum = 0.0;
    var count = 0;
    for (var j = i; j >= 0; j--) {
      if (t - samples[j].elapsedMs > _detrendWindowMs) break;
      sum += samples[j].brightness;
      count++;
    }
    for (var j = i + 1; j < samples.length; j++) {
      if (samples[j].elapsedMs - t > _detrendWindowMs) break;
      sum += samples[j].brightness;
      count++;
    }
    detrended.add(samples[i].brightness - sum / count);
  }

  // (2) Chuan hoa ve [-1, 1].
  final peakAbs = detrended.fold<double>(0, (m, v) => math.max(m, v.abs()));
  if (peakAbs < 0.05) {
    // Duong tin hieu gan nhu phang - ong kinh khong duoc che kin, hoac den
    // flash khong bat duoc.
    return const PpgAnalysis(
      bpm: null,
      waveform: [],
      failure: HeartRateFailure.signalTooNoisy,
    );
  }
  final waveform = detrended.map((v) => v / peakAbs).toList();

  // (3) Nguong = 0.35 x do lech chuan - du cao de bo qua goc song nho giua
  // 2 nhip that (dicrotic notch), du thap de khong bo sot nhip yeu.
  final mean = waveform.reduce((a, b) => a + b) / waveform.length;
  final variance =
      waveform.fold<double>(0, (s, v) => s + (v - mean) * (v - mean)) /
      waveform.length;
  final threshold = 0.35 * math.sqrt(variance);

  final peakIndices = <int>[];
  for (var i = 1; i < waveform.length - 1; i++) {
    final v = waveform[i];
    if (v <= threshold) continue;
    if (v < waveform[i - 1] || v < waveform[i + 1]) continue;
    if (peakIndices.isNotEmpty &&
        samples[i].elapsedMs - samples[peakIndices.last].elapsedMs <
            _minPeakGapMs) {
      // Cung 1 nhip - giu dinh CAO HON trong 2 dinh sat nhau.
      if (waveform[peakIndices.last] < v) peakIndices.last = i;
      continue;
    }
    peakIndices.add(i);
  }
  final peakTimes = peakIndices.map((i) => samples[i].elapsedMs).toList();

  // (4) Trung vi khoang cach giua cac dinh.
  if (peakTimes.length < 6) {
    return PpgAnalysis(
      bpm: null,
      waveform: waveform,
      failure: HeartRateFailure.signalTooNoisy,
    );
  }
  final gaps = <int>[
    for (var i = 1; i < peakTimes.length; i++) peakTimes[i] - peakTimes[i - 1],
  ]..sort();
  final medianGap = gaps.length.isOdd
      ? gaps[gaps.length ~/ 2].toDouble()
      : (gaps[gaps.length ~/ 2 - 1] + gaps[gaps.length ~/ 2]) / 2;

  // (5) Chat luong: neu cac khoang cach lech nhau qua nhieu thi day khong
  // phai nhip tim on dinh ma la nhieu do rung tay.
  final gapMean = gaps.reduce((a, b) => a + b) / gaps.length;
  final gapSd = math.sqrt(
    gaps.fold<double>(0, (s, g) => s + (g - gapMean) * (g - gapMean)) /
        gaps.length,
  );
  if (gapMean <= 0 || gapSd / gapMean > 0.35) {
    return PpgAnalysis(
      bpm: null,
      waveform: waveform,
      failure: HeartRateFailure.signalTooNoisy,
    );
  }

  // (5b) Kiem tra tinh CHU KY bang tu tuong quan tai dung chu ky vua tim
  // duoc. Rieng buoc (5) o tren KHONG du: nhieu ngau nhien o 30 khung/giay
  // cong voi luat "2 dinh cach nhau it nhat 300ms" tu no da sinh ra 1 chuoi
  // dinh kha deu, du de lot qua nguong do lech - da bat duoc truong hop nay
  // trong test/ppg_analyzer_test.dart. Tin hieu nhip tim that lap lai chinh
  // no sau moi chu ky nen tu tuong quan cao; nhieu thi gan 0.
  final periodLag = (medianGap / (samples.last.elapsedMs / samples.length))
      .round();
  if (periodLag < 2 || periodLag >= waveform.length) {
    return PpgAnalysis(
      bpm: null,
      waveform: waveform,
      failure: HeartRateFailure.signalTooNoisy,
    );
  }
  var covariance = 0.0;
  var energy = 0.0;
  for (var i = 0; i < waveform.length - periodLag; i++) {
    covariance += (waveform[i] - mean) * (waveform[i + periodLag] - mean);
  }
  for (final v in waveform) {
    energy += (v - mean) * (v - mean);
  }
  final autocorrelation = energy <= 0 ? 0.0 : covariance / energy;
  if (autocorrelation < 0.35) {
    return PpgAnalysis(
      bpm: null,
      waveform: waveform,
      failure: HeartRateFailure.signalTooNoisy,
    );
  }

  final bpm = (60000 / medianGap).round();
  if (bpm < kMinPlausibleBpm || bpm > kMaxPlausibleBpm) {
    return PpgAnalysis(
      bpm: null,
      waveform: waveform,
      failure: HeartRateFailure.outOfRange,
    );
  }
  return PpgAnalysis(bpm: bpm, waveform: waveform);
}

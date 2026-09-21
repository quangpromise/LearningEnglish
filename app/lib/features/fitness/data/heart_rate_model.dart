/// Nguon so do nhip tim. Hien chi co [camera] duoc hien thuc that
/// (CameraHeartRateService); [wearable] giu cho de sau nay ghep vong deo tay
/// ma khong phai doi schema luu tru lan 2.
enum HeartRateSource {
  camera,
  wearable;

  static HeartRateSource fromCode(String code) =>
      code == 'wearable' ? wearable : camera;
}

/// 1 lan do nhip tim da hoan tat.
class HeartRateMeasurement {
  const HeartRateMeasurement({
    required this.id,
    required this.bpm,
    required this.timestamp,
    required this.durationSeconds,
    required this.source,
    this.waveform = const [],
  });

  final String id;
  final int bpm;
  final DateTime timestamp;
  final int durationSeconds;
  final HeartRateSource source;

  /// Tin hieu PPG da chuan hoa ve [-1, 1] de ve lai bieu do cua lan do nay.
  /// Rong neu ban ghi duoc tao truoc khi co tinh nang ve bieu do.
  final List<double> waveform;

  Map<String, dynamic> toJson() => {
    'id': id,
    'bpm': bpm,
    'timestamp': timestamp.toIso8601String(),
    'durationSeconds': durationSeconds,
    'source': source.name,
    // Luu thua 1 chut du lieu song (toi da ~120 diem, xem
    // HeartRateRepository.save) de man Ket qua ve lai duoc bieu do khi mo
    // tu lich su - re hon nhieu so voi do lai.
    'waveform': waveform.map((v) => (v * 1000).round()).toList(),
  };

  static HeartRateMeasurement fromJson(Map<String, dynamic> json) =>
      HeartRateMeasurement(
        id: json['id'] as String,
        bpm: json['bpm'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
        durationSeconds: json['durationSeconds'] as int,
        source: HeartRateSource.fromCode(json['source'] as String),
        waveform: ((json['waveform'] as List?) ?? const [])
            .map((v) => (v as num) / 1000)
            .toList(),
      );
}

/// Ly do 1 lan do KHONG cho ra ket qua. Man hinh phai hien dung trang thai
/// nay thay vi bia ra 1 con so - xem quy tac "khong fake nhip tim" trong
/// CLAUDE.md/ke hoach tinh nang.
enum HeartRateFailure {
  /// Nguoi dung tu bam dung giua chung.
  cancelled,

  /// Khong mo duoc camera (tu choi quyen, may khong co camera sau...).
  cameraUnavailable,

  /// Do xong 30 giay nhung tin hieu qua nhieu nhieu - thuong do khong che
  /// kin ong kinh hoac ngon tay rung.
  signalTooNoisy,

  /// Gan nhu ca lan do khong thay ngon tay che ong kinh (khung hinh toi).
  /// Tach rieng khoi [signalTooNoisy] vi cach xu ly khac han: khong phai
  /// "giu yen hon" ma la "dat ngon tay len dung cho".
  fingerNotDetected,

  /// Phat hien duoc nhip nhung ra ngoai khoang sinh ly (40-200 bpm) nen
  /// khong dang tin.
  outOfRange,
}

/// Ket qua 1 lan do - HOAC co [measurement], HOAC co [failure], khong bao
/// gio ca hai cung null.
class HeartRateResult {
  const HeartRateResult.success(HeartRateMeasurement this.measurement)
    : failure = null,
      debugInfo = null;
  const HeartRateResult.failed(HeartRateFailure this.failure, {this.debugInfo})
    : measurement = null;

  final HeartRateMeasurement? measurement;
  final HeartRateFailure? failure;

  /// Vai con so tho ve tin hieu vua thu duoc (do sang, do do, ti le khung
  /// hinh coi la co ngon tay). Hien duoi dang dong chu nho o man bao loi.
  ///
  /// Ly do phai hien ra man hinh: may thu nghiem khong cam USB debug duoc
  /// nen khong doc duoc log - anh chup man hinh la kenh duy nhat de biet
  /// phep do that bai o dau. Chi xuat hien khi do KHONG thanh cong.
  final String? debugInfo;

  bool get isSuccess => measurement != null;
}

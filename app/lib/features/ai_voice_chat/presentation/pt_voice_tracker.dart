import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../core/audio/pcm_level.dart';
import '../data/voice_chat_client.dart';

/// Trang thai PT AI hien cho nguoi dung (spec #96, MO-09): Nghe -> Nghi ->
/// Noi.
enum PtVoiceState { idle, connecting, listening, thinking, speaking, error }

/// Suy trang thai Nghe / Nghi / Noi va muc am cho vong mic / thanh song tu
/// cac su kien cua 1 phien tro chuyen giong noi (spec #96, MO-09, quyet
/// dinh #15). "Noi" = giong AI dang THAT SU phat ra:
/// - qua avatar (lipsync tung goi): tu goi am thanh dau toi luc phat het
///   phan da nhan, uoc theo so byte - server gui nhanh hon thoi gian thuc
///   nen tin hieu het luot den truoc khi avatar noi xong;
/// - qua loa (file WAV ca luot, phat sau khi het luot): tu luc loa bao dang
///   phat toi luc dung.
/// Tu luc tha mic toi luc do la "Nghi". Thoi diem ([Duration]) lay tu 1
/// dong ho don dieu cua man hinh; man hinh goi [tick] moi khung hinh trong
/// luc [ticking].
class PtVoiceTracker extends ChangeNotifier {
  PtVoiceTracker({this.avatarDelay = const Duration(milliseconds: 400)});

  /// Avatar bat dau noi tre hon goi am thanh dau bao lau (uoc luong - can do
  /// lai tren may that).
  final Duration avatarDelay;

  /// Do phan giai muc am cua thanh song.
  static const window = Duration(milliseconds: 50);

  /// Giong AI cua Gemini Live: PCM 16-bit mono 24 kHz.
  static const _aiSamplesPerSecond = 24000;

  /// So byte PCM cua 1 [window].
  static final _windowBytes =
      _aiSamplesPerSecond *
      2 *
      window.inMicroseconds ~/
      Duration.microsecondsPerSecond;

  /// Muc am mic 0..1 (vong mic khi Nghe).
  final micLevel = ValueNotifier<double>(0);

  /// Muc am giong AI 0..1 dang phat (thanh song khi Noi).
  final aiLevel = ValueNotifier<double>(0);

  VoiceChatState _client = VoiceChatState.idle;
  PtVoiceState _display = PtVoiceState.idle;
  bool _ticking = false;

  // Avatar: moc bat dau phat, do dai am thanh da nhan (ca khoang lang), muc
  // am tung [window] (phan le cua goi cuoi cho goi sau), da het luot chua.
  Duration? _avatarFrom;
  Duration _avatarLength = Duration.zero;
  bool _avatarStarted = false;
  final _avatarLevels = <double>[];
  Uint8List _carry = Uint8List(0);
  bool _avatarTurnOver = false;

  // Loa: cau tra loi sap phat (Nghi toi khi phat) va muc am lan phat toi.
  bool _replyQueued = false;
  List<double>? _queuedLevels;
  Duration? _playerFrom;
  List<double> _playerLevels = const [];

  PtVoiceState get display => _display;

  /// Avatar / loa dang phat: man hinh chay ticker goi [tick] chi khi true.
  bool get ticking => _ticking;

  void onClientState(VoiceChatState state) {
    _client = state;
    switch (state) {
      case VoiceChatState.listening:
        // Nguoi dung noi (ke ca noi chen): PT thoi noi, vong mic tu 0.
        micLevel.value = 0;
        _stopSpeaking();
      case VoiceChatState.connecting || VoiceChatState.error:
        _stopSpeaking();
      case VoiceChatState.idle:
        // Het luot / ket noi dong: khong con goi am thanh nao nua.
        _avatarTurnOver = true;
        _flushCarry();
      case VoiceChatState.thinking:
        break;
    }
    _update();
  }

  void onMicLevel(double level) => micLevel.value = level;

  /// 1 goi PCM giong AI, den truoc khi het luot. [avatarPlays]: avatar dang
  /// phat no (lipsync); khong thi ca luot se phat qua loa ([queueReply]).
  void onAiChunk(
    Uint8List pcm, {
    required Duration at,
    required bool avatarPlays,
  }) {
    if (!avatarPlays || _client == VoiceChatState.listening) return;
    final start = at + avatarDelay;
    final from = _avatarFrom;
    if (from == null) {
      _clearAvatar();
      _avatarFrom = start;
      _avatarTurnOver = false;
    } else if (start > from + _avatarLength) {
      // Server cham hon thoi gian thuc: avatar im cho goi moi. Khoang lang
      // vao muc am nhu am thanh im -> thanh song van khop thoi gian.
      final gap = start - (from + _avatarLength);
      final samples =
          gap.inMicroseconds *
          _aiSamplesPerSecond ~/
          Duration.microsecondsPerSecond;
      _appendLevels(Uint8List(samples * 2));
      _avatarLength = start - from;
    }
    // Do dai theo dung so mau (goi nho khong bi lam tron len 50 ms).
    _avatarLength += Duration(
      microseconds:
          pcm.length ~/
          2 *
          Duration.microsecondsPerSecond ~/
          _aiSamplesPerSecond,
    );
    _appendLevels(pcm);
    if (at >= (from ?? start)) _avatarStarted = true;
    _update();
  }

  /// Server bao het am thanh cua luot.
  void onTurnAudioEnd() {
    _avatarTurnOver = true;
    _flushCarry();
    _update();
  }

  /// Them muc am tung [window] tron; phan le giu lai cho goi sau.
  void _appendLevels(Uint8List pcm) {
    final data = _carry.isEmpty ? pcm : Uint8List.fromList([..._carry, ...pcm]);
    var offset = 0;
    while (data.length - offset >= _windowBytes) {
      _avatarLevels.add(
        pcm16Level(Uint8List.sublistView(data, offset, offset + _windowBytes)),
      );
      offset += _windowBytes;
    }
    _carry = Uint8List.fromList(Uint8List.sublistView(data, offset));
  }

  /// Het luot / co khoang lang: phan le thanh 1 o rieng.
  void _flushCarry() {
    if (_carry.isEmpty) return;
    _avatarLevels.add(pcm16Level(_carry));
    _carry = Uint8List(0);
  }

  void _clearAvatar() {
    _avatarFrom = null;
    _avatarLength = Duration.zero;
    _avatarStarted = false;
    _avatarLevels.clear();
    _carry = Uint8List(0);
  }

  /// Loa sap phat cau tra loi ([levels]: muc am tung [window]) - Nghi toi khi
  /// loa bao dang phat.
  void queueReply(List<double> levels) {
    _replyQueued = true;
    _queuedLevels = levels;
    _update();
  }

  /// Nghe lai 1 cau cu - khong qua Nghi.
  void queueReplay(List<double> levels) => _queuedLevels = levels;

  /// Cau tra loi se khong phat qua loa (loi file, avatar da phat...).
  void dropReply() {
    _replyQueued = false;
    _queuedLevels = null;
    _update();
  }

  void onPlayer({required bool playing, required Duration at}) {
    if (playing) {
      _replyQueued = false;
      _playerLevels = _queuedLevels ?? const [];
      _queuedLevels = null;
      _playerFrom = at;
    } else {
      _playerFrom = null;
    }
    _update();
  }

  /// Moi khung hinh khi [ticking]: muc am theo dung thoi diem dang phat;
  /// avatar bat dau noi -> Noi; phat het phan da nhan (sau khi het luot) ->
  /// thoi Noi.
  void tick(Duration now) {
    var level = 0.0;
    final avatarFrom = _avatarFrom;
    if (avatarFrom != null) {
      if (_avatarTurnOver && now >= avatarFrom + _avatarLength) {
        _clearAvatar();
      } else {
        if (now >= avatarFrom) _avatarStarted = true;
        level = _avatarLevelAt(now - avatarFrom);
      }
    }
    final playerFrom = _playerFrom;
    if (playerFrom != null) {
      // Khong doc duoc file: thanh song o muc giua.
      level = math.max(
        level,
        _playerLevels.isEmpty ? 0.5 : _levelAt(_playerLevels, now - playerFrom),
      );
    }
    aiLevel.value = level;
    _update();
  }

  /// Muc am avatar tai [offset]; o mep cuoi (phan le chua du 1 o) lay muc am
  /// cua phan le; qua het am thanh da nhan (cho goi moi) -> 0.
  double _avatarLevelAt(Duration offset) {
    if (offset.isNegative || offset >= _avatarLength) return 0;
    final i = offset.inMicroseconds ~/ window.inMicroseconds;
    if (i < _avatarLevels.length) return _avatarLevels[i];
    return _carry.isEmpty ? 0 : pcm16Level(_carry);
  }

  static double _levelAt(List<double> levels, Duration offset) {
    if (offset.isNegative) return 0;
    final i = offset.inMicroseconds ~/ window.inMicroseconds;
    return i < levels.length ? levels[i] : 0;
  }

  void _stopSpeaking() {
    _clearAvatar();
    _replyQueued = false;
    _queuedLevels = null;
    _playerFrom = null;
  }

  void _update() {
    // Avatar: Noi tu luc no that su bat dau. Loa: nghe lai cau cu trong luc
    // cho cau tra loi moi van la Nghi.
    final playerSpeaking =
        _playerFrom != null && _client == VoiceChatState.idle;
    final speaking = (_avatarFrom != null && _avatarStarted) || playerSpeaking;
    final next = switch (_client) {
      VoiceChatState.error => PtVoiceState.error,
      VoiceChatState.connecting => PtVoiceState.connecting,
      VoiceChatState.listening => PtVoiceState.listening,
      VoiceChatState.thinking =>
        speaking ? PtVoiceState.speaking : PtVoiceState.thinking,
      VoiceChatState.idle =>
        speaking
            ? PtVoiceState.speaking
            : _replyQueued
            ? PtVoiceState.thinking
            : PtVoiceState.idle,
    };
    // Ticker chi chay khi avatar dang / sap phat hoac loa dang la "Noi".
    final ticking = _avatarFrom != null || playerSpeaking;
    if (next != PtVoiceState.speaking) aiLevel.value = 0;
    if (next == _display && ticking == _ticking) return;
    _display = next;
    _ticking = ticking;
    notifyListeners();
  }

  @override
  void dispose() {
    micLevel.dispose();
    aiLevel.dispose();
    super.dispose();
  }
}

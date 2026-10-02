import 'dart:math' as math;
import 'dart:typed_data';

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

  /// Muc am mic 0..1 (vong mic khi Nghe).
  final micLevel = ValueNotifier<double>(0);

  /// Muc am giong AI 0..1 dang phat (thanh song khi Noi).
  final aiLevel = ValueNotifier<double>(0);

  VoiceChatState _client = VoiceChatState.idle;
  PtVoiceState _display = PtVoiceState.idle;
  bool _ticking = false;

  // Avatar: moc bat dau phat, muc am tung [window], server da het luot chua.
  Duration? _avatarFrom;
  final _avatarLevels = <double>[];
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
      _avatarFrom = start;
      _avatarLevels.clear();
      _avatarTurnOver = false;
    } else {
      // Server cham hon thoi gian thuc: avatar im cho goi moi.
      final queuedEnd = from + window * _avatarLevels.length;
      if (start > queuedEnd) {
        final gap = (start - queuedEnd).inMicroseconds ~/ window.inMicroseconds;
        _avatarLevels.addAll(List.filled(gap, 0.0));
      }
    }
    _avatarLevels.addAll(
      pcm16Envelope(pcm, samplesPerSecond: _aiSamplesPerSecond, window: window),
    );
    _update();
  }

  /// Server bao het am thanh cua luot.
  void onTurnAudioEnd() {
    _avatarTurnOver = true;
    _update();
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
  /// avatar phat het phan da nhan (sau khi het luot) -> thoi Noi.
  void tick(Duration now) {
    var level = 0.0;
    final avatarFrom = _avatarFrom;
    if (avatarFrom != null) {
      final end = avatarFrom + window * _avatarLevels.length;
      if (_avatarTurnOver && now >= end) {
        _avatarFrom = null;
        _avatarLevels.clear();
      } else {
        level = _levelAt(_avatarLevels, now - avatarFrom);
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

  static double _levelAt(List<double> levels, Duration offset) {
    if (offset.isNegative) return 0;
    final i = offset.inMicroseconds ~/ window.inMicroseconds;
    return i < levels.length ? levels[i] : 0;
  }

  void _stopSpeaking() {
    _avatarFrom = null;
    _avatarLevels.clear();
    _replyQueued = false;
    _queuedLevels = null;
    _playerFrom = null;
  }

  void _update() {
    // Nghe lai cau cu trong luc cho cau tra loi moi: van la Nghi.
    final speaking =
        _avatarFrom != null ||
        (_playerFrom != null && _client == VoiceChatState.idle);
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
    final ticking = _avatarFrom != null || _playerFrom != null;
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

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_session/audio_session.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/env.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/tts/app_tts.dart';
import '../../../core/widgets/speaker_button.dart';
import '../data/anam_session_api.dart';
import '../data/avatar_provider.dart';
import '../data/gemini_gender.dart';
import '../data/gemini_live_direct_client.dart';
import '../data/gemini_voices.dart';
import '../data/spatius_session_api.dart';
import '../data/voice_chat_client.dart';
import '../data/voice_chat_config.dart';
import '../../translation/presentation/word_popup_sheet.dart';
import 'anam_live_avatar.dart';
import 'gemini_voice_picker_sheet.dart';
import 'spatius_live_avatar.dart';

/// AI Voice Chat: tro chuyen tu do bang giong noi voi AI qua backend
/// gemini-proxy (xem backend/README.md ve kien truc + cach deploy). BAT
/// BUOC phai tu deploy backend va thay [kVoiceChatBackendUrl] truoc khi
/// tinh nang nay hoat dong duoc - chua co server nao duoc host san.
///
/// Chu tren GIAO DIEN (tieu de, trang thai, loi...) doi theo ngon ngu app
/// (ref.tr) - noi dung CUOC TRO CHUYEN voi AI (system prompt, cau AI noi)
/// luon co dinh tieng Anh du app dang o ngon ngu nao, vi day la tinh nang
/// luyen tieng Anh.
class AiVoiceChatScreen extends ConsumerStatefulWidget {
  const AiVoiceChatScreen({super.key});

  @override
  ConsumerState<AiVoiceChatScreen> createState() => _AiVoiceChatScreenState();
}

class _AiVoiceChatScreenState extends ConsumerState<AiVoiceChatScreen> {
  VoiceChatSession? _client;
  StreamSubscription<VoiceChatState>? _stateSub;
  StreamSubscription<List<int>>? _audioSub;
  StreamSubscription<TranscriptEvent>? _transcriptSub;
  StreamSubscription<Uint8List>? _liveAudioSub;
  StreamSubscription<void>? _turnAudioEndSub;
  // Chi duoc dung khi kUseAnamAvatar = true - xem build()/_toggle().
  final _anamKey = GlobalKey<AnamLiveAvatarState>();
  bool _anamReady = false;

  // Du phong (failover) sang Spatius AI - chi duoc dung khi
  // kUseSpatiusFailover = true, xem _onAnamUnrecoverable ben duoi. Spatius
  // duoc "hoi am" (khoi tao + ket noi) NGAM tu luc Anam vua san sang, du chua
  // hien len man hinh - de luc thuc su can chuyen mach chi con la doi UI
  // (AnimatedOpacity) + doi huong audio, khong phai cho ket noi moi tu dau
  // (von mat vai giay do round-trip mang), giup thoi gian chuyen mach < 1s.
  final _spatiusKey = GlobalKey<SpatiusLiveAvatarState>();
  AvatarProvider _avatarProvider = AvatarProvider.anam;
  bool _spatiusWarmed = false;
  // Dung `audioplayers` (KHONG dung just_audio) - xem giai thich chi tiet
  // trong pubspec.yaml/app_tts.dart: just_audio_background chi ho tro DUY
  // NHAT 1 AudioPlayer trong toan app (NowPlayingService.player), 1
  // AudioPlayer just_audio THU HAI se luon nem loi khi phat.
  final ap.AudioPlayer _player = ap.AudioPlayer();
  final ScrollController _scrollCtrl = ScrollController();
  final List<TranscriptEvent> _messages = [];

  /// Future dang ghi file WAV cho luot hien tai (tu _playResponse) - xem
  /// _onTranscript de biet tai sao phai await future thay vi doc 1 bien
  /// String? don gian.
  Future<String?>? _pendingAudioFuture;

  VoiceChatState _state = VoiceChatState.idle;
  String? _error;
  String _voiceName = kDefaultGeminiVoiceName;
  // Gioi tinh avatar hien tai, suy ra tu _voiceName - xem
  // GeminiGenderRouter/_currentAnamAvatarId/_currentSpatiusAvatarId. Doi
  // ngay khi nguoi dung doi giong (xem _onVoiceChanged), lam AnamLiveAvatar/
  // SpatiusLiveAvatar tu restart voi avatarId tuong ung qua didUpdateWidget.
  GeminiGender _gender = GeminiGenderRouter.fromVoiceName(
    kDefaultGeminiVoiceName,
  );

  String get _currentAnamAvatarId =>
      _gender == GeminiGender.male ? kAnamAvatarIdMale : kAnamAvatarIdFemale;

  String get _currentSpatiusAvatarId => _gender == GeminiGender.male
      ? kSpatiusAvatarIdMale
      : kSpatiusAvatarIdFemale;

  @override
  void initState() {
    super.initState();
    _voiceName = GeminiVoiceSelection.instance.value;
    _gender = GeminiGenderRouter.fromVoiceName(_voiceName);
    GeminiVoiceSelection.instance.addListener(_onVoiceChanged);
    _ensurePlaybackSession();
  }

  void _onVoiceChanged() {
    if (!mounted) return;
    final newVoice = GeminiVoiceSelection.instance.value;
    if (newVoice == _voiceName) return;
    setState(() {
      _voiceName = newVoice;
      _gender = GeminiGenderRouter.fromVoiceName(newVoice);
    });
    if (_state == VoiceChatState.idle && _client != null) {
      _client!.dispose();
      _client = null;
    }
  }

  Future<void> _pickVoice() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => GeminiVoicePickerSheet(current: _voiceName),
    );
    if (picked == null || picked == _voiceName) return;
    await GeminiVoiceSelection.instance.select(picked);
  }

  @override
  void dispose() {
    GeminiVoiceSelection.instance.removeListener(_onVoiceChanged);
    _stateSub?.cancel();
    _audioSub?.cancel();
    _transcriptSub?.cancel();
    _liveAudioSub?.cancel();
    _turnAudioEndSub?.cancel();
    _client?.dispose();
    _player.dispose();
    _scrollCtrl.dispose();
    // Khoi phuc audio session ve "music" luc roi man - man nay doi sang
    // playAndRecord/voiceCommunication (loa thoai) de mic ghi am ro luc dang
    // chat (xem _ensurePlaybackSession). AudioSession la SINGLETON dung
    // chung toan app, khong tu dong reset - neu khong khoi phuc o day, nguoi
    // dung roi man nay ra bam PHAT TIEP 1 bai dang mo do (khong mo playlist
    // moi) se nghe rat nho, vi NowPlayingService.setQueue chi ep lai
    // .music() luc BAT DAU 1 hang doi moi, khong phai moi lan resume/play.
    unawaited(_restoreMusicSession());
    super.dispose();
  }

  Future<void> _restoreMusicSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (_) {
      // Bo qua - khong lam gian doan viec dong man hinh.
    }
  }

  void _interruptActiveAvatar() {
    switch (_avatarProvider) {
      case AvatarProvider.anam:
        _anamKey.currentState?.interruptPersona();
        break;
      case AvatarProvider.spatius:
        _spatiusKey.currentState?.interruptPersona();
        break;
    }
  }

  Future<void> _toggle() async {
    // Neu dang phat/dang nghe va nguoi dung bam ngat loi (barge-in):
    if (kUseAnamAvatar) {
      _interruptActiveAvatar();
    }

    // Dang noi - bam lai nghia la "toi noi xong roi", ket thuc luot nay va
    // cho AI tra loi (khong dong ca phien - xem VoiceChatSession.endTurn).
    if (_state == VoiceChatState.listening) {
      await _client?.endTurn();
      return;
    }
    // Dang ket noi hoac dang cho AI tra loi luot truoc - bo qua, nut da bi
    // vo hieu hoa trong build() nhung chan lai o day cho chac.
    if (_state == VoiceChatState.connecting ||
        _state == VoiceChatState.thinking) {
      return;
    }

    final existing = _client;
    final VoiceChatSession client;
    if (existing != null && _state == VoiceChatState.idle) {
      // Phien van dang mo (vua nhan xong 1 luot tra loi) - tai su dung, chi
      // bat dau ghi am luot moi thay vi tao ket noi moi tu dau.
      client = existing;
    } else {
      if (kUseDirectGeminiConnection) {
        // TAM THOI (xem voice_chat_config.dart) - bo qua dang nhap/backend.
        client = GeminiLiveDirectClient(
          apiKey: Env.geminiApiKeyDirect,
          voiceName: _voiceName,
          level: ref.read(learnerLevelProvider),
        );
      } else {
        final token = Supabase.instance.client.auth.currentSession?.accessToken;
        if (token == null) {
          setState(() {
            _error = ref.tr('voice_chat_sign_in_required');
            _state = VoiceChatState.error;
          });
          return;
        }
        client = VoiceChatClient(
          backendUrl: kVoiceChatBackendUrl,
          accessToken: token,
          level: ref.read(learnerLevelProvider),
        );
      }
      _client = client;

      _stateSub?.cancel();
      _stateSub = client.stateStream.listen((s) {
        if (!mounted) return;
        setState(() {
          _state = s;
          if (s == VoiceChatState.error) {
            _error =
                client.lastError ??
                _error ??
                ref.tr('voice_chat_error_generic');
          } else if (s == VoiceChatState.listening) {
            // Khi nguoi dung bat dau noi (barge-in): dung ngay lap tuc avatar va loa
            if (kUseAnamAvatar) {
              _interruptActiveAvatar();
            }
          }
        });
      });
      _audioSub?.cancel();
      _audioSub = client.incomingAudio.listen(_playResponse);
      _transcriptSub?.cancel();
      _transcriptSub = client.transcriptStream.listen(_onTranscript);

      // Nap tung chunk audio ngay khi Gemini tra ve vao mieng avatar dang
      // ACTIVE (Anam hoac Spatius, xem _avatarProvider) de lipsync realtime,
      // do tre thap nhat (<500ms) non-blocking. Websocket Gemini Live KHONG
      // bi dong/khoi dong lai khi chuyen mach avatar - chi doi huong noi
      // 2 stream nay tro toi widget nao dang hien.
      if (kUseAnamAvatar) {
        _liveAudioSub?.cancel();
        _liveAudioSub = client.liveAudioChunks.listen(_forwardAudioChunk);
        _turnAudioEndSub?.cancel();
        _turnAudioEndSub = client.turnAudioEnd.listen((_) => _forwardEndTurn());
      }
    }

    setState(() {
      _error = null;
      _state = VoiceChatState.connecting;
    });

    try {
      await client.start();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = ref
              .tr('voice_chat_could_not_connect')
              .replaceFirst('{msg}', '$e');
          _state = VoiceChatState.error;
        });
      }
    }
  }

  void _forwardAudioChunk(Uint8List chunk) {
    switch (_avatarProvider) {
      case AvatarProvider.anam:
        _anamKey.currentState?.sendAudioChunk(chunk);
        break;
      case AvatarProvider.spatius:
        _spatiusKey.currentState?.sendAudioChunk(chunk);
        break;
    }
  }

  void _forwardEndTurn() {
    switch (_avatarProvider) {
      case AvatarProvider.anam:
        _anamKey.currentState?.endTurn();
        break;
      case AvatarProvider.spatius:
        _spatiusKey.currentState?.endTurn();
        break;
    }
  }

  /// Goi khi AnamLiveAvatar bao loi KHONG the tu phuc hoi - hoac loi WebView
  /// that su, hoac (thuong gap hon) do xin token moi that bai sau khi phien
  /// 3 phut cua goi Free bi dong vi da het quota 30 phut/thang (xem
  /// AnamLiveAvatar._onSessionExpired). Chi doi UI + huong audio sang
  /// Spatius - KHONG dong GeminiLiveDirectClient, cuoc tro chuyen tiep tuc
  /// lien tuc.
  ///
  /// BUG DA SUA: truoc day chi doi _avatarProvider ma KHONG tu goi
  /// _warmSpatiusIfNeeded() - neu Anam loi NGAY TU LAN KET NOI DAU TIEN
  /// (chua bao gio vao duoc onReady, vd het quota 30 phut/thang tu truoc do),
  /// _spatiusWarmed van la false vinh vien, khien lop Spatius KHONG BAO GIO
  /// duoc mount trong Stack (xem dieu kien `if (_spatiusWarmed)` trong
  /// build()) - ca 2 lop avatar deu vo hinh, de lo nen anh phia sau nhu
  /// khong co gi (bug nguoi dung bao cao: "Anam het han dang load avatar thi
  /// bien mat"). Goi thang o day thay vi chi trong chieu Anam.onReady.
  void _onAnamUnrecoverable(String msg) {
    if (!mounted) return;
    if (!kUseSpatiusFailover) {
      setState(() => _anamReady = false);
      return;
    }
    setState(() {
      _anamReady = false;
      _avatarProvider = AvatarProvider.spatius;
    });
    _warmSpatiusIfNeeded();
  }

  /// Khoi tao truoc (ngam, khong hien UI) ket noi Spatius ngay khi Anam vua
  /// san sang - de neu sau nay Anam loi, chuyen mach chi con la doi
  /// AnimatedOpacity + doi huong 2 stream audio (xem _forwardAudioChunk),
  /// khong phai cho round-trip mang xin token + tai avatar tu dau (~vai
  /// giay) - dat duoc yeu cau chuyen mach duoi 1 giay.
  void _warmSpatiusIfNeeded() {
    if (!kUseSpatiusFailover || _spatiusWarmed) return;
    _spatiusWarmed = true;
    if (mounted) setState(() {});
  }

  /// Khi AI bao co loi (kem [TranscriptEvent.correction]), boi do luon tin
  /// nhan cua nguoi dung ngay truoc do - do la cau da gay ra loi goi y nay.
  ///
  /// Audio va transcript den tu 2 stream KHAC NHAU (incomingAudio va
  /// transcriptStream) - du client emit audio truoc transcript trong cung 1
  /// luot, ben nghe (o day) khong duoc gia dinh _playResponse (async, co
  /// ghi file) da chay XONG truoc khi _onTranscript chay, vi Dart chi dam
  /// bao thu tu SCHEDULE microtask, khong dam bao _playResponse hoan tat
  /// truoc _onTranscript bat dau - dan den bug thuc te: tin nhan AI bi gan
  /// nham duong dan audio cua luot TRUOC do (dang phat lai lai loi cu khi
  /// bam nghe lai). Sua bang cach _onTranscript CHO (await) chinh future
  /// dang ghi file cua _playResponse thay vi doc 1 bien da-xong-hay-chua.
  Future<void> _onTranscript(TranscriptEvent event) async {
    if (!mounted) return;
    var toAdd = event;
    if (event.role == ChatRole.ai) {
      final pending = _pendingAudioFuture;
      _pendingAudioFuture = null;
      if (pending != null) {
        final path = await pending;
        if (!mounted) return;
        toAdd = event.copyWith(audioPath: path);
      }
    }
    setState(() {
      if (toAdd.role == ChatRole.ai &&
          toAdd.correction != null &&
          _messages.isNotEmpty &&
          _messages.last.role == ChatRole.user) {
        _messages[_messages.length - 1] = _messages.last.copyWith(
          hasError: true,
        );
      }
      _messages.add(toAdd);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });

    // Kiem tra ngu phap/chinh ta cau nguoi dung vua noi bang LanguageTool -
    // DOC LAP voi viec Gemini co chiu noi ra "Correction: ..." hay khong (co
    // che do la best-effort, phu thuoc model tuan thu 1 huong dan phu trong
    // luc dang tro chuyen tu nhien nen khong dam bao). LanguageTool phan tich
    // thang van ban da nhan dien, dang tin cay hon nhieu cho loi ngu phap/
    // chinh ta (khong bat duoc loi phat am thuan tuy - do van la phan viec
    // cua co che "Correction:" cua Gemini).
    if (toAdd.role == ChatRole.user) {
      unawaited(_checkGrammar(toAdd));
    }
  }

  Future<void> _checkGrammar(TranscriptEvent userEvent) async {
    try {
      final res = await http
          .post(
            Uri.parse('https://api.languagetool.org/v2/check'),
            body: {'text': userEvent.text, 'language': 'en-US'},
          )
          .timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return;

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final matches = (data['matches'] as List?) ?? const [];
      if (matches.isEmpty) return;

      final match = matches.first as Map<String, dynamic>;
      final replacements = (match['replacements'] as List?) ?? const [];
      if (replacements.isEmpty) return;
      final replacement =
          (replacements.first as Map<String, dynamic>)['value'] as String?;
      final offset = match['offset'] as int?;
      final length = match['length'] as int?;
      if (replacement == null || offset == null || length == null) return;

      final corrected = userEvent.text.replaceRange(
        offset,
        offset + length,
        replacement,
      );
      if (corrected == userEvent.text) return;

      if (!mounted) return;
      final index = _messages.indexOf(userEvent);
      if (index == -1) return;
      setState(() {
        _messages[index] = _messages[index].copyWith(
          hasError: true,
          correction: corrected,
        );
      });
    } catch (_) {
      // Loi mang/API LanguageTool - bo qua lang le, khong lam gian doan chat.
    }
  }

  /// Ep audio session ve che do "music" + xin lai audio focus truoc khi phat
  /// giong AI - man hinh nay dung mic ghi am lien tuc (record.AudioRecorder)
  /// ngay truoc do, khien Android giu audio mode/focus cho ghi am. _player
  /// (audioplayers, xem khai bao field o tren) khong bi anh huong boi loi
  /// "chi 1 AudioPlayer" cua just_audio_background nua, nhung van can xin
  /// lai focus rieng vi mic co the doi mode cua toan he thong.
  Future<String> _ensurePlaybackSession() async {
    try {
      final session = await AudioSession.instance;
      // KHONG dung const o day - operator | cua AVAudioSessionCategoryOptions
      // khong phai const (chi constructor cua no la const), nen bieu thuc
      // ket hop 3 flag bang | phai tinh luc chay, khong the la hang so bien
      // dich (analyzer bao loi const_eval_type_bool_int neu ep const).
      await session.configure(
        AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.defaultToSpeaker |
              AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.mixWithOthers,
          avAudioSessionMode: AVAudioSessionMode.spokenAudio,
          androidAudioAttributes: const AndroidAudioAttributes(
            contentType: AndroidAudioContentType.speech,
            usage: AndroidAudioUsage.voiceCommunication,
          ),
          androidAudioFocusGainType:
              AndroidAudioFocusGainType.gainTransientMayDuck,
        ),
      );
      final gotFocus = await session.setActive(true);
      return 'setActive=$gotFocus';
    } catch (e) {
      return 'session loi: $e';
    }
  }

  Future<void> _playResponse(List<int> wavBytes) async {
    // Gan future NGAY (dong bo, truoc await dau tien) de _onTranscript luon
    // thay _pendingAudioFuture != null va cho dung file cua luot nay - xem
    // giai thich trong _onTranscript.
    final future = _saveReplyAudio(wavBytes);
    _pendingAudioFuture = future;
    final path = await future;
    if (path == null) return;
    // Van luu file de nut "nghe lai" tren bong chat dung duoc (xem
    // _replayAudio) - chi bo qua phat NGAY luc nay, vi Anam da tu phat tieng
    // dong bo voi video qua WebRTC roi (xem AnamLiveAvatar), phat them lan
    // nua o day se bi vang/lech dong bo 2 nguon tieng.
    if (kUseAnamAvatar && _anamReady) return;
    try {
      await _ensurePlaybackSession();
      await _player.play(ap.DeviceFileSource(path));
    } catch (_) {
      // Loi phat lai khong lam gian doan phien chat - bo qua 1 luot noi.
    }
  }

  Future<String?> _saveReplyAudio(List<int> wavBytes) async {
    try {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/voice_chat_reply_${DateTime.now().millisecondsSinceEpoch}.wav';
      await File(path).writeAsBytes(wavBytes);
      return path;
    } catch (_) {
      return null;
    }
  }

  Future<void> _replayAudio(String path) async {
    try {
      await _ensurePlaybackSession();
      await _player.play(ap.DeviceFileSource(path));
    } catch (_) {
      // Bo qua - file tam co the da bi he thong don dep.
    }
  }

  String _statusLabel() {
    switch (_state) {
      case VoiceChatState.idle:
        return ref.tr('voice_chat_tap_to_start');
      case VoiceChatState.connecting:
        return ref.tr('voice_chat_connecting');
      case VoiceChatState.listening:
        return ref.tr('voice_chat_recording_stop');
      case VoiceChatState.thinking:
        return ref.tr('voice_chat_thinking');
      case VoiceChatState.error:
        return _error ?? ref.tr('voice_chat_error_generic');
    }
  }

  @override
  Widget build(BuildContext context) {
    final recording = _state == VoiceChatState.listening;
    final busy =
        _state == VoiceChatState.connecting ||
        _state == VoiceChatState.thinking;

    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 34,
                    height: 34,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.graphic_eq_rounded,
                  color: AppColors.blue,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ref.tr('voice_chat_title'),
                    style: AppTextStyles.heading(size: 20),
                  ),
                ),
                if (kUseDirectGeminiConnection)
                  GestureDetector(
                    onTap: (busy || recording) ? null : _pickVoice,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.glassFill,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.record_voice_over_rounded,
                            size: 14,
                            color: AppColors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _voiceName,
                            style: AppTextStyles.muted(size: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Text(ref.tr('voice_chat_subtitle'), style: AppTextStyles.muted()),
            const SizedBox(height: 12),
            if (kUseAnamAvatar) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      // Lop DAY CUNG, luon hien dien - phong truong hop CA 2
                      // nha cung cap deu loi (xem SpatiusLiveAvatar.onError
                      // ben duoi dat lai _spatiusWarmed = false, unmount
                      // luon lop Spatius) - khong de khung 220px nay TRONG
                      // SUOT hoan toan lam lo nen anh phia sau (bug da gap:
                      // "Anam het han dang load avatar thi bien mat").
                      Container(color: Colors.black),
                      // Lop Anam - luon ton tai, an di (opacity 0) sau khi da
                      // chuyen sang Spatius thay vi unmount, vi AnamLiveAvatar
                      // khong con nhan audio nua (_forwardAudioChunk da doi
                      // huong) nen khong ton chi phi chay ngam dang ke.
                      AnimatedOpacity(
                        opacity: _avatarProvider == AvatarProvider.anam
                            ? 1.0
                            : 0.0,
                        duration: const Duration(milliseconds: 250),
                        child: IgnorePointer(
                          ignoring: _avatarProvider != AvatarProvider.anam,
                          child: AnamLiveAvatar(
                            key: _anamKey,
                            avatarId: _currentAnamAvatarId,
                            // Uu tien qua Vercel proxy (xem anam_vercel_server/)
                            // neu da deploy - API key that CHI nam tren server,
                            // khong con bi nhung vao APK. Chua deploy
                            // (kAnamVercelProxyUrl rong) thi tam dung cach cu
                            // goi thang API key trong app. [avatarId] o day la
                            // gia tri MOI NHAT (_currentAnamAvatarId) - luon
                            // dung theo GeminiGender hien tai.
                            sessionTokenProvider: (avatarId) =>
                                kAnamVercelProxyUrl.isNotEmpty
                                ? AnamSessionApi.fetchSessionTokenFromProxy(
                                    kAnamVercelProxyUrl,
                                    avatarId: avatarId,
                                  )
                                : AnamSessionApi.fetchSessionToken(
                                    apiKey: Env.anamApiKeyDirect,
                                    avatarId: avatarId,
                                    avatarModel: kAnamAvatarModel,
                                  ),
                            onReady: () {
                              if (!mounted) return;
                              setState(() => _anamReady = true);
                              // Hoi am Spatius ngam ngay khi Anam vua ket noi
                              // duoc, de san sang chuyen mach < 1s neu sau
                              // nay Anam loi (xem _warmSpatiusIfNeeded).
                              _warmSpatiusIfNeeded();
                            },
                            onError: (msg) => _onAnamUnrecoverable(msg),
                          ),
                        ),
                      ),
                      // Lop Spatius - chi duoc mount (bat dau ket noi ngam)
                      // sau khi Anam da san sang lan dau, xem
                      // _warmSpatiusIfNeeded. AnimatedOpacity dao nguoc voi
                      // lop Anam o tren de tao hieu ung crossfade khi
                      // _avatarProvider doi tu anam sang spatius.
                      if (_spatiusWarmed)
                        AnimatedOpacity(
                          opacity: _avatarProvider == AvatarProvider.spatius
                              ? 1.0
                              : 0.0,
                          duration: const Duration(milliseconds: 250),
                          child: IgnorePointer(
                            ignoring: _avatarProvider != AvatarProvider.spatius,
                            child: SpatiusLiveAvatar(
                              key: _spatiusKey,
                              appId: kSpatiusAppId,
                              avatarId: _currentSpatiusAvatarId,
                              sessionTokenProvider: () =>
                                  SpatiusSessionApi.fetchSessionTokenFromProxy(
                                    kSpatiusVercelProxyUrl,
                                  ),
                              onReady: () {},
                              onError: (msg) {
                                // Ca 2 nha cung cap deu loi - khong con noi
                                // nao de du phong, chi tat hien thi avatar.
                                if (!mounted) return;
                                setState(() => _spatiusWarmed = false);
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Text(
                        ref.tr('voice_chat_empty'),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.muted(),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollCtrl,
                      itemCount: _messages.length,
                      itemBuilder: (context, i) => _MessageBubble(
                        message: _messages[i],
                        onReplay: _replayAudio,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              _statusLabel(),
              textAlign: TextAlign.center,
              style: _state == VoiceChatState.error
                  ? AppTextStyles.muted().copyWith(color: AppColors.pink)
                  : AppTextStyles.muted(),
            ),
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: busy ? null : _toggle,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (recording ? AppColors.pink : AppColors.blue)
                            .withValues(alpha: 0.5),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: busy
                      ? const Padding(
                          padding: EdgeInsets.all(22),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Icon(
                          recording ? Icons.stop_rounded : Icons.mic_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends ConsumerWidget {
  const _MessageBubble({required this.message, this.onReplay});

  final TranscriptEvent message;

  /// Goi khi bam nut nghe lai tren bong bao tra loi tu nhien cua AI -
  /// nhan duong dan file WAV da luu tam cua dung luot noi do (xem
  /// AiVoiceChatScreen._replayAudio).
  final Future<void> Function(String path)? onReplay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMine = message.role == ChatRole.user;
    final canReplay = !isMine && message.audioPath != null;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            decoration: BoxDecoration(
              color: isMine
                  ? (message.hasError
                        ? AppColors.pink.withValues(alpha: 0.18)
                        // Xanh kieu bong chat "cua minh" trong Messenger.
                        : const Color(0xFF0084FF))
                  : AppColors.glassFill,
              border: isMine
                  ? (message.hasError
                        ? Border.all(color: AppColors.pink, width: 1.4)
                        : null)
                  : Border.all(color: AppColors.glassBorder),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  // Cau tra loi cua AI: tach tung tu de cham vao tra tu dien +
                  // nghe phat am rieng tu do (giong man Nghe nhac/Doc sach) -
                  // nghe CA CAU thi bam nut loa rieng, khong con bam nguyen
                  // bong chat nua (se dam voi viec cham tung tu).
                  child: isMine
                      ? Text(
                          message.text,
                          style: AppTextStyles.body(
                            color: message.hasError
                                ? AppColors.pink
                                : Colors.white,
                          ),
                        )
                      : _TappableAiText(text: message.text),
                ),
                if (canReplay) ...[
                  const SizedBox(width: 8),
                  SpeakerButton(
                    onTap: () => onReplay!(message.audioPath!),
                    color: AppColors.blue,
                  ),
                ],
              ],
            ),
          ),
          if (message.correction != null)
            GestureDetector(
              onTap: () => AppTts.instance.speak(message.correction!),
              child: Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                ),
                decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.14),
                  border: Border.all(
                    color: AppColors.amber.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_rounded,
                      color: AppColors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${ref.tr('voice_chat_correction_prefix')}${message.correction}',
                        style: AppTextStyles.muted(size: 12)
                            .copyWith(color: AppColors.amber),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.volume_up_rounded,
                      color: AppColors.amber,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Chi tach cau AI thanh tung tu de cham tra tu dien - tuong tu Wrap+split
/// dung o man Player cho lyric, khong dung TextSpan/RegExp phuc tap nhu man
/// Doc sach vi cau chat thuong ngan, khong can tach cau/token chi tiet.
class _TappableAiText extends StatelessWidget {
  const _TappableAiText({required this.text});

  final String text;

  void _openWord(BuildContext context, String rawWord) {
    final clean = rawWord.replaceAll(RegExp("[^A-Za-z']"), '');
    if (clean.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => WordPopupSheet(
        word: clean,
        sentenceEn: text,
        sentenceVi: '',
        sourceLabelKey: 'word_in_chat',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.body();
    return Wrap(
      children: [
        for (final word in text.split(' '))
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _openWord(context, word),
            child: Padding(
              padding: const EdgeInsets.only(right: 4, bottom: 2),
              child: Text(word, style: style),
            ),
          ),
      ],
    );
  }
}

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/ai_voice_chat/data/voice_chat_client.dart';
import 'package:learn_english_music/features/ai_voice_chat/presentation/pt_voice_tracker.dart';

/// [ms] mili giay giong AI (PCM16 24 kHz), luan phien +/-[amplitude].
Uint8List _voice(int ms, {int amplitude = 16384}) {
  final count = 24 * ms;
  final data = ByteData(count * 2);
  for (var i = 0; i < count; i++) {
    data.setInt16(i * 2, i.isEven ? amplitude : -amplitude, Endian.little);
  }
  return data.buffer.asUint8List();
}

Duration _ms(int ms) => Duration(milliseconds: ms);

void main() {
  late PtVoiceTracker t;
  setUp(() => t = PtVoiceTracker(avatarDelay: Duration.zero));
  tearDown(() => t.dispose());

  // Thu tu su kien that cua GeminiLiveDirectClient: endTurn -> thinking ->
  // cac goi am thanh -> (turnComplete) turnAudioEnd -> idle.
  group('avatar plays the reply', () {
    test('thinking until the first audio, speaking until it has played', () {
      t.onClientState(VoiceChatState.listening);
      expect(t.display, PtVoiceState.listening);
      t.onClientState(VoiceChatState.thinking);
      expect(t.display, PtVoiceState.thinking);
      // Server gui 1 s am thanh trong 200 ms (nhanh hon thoi gian thuc).
      for (var i = 0; i < 5; i++) {
        t.onAiChunk(_voice(200), at: _ms(1000 + 40 * i), avatarPlays: true);
      }
      expect(t.display, PtVoiceState.speaking);
      expect(t.ticking, isTrue);
      // Het luot den truoc khi avatar noi xong: van Noi.
      t.onTurnAudioEnd();
      t.onClientState(VoiceChatState.idle);
      t.tick(_ms(1500));
      expect(t.display, PtVoiceState.speaking);
      expect(t.aiLevel.value, closeTo(0.88, 0.01));
      t.tick(_ms(2001));
      expect(t.display, PtVoiceState.idle);
      expect(t.ticking, isFalse);
      expect(t.aiLevel.value, 0);
    });

    test('the avatar starts a little after the first audio', () {
      final delayed = PtVoiceTracker(avatarDelay: _ms(400));
      addTearDown(delayed.dispose);
      delayed.onClientState(VoiceChatState.thinking);
      delayed.onAiChunk(_voice(200), at: _ms(0), avatarPlays: true);
      delayed.onTurnAudioEnd();
      // Ticker van chay de biet luc avatar bat dau.
      expect(delayed.ticking, isTrue);
      delayed.tick(_ms(300));
      expect(delayed.display, PtVoiceState.thinking);
      expect(delayed.aiLevel.value, 0);
      delayed.tick(_ms(450));
      expect(delayed.display, PtVoiceState.speaking);
      expect(delayed.aiLevel.value, closeTo(0.88, 0.01));
      delayed.tick(_ms(601));
      expect(delayed.display, PtVoiceState.thinking);
    });

    test('small chunks: speaking ends when the audio has played', () {
      t.onClientState(VoiceChatState.thinking);
      // 3 s am thanh trong 75 goi 40 ms, server nhanh gap 4.
      for (var i = 0; i < 75; i++) {
        t.onAiChunk(_voice(40), at: _ms(10 * i), avatarPlays: true);
      }
      t.onTurnAudioEnd();
      t.onClientState(VoiceChatState.idle);
      t.tick(_ms(1500));
      expect(t.aiLevel.value, closeTo(0.88, 0.01));
      t.tick(_ms(2990));
      expect(t.display, PtVoiceState.speaking);
      expect(t.aiLevel.value, closeTo(0.88, 0.01));
      t.tick(_ms(3001));
      expect(t.display, PtVoiceState.idle);
    });

    test('a server slower than real time leaves silent gaps', () {
      t.onClientState(VoiceChatState.thinking);
      t.onAiChunk(_voice(200), at: _ms(0), avatarPlays: true);
      t.onAiChunk(_voice(200), at: _ms(500), avatarPlays: true);
      t.tick(_ms(100));
      expect(t.aiLevel.value, closeTo(0.88, 0.01));
      // Het phan da nhan nhung chua het luot: van Noi, thanh song ve 0.
      t.tick(_ms(350));
      expect(t.display, PtVoiceState.speaking);
      expect(t.aiLevel.value, 0);
      t.tick(_ms(600));
      expect(t.aiLevel.value, closeTo(0.88, 0.01));
      t.onTurnAudioEnd();
      t.onClientState(VoiceChatState.idle);
      t.tick(_ms(701));
      expect(t.display, PtVoiceState.idle);
    });

    test('a server just slower than real time keeps the bars in time', () {
      t.onClientState(VoiceChatState.thinking);
      // 50 goi 40 ms im lang, moi goi den sau 41 ms; roi 1 goi to.
      for (var i = 0; i < 50; i++) {
        t.onAiChunk(
          _voice(40, amplitude: 0),
          at: _ms(41 * i),
          avatarPlays: true,
        );
      }
      t.onAiChunk(_voice(40), at: _ms(41 * 50), avatarPlays: true);
      t.tick(_ms(2000));
      expect(t.aiLevel.value, 0);
      // Goi to phat tu 2050 ms: thanh song len dung luc do.
      t.tick(_ms(2060));
      expect(t.aiLevel.value, greaterThan(0.8));
    });

    test('a connection closed mid-reply does not leave the coach speaking', () {
      t.onClientState(VoiceChatState.thinking);
      t.onAiChunk(_voice(200), at: _ms(0), avatarPlays: true);
      // Dong ket noi binh thuong truoc turnComplete: phat not phan da nhan.
      t.onClientState(VoiceChatState.idle);
      t.tick(_ms(100));
      expect(t.display, PtVoiceState.speaking);
      t.tick(_ms(201));
      expect(t.display, PtVoiceState.idle);
      // Loi: thoi noi ngay.
      t.onClientState(VoiceChatState.thinking);
      t.onAiChunk(_voice(200), at: _ms(1000), avatarPlays: true);
      t.onClientState(VoiceChatState.error);
      expect(t.display, PtVoiceState.error);
      expect(t.ticking, isFalse);
    });

    test('talking over the coach stops it at once', () {
      t.onClientState(VoiceChatState.thinking);
      t.onAiChunk(_voice(200), at: _ms(0), avatarPlays: true);
      t.onMicLevel(0.7);
      t.onClientState(VoiceChatState.listening);
      expect(t.display, PtVoiceState.listening);
      expect(t.ticking, isFalse);
      // Vong mic bat dau lai tu 0 moi luot nghe.
      expect(t.micLevel.value, 0);
      t.onAiChunk(_voice(200), at: _ms(100), avatarPlays: true);
      expect(t.display, PtVoiceState.listening);
    });
  });

  group('speaker plays the reply', () {
    test('thinking until the speaker plays, bars follow the file', () {
      t.onClientState(VoiceChatState.thinking);
      // Khong co avatar: goi am thanh chua phat ra -> van Nghi.
      t.onAiChunk(_voice(200), at: _ms(0), avatarPlays: false);
      expect(t.display, PtVoiceState.thinking);
      expect(t.ticking, isFalse);
      // Het luot: file WAV cho loa, client ve idle - van Nghi.
      t.queueReply([0.2, 0.9]);
      t.onTurnAudioEnd();
      t.onClientState(VoiceChatState.idle);
      expect(t.display, PtVoiceState.thinking);
      t.onPlayer(playing: true, at: _ms(1000));
      expect(t.display, PtVoiceState.speaking);
      t.tick(_ms(1010));
      expect(t.aiLevel.value, 0.2);
      t.tick(_ms(1060));
      expect(t.aiLevel.value, 0.9);
      t.onPlayer(playing: false, at: _ms(1100));
      expect(t.display, PtVoiceState.idle);
      expect(t.aiLevel.value, 0);
    });

    test('a reply that will not play goes back to idle', () {
      t.onClientState(VoiceChatState.thinking);
      t.queueReply(const []);
      t.onClientState(VoiceChatState.idle);
      expect(t.display, PtVoiceState.thinking);
      t.dropReply();
      expect(t.display, PtVoiceState.idle);
    });

    test('an unreadable file still shows mid bars', () {
      t.queueReply(const []);
      t.onPlayer(playing: true, at: _ms(0));
      t.tick(_ms(10));
      expect(t.aiLevel.value, 0.5);
    });

    test('a replay is speaking when idle, not while waiting for a reply', () {
      t.queueReplay(const [0.4]);
      t.onPlayer(playing: true, at: _ms(0));
      expect(t.display, PtVoiceState.speaking);
      t.onPlayer(playing: false, at: _ms(100));
      expect(t.display, PtVoiceState.idle);
      t.onClientState(VoiceChatState.thinking);
      t.queueReplay(const [0.4]);
      t.onPlayer(playing: true, at: _ms(200));
      expect(t.display, PtVoiceState.thinking);
      // Khong hien la Noi -> khong chay ticker moi khung hinh.
      expect(t.ticking, isFalse);
    });
  });

  test('connecting and errors pass through', () {
    t.onClientState(VoiceChatState.connecting);
    expect(t.display, PtVoiceState.connecting);
    t.onClientState(VoiceChatState.error);
    expect(t.display, PtVoiceState.error);
  });

  test('notifies only when the state or ticking changes', () {
    var calls = 0;
    t.addListener(() => calls++);
    t.onClientState(VoiceChatState.thinking);
    expect(calls, 1);
    t.onAiChunk(_voice(200), at: _ms(0), avatarPlays: true);
    expect(calls, 2);
    t.onAiChunk(_voice(200), at: _ms(10), avatarPlays: true);
    t.tick(_ms(50));
    t.onMicLevel(0.3);
    expect(calls, 2);
  });
}

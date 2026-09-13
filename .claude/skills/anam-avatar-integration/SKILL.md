---
name: anam-avatar-integration
description: Kiến trúc + quy trình bảo trì avatar siêu thực Anam.ai (video WebRTC, lipsync realtime theo audio Gemini Live) trong tính năng AI Voice Chat - dùng khi cần bật/sửa/mở rộng tính năng này, debug lỗi audio/video, hoặc nâng cấp @anam-ai/js-sdk.
---

# Tích hợp avatar 3D Anam.ai cho AI Voice Chat

## Kiến trúc tổng quan

```
Gemini Live (WebSocket, audio PCM16 24kHz) --> GeminiLiveDirectClient (Dart)
    --> liveAudioChunks stream --> AnamLiveAvatar (InAppWebView)
    --> assets/anam/anam_bridge.html (JS, @anam-ai/js-sdk)
    --> audioInputStream.sendAudioChunk() --> Anam WebRTC
    --> <video> element (mang SAN CA audio lan video da dong bo)
```

**Nguyên tắc cốt lõi: Anam là nguồn phát audio DUY NHẤT khi avatar bật.**
Không tự phát lại audio qua Web Audio API hay `audioplayers` ở tầng Flutter
song song — xem "Bug đã gặp" bên dưới để hiểu vì sao.

## File liên quan

| File | Vai trò |
|---|---|
| `app/assets/anam/anam_bridge.html` | Cầu nối JS: khởi tạo Anam SDK, nhận audio từ Flutter, forward vào `audioInputStream` |
| `app/lib/features/ai_voice_chat/presentation/anam_live_avatar.dart` | Widget `AnamLiveAvatar` bọc `InAppWebView`, expose `sendAudioChunk`/`interruptPersona`/`endTurn` |
| `app/lib/features/ai_voice_chat/data/anam_session_api.dart` | Đổi session token — qua Vercel proxy (`fetchSessionTokenFromProxy`) hoặc thẳng API key (`fetchSessionToken`, chỉ dev/test) |
| `app/lib/features/ai_voice_chat/data/gemini_live_direct_client.dart` | Emit `liveAudioChunks`/`turnAudioEnd` NGAY khi nhận audio từ Gemini (trước cả turnComplete) để độ trễ thấp |
| `app/lib/features/ai_voice_chat/data/voice_chat_config.dart` | Cờ `kUseAnamAvatar`, `kAnamAvatarId`, `kAnamAvatarModel`, `kAnamVercelProxyUrl` |
| `app/third_party/flutter_inappwebview_android/` | Bản vá local của `flutter_inappwebview_android` (xem mục AGP bên dưới) |
| `anam_vercel_server/` (repo riêng: `github.com/quangpromise/anam-session-proxy`) | Serverless proxy giữ `ANAM_API_KEY` thật, không nhúng vào APK |

## API thật của Anam SDK (đã verify từ docs.anam.ai, KHÔNG suy đoán)

```js
import { createClient, AnamEvent } from '@anam-ai/js-sdk';

const client = createClient(sessionToken, { disableInputAudio: true });
await client.streamToVideoElement('video-id'); // video mang SAN audio+hình
const stream = client.createAgentAudioInputStream({
  encoding: 'pcm_s16le', sampleRate: 24000, channels: 1,
});
stream.sendAudioChunk(uint8ArrayBytes);
stream.endSequence(); // het 1 luot noi
client.interruptPersona(); // ngat loi (barge-in)
client.addListener(AnamEvent.CONNECTION_CLOSED, (reason, details) => {});
client.addListener(AnamEvent.VIDEO_PLAY_STARTED, () => {}); // frame dau THUC SU hien
await client.stopStreaming();
```

- **KHÔNG có** `client.on(...)`, `client.start({token})`, hay method
  resume/reconnect nào — muốn "nối lại" phải tạo `createClient()` MỚI hoàn
  toàn từ 1 session token mới (xem `initAnam()`/`restartAnamSession` trong
  `anam_bridge.html`, thực chất là cùng 1 hàm).
- Tạo session token: `POST https://api.anam.ai/v1/auth/session-token`, body
  `{personaConfig: {avatarId, avatarModel, enableAudioPassthrough: true,
  maxSessionLengthSeconds}}` (không phải `ttl`).
- `sessionOptions.videoQuality`: `"high"` (mặc định) = ép bitrate cao nhất
  ngay từ đầu; `"auto"` = ABR tăng dần từ thấp — **ngược trực giác**:
  `"auto"` thường cho khung hình đầu tiên NHANH HƠN trên mạng yếu.

## Bug đã gặp — đọc trước khi đụng vào audio/video

1. **`<video muted="false">` vẫn bị câm.** `muted` là boolean attribute của
   HTML — CHỈ CẦN CÓ MẶT là câm, bất kể giá trị chuỗi. Đây là nguyên nhân
   thật của bug "avatar mấp máy môi nhưng không ra tiếng". Không bao giờ
   đặt thuộc tính này trên `<video>` trong `anam_bridge.html`; nếu cần chắc
   chắn, set qua JS property `videoEl.muted = false` (khác HTML attribute).
2. **Đừng tự phát lại audio qua Web Audio API song song với video.** Video
   WebRTC của Anam đã tự mang audio đồng bộ — thêm 1 tầng phát riêng tạo
   2 nguồn tranh nhau AudioContext, dễ gây câm tiếng hoàn toàn hoặc lệch
   đồng bộ. Chỉ cần gọi `sendAudioChunk` để nạp lipsync, không làm gì thêm.
3. **`flutter_inappwebview_android` xung đột AGP 9.1.0.** Bản pub.dev mới
   nhất (1.1.3) dùng `getDefaultProguardFile('proguard-android.txt')` — AGP
   9+ chặn cứng API này (đã gồm `-dontoptimize`). Đã vendor 1 bản vá vào
   `app/third_party/flutter_inappwebview_android/` (đổi sang
   `'proguard-android-optimize.txt'`) + override trong `pubspec.yaml`
   (`dependency_overrides: flutter_inappwebview_android: path: ...`). XOÁ
   override này khi upstream phát hành bản vá thật (kiểm tra CHANGELOG.md
   tại pub.dev/packages/flutter_inappwebview_android).
4. **Nhạc phát rất nhỏ sau khi rời AI Voice Chat.** Màn này đổi
   `AudioSession` sang `voiceCommunication` (loa thoại) để mic ghi âm rõ.
   `AudioSession` là singleton dùng chung toàn app — phải khôi phục về
   `.music()` trong `dispose()` của `AiVoiceChatScreen`, nếu không nhạc bị
   kẹt ở loa thoại cho tới khi `NowPlayingService` mở 1 hàng đợi bài MỚI
   (resume bài đang mở dở không kích hoạt lại `.music()`).
5. **Gói Free của Anam tự đóng phiên sau ~3 phút.** Bắt bằng
   `AnamEvent.CONNECTION_CLOSED`, phân biệt với việc TỰ đóng (barge-in/rời
   màn hình) bằng cờ `intentionalStop` trong `anam_bridge.html` — nếu không
   phân biệt sẽ vòng lặp xin token vô ích mỗi lần người dùng tự thoát.

## Bật tính năng để test

1. `kUseAnamAvatar = true` trong `voice_chat_config.dart`.
2. Deploy `anam_vercel_server/` lên Vercel (xem README trong đó), set env
   `ANAM_API_KEY`, cập nhật `kAnamVercelProxyUrl` = URL Vercel.
3. Build APK bình thường (`[build]` trong commit message) — không cần thêm
   dart-define nào vì API key giờ chỉ nằm trên Vercel.

## Khi cần cập nhật `@anam-ai/js-sdk`

Đổi số version trong URL import của `anam_bridge.html`:
```js
import { createClient, AnamEvent } from 'https://cdn.jsdelivr.net/npm/@anam-ai/js-sdk@<version>/+esm';
```
Kiểm tra lại các API đã liệt kê ở trên còn đúng không (đọc CHANGELOG tại
anam.ai/docs/changelog) trước khi đổi version trong production.

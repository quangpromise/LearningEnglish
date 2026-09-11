# Nghiên cứu: Khuôn mặt AI (avatar) lip-sync cho tính năng AI Voice Chat

Mục tiêu: đánh giá có nên thêm avatar hiển thị khuôn mặt "nói" đồng bộ theo audio đang phát trong màn `ai_voice_chat`, và nếu có thì chọn công nghệ nào — ưu tiên miễn phí/mã nguồn mở, chạy on-device, không phát sinh chi phí server mới, tương thích với kiến trúc backend Gemini Live + fallback tự host đã có (xem `docs/research-ai-voice.md`).

**Kết luận nhanh: CÓ NÊN THÊM**, nhưng chỉ ở mức **avatar 2D lip-sync theo biên độ âm thanh (amplitude-driven), dựng bằng Rive**, chạy hoàn toàn phía client — không cần đổi gì ở backend. Không nên đầu tư 3D avatar hay viseme-chuẩn-âm-vị ở giai đoạn này vì chi phí/độ phức tạp không tương xứng lợi ích cho một app học tiếng Anh qua âm nhạc.

## 1. Vấn đề cốt lõi: nguồn dữ liệu để lip-sync có gì?

Trước khi chọn công cụ dựng avatar, phải xác định **client nhận được gì từ backend** để điều khiển miệng — đây là yếu tố quyết định, không phải ngược lại.

| Nguồn audio | Có kèm viseme/phoneme timing không? | Ghi chú |
|---|---|---|
| **Google Gemini Live API** (nhánh chính) | **Không.** Chỉ trả về audio thô (PCM 16-bit, mono, 24kHz) qua WebSocket, không có bất kỳ metadata viseme/phoneme nào trong tài liệu chính thức. | Đã tìm kỹ tài liệu `ai.google.dev/gemini-api/docs/live-api` và các docs liên quan — không có trường viseme. Google không công bố kế hoạch bổ sung. |
| **Piper TTS** (fallback tự host hiện tại) | Không (bản gốc). | Có fork cộng đồng **piper-plus** xuất được phoneme timing (JSON/TSV/SRT) nhưng là fork chưa chính chủ, cần tự đánh giá độ ổn định trước khi thay Piper gốc. |
| **Azure Neural TTS** | **Có** — sự kiện `VisemeReceived` trả về ID viseme + thời điểm đồng bộ audio, hỗ trợ cả xuất blend shape cho 3D. | Đã dùng trong dự án cho Pronunciation Assessment (free tier 5h/tháng) — nếu dùng thêm cho TTS ở AI Voice Chat sẽ **cạnh tranh chung quota free** với tính năng luyện phát âm, và Azure TTS không phải nguồn audio chính (Gemini Live mới là chính). |
| **HeadTTS** (dự án mã nguồn mở mới, dùng model Kokoro) | **Có** — xuất kèm timestamp + Oculus visemes, chạy được local (WASM/Node, không cần cloud). | Đáng theo dõi cho roadmap sau, nhưng là engine TTS riêng — muốn dùng phải thay thế toàn bộ audio output của Gemini Live/Piper, không khả thi làm lớp phủ (overlay) lên audio đã có sẵn. |

**Hệ quả quan trọng**: vì nguồn audio chính (Gemini Live) không có viseme, muốn lip-sync "theo âm vị chuẩn" ngay từ đầu bắt buộc phải tự làm audio-to-viseme trên client (chạy mô hình nhận diện phoneme theo thời gian thực trên từng khung audio) — độ phức tạp và độ trễ tăng đáng kể, không phù hợp làm MVP. Ngược lại, **phân tích biên độ (amplitude) của chính buffer PCM đang phát** thì luôn làm được với bất kỳ nguồn audio nào (Gemini Live hay fallback), không cần thay đổi gì ở backend, độ trễ gần như 0 vì tính toán ngay trên thiết bị.

## 2. Bảng so sánh giải pháp dựng avatar

| Giải pháp | License / chi phí | Hạ tầng cần | Chất lượng lip-sync | Độ phức tạp tích hợp Flutter | Khuyến nghị |
|---|---|---|---|---|---|
| **Rive (runtime `rive`/`rive_native` trên pub.dev) + amplitude-driven mouth** | Runtime MIT — dùng thương mại tự do, không phí bản quyền khi export. Rive Editor (dựng animation): plan Free chỉ cho học/thử; muốn export file `.riv` dùng sản xuất cần gói **Cadet $9/tháng** (trả 1 lần cho người dựng animation, không phải phí runtime lặp lại) | Không cần server — chạy hoàn toàn on-device | Trung bình-khá: miệng mở/khép theo biên độ tức thời (RMS) bằng "Number Input" trong Rive State Machine, nội suy mượt qua easing — đủ thuyết phục về mặt cảm giác "đang nói", không phải lip-sync âm vị chính xác | Thấp — package `rive` chính chủ, tài liệu tốt, cộng đồng lớn, còn bảo trì tích cực (bản native mới `rive_native` năm 2026) | **Chọn cho MVP** |
| **Lottie (`lottie` trên pub.dev) chuyển đổi giữa vài animation miệng** | Lottie-Flutter: Apache 2.0/MIT tùy fork, miễn phí thương mại | Không cần server | Thấp hơn Rive — không có state machine nội suy built-in, phải tự lập trình chuyển cảnh giữa các keyframe miệng đóng/mở, dễ giật | Trung bình — không có giải pháp lip-sync "có sẵn" cho Lottie theo xác nhận từ nhiều nguồn 2026 | Không chọn — Rive làm tốt hơn với cùng effort |
| **Live2D Cubism SDK** | Miễn phí cho doanh nghiệp/cá nhân có doanh thu năm dưới 10 triệu JPY (~1.7 tỷ VNĐ); vượt ngưỡng phải mua gói Pro Business trả phí | Không cần server, nhưng SDK gốc là native C++/Java/Swift — **không có runtime Flutter chính chủ**, phải tự viết platform channel hoặc dùng wrapper cộng đồng (rủi ro bảo trì) | Cao nếu đầu tư kỹ (chuẩn cho avatar anime 2D, dùng nhiều trong VTuber) | Cao — thêm native SDK, build phức tạp hơn hẳn, tăng dung lượng APK | Không chọn cho giai đoạn này — chi phí tích hợp không tương xứng lợi ích cho app học tiếng Anh |
| **3D avatar (Ready Player Me + `model_viewer_plus`, hoặc glTF blend shapes)** | Ready Player Me: free tier cho avatar cơ bản, nhưng điều khoản thương mại quy mô lớn cần liên hệ; `model_viewer_plus` là wrapper quanh `<model-viewer>` web component (Apache 2.0) | Không bắt buộc server, nhưng render 3D + blend shape animation theo thời gian thực tốn CPU/GPU đáng kể trên điện thoại tầm trung — rủi ro giật lag, tốn pin | Cao nhất về mặt lý thuyết (blend shape chuẩn ARKit/Oculus) nhưng khó đạt mượt trên mobile giá rẻ mà không có viseme timing từ nguồn audio (quay lại vấn đề mục 1) | Rất cao — cần pipeline glTF + blend shape driver, `model_viewer_plus` không có API điều khiển blend shape theo audio real-time sẵn có | Không chọn — quá nặng, không cần thiết cho mục tiêu học tiếng Anh qua âm nhạc |
| **`simli_flutter` (dịch vụ Simli — avatar AI lip-sync cloud)** | Dịch vụ trả phí theo phút, có API riêng, không phải mã nguồn mở | **Cần gọi API cloud riêng** (thêm nhà cung cấp, thêm chi phí, thêm độ trễ mạng) | Cao — avatar do AI tạo sẵn, lip-sync chuẩn vì Simli tự xử lý audio-to-viseme phía họ | Thấp về code nhưng cao về chi phí vận hành & phụ thuộc bên thứ 3 | Không chọn — vi phạm nguyên tắc ưu tiên miễn phí/offline của dự án, thêm nhà cung cấp trả phí không cần thiết |

## 3. Giới hạn kỹ thuật quan trọng

- **Amplitude-driven ≠ viseme thật.** Cách làm MVP (đo biên độ RMS của audio buffer đang phát, ánh xạ sang "độ mở miệng" 0-1, feed vào Number Input của Rive State Machine) chỉ tạo cảm giác "miệng đang mấp máy theo nhịp nói", KHÔNG khớp hình dạng miệng theo từng âm vị (không phân biệt được âm "o" tròn môi với âm "s" mím môi). Với ứng dụng học tiếng Anh, đây là điểm cần nêu rõ trong UI/kỳ vọng người dùng — avatar là yếu tố tăng trải nghiệm sinh động, không phải công cụ dạy khẩu hình phát âm (khẩu hình chuẩn nên tiếp tục dựa vào nội dung IPA/minh họa của `pronunciation-researcher`, không phải avatar).
- **Muốn viseme chuẩn thật sự** bắt buộc phải có 1 trong 2: (a) nguồn TTS hỗ trợ viseme timing (Azure Neural TTS, HeadTTS) thay cho Gemini Live/Piper hiện tại — đổi kiến trúc âm thanh chính của tính năng; hoặc (b) chạy mô hình audio-to-phoneme trên thiết bị theo thời gian thực (tăng CPU, độ trễ, độ phức tạp) — cả hai đều không đáng đánh đổi ở giai đoạn hiện tại.
- **Độ trễ**: vì Gemini Live stream audio theo chunk nhỏ liên tục, tính RMS trên từng chunk và cập nhật Number Input mỗi ~50-100ms là đủ mượt và không cần buffer trước — giữ đúng tinh thần "phản hồi tức thời" của tính năng.
- **Dung lượng APK**: Rive runtime (`rive`/`rive_native`) nhẹ, file `.riv` avatar thường vài trăm KB — không ảnh hưởng đáng kể tới kích thước APK sideload.
- **iOS (giai đoạn 2)**: package `rive` là runtime đa nền tảng chính chủ (Flutter), không có rào cản riêng cho iOS — thuận lợi khi mở rộng App Store sau này, đúng định hướng "1 codebase" của dự án.

## 4. Kiến trúc đề xuất (MVP)

```
Backend proxy (Gemini Live / fallback Whisper+Ollama+Piper)
      │  audio PCM stream (WebSocket) — KHÔNG đổi gì so với hiện tại
      ▼
App Flutter (ai_voice_chat)
      │
      ├─ Audio player (đã có) phát PCM ra loa
      │
      └─ Lớp phân tích biên độ (mới, thuần client, không gọi mạng):
             mỗi chunk PCM nhận về → tính RMS → chuẩn hoá 0.0–1.0
             → gửi vào Rive State Machine qua Number Input "mouthOpen"
             → Rive tự nội suy hoạt ảnh miệng mở/khép + trạng thái idle khi im lặng
```

Vì lớp lip-sync chỉ đọc buffer audio đã có sẵn ở client (không quan tâm audio đến từ Gemini hay từ pipeline fallback), **avatar hoạt động giống nhau bất kể đang dùng nhánh chính hay nhánh dự phòng** — không cần thêm logic phân nhánh, giữ đúng nguyên tắc "client không cần biết backend đang dùng nguồn nào" đã thiết lập trong `docs/research-ai-voice.md`.

## 5. Việc cần làm khi triển khai (không thuộc phạm vi nghiên cứu này, ghi chú để tham khảo)
- Cần 1 người có khả năng dựng animation trong Rive Editor (hoặc thuê ngoài/mua asset avatar Rive có sẵn license phù hợp) — tạo artboard với ít nhất 2 trạng thái miệng (đóng/mở) + State Machine nội suy qua Number Input.
- Gói Rive Editor **Cadet ($9/tháng)** chỉ cần trả trong (các) tháng thực sự dựng/export animation — không phải chi phí vận hành lặp lại cho ứng dụng đã phát hành (file `.riv` xuất ra dùng vĩnh viễn, không cần license runtime).
- Nên bắt đầu bằng 1 avatar mặc định duy nhất (không cá nhân hoá) để giữ MVP đơn giản.

## 6. Lộ trình nâng cấp nếu muốn chất lượng cao hơn (không làm ngay)
1. **Bước kế tiếp (nếu cần)**: thử nghiệm thay Piper bằng **piper-plus** (fork mã nguồn mở, MIT tương tự Piper gốc — cần tự xác minh license bản fork cụ thể trước khi dùng) để lấy phoneme timing cho riêng nhánh fallback tự host, ánh xạ phoneme → viseme đơn giản (nhóm ~6-8 hình miệng theo IPA), chỉ áp dụng khi audio đến từ fallback (Gemini Live vẫn dùng amplitude).
2. **Xa hơn**: theo dõi HeadTTS (mã nguồn mở, chạy local WASM/Node, có viseme timing) như một ứng viên thay thế toàn bộ pipeline TTS tự host nếu chất lượng giọng đủ tốt và license phù hợp — cần nghiên cứu riêng khi tới lúc.
3. **Không khuyến nghị** theo đuổi Live2D hay 3D avatar trừ khi sản phẩm đổi định hướng thành app có yếu tố nhân vật/giải trí mạnh hơn — không phù hợp với trọng tâm học tiếng Anh qua âm nhạc hiện tại.

## Nguồn tham khảo
- Rive runtime license (MIT) — [github.com/rive-app/rive-runtime/blob/main/LICENSE](https://github.com/rive-app/rive-runtime/blob/main/LICENSE), [pub.dev/packages/rive](https://pub.dev/packages/rive), [help.rive.app/runtimes/overview/flutter](https://help.rive.app/runtimes/overview/flutter)
- Rive Editor pricing 2026 — [rive.app/pricing](https://rive.app/pricing), [rive.app/blog/rive-s-new-9-mo-plan](https://rive.app/blog/rive-s-new-9-mo-plan)
- Rive State Machine cho lip-sync theo viseme — [dev.to/uianimation/how-to-build-real-time-ai-lip-sync-using-rive-state-machine-viseme-data-26o7](https://dev.to/uianimation/how-to-build-real-time-ai-lip-sync-using-rive-state-machine-viseme-data-26o7)
- Gemini Live API audio output format (PCM, không có viseme) — [ai.google.dev/gemini-api/docs/live-api](https://ai.google.dev/gemini-api/docs/live-api)
- Azure Neural TTS viseme events — [learn.microsoft.com/.../how-to-speech-synthesis-viseme](https://learn.microsoft.com/en-us/azure/ai-services/speech-service/how-to-speech-synthesis-viseme), [techcommunity.microsoft.com — Azure Neural TTS lip-sync viseme](https://techcommunity.microsoft.com/blog/azure-ai-foundry-blog/azure-neural-text-to-speech-extended-to-support-lip-sync-with-viseme/2356748)
- Live2D Cubism SDK license (ngưỡng doanh thu 10 triệu JPY) — [live2d.com/en/sdk/license](https://www.live2d.com/en/sdk/license/)
- Rhubarb Lip Sync (MIT, CLI offline, không phù hợp streaming real-time) — [github.com/DanielSWolf/rhubarb-lip-sync](https://github.com/DanielSWolf/rhubarb-lip-sync)
- Piper-plus fork (phoneme timing) — [github.com/ayutaz/piper-plus](https://github.com/ayutaz/piper-plus/blob/dev/README_EN.md)
- HeadTTS (mã nguồn mở, viseme + timestamp, chạy local) — [github.com/met4citizen/HeadTTS](https://github.com/met4citizen/HeadTTS)
- Lottie Flutter không có audio-to-lipsync sẵn — kết quả tổng hợp tìm kiếm 2026 (Mascotbot blog, các bài hướng dẫn Rive vs Lottie)
- `simli_flutter` (dịch vụ cloud trả phí, không chọn) — [pub.dev/packages/simli_flutter](https://pub.dev/packages/simli_flutter)

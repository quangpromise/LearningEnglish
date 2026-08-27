# Nghiên cứu: dịch song ngữ & phát âm mẫu (TTS)

## Dịch (song ngữ Anh–Việt)
| Giải pháp | Chi phí | Offline? | Ghi chú |
|---|---|---|---|
| google_mlkit_translation (đã thử, bỏ) | Miễn phí, không giới hạn lượt gọi | ✅ On-device | Nhúng file native `libtranslate_jni.so` ~16MB/kiến trúc CPU vào APK — riêng thư viện này chiếm ~44% dung lượng app (36.7MB → nếu bỏ còn ~20MB). Đổi lại lợi ích offline không đáng so với cái giá dung lượng, nhất là khi các tính năng khác (từ điển, giọng đọc chất lượng cao) cũng đã cần mạng |
| **MyMemory Translation API** (đang dùng) | Miễn phí, không cần key, ~5000 từ/ngày/IP | ❌ Cần mạng | Gọi HTTP thuần qua package `http` đã có sẵn — không thêm dung lượng APK. Chất lượng dịch từ đơn/câu ngắn đủ tốt cho nhu cầu tra nghĩa trong app |
| Google Cloud Translation API | Free tier 500.000 ký tự/tháng, sau đó tính phí | ❌ Cần mạng | Chất lượng cao hơn MyMemory nếu cần sau này, nhưng thêm 1 dependency cloud + billing như Google Cloud TTS |

**Quyết định**: chuyển từ `google_mlkit_translation` sang MyMemory Translation API để giảm dung lượng APK đáng kể — xem commit lịch sử để biết chi tiết đo đạc.

## Phát âm mẫu (Text-to-Speech)
| Giải pháp | Chi phí | Offline? | Chất lượng giọng |
|---|---|---|---|
| **flutter_tts** (đang dùng, mặc định) | Miễn phí | ✅ Dùng engine TTS gốc máy | Phụ thuộc thiết bị, chấp nhận được cho nhu cầu học cơ bản |
| Google Cloud TTS | Free tier 4 triệu ký tự standard/tháng, 1 triệu ký tự WaveNet/tháng | ❌ Cần mạng | Giọng tự nhiên hơn, có nhiều giọng vùng miền (Anh-Anh, Anh-Úc...) — nâng cấp khi cần chất lượng cao hơn |

**Quyết định**: `flutter_tts` làm mặc định; để ngỏ nâng cấp Google Cloud TTS cho tính năng "nghe giọng bản địa" nếu người dùng phản hồi cần chất lượng cao hơn.

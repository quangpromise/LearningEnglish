# Nghiên cứu: dịch song ngữ & phát âm mẫu (TTS)

## Dịch (song ngữ Anh–Việt)
| Giải pháp | Chi phí | Offline? | Ghi chú |
|---|---|---|---|
| **google_mlkit_translation** (đang dùng) | Miễn phí, không giới hạn lượt gọi | ✅ On-device | Hỗ trợ 50+ ngôn ngữ, dịch qua trung gian English nên non-English↔non-English kém hơn — nhưng English↔Vietnamese dịch trực tiếp, đủ tốt cho nhu cầu app |
| Google Cloud Translation API | Free tier 500.000 ký tự/tháng, sau đó tính phí | ❌ Cần mạng | Dùng khi cần chất lượng dịch cao hơn ML Kit, chấp nhận phụ thuộc mạng |

**Quyết định**: giữ `google_mlkit_translation` làm mặc định vì offline + miễn phí phù hợp mục tiêu dự án.

## Phát âm mẫu (Text-to-Speech)
| Giải pháp | Chi phí | Offline? | Chất lượng giọng |
|---|---|---|---|
| **flutter_tts** (đang dùng, mặc định) | Miễn phí | ✅ Dùng engine TTS gốc máy | Phụ thuộc thiết bị, chấp nhận được cho nhu cầu học cơ bản |
| Google Cloud TTS | Free tier 4 triệu ký tự standard/tháng, 1 triệu ký tự WaveNet/tháng | ❌ Cần mạng | Giọng tự nhiên hơn, có nhiều giọng vùng miền (Anh-Anh, Anh-Úc...) — nâng cấp khi cần chất lượng cao hơn |

**Quyết định**: `flutter_tts` làm mặc định; để ngỏ nâng cấp Google Cloud TTS cho tính năng "nghe giọng bản địa" nếu người dùng phản hồi cần chất lượng cao hơn.

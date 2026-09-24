# GymTalk – Giai đoạn 3: Rảnh tay, giọng HLV, PT AI, thiết lập chung

Tiếp nối [Giai đoạn 1](gymtalk-phase1.md) và [Giai đoạn 2](gymtalk-phase2.md).

## Tính năng
| Tính năng | Mô tả | File chính |
|---|---|---|
| **Luyện nói rảnh tay** | Máy đọc câu tiếng Anh → người dùng nhắc lại → chấm điểm (`scorePronunciation`) → khen hoặc cho nghe lại 1 lần → câu tiếp. Không cần nhìn màn hình, hợp khi chạy bộ/đạp xe. Nội dung: thẻ SRS đến hạn trước, rồi câu ví dụ của từ vựng gym. Mỗi lần chấm được ghi vào thống kê phát âm (nguồn `hands_free`) và vòng "Nói". Giữ màn hình sáng; mở với route `kPronunciationRouteName` để nút AI Voice Chat biết mic đang bận. | `features/speaking/` |
| **Giọng HLV tiếng Anh** | Trong buổi tập, máy đọc câu nhắc ngắn khi bắt đầu nghỉ ("Nice set! Rest for 60 seconds.") và khi hết giờ nghỉ ("Rest is over. Next: Bench Press, set 2 of 4."). Bật/tắt trong bảng chọn thời gian nghỉ (mặc định bật). | `workout_session_screen.dart`, `workout_prefs.dart` |
| **PT AI** | AI Voice Chat thêm tình huống nhập vai huấn luyện viên "Alex": hỏi cách dùng máy, đặt lịch PT, kể chấn thương nhẹ, sets/reps… vẫn giữ cơ chế "Correction: …". Mở từ màn Hôm nay. | `ai_voice_chat/data/voice_chat_scenario.dart` |
| **Thiết lập GymTalk** | Khi chưa theo giáo án: 4 câu hỏi (mục tiêu, trình độ, số buổi/tuần, nơi tập) → gợi ý giáo án (`recommendProgram`, có test) → "Theo giáo án này" đặt làm giáo án đang theo. Có lối sang khảo sát trình độ tiếng Anh sẵn có. | `features/today/data/program_recommendation.dart`, `gymtalk_setup_sheet.dart` |

## Giới hạn đã biết
- PT AI chỉ áp dụng cho kết nối Gemini trực tiếp (`kUseDirectGeminiConnection = true`, như hiện tại); backend proxy chưa nhận hướng dẫn từ máy khách.
- Luyện nói rảnh tay cần màn hình bật (nhận diện giọng nói của Android không chạy khi tắt màn hình) – app giữ màn hình sáng trong lúc luyện.
- Giọng HLV dùng TTS chung của app nên sẽ "duck" nhạc đang phát trong lúc đọc.

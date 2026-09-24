# GymTalk – Giai đoạn 1: Tập gym + học tiếng Anh trong cùng một buổi tập

Mục tiêu: biến màn **đang tập** thành nơi vừa tập vừa học, đồng thời sửa các lỗi khiến buổi tập bị kẹt/mất dữ liệu.

## Tính năng
| Tính năng | File chính |
|---|---|
| **Học khi nghỉ**: thẻ từ vựng gym (nghe phát âm, chạm xem nghĩa + ví dụ, "Chưa nhớ/Đã nhớ") hiện trong lúc đếm ngược nghỉ. Bật/tắt được, lưu trên máy. TTS **chỉ phát khi người dùng bấm** để không giành audio focus với nhạc đang nghe. | `fitness/presentation/rest_vocab_card.dart` |
| **Bộ từ vựng gym** (68 từ A2–B1: khẩu lệnh HLV, dụng cụ, động từ chuyển động, nhóm cơ) + tên tiếng Anh của chính bài đang tập. Chọn từ theo nhóm cơ của buổi tập, ưu tiên từ chưa thuộc (hộp Leitner 0–4, lưu SharedPreferences). | `fitness/data/gym_vocabulary.dart` |
| **5 từ khởi động** ở màn xem trước buổi tập. | `fitness/presentation/warmup_words_card.dart` |
| **Màn đang tập làm lại cho phòng gym**: nút ±/Hoàn thành 56–60dp cố định ở đáy, số to, ảnh động tác, thanh tiến độ + đồng hồ, vòng đếm ngược nghỉ, rung 3-2-1 và khi hết giờ, giữ màn hình sáng, chọn thời gian nghỉ 30–120s, hoàn tác set vừa ghi, giữ mức tạ vừa dùng cho set sau, nghỉ cả khi chuyển bài. | `fitness/presentation/workout_session_screen.dart` |
| **Thoát an toàn**: hỏi "Lưu & kết thúc / Bỏ buổi tập / Tập tiếp". Kết thúc sớm vẫn lưu nhưng **không** tick hoàn thành trong Lập kế hoạch. | như trên + `workout_finished_screen.dart` |

## Sửa lỗi
- `auth.currentUser!` crash khi chưa đăng nhập → hiện màn yêu cầu đăng nhập.
- Mất mạng giữa buổi làm màn hình kẹt (`await` insert Supabase) → **WorkoutOutbox**: hàng đợi lệnh lưu trên máy (SharedPreferences), gửi theo đúng thứ tự `start → set/unset → finish`, tự thử lại (5s → 60s), gửi tiếp khi mở lại Fitness nếu app bị tắt giữa buổi. Màn tổng kết hiện trạng thái lưu + nút Thử lại.
- Đếm ngược nghỉ trôi sai khi app vào nền → tính theo mốc thời gian kết thúc.
- Chạm đúp "Hoàn thành set" ghi 2 set → chặn trong 700ms.

## Việc cần làm khi triển khai
- Chạy migration `supabase/migrations/0072_workout_set_logs_delete_own.sql` (policy xoá set của chính mình – cho nút Hoàn tác).
- Không thêm package mới. Giữ màn hình sáng dùng kênh `app/keep_screen_on` trong `MainActivity.kt` (iOS: bỏ qua, chưa hỗ trợ).

## Giới hạn đã biết
- Nếu insert thành công nhưng mất phản hồi, lần thử lại có thể tạo bản ghi trùng (cần cột id phía client + unique để triệt để – để giai đoạn sau).
- Leitner chưa có lịch ôn theo ngày – SRS thật ở Giai đoạn 2.
- Luyện nói (STT chấm điểm) khi nghỉ để Giai đoạn 3 (chế độ rảnh tay).

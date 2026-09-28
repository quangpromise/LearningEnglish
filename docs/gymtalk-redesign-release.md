# GymTalk redesign — ghi chú phát hành

Spec: #70 · Ticket UI-01…UI-11 (#71–#81) · Thiết kế: `docs/design/gymtalk-redesign/` · ADR 0004–0006.

Từ bản này giao diện mới là giao diện duy nhất (cờ `kUseRedesign` đã bỏ, màn cũ đã xoá). Giao diện sáng vẫn khoá (`kEnableLightTheme = false`).

## Người dùng thấy gì

- **Nghe nhạc học tiếng Anh:** mini player luôn có lối vào — chưa phát bài nào thì chạm để bắt đầu (lời song ngữ, chạm từ tra nghĩa); tab Học có ô **Học qua bài hát**.
- **Khung app mới:** thanh trên có avatar với vòng tiến độ hôm nay + huy hiệu GymTalk Rank, chuỗi ngày, tin nhắn; thanh tab kính mờ 4 tab + nút **Quick Start** ở giữa (vào buổi tập hôm nay, hoặc ôn thẻ nếu đã tập / ngày nghỉ / chưa có giáo án); mini player nổi (tắt/bật ở Tiến độ → Cài đặt).
- **Hôm nay:** 3 vòng Tập/Học/Nói, dải chuỗi 7 ngày, thẻ buổi tập theo trạng thái, **4 nhiệm vụ hằng ngày** tự đánh dấu (ôn thẻ, phát âm, rảnh tay, PT AI) + **rương** khi đủ 4/4; toast XP và màn chúc mừng chỉ hiện XP thật.
- **Tập:** Body Level + còn thiếu bao nhiêu buổi/tuần để lên bậc, 4 chỉ số tuần (không bịa số), buổi hôm nay, giáo án, lối tắt tiện ích.
- **Học:** English Level + tiến độ Unit tới Level Test, từ vựng hằng ngày, 4 kỹ năng, luyện nói 4 chế độ, TOEIC/IELTS/Đố vui.
- **Tiến độ:** GymTalk Rank (không có hạng "Kim cương"), Body/English Level, biểu đồ phút học + phút tập 7 ngày, bạn bè tuần này, cài đặt nhắc nhở và mini player.
- **Ôn thẻ:** thẻ lật, 3 mức **Quên / Khó / Nhớ** hiện khoảng ôn thật; thẻ quên gặp lại 1 lần trong phiên.
- **Buổi tập:** header ảnh + tiến độ các bài, bảng hiệp tick 44dp, "Học trong lúc nghỉ" dùng Rest Game, chúc mừng với XP đã được cộng thật.
- **Onboarding 3 bước** cho tài khoản mới: mục tiêu → số phút/ngày → giáo án gợi ý. Người đã xem giới thiệu cũ không bị hỏi lại; không ghi đè giáo án/persona đã có. Không có Paywall (ADR-0006).

## Cần làm phía server

Chạy trên Supabase (SQL Editor), theo thứ tự, nếu chưa chạy:

1. `supabase/migrations/0075_gymtalk_english_path_sync.sql` — đồng bộ lộ trình tiếng Anh.
2. `supabase/migrations/0076_learning_xp_reward_keys.sql` — `claim_learning_xp`: thưởng nhiệm vụ/rương cộng đúng 1 lần theo khoá ngày trên mọi máy. Chưa chạy thì app tự dùng `add_learning_xp` cũ (tối đa 1 lần trên mỗi máy).

## Đã xoá

Màn Hôm nay / Tiến độ / Trang chủ Fitness / Home tiếng Anh cũ, `FitnessShell`, carousel giới thiệu, thanh tab cũ, `HomeDesignBackground`, `PointingHandBadge`, golden `fitness_home.png` (thay bằng widget test chống tràn ở 390×787 cho từng tab mới).

## Biết trước / để sau

- Bỏ phần tô sáng thẻ theo persona của Home tiếng Anh cũ (persona vẫn dùng cho cấp độ và lộ trình; khảo sát mở ở cuối tab Học).
- Còn ~80 chuỗi i18n chỉ màn cũ dùng và vài widget/tiện ích mồ côi (`mini_app_bottom_nav.dart`, `FitnessPressable`) — dọn ở lượt sau, không ảnh hưởng chạy.

- Vài widget cũ còn dùng bên trong màn mới (stepper, vòng nghỉ và Rest Game ở buổi tập, thẻ bạn bè và nhắc nhở ở Tiến độ) vẫn theo style tối cũ — ổn vì chưa mở giao diện sáng.
- Chưa có badges và giải đấu thăng/giáng hạng (chưa có mô hình dữ liệu, spec #70).
- Chưa chạy thử trên thiết bị thật trước khi bật — nên cài APK kiểm tra các luồng chính trước khi phát hành.

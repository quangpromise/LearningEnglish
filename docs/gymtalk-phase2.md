# GymTalk – Giai đoạn 2: Tab gốc, Hôm nay, Tiến độ, SRS, XP chung

Tiếp nối [Giai đoạn 1](gymtalk-phase1.md). Mục tiêu: biến app từ "3 app con" thành **một app GymTalk** với vòng lặp mỗi ngày *tập + học*.

## Điều hướng
- `RootShell` thành **4 tab** (`core/navigation/root_tabs.dart`): **Hôm nay · Tập · Học · Tiến độ**. Thanh nhạc nằm trên thanh tab, đổi màu theo tab.
  - *Tập* = `FitnessHomeScreen`, *Học* = `HomeScreen` tiếng Anh (trước đây Fitness là app con push bằng `FitnessShell`).
  - Hồ sơ vẫn mở từ avatar trên `AppTopBar` (ProfileScreen thiết kế dạng popup).
  - **Wealth** vẫn là app riêng (`WealthShell`) mở từ nút chuyển app.
- `rootTabProvider` là nguồn chọn tab; `currentAppSectionProvider` (theme, nền, mặc định Lập kế hoạch…) được đồng bộ theo tab (Tập → fitness, còn lại → learnEnglish) và tự khôi phục khi đóng Wealth.
- Thời gian dùng Fitness (nguồn `'fitness'`) giờ được ghi khi rời tab Tập / app xuống nền (thay cho `FitnessShell.dispose`). Hàng đợi buổi tập (outbox) được gửi lại ngay khi mở app.
- `AppSwitcherPill`: chọn Fitness/Học tiếng Anh → đổi tab; khôi phục khu vực sau đăng nhập → chọn tab Tập.

## Màn Hôm nay (`features/today/presentation/today_screen.dart`)
- **3 vòng mục tiêu**: Tập (≥1 buổi hoặc ngày nghỉ theo giáo án), Học (≥10 lượt ôn từ), Nói (≥5 lượt phát âm được chấm).
- **Chuỗi Body + Brain**: ngày đạt vòng Học **và** vòng Tập (hoặc ngày nghỉ).
- **Nút hành động chính** đổi theo lịch: bắt đầu buổi tập hôm nay / đã tập xong / ngày nghỉ → ôn từ / chưa có giáo án → chọn giáo án.
- Thẻ **Ôn tập từ vựng** (số thẻ đến hạn) và **Luyện nói**.
- Số liệu vòng lưu trên máy: `features/today/data/daily_progress_store.dart` (60 ngày), được cộng từ: kết thúc buổi tập, thẻ "Học khi nghỉ", ôn SRS, "Từ mới mỗi ngày" (markLearned), mọi lần chấm phát âm (`StatsRepository.recordPronunciationScore`).

## SRS thật (`features/srs/`)
- Thay hộp Leitner của Giai đoạn 1 bằng **thẻ SRS có lịch theo ngày**: hộp 0–5, khoảng ôn `[0, 1, 3, 7, 16, 35]` ngày; nhớ → lên hộp, quên → về hộp 0.
- Bộ thẻ gồm **từ vựng gym** (thẻ Học khi nghỉ) + **từ học qua Từ mới mỗi ngày** (lưu kèm nội dung vì danh sách hằng ngày hết hạn lúc nửa đêm).
- Màn **Ôn tập** (`srs_review_screen.dart`): tối đa 20 thẻ/lượt, nghe phát âm khi bấm, Hiện nghĩa → Quên/Nhớ.

## GymTalk XP chung – migration `0073_gymtalk_unified_xp.sql`
Định nghĩa lại `learning_xp_from_activity`: giữ công thức 0064 **+ 25 XP / buổi tập hoàn thành + XP Quiz / 5**. Thời gian ở tab Tập đã được tính 1 XP/phút qua `user_practice_time`, nên thưởng buổi tập để vừa phải. Sửa luôn lỗi tiềm ẩn: user chưa có dòng `user_practice_time` làm tổng XP thành NULL. Bảng xếp hạng Quiz giữ nguyên.

## Màn Tiến độ (`progress_screen.dart`)
Cấp độ + thanh XP, chuỗi Body + Brain với lịch sử 7 ngày (3 chấm màu/ngày), số liệu tập tuần này (+ mở Thống kê tập), số liệu học (từ đã học, thẻ đã thuộc, điểm phát âm TB).

## Việc cần làm khi triển khai
- Chạy migration `0073_gymtalk_unified_xp.sql` (sau `0072` của Giai đoạn 1). Cấp độ của người dùng sẽ tăng theo số buổi tập/XP Quiz đã có.

## Giới hạn đã biết
- Số liệu vòng/SRS lưu theo **máy**, chưa tách theo tài khoản (đổi tài khoản trên cùng máy sẽ thấy số liệu cũ).
- Ngày tính theo giờ máy (Từ mới mỗi ngày dùng giờ VN) – lệch nhau nếu máy không ở múi giờ VN.
- Màn Học và Tập vốn thiết kế cố định chiều cao; thêm thanh tab làm nội dung co lại một chút – cần kiểm tra trên máy màn thấp.

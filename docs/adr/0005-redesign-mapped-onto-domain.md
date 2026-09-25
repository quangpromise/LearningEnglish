# Bản redesign được ánh xạ vào domain đã chốt: không có "cấp XP", XP thưởng đi qua RPC bonus

Handoff có dùng số mẫu kiểu "Cấp 8 · 2.480 XP", "Kim cương III", "Cấp cơ thể 14", "Còn 420 XP tới B2". Các số này mâu thuẫn với spec #45 (XP chỉ là điểm tích lũy, không còn khái niệm cấp XP) và ADR-0002 (Body Level và English Level là hai thang độc lập). Vì vậy giữ nguyên domain và chỉ lấy phần trình bày của design:

- **Thẻ hạng** hiển thị **GymTalk Rank** (5 bậc, ghép Rookie↔A1 … Beast↔C1). Không có "Kim cương".
- **Avatar ring** hiển thị % hoàn thành 3 vòng hôm nay. Huy hiệu góc avatar là bậc GymTalk Rank.
- **"Cấp cơ thể"** hiển thị Body Level kèm mục tiêu kế tiếp (số buổi và số tuần). **"Cấp tiếng Anh"** hiển thị English Level kèm tiến độ Unit tới Level Test.
- **XP thưởng** (nhiệm vụ, rương) được cộng qua RPC `add_learning_xp` hiện có. Mỗi phần thưởng có khóa theo ngày để không cộng trùng. Số XP hiển thị luôn là số thật; con số mẫu trong design không được dùng.
- **League:** chỉ là bảng bạn bè trong tuần (RPC `friends_body_brain_week`), không có hạng thăng/giáng.

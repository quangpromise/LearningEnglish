# Nghiên cứu UX: Tính năng "Lập kế hoạch" (Plan Work) dùng chung 3 mini-app

Mục tiêu: xác định pattern UX an toàn để tham khảo cho màn hình timeline theo giờ +
date-strip + trạng thái công việc bằng màu + menu nổi kiểu AssistiveTouch, dùng
chung cho Học tiếng Anh / Fitness / Quản lý tài sản. Ảnh tham khảo bố cục:
`PlanWork.jpg` (UI kit "My Tasks") — chỉ dùng để hiểu cấu trúc, KHÔNG copy màu/icon/avatar.

## 1. Xử lý chồng lấn giờ trong timeline

| App | Cách xử lý overlap | Nhận xét |
|---|---|---|
| Google Calendar | Thuật toán "interval partitioning": sort theo giờ bắt đầu, gom nhóm sự kiện chồng nhau, chia cột (columns) có độ rộng bằng nhau, số cột = số sự kiện chồng lấn tối đa tại 1 thời điểm | Pattern chuẩn công nghiệp, rõ ràng, không mất thông tin nhưng card sẽ hẹp lại khi có >2-3 việc trùng giờ |
| Todoist (time blocking) | Sự kiện lịch đồng bộ hiển thị dạng block màu để "tránh" chồng nhau khi người dùng tự kéo-thả sắp lịch — không có màn hình chuyên xử lý overlap tự động phức tạp | Đơn giản, phù hợp app ít việc trùng giờ |
| TickTick | Week View có 2 layout: "timeline" (cột giờ dọc) và "grid" (lưới ô) — người dùng tự chuyển đổi qua nút ở đầu trang | Cho người dùng chọn cách nhìn phù hợp thay vì ép 1 kiểu |
| Structured | Người dùng phản hồi (feedback board chính thức của họ) muốn có cách "ẩn bớt" các task chồng lấn không quan trọng (vd task cá nhân đè lên task công việc) — cho thấy xử lý overlap thuần bằng thu nhỏ cột chưa đủ, cần thêm lựa chọn ẩn/gộp theo mức ưu tiên | Bài học: overlap không chỉ là vấn đề layout mà còn là vấn đề ưu tiên hiển thị |
| Asana Timeline | Có yêu cầu tính năng "stack nhiều task trên 1 dòng" — chưa hỗ trợ mặc định, task chồng nhau bị đẩy xuống dòng riêng (tăng chiều cao) | Cách "đẩy xuống dòng riêng" đơn giản để code nhưng làm timeline dài ra nhanh khi nhiều task/ngày |

**Kết luận áp dụng cho app này:** vì đây là 1 tính năng DÙNG CHUNG cho 3 mini-app hoàn toàn khác domain (bài học tiếng Anh, buổi tập gym, nhắc nhở tài chính), khả năng cao người dùng có việc chồng giờ giữa 2-3 loại khác nhau trong cùng 1 ngày. Đề xuất:
- Áp dụng thuật toán chia cột kiểu Google Calendar khi có ≤3 việc chồng nhau (card thu hẹp bề ngang, vẫn đọc được tiêu đề + màu trạng thái).
- Khi >3 việc chồng nhau tại cùng khung giờ: gộp thành 1 "chip tổng hợp" dạng "+2 việc khác" (giống cách calendar mobile thu gọn ngày quá bận) — bấm vào mở rộng dạng list nhỏ, tránh card bị bóp quá hẹp không đọc được.
- KHÔNG cần build engine xử lý overlap phức tạp cho web (nhiều người/nhiều calendar) — vì đây là kế hoạch cá nhân 1 người dùng, độ phức tạp thấp hơn Google Calendar multi-calendar nhiều.

## 2. Date-strip (dải ngày ngang) và calendar-grid (lưới tháng)

| App | Cách phối hợp 2 chế độ |
|---|---|
| Fantastical | "DayTicker" — dải ngang hiển thị vệt chấm/gạch màu theo độ bận của mỗi ngày, kết hợp cùng lúc với calendar grid ở trên (split-screen: grid nhỏ overview + timeline chi tiết bên dưới) hiển thị đồng thời, không cần chuyển màn hình |
| TickTick | Week view có nút chuyển "timeline ↔ grid" ở đầu trang; Month view hỗ trợ pinch-to-zoom để thu gọn số tuần hiển thị; Multi-week view (chọn số tuần muốn xem) chỉ có trên desktop | Cho thấy pattern "date-strip thu gọn là mặc định, calendar-grid đầy đủ là chế độ mở rộng theo yêu cầu" khá phổ biến |
| PlanWork.jpg (ảnh tham khảo) | Header "January 2023 ⌄" (bấm mở rộng thành lưới tháng) + date-strip 5 ngày ngay bên dưới, ngày chọn nổi bật bằng hình viên thuốc (pill) màu sáng | Đúng pattern phổ biến: date-strip là mặc định, lưới tháng là overlay/dropdown khi cần nhảy xa ngày |

**Kết luận áp dụng:** dùng đúng pattern phổ biến — date-strip 5-7 ngày là chế độ mặc định (vuốt ngang để đổi tuần), tiêu đề tháng/năm ở trên cùng có mũi tên bấm mở ra calendar-grid dạng lưới tháng đầy đủ (dùng khi cần nhảy xa, ví dụ xem lịch tháng sau). Đây là pattern AN TOÀN, không đặc thù thương hiệu riêng của app nào — nhiều app lớn đều dùng chung mô hình "compact strip mặc định + grid mở rộng theo yêu cầu".

## 3. Ánh xạ trạng thái công việc → màu sắc

| App | Cách làm |
|---|---|
| Motion | Có đúng 4 trạng thái cố định (Backlog, Not Started, Auto-Scheduled, Completed), người dùng KHÔNG được đổi màu — chỉ đổi tên nhãn | Giữ nhất quán toàn hệ thống, tránh người dùng tự làm rối bằng màu tùy ý |
| Sunsama | Cho phép tùy biến màu theo "channel"/dự án tự do | Linh hoạt nhưng dễ gây rối nếu không có gợi ý ban đầu hợp lý |
| Notion Calendar | Khuyến nghị rõ trong tài liệu: "gán và giữ nguyên 1 hệ màu cố định, ví dụ đỏ = khẩn cấp, xanh lá = hoàn thành, xanh dương = thông tin" — tránh đổi màu tùy tiện giữa các mục | Nguyên tắc UX cốt lõi: số lượng màu trạng thái nên giới hạn (3-5 màu), mỗi màu gắn 1 ý nghĩa DUY NHẤT xuyên suốt app |
| PlanWork.jpg | 4 trạng thái mẫu: Completed (xanh lá nhạt), Rejected (xanh dương/cyan), Running (tím nhạt), Upcoming (xanh lá) — card TOÀN BỘ nền đổi màu theo trạng thái (không chỉ viền/nhãn nhỏ) | Cách "toàn bộ nền card đổi màu" giúp quét nhanh bằng mắt khi cuộn timeline dài, nhưng với 4 mini-app khác domain, cần né trùng màu thương hiệu của từng mini-app (Fitness/Wealth/English đã có accent gradient riêng theo `app_theme.dart`) |

**Kết luận áp dụng:** giống Motion hơn Sunsama — **cố định** đúng 4 màu cho 4 trạng thái (Hoàn thành/Đang chạy/Từ chối/Sắp tới), KHÔNG cho người dùng tùy biến màu trạng thái (tránh rối khi dùng chung 3 mini-app có accent màu riêng theo section). Nên chọn 4 màu trạng thái **tách biệt hẳn** khỏi 3 accent gradient hiện có của English/Fitness/Wealth (xem `AppColors.accentGradient`, `AppColors.fitnessAccent`, `AppColors.wealthAccent` trong `app/lib/core/theme/app_theme.dart`) để không gây nhầm "màu trạng thái" với "màu section đang mở". Không tô toàn bộ nền card đậm như ảnh mẫu (dễ trùng cảm giác thị giác với 3 màu section) — có thể dùng dải màu bên trái card (accent bar) + nhãn text màu, nhạt nền hơn ảnh gốc.

## 4. Pattern menu nổi kiểu AssistiveTouch / radial menu

| Nguồn | Đặc điểm chính |
|---|---|
| AssistiveTouch (iOS) | Nút tròn nổi, kéo được tới mọi cạnh màn hình để tránh che nội dung; tap để mở menu cấp cao nhất chứa các icon shortcut cố định; có "Idle Opacity" tự mờ đi khi không dùng tới |
| Path app (nguồn gốc pattern "circular floating action menu" trên Android, nhiều thư viện open-source mô phỏng lại: CircularFloatingActionMenu, react-native-circular-action-menu) | Bấm nút trung tâm → các mục con animate "nở ra" theo vòng cung quanh nút chính (không phải full circle 360°, thường chỉ 90-180° để không che phần màn hình đối diện) |
| Nguyên tắc thiết kế radial menu (tổng hợp từ nhiều nguồn UX) | Giới hạn 4-6-8 lựa chọn (nhiều hơn sẽ như "bảng phi tiêu", mất lợi thế tốc độ); luôn có icon + nhãn ngắn ngoài vòng; dùng hiệu ứng scale/fade nhẹ khi mở; kích hoạt bằng nút nổi cố định (không dùng long-press ẩn, để người dùng luôn biết menu tồn tại) |

**Kết luận áp dụng — vấn đề va chạm với FAB AI Voice Chat đã có sẵn:**
- App đã có `AiFabOverlay` (xem `app/lib/core/navigation/ai_fab_overlay.dart`) — 1 FAB tròn 58px, kéo-thả tự do, chỉ hiện ở 3 màn Home chính, tap nhanh mở AI Voice Chat, giữ-kéo di chuyển vị trí (không lưu qua phiên). Nút "Lập kế hoạch" mới PHẢI dùng cùng cơ chế phân biệt tap/drag (ngưỡng khoảng cách di chuyển, không dùng long-press) để nhất quán trải nghiệm và tránh 2 loại logic kéo-thả khác nhau trong cùng app.
- Để 2 FAB không đè lên nhau: vị trí mặc định nên đặt SO LE nhau (vd AI Voice Chat ở góc dưới-phải, Lập kế hoạch ở cạnh phải-giữa màn hình như yêu cầu ban đầu — đã tách biệt theo trục dọc). Khi 1 trong 2 nút được kéo lại gần nút kia (khoảng cách < đường kính 1 nút), nên có hiệu ứng đẩy nhẹ (nudge) nút kia ra xa hoặc chỉ đơn giản cho phép chồng lên nhau tạm thời (ưu tiên đơn giản, không cần physics phức tạp) — đây là **chi tiết kỹ thuật cần bàn thêm với planner-ui-designer/lập trình viên**, không phải kết luận UX cuối cùng.
- Khi bung menu tròn (radial), giới hạn 4-5 mục lối tắt (vd: Thêm việc mới, Xem hôm nay, Xem tuần, Lọc theo mini-app...) theo đúng khuyến nghị 4-6-8 lựa chọn ở trên — không nhồi quá nhiều để tránh như "bảng phi tiêu".
- Vòng cung nên mở về phía có nhiều khoảng trống màn hình (nếu nút đang ở cạnh phải-giữa, mở vòng cung sang trái, không mở tràn ra ngoài mép phải màn hình) — giống cách AssistiveTouch tự đổi hướng menu khi nút áp sát cạnh màn hình.

## 5. Pattern chung (AN TOÀN để bàn giao cho `planner-ui-designer`) vs. chi tiết đặc thù (KHÔNG nên copy)

**Pattern chung — an toàn tham khảo:**
- Date-strip ngang (5-7 ngày) làm mặc định + calendar-grid dạng lưới tháng mở rộng khi bấm vào tiêu đề tháng/năm.
- Timeline dọc theo giờ, cột giờ bên trái, card task chiếm đúng khoảng thời gian theo chiều cao tương ứng.
- Chia cột khi có việc chồng giờ (≤3 việc), gộp thành chip "+N việc khác" khi vượt ngưỡng.
- Cố định 1 bảng màu nhỏ (3-5 màu) ánh xạ 1-1 với trạng thái, không cho tùy biến, dùng xuyên suốt toàn app.
- FAB tròn nổi có thể kéo-thả tự do, tap nhanh mở tính năng / giữ-kéo di chuyển vị trí, tự ẩn ở màn hình không liên quan (theo route hiện tại).
- Radial menu giới hạn 4-6-8 mục, mở theo vòng cung hướng về khoảng trống màn hình, có icon + nhãn ngắn.

**Chi tiết đặc thù/thương hiệu riêng — KHÔNG nên sao chép nguyên văn:**
- Bảng màu cụ thể + shape "viên kim cương" cho icon card trong `PlanWork.jpg` (thuộc về UI kit gốc, có thể vướng bản quyền UI kit).
- Ảnh đại diện (avatar) người dùng mẫu trong `PlanWork.jpg`.
- Cách đặt tên nhãn trạng thái tiếng Anh cụ thể của từng app (vd 4 trạng thái cố định của Motion) — app này nên tự đặt nhãn tiếng Việt (Hoàn thành/Đang chạy/Từ chối/Sắp tới) theo đúng yêu cầu gốc, không cần khớp y hệt tên tiếng Anh của app khảo sát.
- "DayTicker" của Fantastical (chấm/gạch màu mini biểu diễn độ bận) là tính năng đặc trưng có thể liên quan tới bằng sáng chế UI riêng của Flexibits — nên tránh bắt chước hình dạng chính xác, chỉ lấy Ý TƯỞNG chung "biểu diễn độ bận trên date-strip bằng dấu hiệu nhỏ" nếu muốn làm.

## 6. Ghi chú kỹ thuật cần chuyển tiếp

- Cần package Flutter để vẽ timeline theo giờ có card định vị theo thời gian + chia cột khi overlap (ví dụ nhóm package `syncfusion_flutter_calendar`, `flutter_calendar_timeline`, hoặc tự vẽ bằng `CustomMultiChildLayout`) — **nên gọi `library-researcher` riêng** để so sánh license (đặc biệt Syncfusion có phiên bản free có giới hạn doanh thu công ty, cần kiểm tra kỹ điều khoản thương mại) trước khi chọn.
- Không phát hiện yêu cầu thư viện đặc biệt nào khác ngoài phần vẽ timeline/calendar.

### Kết quả `library-researcher` — chọn `kalender` (MIT)

| Ứng viên | License | Điều kiện thương mại | Drag-to-reschedule | Chia cột overlap | Trưởng thành |
|---|---|---|---|---|---|
| **kalender** (chọn) | MIT | Tự do dùng thương mại, không giới hạn | Có (drag/resize/zoom, touch+mouse) | Có (built-in) | Bản 0.29.x (chưa 1.0, publisher xác thực KDAB, ~59k lượt tải) |
| syncfusion_flutter_calendar | Proprietary + "Community License" miễn phí | Đủ điều kiện HIỆN TẠI (dev đơn lẻ, doanh thu &lt;$1M, ≤5 dev, ≤10 nhân viên, chưa nhận &gt;$3M vốn ngoài) nhưng MẤT quyền miễn phí ngay khi vượt bất kỳ ngưỡng nào (kể cả thêm 1 nhân viên) | Có | Có | Rất trưởng thành nhưng đóng source |
| calendar_view | MIT | Tự do | Không có tài liệu hỗ trợ | Không rõ | Ổn định (2.0.0) nhưng thiếu tính năng kéo-thả cần |
| Tự vẽ `CustomMultiChildLayout` | — | Tự do hoàn toàn | Tự code | Tự code | Kiểm soát tối đa, tốn công phát triển/bảo trì |

**Lý do chọn `kalender` thay vì Syncfusion** (dù hiện đủ điều kiện Community License miễn phí): điều kiện Syncfusion ràng buộc theo doanh thu/số nhân viên — dễ mất tư cách miễn phí khi dự án phát triển hoặc có thêm cộng tác viên, phải trả phí hoặc gỡ bỏ giữa chừng. `kalender` là MIT, mã nguồn mở, không ràng buộc quy mô, đáp ứng đủ 4 yêu cầu (timeline theo giờ, chia cột overlap, drag-to-reschedule, date-strip tự ghép riêng vì package chỉ lo phần lịch/timeline).

**Rủi ro cần lưu ý**: package chưa ra bản 1.0, có thể breaking change khi nâng cấp minor version — **pin version cụ thể** trong `pubspec.yaml` và test kỹ trước khi bump.

Nguồn: [kalender trên pub.dev](https://pub.dev/packages/kalender), [kalender GitHub](https://github.com/werner-scholtz/kalender), [calendar_view](https://pub.dev/packages/calendar_view), [Syncfusion Community License](https://www.syncfusion.com/products/communitylicense).

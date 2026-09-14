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

## 7. Gap analysis: planner hiện tại vs các app đối thủ (2026-09)

Mục tiêu: so sánh TÍNH NĂNG (không chỉ bố cục) của planner đang có trong `app/lib/features/planner/` với Todoist, TickTick, Google Calendar, Structured, Sunsama, Notion Calendar, Fantastical, Apple Reminders/Calendar, Motion, Tiimo — tìm tính năng còn thiếu, xếp ưu tiên theo kiến trúc hiện tại (local-only, model phẳng), và gợi ý cách gắn với 3 mini-app.

### 7.1. Hiện trạng đã xác minh trong code (2026-09-14)

Đọc trực tiếp `planner_models.dart`, `planner_repository.dart`, `planner_providers.dart`, `planner_screen.dart`, `planner_timeline.dart`, `planner_task_sheet.dart`, `planner_notification_service.dart`, `core/navigation/assistive_fab_overlay.dart`:

| Hạng mục | Thực tế trong code | Ghi chú lệch so với mô tả ban đầu |
|---|---|---|
| Model | `PlannerTask{id, title, appSection, start, end, status, reminderEnabled, icon}` — `fromJson` đã có fallback cho `reminderEnabled`/`icon` (tiền lệ tốt cho tương thích ngược) | — |
| Lưu trữ | 1 key SharedPreferences `planner_tasks_v1` (cả danh sách JSON), ghi lại toàn bộ mỗi lần sửa | Chưa Supabase |
| Timeline | 24 hàng giờ cao tối thiểu 68px, gom việc theo `start.hour`; ≤3 việc chia hàng ngang, >3 thì "+N" xổ tại chỗ | Card KHÔNG kéo dài theo thời lượng; `kalender` (đã chọn ở §6) CHƯA được thêm vào `pubspec.yaml` |
| Kéo-thả | `LongPressDraggable` → thả vào hàng giờ → `reschedule(id, hourStart)` | Luôn làm tròn về HH:00 (mất phút); không resize; không sang ngày khác |
| Form thêm/sửa | Tiêu đề, mini-app, icon, giờ bắt đầu/kết thúc, trạng thái, bật nhắc | Không có ô chọn NGÀY; nếu giờ kết thúc ≤ giờ bắt đầu thì bị ép thành +30 phút → không tạo được việc qua nửa đêm (vd "Ngủ" 23:00-06:30) dù có sẵn icon `sleep` |
| Xoá | Xoá ngay trong sheet sửa | Không xác nhận, không hoàn tác |
| Nhắc nhở | Chỉ `AndroidNotificationDetails`; không có payload → bấm thông báo không mở đúng việc; lệch giờ nhắc là cài đặt TOÀN CỤC | Trên bản web (người dùng test chính trên iPhone), plugin thông báo cục bộ không lập lịch được — lỗi bị nuốt trong `try/catch`, người dùng không được báo |
| Menu nổi | `AssistiveFabOverlay` có 5 mục: Về Home, Lập kế hoạch, AI Voice Chat, Máy tính, Dịch | **Không có** lối tắt "Hôm nay"/"Lọc mini-app". `plannerSectionFilterProvider` tồn tại nhưng không có UI nào ghi vào → tính năng lọc hiện là "code chết" |
| Tích hợp mini-app | Không file nào ngoài `features/planner/` tạo `PlannerTask` | Chưa có liên kết 2 chiều nào với English/Fitness/Wealth |

### 7.2. Bảng tính năng THIẾU theo chủ đề

Impact: Cao / TB / Thấp. Effort (ước lượng theo kiến trúc hiện tại): S (≤1-2 ngày), M (3-5 ngày), L (>1 tuần hoặc cần native/backend/thư viện mới).

| # | Chủ đề | Tính năng thiếu | App đối thủ làm thế nào | Giá trị cho người dùng | Gắn với 3 mini-app | Impact | Effort |
|---|---|---|---|---|---|---|---|
| A | Hoàn thành nhanh | Checkbox/nút tròn 1 chạm trên card + trạng thái tự suy theo giờ | Todoist/TickTick: vòng tròn tick ngay trên dòng việc; Structured: tick cả từ widget; Motion/Sunsama: việc quá giờ tự chuyển trạng thái | Hiện phải mở sheet → chọn chip trạng thái → Lưu (3 thao tác). "Đang chạy" và "Sắp tới" nhập tay nên sai ngay khi thời gian trôi | Hoàn thành buổi tập ở Fitness hoặc bài học ở English có thể tự đánh dấu việc tương ứng (xem mục K) | Cao | S |
| B | Hoàn tác | Snackbar "Hoàn tác" sau khi xoá/hoàn thành/kéo-thả | Todoist: pop-up Undo vài giây sau khi hoàn thành việc | Chống mất dữ liệu do bấm nhầm, đặc biệt trên màn nhỏ | Chung | Cao | S |
| C | Lặp lại | Việc lặp hằng ngày/tuần (chọn thứ)/tháng, "lặp từ ngày hoàn thành" | Todoist: cú pháp "every"/"every!" (từ ngày gốc hoặc từ ngày hoàn thành); Structured: việc lặp tự hiện mỗi ngày với màu riêng; Google Calendar: task lặp nhưng chưa có thời lượng (01/2026) | Không phải tạo lại lịch tập/lịch học mỗi ngày; đây là tính năng cốt lõi mọi đối thủ đều có | Fitness: `ProgramDay.dayOfWeek` (1-7) ánh xạ thẳng thành lịch lặp tuần; English: "Ôn từ vựng 20:00 mỗi ngày"; Wealth: `RecurringService.cycleType` (tuần/tháng/năm) → nhắc gia hạn | Cao | M |
| D | Inbox | Danh sách việc chưa xếp giờ, kéo vào timeline sau | Structured: Inbox cho việc chưa có ngày; Sunsama: backlog kéo vào ngày; Todoist: việc không ngày | Ghi nhanh ý tưởng mà không bắt chọn giờ ngay — giảm ma sát tạo việc | "Lưu để ôn sau" từ màn từ vựng; "Kiểm tra danh mục cổ phiếu" chưa biết làm lúc nào | Cao | M |
| E | Replan quá hạn | Gom việc hôm trước chưa xong → vuốt: Xong / Dời mai / Về Inbox / Xoá | Structured: "Replan" (từ bản 4.2, vuốt để xử lý); Sunsama: shutdown ritual chuyển việc dang dở sang ngày mai | Hiện việc quá giờ nằm lại "Sắp tới" vĩnh viễn ở ngày cũ; người dùng không biết mình bỏ sót gì | Buổi tập bị lỡ → dời sang ngày nghỉ gần nhất | Cao | S-M (sau D) |
| F | Nhắc theo từng việc | Nhiều mốc nhắc riêng mỗi việc, "khẩn cấp" kiểu báo thức, nút hành động trên thông báo | Apple Reminders iOS 26.2: đánh dấu "Urgent" → iPhone đổ chuông báo thức, iOS 26.4 thêm danh sách "Urgent"; Todoist/TickTick: nhiều reminder mỗi task | Việc quan trọng (đóng tiền) cần nhắc trước 1 ngày, việc thường chỉ cần đúng giờ — cài đặt toàn cục không đáp ứng | Wealth: `RecurringService.reminderLeadDays` (7/15/30) đã có khái niệm nhắc trước N ngày — planner nên hỗ trợ mức "ngày" chứ không chỉ phút | Cao | M |
| G | Liên kết sâu mini-app | Việc mang tham chiếu tới nội dung gốc; nút "Bắt đầu" mở đúng màn | Notion Calendar: mọi database có trường ngày hiện trên lịch, sửa ở lịch cập nhật ngược lại Notion | Đây là lợi thế RIÊNG của app 3-trong-1 mà đối thủ đơn lẻ không có — planner thành "trung tâm điều phối" thay vì 1 tính năng rời | Xem chi tiết §7.4 | Cao | M-L |
| H | Timeline chính xác | Card cao theo thời lượng, vạch "bây giờ", chia cột chồng lấn thật, kéo bước 15 phút, kéo giãn để đổi giờ kết thúc | Google Calendar/TickTick/Structured đều có vạch giờ hiện tại và card theo thời lượng | Hiện việc 09:00-12:00 trông giống hệt việc 09:00-09:15; việc 09:50-11:00 và 10:00-10:30 không hiện là chồng nhau | Buổi tập 90 phút phải thể hiện đúng độ dài | Cao | M (tích hợp `kalender` đã chọn ở §6) |
| I | Chế độ xem | Agenda (danh sách nhiều ngày), tuần, lưới tháng; chấm báo ngày có việc trên date-strip | TickTick: tuần dạng timeline/grid, tháng pinch-zoom; Notion Calendar mobile: 1/2/3 ngày; Google Calendar: chế độ lịch biểu | Chỉ có view ngày → không nhìn được tuần tập gym, không biết ngày nào đang trống | Agenda 7 ngày rất hợp lịch tập theo chương trình | TB-Cao | Agenda S; lưới tháng M; tuần L |
| J | Nhập nhanh | Gõ/nói 1 câu → tự tách ngày, giờ, mini-app | Todoist Quick Add + Ramble (GA 21/01/2026, nói tự nhiên 38 ngôn ngữ → task có ngày/giờ/lặp/ưu tiên); Fantastical NLP; Tiimo AI Co-Planner (nói/gõ → chia nhỏ việc kèm ước lượng thời gian) | Tạo việc trong 1 thao tác | Bộ quy tắc tiếng Việt hẹp: "mai 7h tập ngực", "thứ 6 hằng tuần 20h ôn từ"; giọng nói dùng lại `speech_to_text` đã có trong stack; bản AI có thể đi qua backend Gemini đã có | TB | M (quy tắc); L (AI) |
| K | Mẫu/Routine | Lưu 1 nhóm việc thành mẫu, áp dụng cho 1 ngày | Fantastical: event/task templates (Premium); Structured: routine buổi sáng/tối | Dựng ngày điển hình trong 1 chạm | "Ngày tập Push": khởi động → tập → giãn cơ; "Tối học": nghe nhạc → ôn từ → luyện phát âm | TB | S-M |
| L | Checklist & ghi chú | Subtask có tick, ghi chú tự do | Structured: subtask + notes trên timeline, widget riêng cho subtask; TickTick checklist | Việc lớn chia bước; ghi lý do "Từ chối" | Buổi tập = checklist bài tập (lấy từ `ProgramExerciseRef`); "Ôn 10 từ" = checklist 10 từ | TB | Ghi chú S; checklist M |
| M | Focus/timer | Pomodoro/đồng hồ đếm ngược gắn việc | TickTick: Pomodoro trong task + thống kê; Structured: focus timer + Live Activity; Tiimo: đồng hồ tròn trực quan cho người "mù thời gian" | Biến kế hoạch thành hành động | Fitness đã có màn buổi tập riêng → không nên làm timer thứ 2 cho gym, chỉ nên deep-link; English: phiên học 25 phút | TB | M |
| N | Review/thống kê | Tổng kết ngày/tuần: hoàn thành bao nhiêu, thời gian theo mini-app | Sunsama: shutdown ritual, Daily Highlights, tổng kết tuần theo dự án; TickTick: thống kê hoàn thành; Tiimo: review ngày + mood | Tạo động lực, thấy mất cân bằng giữa học/tập/tài chính | Biểu đồ "giờ dành cho English/Fitness/Wealth tuần này"; nối vào `features/stats`/`features/rewards` đã có thay vì dựng module mới | TB | M |
| O | Thói quen/streak | Chuỗi ngày liên tiếp cho việc lặp | TickTick: habit tracker, streak, check-in từ widget | Duy trì học/tập đều | Chỉ nên tính streak trên việc lặp (phụ thuộc C); tái sử dụng hệ streak/rewards sẵn có của app | TB | M (sau C) |
| P | Ưu tiên/hạn chót | Cờ "Quan trọng" và hạn chót tách khỏi giờ làm | Todoist: 4 mức ưu tiên + Deadlines tách khỏi ngày thực hiện (01/2025); Motion: xếp lịch theo ưu tiên + hạn; Apple: "Urgent" | Phân biệt "định làm lúc nào" với "phải xong trước khi nào" | Wealth: hạn trả nợ (`wealth_debt`) và ngày hết hạn dịch vụ là hạn chót thật; lịch "xem lại danh mục" là giờ làm | TB | S (1 cờ); M (deadline) |
| Q | Việc cả ngày/qua đêm | Việc cả ngày, nhiều ngày, qua nửa đêm | Google/Apple Calendar: all-day ở dải trên cùng | "Ngày nghỉ tập", "Hạn đóng học phí", "Ngủ 23:00-06:30" hiện không nhập được | Rest day của chương trình tập hiện thành việc cả ngày | TB | S-M |
| R | Tìm kiếm & lọc | Ô tìm theo tiêu đề; UI cho bộ lọc mini-app | Todoist filter, TickTick smart list | Provider lọc đã có sẵn, chỉ thiếu UI | Chip lọc English/Fitness/Wealth ngay dưới date-strip | TB | S |
| S | Sửa nhanh cơ bản | Đổi ngày trong form, nhân bản việc, dời sang mai | Mọi đối thủ | Hiện muốn đổi ngày phải xoá rồi tạo lại | Chung | TB | S |
| T | Đồng bộ & sao lưu | Lưu cloud, nhiều thiết bị | Tất cả đối thủ đều sync | Xem rủi ro dữ liệu web ở §7.6 | App đã dùng Supabase cho nhiều repository khác → có hạ tầng sẵn | Cao (với web) | M-L |
| U | Widget/Live Activity | Widget màn hình chính, tick từ widget | Structured: widget timeline 3 kích thước + Live Activity; TickTick: widget Tasks/Thống kê/Thêm việc/Habit | Không cần mở app | Widget "Việc tiếp theo" | TB | L — cần native, không áp dụng cho bản web; **cần library-researcher** |
| V | Lịch ngoài | Xuất/nhập ICS, đồng bộ Google/Apple Calendar | Notion Calendar, Fantastical, TickTick | Thấy lịch học/tập cùng lịch công việc | — | Thấp-TB | Xuất ICS S-M; sync 2 chiều L — **cần library-researcher** |
| W | Tự xếp lịch/AI | AI tự xếp việc vào khoảng trống | Motion: auto-schedule theo ưu tiên/hạn/năng lượng, tự dời khi lịch thay đổi; Structured AI | Mạnh nhưng phức tạp | Không phù hợp giai đoạn này | Thấp | L |
| X | Năng lượng | Gắn mức năng lượng cho việc | Structured: Energy Monitor (Pro) | Có ích với gym nặng/nhẹ, nhưng ngách | — | Thấp | S |
| Y | Chia sẻ | Chia sẻ việc/kế hoạch | TickTick: danh sách chia sẻ; Fantastical: Openings (link đặt lịch) | Hẹn bạn tập chung/học chung | Có thể dùng module `social` sẵn có: gửi thẻ "buổi tập" vào chat | Thấp | L |

### 7.3. Top 5 đề xuất làm tiếp theo

Thứ tự ưu tiên: giá trị/công sức cao nhất trước, và tính năng nền phải làm trước tính năng phụ thuộc vào nó.

#### (1) Hoàn thành 1 chạm + trạng thái tự suy + Hoàn tác — Cao × S
- Card: vòng tròn tick bên trái; chạm → Hoàn thành + snackbar "Đã hoàn thành · Hoàn tác" (4-5 giây). Áp dụng snackbar hoàn tác cho cả xoá và kéo-thả.
- Trạng thái hiển thị = hàm theo thời gian nếu người dùng chưa chốt: `now < start` → Sắp tới; `start ≤ now < end` → Đang chạy; `now ≥ end` và chưa xong → trạng thái mới "Quá hạn" (hoặc tái dùng "Từ chối" với nhãn "Bỏ lỡ" — cần `planner-ui-designer` quyết, lưu ý giữ tối đa 5 màu theo §3).
- Model (ý tưởng): thêm `completedAt: DateTime?`, `skippedAt: DateTime?`. `status` cũ vẫn đọc được: `completed` → `completedAt = end`, `rejected` → `skippedAt = end`, `running`/`upcoming` → bỏ qua (suy theo giờ). Giữ ghi cả `status` trong `toJson` thêm 1-2 phiên bản để APK cũ đọc được file mới (người dùng sideload có thể quay lại bản cũ).

#### (2) Việc lặp lại — Cao × M
- UI: trong form thêm dòng "Lặp lại: Không / Hằng ngày / Các thứ trong tuần [T2..CN] / Hằng tháng" + "Kết thúc: không bao giờ / ngày / sau N lần". Khi sửa 1 lần lặp: hỏi "Chỉ lần này / Lần này và các lần sau / Tất cả".
- Model (ý tưởng): `recurrence: {freq: 'daily'|'weekly'|'monthly', interval: int, byWeekday: [1..7]?, until: date?, count: int?}` — nên là tập con tương thích RRULE (RFC 5545) để sau này xuất ICS không phải đổi schema. Thêm `occurrenceOverrides: {'yyyy-MM-dd': {start?, end?, completedAt?, skipped?, deleted?}}` để lưu trạng thái riêng từng lần. Provider sinh các lần xuất hiện theo ngày đang xem, KHÔNG lưu sẵn từng bản sao (tránh phình JSON trong SharedPreferences).
- Thông báo: chỉ đặt lịch cho N lần sắp tới (vd 7-14 ngày), đặt lại mỗi lần mở app — tránh vượt giới hạn số thông báo chờ của hệ điều hành.
- Tương thích: thiếu `recurrence` → `null` → việc 1 lần như hiện tại.

#### (3) Inbox + Replan việc quá hạn — Cao × M
- Tab/ngăn "Chưa xếp giờ" ở đầu màn; kéo việc từ Inbox thả vào hàng giờ (tái dùng `DragTarget` sẵn có).
- Khi mở planner mà ngày trước có việc chưa xong: banner "3 việc hôm qua chưa xong" → sheet danh sách, vuốt trái/phải: Xong / Dời mai cùng giờ / Về Inbox / Xoá.
- Model (ý tưởng): `start`/`end` chuyển thành nullable (null = đang ở Inbox) + `estimatedMinutes: int?` để khi kéo vào timeline biết độ dài. JSON cũ luôn có `start`/`end` nên đọc được; nhưng đây là thay đổi lan rộng (mọi chỗ dùng `task.start` phải xử lý null) — cân nhắc tách class hoặc thêm getter `isScheduled` để giảm sửa đổi.

#### (4) Liên kết 3 mini-app (nguồn + deep link + tạo tự động) — Cao × M-L
- Model (ý tưởng): `source: {kind: 'fitness_program_day' | 'english_vocab_review' | 'wealth_recurring_service' | 'wealth_debt' | ..., refId: String}` (nullable). Khoá chống trùng = `kind + refId + ngày`.
- Nút "Bắt đầu"/"Mở" trên card → mở đúng màn nguồn (buổi tập, bộ từ ôn, dịch vụ cần gia hạn).
- Tự đánh dấu hoàn thành khi mini-app báo xong (vd kết thúc buổi tập ở `WorkoutFinishedScreen`, hoàn thành lượt ôn từ hôm nay).
- Làm SAU (2) vì phần lớn nguồn là lịch lặp. Chi tiết từng mini-app ở §7.4.

#### (5) Nhắc theo từng việc + thông báo có hành động + xử lý bản web — Cao × M
- Model (ý tưởng): `reminderOffsets: List<int>?` (phút trước giờ bắt đầu; hỗ trợ cả 1440 = 1 ngày). `null` → dùng cài đặt toàn cục như hiện nay; `reminderEnabled == false` → danh sách rỗng. Tuỳ chọn `urgent: bool` (âm báo thức, lấy ý tưởng chung từ Apple Reminders nhưng không dùng tên/giao diện của họ).
- Payload `planner:<taskId>` đi qua dispatcher chung đã có (cách làm giống payload `quiz:` trong `chat_push.dart`) → bấm thông báo mở planner đúng ngày và làm nổi việc đó. Nút hành động Android: "Xong", "Hoãn 10 phút".
- Bản web: tối thiểu hiện rõ "Nhắc nhở chỉ hoạt động trên app Android" thay vì im lặng, và hiện banner trong app khi đang mở mà đến giờ. Web Push trên iPhone chỉ chạy khi người dùng đã "Thêm vào Màn hình chính" (iOS 16.4+) và cần máy chủ gửi push → là quyết định kỹ thuật riêng, không thuộc phạm vi nghiên cứu này.

**Việc nhỏ nên làm kèm (S, không tính vào top 5):** UI chip lọc mini-app (provider đã có), đổi ngày trong form + nhân bản, cho phép qua nửa đêm, chấm báo ngày có việc trên date-strip, nút "Hôm nay" ngay trong màn, cho bấm vào hàng giờ đã có việc để thêm việc.

### 7.4. Gợi ý gắn với từng mini-app (dữ liệu đã có sẵn trong code)

| Mini-app | Nguồn dữ liệu sẵn có | Việc planner tạo/nhận | Hoàn thành tự động |
|---|---|---|---|
| Học tiếng Anh | `vocabulary/data/daily_words_repository.dart`, `learning_path/`, thông báo `DailyQuizNotifications` | Nút "Thêm vào kế hoạch" trên màn Học từ hôm nay → việc lặp hằng ngày "Ôn từ vựng"; bài nghe nhạc/luyện phát âm → việc có deep link tới bài hát | Khi xong lượt ôn/quiz trong ngày. Lưu ý không để thông báo planner trùng giờ với thông báo quiz hằng ngày (gộp hoặc chọn 1) |
| Fitness | `fitness/data/program_model.dart` (`ProgramDay.dayOfWeek`, ngày nghỉ = danh sách bài rỗng), `workout_session_screen.dart` | "Thêm chương trình vào lịch" → 1 việc lặp theo tuần cho các thứ có tập, ngày nghỉ hiện thành việc cả ngày mờ; checklist = danh sách bài tập của ngày | Khi `WorkoutFinishedScreen` ghi nhận xong buổi tập |
| Quản lý tài sản | `wealth/data/recurring_service_model.dart` (`expiryDate`, `reminderLeadDays`, `cycleType`, và `appSection` gắn dịch vụ cho Fitness/English — vd gói tập, khoá học), `wealth_debt_*`, `price_alert_prefs_repository.dart` | Việc "Gia hạn <dịch vụ>" vào ngày (hết hạn − lead days) và việc cả ngày vào ngày hết hạn; "Trả nợ <người>" theo hạn; việc lặp "Xem lại danh mục đầu tư" hằng tuần/tháng | Khi ghi nhận thanh toán gia hạn/trả nợ. Chú ý: dịch vụ có `appSection = fitness` thì việc nên gắn `appSection` Fitness để lọc đúng |

Nguyên tắc: planner chỉ LƯU THAM CHIẾU (`source.kind/refId`), không sao chép dữ liệu nghiệp vụ (số tiền, danh sách bài tập) — giống cách `ProgramExerciseRef` chỉ lưu `exerciseId`. Tránh để planner phụ thuộc vòng vào các feature: nên có 1 giao diện "PlannerSource" nhỏ ở `core/` để mỗi feature tự đăng ký, giữ đúng tinh thần feature-first/nhiều người code song song.

### 7.5. Điểm yếu UX của bản hiện tại so với đối thủ

1. **Timeline không thể hiện thời lượng và thời điểm hiện tại**: card có chiều cao cố định trong hàng giờ bắt đầu, không có vạch "bây giờ", gom theo giờ bắt đầu nên chồng lấn thật bị che (Google Calendar, TickTick, Structured đều vẽ theo thời lượng + vạch giờ hiện tại). Khuyến nghị §1 (chia cột thật) và lựa chọn `kalender` ở §6 chưa được áp dụng.
2. **Kéo-thả thô**: luôn làm tròn về đầu giờ (09:45 → 10:00), không kéo giãn để đổi giờ kết thúc, không kéo sang ngày khác, nhấn giữ không có gợi ý nào cho người dùng mới.
3. **Chỉ có view ngày**: không có agenda/tuần/tháng; date-strip không báo ngày nào có việc; lưới tháng khi bấm tiêu đề (khuyến nghị §2) chưa làm — chỉ có mũi tên đổi tháng.
4. **Trạng thái nhập tay**: "Đang chạy"/"Sắp tới" không tự đổi theo giờ; việc đã qua vẫn "Sắp tới"; muốn hoàn thành phải mở form (đối thủ chỉ 1 chạm).
5. **Thao tác huỷ hoại không có lưới an toàn**: xoá ngay, không xác nhận, không hoàn tác.
6. **Form thiếu cơ bản**: không đổi được ngày, không nhân bản, không qua nửa đêm (mâu thuẫn với icon "Ngủ" có sẵn), không có việc cả ngày.
7. **Hai hệ màu đụng nhau — vi phạm nguyên tắc §3**: bảng màu icon phân loại trùng mã màu với trạng thái — `relax` = `completed` = `0xFF5BE0D0`, `other` = `rejected` = `0xFFFF6B9D`. Card "Thư giãn" nhìn như "Hoàn thành". Cộng thêm màu mini-app → 3 trục màu trên cùng 1 card. Cần `planner-ui-designer` tách lại bảng màu icon (hoặc bỏ màu riêng của icon, dùng xám + hình icon).
8. **Lọc mini-app không truy cập được**: provider có nhưng không có UI; menu nổi thực tế không có "Hôm nay"/"Lọc".
9. **Hàng giờ đã có việc không bấm để thêm được** (`onTap` chỉ gán khi hàng trống) → người dùng phải biết dùng nút + ở header.
10. **Nhắc nhở "câm" trên web và không dẫn đường**: bấm thông báo không mở đúng việc; không có nút Xong/Hoãn; lệch giờ nhắc chỉ toàn cục.

### 7.6. Rủi ro dữ liệu cần lưu ý (không phải tính năng, nhưng ảnh hưởng quyết định)

- Bản web lưu SharedPreferences → `localStorage`. Safari/WebKit (từ iOS 13.4) xoá toàn bộ storage do script ghi của 1 site nếu người dùng không tương tác với site đó trong 7 ngày có dùng trình duyệt; web app đã "Thêm vào Màn hình chính" được miễn quy tắc này. Người dùng test chủ yếu web trên iPhone → kế hoạch có thể biến mất nếu vài tuần không mở. Giảm rủi ro: hướng dẫn thêm vào màn hình chính, hoặc ưu tiên đồng bộ Supabase (mục T) sớm hơn dự kiến.
- Mỗi lần sửa ghi lại toàn bộ danh sách JSON vào 1 key. Khi có việc lặp + override + checklist, dung lượng tăng — nên sinh lần lặp khi hiển thị thay vì lưu từng bản sao (đã nêu ở (2)).
- Id thông báo lấy từ `String.hashCode`. Dart không cam kết giá trị này ổn định giữa các phiên bản runtime → sau khi nâng SDK có thể không huỷ được thông báo cũ. Rủi ro thấp, nên cân nhắc hàm băm tự viết ổn định khi làm mục (5).

### 7.7. Pattern chung (an toàn tham khảo) vs chi tiết thương hiệu (KHÔNG copy)

**Pattern chung — bàn giao cho `planner-ui-designer`:**
- Vòng tick hoàn thành trên dòng việc + snackbar hoàn tác vài giây.
- Lặp lại theo ngày/thứ trong tuần/tháng + hỏi "chỉ lần này / các lần sau / tất cả" khi sửa.
- Inbox việc chưa xếp giờ + kéo vào timeline; màn xử lý việc quá hạn bằng vuốt.
- Vạch giờ hiện tại, card theo thời lượng, kéo bước 15 phút, kéo giãn cạnh dưới.
- Agenda nhiều ngày; chấm nhỏ báo ngày có việc (dấu hiệu tối giản của riêng app, xem lưu ý về DayTicker ở §5).
- Nhắc nhiều mốc cho mỗi việc, mức "khẩn cấp", nút hành động trên thông báo.
- Nhập nhanh bằng câu tự nhiên, tô sáng phần ngày/giờ được nhận diện.
- Mẫu/routine, checklist con, ghi chú, tổng kết cuối ngày/tuần, streak cho việc lặp.

**Chi tiết đặc thù/thương hiệu — không sao chép:**
- Tên gọi và cách trình bày riêng: "Ramble", "Todoist Assist", karma (Todoist); "Replan", "Energy Monitor", timeline dạng các viên icon tròn nối nhau bằng 1 đường dọc (hình ảnh nhận diện của Structured); "Daily Highlights" và kịch bản từng bước của nghi thức lập kế hoạch (Sunsama); đồng hồ tròn và phong cách minh hoạ của Tiimo; "Achievement Score"/cấp độ/so sánh với người dùng khác (TickTick); "Openings", "DayTicker" (Fantastical); thuật toán auto-schedule của Motion.
- Cú pháp chính xác của đối thủ (vd "every!" của Todoist, mã "p1-p4" và màu cờ ưu tiên của Todoist) — app nên tự đặt cú pháp tiếng Việt riêng ("hằng ngày", "thứ 2,4,6").
- Âm báo/giao diện báo thức "Urgent" của Apple — chỉ lấy ý tưởng "việc khẩn cấp đổ chuông như báo thức".

### 7.8. Việc cần chuyển cho agent khác

- **`library-researcher`**: (a) widget màn hình chính Android/iOS; (b) xuất/đọc ICS + RRULE nếu làm mục V; (c) nếu không tự viết, thư viện phân tích ngày giờ tiếng Việt từ câu tự nhiên (khả năng cao không có sẵn → tự viết bộ quy tắc hẹp). Nhắc lại: `kalender` đã chọn ở §6 nhưng chưa có trong `pubspec.yaml`.
- **Quyết định kỹ thuật (không phải UX)**: Web Push cho bản web iPhone (cần backend gửi push + web app đã thêm vào màn hình chính); đồng bộ planner qua Supabase.
- **`planner-ui-designer`**: tách lại bảng màu icon khỏi màu trạng thái (§7.5 mục 7); quyết định trạng thái "Quá hạn/Bỏ lỡ" có thành màu thứ 5 không; thiết kế Inbox, sheet Replan, dòng "Lặp lại" trong form, vòng tick trên card.

Nguồn (truy cập 2026-09):
[Structured – App Store](https://apps.apple.com/us/app/structured-daily-planner-todo/id1499198946),
[Structured App Review 2026 – daveswift.com](https://daveswift.com/structured/),
[Structured – What Is Replan?](https://help.structured.app/en/articles/4526850),
[Structured – Can I Reschedule Unfinished Tasks?](https://help.structured.app/en/articles/1990594),
[Structured – How to Add a Structured Widget](https://help.structured.app/en/articles/330498),
[Plaky – 18 Best Daily Planner Apps 2026](https://plaky.com/blog/best-daily-planner-apps/),
[HabitBox – TickTick Review 2026](https://habitbox.app/blog/ticktick-review),
[ClickUp – TickTick Review 2026](https://clickup.com/learn/topic/task-management/tools/ticktick/),
[TickTick Help – Achievements and Statistics](https://help.ticktick.com/articles/7082302534169133056),
[TickTick Help – Widgets](https://help.ticktick.com/articles/7055780404896202752),
[Todoist – Ramble (Beta)](https://www.todoist.com/help/todoist/product-updates/capture-tasks-at-the-speed-of-thought-ramble-beta-nov-19-r6701hY0t),
[TechCrunch – Todoist Ramble (01/2026)](https://techcrunch.com/2026/01/21/todoists-app-now-lets-you-add-tasks-to-your-to-do-list-by-speaking-to-its-ai/),
[Todoist – Introduction to deadlines](https://www.todoist.com/help/articles/introduction-to-deadlines-in-todoist-uMqbSLM6U),
[Todoist – Complete a task with a recurring date (Undo)](https://www.todoist.com/help/articles/complete-a-task-with-a-recurring-date-dmI6SVqdP),
[Todoist – Introduction to recurring dates](https://www.todoist.com/help/articles/introduction-to-recurring-dates-YUYVJJAV),
[Tiimo – Product](https://www.tiimoapp.com/product),
[Tiimo – Wikipedia](https://en.wikipedia.org/wiki/Tiimo),
[Sunsama Review 2026 – ClickUp](https://clickup.com/learn/topic/productivity/tools/sunsama/),
[Sunsama Review 2026 – Efficient App](https://efficient.app/apps/sunsama),
[Motion – Auto-scheduling Help Center](https://www.usemotion.com/help/time-management/auto-scheduling),
[Motion – AI Task Manager](https://www.usemotion.com/features/ai-task-manager),
[9to5Mac – Everything new for Reminders in iOS 26](https://9to5mac.com/2025/10/13/heres-everything-new-in-reminders-with-ios-26/),
[9to5Mac – iOS 26.4 Reminders Urgent list](https://9to5mac.com/2026/02/27/ios-26-4-gives-reminders-best-new-feature-the-one-thing-it-was-missing/),
[Lifestack – Google Calendar time blocking 2026](https://lifestack.ai/blog/google-calendar-timeblocking),
[Digital Trends – Google Calendar task time blocking](https://www.digitaltrends.com/phones/google-calendar-will-finally-let-you-block-time-for-a-task-instead-of-a-meeting/),
[Efficient App – Notion Calendar Review 2026](https://efficient.app/apps/notion-calendar),
[Flexibits – Fantastical](https://flexibits.com/fantastical),
[MagicBell – PWA iOS Limitations 2026](https://www.magicbell.com/blog/pwa-ios-limitations-safari-support-complete-guide),
[Pushpad – iOS requirements for web push](https://pushpad.xyz/blog/ios-special-requirements-for-web-push-notifications),
[Michael Tsai – Safari 7-day script-writeable storage](https://mjtsai.com/blog/2020/03/26/safari-13-1-third-party-cookie-blocking-and-7-day-script-writeable-storage/).

## 8. Trạng thái triển khai (2026-09-14)

Đã làm trong `app/lib/features/planner/` (không thêm package mới nào vào `pubspec.yaml`):

| Mục §7 | Đã làm | Ghi chú |
|---|---|---|
| Timeline nhiều ngày (yêu cầu mới) | Cột giờ cố định + **3 cột ngày song song**, vuốt ngang để đổi ngày; cột giữa = ngày đang chọn, date-strip và hàng tiêu đề ngày sáng theo | `planner_timeline.dart`. Card thu gọn (vòng tick + giờ + tên 2 dòng). Vẫn nhóm theo giờ bắt đầu, chưa vẽ theo thời lượng (cột quá hẹp) |
| A. Tick 1 chạm + trạng thái tự suy | Vòng tick trên mọi card; Sắp tới/Đang chạy/**Quá hạn** tự tính theo giờ | `overdue` chỉ tính khi hiển thị, không bao giờ ghi ra JSON |
| B. Hoàn tác | Snackbar "Hoàn tác" 4 giây cho tick, xoá, kéo-thả, nhân bản, xếp từ Inbox, xử lý quá hạn | `planner_undo.dart` (snapshot toàn bộ danh sách) |
| C. Lặp lại | Hằng ngày / theo thứ / hằng tháng + "đến ngày"; trạng thái từng lần lưu theo ngày; kéo-thả 1 lần lặp = tách riêng lần đó | Tập con RRULE; lần lặp sinh khi hiển thị |
| D. Inbox | Công tắc "Chưa chọn giờ"; dải chip phía trên timeline, nhấn giữ kéo vào ô giờ | |
| E. Xử lý quá hạn | Banner + sheet: Xong / Làm hôm nay / Chưa xếp giờ / Bỏ qua, vuốt phải = Xong, vuốt trái = Làm hôm nay | Chỉ việc 1 lần trong 14 ngày gần nhất |
| F. Nhắc theo từng việc | Tối đa 3 mốc/việc (đúng giờ, 5/15/30 phút, 1 giờ, 1 ngày); payload `planner:<id>|<ngày>` mở đúng ngày; bản web hiện cảnh báo | Chưa có nút hành động Xong/Hoãn trên thông báo |
| Chuông (yêu cầu mới) | **Chuông báo thức có sẵn trên máy** (RingtoneManager.TYPE_ALARM qua kênh native `planner/alarm_sounds`), nghe thử, phát qua luồng âm lượng báo thức; mặc định tự chọn chuông báo thức mặc định của máy | Chỉ Android; iOS/web không cho đọc chuông hệ thống |
| G. Liên kết mini-app | Fitness: "Thêm vào kế hoạch" ở chi tiết chương trình (lặp theo thứ tập) + tự tick khi xong buổi tập. English: "Thêm vào kế hoạch" ở "Học từ hôm nay" (lặp hằng ngày 20:00) + tự tick khi ôn hết từ. Wealth: icon lịch trên thẻ dịch vụ (việc gia hạn trước N ngày, nhắc đúng giờ + trước 1 ngày) + tự tick khi gia hạn | `planner_links.dart` — phụ thuộc 1 chiều mini-app → planner. Chưa có nút "Mở" deep link từ card về màn nguồn |
| R. Lọc mini-app | Chip lọc dưới date-strip | |
| S/Q. Sửa nhanh | Chọn ngày trong form, nhân bản, việc qua nửa đêm, ghi chú, bấm ô giờ đã có việc để thêm | |
| I (một phần) | Chấm báo ngày có việc trên date-strip, nút "Hôm nay", vạch giờ hiện tại | Chưa có lưới tháng |
| §7.5 mục 7 | Tách màu icon "Thư giãn"/"Khác" khỏi màu trạng thái | Có unit test chặn trùng lại |
| Lỗi phát hiện thêm | Mở app từ thông báo khi app đang tắt hẳn trước đây LUÔN mở Quiz với mọi loại thông báo → giờ chuyển đúng payload cho dispatcher chung | `daily_quiz_notifications.dart` |

### Đợt 2 (2026-09-14)

| Mục | Đã làm | Ghi chú |
|---|---|---|
| T. Đồng bộ Supabase | Bảng `planner_tasks` (migration `0063_planner_tasks.sql`, RLS theo user). Máy vẫn là nguồn đọc chính; mỗi thay đổi tự đồng bộ sau 2 giây và mỗi lần mở màn Lập kế hoạch | Gộp theo `updatedAt` (bản sửa sau cùng thắng); xoá = `deleted = true`. Dữ liệu cũ trên máy được nhận cho tài khoản đang đăng nhập ở lần đồng bộ đầu; đổi tài khoản thì bỏ dữ liệu của tài khoản cũ trên máy. Cài đặt chuông KHÔNG đồng bộ (mỗi máy chuông khác nhau). **Cần chạy migration 0063 trong SQL Editor** — chưa chạy thì app vẫn chỉ lưu trên máy |
| I. Lưới tháng | Bấm tên tháng → lịch cả tháng, tối đa 3 chấm/ngày (xanh = đã xong) | `planner_month_sheet.dart` |
| G. Nút "Mở" | Nút "Mở" trong sheet sửa việc do mini-app tạo: chương trình tập → chi tiết chương trình; ôn từ → Quiz ôn từ hôm nay; gia hạn → danh sách dịch vụ | Mini-app đăng ký ở `core/navigation/planner_source_openers.dart`, planner không import ngược feature nào |
| L. Checklist con | Thêm/xoá bước trong form, tick theo từng ngày (việc lặp mỗi ngày checklist riêng), card hiện "2/5" | |

Chưa làm: H (card theo thời lượng, kéo giãn), J (nhập bằng câu tự nhiên), K (mẫu/routine), M (Pomodoro), N (thống kê), O (streak), P (ưu tiên/hạn chót), U/V/W/X/Y.

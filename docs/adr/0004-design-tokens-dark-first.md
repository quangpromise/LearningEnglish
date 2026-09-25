# Design token qua ThemeExtension, dark-first, light theme tạm khóa; redesign bật bằng cờ

Bản redesign (`docs/design/gymtalk-redesign/`) đưa vào token màu mới (bg / s1 / s2 / bd / tx…, accent theo khu vực) cho cả dark lẫn light. Nhưng hiện 206 file đang dùng `AppColors` dạng `static const` và toàn bộ app chỉ có dark theme. Quyết định như sau:

- Token mới là một `ThemeExtension` (`GtTokens`), có đủ hai bảng dark và light, đọc qua `context.gt`.
- `AppColors` được giữ nguyên cho các màn chưa redesign, theo kiểu expand–contract: màn mới dùng token, màn cũ không bị đụng tới.
- Nền ảnh và "planet painter" của từng khu vực bị bỏ ngay tại **một điểm duy nhất** (`ScreenBackground`) để cả app phẳng màu `bg`, đúng như handoff yêu cầu.
- **Light theme** đã được định nghĩa và có test, nhưng nút chọn giao diện sáng **tạm khóa** (cờ `kEnableLightTheme = false`). Lý do: màn cũ còn hard-code màu tối, bật lên thì app nửa sáng nửa tối.
- Toàn bộ redesign được đưa vào sau cờ `kUseRedesign`. Mỗi ticket merge vào main mà app vẫn chạy màn cũ; ticket cuối cùng mới bật cờ và xóa màn cũ đã được thay.

## Consequences

- Màu `tx3` của light theme được đổi từ #8A8F97 (giá trị trong handoff) sang **#878C94**. Giá trị gốc chỉ đạt 2,95:1 trên nền #F4F4F2, dưới mức tối thiểu 3:1 cho nhãn; giá trị mới đạt 3,07:1. Test độ tương phản trong `gt_tokens_test.dart` giữ mọi token ở trên ngưỡng.

## Considered Options

- Đổi thẳng `AppColors` sang theme động: bị loại vì phải sửa 206 file cùng lúc, không chia nhỏ thành PR xanh được.
- Bật light theme ngay: bị loại vì các màn chưa redesign sẽ vỡ giao diện.

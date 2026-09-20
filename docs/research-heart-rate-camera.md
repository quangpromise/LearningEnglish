# Đo nhịp tim bằng camera (PPG) — chọn thư viện & giới hạn

## Gói đã thêm vào `pubspec.yaml`

| Gói | Bản | License | Online? | Lý do chọn |
|---|---|---|---|---|
| `camera` | ^0.11.0 | BSD-3-Clause | **Hoàn toàn offline** | Gói **chính thức** của nhóm Flutter (repo `flutter/packages`), miễn phí, không giới hạn. Là gói duy nhất cho phép **đọc từng khung hình** (`startImageStream`) + **bật đèn flash liên tục** (`FlashMode.torch`) — hai thứ bắt buộc để đo PPG. `image_picker` (đã có sẵn trong app) không làm được: nó chỉ mở app camera của hệ thống và trả về 1 file ảnh. |

Không thêm gói xử lý tín hiệu nào: phần lọc nhiễu + đếm nhịp tự viết trong
`app/lib/features/fitness/data/ppg_analyzer.dart` (~150 dòng Dart thuần, có
test ở `app/test/ppg_analyzer_test.dart`).

## Nguyên lý

Photoplethysmography (PPG): đặt ngón tay che kín ống kính + đèn flash, ánh sáng
xuyên qua đầu ngón tay. Mỗi nhịp tim đẩy một lượng máu qua mao mạch làm độ sáng
khung hình thay đổi rất nhỏ theo chu kỳ. App đo **độ sáng trung bình** của mỗi
khung hình (kênh luma Y của YUV420, lấy mẫu cách quãng 4×4 điểm ảnh cho nhẹ
CPU), rồi:

1. Khử trend bằng trung bình trượt 750 ms (bỏ phần nền trôi khi ngón tay ấn
   chặt dần).
2. Chuẩn hoá tín hiệu về [-1, 1].
3. Tìm đỉnh cục bộ vượt ngưỡng 0.35×độ lệch chuẩn, hai đỉnh cách nhau ≥ 300 ms
   (tương đương trần 200 bpm).
4. Lấy **trung vị** khoảng cách giữa các đỉnh → BPM.
5. Kiểm tra chất lượng **hai lớp**: (a) độ lệch chuẩn của các khoảng cách phải
   < 35% giá trị trung bình, (b) **tự tương quan** của tín hiệu tại đúng chu kỳ
   vừa tìm được phải ≥ 0.35.

Lớp (b) là bắt buộc: khi chỉ có lớp (a), nhiễu ngẫu nhiên ở 30 khung/giây cộng
với luật "2 đỉnh cách nhau ≥ 300 ms" tự nó sinh ra một chuỗi đỉnh khá đều và
lọt qua kiểm tra — đúng trường hợp `ppg_analyzer_test.dart` bắt được.

## Giới hạn — cố ý để lộ, không che giấu

- **Không phải thiết bị y tế.** Kết quả chỉ để tham khảo khi tập, và màn hình
  nói đúng như vậy.
- Nếu tín hiệu không đạt (không che kín ống kính, rung tay), app hiện
  **"Không đo được nhịp tim"** kèm hướng dẫn, **không đoán bừa một con số**.
  Thẻ "Nhịp tim" ở Trang chủ hiện `--` khi chưa từng đo.
- Kết quả ngoài khoảng 40–200 bpm bị coi là sai và không hiển thị.
- Độ chính xác phụ thuộc vào việc giữ yên tay suốt 30 giây.

## Kiến trúc để thay nguồn dữ liệu sau này

`HeartRateService` là lớp trừu tượng (`measure()` → `HeartRateResult`).
`CameraHeartRateService` là hiện thực đầu tiên. Khi ghép vòng đeo tay chỉ cần
thêm một hiện thực mới; màn hình và kho lưu trữ giữ nguyên. Trường
`HeartRateMeasurement.source` đã có sẵn giá trị `wearable` để không phải đổi
định dạng lưu trữ lần hai.

## Lưu trữ

Lịch sử đo lưu **trên máy** (`shared_preferences`, tối đa 200 bản ghi) chứ
không phải Supabase như dữ liệu tập luyện/dinh dưỡng: đây là dữ liệu sức khoẻ
đo bằng cảm biến của chính máy đó và người dùng chưa hề đồng ý cho nó rời khỏi
máy. Nhật ký giấc ngủ (`SleepRepository`) theo đúng nguyên tắc này.

## Quyền hệ thống

- Android: `android.permission.CAMERA` + 2 khai báo `uses-feature`
  (`camera`, `camera.flash`) với `required="false"` — máy không có đèn flash
  vẫn cài được app, chỉ là không dùng được tính năng này.
- iOS: `NSCameraUsageDescription`. Nhân tiện bổ sung luôn
  `NSMicrophoneUsageDescription` và `NSSpeechRecognitionUsageDescription` —
  hai khoá này trước đây **thiếu** trong `Info.plist` dù app đã dùng mic cho
  Luyện phát âm/AI Voice Chat; thiếu chúng thì iOS sẽ tắt app ngay lần đầu mở
  mic và App Store sẽ từ chối.

# Nghiên cứu: thông báo nhắc học 10 từ hôm nay

## Nhu cầu
Người dùng chọn tối đa 10 từ ở màn Vocabulary để "học hôm nay". Màn Hồ sơ
cho phép đặt khoảng thời gian (phút) và bấm "Bắt đầu học" - sau đó cứ mỗi
X phút, một thông báo sẽ hiện lên (kể cả khi app đã tắt/máy khoá màn hình),
bấm vào thông báo sẽ mở 1 câu quiz trắc nghiệm cho 1 trong 10 từ đó. Có nút
"Kết thúc học" để huỷ toàn bộ thông báo còn lại trong ngày.

## Package đã chọn
- **`flutter_local_notifications`** (pub.dev, BSD-style license, miễn phí,
  mã nguồn mở, chạy hoàn toàn on-device - không gọi API/gửi dữ liệu ra
  ngoài). Đây là package chuẩn của cộng đồng Flutter cho thông báo cục bộ
  có lên lịch, hoạt động được cả khi app đã bị đóng nhờ `AlarmManager`
  (Android) đặt lịch sẵn từ trước, không cần app chạy nền.
- **`timezone`** (pub.dev, thuộc dart-lang/labs, Apache 2.0, miễn phí) -
  phụ thuộc bắt buộc của `flutter_local_notifications` để dùng
  `zonedSchedule` (API duy nhất hỗ trợ đặt lịch vào một thời điểm tuyệt đối
  chính xác). Không cần thêm package dò múi giờ thiết bị (`flutter_timezone`)
  vì lịch chỉ tính tương đối "bây giờ + X phút" - dùng `tz.UTC` làm mốc là
  đủ chính xác cho tuyệt đối thời điểm bắn thông báo, không phụ thuộc múi
  giờ hiển thị.

## Vì sao KHÔNG dùng `Timer` trong app
`Timer.periodic` chỉ chạy khi tiến trình Dart/app còn sống (kể cả nền một
chút) - khi Android/iOS kill hẳn tiến trình (chuyện bình thường khi người
dùng vuốt tắt app hoặc hệ thống dọn RAM), timer mất tác dụng hoàn toàn.
Người dùng yêu cầu rõ thông báo phải hoạt động "cả khi app đã đóng/khoá
máy" - bắt buộc phải dùng lịch hẹn giờ cấp hệ điều hành (`AlarmManager`
qua `flutter_local_notifications`), không thể dùng timer thuần Dart.

## Giới hạn kỹ thuật cần lưu ý
- Android 12+ giới hạn rất chặt việc đặt "exact alarm" (báo đúng giờ tuyệt
  đối) - cần khai báo quyền `SCHEDULE_EXACT_ALARM` trong Manifest và xin
  người dùng cấp quyền "Alarms & reminders" trong Settings (không phải
  runtime permission dialog thông thường, phải điều hướng người dùng qua
  Settings nếu bị từ chối). Nếu người dùng không cấp, app tự động chuyển
  sang `inexactAllowWhileIdle` (thông báo có thể trễ vài phút so với lịch,
  vẫn hoạt động, chỉ kém chính xác).
- Android 13+ (API 33) yêu cầu quyền runtime `POST_NOTIFICATIONS` - phải
  xin quyền này trước khi đặt lịch, nếu không thông báo sẽ không hiện.
- Vì đặt lịch qua `AlarmManager`, khi máy khởi động lại (reboot) toàn bộ
  lịch đã đặt bị hệ điều hành xoá sạch (hành vi mặc định của Android) -
  đã khai báo `RECEIVE_BOOT_COMPLETED` + receiver `ScheduledNotificationBootReceiver`
  của package để plugin tự khôi phục lại các thông báo đã lưu sau khi khởi
  động lại máy.
- Phạm vi tính năng chỉ trong "hôm nay" - lịch được đặt từ thời điểm bấm
  "Bắt đầu học" đến hết ngày (23:59), không lặp lại qua ngày hôm sau (mỗi
  ngày người dùng tự chọn lại 10 từ mới nếu muốn).

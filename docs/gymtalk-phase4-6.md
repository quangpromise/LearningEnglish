# GymTalk – Giai đoạn 4–6: Nền tảng, "wow", tăng trưởng

Tiếp nối [Giai đoạn 1](gymtalk-phase1.md), [2](gymtalk-phase2.md), [3](gymtalk-phase3.md).

## Giai đoạn 4 – Nền tảng
| Hạng mục | Mô tả | File chính |
|---|---|---|
| **Đồng bộ theo tài khoản** | Bộ thẻ SRS + số liệu 3 vòng Tập/Học/Nói lưu lên Supabase (bảng `user_gymtalk_state`, 1 dòng/user, 2 cột jsonb). Đồng bộ khi mở app, khi quay lại app và 5 giây sau mỗi thay đổi: đọc server → **gộp** → ghi lên. Gộp SRS theo **lần ôn mới nhất** (`reviewedAt`, kể cả lần "Quên"); gộp vòng theo MAX từng bộ đếm, ngày nghỉ = OR – gộp nhiều lần vẫn ra cùng kết quả. Đăng nhập tài khoản khác trên cùng máy → xoá dữ liệu máy trước khi kéo về. | `features/today/data/gymtalk_sync_service.dart`, migration `0074` |
| **Backend nhận `scenario`** | gemini-proxy nhận query `scenario` (chỉ các giá trị trong danh sách, không ghép chuỗi từ máy khách) → PT AI dùng được khi chuyển sang backend proxy. `VoiceChatClient` gửi kèm. Cờ kết nối Gemini trực tiếp giữ nguyên cho tới khi deploy backend. | `backend/gemini-proxy/src/*`, `voice_chat_client.dart` |
| **Ẩn Wealth** | Cờ `kShowWealthSection = false`: ẩn Wealth khỏi nút chuyển app, bỏ qua khôi phục Wealth sau đăng nhập. Code Wealth giữ nguyên – đổi cờ thành `true` là hiện lại. | `core/config/gymtalk_flags.dart` |

## Giai đoạn 5 – "Wow"
| Hạng mục | Mô tả | File chính |
|---|---|---|
| **Đếm rep bằng camera** | Nút "Đếm rep bằng camera" ở màn đang tập (chỉ hiện với bài hỗ trợ: squat/lunge, đẩy/ép, cuốn tay, gập hông). Camera trước + ML Kit Pose Detection (on-device) → góc gối/khuỷu/hông → máy trạng thái có trễ đếm rep; HLV đếm to "one, two…" và nhắc "Go a little lower!" khi rep chưa đủ sâu; bấm Xong → số rep điền vào ô Reps. ~8 khung/giây, chọn 1 bên cơ thể rồi giữ cố định; lỗi/không hỗ trợ → báo và nhập tay như cũ. | `rep_counter.dart` (có test), `rep_camera_screen.dart` |
| **Buổi tập HLV dẫn bằng tiếng Anh** | Khi bật Giọng HLV: giới thiệu bài mới, "Set 2 of 4. Aim for 8 to 12 reps.", 1 nhắc kỹ thuật lấy từ hướng dẫn tiếng Anh của bài (xoay vòng theo set), câu giữa giờ nghỉ (khi tắt thẻ từ), lời chúc cuối buổi – câu chữ theo **trình độ người học** (cơ bản: câu ngắn). | `coach_script.dart` (có test) |

## Giai đoạn 6 – Tăng trưởng
| Hạng mục | Mô tả | File chính |
|---|---|---|
| **Thử thách tuần với bạn bè** | Màn Tiến độ: xếp hạng số ngày đạt Body + Brain trong 7 ngày của bạn và bạn bè đã kết bạn (RPC `friends_body_brain_week`, giờ VN). | migration `0074`, `progress_social_cards.dart` |
| **Nhắc theo lịch giáo án** | Bật + chọn giờ ở màn Tiến độ; đặt 7 thông báo tới, nội dung theo từng ngày: ngày tập "ôn 5 từ gym trước khi tập", ngày nghỉ "ôn N từ để giữ chuỗi". Chạm → tab Hôm nay. Đặt lại khi mở app/đổi giáo án/đổi cài đặt. | `gymtalk_reminders.dart` (có test) |
| **Ảnh chia sẻ kết quả** | Màn tổng kết buổi tập: "Chia sẻ ảnh kết quả" – chụp thẻ (GymTalk, chuỗi Body + Brain, thời gian, khối lượng, số set, số từ) thành PNG và mở bảng chia sẻ hệ thống. | `workout_finished_screen.dart` |
| **Thiết lập lần đầu** | Người dùng chưa có giáo án: tự mở "Thiết lập GymTalk" 1 lần trên màn Hôm nay. | `today_screen.dart` |

## Package mới (lý do chọn)
| Package | Lý do | License / chi phí | Online/offline |
|---|---|---|---|
| `google_mlkit_pose_detection ^0.16.1` | Nhận diện tư thế để đếm rep; model ML Kit đóng gói sẵn trong APK, chạy trên máy, không gọi mạng. Thêm luật giữ class trong `proguard-rules.pro` vì release bật R8. APK tăng ~10–20 MB. | Plugin MIT; ML Kit miễn phí | Offline |
| `share_plus ^13.3.0` | Mở bảng chia sẻ hệ thống cho ảnh kết quả buổi tập. Tương thích lockfile hiện tại (`win32 6.4.0`, `file 7.0.1`, `web 1.1.1`). | BSD-3, miễn phí | Offline |

## Việc cần làm khi triển khai
- Chạy migration `supabase/migrations/0074_gymtalk_state_sync.sql`.
- `flutter pub get` (thêm 2 package) rồi build APK.
- Thử trên máy thật: camera đếm rep (đặt máy cách 2–3 m, thấy toàn thân), thông báo nhắc (cấp quyền thông báo + báo thức chính xác), chia sẻ ảnh.

## Giới hạn đã biết
- Bộ đếm vòng gộp theo MAX: nếu dùng 2 máy **offline cùng ngày**, số lượt không cộng dồn giữa 2 máy.
- Đếm rep bằng camera dựa trên góc 2D từ camera trước – kết quả phụ thuộc góc đặt máy và ánh sáng; bài chưa hỗ trợ (plank, cardio…) không hiện nút.
- Nhắc hằng ngày chỉ trên Android (plugin thông báo hiện chỉ khởi tạo Android).

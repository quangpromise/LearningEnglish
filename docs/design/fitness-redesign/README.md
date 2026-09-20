# Fitness redesign — nguồn ảnh nền các thẻ

`_ref.jpg` là **ảnh thiết kế do chủ dự án tự tạo** (không phải stock photo
bên thứ ba), nên dùng lại nội dung trong đó không vướng bản quyền — cùng
nguyên tắc đã áp dụng cho ảnh minh hoạ Part 1 TOEIC (xem `app/pubspec.yaml`).

5 file trong `app/assets/fitness/home/` được **cắt trực tiếp** từ ảnh đó:

| File | Vùng cắt trên `_ref.jpg` | Ghi chú |
|---|---|---|
| `hero.jpg` | (46, 250) → (1035, 696) | Xoá phần chữ tiêu đề/nút bên trái. **Giữ nguyên** cụm STRONGER/HEALTHIER/HAPPIER và đường nhịp tim bên phải — app không vẽ lại 2 thứ đó nữa. |
| `today_plan.jpg` | (46, 1030) → (1035, 1370) | Xoá chữ bên trái, giữ chồng bánh tạ bên phải. |
| `program_beginner.jpg` | (48, 1480) → (368, 1775) | Xoá icon + chữ ở đáy thẻ. |
| `program_muscle.jpg` | (385, 1480) → (705, 1775) | nt. |
| `program_fatloss.jpg` | (722, 1480) → (1035, 1775) | nt. |

Chữ in sẵn trên ảnh **bắt buộc phải xoá**: app tự vẽ chữ thật lên trên để
còn đổi được ngôn ngữ (Việt/Anh) và để nút bấm được.

## Tạo lại khi ảnh thiết kế đổi

Cách xoá chữ: phủ một dải màu đặc (đen cho thẻ lớn/thẻ giáo án, `#111111`
cho thẻ kế hoạch) nhạt dần về phía phần ảnh cần giữ —
`hero`/`today_plan` phủ từ mép **trái**, 3 thẻ giáo án phủ từ mép **dưới**.

## Các file còn lại trong thư mục

- `TOKENS.md` — bảng đo màu/kích thước lấy từ `_ref.jpg`.
- `Main.dc.html` — bản dựng lại bằng HTML, chỉ dùng để đối chiếu tỉ lệ lúc
  thiết kế; **không phải** nguồn của app.
- `_shot-home.png`, `_compare.png`, `_compare_flutter.png` — ảnh đối chiếu.
  Ảnh chụp màn Flutter thật nằm ở `app/test/goldens/fitness_home.png`, sinh
  lại bằng:
  `flutter test test/fitness_home_golden_test.dart --update-goldens`

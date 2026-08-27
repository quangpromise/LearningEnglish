---
name: ui-design-system
description: Design system & hệ thống mockup giao diện của app Learn English Through Music — màu sắc, font, component, và bộ 6 màn hình mẫu. Dùng khi cần thiết kế thêm màn hình mới hoặc muốn giữ giao diện đồng nhất.
---

# UI Design System — Learn English Through Music

Lấy cảm hứng từ ảnh tham chiếu `uxui.jpg` (phong cách dark glassmorphism, glow neon, cảm giác cao cấp mượt mà kiểu Apple).

## Canvas mockup đã publish
👉 https://claude.ai/code/artifact/3e5cf1f3-e324-4b62-bc1f-e89741ada66b

**Trang "Màn hình chính"** — 6 màn hình + 1 bìa tổng quan:
1. **Home** — trang chủ chọn bài hát theo thể loại/trình độ.
2. **Player** — nghe nhạc, lyric song ngữ Anh–Việt đồng bộ theo thời gian.
3. **WordPopup** — bottom sheet khi chạm vào 1 từ (nghĩa, IPA, nghe phát âm mẫu).
4. **Pronunciation** — luyện phát âm bằng mic (waveform, chấm điểm so khớp).
5. **Grammar** — giải thích ngữ pháp câu khó trong lyric + bài tập nhanh.
6. **Profile** — hồ sơ, thống kê tiến độ học tập, streak, huy hiệu.

**Trang "Đố vui & Xếp hạng"** — tính năng game hoá, nội dung câu đố tham khảo từ kho đố vui tiếng Anh tại vn.elsaspeak.com/do-vui-tieng-anh (trang đó chỉ là kho nội dung tĩnh — không có điểm số/xếp hạng, phần gamification là tự thiết kế thêm cho app này):
7. **QuizCategory** — chọn chủ đề đố (chơi chữ, suy luận, động vật, cuộc sống, bảng chữ cái, trái cây & xe cộ).
8. **QuizQuestion** — câu hỏi trắc nghiệm song ngữ, đếm giờ, thanh tiến trình, thưởng XP.
9. **QuizResult** — kết quả sau thử thách: điểm số, XP nhận được, thay đổi thứ hạng, chi tiết đúng/sai.
10. **Leaderboard** — bảng xếp hạng người chơi (podium top 3 + danh sách, theo tuần/tháng/mọi lúc).

Source `.dc.html` của từng màn hình (để tái sử dụng/chỉnh sửa) nằm trong [mockups/](mockups/).

## Design tokens

**Màu nền (dark, chủ đạo)**
- Nền chính: `linear-gradient(170deg,#0a0e1c 0%,#0d1330 55%,#080b16 100%)`
- Glow trang trí: radial-gradient xanh dương `rgba(91,140,255,.35)` và tím `rgba(155,107,255,.3)` phủ mờ ở góc trên/dưới màn hình.

**Accent**
- Xanh dương: `#5b8cff`
- Tím: `#9b6bff`
- Gradient chính (nút, icon nổi bật): `linear-gradient(135deg,#5b8cff,#9b6bff)`
- Glow shadow đi kèm accent: `box-shadow: 0 20px 40px rgba(91,140,255,.5), 0 0 40px rgba(155,107,255,.35)`
- Màu phụ: xanh ngọc `#5be0d0` (đúng/thành công), vàng cam `#ffb23c`/`#ffd66b` (streak, cảnh báo nhẹ), hồng `#ff6b9d` (điểm nhấn phụ).

**Card**
- Glass tối: `background: rgba(255,255,255,.05); border: 1px solid rgba(255,255,255,.09); border-radius: 20–24px`
- Card sáng nổi bật (kiểu ảnh gốc xen kẽ card trắng/kem): `background: rgba(255,255,255,.95); color:#0b1220; border-radius:24–26px; box-shadow: 0 24px 48px rgba(0,0,0,.35)`

**Nút**
- Pill primary: bo góc `999px`, nền gradient accent, chữ trắng đậm, có glow shadow.
- Pill outline: nền `rgba(255,255,255,.06)`, viền `1px solid rgba(255,255,255,.15)`.

**Font**
- Heading: `Space Grotesk` (Google Fonts) — dùng cho tiêu đề, số liệu lớn.
- Body: `Manrope` (Google Fonts) — dùng cho phần còn lại.

**Icon**
- SVG inline, stroke 2px, bo góc (rounded linecap/linejoin), không dùng emoji.

**Bo góc & shadow**
- Card lớn: 20–32px. Nút pill: 999px (full round). Shadow luôn mềm, lan tỏa (soft + glow), không dùng shadow cứng/sắc cạnh.

## Khi thiết kế thêm màn hình mới
Dùng đúng token màu sắc/font/nút ở trên để đồng nhất với 6 màn hình đã có. Xem trực tiếp `mockups/*.dc.html` để copy cấu trúc CSS (`.screen`, `.card`, `.btn-pill`, v.v.) làm nền cho màn hình mới.

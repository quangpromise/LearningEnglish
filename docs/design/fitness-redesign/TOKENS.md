# Fitness redesign — bảng đo từ ảnh gốc

Ảnh gốc: `_ref.jpg` (1080 × 2179 px). Thiết bị ~1080px @ 2.769 px/dp → khung
logic **390 × 787 dp**. Mọi số dưới đây đo trực tiếp bằng pixel trên ảnh đó
rồi chia cho 2.769.

## Màu (lấy trung bình vùng)
| Token | Hex | Dùng ở |
|---|---|---|
| background | `#050505` | nền trang |
| card | `#111111` | thẻ chỉ số, thẻ kế hoạch |
| card border | `#262626` | viền thẻ |
| primary red | `#E50914` | nút, icon, số liệu nhấn |
| bright red | `#FF2028` | đường sparkline, mũi tên tăng |
| dark red | `#5C080D` | nền thẻ Tiện ích nhanh (pha với đen) |
| text primary | `#FFFFFF` | tiêu đề, số |
| text secondary | `#A5A5A5` | nhãn, phụ đề |
| text muted | `#666666` | đơn vị mờ |

## Trục dọc (dp, tính từ mép trên vùng an toàn)
| Khối | Top | Bottom | Cao |
|---|---|---|---|
| Avatar header | 36 | 64 | 46 (đường kính) |
| Hero card | 90 | 251 | 161 |
| Thẻ chỉ số | 265 | 358 | 93 |
| Thẻ kế hoạch hôm nay | 374 | 493 | 119 |
| Tiêu đề "Tập luyện" | 517 | 527 | — |
| Hàng thẻ chương trình | 538 | 642 | 104 |
| Tiêu đề "Tiện ích nhanh" | 658 | 668 | — |
| Hàng Tiện ích nhanh | 675 | 725 | 50 |
| Thanh nhạc | 728 | 775 | 47 |

## Trục ngang
- Padding ngang trang: **16 dp** (mép thẻ ở x = 46 px).
- Thẻ chương trình: rộng **115 dp**, khoảng cách **12 dp**, bo **14 dp**.
- Thẻ Tiện ích nhanh: rộng **85.5 dp** (4 cột, cách **7 dp**), bo **12 dp**.
- Thẻ chỉ số: 4 cột chia đều, có vạch dọc `#262626` giữa các cột.

## Cỡ chữ
| Vai trò | Size | Weight |
|---|---|---|
| Tên người dùng | 21 | 700 |
| "Xin chào," | 12.5 | 500 |
| Nhãn hero (in hoa) | 10.5 | 800, letter-spacing 1.2 |
| Tiêu đề hero | 21 | 700, line-height 1.25 |
| Phụ đề hero | 12 | 500 |
| Tiêu đề section | 20 | 700 |
| "Xem tất cả" | 13 | 600 |
| Nhãn chỉ số | 13 | 500 |
| Giá trị chỉ số | 26 | 700 |
| Đơn vị chỉ số | 13 | 600 |
| Tên chương trình | 14 | 700 |
| Phụ đề chương trình | 11.5 | 500 |
| Nhãn tiện ích | 12 | 600 |

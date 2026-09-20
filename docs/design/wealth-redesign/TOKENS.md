# Wealth Redesign — Design tokens đo từ ảnh mẫu

Nguồn: ảnh mẫu do người dùng tự thiết kế, `2479fab7-image.png`, **841 × 1870 px**.
Hệ quy đổi sang khổ logic 390 px: `k = 390 / 841 = 0.46373`.
Gốc toạ độ của artboard = ảnh y = 64 (ngay dưới thanh trạng thái hệ thống — mockup **không** vẽ thanh trạng thái giả).

Cách đo: nạp ảnh vào `<canvas>` → `getImageData`, chạy trong Chrome headless.
- Màu vùng: median của ô 7×7 (bỏ qua nét chữ)
- Màu chữ: trung bình 2% pixel sáng nhất trong ô chứa chữ (màu lõi nét)
- Biên: quét cột/hàng tìm điểm nhảy độ sáng > 3–6 đơn vị

---

## 1. Màu nền trang

| Vị trí (ảnh y) | Đo được | Ghi chú |
|---|---|---|
| y = 0–400, x = 6 | `#03090D` | vùng trên hơi ngả xanh lam |
| y = 500–800 | `#00050A` | |
| y = 900–1800 | `#000307` | vùng dưới gần đen tuyệt đối |
| khe giữa 2 thẻ | `#010104` – `#000306` | tối hơn cả ruột thẻ |

**Token nền trang**
```
--bg-base:  #02060B
background:
  radial-gradient(120% 55% at 78% 5%,  rgba(56,104,150,.20), transparent 60%)  /* phản chiếu lam lạnh */
  radial-gradient(95% 40% at 18% 24%,  rgba(212,175,55,.10), transparent 62%)  /* quầng vàng sau hero */
  linear-gradient(180deg, #04090F 0%, #02060B 42%, #000205 100%);
```

## 2. Ruột thẻ (glass fill)

Đo median dọc theo cột trái của từng thẻ (tránh artwork):

| Thẻ | ~14 px dưới mép trên | giữa | đáy |
|---|---|---|---|
| Hero | `#191D21` | `#080D13` | `#050A0F` |
| Widget nhỏ | `#0F141A` | `#04090E` | `#030A11` |
| Tổng quan | `#080D10` | `#03080C` | `#040A10` |
| Nhạc | `#05090E` | `#030A13` | `#040B13` |

**Token**
```
--card-fill: linear-gradient(180deg,#121A22 0%, #080D14 38%, #03070C 100%);
--card-fill-soft: linear-gradient(180deg,#0F141B 0%, #05090F 45%, #02060B 100%);
```

## 3. Viền — phân cấp rõ (điểm mấu chốt)

Đo màu sáng nhất trong ô 5×5 ngay trên đường viền:

**Hero** — viền TRÁI là vàng kim loại chạy suốt chiều cao, các cạnh khác là slate lạnh:

| Cạnh | Đo được |
|---|---|
| trái, y=340 / 450 / 560 / 680 | `#E5E08E` / `#D3B980` / `#E6D49E` / `#A28D67` |
| trên, x=100 (góc trái) | `#75664E` |
| trên, x=250 → 760 | `#2D333A` → `#242930` |
| phải, mọi y | `#2C3036` – `#444A4F` |
| dưới, x=100 (góc trái) | `#967644` |
| dưới, x=250 → 760 | `#2E343B` |

```
/* hero */
border: 1.5px solid transparent;
background: var(--card-fill) padding-box,
  linear-gradient(90deg,#E6D79C 0%, #C9A458 3%, #4A4A44 10%, #2E343B 30%, #2B3036 100%) border-box;
```

**Thẻ nhỏ (Tổng quan / widget / Báo cáo / Nhạc)** — viền mảnh, gần như trung tính, chỉ ấm nhẹ ở góc trên-trái:

| Cạnh | Đo được |
|---|---|
| trên, x=150 | `#454340` (ấm nhẹ) |
| trên, x=420 / 700 | `#21272D` / `#1F2329` |
| trái / phải | `#3F444A` / `#343A41` |
| dưới | `#2B3036` |

```
/* thẻ nhỏ */
border: 1px solid transparent;
background: var(--card-fill-soft) padding-box,
  linear-gradient(120deg, rgba(212,175,55,.42) 0%, #2C3239 16%, #23282E 100%) border-box;
```

**Quầng sáng** (không để mọi thẻ sáng bằng nhau):
- hero: `0 0 28px rgba(212,175,55,.07), 0 18px 46px rgba(0,0,0,.62)`
- thẻ nhỏ: `0 8px 24px rgba(0,0,0,.5)` (không quầng vàng)

## 4. Vàng & artwork

| Mục | Đo được |
|---|---|
| `AppColors.wealthAccent` (giữ nguyên) | `#D4AF37` |
| `wealthAccentGradient` (giữ nguyên) | `#D4AF37 → #F0D585` |
| lõi nét đường biểu đồ (hero) | `#FFFFDA` |
| lõi nét đường biểu đồ (Tổng quan) | `#FFFFD6` |
| vùng sáng nhất khối 3D | `#FFF4D3` |
| vùng vàng trung bình khối 3D | `#CF9A4A`, `#A2763A` |
| bóng tối khối 3D | `#42280E` |

## 5. Chữ (màu lõi nét, brightest-2% / brightest-10%)

| Chỗ | 2% | 10% |
|---|---|---|
| Tên người dùng, tiêu đề, số dư | `#FFFFFF` | `#FBFBFB` |
| "Hello," | `#F8FAFB` | `#C4C7CA` |
| Phụ đề / nhãn phụ | `#D2D9E2` | `#B0B9C3` |
| Chữ trong pill ASSETS MANAGEMENT | `#DBE2E9` | `#A9B1BA` |
| Tagline BIGGER DREAMS | `#BFC1BB` | `#9DA5AE` |
| % dương (xanh) | `#2CFFC5` | `#22F4B3` |

```
--text-primary: #FFFFFF;   /* tiêu đề, số liệu */
--text-body:    #EEF1FB;   /* = AppColors.textPrimary */
--text-muted:   #AEB7C3;   /* phụ đề */
--pos: #22E3A4;            /* % dương — đo #22F4B3 */
--neg: #F4626C;            /* % âm — KHÔNG có trong ảnh mẫu, chọn theo brief "đỏ trang nhã" */
```

## 6. Kiểu chữ (đo chiều cao chữ hoa / chiều cao chữ số)

Font giữ nguyên của app: **Space Grotesk** (tiêu đề) + **Manrope** (nội dung).

| Chỗ | Chiều cao đo (ảnh px) | → 390 | Cỡ chữ suy ra | Dùng trong mockup |
|---|---|---|---|---|
| Số dư `$ 12,436` (chữ số "1") | 46 | 21.3 | ~30.5 | **31** / 700 |
| Phần `.00` | 43 | 19.9 | ~28 | **28** / 700, trắng |
| Tên "Quang Hua" (chữ Q) | 32 | 14.8 | ~21 | **21** / 700 |
| "Hello," (chữ H) | 18 | 8.3 | ~11.5 | **12** / 600 |
| "Tổng tài sản" (chữ T) | 18 | 8.3 | ~11.6 | **12.5** / 700 |
| "+12.8%" | 20 | 9.3 | ~13 | **13** / 800 |
| Tiêu đề mục (chữ T "Tổng quan") | 15 | 7.0 | ~9.7 | **12.5** / 700 † |
| Nhãn widget (chữ C "Chi tiêu") | 15 | 7.0 | ~9.7 | **12** / 700 † |
| Giá trị thống kê `$ 2,480.00` | 18 | 8.3 | ~11.5 | **12** / 700 |
| Phụ đề / nhãn mờ | 14–16 | 6.5–7.4 | ~9.5 | **9.5** / 500 |
| ASSETS MANAGEMENT (in hoa) | 11 | 5.1 | ~7.1 | **8.5** / 800, tracking .14em |

† nâng nhẹ so với số đo để chữ tiếng Việt có dấu còn đọc được ở 390 px — đây là chỗ duy nhất lệch có chủ đích khỏi số đo.

## 7. Toạ độ & kích thước (quy về 390, gốc = ảnh y 64)

| Phần tử | Ảnh (x0..x1 / y0..y1) | 390 |
|---|---|---|
| Lề trái/phải trang | x 34 .. 809 | **16** / rộng **358** |
| Avatar (vòng vàng) | x32..153, y118..240 | 16, 25 — **d = 56** |
| Nút tròn chuông/cài đặt | d = 64 | **d = 30** (mockup dùng **40** cho vùng chạm ≥ 44) |
| Pill ASSETS MANAGEMENT | x185..474, y207..253 | x 86, y 66, w 134, **h 21** |
| **Hero** | x34..809, y304..747 | y **111**, **h 205**, bo góc ~20 |
| — padding trong hero | chữ bắt đầu x=73 | **18** |
| — nhãn "Tổng tài sản" | y352 | +22 so với mép thẻ |
| — số dư | y405..466 | +47 |
| — "+12.8% (24h)" | y493..512 | +88 |
| — biểu đồ nhỏ | x61..377, y507..584 | trái 13, trên 94, **150 × 38** |
| — dải Chi/Thu · Mã QR | x62..781, y636..733 | lùi trong 13, **h 45** |
| — artwork chồng xu | x424..808, y312..624 | phải 0, trên 2, **178 × 145** |
| **4 widget (ảnh mẫu)** | y785..1004, 4 cột 183 px, khe 15 | h 102, cột 85, khe 7 → **mockup đổi sang lưới 2×2** vì nhãn tiếng Việt dài |
| — icon 3D trong widget | d ≈ 100–112 | **44** |
| **Tổng quan** | x34..809, y1032..1396 | y **449**, **h 169** |
| — icon tròn trái | x67..147, y1055..1137 | **d 38** |
| — badge % | x567..779, y1056..1129 | phải 14, trên 11, **98 × 34** |
| — biểu đồ đường | x66..540, y1130..1242 | trái 15, trên 46, **220 × 52** |
| — artwork cột 3D | x562..810, y1145..1395 | phải 0, trên 52, **115 × 116** |
| — 3 ô thống kê | x68..213 / 236..380 / 403..545, y1271..1375 | lùi 16, trên 111, **67 × 48**, khe 11 |
| **Báo cáo** | x34..809, y1424..1529 | y **631**, **h 49** |
| — icon tài liệu | d ≈ 82 | **d 40** |
| — pill "Xem tất cả" | x658..786, y1451..1500 | phải 11, **59 × 23** |
| **Nhạc** | x34..809, y1555..1664 | y **692**, **h 50** |
| — đĩa than | d ≈ 87 | **d 40** |
| — nút play | x707..794, y1574..1659 | phải 7, **d 40** |

Bo góc thẻ đo được ≈ 34 px ảnh → **~16–20 px** ở khổ 390 (hero 20, thẻ nhỏ 16–18).

## 8. Artwork cắt từ ảnh mẫu (`img/`)

Các khối 3D không vẽ lại được bằng SVG nên cắt trực tiếp từ ảnh mẫu (người dùng xác nhận ảnh do họ tự thiết kế). Tất cả xuất JPEG q0.88–0.9, đặt trên nền tối với `mix-blend-mode: screen` để nền đen của ảnh hoà vào thẻ.

| File | Vùng cắt (ảnh) | KB |
|---|---|---|
| `coins.jpg` | 424,312 · 384×312 | 27.0 |
| `bars.jpg` | 562,1145 · 248×250 | 11.9 |
| `ic-wallet.jpg` | 40,793 · 112×112 | 3.3 |
| `ic-coins.jpg` | 238,791 · 112×112 | 3.5 |
| `ic-arrows.jpg` | 452,800 · 112×112 | 3.4 |
| `ic-card.jpg` | 633,793 · 112×112 | 3.2 |
| `ic-doc.jpg` | 49,1420 · 112×112 | 3.3 |
| `ic-chart.jpg` | 51,1040 · 112×112 | 3.4 |
| `ic-vinyl.jpg` | 41,1547 · 112×112 | 3.7 |
| `ic-play.jpg` | 694,1560 · 112×112 | 3.6 |
| `ic-wallet-sm.jpg` | 77,661 · 58×53 | 2.0 |
| `ic-qr.jpg` | 537,662 · 70×56 | 2.6 |
| `avatar.jpg` | 31,117 · 124×124 | 6.4 |

Tổng ≈ 76 KB.

---

## 9. Kết quả đối chiếu trắc đồ (ảnh mẫu ↔ bản dựng)

Bản dựng chụp ở đúng tỉ lệ ảnh mẫu (`--window-size=390,920 --force-device-scale-factor=2.15641` → 841 px ngang).
Percentile độ sáng p10 / p50 / p97 trên từng khối:

| Khối | Ảnh mẫu | Bản dựng | Lệch |
|---|---|---|---|
| Toàn màn | 2.8 / 10.7 / 191.3 | 5.5 / 16.6 / 189.0 | +2.7 / +5.9 / −2.3 |
| Hero | 9.2 / 18.9 / 218.6 | 10.4 / 21.0 / 214.9 | +1.2 / +2.1 / −3.7 |
| Khối 4 widget | 4.6 / 11.2 / 180.8 | 6.6 / 11.4 / 139.9 | +2.0 / +0.2 / −40.9 * |
| Tổng quan | 8.2 / 11.3 / 159.7 | 9.7 / 17.7 / 181.4 | +1.5 / +6.4 / +21.7 |
| Báo cáo | 8.7 / 11.2 / 138.4 | 7.4 / 15.9 / 169.0 | −1.3 / +4.7 / +30.6 † |
| Nhạc | 7.4 / 9.8 / 122.0 | 8.6 / 16.8 / 171.7 | +1.2 / +7.0 / +49.7 † |
| Nền ngoài thẻ | 2.6 / 2.8 / 3.7 | 1.9 / 3.4 / 12.6 | −0.7 / +0.6 / +8.9 |

p10 và p50 (vùng tối và tông chung) lệch dưới ±8 ở mọi khối — đạt.

Hai chỗ p97 lệch > 25, đều là lệch **có chủ đích**, không phải sai tông:
- \* **Khối 4 widget**: bản dựng xếp 2×2 (cao 396 px ảnh) thay vì 4 cột (cao 219 px) nên cùng 4 icon vàng nhưng trải trên diện tích gấp đôi → mật độ pixel sáng loãng hơn. Đo riêng 1 icon: max 255 (bằng ảnh mẫu).
- † **Báo cáo / Nhạc**: chữ tiêu đề ở bản dựng là 11.5 px (số đo gốc ~10.3 px) — bump để chữ tiếng Việt có dấu còn đọc được ở 390 px, xem ghi chú † mục 6. Đo riêng icon đĩa than & nút play thì bản dựng còn **tối hơn** ảnh mẫu (p99 173/204 so với 214/234).

## 10. File trong thư mục

| File | Vai trò |
|---|---|
| `Main.dc.html` | Artboard chính — màn Home (390 × 920) |
| `States.dc.html` | Artboard phụ — quy tắc màu %, lý do lưới 2×2, map provider |
| `canvas.json` | Bố cục canvas + ghi chú dán |
| `quan-ly-tai-san-redesign.html` | File canvas đã seed (đã publish) |
| `img/` | 13 ảnh cắt từ ảnh mẫu |
| `preview-main.html`, `preview-states.html` | Bản HTML thường để chụp đối chiếu |
| `compare.png` | Ảnh so sánh: ảnh mẫu trái ↔ bản dựng phải |

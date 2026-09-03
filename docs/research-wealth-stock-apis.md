# Nghiên cứu API dữ liệu chứng khoán (tính năng Quản lý tài sản)

Tính năng Quản lý tài sản cần giá cổ phiếu Việt Nam (HOSE/HNX/UPCOM) và quốc
tế (NYSE/NASDAQ), kết hợp với crypto (đã giải quyết, xem
`docs/research-crypto-api.md`). Khác với crypto, không có nguồn chứng khoán
nào vừa miễn phí, vừa chính thức, vừa không cần API key như CoinGecko.

## Quốc tế: chọn Twelve Data

| API | Free tier | Cần key? | Thương mại | Độ trễ |
|---|---|---|---|---|
| **Twelve Data** (chọn) | 800 call/ngày, 8 call/phút | Có | Cho phép dùng nội bộ, điều khoản rõ ràng hơn Finnhub free | Delayed ở free tier |
| Alpha Vantage | 25 call/ngày | Có | — | Quota quá thấp để dùng thực tế |
| Finnhub | 60 call/phút | Có | **Free tier cấm dùng thương mại** | Realtime |
| Polygon.io | 5 call/phút | Có | Starter ($29/tháng) mới hết giới hạn call | Delay 15 phút (free/Starter) |
| IEX Cloud | — | — | **Đã ngừng hoạt động từ 08/2024** | Loại bỏ |

Twelve Data cân bằng tốt nhất giữa hạn mức đủ dùng (refresh theo thao tác
người dùng, không polling liên tục) và điều khoản thương mại không cấm rõ
ràng như Finnhub free.

## Việt Nam: SSI FastConnect Data (chính thức, Phase 2) + fallback không chính thức

| Nguồn | Chính thức? | Cần đăng ký? | Độ trễ |
|---|---|---|---|
| **SSI FastConnect Data** (khuyến nghị) | Có, tài liệu API đầy đủ | Cần đăng ký offline (CCCD) — người dùng tự làm, không tự động hoá được | Realtime nếu được cấp quyền |
| VNDirect (`finfo-api.vndirect.com.vn`) | Không, reverse-engineer | Không cần | Gần real-time, không đảm bảo |
| TCBS/VCI (qua thư viện `vnstock`) | Không, reverse-engineer | Không cần | Tương tự VNDirect |
| Vietstock, cafef.vn | Không, reverse-engineer | Không cần | Delay 15-20 phút |
| FiinTrade/FiinGroup | Có, B2B | Hợp đồng thương mại, không có free tier | Realtime (gói cao cấp) |

Chưa có nguồn "an toàn tuyệt đối" như CoinGecko cho thị trường VN. Quyết
định: **Phase 1 chưa làm chứng khoán VN**, chờ người dùng tự đăng ký xong
SSI FastConnect rồi mới thêm ở Phase 2.

## Vì sao không dùng OKX (hay Bybit/Binance) cho chứng khoán

Đã kiểm tra riêng theo yêu cầu: OKX không có API dữ liệu chứng khoán thật.
Cái OKX (và Bybit, Binance qua đối tác, Bitget, MEXC) có là **Tokenized
Stocks** (vd XAAPL, XTSLA) — token on-chain do bên thứ ba xStocks/Backed
Finance phát hành, giao dịch như 1 cặp spot crypto thông thường trên sàn.
Gọi được qua cùng API ticker crypto (free, không cần key), nhưng:

- Chỉ phủ ~40 mã lớn, không có cổ phiếu Việt Nam.
- Giá là giá token on-chain, có thể lệch so với giá thật trên NASDAQ/NYSE do
  chênh lệch cung-cầu/thanh khoản riêng của token.
- Không khả dụng ở Mỹ/EU (giới hạn khu vực).

Trình bày giá token này như "giá cổ phiếu thật" trong 1 app tài chính có
rủi ro gây hiểu lầm nghiêm trọng cho người dùng. **Không dùng OKX cho phần
chứng khoán** — chỉ tiếp tục dùng cho crypto như hiện tại (không đổi).

## Kiến trúc: cần backend proxy lần đầu tiên trong dự án

Mọi nguồn dùng được ở trên (Twelve Data, SSI) đều cần API key — không thể
nhúng thẳng vào APK (khác với CoinGecko). Dùng **Supabase Edge Functions**
(đã có sẵn project Supabase, không cần dựng hạ tầng mới) làm lớp proxy giữ
key phía server: `stocks-intl` (Phase 1, Twelve Data), `stocks-vn` (Phase 2,
SSI FastConnect). Xem quy trình gọi chi tiết trong
`.claude/skills/wealth-data-sync/SKILL.md`.

Không thêm package Flutter mới — `supabase_flutter` đã có sẵn hỗ trợ
`functions.invoke()`.

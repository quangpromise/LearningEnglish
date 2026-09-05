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

**Setup bắt buộc (dễ quên — đã từng bị bỏ sót khiến toàn bộ giá cổ phiếu quốc
tế không load được):**
1. Đăng ký tài khoản free tại twelvedata.com, lấy API key ở Dashboard.
2. Set secret trên Supabase: `supabase secrets set TWELVE_DATA_API_KEY=<key>
   --project-ref pbvxnzsquqycweyjjnis` (Edge Function `stocks-intl` đọc qua
   `Deno.env.get("TWELVE_DATA_API_KEY")`, KHÔNG hoạt động nếu thiếu bước
   này — trả lỗi 500 "Thiếu TWELVE_DATA_API_KEY trên server").
3. Deploy function: `supabase functions deploy stocks-intl --project-ref
   pbvxnzsquqycweyjjnis --use-api`.

**Giới hạn cứng đã xác nhận qua test thực tế:** free tier chỉ cho **8 API
credit/phút**, và 1 lần gọi `/quote` theo batch (nhiều mã cách nhau bằng
dấu phẩy) tốn **1 credit/mã trong batch đó** — gọi 1 lần với 40 mã sẽ bị từ
chối toàn bộ (lỗi 429 "run out of API credits"), khiến cả batch trả về mảng
RỖNG chứ không phải lỗi riêng từng mã. Vì vậy mọi nơi gọi
`stocksIntlQuotesProvider` với danh sách mã KHÔNG do người dùng tự chọn
(vd toàn bộ danh sách xStocks trong picker khi chưa gõ tìm kiếm) phải giới
hạn tối đa **8 mã/lần gọi** (xem `stock_picker_sheet.dart`
`_IntlResults` — `filtered.take(8)`).

## Việt Nam: đã triển khai — API công khai của chính HOSE (`api.hsx.vn`)

| Nguồn | Chính thức? | Cần đăng ký? | Thương mại (redistribute) | Độ trễ |
|---|---|---|---|---|
| **API công khai của HOSE** (`api.hsx.vn`, đã dùng) | Là API nội bộ của chính Sở GDCK, không có tài liệu công khai (reverse-engineer từ bundle JS của `rtboard.hsx.vn`) nhưng do HOSE tự vận hành và phơi bày công khai cho bất kỳ ai xem bảng giá của họ | Không cần | Không tìm thấy ToS nào cấm — đây là dữ liệu công bố của cơ quan quản lý thị trường, khác hẳn sản phẩm dữ liệu thương mại tư nhân | Giá khớp lệnh/đóng cửa gần nhất (không phải real-time chuẩn giao dịch qua WebSocket riêng — xem bên dưới) |
| SSI FastConnect Data | Có, tài liệu API đầy đủ | Cần đăng ký offline (CCCD) | **ToS mặc định cấm cung cấp lại cho bên thứ ba** — cần xin phép riêng bằng văn bản | Realtime nếu được cấp quyền |
| vnstock (Python, wrap TCBS/VCI/MSN) | Không, reverse-engineer nhiều lớp | Không cần | **License chính thư viện cấm thương mại rõ ràng** | Không đảm bảo |
| Vietstock | Không | Không cần | **Quy định cấm thương mại tường minh** | Delay 15-20 phút |
| cafef.vn, VNDirect | Không, reverse-engineer | Không cần | Không có ToS cho phép, rủi ro tương tự vnstock | Gần real-time, không đảm bảo |
| Yahoo Finance / TradingView / Investing.com | Không (data thật nhưng license lại) | — | **Cấm thương mại tường minh ở cả 3** | Delayed |
| iTick (blog.itick.org) | Có vẻ là dịch vụ thật nhưng ít uy tín/review | Cần key, free tier vô dụng (5 call/phút, chỉ EOD) | **ToS cấm redistribute mặc định, như SSI** nhưng công ty kém minh bạch hơn | Trả phí mới có realtime ($79+/tháng) |
| Simplize.vn | Không, chỉ web/app hiển thị (fintech phân tích cổ phiếu tư nhân, không phải nguồn dữ liệu gốc) | Không cần key nhưng phải scrape/reverse-engineer | **ToS cấm rõ bằng văn bản** việc sao chép/phân phối/tạo sản phẩm phái sinh, chủ động dò IP để chặn lấy dữ liệu hàng loạt | Không công bố rõ độ trễ/nguồn gốc | **Không dùng** — rủi ro pháp lý + kỹ thuật đều cao hơn api.hsx.vn |
| FiinTrade/FiinGroup | Có, B2B | Hợp đồng thương mại, không có free tier | Có, đúng mô hình cho redistribute | Realtime (gói cao cấp) |

**Quyết định cuối (đã triển khai, xem `supabase/functions/stocks-vn`):** dùng
thẳng API công khai của HOSE (`https://api.hsx.vn/l/api/v1/securities/load-securities-matching/0`)
qua Edge Function proxy — tìm được bằng cách phân tích bundle JS của chính
trang bảng giá chính thức `rtboard.hsx.vn` (trang này gọi thẳng API đó từ
trình duyệt người dùng, không cần đăng nhập/key). Đây là lựa chọn rủi ro
pháp lý thấp nhất trong tất cả nguồn đã khảo sát vì là dữ liệu công bố trực
tiếp của cơ quan quản lý thị trường, không phải sản phẩm thương mại tư nhân
có ToS cấm redistribute. Nhược điểm: không có tài liệu API chính thức (có
thể đổi/ngừng bất kỳ lúc nào), và giá trả về là "giá khớp lệnh gần nhất"
(field `accumulatedPrice`), không phải real-time chuẩn giao dịch — đã ghi
rõ trong comment code + UI (`wealth_market_stocks_vn_note`).

### VN-Index (điểm số tổng) — CHƯA làm, để sau

HOSE chỉ phát điểm VN-Index/VN30 qua kênh WebSocket/SignalR riêng
(`wss://api.hsx.vn/hub/mddsnotificationhub`, target `ChartIndexVNINDEX`),
KHÔNG có REST đơn giản. Đã xác nhận bằng test thực tế: kết nối bắt buộc
phải có header `Origin: https://rtboard.hsx.vn` thì HOSE mới chấp nhận
handshake — nhưng `WebSocket` chuẩn (dùng trong Deno/Supabase Edge Function)
không cho phép code tự đặt header này (giới hạn bảo mật chuẩn WHATWG, giống
trình duyệt). Muốn lấy được số này cần tự viết tay toàn bộ handshake
WebSocket trên raw TCP/TLS trong Edge Function (mở kết nối thô, tự soạn
HTTP Upgrade request kèm header Origin, tự giải khung dữ liệu) — phức tạp
và dễ vỡ hơn hẳn mọi Edge Function hiện có trong dự án (đều chỉ dùng `fetch`
REST đơn giản). Quyết định: triển khai giá cổ phiếu trước (đã xong), để
VN-Index lại làm sau nếu thực sự cần.

## OKX cho "Quốc tế" trong Market > Chứng khoán — dùng CÓ ĐIỀU KIỆN (đã đổi quyết định)

OKX không có API dữ liệu chứng khoán thật. Cái OKX (và Bybit, Binance qua
đối tác, Bitget, MEXC) có là **Tokenized Stocks** (xStocks/Backed Finance,
mã dạng `X{TICKER}-USDT` vd XAAPL-USDT, XTSLA-USDT — đã xác nhận qua API
thực tế có ~80+ mã, không chỉ ~40 như ước tính ban đầu) — token on-chain mô
phỏng giá, giao dịch như 1 cặp spot crypto thông thường, KHÔNG PHẢI giá
khớp lệnh thật từ NASDAQ/NYSE, có thể lệch giá do cung-cầu/thanh khoản
riêng của token.

**Quyết định ban đầu (khi mới có tính năng Market Chứng khoán)** là không
dùng, vì rủi ro trình bày token như giá cổ phiếu thật. **Sau đó người dùng
yêu cầu rõ ràng dùng OKX cho toàn bộ "International Stocks"** (thay cho
danh sách 8 mã cố định qua Twelve Data, quota quá thấp để lấy "tất cả" như
crypto) — đã đồng ý VỚI ĐIỀU KIỆN ghi chú rõ ràng trong UI rằng đây là giá
token mô phỏng, không phải giá cổ phiếu thật (xem
`wealth_market_stocks_okx_note` trong `app_strings.dart` và
`market_stocks_tab.dart`). Không có khái niệm vốn hóa thị trường chính thức
cho token này nên sắp xếp theo **thanh khoản (volume) 24h giảm dần** làm
proxy, không phải vốn hóa thật — đã ghi rõ trong code
(`OkxService.fetchTokenizedStocks`).

Portfolio thực (Wallet > Tài sản đầu tư > Cổ phiếu, `stock_portfolio_screen.dart`)
VẪN dùng Twelve Data (giá thật) — quyết định này CHỈ áp dụng cho màn Market
(xem giá tham khảo/theo dõi), nơi độ phủ rộng quan trọng hơn độ chính xác
tuyệt đối, và đã có disclaimer rõ ràng.

## Kiến trúc: cần backend proxy lần đầu tiên trong dự án

Mọi nguồn dùng được ở trên (Twelve Data, SSI) đều cần API key — không thể
nhúng thẳng vào APK (khác với CoinGecko). Dùng **Supabase Edge Functions**
(đã có sẵn project Supabase, không cần dựng hạ tầng mới) làm lớp proxy giữ
key phía server: `stocks-intl` (Phase 1, Twelve Data), `stocks-vn` (Phase 2,
SSI FastConnect). Xem quy trình gọi chi tiết trong
`.claude/skills/wealth-data-sync/SKILL.md`.

Không thêm package Flutter mới — `supabase_flutter` đã có sẵn hỗ trợ
`functions.invoke()`.

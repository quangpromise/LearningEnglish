---
name: wealth-data-sync
description: Quy trình gọi Edge Function proxy lấy giá cổ phiếu (quốc tế qua Twelve Data, Việt Nam qua API công khai của HOSE) cho tính năng Quản lý tài sản, và checklist xác minh trước khi thêm 1 nguồn dữ liệu tài chính mới.
---

# Quy trình đồng bộ dữ liệu tài chính (Wealth Management)

## Khi nào dùng
- Khi cần lấy giá cổ phiếu quốc tế/Việt Nam hiện tại cho tab Đầu tư (`wealth_investments_tab.dart`).
- Khi cần thêm 1 nguồn dữ liệu tài chính mới (mã mới, sàn mới, nhà cung cấp API mới) — chạy checklist bên dưới TRƯỚC khi tích hợp, tốt nhất nhờ agent `finance-api-researcher` kiểm tra kỹ trước.

## Vì sao phải qua Edge Function (khác với crypto)

Crypto gọi thẳng CoinGecko từ Flutter client vì endpoint không cần key (xem
`docs/research-crypto-api.md`). Chứng khoán thì KHÔNG — mọi nguồn dùng được
(Twelve Data, SSI FastConnect) đều cần API key/token. Nhúng thẳng key này
vào APK sẽ bị trích xuất/lạm dụng, nên toàn bộ request phải đi qua Supabase
Edge Function (giữ key trong Supabase secret, không bao giờ trả về client).

## Cách gọi Edge Function `stocks-intl` (Phase 1)

Từ Flutter (đã có sẵn `supabase_flutter`, không cần thêm package):

```dart
final res = await supabase.functions.invoke(
  'stocks-intl',
  queryParameters: {'symbols': 'AAPL,TSLA'},
);
// res.data: List các { symbol, price, changePercent, currency }
```

Test trực tiếp Edge Function khi phát triển local:

```bash
supabase functions serve stocks-intl
curl "http://localhost:54321/functions/v1/stocks-intl?symbols=AAPL,TSLA"
```

Function cache kết quả trong bộ nhớ vài phút (tránh tốn quota free tier
800 call/ngày của Twelve Data) — không polling liên tục từ UI, chỉ fetch khi
người dùng mở tab Đầu tư hoặc bấm refresh thủ công.

## Edge Function `stocks-vn` (đã triển khai — API công khai của HOSE)

Không dùng SSI FastConnect (ToS mặc định cấm redistribute cho bên thứ ba) —
dùng thẳng API công khai `api.hsx.vn` mà chính trang bảng giá chính thức
`rtboard.hsx.vn` của HOSE gọi từ trình duyệt, không cần key. Xem lý do chọn
đầy đủ trong `docs/research-wealth-stock-apis.md`.

```dart
final res = await supabase.functions.invoke(
  'stocks-vn',
  queryParameters: {'symbols': 'VNM,VIC,FPT'},
);
// res.data: List các { symbol, price, changePercent, currency: 'VND' } -
// price la gia khop lenh/dong cua GAN NHAT, KHONG phai real-time chuan
// giao dich.
```

Test local:

```bash
supabase functions serve stocks-vn
curl "http://localhost:54321/functions/v1/stocks-vn?symbols=VNM,VIC,FPT"
```

**VN-Index (điểm số) chưa làm** — HOSE chỉ phát số này qua WebSocket/SignalR
riêng (`wss://api.hsx.vn/hub/mddsnotificationhub`, cần header `Origin` mà
`WebSocket` chuẩn của Deno không cho đặt được) — phức tạp hơn nhiều so với
REST, xem chi tiết trong `docs/research-wealth-stock-apis.md`.

## Checklist xác minh trước khi thêm 1 nguồn/mã dữ liệu mới

1. Nguồn có cần API key không? Nếu có → phải đi qua Edge Function, không
   được gọi thẳng từ client.
2. Free tier (nếu có) có cấm dùng thương mại không? Đọc kỹ điều khoản, đừng
   suy diễn.
3. Đây có phải giá thị trường THẬT không, hay là sản phẩm phái sinh/tokenized
   (vd Tokenized Stocks trên sàn crypto)? Không hiển thị loại thứ 2 như giá
   cổ phiếu thật.
4. Độ trễ dữ liệu là bao nhiêu — có cần ghi chú "delayed 15 phút" trên UI
   không?
5. Ghi lại quyết định vào `docs/research-wealth-*.md` (mẫu:
   `docs/research-wealth-stock-apis.md`), kèm lý do chọn/loại bỏ.

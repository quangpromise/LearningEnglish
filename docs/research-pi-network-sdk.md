# Nghiên cứu tích hợp Pi Network SDK (nếu build app sang Web)

Câu hỏi đặt ra: nếu build app này sang Flutter Web, có kết nối được Pi SDK
(https://minepi.com/developers/) không?

## Kết luận

**Có thể nhúng SDK về mặt kỹ thuật, nhưng SDK chỉ thực sự hoạt động khi
trang được mở TRONG Pi Browser** (trình duyệt riêng nằm trong app Pi Network) —
**không dùng được như 1 website công khai truy cập tự do bằng Chrome/Safari
thường**. Nếu mục tiêu là phục vụ người dùng web thông thường thì hướng này
không khả thi; nếu mục tiêu là làm 1 "Pi App" phục vụ riêng cộng đồng Pi
Network (mở qua Pi Browser) thì làm được.

## Cách Pi SDK hoạt động

- SDK thuần JavaScript phía trình duyệt (`https://sdk.minepi.com/pi-sdk.js`),
  **không có bản server-side (Node.js)** — chỉ chạy trên client.
- Nhúng bằng thẻ script:
  ```html
  <script src="https://sdk.minepi.com/pi-sdk.js"></script>
  <script>Pi.init({ version: "2.0" })</script>
  ```
- `Pi.authenticate(scopes, onIncompletePaymentFound)` để đăng nhập (yêu cầu
  khai báo scope như `['payments']`, có callback bắt buộc xử lý thanh toán dở
  dang), `Pi.createPayment(...)` để tạo giao dịch thanh toán bằng Pi coin.
- Luồng thanh toán hoàn chỉnh (approve/complete payment) vẫn cần 1 backend
  riêng gọi Pi Platform API bằng server API key — giống mô hình
  client + backend proxy đã dùng cho các tính năng khác trong app này (Gemini
  Live, Twelve Data...).

## Ràng buộc quan trọng nhất — bắt buộc chạy trong Pi Browser

- Tài liệu chính thức (`pi-apps/pi-platform-docs` trên GitHub) ghi rõ SDK
  "designed to be used in your HTML pages or Single-Page Apps, **served in
  the Pi Browser**" — tức là thiết kế để chạy trong trình duyệt riêng của app
  Pi Network, nơi người dùng đã đăng nhập sẵn tài khoản Pi/ví Pi.
- Đăng ký app cũng bắt buộc qua Developer Portal (`develop.pi`), và trang này
  **chỉ mở được từ trong Pi Browser**, không mở được bằng trình duyệt thường.
- Hệ quả: mở trang bằng Chrome/Safari/Edge bình thường thì `Pi.init()` vẫn
  load được SDK (không lỗi), nhưng `Pi.authenticate()` sẽ không có phiên đăng
  nhập Pi nào để xác thực — về cơ bản tính năng đăng nhập/thanh toán không
  chạy được ngoài Pi Browser.

## Áp vào Flutter Web của app này

- Flutter Web build ra `index.html` + JS/Wasm — hoàn toàn nhúng được thẻ
  script SDK vào `web/index.html`, gọi `window.Pi.init()`/`authenticate()`/
  `createPayment()` qua `dart:js_interop` (hoặc `package:js`). Không có rào
  cản kỹ thuật từ phía Flutter.
- Nhưng vì ràng buộc ở trên, bản Flutter Web tích hợp Pi SDK **chỉ dùng được
  cho người dùng mở qua Pi Browser** — không thể thay thế/mở rộng cho người
  dùng web thông thường của app.
- Rủi ro phụ cần test thực tế trước khi cam kết: Pi Browser là 1 WebView
  nhúng trong app Pi Network (không phải trình duyệt đầy đủ) — renderer
  CanvasKit/Skwasm mặc định của Flutter Web hiện đại có thể gặp vấn đề tương
  thích trên WebView cũ/thiết bị cấu hình thấp.

## Nguồn tham khảo

- https://minepi.com/developers/ — trang tổng quan, không có chi tiết kỹ
  thuật tích hợp.
- https://github.com/pi-apps/pi-platform-docs — tài liệu kỹ thuật SDK
  (script tag, `Pi.init`/`Pi.authenticate`, yêu cầu chạy trong Pi Browser,
  đăng ký app qua `develop.pi`).

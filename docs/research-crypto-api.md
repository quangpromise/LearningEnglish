# Nghiên cứu API giá Crypto (tính năng Crypto trong Menu)

Tính năng độc lập với phần học tiếng Anh, hiển thị bảng xếp hạng top 100 coin theo vốn hoá, bỏ vào Menu cho tiện dùng chung 1 app (tương tự lý do gộp tính năng Tập luyện trước đây).

## Lựa chọn: CoinGecko `/coins/markets`

- **Miễn phí, không cần đăng ký/API key** cho endpoint public `https://api.coingecko.com/api/v3/coins/markets` — gọi thẳng từ app (client), không cần backend trung gian.
- Trả đủ dữ liệu cần cho bảng xếp hạng: rank, tên, ký hiệu, ảnh logo, giá USD, % thay đổi 24h, vốn hoá.
- Rate limit free tier đủ dùng cho việc người dùng tự bấm refresh/mở màn hình (không polling liên tục).

## Vì sao không dùng CoinMarketCap

CoinMarketCap yêu cầu đăng ký lấy **API key riêng cho từng ứng dụng** để gọi API chính thức của họ — không phù hợp gọi thẳng từ client (APK) vì key sẽ bị lộ trong app; muốn dùng an toàn phải có backend riêng giữ key, tốn thêm hạ tầng cho 1 tính năng phụ. Scrape trực tiếp trang web coinmarketcap.com vi phạm điều khoản sử dụng của họ nên không dùng.

Không thêm package mới vào `pubspec.yaml` — dùng lại `http` đã có sẵn trong dự án.

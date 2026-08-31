# Nghiên cứu nguồn sticker mascot (kiểu Zalo/LINE) cho chat trong app

## Bối cảnh

App hiện dùng **GIPHY Stickers API** (`sticker_repository.dart`, endpoint
`/v1/stickers/trending` và `/v1/stickers/search`) làm nguồn sticker cho tính
năng chat. Người dùng thấy bộ sticker "Chồn Mặt Lầy" của Zalo (1 nhân vật
mascot nhất quán, nhiều biểu cảm, chất lượng vẽ tay chuyên nghiệp) và hỏi có
API nào cho ra trải nghiệm tương tự không.

**Không thể tái tạo đúng bộ đó** — đây là nhân vật do Zalo thuê hoạ sĩ vẽ
riêng và giữ độc quyền IP, không có API/license nào cấp lại hợp pháp cho app
khác dùng.

## Bảng so sánh các lựa chọn thay thế

| Nguồn | License thương mại | Cần ghi công? | API hay asset tĩnh | Phong cách/chất lượng | Rủi ro pháp lý |
|---|---|---|---|---|---|
| **GIPHY Stickers API** (đang dùng) | Free tier (beta key, 100 req/giờ) cho dev/test; production key không giới hạn phải đàm phán giá riêng với GIPHY sales khi app scale lên | Bắt buộc hiển thị "Powered by GIPHY" | API (search/trending) | Tạp nham — hàng nghìn artist khác nhau, phong cách không đồng nhất | Thấp ở mức beta key |
| **Tenor API** | — | — | — | — | **Đã đóng cửa vĩnh viễn 30/6/2026** — không dùng được nữa |
| **Sticker.ly (NAVER Z)** | Không có API chính thức cho bên thứ ba — chỉ có bản reverse-engineer không được phép trên GitHub | N/A | Không chính thức, vi phạm ToS nếu dùng trong app thương mại | Tốt (nhiều pack mascot nhất quán) | **Cao** — không nên dùng |
| **Stipop** | Có API/SDK, thư viện >150.000 sticker. Free cho sticker miễn phí (không chia doanh thu); sticker trả phí thì chia doanh thu với artist | Thường không bắt buộc | **API/SDK** (có Android SDK sẵn) | Nhiều pack mascot nhất quán, định vị đúng phân khúc "sticker chat app", gần Zalo/LINE hơn GIPHY | Trung bình — pricing/điều khoản chi tiết chưa công khai đầy đủ, cần liên hệ trực tiếp (webmaster@stipop.io) xác nhận bằng văn bản trước khi tích hợp, đặc biệt là điều khoản cho app phát hành ngoài Play Store |
| **Kenney.nl – Emotes Pack** | **CC0 1.0** — miễn phí tuyệt đối, không cần ghi công | Không | Asset tĩnh, tự host | Phong cách emoji/icon phẳng, không phải 1 nhân vật mascot xuyên suốt | Không — CC0 rõ ràng nhất |
| **itch.io asset packs** (vd. "Chibi Anime Stickers & Emotes 500+") | Thay đổi theo từng tác giả (CC0/CC-BY/"free for commercial"/NC) — phải đọc từng trang riêng lẻ | Tuỳ tác giả | Asset tĩnh, tự host | Có pack tốt, đúng tinh thần "1 nhân vật × nhiều cảm xúc" | Trung bình — phải verify license từng pack thủ công (giống quy trình đã áp dụng với nhạc) |
| **OpenMoji** | CC BY-SA 4.0 | Bắt buộc ghi công + derivative giữ cùng license | Asset tĩnh | Emoji phẳng nhất quán, không phải nhân vật mascot có tên riêng | Thấp, có ràng buộc share-alike |
| **Twemoji / Blobmoji** | Twemoji: CC-BY 4.0; Blobmoji: Apache 2.0 | Twemoji cần ghi công | Asset tĩnh | Bộ emoji, không phải mascot | Thấp |

## Đánh giá nhanh từng câu hỏi

- **GIPHY có tune giống Zalo hơn được không?** Chỉ tinh chỉnh UX (tab/từ khoá
  cố định như "kawaii", "chibi") chứ không tái tạo được cảm giác "1 con vật
  quen thuộc lặp lại nhiều cảm xúc" vì đây là kho tổng hợp từ hàng nghìn
  artist riêng lẻ.
- **Tenor**: đã chết, loại khỏi mọi cân nhắc.
- **Sticker.ly**: không có API chính thức, loại vì rủi ro pháp lý.
- **Stipop**: lựa chọn đáng chú ý nhất nếu muốn có API thật sự cho phong cách
  gần Zalo — nhưng bắt buộc phải tự liên hệ xin xác nhận điều khoản bằng văn
  bản trước khi tích hợp sâu (không suy diễn từ trang marketing).
- **Asset tĩnh CC0/CC-BY**: hướng an toàn nhất nếu muốn có bộ mascot riêng
  của app, không phụ thuộc dịch vụ ngoài, không lo bị sập như Tenor — đổi lại
  mất khả năng tìm kiếm linh hoạt như API.

## Khuyến nghị

1. **Giữ GIPHY** làm nguồn chính hiện tại — không cần thay đổi ngay.
2. Nếu muốn phong cách "mascot nhất quán" hơn: **liên hệ Stipop trước**
   (webmaster@stipop.io) xin xác nhận điều khoản, rồi mới tích hợp làm nguồn
   thứ 2 song song với GIPHY (kiến trúc feature-first hiện có cho phép thêm
   1 implementation khác của cùng interface trong `sticker_repository.dart`
   mà không phải viết lại UI).
3. Nếu muốn có **1 bộ mascot "signature" riêng của app** không phụ thuộc
   dịch vụ ngoài: chọn lọc thủ công 1-2 pack CC0 trên itch.io kiểu
   "chibi × nhiều emotion", tự host làm asset tĩnh, lưu `ATTRIBUTION.md` nếu
   là CC-BY — đúng quy trình đã áp dụng với nhạc (xem
   `docs/research-music-libraries.md`).

## Nguồn tham khảo

- https://support.giphy.com/hc/en-us/articles/10389869671322-Is-there-a-fee-for-using-GIPHY-s-API
- https://support.giphy.com/hc/en-us/articles/360035158592-What-conditions-does-my-app-project-need-to-meet-in-order-to-get-a-production-API-Key
- https://engineering.giphy.com/new-stickers-api-available/
- https://giphy.com/stickers/packs/kawaii
- https://github.com/theabbie/sticker.ly (unofficial, KHÔNG dùng)
- https://stipop.io/ , https://stipop.io/en/products , https://stipop.io/pricing
- https://github.com/stipop-development/stipop-android-sdk
- https://studio.stipop.io/policies , https://studio.stipop.io/guidelines
- https://kenney.nl/assets/emotes-pack
- https://itch.io/game-assets/tag-emotes
- https://itch.io/game-assets/assets-cc0/tag-characters
- https://itch.io/blog/929708/general-paid-asset-license
- https://github.com/hfg-gmuend/openmoji , https://openmoji.org/faq/

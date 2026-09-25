# Nội dung học sinh offline thành Content Pack, không sinh bằng AI lúc chạy app

Practice Item cho lộ trình A1–C1 được sinh bằng một pipeline Python chạy offline từ các Content Source đã xác minh license thương mại (CEFR-J, NGSL/NAWL, Tatoeba, Open English WordNet), rồi đóng gói thành JSON trong app. Làm vậy vì Rest Game phải chạy được offline trong phòng gym, trả lời ngay trong vài giây, và mọi câu hỏi phải duyệt được trước khi phát hành. Mỗi Content Source ghi rõ license và provenance; nguồn share-alike (NGSL/NAWL, CC BY-SA 4.0) để trong file dữ liệu riêng, giữ đúng giấy phép và ghi công trong `ATTRIBUTION.md`. Không dùng Oxford 3000/5000, English Vocabulary Profile, AWL hay các bộ đề/essay IELTS không có license.

## Considered Options

- Sinh câu hỏi bằng Gemini lúc chạy app: bị loại vì cần mạng, có độ trễ, tốn chi phí và không kiểm soát được chất lượng hay nguồn gốc.

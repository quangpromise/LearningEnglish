---
name: grammar-check
description: Quy trình gọi LanguageTool để chấm lỗi ngữ pháp câu trong lyric hoặc câu người dùng luyện tập, dùng cho tính năng Grammar trong app.
---

# Quy trình kiểm tra ngữ pháp bằng LanguageTool

## Khi nào dùng
- Khi soạn nội dung giải thích ngữ pháp cho 1 câu lyric mới (màn `grammar_screen.dart`) — kiểm tra câu gốc không có lỗi trước khi đưa vào app.
- Khi cần chấm câu người dùng tự viết trong bài tập (nếu tính năng này được thêm sau).

## Cách gọi
LanguageTool có REST API công khai (miễn phí, giới hạn rate) hoặc tự host server riêng (mã nguồn mở, LGPL 2.1+):

```bash
curl -X POST 'https://api.languagetool.org/v2/check' \
  --data-urlencode 'text=She is standing in the rain now.' \
  --data-urlencode 'language=en-US'
```

Response trả về danh sách `matches` — mỗi lỗi kèm vị trí, thông điệp giải thích, và gợi ý sửa (`replacements`).

## Tự host (khi cần gọi nhiều/không muốn phụ thuộc rate limit public API)
```bash
docker run -d -p 8081:8010 erikvl87/languagetool
```
Sau đó gọi `http://localhost:8081/v2/check` thay vì API công khai.

## Quy trình soạn nội dung ngữ pháp cho 1 câu lyric
1. Lấy câu gốc (EN) từ file `.lrc` của bài hát.
2. Gọi LanguageTool để xác nhận câu không có lỗi ngữ pháp lạ (lyric đôi khi cố ý sai văn phạm vì tính nghệ thuật — cần agent `grammar-researcher` xem xét từng trường hợp thay vì áp dụng máy móc).
3. Xác định điểm ngữ pháp đáng dạy (thì, cấu trúc câu...) — nhờ agent `grammar-researcher` soạn phần giải thích + bài tập.
4. Đưa nội dung vào `GrammarScreen` (hiện đang nhận `LyricLine` qua constructor, xem `app/lib/features/grammar/presentation/grammar_screen.dart`).

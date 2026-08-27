---
name: lyric-sync
description: Quy trình parse file lyric .lrc (có timestamp) và đồng bộ với vị trí phát nhạc để highlight từ/dòng đang hát trong màn Player.
---

# Đồng bộ lyric (.lrc) với nhạc

## Định dạng file .lrc
```
[00:12.30]I used to run from every storm
[00:16.80]Now I'm standing in the rain
[00:20.10]Learning how to feel the warmth
```
Mỗi dòng: `[phút:giây.mili]Nội dung dòng lyric (tiếng Anh)`. Với song ngữ, lưu thêm 1 file `.vi.lrc` cùng timestamp hoặc 1 field `vi` song song trong file dữ liệu bài hát (JSON) — xem cấu trúc `LyricLine` demo trong `app/lib/features/music_player/presentation/player_screen.dart`.

## Quy trình tích hợp thật (thay dữ liệu tĩnh `kLyrics` hiện tại)
1. Parse file `.lrc` bằng regex `\[(\d+):(\d+\.\d+)\](.*)` → danh sách `{timestampMs, text}`.
2. Lưu kèm bản dịch tiếng Việt tương ứng theo từng timestamp (cùng file JSON metadata bài hát, không parse từ `.lrc` gốc vì định dạng .lrc không có chỗ cho 2 ngôn ngữ).
3. Lắng nghe `position` stream của trình phát nhạc (`just_audio`), tìm dòng lyric có `timestampMs` lớn nhất mà vẫn `<= position hiện tại` → đó là dòng đang hát (current line).
4. Cập nhật state (Riverpod provider trong `features/music_player/`) để UI tự re-render dòng đang highlight — logic UI (ShaderMask, opacity mờ dần) đã có sẵn trong `player_screen.dart`, chỉ cần thay nguồn `_currentLine` từ tĩnh sang tính theo `position` thật.

## Lưu ý hiệu năng
Danh sách lyric 1 bài hát thường vài chục dòng — dùng thuật toán tìm kiếm tuyến tính hoặc binary search đơn giản là đủ, không cần tối ưu phức tạp.

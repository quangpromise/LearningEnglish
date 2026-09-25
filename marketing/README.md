# Marketing / video (HyperFrames)

Video và mockup của GymTalk làm bằng [HyperFrames](https://github.com/heygen-com/hyperframes) (Apache-2.0): viết cảnh bằng HTML + GSAP, render ra MP4 bằng Chrome headless + FFmpeg. **Không dùng trong app** – chỉ cho marketing / thiết kế. Trình phát hướng dẫn bài tập trong app dựng trực tiếp bằng Flutter (xem `docs/gymtalk-exercise-tutorial.md`).

| Thư mục | Nội dung | Kết quả |
|---|---|---|
| `gymtalk-promo/` | Video giới thiệu GymTalk, dọc 1080×1920, 28 s, 7 cảnh, giọng đọc tiếng Anh + phụ đề | `out/gymtalk-promo.mp4` |
| `goblet-squat-tutorial/` | Bản thử video hướng dẫn bài Goblet Squat, ngang 1280×720, 45 s (dẫn tới quyết định dựng trình phát trong app) | `out/goblet-squat-tutorial.mp4` |
| `ux-exercise-video-mockup/` | Mockup UI/UX 3 màn: chi tiết bài tập → trình phát dọc → màn kết thúc | `snapshots/frame-00-at-0.5s.png` |

## Nguồn tài nguyên
- Giọng đọc: TTS **Kokoro-82M** chạy trên máy (`npx hyperframes tts`, voice `am_michael`) – model Apache-2.0.
- Hình: logo và ảnh động tác có sẵn trong `app/assets` (đã xác nhận quyền sử dụng). **Không có nhạc nền** (quy định bản quyền nhạc trong CLAUDE.md).
- Font: Space Grotesk + Manrope (Google Fonts, OFL).

## Chạy lại
Cần Node 22+, FFmpeg. Trong từng thư mục:
```bash
npx hyperframes@0.8.74 check                 # lint + runtime + layout + tương phản
npx hyperframes@0.8.74 snapshot --at 1,5,10  # chụp vài khung để xem nhanh
npx hyperframes@0.8.74 render -o out/video.mp4
```
Tạo lại giọng đọc: `npx hyperframes@0.8.74 tts "câu tiếng Anh" -v am_michael -o assets/vo/lineN.wav`.

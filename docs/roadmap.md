# Roadmap

## Giai đoạn 1 — MVP (đã code khung UI + tính năng cơ bản)
- [x] Trang chủ chọn bài hát (`features/music_player/home_screen.dart`)
- [x] Nghe nhạc + lyric song ngữ đồng bộ theo dòng, chạm từ xem nghĩa (`player_screen.dart`, `word_popup_sheet.dart`)
- [x] Luyện phát âm bằng mic, chấm điểm so khớp văn bản (`pronunciation_screen.dart`)
- [x] Giải thích ngữ pháp cho câu trong lyric (`grammar_screen.dart`)
- [x] Đố vui tiếng Anh + bảng xếp hạng (`features/quiz/`)
- [x] Hồ sơ/thống kê tiến độ (`profile_screen.dart`)
- [ ] Thay dữ liệu mẫu (song, dictionary) bằng nhạc CC0/CC-BY thật đã tải theo `docs/research-music-libraries.md`
- [ ] Build APK release ký sẵn, host & hướng dẫn sideload (xem `.claude/skills/apk-release`)

## Giai đoạn 2
- [ ] Tích hợp `google_mlkit_translation` thật (thay từ điển demo trong `word_popup_sheet.dart`)
- [ ] `just_audio` phát nhạc thật đồng bộ với lyric `.lrc`
- [ ] Nâng cấp chấm phát âm: cân nhắc Azure Pronunciation Assessment cho câu luyện cụ thể (xem `docs/research-pronunciation.md`)
- [ ] Dựng backend thật cho AI Voice Chat (`backend/gemini-proxy` + `backend/fallback-pipeline`, xem `docs/research-ai-voice.md`)

## Giai đoạn 3
- [ ] Tối ưu UX, thêm nhiều bài hát, cải thiện chấm phát âm
- [ ] Lưu tiến độ người dùng thật (hiện tại Profile/Leaderboard dùng dữ liệu tĩnh)

## Giai đoạn 4 — App Store
- [ ] Tài khoản Apple Developer, cấu hình ký iOS, tuân thủ App Store Review Guidelines (đặc biệt quyền mic)

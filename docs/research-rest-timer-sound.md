# Nghiên cứu: âm báo hết giờ nghỉ giữa hiệp (Rest timer) — GymTalk

> Issue: quangpromise/LearningEnglish#131 · Ngày nghiên cứu: 2026-10-02 · Người thực hiện: library-researcher
>
> **Đã chốt (2026-10-02, chủ repo chọn sau khi nghe thử):**
> - Hết giờ nghỉ dùng **#3 "Pleasing Bell"** (Spring Spring, OpenGameArt, CC0).
> - 3-2-1 dùng **tiếng gõ mõ VCSL `wood_click_pp_rr1.wav`** (CC0).
>
> File trong app: `app/assets/audio/rest_end_bell.wav` và `rest_tick.wav`. Tạo lại bằng `python scripts/make_rest_sounds.py`; script kiểm sha256 file gốc.
>
> Ghi công tự nguyện ở `ATTRIBUTION.md`. Cách phát xem §5.

## 0. Bối cảnh & tiêu chí

- **Hiện trạng:** `_onRestElapsed()` trong `app/lib/features/fitness/presentation/workout_session_screen.dart` gọi `GtHaptics.play(GtHapticEvent.restEnded)` rồi `SystemSound.play(SystemSoundType.alert)`. Lệnh này không phát ra tiếng gì trên điện thoại.
- **Âm cần tìm:**
  - dài 0,3–1,5 s, attack sạch;
  - dễ chịu nhưng nghe rõ giữa tiếng ồn phòng gym, khi điện thoại đặt trên ghế cách khoảng 1 m;
  - không phải còi báo động;
  - kiểu "ding", chuông, chime, hoặc 2–3 nốt đi lên báo "xong".
  - Điểm cộng: có kèm 1 tiếng tick nhẹ cùng tông để đếm ngược 3-2-1.
- **Giấy phép:**
  - Ưu tiên CC0. Chấp nhận CC BY 4.0, khi đó thêm một mục vào `ATTRIBUTION.md`.
  - Phải cho phép dùng thương mại, chỉnh sửa, và phân phối kèm trong APK/IPA.
  - Loại: NC, ND, Sampling+; giấy phép trả phí hoặc gắn với tài khoản; điều khoản "no standalone" mà không nói rõ là được nhúng làm âm UI.
  - Theo quy tắc dự án: **không Pixabay, không Jamendo**.
- **Nguồn gốc:** người đăng phải chính là người thu âm hoặc tổng hợp ra âm đó. Loại mọi âm lấy từ điện thoại, thiết bị, game, hay thư viện thương mại.
- **Cách kiểm tra:**
  - Đọc giấy phép ngay trên trang gốc: trang sound của Freesound, trang asset của kenney.nl kèm `License.txt` trong pack, file `LICENSE` trong repo VCSL, hoặc trang OpenGameArt do chính tác giả đăng.
  - **Không tải file audio hay zip nào.** Vì vậy chưa nghe thử. Mọi nhận xét về âm sắc đều dựa trên mô tả, tag và thời lượng do nguồn công bố.
  - Thời lượng có dấu "≈" là ước tính từ dung lượng file.

## 1. Kết luận nhanh

*Bảng dưới là khuyến nghị lúc nghiên cứu. Lựa chọn cuối cùng ở đầu trang: #3 cho âm hết giờ, VCSL woodblock cho tick.*

| Vai trò | Chọn | Giấy phép | Ghi công |
|---|---|---|---|
| **Âm hết giờ nghỉ** | **"bell ding 1.wav" — 5ro4 (Alva Majo), Freesound #611113.** Cắt còn khoảng 1,2–1,4 s, thêm fade-out, trộn về mono, chuẩn hoá đỉnh −1 dBFS, xuất WAV | CC0 1.0 | Không bắt buộc |
| **Tick đếm ngược 3-2-1** (bonus) | **VCSL Woodblock `wood_click_pp_rr1.wav`** (Versilian Studios). Phương án nhẹ hơn: Kenney `tick_00x` | CC0 1.0 | Không bắt buộc |
| **Phương án B** (nếu muốn 2 nốt đi lên) | VCSL Glockenspiel C6 → G6 ghép lệch nhau khoảng 130 ms, đi cùng woodblock tick của cùng thư viện | CC0 1.0 | Không bắt buộc |

## 2. Bảng xếp hạng ứng viên

### #1 — "bell ding 1.wav" (5ro4, Freesound #611113) — **KHUYẾN NGHỊ**

- **Trang nghe thử:** https://freesound.org/people/5ro4/sounds/611113/
- **File gốc:** https://freesound.org/people/5ro4/sounds/611113/download/611113__5ro4__bell-ding-1.wav
  - Cần đăng nhập Freesound (miễn phí) mới tải được. Giấy phép không gắn với tài khoản.
  - Pack "Bell dings": https://freesound.org/people/5ro4/packs/33679/
- **Định dạng / thời lượng / dung lượng:** WAV 16-bit, 44,1 kHz, stereo · **2,519 s** · 434,0 KB
- **Giấy phép:**
  - Trang ghi "Creative Commons 0": [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/legalcode)
  - Mô tả của tác giả: *"You can do whatever you want with this sound, no credit required"*
- **Ghi công:** **Không.** Nếu muốn ghi công tự nguyện thì tác giả xin ghi *"Alva Majo or 5ro4"*.
- **Nguồn gốc:** tự thu âm. Mô tả: *"Ding sound of a pet training bell. Recording device: Blue Yeti."*
  - Chuông là vật thật nên không có bản quyền sáng tác đi kèm.
  - Khoảng 10 nghìn lượt tải; 4,6/5 trên 202 lượt đánh giá.
- **Rủi ro / ghi chú:**
  - File dài 2,5 s nên phải cắt và fade.
  - Thu bằng mic USB, cần nghe lại xem có nhiễu nền không.
  - Cùng pack có "bell ding 2" và "bell ding 3" (#611112 và #611111, CC0, 3,5 s) dùng làm biến thể dự phòng.

### #2 — VCSL: Glockenspiel 2 nốt đi lên + Woodblock tick

- **Trang nghe thử / duyệt file:**
  - https://github.com/sgossner/VCSL/tree/master/Idiophones/Struck%20Idiophones/Glockenspiel
  - https://github.com/sgossner/VCSL/tree/master/Idiophones/Struck%20Idiophones/Woodblock
- **File:**
  - Glockenspiel:
    - https://github.com/sgossner/VCSL/blob/master/Idiophones/Struck%20Idiophones/Glockenspiel/glock_medium_C6_01.wav (1.271.310 B)
    - …/glock_medium_G6_01.wav (843.122 B)
    - …/glock_loud_C7_01.wav (464.710 B)
  - Woodblock: https://github.com/sgossner/VCSL/blob/master/Idiophones/Struck%20Idiophones/Woodblock/wood_click_pp_rr1.wav (107.200 B)
- **Định dạng / thời lượng / dung lượng:**
  - WAV không nén (README: 44,1 hoặc 48 kHz, 16 hoặc 24-bit).
  - Thời lượng không công bố. Mẫu glockenspiel dài vài giây nên phải cắt.
  - Có các nốt C4–C7 với 3 lực đánh soft / medium / loud. Riêng nốt G6 không có bản loud.
- **Giấy phép:**
  - [CC0 1.0](https://github.com/sgossner/VCSL/blob/master/LICENSE): file `LICENSE` trong repo là toàn văn CC0 1.0.
  - README: *"This collection is under a Creative Commons 0 license. Essentially it's Public Domain- you can do whatever you want with these sounds (even make commercial software), no royalties, no credit, no special terms."*
- **Ghi công:** **Không.**
- **Nguồn gốc:** thư viện sample do chính nhà làm thu âm.
  - README ghi "created by Versilian Studios LLC".
  - Repo của Sam Gossner, hồ sơ GitHub: "Sample library developer", Versilian Studios LLC.
- **Rủi ro / ghi chú:**
  - Phải tự ghép 2 nốt rồi cắt, fade, chuẩn hoá, mất khoảng 15–30 phút và cần nghe thử.
  - Trang chính thức vis.versilstudios.com đang lỗi chứng chỉ hết hạn, nên đã kiểm tra bằng file `LICENSE`/README trong repo của chính tác giả.
  - Có thể chỉ dùng 1 nốt `glock_loud_C7_01` để có tiếng "ding" đơn.

### #3 — "Pleasing Bell Sound Effect" (Spring Spring, OpenGameArt)

- **Trang nghe thử:** https://opengameart.org/content/pleasing-bell-sound-effect
- **File:** https://opengameart.org/sites/default/files/pleasing-bell.wav
- **Định dạng / thời lượng / dung lượng:** WAV · ≈0,6–1,3 s (OGA không ghi thời lượng) · 109,4 KB
- **Giấy phép:** trang OGA ghi [CC0](https://creativecommons.org/publicdomain/zero/1.0/legalcode).
- **Ghi công:** **Không bắt buộc.**
  - Mục Copyright/Attribution Notice ghi: *"Produced by Julie Damsgaard/Spring Spring/Spring Enterprises @ https://spring-enterprises.neocities.org"*. Nên ghi công tự nguyện theo đúng câu này.
- **Nguồn gốc:** chính tác giả đăng (đăng ngày 14/07/2018). Đây là người đóng góp lâu năm trên OGA (nhạc, đồ hoạ, SFX). Đã được dùng trong một game mobile (Bouncy Bird).
- **Rủi ro / ghi chú:**
  - Không ghi cách tạo. Có tag "vibraphone" nên có thể được render từ một nhạc cụ ảo (VST); rủi ro thấp–vừa.
  - Tiếng vibraphone mềm, có thể kém nổi trong phòng gym. Cần nghe thử.

### #4 — "Bell Chime Alert" (plasterbrain, Freesound #419493)

- **Trang nghe thử:** https://freesound.org/people/plasterbrain/sounds/419493/
- **File:** https://freesound.org/people/plasterbrain/sounds/419493/download/419493__plasterbrain__bell-chime-alert.flac
  - Pack "GUI": https://freesound.org/people/plasterbrain/packs/22287/
- **Định dạng / thời lượng / dung lượng:** **FLAC** 16-bit, 44,1 kHz, stereo · **0,666 s** · 26,9 KB. Phải chuyển sang WAV hoặc M4A.
- **Giấy phép:** trang ghi "Creative Commons 0": [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/legalcode)
- **Ghi công:** **Không.** Nếu ghi tự nguyện: "plasterbrain".
- **Nguồn gốc:** tự tổng hợp. Mô tả: *"A neutral-sounding UI chime alert sound using a bell-like synth. Made in Hybrid3."* Hồ sơ: *"Musician and game dev…"*.
- **Rủi ro / ghi chú:**
  - Uploader có vài âm khác cố ý làm cho nghe giống âm của game thương mại (vd #608432: *"sounds a lot like the menu select sound from … Pokémon games, but it's actually made in Serum"*). Riêng file này không nhắc bắt chước gì.
  - Tiếng "neutral" nên có thể hơi nhẹ cho phòng gym.

### #5 — Kenney "Interface Sounds" (pack 100 file)

- **Trang nghe thử:** https://kenney.nl/assets/interface-sounds
- **Pack:** https://kenney.nl/media/pages/assets/interface-sounds/fa43c1dd4d-1677589452/kenney_interface-sounds.zip
- **Định dạng / thời lượng / dung lượng:**
  - **OGG Vorbis** ×100. Bản zip trên OGA nặng 834,5 KB.
  - Ứng viên trong pack: `confirmation_001–004`, `glass_001–006`, `bong_001`, `tick_001–004`.
  - ≈0,03–0,7 s, ước từ dung lượng bản WAV chuyển đổi của Calinou: confirmation_002 là 49.614 B, glass_004 là 62.926 B, tick_001 là 4.046 B.
  - Phải chuyển OGG sang WAV vì iOS không phát được OGG.
- **Giấy phép:**
  - Trang kenney.nl: "Creative Commons CC0", link [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/)
  - `License.txt` trong pack: *"License: (Creative Commons Zero, CC0) … This content is free to use in personal, educational and commercial projects. Support us by crediting Kenney or www.kenney.nl (this is not mandatory)"*
  - kenney.nl/support: *"all game assets on the asset pages are public domain licensed (CC0)"*
- **Ghi công:** **Không.**
- **Nguồn gốc:** Kenney tự làm và phân phối. Các pack Emotes và Particle đã được đánh giá trong docs của dự án.
- **Rủi ro / ghi chú:**
  - Đây là âm UI rất ngắn và nhẹ, **không nên** làm âm hết giờ chính trong phòng gym.
  - Hợp nhất để làm **tick 3-2-1**.

### Tick đếm ngược 3-2-1 (bonus)

| Tên | URL | Định dạng | Giấy phép | Ghi chú |
|---|---|---|---|---|
| **VCSL `wood_click_pp_rr1.wav`** (hoặc `_rr2`, `_rr3`) | https://github.com/sgossner/VCSL/blob/master/Idiophones/Struck%20Idiophones/Woodblock/wood_click_pp_rr1.wav | WAV, 107.200 B (rr3 là 82.468 B) | CC0 (`LICENSE` trong repo) | Woodblock đánh nhẹ. Ghép với chuông #1 cho cảm giác kiểu đồng hồ hẹn giờ bếp: tích tắc rồi "ding". Cắt còn khoảng 80–150 ms |
| Kenney `tick_001`–`tick_004` | Pack Interface Sounds ở trên | OGG, ≈25–65 ms | CC0 | Nhẹ hơn và mang chất UI hơn. Phải chuyển sang WAV |

### Dự phòng (đạt yêu cầu nhưng xếp sau)

**CC0:**

- **"service bell ring" — AlaskaRobotics, Freesound #221515**
  - Trang: https://freesound.org/people/AlaskaRobotics/sounds/221515/
  - File: …/download/221515__alaskarobotics__service-bell-ring.wav
  - WAV 48 kHz stereo, 8,833 s, 1,6 MB.
  - Tự thu: *"Recorded on a Marantz PMD660 with a Roland DR-20 dynamic microphone."*
  - Cùng loại chuông với #1. Phải cắt nhiều hơn.
- **"[UI Sound] Approval - High Pitched Bell Synth" — GabFitzgerald, Freesound #625174**
  - Trang: https://freesound.org/people/GabFitzgerald/sounds/625174/
  - WAV, 0,774 s, 134,8 KB.
  - Tổng hợp bằng wavetable synth.
  - Pack của người đăng chỉ có 1 âm nên ít lịch sử để đánh giá.
- **"Level Up" — qubodup, Freesound #442943**
  - Trang: https://freesound.org/people/qubodup/sounds/442943/
  - WAV 96 kHz, 1,667 s, 625,5 KB.
  - *"Created using VSTs"*.
  - Tag dreamy/fantasy nên có thể quá "game" và quá mềm.

**CC BY 4.0** (phải ghi công):

- **"Bike, Bell Ding, Single, 01-01.wav" — InspectorJ, Freesound #484344**
  - Trang: https://freesound.org/people/InspectorJ/sounds/484344/
  - File: …/download/484344__inspectorj__bike-bell-ding-single-01-01.wav
  - WAV 16-bit, 44,1 kHz, stereo, 3,020 s, 520,6 KB.
  - Thu bằng Zoom H6. Chất lượng thu tốt nhất trong danh sách. Khoảng 48,5 nghìn lượt tải.
  - Giấy phép: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/legalcode).
- **notificationsounds.com**
  - Trang giấy phép: https://notificationsounds.com/license
  - Ghi: *"All sounds are licensed under Creative Commons Attribution 4.0 International (CC BY 4.0)"*. Cho phép dùng *"in apps you sell on the App Store or Google Play"*.
  - Có định dạng MP3, M4R, OGG.
  - **Rủi ro:** người vận hành ẩn danh. Trang About chỉ ghi "Notification Sounds", "made in-house" và không nêu tên tác giả, nên không xác minh được nguồn gốc từng âm.

## 3. Khuyến nghị & lý do

**Chọn #1 — "bell ding 1.wav" của 5ro4 làm âm hết giờ nghỉ. Ghép kèm tick woodblock của VCSL cho đếm ngược 3-2-1.**

1. **Giấy phép sạch nhất có thể.**
   - CC0 cộng thêm câu của chính tác giả: "do whatever you want … no credit required".
   - Không cần ghi công.
   - Cho phép thương mại, chỉnh sửa, và nhúng vào APK/IPA (CC0 §2: *"for any purpose whatsoever, including without limitation commercial…"*).
   - Không vướng chi tiết DRM/ETM của App Store như CC BY 4.0 (§2(a)(5)(C)).
2. **Nguồn gốc rõ ràng.** Tác giả tự thu một quả chuông thật và có ghi tên thiết bị thu.
3. **Hợp mục đích.**
   - Chuông bàn có attack rất sắc, năng lượng nằm ở dải khoảng 2–5 kHz. Đây là dải loa điện thoại phát tốt và tai người nhạy nhất, nên dễ nghe xuyên qua nhạc và tiếng ồn phòng gym.
   - Tiếng "ding" mang nghĩa "đến giờ / xong" mà không gây cảm giác báo động.
   - Đây là nhận định từ đặc tính chung của loại chuông này, chưa nghe file thật.
4. **Được cộng đồng kiểm chứng:** khoảng 10 nghìn lượt tải, 4,6/5 trên 202 lượt đánh giá. Chỉ cần cắt và chuẩn hoá là dùng được.
5. **Woodblock VCSL hợp làm tick:** cũng CC0, do nhà làm thư viện tự thu, và gợi đúng cặp "tích tắc → ding" của đồng hồ hẹn giờ.

**Khi nào chọn phương án B (VCSL glockenspiel C6 → G6):**
- khi đội muốn âm "xong" kiểu 2 nốt đi lên, hoặc
- khi muốn âm chính và tick cùng một thư viện, cùng không gian thu.

Ngoài ra nên nghe thử #1, #2 và #3 trên một điện thoại thật, đặt cách khoảng 1 m, có bật nhạc nền, rồi mới chốt.

## 4. Văn bản ghi công cần lưu

**Phương án chọn (CC0): không bắt buộc ghi công.** Dù vậy vẫn nên ghi lại nguồn và giấy phép trong `ATTRIBUTION.md`, theo tinh thần quy tắc "mỗi asset phải có ghi chú nguồn + loại giấy phép". Đề xuất nội dung:

```markdown
## Âm thanh giao diện (SFX)

### Âm hết giờ nghỉ — `app/assets/audio/rest_end_ding.wav`
- Nguồn: "bell ding 1.wav" — Alva Majo (5ro4), Freesound — https://freesound.org/s/611113/
- Giấy phép: CC0 1.0 (https://creativecommons.org/publicdomain/zero/1.0/) — không bắt buộc ghi công.
- Đã chỉnh sửa: cắt còn ~1,3 s, fade-out, trộn mono, chuẩn hoá đỉnh −1 dBFS.

### Tick đếm ngược 3-2-1 — `app/assets/audio/rest_countdown_tick.wav`
- Nguồn: VCSL — Versilian Community Sample Library (Versilian Studios LLC),
  `Idiophones/Struck Idiophones/Woodblock/wood_click_pp_rr1.wav` — https://github.com/sgossner/VCSL
- Giấy phép: CC0 1.0 — không bắt buộc ghi công.
```

**Nếu chuyển sang phương án CC BY 4.0 (InspectorJ):**
- Đây là văn bản **bắt buộc**.
- Phải hiện trong app (màn Giấy phép / Credits) và trong `ATTRIBUTION.md`.
- Phải ghi rõ đã chỉnh sửa (CC BY 4.0 §3(a)(1)(B)).

```text
"Bike, Bell Ding, Single, 01-01.wav" by InspectorJ (www.jshaw.co.uk) of Freesound.org
— https://freesound.org/s/484344/ — licensed under CC BY 4.0
(https://creativecommons.org/licenses/by/4.0/). Modified: trimmed, faded out, converted to mono, normalised.
```

**Nếu dùng notificationsounds.com:** trang licence của họ yêu cầu ghi tên nguồn "notificationsounds.com", có link về trang, và ghi chú nếu đã chỉnh sửa. Ví dụ: `"<Tên âm>" from notificationsounds.com (https://notificationsounds.com) — CC BY 4.0 — modified (trimmed, normalised).`

## 5. Xử lý file & ghi chú tích hợp

**Định dạng đích: WAV PCM 16-bit, mono, 44,1 kHz.**

**Đã làm** (`scripts/make_rest_sounds.py`):

| File | Nguồn | Xử lý | Kết quả |
|---|---|---|---|
| `rest_end_bell.wav` | Pleasing Bell | Giữ nguyên độ dài, fade-out 60 ms, chuẩn hoá đỉnh −1 dBFS | 0,618 s, 54,6 KB |
| `rest_tick.wav` | VCSL woodblock | Cắt còn 160 ms, fade-out 60 ms, chuẩn hoá đỉnh −4 dBFS (nhỏ hơn chuông) | 14,2 KB |

Cả hai file đều đã cắt khoảng lặng đầu, chỉ giữ lại 2 ms trước điểm bắt đầu. File gốc thu khá nhỏ tiếng (đỉnh −24,3 và −29,9 dBFS) nên phải chuẩn hoá.
- iOS (AVPlayer) **không phát OGG Vorbis**. Bản FLAC của #4 cũng nên chuyển cho đồng nhất.
- MP3 và AAC thường có khoảng lặng đầu do encoder (vài chục ms), làm mất độ "sắc" của attack. WAV tránh được việc này.
- Thư mục `assets/audio/` đã được khai báo sẵn trong `app/pubspec.yaml`.
- WAV PCM cũng là định dạng iOS chấp nhận cho âm local notification, với điều kiện ngắn hơn 30 s. Nhờ vậy dùng lại được nếu sau này cần kêu cả khi app ở nền hoặc màn hình đã khoá (Android: `res/raw`).

**Các bước xử lý** (Audacity hoặc ffmpeg):
1. Cắt khoảng lặng đầu để attack dưới 10 ms.
2. Cắt còn 1,2–1,4 s.
3. Fade-out khoảng 300–400 ms.
4. Trộn về mono.
5. Chuẩn hoá đỉnh −1 dBFS.
6. Nghe lại trên loa điện thoại.

Ví dụ ghép phương án B bằng ffmpeg (nốt 2 trễ 130 ms; giả định mẫu là stereo; chuẩn hoá đỉnh làm riêng sau đó):
```bash
ffmpeg -i glock_medium_C6_01.wav -i glock_medium_G6_01.wav -filter_complex \
 "[1]adelay=130|130[b];[0][b]amix=inputs=2:normalize=0,atrim=0:1.3,afade=t=out:st=0.9:d=0.4,pan=mono|c0=0.5*c0+0.5*c1" \
 -ar 44100 -sample_fmt s16 rest_end_chime.wav
```

**Đã tích hợp (#131):**
- Code nằm ở `features/fitness/data/rest_sounds.dart` và `audioplayers_sfx.dart`.
- Phát bằng `audioplayers`. Cả 2 âm được nạp sẵn khi vào buổi tập, đặt `ReleaseMode.stop` để giữ file đã nạp, mỗi lần kêu thì phát lại từ đầu.
- **Android:**
  - Dùng `usageType: notificationEvent` và `contentType: sonification`, nên âm theo âm lượng thông báo và tự im khi máy để im lặng hoặc rung. Rung `restEnded` vẫn luôn có.
  - Chuông xin audio focus `gainTransientMayDuck`, nên nhạc đang phát chỉ bị hạ nhỏ trong chốc lát.
  - Tiếng mõ không xin focus (`none`) và trộn chung với nhạc, để nhạc không bị hạ nhỏ 3 lần liền.
- **iOS:** chưa đặt `AVAudioSession`, vì session dùng chung với chat PT AI (`playAndRecord`) và trình phát nhạc. Phải làm cùng chiến lược session toàn app ở giai đoạn 2.
- Có công tắc "Âm báo giờ nghỉ" trong cài đặt buổi tập (`WorkoutPrefs.restSounds`, mặc định bật).
- Lỗi phát âm bị nuốt, không làm hỏng buổi tập.

**Lưu ý lúc nghiên cứu:**
- `app/pubspec.yaml` (dòng 46–55) ghi rõ `just_audio_background` chỉ cho phép **1** `AudioPlayer` của just_audio trong toàn app. Player thứ hai sẽ ném `PlatformException` và lỗi này bị nuốt mất, gây bug "im tiếng".
  - Vì vậy âm SFX ngắn **nên phát bằng `audioplayers`**, giống `_playIncomingMessageSound()` trong `app/lib/features/social/presentation/incoming_message_banner.dart`: tạo player, phát, chờ `onPlayerComplete`, rồi `dispose`.
  - Không nên dùng just_audio như mô tả trong issue.
- Nên cấu hình audio context (duck hoặc mix) để tiếng ding không làm dừng nhạc đang phát, đồng thời giữ rung `GtHapticEvent.restEnded` như hiện tại.
  - Cần kiểm tra trên máy thật: chế độ im lặng, iOS silent switch, và luồng âm lượng trên Android.

## 6. Đã loại & lý do

- **Pixabay, Pexels:** quy tắc dự án (điều khoản "Standalone", xem `docs/research-music-libraries.md` §6).
- **Jamendo:** quy tắc dự án. API chỉ miễn phí cho mục đích phi thương mại.
- **Zapsplat:** đọc trên PDF giấy phép của chính Zapsplat: https://s3.amazonaws.com/zapsplat-assets/zapsplat-standard-license.pdf (trang license-type trả về 403).
  - Giấy phép gắn với 1 người dùng: *"This License grants a single user the right to download and use…"*.
  - *"Our sound effects must not be shared with any person."* Điều này mâu thuẫn với việc commit file vào repo dùng chung của nhóm.
  - Bắt buộc ghi công, trừ khi trả phí lên gói Gold.
  - *"we or our contributors retain all copyrights"*.
  - Có điểm cho phép *"Games and apps"* nhưng đi kèm điều kiện *"not be the primary value of your project"*.
  - Kết luận: là giấy phép gắn tài khoản, không phải CC, nên loại.
- **Mixkit:**
  - Toàn văn "Sound Effects Free License" chỉ hiện qua nút "View License" nên không đọc được nguyên văn tại https://mixkit.co/license/.
  - Bản được công cụ tìm kiếm lập chỉ mục liệt kê các phương tiện: web/social, podcast, *video games*, phim, trình chiếu, TV/radio, VOD. Không nêu rõ ứng dụng di động.
  - https://mixkit.co/terms/ cấm *"make Mixkit or any Item available to any third party"*.
  - Thuộc Envato, không phải CC. Rủi ro, loại.
- **Material Design sound resources (Google):** chưa xác minh được trên nguồn gốc.
  - Trang https://m2.material.io/design/sound/sound-resources.html render bằng JavaScript nên công cụ không đọc được.
  - Hai bản mirror ghi mâu thuẫn: GitHub nana-4/materia-sound-theme ghi CC BY 4.0, còn archive.org ghi CC BY-SA 4.0 (do người upload tự chọn).
  - Tạm loại. Chỉ cân nhắc lại sau khi mở trang Google bằng trình duyệt và lưu nguyên văn câu giấy phép.
- **Freesound — các âm có nguồn gốc không đạt hoặc chất lượng kém:**
  - **Jofae "Chime Notification" #380482** (CC0): mô tả là *"some kind of notification you might get on your phone"* và không ghi cách tạo. Có thể là âm lấy từ điện thoại.
  - **Vendarro "Signal-Ring 1" #399315** (CC0, glockenspiel): mô tả *"sounds a bit like from 'City Skylines'"*. Đây là bản bắt chước âm của một game thương mại.
  - **chennes "Ding.wav" #376807** (CC0): *"based on OddWorld's 'MicrowaveDing'"*. Là bản phái sinh, phải xác minh thêm âm gốc.
  - **Koyber "Casio F-91W Hour Chime" #160483** (CC0): thu lại tiếng chuông có sẵn của đồng hồ Casio, tức là âm của thiết bị thương mại.
  - **JohnsonBrandEditing "Ding Ding Small Bell" #173932** (CC0, rất phổ biến): không có mô tả, không rõ cách tạo, dài 14,2 s.
  - **dland "Kitchen Timer — Done!" #149506** (CC0, tự thu): thu bằng Voice Notes trên iPhone nên chất lượng thấp, dài 8,9 s.
  - **ertfelda "correct" #243701** (CC0): đàn Yamaha PSS-270 thu bằng iPhone 3GS nên chất lượng thấp, chỉ dài 0,318 s.
  - **Mateusz_Chenc "Boxing Bell Signals" #520998** (CC0, tự thu): chuỗi tín hiệu dài 32,8 s, dễ thành cảm giác báo động.
  - **sethlind "Toaster oven timer and ding" #265022** (CC0): dài 54 s, có tag "alarm".
- **OpenGameArt:**
  - **"Completion sound":** người đăng (HaelDB) không phải tác giả (Brandon Morris), chuỗi nguồn gốc yếu hơn.
  - **"Bell dings/chimes" (PWL):** *"Somewhat thin and short"*, không ghi cách tạo.
  - **"UI Sound Effects…" (Robin Lamb, CC0):** nguồn gốc ổn vì cắt từ VCSL và VSCO 2 CE, nhưng nên lấy thẳng từ VCSL (nguồn gốc gần hơn).
- **Kenney UI Audio** (50 file: button, switch, click) và **Kenney Digital Audio** (60 file: laser, space synth): CC0 đã xác minh trên kenney.nl nhưng không có tiếng chuông hay chime phù hợp.

## 7. Ghi chú phụ

- `app/assets/audio/notification_tone.mp3` (và `app/android/app/src/main/res/raw/notification_tone.mp3`) đang được dùng cho tin nhắn chat, nhưng không thấy ghi nguồn hay giấy phép ở `ATTRIBUTION.md` hoặc `docs/`. Nên bổ sung để đúng quy ước.
- Giới hạn của lần nghiên cứu này:
  - Chưa nghe thử bất kỳ file nào, vì quy tắc là không tải file.
  - Thời lượng của Kenney, VCSL và "Pleasing Bell" là ước tính.
  - kenney.nl và freesound.org thỉnh thoảng lỗi DNS hoặc 429 khi đọc, nhưng các trang dùng làm căn cứ đều đã đọc được.

## Nguồn đã đọc

- Freesound:
  - https://freesound.org/people/5ro4/sounds/611113/ · /611112/ · /611111/ · https://freesound.org/people/5ro4/packs/33679/
  - https://freesound.org/people/plasterbrain/sounds/419493/ · https://freesound.org/people/plasterbrain/ · https://freesound.org/people/plasterbrain/packs/22287/ · https://freesound.org/people/plasterbrain/sounds/608432/
  - https://freesound.org/people/AlaskaRobotics/sounds/221515/ · https://freesound.org/people/InspectorJ/sounds/484344/ · https://freesound.org/people/GabFitzgerald/sounds/625174/ · https://freesound.org/people/qubodup/sounds/442943/
  - https://freesound.org/help/faq/
- Kenney:
  - https://kenney.nl/assets/interface-sounds · https://kenney.nl/support · https://kenney.nl/assets/ui-audio · https://kenney.nl/assets/digital-audio · https://kenney.nl/assets/impact-sounds · https://kenney.nl/assets/music-jingles
  - `License.txt` của pack (bản sao trong https://github.com/Calinou/kenney-interface-sounds) · https://opengameart.org/content/interface-sounds
- VCSL: https://github.com/sgossner/VCSL (README, LICENSE) · https://github.com/sgossner
- OpenGameArt: https://opengameart.org/content/pleasing-bell-sound-effect · https://opengameart.org/content/ui-sound-effects-button-clicks-user-feedback-notifications
- Giấy phép: https://creativecommons.org/publicdomain/zero/1.0/legalcode.en · https://creativecommons.org/licenses/by/4.0/legalcode.en
- Các nguồn đã loại hoặc dự phòng:
  - https://notificationsounds.com/license · https://notificationsounds.com/about
  - https://s3.amazonaws.com/zapsplat-assets/zapsplat-standard-license.pdf
  - https://mixkit.co/license/ · https://mixkit.co/terms/
  - https://archive.org/details/material-design-sound-resources · https://github.com/nana-4/materia-sound-theme

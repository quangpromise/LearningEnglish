# Kế hoạch: từ app học qua bài hát → nền tảng học đa phương tiện

Tài liệu **thiết kế**, chưa code. Mọi kết luận đều dẫn chiếu file thật trong repo.

> **Bản v2 — đã qua phản biện.** Bản v1 có 6 claim sai và 1 mâu thuẫn nội tại; xem [§H](#h-những-gì-đã-sửa-sau-phản-biện) để biết đã sửa gì và vì sao. Đọc §H trước nếu bạn đã xem bản v1.

---

## A. Hiện trạng kiến trúc

### A.1 Nội dung là CODE

Toàn bộ nội dung học nằm trong `const` Dart biên dịch vào app:

| Loại | File | Dòng | Model |
|---|---|---|---|
| Bài hát | `features/music_player/data/songs_data.dart` | 2.497 | `Song`, `LyricLine` |
| Từ vựng | `features/vocabulary/data/vocabulary_data.dart` | 4.726 | `VocabTopic`, `VocabWord` |
| Ngữ pháp | `features/grammar/data/grammar_data.dart` | 1.609 | `GrammarTopic`, … |
| Phát âm | `features/pronunciation/data/phonics_data.dart` | 612 | `PhonicsLesson`, … |
| Sách đọc | `features/reading/data/reading_data.dart` | 54 | `Book` |
| Đố vui | `features/quiz/data/quiz_data.dart` | 114 | `Riddle` |

Sáu model rời rạc, **không có khái niệm chung nào** — không `Lesson`, không `Content`, không ID.

⚠️ **Nhưng hệ quả nhẹ hơn tưởng.** Repo có `build-apk.yml` chạy khi commit message chứa `[build]`, phát hành qua GitHub Releases, và app tự kiểm tra cập nhật lúc mở + khi resume + **mỗi 15 phút** (`root_shell.dart:66-76`), tải và mở trình cài đặt ngay trong app (`update_dialog.dart`). Thêm nội dung tốn **1 commit + ~6 phút CI**, không phải chu kỳ duyệt store. Điều này **làm yếu đáng kể** lập luận phải tách nội dung khỏi code — xem §C.5.

### A.2 Backend chỉ chứa dữ liệu người dùng

14 migration, toàn bộ user-scoped. **Không có bảng nội dung nào.**

### A.3 Tiến độ khoá theo TÊN BÀI HÁT — và có sẵn 2 lỗi

```sql
-- 0004_real_stats.sql
create table public.user_completed_songs (
  user_id uuid not null,
  song_title text not null,        -- ⚠️ khoá bằng chuỗi tiêu đề
  primary key (user_id, song_title)
);
```

**Lỗi tiềm ẩn #1 — thiếu policy UPDATE.** `0004` và `0010` chỉ tạo policy `select`/`insert`(/`delete`). Nhưng client gọi `.upsert()` (`stats_repository.dart:113,122`, `favorites_repository.dart:24`) = `INSERT … ON CONFLICT DO UPDATE`, mà Postgres đòi policy UPDATE cho nhánh đó. Nghe lại một bài đã nghe → lỗi RLS → **bị nuốt** bởi `.catchError((_) {})` (`player_screen.dart:171`).

Hôm nay vô hại (dòng đã tồn tại rồi, không mất gì). **Nhưng mọi kế hoạch "dual-write thêm cột `lesson_id` bằng upsert" sẽ thất bại âm thầm** vì đúng cái nhánh UPDATE đó.

**Lỗi tiềm ẩn #2 — `song_title` vừa `not null` vừa là nửa khoá chính.** Nội dung không phải bài hát không có `song_title`. Không thể tái dùng bảng này.

### A.4 Đã có HAI bộ máy "phát + đồng bộ chữ"

| | `PlayerScreen` | `ReadingScreen` |
|---|---|---|
| Nguồn thời gian | `AudioPlayer.position` qua `Ticker` 60fps | TTS tuần tự `await speakAndWait()` |
| Đơn vị | `LyricLine` (chỉ `startSeconds`) | câu tách bằng `splitSentences()` |
| Lưu tiến độ | Supabase, theo tên bài | `SharedPreferences`, theo `assetPath` |
| Tra từ | `WordPopupSheet` | `WordPopupSheet` |

Cùng một bài toán, hai lời giải. Video sẽ thành bộ thứ ba.

### A.5 Phần tái dùng được — đánh giá lại cho đúng

**`KaraokeLyricsView` là *time-source*-agnostic, KHÔNG phải media-agnostic.** Nó nhận `ValueListenable<double> positionSeconds` nên không quan tâm thời gian đến từ đâu. Nhưng vẫn vướng:

- `final int activeIndex` — **một** dòng active duy nhất, không biểu diễn được chồng lời.
- `onWordTap: isActive ? onWordTap : null` (`:347`) — chỉ chạm được từ trên dòng đang hát. Với video/narration người học muốn chạm mọi từ đang thấy.
- Không có `speakerId` → hội thoại cần sửa UI trong `_LineTile`.
- Thiết kế thị giác gắn với nền tối: `_kSungColor` trắng, glow xanh→tím (`:228-247`), `ListView` cuộn toàn màn với cache 2000px. **Đè lên khung hình video sẽ không đọc được** và sai hình dạng (phụ đề cần 1–3 dòng, không phải danh sách cuộn).
- Logic đồng bộ **không nằm trong widget** — nó ở `_onTick` (`player_screen.dart:88-104`), quét O(n) mỗi khung hình lấy "segment cuối có start ≤ t". Logic này không có khái niệm khoảng lặng → **phải viết lại** cho video.

→ Tái dùng được: **bộ vẽ quét-từ**. Không tái dùng được: container, bộ điều khiển active-index, và toàn bộ xử lý thị giác. Cần một biến thể `SubtitleOverlay` riêng cho video.

**`WordPopupSheet` đã generic thật** — đang dùng lại từ Player, Reading và AI Voice Chat (`ai_voice_chat_screen.dart:635`).

**`PronunciationScreen(targetEn:)` là CODE CHẾT.** `initState()` gán đè vô điều kiện:

```dart
// pronunciation_screen.dart:66-68
final initial = _randomSongLine();     // ← luôn chạy
_targetEn = initial.en;
```

`widget.targetEn` chỉ được đọc ở `:113` làm fallback khi `kSongs` rỗng (không bao giờ). **Truyền `targetEn` vào hôm nay sẽ ra một câu lyric ngẫu nhiên.** Shadowing là việc mới, không phải tái dùng.

**Pipeline `scripts/` đã source-agnostic + có cổng gác license**, 37 test trong CI. Đây là tài sản tốt nhất và nên giữ nguyên hình dạng.

### A.6 Hard-code quanh "bài hát"

| Vị trí | Vấn đề | Mức |
|---|---|---|
| `LyricLine(startSeconds, en, vi)` | **Không có `end`, không có người nói** | Cao |
| `_levelColor`/`_levelLabel` so khớp chuỗi `'Cơ bản'/…` | Cấp độ là chuỗi tiếng Việt | Cao |
| `NowPlayingService` cứng `AudioPlayer` | Không chỗ cho video | Cao |
| `user_completed_songs.song_title` | Khoá tiến độ bằng tiêu đề | Cao |
| `_randomSongLine()` **và** `_PracticeSourcePicker` (`:774`) | 2 chỗ đọc thẳng `kSongs` | Trung bình |
| `favoriteSongTitlesProvider` trả `Set<String>` tiêu đề | So sánh bằng tiêu đề (`player_screen.dart:222`) | Trung bình |
| `home_screen.dart:62-70` lọc theo `title`/`artist` | Không có bộ lọc theo loại/cấp độ | Trung bình |
| `GrammarScreen({required LyricLine sentence})` | Kiểu bài hát rò rỉ | Thấp |

### A.7 Luồng dữ liệu

```
scripts/add_songs.py → songs_data.dart (const kSongs)
        │  ⚠️ metadata bản quyền DỪNG ở đây, không vào app
        ▼
HomeScreen → PlayerScreen → NowPlayingService (1 AudioPlayer)
                  │                  │
                  │           position (Ticker 60fps)
                  ▼                  ▼
            KaraokeLyricsView ◄──────┘
                  │
          WordPopupSheet / GrammarScreen / seek
```

**Rò rỉ:** `emit` ghi license vào `ATTRIBUTION.md` (văn xuôi, trong git), nhưng `Song` không có trường bản quyền → **app không hiển thị attribution ở đâu cả**. Người dùng nhận APK, không nhận repo. CC-BY yêu cầu ghi công **đi kèm bản phân phối** → đây là **khoảng trống tuân thủ đang tồn tại**, không phải việc tương lai.

---

## B. Phân tích khoảng trống

| # | Khoảng trống | Mức | Ghi chú |
|---|---|---|---|
| 1 | **APK size gate vs. 2 media stack** | 🔴 **Rủi ro số 1, chưa ai đo** | `build-apk.yml` **fail cứng** ở 30MB/split, 55MB/universal. `just_audio` (ExoPlayer 2) + `video_player` (Media3) = 2 thư viện player. Đã có tiền lệ: `google_mlkit_translation` từng làm APK nặng gấp đôi vì 1 file `.so` 16MB |
| 2 | Tiến độ khoá theo tiêu đề + thiếu policy UPDATE | 🔴 Chặn cứng | §A.3 |
| 3 | `LyricLine` thiếu `end` + `speaker` | 🔴 Chặn cứng | Không biểu diễn được hội thoại |
| 4 | Không có attribution trong app | 🟠 Cao — **tuân thủ, đang xảy ra** | §A.7 |
| 5 | `NowPlayingService` chỉ audio | 🟠 Cao | `video_player` tạo player native riêng nó không biết |
| 6 | Cấp độ không phải CEFR | 🟠 Cao | |
| 7 | Audio ~280 kbps | 🟡 Trung bình — **cơ hội rẻ** | 167,4MB/20 file. Về 96 kbps mono → ~57MB (2,9×) |
| 8 | Hai bộ máy phát song song | 🟡 Trung bình | |
| 9 | Impeller đang bị TẮT | 🟡 Trung bình | `AndroidManifest.xml:34-39` — tắt vì lỗi render chữ. Video texture trên Skia là đường chậm hơn |

**Điều chỉnh quan trọng so với v1:** `raw.githubusercontent.com` **có** Fastly + edge cache + HTTP Range (đúng thứ `just_audio` cần) và đang chạy tốt. Lý do chuyển CDN là **ToS của GitHub và throttling**, không phải "không phải CDN". Kết luận nên chuyển vẫn đúng, **nhưng tính cấp bách thì không**.

**Và chuyển CDN không bao giờ là một cuộc "dời nhà".** `_audioBaseUrl` là `const` compile-time (`songs_data.dart:10-11`) → đã nướng vào **mọi APK đã cài**. File trên `main/content/audio/` phải sống **vĩnh viễn**, nếu không nhạc của người không cập nhật sẽ 404. Quy tắc: **`content/audio` là append-only, không bao giờ xoá, không bao giờ rewrite history.**

---

## C. Kiến trúc đích

### C.1 Nguyên tắc

1. **MỘT** entity `Lesson`. Không tạo nhánh kiến trúc riêng cho video.
2. Khác biệt nằm ở **dữ liệu** (`media.kind`, `speakers.isEmpty`), không ở **lớp**.
3. Bài hát hiện tại là **tập con** → migrate bằng adapter.
4. **Chỉ đưa vào model những trường app THỰC SỰ đọc.** Rubric biên tập ở markdown, hồ sơ audit ở `scripts/`.

### C.2 Entity — bản đã cắt gọn

```dart
enum MediaKind { audio, video, tts }   // tts = tổng hợp lúc chạy (Reading)

class Lesson {
  final String id;                  // slug ổn định, suy từ audioUrl — KHÔNG BAO GIỜ đổi
  final List<String> tags;          // 'song','video-story','conversation' — CHỈ để xếp kệ ở Home
  final String title;
  final String? byline;             // artist | narrator | "Hội thoại"
  final CefrLevel level;
  final Media media;
  final Transcript transcript;
  final List<Speaker> speakers;     // rỗng = một giọng
  final Attribution attribution;
  final String colorToken;          // 'blue' — KHÔNG phải dart:ui Color
}

class Media {
  final MediaKind kind;
  final String? url;
  final int? durationMs;
  final String? posterUrl;
}

class Transcript { final List<Segment> segments; }

class Segment {
  final String id;                  // ⭐ khoá ổn định cho bookmark/bài tập/tiến độ
  final int startMs;
  final int endMs;                  // ⭐ BẮT BUỘC — adapter tính sẵn, runtime không branch null
  final String? speakerId;          // ⭐ hội thoại
  final String en;
  final String vi;
}

class Speaker { final String id, label; final String? ttsVoice; final String colorToken; }
```

**Vì sao `tags` chứ không phải `enum LessonKind`:** nguyên tắc C.1.2 nói khác biệt nằm ở dữ liệu, nhưng một enum 5 giá trị chính là lời mời viết `switch (kind)`. Trục hành vi thật là `media.kind` và `speakers.isEmpty`. `song` với `educationalSong` khác nhau **không một dòng code nào**. → `tags` chỉ dùng để xếp kệ; **cấm `switch` theo nó**.

**Vì sao `endMs` bắt buộc:** `endMs` nullable + `words` nullable = 4 trạng thái, 2 vô nghĩa, và mọi consumer phải branch null mãi mãi. Adapter tính `endMs` từ start dòng sau (hoặc bộ ước lượng hiện có) → runtime luôn có giá trị.

**Đã cắt khỏi Phase 0:** `Segment.words` (bộ ước lượng hiện tại đã tốt, 15 test bảo chứng), `variantGroupId`, `exercises`, `vocabulary` — thuộc Phase 3+.

**Tương thích ngược:** `LyricLine(s, en, vi)` → `Segment(startMs: s*1000, endMs: <start dòng sau>, …)`. `buildKaraokeLines` giữ nguyên thuật toán. 20 bài hiện có chạy y hệt.

**Chồng lời (duet, ngắt lời trong hội thoại) là KHÔNG biểu diễn được** với `List<Segment>` phẳng + một `activeIndex`, và `karaoke_lyrics_test.dart:57-70` đang **assert ngược lại** (`lines[i].end <= lines[i+1].start`). → Ghi thành **bất biến có chủ đích**: *segment không chồng nhau, sắp xếp tăng dần*, và cổng gác ingest kiểm điều đó. Nếu sau này thật sự cần chồng lời thì phải thêm khái niệm lane — **không nằm trong kế hoạch này**.

### C.3 Attribution — 5 trường, không phải 15

```dart
class Attribution {
  final String creator;
  final String licenseId;        // 'CC-BY-4.0'
  final String licenseUrl;
  final String sourceUrl;
  final bool required;           // có phải hiện trong app không
}
```

App chỉ có thể **hiển thị** được chừng đó. `reviewedBy`, `reviewedAt`, `licenseSnapshotPath`, `redistribution`, `ownership` là hồ sơ audit cho một quy trình mà **hiện chỉ có một người vừa làm vừa duyệt** — chúng đã nằm đúng chỗ trong `scripts/song_licensing.py` + `ATTRIBUTION.md`, để nguyên đó.

Nguyên tắc **bản thu ≠ phần lời** vẫn được giữ **ở cổng gác ingest** (`song_licensing.py` đã làm đúng), chỉ không nhân đôi vào app model.

### C.4 CEFR — enum + rubric, không phải data model

```dart
enum CefrLevel { a1, a2, b1, b2, c1, c2 }
```

Hết. `LevelProfile` 12 trường ở bản v1 (`implicitMeaningLevel`, `pronunciationClarity`, `idiomDensity`…) là **rubric biên tập đội lốt data model** — không dòng code nào đọc chúng. Chuyển thành `docs/cefr-rubric.md` cho người viết nội dung dùng, kèm 3 ràng buộc đo được để QA: **số từ tối đa mỗi câu, dải tần suất từ vựng, tốc độ nói mục tiêu**.

**IELTS chỉ là gợi ý hiển thị**, dạng dải ("B1 ≈ 4.0–5.0"). Không có ánh xạ chính thức 1-1.

### C.5 Nội dung lưu ở đâu — **bỏ bước JSON assets**

Bản v1 đề xuất `assets/lessons/*.json` làm bước trung gian. **Cắt.** Lý do:

- Asset đóng gói vẫn nằm trong APK → **nhịp phát hành nội dung không đổi một chút nào**. Đó là toàn bộ lợi ích được viện dẫn.
- **Mất type-safety:** hôm nay lyric sai là `flutter analyze` fail ở CI; thành JSON là exception trên máy người dùng.
- **Làm hỏng test tốt nhất đang có:** `karaoke_lyrics_test.dart` duyệt `kSongs` như const thuần; chuyển JSON thì phải kéo `TestWidgetsFlutterBinding` + `rootBundle` vào.
- Mọi consumer hiện đọc `kSongs` **đồng bộ** (`home_screen.dart:62` trong `build()`, `pronunciation_screen.dart:66` trong `initState()`) → phải thêm loading/error/empty khắp nơi.

**Thay bằng:** interface `LessonRepository` + **ID ổn định**, cài đặt bằng const Dart sinh sẵn (script đã sinh Dart rồi). Nếu Phase từ xa thực sự tới, sinh JSON từ Dart lúc đó.

### C.6 Pipeline sản xuất

```
nguồn media → cổng gác license (đã có) → chọn cấp CEFR
   → viết kịch bản EN → 👤 dịch VI + duyệt → TTS/thu giọng
   → căn timestamp → 👤 QA theo rubric → publish
```

**Căn timestamp cho narration TTS gần như miễn phí:** tự tổng hợp từng segment nên biết chính xác độ dài từng đoạn — không cần ASR. So với nhạc phải chạy forced-alignment và vẫn còn **45/504 khoảng cách < 0,75s** (ngưỡng phải nêu rõ, nếu không con số vô nghĩa; 524 dòng, 504 khoảng cách). Đây là lập luận mạnh cho việc bắt đầu bằng narration.

---

## D. Kế hoạch — sắp lại theo "rẻ nhất và đảo ngược được trước"

### Spike 0 — Video có vừa APK không? (½ ngày, **trước mọi thứ**)

Đây là **ẩn số lớn nhất** và chưa ai đo. Nếu trả lời là không, toàn bộ `MediaController`/`Media.kind`/kệ "Video Story" là việc chết.

1. Nhánh vứt đi: `flutter pub add video_player`, 1 URL H.264 hardcode, không abstraction, không `Lesson`, không đụng DB.
2. Push kèm `[build]` → đọc kết quả size-check của `build-apk.yml`. **Đây là go/no-go miễn phí.**
3. Sideload lên máy Android rẻ nhất có. Kiểm: hardware decode, chạy đồng thời ticker karaoke 60fps, nhiệt sau 5 phút, pin, hành vi khi bấm Home, và bật một bài hát trong lúc video đang chạy.
4. Vứt nhánh.

Chạy với **Impeller vẫn tắt**, trên đúng máy đã từng lỗi render chữ.

### Phase 0 — Nền tảng (không đổi trải nghiệm người dùng)

| Hạng mục | Chi tiết |
|---|---|
| **Sửa lỗi RLS trước tiên** | Thêm policy UPDATE, **hoặc** đổi sang `insert(ignoreDuplicates: true)`. Bỏ `.catchError((_) {})` nuốt lỗi ở `player_screen.dart:171` |
| **ID ổn định** | Thêm `id` vào 20 `const Song(...)`, **suy từ slug trong `audioUrl`** (`dont-close-your-eyes`), **không** từ tiêu đề — tiêu đề chính là thứ đang hỏng |
| **Bảng MỚI** | `user_lesson_progress(user_id, lesson_id, kind, …)`. **Không ALTER** bảng cũ — client cũ vẫn upsert `onConflict:'user_id,song_title'`, đổi PK là làm hỏng chúng. Rollback = `drop table` |
| Dual-write | APK mới ghi cả hai. **Là vĩnh viễn** — bỏ đi chỉ tiết kiệm một khoá JSON, đổi lấy rủi ro regression |
| Bỏ backfill | 20 bài lịch sử "đã nghe" không đáng một migration viết tay có 2 tiêu đề chứa dấu nháy (`"Don't Close Your Eyes"`, `'I\'m Letting Go'`). Ghi `lesson_id` từ nay trở đi |
| `LessonRepository` + `Segment` | Adapter `Song → Lesson`; `karaoke_lyrics.dart` nhận `Segment` |
| **Màn Attribution** | Vài giờ. Đóng khoảng trống tuân thủ CC-BY §A.7 |
| Gỡ coupling | `GrammarScreen` nhận `Segment`; `PronunciationScreen` nhận danh sách segment (**2 chỗ**: `_randomSongLine` và `_PracticeSourcePicker`) |
| UI | **Không đổi trải nghiệm.** Nhưng *có* sửa file presentation và **làm vỡ import của cả 2 file test** — phải tính công |
| Test | Bất biến **cấu trúc** (đúng số lượng, đúng start, tăng dần, không tràn) — **không** phải byte-identical, nếu không việc sửa 45 dòng lệch giờ sẽ bị coi là regression. Thêm fixture khoá `id → title`, CI fail nếu id đổi |
| Rủi ro | Thấp |

### Phase 1 — Câu chuyện đầu tiên, **không cần video**

**Đây là thay đổi lớn nhất so với v1.** Story đầu tiên = **narration audio + một ảnh tĩnh + phụ đề song ngữ + shadowing**.

- **Không cần package mới.** Chạy trên đúng đường `just_audio` đang có.
- **Không dính rủi ro APK size, codec, nhiệt, Impeller.**
- **Không dính câu hỏi pháp lý Pexels chưa ngã ngũ.**
- Kiểm chứng đúng giả thuyết sản phẩm: *một micro-story B1 tự viết, narration TTS, có dạy tốt hơn bài hát không?*

Nếu câu chuyện tĩnh không thuyết phục được người học thì phần video vốn dĩ chưa bao giờ đáng làm.

Kèm theo: tốc độ phát, lặp đoạn, ẩn/hiện EN, ẩn/hiện VI, và **shadowing** (xem rủi ro bên dưới).

### Phase 1.5 — Transcode + CDN (độc lập, làm bất cứ lúc nào)

`ffmpeg` về 96 kbps mono: 167MB → ~57MB. Sửa cùng lúc: phình repo, lãng phí checkout ở **cả hai** job CI, và cước dữ liệu của người dùng. Thêm `_audioBaseUrlV2` cho media **mới**; **giữ URL cũ sống vĩnh viễn**.

### Phase 2 — Video (chỉ khi Spike 0 pass)

`MediaController` mỏng + token "ai đang sở hữu playback" mà **cả hai** player đăng ký (video→song hiện **không** có gì chặn). Áp cùng cấu hình `audio_session` cho đường video, nếu không **lỗi phát ra loa tai nghe đã sửa một lần sẽ quay lại**. Thêm `didChangeAppLifecycleState → pause()` (video Android **không** tự dừng khi vào nền).

**Với video: hạ karaoke từ quét-cấp-từ xuống highlight-cấp-dòng ~10Hz.** Không ai đọc phụ đề trên video cần quét từng âm tiết, và nó gỡ luôn bài toán nhiệt.

Video: H.264 Main/High ≤ level 4.0, yuv420p, AAC, **`-movflags +faststart`**, 540–720p, ~600–800 kbps, **≤5MB/phút**. Không làm HLS.

### Phase 3+ — CEFR đa cấp, hội thoại, catalog từ xa

Chỉ mở khi Phase 1 chứng minh được nội dung tự sản xuất có hiệu quả.

---

## E. MVP — chấp nhận giả thuyết, **đổi phương tiện**

### Giả thuyết của Product

> "Một video stock → một micro-story B1 → narration → phụ đề Anh/Việt → từ vựng → phát + shadowing."

### Kết luận: **chấp nhận phần học, bác bỏ phần "video stock" cho MVP**

| Thành phần | Đánh giá |
|---|---|
| Phụ đề song ngữ có timestamp | ✅ Bộ vẽ quét-từ tái dùng được; controller thì không |
| Từ vựng + tra từ | ✅ `WordPopupSheet` đã generic thật |
| Narration + căn giờ | ✅ TTS cho timestamp chính xác, rẻ hơn nhạc |
| **Shadowing** | ⚠️ **KHÔNG rẻ** — `targetEn` là code chết (§A.5). Xem rủi ro dưới |
| **Video** | 🔴 Chưa đo được có vừa APK không |
| **Nguồn Pexels** | 🔴 **Mâu thuẫn với chính doc của repo** |

**Về Pexels:** `docs/research-music-libraries.md` §6 kết luận in đậm *"cả họ nhà stock-media license (Pixabay, Pexels…) đều không hợp với app này"*, và `song_licensing.py` có quy tắc vàng *"KHÔNG RÕ = TỪ CHỐI"*. Lập luận "đã có công sức sáng tạo nên không còn standalone" **dễ bảo vệ hơn** với video-dưới-narration so với cả bài hát — nhưng nó vẫn là câu hỏi pháp lý chưa ngã ngũ (chính §F.4 thừa nhận). **Không đặt câu hỏi pháp lý chưa có lời giải lên đường găng của MVP.**

### MVP đề xuất

**MVP-0 (½–1 ngày):** ID ổn định + bảng progress mới + sửa lỗi RLS + màn attribution. Không ai thấy gì khác. Đóng luôn 2 lỗi đang tồn tại.

**MVP-1:** 1 micro-story B1 tự viết + narration TTS + **ảnh tĩnh** + phụ đề Anh/Việt + ~10 từ vựng + tốc độ/lặp đoạn + shadowing.

**Video là quyết định riêng**, mở khoá bởi Spike 0, không nằm trong MVP.

### Shadowing — không miễn phí, và có 4 cái bẫy

Đẩy `PronunciationScreen` như một route từ player sẽ vỡ:

1. **Nhạc vẫn phát vào mic.** `PlayerScreen` chỉ dừng audio trong `dispose()` (`:199`), mà push không gọi dispose → STT chấm điểm giọng ca sĩ.
2. **Không có nút back.** `:398` là `const SizedBox(width: 48)` với comment ghi rõ màn này "không bao giờ được `Navigator.push`".
3. **Nút AI FAB đè lên.** Nó chỉ ẩn theo `pronunciationTabActiveProvider`, mà cờ đó set theo **chỉ số tab** (`root_shell.dart:56-60`).
4. **Hỏng audio session.** `_playRecording()` cấu hình lại `AudioSession` **toàn cục** và dùng `AudioPlayer` thứ hai — đúng thứ `NowPlayingService` sinh ra để ngăn.

**Và nó làm hỏng 2 chỉ số:** mỗi lần chấm ghi vào `user_pronunciation_attempts` → kéo `avg(score)` ở Profile; đồng thời `addPracticeSeconds` được gọi bởi **cả** `PlayerScreen.dispose()` **và** màn phát âm → **đếm trùng thời gian luyện**.

→ Tách `PronunciationPractice(target)` thành widget không state tab, wrapper tab cấp câu ngẫu nhiên; `NowPlayingService.pauseIfCurrent()` khi push; ẩn FAB theo route; thêm cột `source` cho attempt. **Khoảng 1 ngày, không phải "chỉ push màn hình".**

---

## F. Quyết định cần Product

1. **Ánh xạ 3 cấp cũ sang CEFR.** `'Cơ bản'/'Trung cấp'/'Nâng cao'` → `A2/B1/B2`?
2. **Có hiển thị IELTS không?** Nếu có thì dạng dải.
3. **Narration: TTS hay giọng người thật?** Định hình toàn bộ chi phí sản xuất.
4. **Ai duyệt bản dịch VI ở quy mô lớn?** Pipeline bắt buộc có người, nhưng chưa có công cụ, hàng đợi, hay ước lượng thông lượng. Đây là trần thật của tốc độ sản xuất.
5. **Thời gian luyện tính thế nào** khi shadowing lồng trong bài học? (Hiện đang đếm trùng.)
6. **Có theo đuổi video không**, sau khi có kết quả Spike 0?
7. **CC-BY-SA** — vẫn treo từ trước (`research-music-libraries.md` §5).
8. **Reading có gộp vào `Lesson` không?** Kỹ thuật thì hợp (`MediaKind.tts`), nhưng UX đọc sách khác hẳn. Khuyến nghị **hoãn**.

---

## G. Nợ kỹ thuật

1. **45/504 khoảng cách < 0,75s** trong `songs_data.dart` (524 dòng, 504 khoảng cách). Nêu ngưỡng, nếu không con số không kiểm chứng được.
2. **Thiếu policy UPDATE** khiến `.upsert()` hỏng âm thầm — §A.3.
3. **Đếm trùng thời gian luyện** giữa `PlayerScreen.dispose()` và màn phát âm.
4. **`docs/architecture.md`, `docs/roadmap.md`, `docs/ci-apk-distribution.md` đều lỗi thời.** Cái cuối nói build tự động mỗi lần push vào `main`, thực tế đã đổi thành gate `[build]`.
5. **Ba màn quiz gần trùng nhau.** Không thuộc migration này.
6. Không có: offline/cache, phát nền/màn hình khoá, wakelock, versioning nội dung khi sửa transcript, telemetry để đo giả thuyết MVP.
7. **`features/crypto/`** (7 file) không liên quan học tiếng Anh.

---

## H. Những gì đã sửa sau phản biện

Bản v1 được hai agent phản biện đọc code thật. Sáu claim **sai**, đã kiểm chứng lại từng cái:

| Claim v1 | Thực tế |
|---|---|
| "`PronunciationScreen` đã hỗ trợ luyện câu chỉ định → shadowing rẻ" | **Sai.** `initState():66-68` gán đè bằng `_randomSongLine()`; `targetEn` là code chết |
| "`KaraokeLyricsView` đã media-agnostic" | **Sai.** Time-source-agnostic thôi. `activeIndex` đơn, chỉ chạm được dòng active, thiết kế gắn nền tối, logic sync nằm ở `player_screen._onTick` |
| "`raw.githubusercontent.com` không phải CDN" | **Sai.** Có Fastly + Range. Lý do chuyển là ToS/throttling |
| "504 dòng lyric" | **Sai.** 524 dòng / 504 khoảng cách. Và "69" phải kèm ngưỡng |
| "`WordPopupSheet` dùng lại ở social Chat" | **Sai.** Là AI Voice Chat |
| "Thêm nội dung = phải phát hành lại APK" (nêu như hệ quả chi phối) | **Quá lời.** Có in-app updater + poll 15 phút + gate `[build]` → 1 commit + ~6 phút CI |

Và một **mâu thuẫn nội tại**: v1 đặt Pexels lên đường găng MVP, trong khi `docs/research-music-libraries.md` §6 — do chính dự án này viết và merge ở PR #2 — đã loại họ stock-media.

**Đã cắt:** bước JSON assets, `LevelProfile` (12 trường → enum + rubric markdown), `AssetProvenance` (15 → 5 trường), `variantGroupId`, `Segment.words`, `LessonKind` enum (→ `tags`), Phase catalog từ xa, gộp 3 màn quiz.

**Đã thêm:** Spike 0 đo APK size trước mọi thứ; sửa lỗi RLS; ID suy từ slug thay vì tiêu đề; **bảng mới** thay vì ALTER bảng đang có client cũ dùng; màn attribution vào Phase 0; transcode audio; quy tắc append-only cho `content/audio`; token sở hữu playback cho video→song; hạ karaoke xuống cấp-dòng cho video; 4 cái bẫy của shadowing; đếm trùng thời gian luyện.

**Lý do cắt gọn mạnh tay:** `git shortlog` cho thấy repo có **một người** (51 commit) cộng 7 commit của Claude. `CODEOWNERS` gán `@quangpromise` cho mọi đường dẫn. Kế hoạch v1 được thiết kế cho một đội không tồn tại.

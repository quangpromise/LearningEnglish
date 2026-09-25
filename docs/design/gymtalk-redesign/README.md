# Handoff: GymTalk UI Redesign (Today / Train / Learn / Progress / Onboarding / Paywall / Wealth)

## Overview
Full visual + UX redesign of the GymTalk Flutter app (`LearningEnglish/app`). Goal: professional yet highly motivating, strong gamification, unified look across all areas, fewer popups, easier navigation, larger type. Covers: onboarding (3 steps), Pro paywall, 4 root tabs, workout session, flashcard review, Wealth home, tab bar + mini player, XP toast + celebration overlay. Dark + light themes.

## About the Design Files
`GymTalk Prototype.dc.html` is a **design reference built in HTML** (open it in a browser; it needs `support.js` + `assets/` next to it). It is a working prototype of intended look and behavior, **not production code**. Recreate it in the existing Flutter codebase using its patterns (Riverpod, `AppColors`/`AppTextStyles` in `lib/core/theme/app_theme.dart`, `RootShell`/`RootTab` in `lib/core/navigation/`, real providers like `DailyProgressStore`, `SrsStore`, `todayWorkoutPlanProvider`, `myLearningXpProvider`). All strings go through `ref.tr(...)` / `app_strings.dart`.

## Fidelity
**High-fidelity.** Colors, type, spacing, radii and interactions are final. Recreate pixel-accurately on a 390×844 logical frame. Content numbers are sample data — wire to real providers.

## Design Tokens

### Colors — Dark (default)
| Token | Value | Use |
|---|---|---|
| bg | `#08090B` | screen background |
| s1 | `#121418` | cards |
| s2 | `#1B1E23` | inner fills, progress tracks, chips |
| bd | `rgba(255,255,255,0.08)` | 1px card borders, dividers |
| tx | `#F4F5F7` | primary text |
| tx2 | `#A3A8B1` | secondary text |
| tx3 | `#6E737C` | labels, inactive icons |
| inv / oninv | `#F4F5F7` / `#0B0C0E` | primary neutral CTA (white pill, black text) |
| glass | `rgba(18,20,24,0.86)` + blur 20 | tab bar, mini player |

### Colors — Light
bg `#F4F4F2`, s1 `#FFFFFF`, s2 `#ECECE9`, bd `rgba(12,14,18,0.08)`, tx `#0C0D10`, tx2 `#585D66`, tx3 `#8A8F97`, inv `#0C0D10`, oninv `#FFFFFF`, glass `rgba(255,255,255,0.86)`.

### Area accents (same perceived lightness; defined in OKLCH)
| Accent | Dark | Light | Area |
|---|---|---|---|
| red | `oklch(0.64 0.22 25)` ≈ `#E5484D` | `oklch(0.56 0.22 25)` ≈ `#C8303A` | Train / Tập |
| blue | `oklch(0.68 0.16 262)` ≈ `#6E8FF5` | `oklch(0.54 0.18 262)` ≈ `#3F63D6` | Learn / Học |
| gold | `oklch(0.80 0.14 82)` ≈ `#E8B84A` | `oklch(0.66 0.14 72)` ≈ `#B8862A` | Rewards, XP, Progress, Wealth, Pro |
| teal | `oklch(0.80 0.13 172)` ≈ `#3DD6B5` | `oklch(0.58 0.12 172)` ≈ `#1F9B80` | Speaking / Nói, positive deltas |
| streak orange | `#FF8A3D` | same | streak flame only |

Tints: accent at 12–18% alpha (`redT` 0.18, `blueT` 0.16, `goldT` 0.13, `tealT` 0.16). `goldB` = gold @ 35% (45% light) — border of rank / total-assets hero cards. Text on gold: `#1A1406`. Text on red: `#FFFFFF`. Text on teal button: `#04201A`.

Photo cards (hero images) stay dark in both themes with white text.

### Typography
- Headings / numbers: **SpaceGrotesk** 700 (`assets/fonts/SpaceGrotesk.ttf`)
- Body / labels: **Manrope** 600–800 (`assets/fonts/Manrope.ttf`)

| Role | Font | Size / weight / tracking |
|---|---|---|
| Onboarding hero | SpaceGrotesk | 44 / 700 / -1.5, lh 1.02 |
| Screen hero title | SpaceGrotesk | 30 / 700 / -0.8, lh 1.05 |
| Onboarding step title | SpaceGrotesk | 32 / 700 / -0.8, lh 1.1 |
| Big stat number | SpaceGrotesk | 40 / 700 / -1.5 (unit 18, tx3) |
| Ring stats | SpaceGrotesk | 26 / 700 / -0.5 (unit 14 Manrope tx2) |
| Card title | SpaceGrotesk | 20 / 700 |
| Top-bar name | SpaceGrotesk | 21 / 700 / -0.3 |
| Row title | Manrope | 15 / 800 |
| Body / sub | Manrope | 13–15 / 600–700, tx2 |
| Overline label | Manrope | 12 / 800 / +1.4, UPPERCASE, tx3 or accent |
| Tab label | Manrope | 12 / 800 active, 600 inactive |
Minimum text size 12.

### Radii & spacing
- Big cards: 28 · stat/skill cards: 22 · inner tiles / quest icons: 14–16 · buttons: 999 (pill) · phone-level sheets: 32.
- Screen horizontal padding 16; gap between cards 14; card padding 20 (stat cards 16).
- Primary CTA height 58 (onboarding/paywall), 52–54 in cards. Min touch target 44.
- No drop shadows on cards; separation via s1 on bg + 1px `bd` border.

### Icons
Material Symbols Rounded (Flutter: `Icons.*_rounded` or `material_symbols_icons` package). Filled variant for active/accent icons.

## Global Shell

### Top bar (all 4 tabs), height ~56, padding 6/2
- Avatar 48: conic progress ring in gold = XP % to next level (3px), inner circle s1 with initials; level badge (gold pill, 10/800, 2px bg border) bottom-right.
- Greeting "Chào buổi sáng," 13/600 tx2 + name 21 SpaceGrotesk.
- Streak chip: 40h pill s1 + bd, orange flame + number 16 SpaceGrotesk.
- `apps` icon button 40 → opens Wealth (replaces old AppSwitcherPill).
- Messages icon button 40 with 8px red unread dot.

### Tab bar (replaces `GymTalkTabBar`)
Height 88 (incl. home indicator), glass bg + blur, top border bd. 5 slots: **Hôm nay** (wb_sunny) · **Tập** (fitness_center) · center **Quick Start** · **Học** (school) · **Tiến độ** (insights).
- Active color per tab: Hôm nay = tx, Tập = red, Học = blue, Tiến độ = gold; inactive tx3. Active icon filled.
- Quick Start: 58 circle, inv bg, oninv `bolt` icon 32, 4px border in bg color, raised -18px. Action: if today's workout not done → workout session; else → flashcard review.

### Mini player (replaces `CenterMediaButton` placement)
Floating 60h bar, 12px side inset, 94px from bottom, radius 20, glass. 44 cover (radius 12), title 14/800 ellipsis, sub "Artist · Có lời song ngữ" 12 tx2, play/pause 30 filled icon. 2px progress line at bottom edge (tx). Toggleable via setting.

## Screens

### 1. Onboarding — Welcome (`onb1`)
Full-bleed black; `hero.jpg` anchored top-right (height 560, offset right -260), gradient to black from 30%→70%. Bottom block (padding 24, bottom 44, gap 22): red dot + "GYMTALK" 12/800/+2 · hero "Khỏe thân. / Giỏi tiếng Anh. / Mỗi ngày." (last line red) · body 16 `#B8BCC4` "Một kế hoạch cho cả cơ bắp và vốn từ. Tập xong một hiệp, học thêm một từ." · white pill CTA "Bắt đầu miễn phí →" (58h) · ghost "Tôi đã có tài khoản" (52h).

### 2. Onboarding — Goals (`onb2`)
Padding 64/20/36. Back button 44 circle + 3-segment progress (6h, radius 3; done = tx, todo = s2). Overline "BƯỚC 1 / 3", title "Bạn muốn đạt được gì?", sub "Chọn bao nhiêu cũng được." 2×2 grid (gap 12) of multi-select cards, min-height 124, radius 22, s1, **2px border** = goal color when selected else bd; icon 30 filled in goal color top-left, check_circle / radio_button_unchecked top-right. Goals: Tăng cơ (red, "Giáo án 8 tuần"), Giảm mỡ (orange, "Cardio + dinh dưỡng"), Giao tiếp (blue, "Nói tự tin hơn"), Thi chứng chỉ (gold, "TOEIC · IELTS"). CTA "Tiếp tục" (inv).

### 3. Onboarding — Daily time (`onb3`)
Same header, step 2/3. Title "Mỗi ngày bạn có bao nhiêu phút?". Single-select rows (radius 20, padding 16/18, 2px border tx when selected): big number 30 SpaceGrotesk + label/sub: 15 "Nhẹ nhàng — 1 bài tập ngắn + 5 từ", 30 "Đều đặn — Buổi tập gọn + 12 từ" (default), 45 "Nghiêm túc — Buổi tập đầy đủ + 12 từ + nói", 60 "Hết mình — Tập, học, luyện thi". Live summary box (s2, radius 20) "KẾ HOẠCH CỦA BẠN": train icon + "4 buổi/tuần", learn icon + "12 từ/ngày" (map: 15→3/5 từ, 30→4/12 từ, 45→4/12 từ + nói, 60→5/20 từ). CTA "Tạo kế hoạch" → paywall. Maps onto existing `GymTalkSetupSheet` data.

### 4. Paywall (`paywall`)
Always dark (#000). 300h hero with `hero.jpg`, close button (40, rgba white .14) top-left at y 60; gold pill "GYMTALK PRO" + title "Tiến bộ nhanh / gấp đôi." 34. Feature list (gap 14; 36 icon tile #15171B radius 12, gold filled icon, 15/700 text): Giáo án tự điều chỉnh theo sức bạn · PT AI nói tiếng Anh, không giới hạn phút · Chấm phát âm chi tiết từng âm · Toàn bộ đề TOEIC và IELTS · Không quảng cáo. Plan cards (#101114, radius 20, 2px border gold when selected else `#24272C`): **Theo năm** 899.000 ₫/năm, 74.900 ₫/tháng, badge "TIẾT KIỆM 42%" (default selected); **Theo tháng** 129.000 ₫/tháng "Hủy bất cứ lúc nào". Gold CTA "Dùng thử 7 ngày miễn phí" + fine print 12 `#8A8F97` "Không trừ tiền hôm nay. Nhắc bạn 2 ngày trước khi hết hạn dùng thử." Prices are placeholders — confirm with business.

### 5. Hôm nay (Today) — replaces `today_screen.dart`
Order: top bar → Rings card → Today workout card → Daily quests card.
- **Rings card** (s1, radius 28, padding 20, gap 18): overline "MỤC TIÊU HÔM NAY" + date right. Left: 164px concentric rings, stroke 14, round caps, track = accent tint: outer r72 red = Tập (workouts/1 or rest day), middle r55 blue = Học (wordsReviewed/12), inner r38 teal = Nói (speakAttempts/5). Center: overall % 26 SpaceGrotesk. Right column: 3 stats (label 13/800 in accent, value 26 + unit). Animate dash 600ms. Bottom (top border bd, pt 14): 7-day streak strip T2…CN — 34 circles: completed = solid orange + white flame; today = 2px orange ring + orange flame (fills when all rings done); future = 2px bd ring.
- **Today workout card** (radius 28, #0A0A0A, min-h 220, photo `today_plan.jpg` right with left→right dark gradient 38%): chip "NGÀY 3 · ĐẨY" (red tint, `#FF6B6F`), "Tuần 3/8", title 26 "Tăng cơ toàn thân 8 tuần", meta "8 bài · 26 hiệp · ~45 phút", red CTA "▶ Bắt đầu tập" (52h) + "+120 XP" gold. After completion: CTA teal "✓ Đã tập xong" → Progress. Covers the `_PrimaryAction` states (no plan → "Chọn giáo án"; rest day → review).
- **Daily quests card**: title "Nhiệm vụ hằng ngày" + "n/4". Rows (padding 12 0): 44 icon tile (radius 14, accent tint) · title 15/800 + sub 13 tx2 · "+XP" 13/800 gold · 28 circle check (2px tx3 border → gold filled with check when done; title gets line-through + 55% opacity). Quests: Ôn 12 thẻ từ đến hạn (+30, blue, opens review) · Luyện phát âm 5 câu (+20, teal) · Nghe và nhắc lại khi chạy (+25, teal, hands-free) · Nói chuyện với PT AI (+40, red). These replace the old list of `_ActionCard`s (Review/Speak/HandsFree/TrainerChat). Footer chest box (goldT, radius 18): `redeem` icon, label ("Hoàn thành N nhiệm vụ nữa để mở rương" / "Rương đã sẵn sàng!" / "Đã mở rương hôm nay"), 8h gold progress bar, gold "Mở" button when 4/4 → +100 XP celebration.

### 6. Tập (Train) — replaces `fitness_home_screen.dart`
- Hero (250h, radius 28, `hero.jpg` right, gradient black 30%→transparent 80%): overline red "CẤP CƠ THỂ 14", title "Kỷ luật hôm nay / là kết quả / ngày mai.", bottom: "Lên cấp 15 · 62%" + 6h red bar (max-w 190).
- 2×2 stat grid (radius 22, padding 16): Buổi tập tuần này **3**/4 + 4 segment bar · Tổng khối lượng **7.5** tấn + "+12% so với tuần trước" teal · Nhịp tim nghỉ **78** bpm "Đo bằng camera" · Calo nạp vào **512** kcal + gold bar.
- "Buổi hôm nay" card: rows `01` (18 SpaceGrotesk tx3) · name 15/800 + target 13 · "50 kg" 16 SpaceGrotesk; red full-width CTA "Bắt đầu tập".
- "Giáo án" + "Xem tất cả"; horizontal scroll of 150×190 photo cards (radius 22, bottom gradient, title 16 + level 12).

### 7. Học (Learn) — replaces English `home_screen.dart`
- Level card: 64 tile (blueT, radius 20) "B1" 26 blue; "Trung cấp" 19 + "Còn 420 XP tới B2"; 8h blue bar.
- Hero (#050B16, radius 28, `hero_daily_words.jpg` right): overline `#8FB0FF` "TỪ VỰNG HẰNG NGÀY", "Học 12 từ / hôm nay", "Chủ đề: Phòng gym. 8/12 từ đã ôn." `#AFC0DA`, white CTA "▶ Tiếp tục" → review.
- 2×2 skills (radius 22): outline icon blue 26, % right, name 16/800, sub, 5h blue bar: Từ vựng 64% · Ngữ pháp 41% · Đọc sách 28% · Luyện viết 17%.
- Speaking card: overline teal "LUYỆN NÓI", "Nghe kỹ. Nói lại.", sub; 64 teal mic button. 2×2 mode tiles (s2, radius 16): Phát âm · Rảnh tay · Chuyện ngắn · Trò chuyện AI.
- 3 exam tiles: TOEIC · IELTS · Đố vui.

### 8. Tiến độ (Progress) — replaces `progress_screen.dart`
- Rank card (s1, goldB border): 72 tile goldT + `diamond` 44 gold; "HẠNG CỦA BẠN", "Kim cương III" 24, "Cấp 8 · 2.480 XP"; 10h gold XP bar + "Cấp 8" / "520 XP tới cấp 9". (Use `gymtalk_rank.dart`.)
- Two level tiles: Cấp cơ thể 14 "Vận động viên" (red) · Tiếng Anh B1 "Trung cấp" (blue) — independent progressions (ADR 0002).
- "Tuần này" stacked bar chart (7 cols, 110px plot, gap 10; blue = learn minutes on top, red = train minutes; radius 6, 3px gap; 1 min = 1.6px) + legend + total "5 giờ 48 phút".
- League "Giải Kim cương" + "Còn 3 ngày": rows rank (gold for top 3) · 36 avatar · name · XP. Current user row highlighted goldT. Footer "Top 3 lên hạng Cao thủ". (Use `friends_challenge_repository.dart` / social.)
- Badges 3-col grid: 64 tile radius 22, filled icon; locked = 50% opacity with s2 bg.

### 9. Workout session (`workout`)
Full screen, no tab bar. 280h photo header, close button, 8-segment exercise progress (done white, current red, todo white 25%), "n/8"; muscle 13 + name 28. Sets table card: columns HIỆP / KG / LẦN / ✓ (52 1fr 1fr 48), numbers 24 SpaceGrotesk, 44 check buttons (radius 14; done = red fill). "HỌC TRONG LÚC NGHỈ" card (blueT): rest timer 01:30, phrase "One more rep!" + "Thêm một lần nữa!", 52 blue mic (counts a speak attempt). Primary: disabled s2 "Hoàn thành k/4 hiệp" → red "Bài tiếp theo" → on last exercise "Hoàn thành buổi tập". Secondary outline "Kết thúc buổi tập". Finish → +120 XP, train ring full, weekly sessions +1, celebration.

### 10. Flashcard review (`review`) — maps to `SrsReviewScreen`
Close + 8h blue progress + "n/5". Big card (radius 32, s1): overline "PHÒNG GYM", word 46, IPA 17 tx2; tap to flip → divider + meaning 26 blue + example 16; hint "Chạm để xem nghĩa". Grade buttons (64h, radius 20; 35% opacity until flipped): Quên/1 phút (red tint), Khó/1 ngày (gold tint), Nhớ/4 ngày (teal tint). Deck end → +30 XP, review quest done, celebration.

### 11. Wealth (`wealth`)
Back pill "‹ GymTalk" + centered "Tài chính". Total card (goldB border): "TỔNG TÀI SẢN", "1.284.500.000 ₫" 38, "+2,4% tháng này · +30,1 tr ₫" teal; 12h segmented allocation bar (3px gaps) + 2×2 legend (Tiền mặt tx2, Cổ phiếu gold, Crypto blue, Vàng `#C99A2E`). 4 action tiles 60 (Thu, Chi, Chuyển, Quét QR; gold icons). Budget card "Ngân sách tháng 9" 11,2 tr / 15 tr ₫ + gold bar. Recent transactions list (44 icon tile s2; positive amounts teal). Wealth now uses the same tokens as the rest of the app (gold accent only).

## Interactions & Behavior
- **XP toast**: gold pill at top (y 58), SpaceGrotesk 16, "+N XP"; animation 1.8s: slide down 12px + fade in (15%), hold, fade out.
- **Celebration overlay**: black 86% + blur 8. 150 gold radial badge "+N XP" — pop-in 0.6s `cubic-bezier(.2,1.4,.4,1)` (scale .4→1.08→1), then pulsing gold ring glow 1.8s infinite. Title 30, sub 16, chips "Chuỗi N ngày" / "XP total", white CTA "Tuyệt vời" → back to Today.
- Rings / progress bars animate width/dash 300–600ms ease.
- Streak increments when workout is completed that day.
- Theme: follow system with in-app override (dark/light).
- Remove the per-area background images/planet painter (`HomeDesignBackground`, `WealthDesignBackground`, `ScreenBackground` photo layer): flat `bg` everywhere; photos only inside hero cards.

## State Management
- `xp`, `level`, `streak` → existing `myLearningXpProvider`, `DailyProgressStore.bodyBrainStreak`.
- Rings: `DailyProgressStore.today` (`workouts`, `wordsReviewed`, `speakAttempts`, `restDay`) with goals `kDailyTrainGoal`/`kDailyLearnGoal`/`kDailySpeakGoal`.
- New: daily quests (id, done, xp) + `chestOpened` per day — persist locally and sync via `gymTalkSyncProvider`.
- Workout session: current exercise index, per-set done flags (from `todayWorkoutPlanProvider`), feeds `workoutOutboxProvider`.
- Review: SRS queue from `SrsStore`, flip state, grade → SRS scheduling.
- Onboarding answers (goals multi-select, minutes) → `GymTalkSetupSheet` logic → program recommendation.
- `rootTabProvider` unchanged (4 tabs); Quick Start is an action, not a tab.

## Assets
In `assets/` (copied from the app repo):
- `fonts/SpaceGrotesk.ttf`, `fonts/Manrope.ttf` — already in `app/assets/fonts`.
- `img/hero.jpg`, `today_plan.jpg`, `program_*.jpg` — from `app/assets/fitness/home/`.
- `img/hero_daily_words.jpg` — from `app/assets/home/`.
- Icons: Material Symbols Rounded (no custom icon files).

## Files
- `GymTalk Prototype.dc.html` — the full interactive prototype (open in a browser; left panel jumps to any screen and toggles Dark/Light). Screen data and interaction logic are in the `<script data-dc-script>` block at the bottom.
- `support.js` — runtime for the prototype (not for production).
- `assets/` — fonts and images used.

# Nghiên cứu: nguồn nhạc royalty-free cho app

Xem quy tắc bắt buộc đầy đủ trong [CLAUDE.md](../CLAUDE.md#nguồn-nhạc--quan-trọng-về-bản-quyền).

---

## 1. Điểm nghẽn thật là gì

App cần **4 thứ** cho mỗi bài hát, không phải 1:

| # | Cần | Khó ở đâu |
|---|---|---|
| 1 | File audio có giấy phép cho phép **thương mại** | Dễ — nhiều nguồn |
| 2 | Audio đó có **giọng hát tiếng Anh thật, lời rõ** | Khó — đa số nhạc royalty-free là instrumental |
| 3 | **Lời bài hát** dùng được về mặt pháp lý | ⚠️ Đây mới là chỗ dễ sai (xem §2) |
| 4 | Bản dịch tiếng Việt + timestamp | Tự làm được (script + duyệt tay) |

Nghiên cứu trước đây kết luận điểm nghẽn là **(3) — phải tìm nghệ sĩ tự đăng lyrics công khai**, nên đã loại Pixabay/ccMixter. Kết luận đó **không còn đúng nữa**, vì lý do ở §3.

---

## 2. Cạm bẫy pháp lý quan trọng nhất: bản ghi ≠ bài hát

Một bài hát có **2 bản quyền riêng biệt**:

- **Sound recording** — bản thu âm cụ thể
- **Musical composition** — giai điệu + **lời bài hát**

Giấy phép CC dán trên 1 track **chỉ bao trùm phần mà người đăng thực sự sở hữu**. Nếu một người remix đăng bản thu của họ dưới CC-BY nhưng lời do người khác viết, thì CC-BY đó **không** cho ta quyền với lời bài hát — mà lời chính là thứ app này dùng nhiều nhất.

**Hệ quả cho việc chọn nguồn:**

> ✅ Ưu tiên tuyệt đối **singer-songwriter tự viết + tự thu + tự sở hữu toàn bộ**, phát hành dưới **CC 4.0** (bản 4.0 nói rõ áp dụng cho *mọi* quyền tác giả và quyền liên quan → bao trùm cả lời).
>
> ⚠️ Nền tảng remix (ccMixter) dùng được nhưng **từng track phải truy ngược chuỗi nguồn**: bản acapella gốc là ai, license gì.

Josh Woodward hợp lệ trọn vẹn chính vì lý do này — anh tự viết, tự hát, tự sở hữu tất cả.

---

## 3. Phát hiện mới: không cần nghệ sĩ đăng sẵn lyrics

Với track **CC-BY / CC0 mà license bao trùm cả phần lời** (§2), ta được phép tạo **tác phẩm phái sinh** — và "chép lại lời từ chính bản thu" chính là một tác phẩm phái sinh hợp lệ.

Repo đã có sẵn công cụ làm việc này: `scripts/realign_lyrics.py` chạy **faster-whisper**, vốn đã xuất ra **transcript + timestamp cấp-từ**. Hiện script chỉ lấy timestamp và bỏ transcript đi (cố ý, để ASR không nghe nhầm làm sai lời đã viết sẵn) — nhưng với bài **chưa có lời**, chính transcript đó là bản nháp lời.

Quy trình mới cho 1 bài chưa có lyrics:

```
audio CC-BY  →  Whisper (đã có sẵn)  →  transcript nháp + timestamp
             →  người duyệt/sửa lời (~5–10 phút/bài)
             →  dịch sang tiếng Việt + duyệt
             →  songs_data.dart
```

Việc "duyệt lại lời máy chép" rẻ hơn rất nhiều so với "tìm nghệ sĩ chịu đăng lyrics". Điều này **mở lại** toàn bộ các nguồn từng bị loại vì lý do "không có lyrics công khai".

⚠️ Bắt buộc có người đọc lại: ASR nghe nhạc có nền rất dễ sai, mà đây là app **dạy tiếng Anh** — sai 1 từ là dạy sai.

---

## 4. Bảng nguồn (đã cập nhật)

| Nguồn | License | Dùng cho app này? | Ghi chú |
|---|---|---|---|
| **Josh Woodward** | CC-BY 4.0, **200+ bài** | ✅ **Đang dùng — còn ~180 bài chưa khai thác** | Singer-songwriter tự sở hữu toàn bộ. Lyrics đăng công khai trên từng trang bài (kể cả JSON-LD `MusicComposition.lyrics`). Chỉ quảng cáo / nhạc chờ / nhạc trong cửa hàng mới cần mua license riêng — app học ngôn ngữ **không** thuộc nhóm đó |
| **ccMixter — mục "Free for Commercial Use"** | CC-BY (~4.200 track) | ⚠️ Dùng được, **phải kiểm từng track** | Kho lớn nhất còn lại có giọng hát. Nhưng là nền tảng remix → phải truy chuỗi nguồn theo §2. Attribution cần đủ TASL (Title–Author–Source–License) |
| **Free Music Archive** | Tùy track | ⚠️ Dùng được, lọc thủ công | Có bộ lọc license nâng cao (`freemusicarchive.org/search?adv=1`) chọn riêng CC-BY / CC-BY-SA. Không còn API public → thêm tay |
| **CCTrax / Chosic** | Tùy track, hiện license từng bài | ⚠️ Dùng được, lọc thủ công | Chosic hiện sẵn license + sẵn đoạn attribution copy được cho từng track |
| **Brad Sucks** (bradsucks.net) | **CC-BY-SA** 3.0 | ⚠️ Cần quyết định (xem §5) | Pop/rock, giọng Anh thật, **có kèm file lyrics**, tự sở hữu toàn bộ. Ứng viên tốt nhất ngoài Josh Woodward — nếu chấp nhận điều kiện ShareAlike |
| **Pixabay Music** | Pixabay Content License | ❌ **Đổi kết luận — xem §6** | License cấm phân phối content "trên cơ sở standalone"; app này phát nguyên file mp3 → rủi ro thật |
| **Pexels** | Pexels License | ❌ Không dùng được, **2 lý do** | (1) Pexels **không có nhạc** — mọi video trên Pexels đều đăng không kèm tiếng, và chính Pexels chỉ người dùng sang Pixabay để lấy nhạc. (2) Kể cả nếu có, Pexels License dùng **đúng cùng một điều khoản "Standalone"** với định nghĩa y hệt Pixabay (2 bên cùng thuộc Canva) → dính đúng vấn đề ở §6 |
| **Jamendo API** | CC theo track | ❌ Đã loại từ trước | API chỉ miễn phí phi thương mại |
| **Incompetech, Chris Zabriskie, Kevin MacLeod, Scott Buckley…** | CC-BY | ❌ Không dùng được cho tính năng chính | **Instrumental** — không có lời thì không dạy tiếng Anh được |
| **Bản ghi thuộc public domain** | PD | ❌ Không phù hợp | Tính tới 2026 chỉ bản thu **từ 1925 trở về trước** mới hết hạn (Music Modernization Act, mốc 100 năm). Chất lượng thu âm thời tiền-điện và tiếng Anh cổ → không hợp người mới học |
| **CC-BY-NC / CC-BY-ND (bất kỳ nguồn nào)** | — | ❌ Cấm tuyệt đối | NC cấm thương mại; ND cấm tạo phái sinh → mà lyrics dịch + căn giờ **chính là** phái sinh |

---

## 5. CC-BY-SA: dùng được, nhưng có điều kiện

CC-BY-SA **cho phép thương mại**, nên không bị loại như NC/ND. Vấn đề là điều kiện ShareAlike lan tới đâu:

- **Code của app: KHÔNG bị ảnh hưởng.** Nhét 1 bài hát chưa chỉnh sửa vào app là "collection / mere aggregation", không phải "adaptation" → ShareAlike không đụng tới source code.
- **Nhưng phần lyrics đã dịch + căn giờ thì CÓ.** Đó rõ ràng là tác phẩm phái sinh của lời gốc → phần dữ liệu đó phải phát hành lại dưới **chính CC-BY-SA**.

Nói cách khác: dùng CC-BY-SA nghĩa là chấp nhận **các dòng lyric Anh-Việt của những bài đó là tài sản mở**, ai cũng copy lại được. App vẫn đóng, vẫn bán được.

**Khuyến nghị:** cứ ưu tiên CC-BY / CC0 cho sạch. Chỉ mở sang CC-BY-SA nếu cần thêm số lượng — và khi mở thì tách lyrics của nhóm đó ra file riêng có ghi rõ license, đừng trộn lẫn.

> ⚠️ Đây là phân tích kỹ thuật đọc từ điều khoản license, **không phải tư vấn pháp lý**. Trước khi phát hành thương mại thật nên có người hiểu luật xem lại phần này.

---

## 6. Đính chính: Pixabay không an toàn cho app này

Tài liệu trước ghi Pixabay là ✅ "miễn phí thương mại, không cần ghi công". Điều đó **đúng với video/podcast nhưng không đúng với app này**.

Pixabay Content License cấm:

> *sell or distribute Content (either in digital or physical form) on a **Standalone** basis*
>
> — trong đó "Standalone" = *"no creative effort has been applied to the Content and it remains in substantially the same form as it exists on the Service"*

App này **host file mp3 và stream nguyên vẹn cho người dùng nghe**. File audio được giao đúng dạng gốc; phần sáng tạo ta thêm vào (lyrics, dịch, chấm phát âm) nằm *quanh* bài hát chứ không sửa bản thân bài hát. Đây là đúng cái mà điều khoản trên nhắm tới.

Khác biệt then chốt so với video YouTube: ở đó nhạc là **nền** cho nội dung khác; ở đây bài hát **chính là** nội dung người dùng tới nghe.

→ **Không thêm track Pixabay vào app.** Nếu vẫn muốn dùng, phải hỏi Pixabay bằng văn bản trước.

**Pexels cũng vậy — và còn không dùng được ngay từ đầu.** Pexels là câu hỏi tự nhiên tiếp theo (cùng nhà Canva với Pixabay), nhưng:

1. **Pexels không có nhạc.** Mọi video trên Pexels đều đăng **không kèm tiếng**; chính trang trợ giúp của Pexels chỉ người dùng sang Pixabay khi cần nhạc. Không có kho audio để mà lấy.
2. Kể cả nếu có, **Pexels License dùng đúng cùng điều khoản "Standalone"**, định nghĩa y hệt (*"no creative effort has been applied to the Content and it remains in substantially the same form"*), và liệt kê rõ cả **audio** trong danh sách bị cấm phân phối standalone → dính đúng vấn đề vừa nói ở trên.

Nói chung: **cả họ nhà stock-media license (Pixabay, Pexels, và các site cùng mô hình) đều không hợp với app này**, vì mô hình của app là *giao nguyên bài hát cho người dùng nghe* — đúng thứ mà loại license đó cấm. Chỉ **Creative Commons / public domain** mới cho phép việc đó.

---

## 7. Mở rộng thế nào cho có quy mô

### Cái gì thực sự chặn quy mô

Không phải audio. Nhạc CC có vocals thì tìm được. Thứ chặn quy mô là **việc xác minh quyền với PHẦN LỜI, tính theo từng track** (§2) — đó là công của con người, không tự động hoá được, và nó tỉ lệ thuận với số bài.

Nên câu hỏi đúng không phải *"nguồn nào nhiều bài nhất"* mà là:

> **Một lần xác minh mở khoá được bao nhiêu bài?**

Xếp theo tiêu chí đó:

| Hạng | Đơn vị xác minh | Tỉ lệ | Ví dụ |
|---|---|---|---|
| **A** | 1 nghệ sĩ tự viết + tự thu + tự sở hữu, giấy phép áp cho **cả catalog** | 1 lần kiểm → **hàng trăm bài** | Josh Woodward (200+), Brad Sucks (CC-BY-SA) |
| **B** | 1 netlabel có chính sách giấy phép áp cho cả hãng | 1 lần kiểm → **1 album** | blocSonic (cần xác minh, xem dưới) |
| **C** | Nền tảng từng-track | 1 lần kiểm → **1 bài** | FMA, ccMixter |

Hạng C **không mở rộng được** — mỗi bài là một lần truy chuỗi bản quyền. Chỉ dùng nó để **lấp lỗ hổng cụ thể** (cần một giọng nữ, cần một giọng Anh-Anh), đừng dùng để tăng số lượng.

Ưu tiên đúng: **đi tìm thêm "Josh Woodward khác"** — nghệ sĩ tự sở hữu toàn bộ và phát hành cả catalog dưới CC-BY. Một nghệ sĩ như vậy đáng giá bằng hàng trăm lần lục FMA.

### Thứ tự triển khai

**Bước 1 — Khai thác nốt Josh Woodward (rủi ro ~0).** Đang dùng **20/200+** bài. Cùng nghệ sĩ, cùng giấy phép đã kiểm chứng, lời đã đăng sẵn, adapter đã có. Đưa thư viện lên **60–80 bài** là chuyện công sức dịch, không phát sinh rủi ro pháp lý mới. Cần lọc theo tiêu chí sư phạm: lời rõ, tốc độ vừa, từ vựng phổ thông, không chủ đề nhạy cảm.

**Bước 2 — Đa dạng hoá giọng (quan trọng về mặt sư phạm).** 20 bài hiện tại đều **một giọng nam Mỹ duy nhất**. Người học chỉ quen 1 giọng thì nghe người khác nói sẽ hụt. Cần giọng nữ, giọng Anh-Anh, tốc độ khác nhau. Đây là chỗ hạng C hữu ích: dùng `fma`/`ccmixter` để lấp đúng những lỗ hổng đó, chấp nhận chi phí kiểm từng bài.

**Bước 3 — Tìm nguồn hạng A/B mới.** Việc đáng đầu tư nhất nhưng chưa làm được trong phiên này (bị chặn mạng, §12). Hướng tìm:

- **Netlabel CC** — `blocSonic` là netlabel chuyên phát hành nhạc CC. ⚠️ **Chưa xác minh**: rất nhiều netlabel dùng CC-BY-**NC** (cấm thương mại → loại thẳng). Phải mở trang chính sách giấy phép của hãng và kiểm trước khi mừng.
- **Danh sách nghệ sĩ CC** trên wiki Creative Commons và các bài tổng hợp — lọc lấy người có **cả catalog** dưới CC-BY và **tự viết bài**.
- Tiêu chí lọc nhanh khi gặp ứng viên mới: *(1)* có vocals tiếng Anh không, *(2)* nghệ sĩ có tự viết lời không, *(3)* giấy phép áp cho cả catalog hay từng bài, *(4)* có phải NC/ND không.

**Bước 4 — Quyết định về CC-BY-SA.** Mở ra Brad Sucks và một mảng hạng A nữa. Chỉ làm sau khi chốt §5.

### Đã loại vì không hợp mục đích học tiếng Anh

Phần lớn nhạc "royalty-free" là **instrumental** (Incompetech, Chris Zabriskie, Kevin MacLeod, Scott Buckley, Alexander Nakarada…). Không có lời thì không dạy tiếng Anh được, dù giấy phép có sạch tới đâu. Pipeline chặn thẳng track instrumental ở §8 để khỏi mất công tải về rồi mới phát hiện.

---

## 8. Công cụ: pipeline nạp bài hát

`scripts/add_songs.py` — **không gắn với riêng nguồn nào**. Mỗi nguồn là một adapter trong `scripts/song_sources.py`; cổng gác bản quyền nằm riêng trong `scripts/song_licensing.py`.

```bash
python scripts/add_songs.py list-sources                        # nguồn + giấy phép chấp nhận
python scripts/add_songs.py fetch joshwoodward TheSimpleLife    # → content/pending/<slug>.json
python scripts/add_songs.py verify the-simple-life              # chấm bản quyền + độ sẵn sàng
python scripts/add_songs.py emit the-simple-life                # chèn vào app
python scripts/realign_lyrics.py --only the-simple-life         # căn timestamp — BẮT BUỘC
```

### Nguồn đang hỗ trợ

| Adapter | Adapter tự đọc được gì | Người phải tự làm gì |
|---|---|---|
| `joshwoodward` | Metadata, **lời có sẵn**, giấy phép **cả 2 phần** | Chỉ dịch |
| `fma` | Giấy phép **bản thu** (từ link deed CC) | Xác minh **ai giữ bản quyền phần lời**, chép lời bằng ASR, dịch |
| `ccmixter` | Giấy phép bản ghi remix + **danh sách nguồn gốc** | Truy từng nguồn gốc trong chuỗi, xác minh phần lời, chép lời, dịch |
| `manual` | Không gì cả | Tất cả |

Adapter **khai báo được gì thì khai, không đoán**. Chỗ nào không tự biết được (điển hình: giấy phép **phần lời** trên nền tảng nhiều nghệ sĩ) thì để trống, và cổng gác sẽ chặn cho tới khi có người điền.

Chỉ `joshwoodward` được phép tự điền giấy phép cho cả phần lời — vì anh tự viết lời, tự thu âm, tự giữ bản quyền cả hai, phát hành toàn bộ catalog dưới CC-BY 4.0. Với nền tảng nhiều nghệ sĩ thì tuyệt đối không được suy như vậy (§2).

### Bốn cổng gác

1. **Bản quyền** — khai báo **riêng** giấy phép cho *bản thu* và cho *phần lời*, mỗi bên kèm `evidence_url` (trang chứng minh) và `verified_by` (`adapter` hay `human`). Quy tắc vàng: **không rõ = từ chối**.
   - NC → chặn (cấm thương mại). ND → chặn (dịch + căn giờ **là** phái sinh).
   - SA → chặn, trừ khi chạy với `--allow-share-alike`; khi đó nghĩa vụ ShareAlike được in ra và ghi vào `ATTRIBUTION.md`.
   - Giấy phép họ stock-media (Pixabay/Pexels…) → chặn kèm đúng lý do ở §6.
   - Lời chép bằng **ASR** → bắt buộc `verified_by: human` cho phần lời, vì chép lời từ bản thu là tạo phái sinh của **phần lời**, không phải của bản thu.
   - Track remix còn nguồn gốc chưa truy → chặn.
2. **Có lời hát** — track instrumental hoặc dưới 4 dòng lời bị từ chối. App dạy tiếng Anh bằng lời bài hát; giấy phép đẹp mấy cũng vô dụng nếu không có lời.
3. **Người dịch** — `emit` từ chối chạy khi còn dòng `vi` trống.
4. **Căn timestamp** — bài vừa chèn có mọi dòng ở giây 0; chưa căn mà commit thì test karaoke đỏ.

### Ghi công

`emit` tự ghi vào `ATTRIBUTION.md`, trong một khối có marker, **riêng giấy phép của bản thu và của phần lời** kèm link chứng minh — vì có track hai phần khác giấy phép nhau, và 6 tháng sau không ai nhớ lại được.

### Test

`scripts/test_add_songs.py` (37 test, chạy bằng `python -m unittest discover -s scripts -p 'test_*.py'`, đã gắn vào CI). Mỗi adapter tách `parse(html, ref)` thuần tuý khỏi `fetch(ref)` nên phần đọc trang test được bằng fixture HTML, **không cần mạng**.

⚠️ Riêng phần `fetch` (gọi mạng thật) **chưa chạy thử được** — phiên viết bị chặn egress (§12). Nếu adapter không đọc được trang, dùng `--audio-url` để chỉ tay link mp3, hoặc dùng adapter `manual`.

## 9. Checklist bắt buộc khi thêm 1 bài hát

1. Tải file gốc, **lưu lại link trang license của đúng track đó** (không phải link trang chủ của nguồn).
2. Xác nhận license là **CC0 hoặc CC-BY** (hoặc CC-BY-SA nếu đã có quyết định theo §5). Loại mọi track NC/ND.
3. **Kiểm tra license có bao trùm cả phần lời không** (§2) — người đăng có tự viết + tự thu không? Nếu là remix, truy ngược tới bản acapella gốc và kiểm license của nó.
4. Nghe thử: giọng có rõ không, tốc độ có hợp người học không, nội dung có phù hợp không.
5. Ghi track vào bảng §10 bên dưới.
6. Nếu là CC-BY / CC-BY-SA: thêm dòng ghi công vào `ATTRIBUTION.md` đủ **TASL** (Title, Author, Source link, License link).
7. Host audio trên CDN riêng (xem §11), không hotlink từ trang gốc.
8. Chạy `python scripts/realign_lyrics.py --only <ten-file>` để căn timestamp.

---

## 10. Danh sách track đã thêm

| Track | Tác giả | Nguồn | License | Ghi công |
|---|---|---|---|---|
| Don't Close Your Eyes | Josh Woodward | https://www.joshwoodward.com/song/DontCloseYourEyes | CC-BY 4.0 | Có, xem `ATTRIBUTION.md` |
| Circles | Josh Woodward | https://www.joshwoodward.com/song/Circles | CC-BY 4.0 | Có, xem `ATTRIBUTION.md` |
| Same Boat | Josh Woodward | https://www.joshwoodward.com/song/SameBoat | CC-BY 4.0 | Có, xem `ATTRIBUTION.md` |
| A Thousand Years, California Lullabye, Cherubs, Crazy Glue, Flickering Flame, Goodbye to Spring, I'm Letting Go, Let It In, My Favorite Regret, Release, Saboteurs, She Dreams in Blue, Swansong, The Box, The Long Fade, The Maze, The Nest (17 bài) | Josh Woodward | joshwoodward.com/song/&lt;tên bài&gt; | CC-BY 4.0 | Có, xem `ATTRIBUTION.md` |

Ghi chú chọn lọc: trong danh sách bài nổi bật trên trang chủ Josh Woodward (~22 bài), đã loại 2 bài không phù hợp cho app học tiếng Anh đại trà — "I Want to Destroy Something Beautiful" (giọng điệu gay gắt/nhắc rượu) và "Wade" (từ vựng nâng cao, giễu nhại tiêu dùng — có thể để dành cho cấp độ nâng cao).

---

## 11. Kỹ thuật

**Timestamp lyrics.** Đã căn bằng forced-alignment tự động (`scripts/realign_lyrics.py`, faster-whisper) trên file audio thật, chỉ lấy timestamp chứ không đổi lời. Chạy `--dry-run` để xem trước, `--only <ten-file-khong-duoi>` để chạy 1 bài.

⚠️ **Nợ kỹ thuật đã biết:** hiện có **69/504 dòng bị dồn timestamp** (có dòng 7 chữ mà chỉ cách dòng sau 0.1s) — do lưới an toàn `+0.1s` cuối script kích hoạt khi ASR khớp nhầm ở đoạn điệp khúc hát lại. Từ khi có hiệu ứng karaoke cấp-từ, lỗi này lộ rõ (mấy dòng đó vụt qua rất nhanh). Cách sửa: chạy lại script với model Whisper lớn hơn (`small`/`medium` thay vì `base`). Nên làm **trước** khi thêm hàng loạt bài mới, để bài mới không dính cùng lỗi.

**Host file khi scale.**
- Hiện tại: commit mp3 vào `content/audio/`, app stream qua `raw.githubusercontent.com` — đơn giản, hợp với vài chục bài.
- Khi lên ~100 bài / nhiều người dùng: chuyển sang **Cloudflare R2** (free tier 10GB, egress $0 vĩnh viễn). 20 bài hiện tại đã ~160MB → 100 bài sẽ ~800MB, bắt đầu nặng cho 1 git repo và rủi ro GitHub coi raw.githubusercontent.com là traffic bất thường.

---

## 12. Giới hạn của nghiên cứu này

Phiên làm việc này bị chặn egress mạng, **không truy cập trực tiếp được** joshwoodward.com, pixabay.com, freemusicarchive.org, ccmixter.org, archive.org. Các kết luận về điều khoản license ở trên dựa trên **kết quả tìm kiếm web trích dẫn lại điều khoản**, không phải đọc trực tiếp trang license gốc.

→ Trước khi thêm track thật, người thực hiện **phải tự mở trang license gốc của từng track và đọc lại** (đây cũng đã là bước 1–2 trong checklist §9). Riêng phần đính chính Pixabay ở §6 nên được xác nhận lại bằng cách đọc thẳng https://pixabay.com/service/license-summary/ trước khi coi là kết luận cuối cùng.

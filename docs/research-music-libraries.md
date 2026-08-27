# Nghiên cứu: nguồn nhạc royalty-free cho app

Xem quy tắc bắt buộc đầy đủ trong [CLAUDE.md](../CLAUDE.md#nguồn-nhạc--quan-trọng-về-bản-quyền). Tóm tắt nghiên cứu:

| Nguồn | License | Dùng thương mại? | API | Ghi chú |
|---|---|---|---|---|
| **Jamendo API** | CC theo từng track | ❌ API chỉ miễn phí phi thương mại | Có (REST) | Loại khỏi dự án — commercial phải mua quote riêng dù track gắn nhãn CC |
| **Pixabay Music** | Pixabay Content License | ✅ Miễn phí, không cần ghi công | Không có API chính thức cho nhạc | Tải thủ công, kiểm tra license từng track |
| **Incompetech (Kevin MacLeod)** | CC-BY | ✅ Cần ghi công tác giả | Không | Kho nhạc nền/instrumental lớn, phù hợp làm nhạc lyric đơn giản |
| **Free Music Archive** | Đa dạng, tuỳ track | ✅ Chỉ với track CC0/CC-BY | Không còn API public | Phải lọc thủ công, loại bỏ track CC-BY-NC |
| **ccMixter** | Đa dạng, tuỳ track | ✅ Chỉ với track CC0/CC-BY | Không có API public | Tương tự FMA |
| **Josh Woodward** (joshwoodward.com) | CC-BY 4.0 (toàn bộ ~200 bài) | ✅ Cần ghi công, có bán license riêng chỉ cho quảng cáo/nhạc chờ (không áp dụng cho app học ngôn ngữ) | Không | **Nguồn thực tế đang dùng** — hiếm hoi trong các nguồn "royalty-free" có **giọng hát tiếng Anh thật, lời rõ ràng, phát âm chuẩn**, lại có sẵn lyrics đầy đủ đăng công khai trên từng trang bài hát (kể cả JSON-LD `MusicComposition.lyrics` để trích dẫn chính xác). Đã thử Pixabay/ccMixter trước nhưng: Pixabay "indie vocals" phần lớn là nhạc AI-generated hoặc vocal không lời (ooh/aah), không có lyrics công khai; ccMixter tag CC0 hầu như chỉ có nhạc điện tử/sample, không có bài hát có lời. |

## Quy trình thêm 1 bài hát mới vào app
1. Tải file gốc từ 1 trong các nguồn trên, chụp lại/lưu link trang license của track đó.
2. Xác nhận license là CC0 hoặc CC-BY (không dùng CC-BY-NC/CC-BY-ND cho mục đích thương mại).
3. Ghi thông tin track vào bảng bên dưới.
4. Nếu là CC-BY: thêm dòng ghi công vào `ATTRIBUTION.md` (tên tác giả, tên track, link gốc, loại license).
5. Host file audio trên CDN riêng (Cloudflare R2 khi scale — xem gợi ý dưới), không phát trực tiếp từ trang gốc.

## Danh sách track đã thêm
| Track | Tác giả | Nguồn | License | Ghi công (nếu CC-BY) |
|---|---|---|---|---|
| Don't Close Your Eyes | Josh Woodward | https://www.joshwoodward.com/song/DontCloseYourEyes | CC-BY 4.0 | Có, xem `ATTRIBUTION.md` |
| Circles | Josh Woodward | https://www.joshwoodward.com/song/Circles | CC-BY 4.0 | Có, xem `ATTRIBUTION.md` |
| Same Boat | Josh Woodward | https://www.joshwoodward.com/song/SameBoat | CC-BY 4.0 | Có, xem `ATTRIBUTION.md` |
| A Thousand Years, California Lullabye, Cherubs, Crazy Glue, Flickering Flame, Goodbye to Spring, I'm Letting Go, Let It In, My Favorite Regret, Release, Saboteurs, She Dreams in Blue, Swansong, The Box, The Long Fade, The Maze, The Nest (17 bài) | Josh Woodward | joshwoodward.com/song/&lt;tên bài&gt; | CC-BY 4.0 | Có, xem `ATTRIBUTION.md` |

Ghi chú chọn lọc: trong danh sách bài hát nổi bật trên trang chủ Josh Woodward (~22 bài), đã loại 2 bài không phù hợp cho app học tiếng Anh đại trà — "I Want to Destroy Something Beautiful" (giọng điệu gay gắt/nhắc rượu) và "Wade" (từ vựng nâng cao, giễu nhại tiêu dùng, đã ghi nhận là lựa chọn cho cấp độ nâng cao nếu sau này cần).

Ghi chú kỹ thuật: timestamp đồng bộ lyric-nhạc trong `songs_data.dart` hiện là **ước lượng** (phân bổ tỉ lệ theo độ dài từng câu trên tổng thời lượng bài hát), không phải forced-alignment thật từ việc nghe file — vì chưa có công cụ nghe/tách giọng tại thời điểm thêm dữ liệu. Cần nghe lại và tinh chỉnh `startSeconds` thủ công cho khớp chính xác trước khi coi lyric-sync là "chuẩn".

## Lưu trữ/host file khi scale
- Giai đoạn đầu (hiện tại): commit trực tiếp file mp3 vào repo tại `content/audio/`, app stream qua `raw.githubusercontent.com` — đơn giản, không tốn thêm hạ tầng, phù hợp vài bài hát đầu tiên.
- Khi nhiều bài hát/người dùng: chuyển sang **Cloudflare R2** (free tier 10GB storage, egress $0 vĩnh viễn) — phù hợp vì người dùng liên tục tải/nghe nhạc, tránh phát sinh phí băng thông khi scale, và tránh rủi ro GitHub coi raw.githubusercontent.com là traffic bất thường nếu lượng nghe tăng cao.

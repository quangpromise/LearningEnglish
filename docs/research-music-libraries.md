# Nghiên cứu: nguồn nhạc royalty-free cho app

Xem quy tắc bắt buộc đầy đủ trong [CLAUDE.md](../CLAUDE.md#nguồn-nhạc--quan-trọng-về-bản-quyền). Tóm tắt nghiên cứu:

| Nguồn | License | Dùng thương mại? | API | Ghi chú |
|---|---|---|---|---|
| **Jamendo API** | CC theo từng track | ❌ API chỉ miễn phí phi thương mại | Có (REST) | Loại khỏi dự án — commercial phải mua quote riêng dù track gắn nhãn CC |
| **Pixabay Music** | Pixabay Content License | ✅ Miễn phí, không cần ghi công | Không có API chính thức cho nhạc | Tải thủ công, kiểm tra license từng track |
| **Incompetech (Kevin MacLeod)** | CC-BY | ✅ Cần ghi công tác giả | Không | Kho nhạc nền/instrumental lớn, phù hợp làm nhạc lyric đơn giản |
| **Free Music Archive** | Đa dạng, tuỳ track | ✅ Chỉ với track CC0/CC-BY | Không còn API public | Phải lọc thủ công, loại bỏ track CC-BY-NC |
| **ccMixter** | Đa dạng, tuỳ track | ✅ Chỉ với track CC0/CC-BY | Không có API public | Tương tự FMA |

## Quy trình thêm 1 bài hát mới vào app
1. Tải file gốc từ 1 trong các nguồn trên, chụp lại/lưu link trang license của track đó.
2. Xác nhận license là CC0 hoặc CC-BY (không dùng CC-BY-NC/CC-BY-ND cho mục đích thương mại).
3. Ghi thông tin track vào bảng bên dưới.
4. Nếu là CC-BY: thêm dòng ghi công vào `ATTRIBUTION.md` (tên tác giả, tên track, link gốc, loại license).
5. Host file audio trên CDN riêng (Cloudflare R2 khi scale — xem gợi ý dưới), không phát trực tiếp từ trang gốc.

## Danh sách track đã thêm
| Track | Tác giả | Nguồn | License | Ghi công (nếu CC-BY) |
|---|---|---|---|---|
| _(chưa có track nào — điền khi thêm nhạc thật vào app)_ | | | | |

## Lưu trữ/host file khi scale
- Giai đoạn đầu: bundle file trong app hoặc host trên GitHub Releases (đơn giản, đủ dùng khi ít bài hát).
- Khi nhiều bài hát/người dùng: chuyển sang **Cloudflare R2** (free tier 10GB storage, egress $0 vĩnh viễn) — phù hợp vì người dùng liên tục tải/nghe nhạc, tránh phát sinh phí băng thông khi scale.

# Hướng dẫn cho thành viên mới dùng Claude Code

Repo: https://github.com/quangpromise/LearningEnglish

## Bước 1 — Clone code
```bash
git clone https://github.com/quangpromise/LearningEnglish.git
cd LearningEnglish
```
Nếu chưa có quyền truy cập repo (repo private), nhờ chủ dự án (@quangpromise) mời qua **Settings → Collaborators** trên GitHub trước.

## Bước 2 — Mở project bằng Claude Code
```bash
claude
```
(chạy trong thư mục vừa clone). Claude Code sẽ tự đọc `CLAUDE.md` ở gốc repo — file này đã mô tả sẵn toàn bộ mục tiêu app, stack kỹ thuật, quy ước code, và danh sách agent/skill sẵn có, nên Claude sẽ hiểu ngữ cảnh dự án ngay từ tin nhắn đầu tiên mà không cần giải thích lại.

## Bước 3 — Cho phép MCP GitHub (tuỳ chọn nhưng nên bật)
Repo có sẵn file `.mcp.json` cấu hình MCP GitHub. Khi mở project, Claude Code sẽ hỏi có cho phép dùng MCP server `github` không — đồng ý, sau đó lần đầu gọi tới GitHub trình duyệt sẽ mở để bạn đăng nhập OAuth **bằng chính tài khoản GitHub của bạn** (không dùng chung token với ai). Sau đó Claude Code có thể tự đọc/tạo issue, xem PR, xem trạng thái CI thay bạn.

## Bước 4 — Cài môi trường Flutter (nếu code phần app)
1. Cài Flutter SDK (kênh `stable`) — có thể nhờ Claude Code tự tải/cài giúp (giống cách đã làm cho máy chủ dự án) hoặc tải thủ công tại flutter.dev.
2. Cài Android SDK (qua Android Studio hoặc `sdkmanager` command-line).
3. Trong thư mục `app/`, chạy:
   ```bash
   flutter pub get
   flutter analyze
   flutter test
   ```
4. Xem chi tiết setup, branch naming, coding convention tại [CONTRIBUTING.md](../CONTRIBUTING.md).

## Bước 5 — Nhận việc, tạo nhánh, code
- Xem việc cần làm trong **GitHub Issues** của repo.
- Mỗi người/nhóm nên nhận trọn 1 thư mục trong `app/lib/features/` (`music_player`, `translation`, `pronunciation`, `grammar`, `quiz`) để hạn chế đụng code nhau — xem mục "Cộng tác nhiều người" trong `CLAUDE.md`.
- Tạo nhánh từ `develop`: `feature/<module>-<mo-ta-ngan>`.
- Trước khi tạo Pull Request: chạy `flutter analyze`, `dart format .`, `flutter test` — CI (`.github/workflows/ci.yml`) sẽ tự kiểm tra lại các bước này trên mọi PR.

## Bước 6 — Dùng agent/skill có sẵn khi cần
Dự án đã có sẵn trong `.claude/`:
- **Agents**: `grammar-researcher`, `pronunciation-researcher`, `library-researcher` — gõ tên trực tiếp trong Claude Code để nhờ agent chuyên biệt xử lý.
- **Skills**: `grammar-check`, `pronunciation-check`, `lyric-sync`, `apk-release`, `ui-design-system` — gọi bằng `/`<tên-skill>` khi cần đúng quy trình đã chuẩn hoá của dự án.

Không cần thiết lập gì thêm — mọi thứ trên đều đã commit sẵn trong repo, Claude Code của mỗi người sẽ tự nhận diện khi mở đúng thư mục project.

# Hướng dẫn cộng tác (CONTRIBUTING)

Tài liệu này dành cho nhiều người cùng code chung dự án. Đọc kèm [CLAUDE.md](CLAUDE.md) để hiểu kiến trúc & stack.

## 1. Setup môi trường
1. Cài Flutter SDK (kênh `stable`), chạy `flutter doctor` cho đến khi không còn lỗi.
2. Clone repo, vào thư mục `app/`, chạy `flutter pub get`.
3. Copy `app/.env.example` → `app/.env` (nếu có key API riêng như Google Cloud TTS), điền key cá nhân. **Không commit file `.env`**.
4. Chạy thử: `flutter run` (chọn thiết bị/emulator Android).

## 2. Nhánh (branching)
- `main` — luôn ở trạng thái build được, là nguồn build APK release.
- `develop` — nhánh tích hợp, mọi feature branch merge vào đây trước khi lên `main`.
- Feature branch đặt tên: `feature/<ten-module>-<mo-ta-ngan>` (vd `feature/pronunciation-mic-recording`).
- Fix bug: `fix/<mo-ta-ngan>`. Nghiên cứu/tài liệu: `docs/<mo-ta-ngan>`.
- Không push trực tiếp lên `main`/`develop` — luôn qua Pull Request.

## 3. Chia module để hạn chế đụng code (conflict)
Dự án theo **feature-first**: mỗi tính năng nằm trong 1 thư mục riêng dưới `app/lib/features/`:
```
features/
├── music_player/
├── translation/
├── pronunciation/
└── grammar/
```
- Mỗi người/nhóm nhận 1 feature để làm việc độc lập, hạn chế sửa file dùng chung (`core/`).
- Muốn thay đổi `core/` (routing, DI, theme dùng chung) → báo trước trong PR mô tả rõ ảnh hưởng, cần review kỹ hơn (xem `CODEOWNERS`).
- State management dùng **Riverpod**: mỗi feature có provider riêng trong thư mục của mình, tránh 1 file state khổng lồ nhiều người cùng sửa.

## 4. Quy trình Pull Request
1. Tạo branch từ `develop` mới nhất.
2. Code + viết test (nếu có logic nghiệp vụ, ví dụ thuật toán chấm điểm phát âm, parser `.lrc`).
3. Chạy trước khi tạo PR:
   - `flutter analyze` (không còn warning/error)
   - `dart format .` (format code)
   - `flutter test`
4. Tạo PR vào `develop`, điền theo `.github/PULL_REQUEST_TEMPLATE.md`.
5. Cần ít nhất 1 review approve (theo `CODEOWNERS`) trước khi merge.
6. Merge bằng **squash merge** để lịch sử `develop` gọn gàng.

## 5. Coding convention
- Lint: dùng `flutter_lints` (khai báo trong `analysis_options.yaml`), CI sẽ fail nếu có lỗi lint.
- Đặt tên file/class theo chuẩn Dart (`snake_case.dart`, `UpperCamelCase` cho class).
- Comment chỉ khi giải thích lý do (WHY) không hiển nhiên, không viết comment mô tả lại code.
- Mọi package mới thêm vào `pubspec.yaml` phải:
  - Miễn phí, license rõ ràng (ưu tiên MIT/BSD/Apache/LGPL).
  - Ghi lý do chọn vào `docs/` tương ứng (xem quy tắc trong CLAUDE.md).

## 6. Quy tắc thêm nhạc (bản quyền)
Xem chi tiết trong [CLAUDE.md](CLAUDE.md#nguồn-nhạc--quan-trọng-về-bản-quyền). Tóm tắt: **không dùng Jamendo API cho bản thương mại**; chỉ thêm track CC0/CC-BY đã tự tải & xác minh license, có ghi chú nguồn trong `docs/research-music-libraries.md`.

## 7. Commit message
Theo [Conventional Commits](https://www.conventionalcommits.org/):
```
feat(pronunciation): thêm chấm điểm phát âm bằng speech_to_text
fix(music_player): sửa lỗi lyric không đồng bộ khi tua nhạc
docs(music): thêm 5 track CC-BY mới kèm attribution
```

## 8. MCP cho thành viên dùng Claude Code
Repo có sẵn `.mcp.json` (đã commit, không chứa secret) cấu hình **GitHub MCP server** dùng bản remote chính thức của GitHub (`https://api.githubcopilot.com/mcp/`), xác thực bằng OAuth cá nhân — không cần tạo/lưu Personal Access Token, không cần cài Docker.

Khi mở project bằng Claude Code, mỗi thành viên:
1. Được hỏi cho phép dùng MCP server `github` trong repo (chỉ 1 lần) → đồng ý.
2. Lần đầu gọi tool GitHub, trình duyệt sẽ mở để đăng nhập OAuth GitHub cá nhân của mình.
3. Sau đó Claude Code có thể tự đọc/tạo issue, xem PR, xem trạng thái CI... thay mặt bạn trên tài khoản GitHub của chính bạn.

Không bắt buộc — chỉ giúp Claude thao tác GitHub nhanh hơn thay vì gõ lệnh `gh` thủ công. Nếu team dùng thêm công cụ khác (Linear, Jira, Slack...) có thể thêm MCP server tương ứng vào `.mcp.json` — nhớ dùng OAuth hoặc biến môi trường, **không hardcode token/secret vào file commit**.

## 9. Liên lạc & phân công
- Việc/bug theo dõi qua GitHub Issues, gắn nhãn `feature`, `bug`, `research`, `docs`.
- Trước khi bắt đầu 1 issue lớn, comment nhận việc để tránh 2 người làm trùng.

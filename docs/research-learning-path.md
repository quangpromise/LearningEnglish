# Nghiên cứu: Lộ trình học cho từng nhóm người dùng

## Mục tiêu

App hiện có rất nhiều tính năng rời rạc (Từ vựng, Ngữ pháp, Đọc, Phonics,
Luyện phát âm, Story, Đố vui, Luyện viết, TOEIC, IELTS, AI Voice Chat) nhưng
**không có gợi ý nào về thứ tự học** — người dùng mới mở app sẽ thấy 10+ ô
icon ngang hàng nhau, không biết bắt đầu từ đâu. Tài liệu này nghiên cứu và
đề xuất:

1. Phân nhóm người học (persona) theo trình độ + mục tiêu thực tế.
2. Lộ trình học cụ thể cho từng nhóm, CHỈ dùng tính năng đã có sẵn trong app
   (không đề xuất tính năng mới ngoài chính bản thân tính năng "Lộ trình
   học").
3. Cách xác định người dùng thuộc nhóm nào (khảo sát ngắn khi vào tính năng
   lần đầu).
4. Cách theo dõi tiến độ, dựa theo đúng quy ước dữ liệu đã dùng trong app
   (xem mục 5).

## 1. Kiểm kê tính năng hiện có (dùng làm "khối xây dựng" lộ trình)

| Tính năng | Vai trò trong lộ trình | Có sẵn cấp độ/thứ tự? |
|---|---|---|
| Phonics (12 bài phát âm) | Nền tảng phát âm — nên học ĐẦU TIÊN cho người mất gốc | Có, đã đánh số 1-12 |
| Từ vựng theo chủ đề | Xây vốn từ theo nhu cầu (gia đình, công việc, du lịch...) | Không, chỉ theo chủ đề |
| Ngữ pháp (31 chủ đề) | Cấu trúc câu — cần học có chọn lọc theo trình độ | Không, danh sách phẳng |
| Luyện phát âm (ghi âm) | Luyện nói sau khi có vốn từ + ngữ pháp cơ bản | Không |
| Story (theo CEFR A2-C1) | Luyện nghe/đọc hiểu theo trình độ tăng dần | Có field `level` nhưng chưa lọc theo level trên UI |
| Đọc sách (Reading) | Đọc hiểu nâng cao | Không |
| Đố vui (Quiz) | Ôn lại từ vựng/kiến thức chung, mang tính giải trí | Không |
| Luyện viết (Writing) | Luyện viết câu — từ vựng riêng lẻ → câu hoàn chỉnh có đủ thì | Không (nhưng 2 chế độ đã có thứ tự tự nhiên: Từ vựng trước, Đoạn văn sau) |
| TOEIC | Luyện thi TOEIC — cần nền tảng từ vựng + ngữ pháp trước | Có (đã là "test prep" cấp cao) |
| IELTS | Luyện thi IELTS — cần nền tảng cao hơn TOEIC (đọc/nghe học thuật) | Có |
| AI Voice Chat | Luyện phản xạ giao tiếp thực tế | Không, nhưng cần vốn từ + ngữ pháp cơ bản trước mới dùng hiệu quả |

## 2. Phân nhóm người học (6 persona)

Chọn 6 nhóm để bao quát đủ các nhu cầu chính đã thấy trong thực tế học
tiếng Anh tại Việt Nam, không quá dàn trải để soạn nội dung lộ trình:

### Persona A — "Mất gốc" (Absolute beginner)
Chưa nắm chắc bảng chữ cái phát âm, từ vựng cơ bản, hoặc đã học nhưng quên
gần hết. Mục tiêu: xây lại nền tảng vững chắc, không nản.

### Persona B — "Giao tiếp hằng ngày" (đi làm, không chuyên biệt)
Đã có vốn từ cơ bản, muốn nói được các tình huống đời thường (đặt đồ ăn, hỏi
đường, trò chuyện xã giao). Không cần ngữ pháp học thuật sâu, ưu tiên phản
xạ nói.

### Persona C — "Tiếng Anh công sở" (đi làm, cần dùng trong công việc)
Cần viết email, họp hành, thuyết trình bằng tiếng Anh. Cần vốn từ chuyên
ngành + khả năng viết câu hoàn chỉnh, đúng ngữ pháp hơn nhóm B.

### Persona D — "Ôn tập toàn diện" (học sinh/sinh viên, mất gốc ngữ pháp)
Đã có vốn từ nhưng ngữ pháp lẫn lộn (chia thì sai, cấu trúc câu sai). Mục
tiêu: hệ thống lại ngữ pháp bài bản theo đúng trình tự từ cơ bản đến nâng
cao.

### Persona E — "Luyện thi TOEIC" (cần điểm TOEIC đi làm/xin việc)
Đã có nền tảng, cần làm quen format đề thi, luyện tốc độ + chiến thuật.

### Persona F — "Luyện thi IELTS" (du học/định cư)
Cần trình độ cao hơn, cả 2 kỹ năng đã hỗ trợ (Đọc, Nghe) + kỹ năng viết học
thuật (dùng tạm tính năng Luyện viết đoạn văn để luyện phản xạ dịch/viết câu
đúng ngữ pháp, dù chưa phải writing task thật của IELTS).

## 3. Khảo sát xác định persona (khi vào "Lộ trình học" lần đầu)

2 câu hỏi, dạng chọn 1 đáp án, ánh xạ TRỰC TIẾP ra persona (không cần thuật
toán phức tạp):

**Câu 1 — "Trình độ hiện tại của bạn?"**
- Tôi gần như mất gốc / mới bắt đầu → tạm gán **A**, hỏi tiếp câu 2 vẫn áp
  dụng để tinh chỉnh (mất gốc nhưng mục tiêu công sở vẫn nên bắt đầu từ A
  trước khi rẽ sang lộ trình C ở giai đoạn sau — xem "lộ trình nối tiếp" ở
  mục 4).
- Tôi biết cơ bản nhưng ngữ pháp còn yếu → thiên về **D**.
- Tôi khá ổn, cần luyện theo mục tiêu cụ thể → hỏi tiếp câu 2 để chọn
  B/C/E/F.

**Câu 2 — "Mục tiêu chính của bạn là gì?"**
- Giao tiếp hằng ngày, tự tin nói chuyện → **B**
- Dùng trong công việc (email, họp, thuyết trình) → **C**
- Luyện thi TOEIC → **E**
- Luyện thi IELTS → **F**
- Chưa rõ, muốn học tổng quát → **D**

Kết quả: 1 persona được gán, nhưng cho phép người dùng đổi persona bất kỳ
lúc nào từ màn hình lộ trình (không khoá cứng).

## 4. Lộ trình theo từng persona

Mỗi lộ trình gồm **5-6 giai đoạn (stage)**, mỗi giai đoạn trỏ tới đúng 1
tính năng/phần đã có sẵn. Đây là nội dung hiển thị trong tính năng "Lộ
trình học", KHÔNG phải danh sách bài học mới cần soạn.

### A — Mất gốc
1. Phonics — học đủ 12 bài (nền tảng phát âm).
2. Từ vựng theo chủ đề — bắt đầu từ các chủ đề đời sống cơ bản (Gia đình, Đồ
   vật, Số đếm, Màu sắc — tuỳ chủ đề nào đã có, ưu tiên chủ đề ít từ nhất).
3. Ngữ pháp — chỉ 5-6 chủ đề nền tảng đầu tiên (thì hiện tại đơn, hiện tại
   tiếp diễn, danh từ số ít/nhiều, đại từ, giới từ chỉ nơi chốn — chọn đúng
   theo danh sách 31 chủ đề thật có sẵn khi build, không bịa tên chủ đề).
4. Story — lọc/khuyến nghị theo `level == A2` (cần thêm bộ lọc hoặc chỉ hiển
   thị gợi ý bằng text, xem mục 6 "Giới hạn kỹ thuật").
5. Luyện viết — chế độ Từ vựng (gõ lại từ đã học ở bước 2).
6. Sau khi hoàn thành → gợi ý chuyển sang lộ trình B hoặc D tuỳ mục tiêu ban
   đầu.

### B — Giao tiếp hằng ngày
1. Từ vựng theo chủ đề — các chủ đề giao tiếp (Nhà hàng, Mua sắm, Du lịch,
   Hỏi đường...).
2. Luyện phát âm (ghi âm câu, chấm điểm) — luyện phản xạ nói câu đơn giản.
3. Ngữ pháp — các thì cơ bản dùng trong hội thoại (hiện tại đơn, quá khứ
   đơn, tương lai gần).
4. AI Voice Chat — luyện hội thoại tự do với AI.
5. Story — thể loại hội thoại (dialogue).

### C — Tiếng Anh công sở
1. Từ vựng theo chủ đề — chủ đề công việc (Công việc, Tài chính nếu có, Công
   nghệ).
2. Ngữ pháp — đầy đủ các thì (đúng như nội dung 12 thì đã soạn cho Luyện
   viết đoạn văn) + câu bị động, câu điều kiện nếu có trong 31 chủ đề.
3. Luyện viết — CẢ 2 chế độ (Từ vựng rồi Đoạn văn) — đây là tính năng khớp
   nhất với nhu cầu "viết email/câu hoàn chỉnh".
4. AI Voice Chat — luyện phản xạ họp/thuyết trình (roleplay qua hội thoại
   tự do).
5. Đọc sách — đọc tài liệu dài hơn, luyện đọc hiểu văn phong trang trọng.

### D — Ôn tập toàn diện (ngữ pháp)
1. Ngữ pháp — học tuần tự HẾT 31 chủ đề theo đúng thứ tự đã sắp trong
   `grammar_data.dart` (thứ tự này vốn đã đi từ cơ bản đến nâng cao).
2. Từ vựng theo chủ đề — song song, mỗi tuần 1-2 chủ đề.
3. Đố vui — ôn lại kiến thức đã học dưới dạng giải trí.
4. Luyện viết — chế độ Đoạn văn (áp dụng ngữ pháp vừa học vào câu thật).
5. Đọc sách / Story — đọc hiểu để củng cố.

### E — Luyện thi TOEIC
1. Từ vựng theo chủ đề — ưu tiên chủ đề công việc/kinh doanh.
2. Ngữ pháp — ôn nhanh các điểm ngữ pháp hay gặp trong đề (thì, câu bị động,
   liên từ, giới từ — chọn đúng tên chủ đề có sẵn).
3. Phonics — ôn nhanh nếu người dùng yếu phần Nghe (Part 1-4 TOEIC).
4. TOEIC — làm bài Luyện tập (Practice mode) trước, sau đó Thi thử (Exam
   mode), theo dõi qua `toeic_history_screen.dart`.
5. Lặp lại bước 4 định kỳ, xem lịch sử để đánh giá tiến bộ.

### F — Luyện thi IELTS
1. Từ vựng theo chủ đề — ưu tiên chủ đề học thuật/xã hội nếu có.
2. Ngữ pháp — ôn các cấu trúc phức (câu điều kiện, mệnh đề quan hệ, câu bị
   động) nếu có trong 31 chủ đề.
3. Luyện viết — chế độ Đoạn văn (luyện phản xạ viết câu đúng ngữ pháp, tuy
   chưa phải đúng dạng đề Writing thật của IELTS — cần ghi chú rõ trong UI
   đây là bài tập bổ trợ, không phải luyện thi Writing chính thức).
4. IELTS — làm bài Luyện tập rồi Thi thử (Reading + Listening), theo dõi
   qua `ielts_history_screen.dart`.
5. Story — chọn truyện có `level` B2/C1 để luyện đọc/nghe học thuật.

## 5. Thiết kế theo dõi tiến độ (đúng quy ước đã có trong app)

Không có cơ chế chung nào để biết "người dùng đã học xong 1 bước" (vd đã
xem hết 1 chủ đề ngữ pháp) — most feature không lưu completion flag. Giải
pháp đơn giản, nhất quán với quy ước `user_lesson_progress` đã dùng cho
Story (`supabase/migrations/0026_lesson_progress.sql`):

- Bảng mới `user_learning_path_progress`:
  `user_id, persona_id (text), step_index (int), completed_at (timestamptz)`,
  PK `(user_id, persona_id, step_index)`. Người dùng TỰ đánh dấu "Hoàn
  thành bước này" bằng 1 nút bấm sau khi học xong (giống cách rất nhiều app
  học tập làm khi không thể tự động phát hiện hoàn thành 1 bước tổng hợp
  nhiều màn hình khác nhau) — KHÔNG cố gắng tự động dò tiến độ từ các bảng
  khác (`toeic_attempts`, `user_lesson_progress`...) vì mỗi bước lộ trình
  có thể trỏ tới nhiều màn hình khác nhau, tự động hoá sẽ phức tạp và dễ sai
  mà lợi ích không tương xứng cho v1.
- Bảng `user_learning_path_choice`: `user_id, persona_id, chosen_at` — lưu
  persona hiện tại của người dùng (upsert, 1 dòng/user), để lần sau mở lại
  app vào đúng lộ trình đã chọn thay vì hỏi lại khảo sát.
- RLS: theo đúng mẫu đã có — `enable row level security`, policy
  `select_own`/`insert_own`/`update_own` dùng `auth.uid() = user_id`, kèm
  `grant select, insert, update to authenticated`.

## 6. Giới hạn kỹ thuật cần lưu ý khi build

- Story hiện CHƯA có bộ lọc theo `level` trên UI (`story_list_screen.dart`
  chỉ nhóm theo `StoryCategory`, không theo CEFR) — lộ trình chỉ có thể
  **gợi ý bằng chữ** ("tìm truyện có nhãn A2 trong danh sách") thay vì
  deep-link lọc sẵn, trừ khi làm thêm 1 tham số lọc cho màn đó (việc nhỏ,
  có thể làm kèm nếu cần).
- Tên chủ đề Ngữ pháp/Từ vựng cụ thể dùng trong lộ trình PHẢI lấy đúng từ
  `grammar_data.dart`/`vocabulary_data.dart` thật khi code, không tự bịa —
  tài liệu này chỉ mô tả Ý ĐỊNH ("5-6 chủ đề nền tảng"), việc chọn ID chủ đề
  chính xác sẽ làm ở bước implementation.
- AI Voice Chat không có "chế độ roleplay công sở" riêng — bước lộ trình
  trỏ tới tính năng chung, kèm gợi ý bằng text trong mô tả bước ("hãy thử
  hỏi AI về một tình huống họp hành").
- Không tự động khoá bước sau nếu bước trước chưa hoàn thành — người dùng
  có thể bấm vào bất kỳ bước nào bất kỳ lúc nào (chỉ mang tính gợi ý thứ
  tự, không ép buộc), tránh cảm giác bị "khoá" gây khó chịu.

## 7. Tính năng trong app (tóm tắt để tham chiếu khi lên kế hoạch code)

- 1 tile mới trên Home ("Lộ trình học") — đề xuất đặt ở vị trí NỔI BẬT nhất
  (đầu trang, trên cả 3 khung nhóm hiện có) vì đây là điểm khởi đầu định
  hướng cho toàn bộ trải nghiệm.
- Màn khảo sát 2 câu hỏi (chỉ hỏi khi chưa có `user_learning_path_choice`
  hoặc khi người dùng chủ động bấm "Đổi lộ trình").
- Màn hiển thị lộ trình đã chọn: danh sách stage tuần tự, mỗi stage có nút
  mở đúng tính năng tương ứng (dùng lại `openAppPopup`/`Navigator.push` như
  các nơi khác) + nút "Đánh dấu hoàn thành" + thanh tiến độ tổng (x/6 bước).

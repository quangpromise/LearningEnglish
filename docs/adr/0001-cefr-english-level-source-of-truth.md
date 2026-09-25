# English Level (CEFR) là nguồn gốc duy nhất về trình độ; Learner Level chỉ là lớp tương thích

Trước đây trình độ được suy ra từ Persona thành `LearnerLevel` 3 cấp, và nhiều tính năng (lọc từ vựng, AI Voice Chat, coach, bài viết) đọc trực tiếp giá trị đó. Nay lộ trình lên IELTS cần thang 5 bậc CEFR (A1, A2, B1, B2, C1), có Placement Test và Level Test, nên English Level trở thành nguồn gốc duy nhất. `LearnerLevel` được suy ra từ nó (A1–A2 → Basic, B1 → Intermediate, B2–C1 → Advanced) để các tính năng cũ chạy tiếp mà không phải sửa. Persona chỉ còn dùng làm mặc định khi người dùng bỏ qua Placement Test.

## Consequences

- Khi người dùng **chưa có English Level đã lưu** (chưa làm Placement hay Level Test), Learner Level vẫn suy từ Persona theo mapping 3 cấp cũ. Mapping này khác mapping CEFR → Learner Level: ví dụ Persona IELTS cũ là Advanced, còn B1 là Intermediate. Làm vậy có chủ đích, để người dùng hiện tại không bị đổi độ khó khi cập nhật app. Khi đã có English Level thì chỉ dùng CEFR.
- Chế độ "Tự học" (không chọn Persona) luôn không lọc nội dung, kể cả khi đã có English Level.

## Considered Options

- Mở rộng `LearnerLevel` thành 5 cấp: bị loại vì mọi nơi đang switch trên 3 giá trị sẽ phải sửa cùng lúc.
- Giữ Persona là nguồn và chỉ thêm thang CEFR riêng: bị loại vì sẽ có 2 nguồn trình độ mâu thuẫn nhau (Persona "IELTS" trong khi Level Test cho thấy A2).

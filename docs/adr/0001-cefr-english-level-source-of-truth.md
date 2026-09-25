# English Level (CEFR) là nguồn gốc duy nhất về trình độ; Learner Level chỉ là lớp tương thích

Trước đây trình độ được suy ra từ Persona thành `LearnerLevel` 3 cấp, và nhiều tính năng (lọc từ vựng, AI Voice Chat, coach, bài viết) đọc trực tiếp giá trị đó. Nay lộ trình lên IELTS cần thang 5 bậc CEFR (A1, A2, B1, B2, C1), có Placement Test và Level Test, nên English Level trở thành nguồn gốc duy nhất. `LearnerLevel` được suy ra từ nó (A1–A2 → Basic, B1 → Intermediate, B2–C1 → Advanced) để các tính năng cũ chạy tiếp mà không phải sửa. Persona chỉ còn dùng làm mặc định khi người dùng bỏ qua Placement Test.

## Considered Options

- Mở rộng `LearnerLevel` thành 5 cấp: bị loại vì mọi nơi đang switch trên 3 giá trị sẽ phải sửa cùng lúc.
- Giữ Persona là nguồn và chỉ thêm thang CEFR riêng: bị loại vì sẽ có 2 nguồn trình độ mâu thuẫn nhau (Persona "IELTS" trong khi Level Test cho thấy A2).

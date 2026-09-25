# GymTalk

App vừa tập gym vừa học tiếng Anh cho người Việt: mỗi buổi tập là một buổi học, giờ nghỉ giữa các set là lúc học.

## Language

### Tiến độ tiếng Anh

**English Level**:
Bậc tiếng Anh hiện tại của người học trên thang CEFR A1 → A2 → B1 → B2 → C1 (không có C2). Là nguồn gốc duy nhất về trình độ; mọi phân cấp khác suy ra từ nó.
_Avoid_: trình độ, rank, XP level

**Stage**:
Một bậc CEFR trong lộ trình (ví dụ Stage B1), gồm nhiều Unit và kết thúc bằng một Level Test.
_Avoid_: level (khi nói về bậc cụ thể), chapter

**Unit**:
Một đơn vị học nhỏ trong một Stage, gồm một nhóm từ vựng và một điểm ngữ pháp cùng các Practice Item của chúng.
_Avoid_: lesson, bài

**Practice Item**:
Một câu hỏi đã sinh sẵn, gắn với một Unit, dùng được trong Unit session, Rest Game hoặc Level Test.
_Avoid_: question (khi nói chung), exercise

**Placement Test**:
Bài xếp lớp thích ứng khoảng 15 câu, xác định English Level ban đầu; bỏ qua thì lấy bậc mặc định theo Persona.
_Avoid_: entry test, test đầu vào

**Level Test**:
Bài kiểm tra cuối Stage; đạt ≥80% thì lên Stage kế tiếp, trượt thì chờ 24 giờ và ôn các câu đã sai.
_Avoid_: final test, exam

**Estimated Band**:
Band IELTS ước tính hiển thị sau Level Test từ B1 trở lên; chỉ mang tính tham chiếu, CEFR và IELTS không tương đương tuyệt đối.
_Avoid_: IELTS score, band điểm

**IELTS Micro Exercise**:
Practice Item tự soạn theo format IELTS (True/False/Not Given, chọn tiêu đề, từ học thuật) chỉ có ở Stage B1–C1.
_Avoid_: IELTS mock, đề IELTS

**Learner Level**:
Lớp tương thích 3 cấp (Basic / Intermediate / Advanced) suy ra từ English Level, cho các tính năng cũ đang lọc theo cấp.
_Avoid_: dùng làm nguồn dữ liệu trình độ

**Persona**:
Mục tiêu học người dùng chọn ở khảo sát lộ trình (mất gốc, giao tiếp, công sở, TOEIC, IELTS...); chỉ dùng làm mặc định khi bỏ qua Placement Test.

### Tiến độ gym

**Body Level**:
Bậc gym tính theo độ đều đặn (số buổi hoàn thành và số tuần tập liên tiếp), không theo mức tạ.
_Avoid_: fitness level, strength level

**GymTalk Rank**:
Huy hiệu chung bằng bậc thấp hơn giữa Body Level và English Level, thể hiện độ cân bằng giữa tập và học.
_Avoid_: overall level

### Giờ nghỉ

**Rest Break**:
Khoảng nghỉ có đếm ngược giữa hai set trong một buổi tập.
_Avoid_: rest time, pause

**Rest Game**:
Mini-game học tiếng Anh chơi được một tay trong Rest Break, tự co giãn theo thời gian còn lại và tự đóng khi hết giờ nghỉ. Có 4 loại: Meaning, Listening, Gap-fill, Word Scramble.
_Avoid_: quiz lúc nghỉ, rest quiz

### Nội dung

**Content Source**:
Một bộ dữ liệu bên ngoài được dùng để sinh nội dung (CEFR-J, NGSL/NAWL, Tatoeba...), luôn kèm license và provenance đã xác minh cho dùng thương mại.
_Avoid_: dataset (khi chưa xác minh license)

**Content Pack**:
File JSON đóng gói trong app do pipeline Python offline sinh ra từ các Content Source; không sinh nội dung bằng AI lúc chạy app.
_Avoid_: question bank, database câu hỏi

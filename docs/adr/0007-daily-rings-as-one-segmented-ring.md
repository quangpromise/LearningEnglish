# Daily Rings vẽ thành một vòng chia 3 cung, không phải 3 vòng đồng tâm

Handoff redesign (README §5) vẽ Daily Rings thành 3 vòng đồng tâm đỏ/xanh/ngọc trên nền đen — rất giống Activity Rings của Apple. Apple HIG (Activity rings) yêu cầu không sao chép hay biến tấu Activity rings cho mục đích khác, và App Review 5.2.5 chặn giao diện dễ nhầm với giao diện của Apple; app sẽ lên iOS ở giai đoạn 2. Vì vậy phase Motion vẽ Daily Rings thành **một vòng chia 3 cung** Tập / Học / Nói (mỗi cung 1/3 vòng, có khe hở, tự đầy trong phần của mình), % trung bình ở giữa, giữ nguyên bố cục thẻ. Làm cùng lúc với hoạt ảnh vòng mới để không phải làm hai lần.

## Considered Options

- 3 vòng nhỏ tách rời cạnh nhau (kiểu WHOOP): khác Apple nhưng phải dàn lại thẻ Rings.
- Giữ 3 vòng đồng tâm tới giai đoạn iOS: rủi ro bị từ chối khi duyệt và phải làm lại hoạt ảnh lần nữa.

# Pipeline nội dung lộ trình tiếng Anh (Content Pack)

Spec: issue #45. Ticket: #46 (tracer bullet), #55/#56/#57 (nội dung đầy đủ).
Quyết định: [ADR-0003](adr/0003-offline-content-pipeline.md). Thuật ngữ: `CONTEXT.md`.

## Sinh pack

```bash
python scripts/english_path_pipeline.py build
```

- Đọc Content Source → gắn cấp CEFR → chia Stage/Unit → sinh Practice Item.
- Chạy **validation tự động**. Có lỗi thì dừng và **không ghi file**. Validation kiểm các lỗi sau:
  - thiếu đáp án, hoặc đáp án không nằm trong options;
  - options trùng nhau sau khi chuẩn hoá;
  - thiếu bản dịch tiếng Việt;
  - Unit không tồn tại;
  - `sourceId` lạ, hoặc source thiếu license/provenance;
  - trùng id.
- Ghi pack vào **staging** `scripts/english_path/build/pack.json` và CSV review `scripts/english_path/review/pack_review.csv`. Chỉ pack **đã approve đúng hash** mới được ghi vào `app/assets/english_path/pack.json`, tức là mới được đóng gói vào app.
- CEFR-J được pin vào một commit cố định (`CEFRJ_COMMIT`), nên chạy lại luôn ra cùng dữ liệu.
- Chạy lại lúc nào cũng cho ra cùng một kết quả (deterministic), vì id và seed đều cố định theo nội dung.

## Quality gate (bắt buộc trước khi đóng gói)

1. **Validation tự động**: nằm trong `build`, như trên.
   Validation không bắt được đáp án nhiễu **đồng nghĩa** (khác chữ nhưng trùng nghĩa). Lỗi này do bước 2 và 3 bắt; kiểm tra bằng WordNet sẽ thêm ở #55.
2. **Review ngẫu nhiên 10%**: người duyệt đọc các dòng có `sample = yes` trong CSV review. Mẫu được chọn cố định theo id. Lỗi phải sửa trong pipeline hoặc dữ liệu nguồn, **không sửa tay JSON**.
3. **Grok đối chiếu chéo** trên cùng mẫu đó.
4. **Final approval** của maintainer/reviewer được chỉ định:

   ```bash
   python scripts/english_path_pipeline.py approve --reviewer "<tên>" --date YYYY-MM-DD --note "<ghi chú>"
   ```

   Lệnh này đọc pack ở staging, kiểm reviewer không rỗng và ngày đúng dạng YYYY-MM-DD, ghi `contentHash` và `packVersion` vào `scripts/english_path/approvals.json`, rồi đóng gói pack kèm metadata `approval` vào assets.

`contentHash` là sha256 của JSON đã chuẩn hoá (bỏ phần `approval`). Mọi thay đổi nội dung đều làm hash đổi và pack mất approval. Hai test sẽ **fail CI** khi pack trong assets thiếu, chưa được approve hoặc bị sửa tay:
- `app/test/english_path_content_pack_test.dart`
- `scripts/test_english_path_pipeline.py`

## Content Source

| id | Nguồn | License | Ghi chú |
|---|---|---|---|
| `cefrj` | CEFR-J Wordlist 1.5 (Tono Lab, TUFS) | Dùng thương mại miễn phí, bắt buộc trích dẫn | CSV tải lúc chạy, không đưa vào repo. Ghi công trong `ATTRIBUTION.md` |
| `gymtalk-vocab` | `vocabulary_data.dart` | Nội dung tự soạn của dự án | Cung cấp IPA, nghĩa tiếng Việt và câu ví dụ |

Nguồn sẽ thêm ở các ticket sau:
- Tatoeba (CC BY 2.0 FR)
- NGSL/NAWL (CC BY-SA 4.0, để trong asset riêng)
- Open English WordNet (CC BY 4.0)

Nguồn **không dùng** vì license: Oxford 3000/5000, English Vocabulary Profile, AWL, các bộ đề/essay IELTS trên HF/Kaggle, RACE.

## Quy mô

| Giai đoạn | Nội dung |
|---|---|
| Tracer (#46) | A1 × 1 Unit × 15 từ, item dạng `meaning` |
| Mục tiêu v1 | A1–B2 × 10 Unit, C1 × 3 Unit, khoảng 600 từ, khoảng 1.300 item |

Đáp án nhiễu ưu tiên lấy từ các từ cùng Unit (cùng chủ đề, thường cùng từ loại) để câu hỏi không quá dễ.

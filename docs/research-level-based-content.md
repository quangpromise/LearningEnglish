# Nghiên cứu: Lọc nội dung theo mức độ học (Từ vựng, Viết, Phát âm, Học nói)

## Mục tiêu

Khi người dùng chọn 1 gợi ý ở khảo sát "Gợi ý lộ trình học" (xem
`docs/research-learning-path.md`), các phần **Từ vựng theo chủ đề, Luyện viết,
Luyện phát âm, Học nói (AI Voice Chat)** phải tự lọc và chỉ hiển thị nội dung
đúng mức độ đó. Ví dụ người mới bắt đầu mở Từ vựng thì chỉ thấy từ "Thông
dụng" (common), và phần Viết cũng thế.

Quy tắc hiển thị (theo yêu cầu người dùng):

- **Chọn "Tự học"** (hoặc chưa làm khảo sát): hiển thị **đầy đủ**, không lọc,
  không có gợi ý, không có bàn tay.
- **Chọn 1 trong các gợi ý**: lọc theo mức độ, và hình **bàn tay chỉ vào mục
  gợi ý luôn hiển thị** (không tự tắt sau lần bấm đầu).

## 1. Hiện trạng (đo trực tiếp từ code, 12/09/2026)

| Phần | Hiện trạng | Vấn đề với việc lọc theo mức độ |
|---|---|---|
| Từ vựng (`vocabulary_data.dart`) | 59 chủ đề, 6.095 từ, **100% đã gắn nhãn** `VocabFrequency`: common 1.398 / medium 3.263 / rare 1.433 | Nhãn là **nhận định chủ quan** (comment trong code ghi rõ), chưa đối chiếu chuẩn CEFR. Một số chủ đề gần như không có từ common: Art 3, Common Idioms 4, Construction & Tools 8, Jewelry 8, Appearance 9 → người mới vào sẽ gần như trống. |
| Màn chi tiết chủ đề | Đã có tab Tất cả / Thông dụng / Thường gặp / Ít gặp, **mặc định "Tất cả"** | Chưa đọc persona, nên chưa tự chọn tab. |
| Viết – Gõ từ (`writing_vocab_quiz_screen.dart`) | Xáo trộn **toàn bộ ~100 từ** của chủ đề vào 1 vòng | Không lọc mức độ, và 1 vòng 100 từ là quá dài với mọi trình độ. |
| Viết – Đoạn văn (`writing_paragraph_data.dart`) | 24 chủ đề × **1 đoạn** × 6 câu = 144 câu, TB 9,3 từ/câu. **Mỗi đoạn trộn đủ 12 thì** (mỗi thì 12 câu) | Người mất gốc mở đoạn "Công việc" gặp ngay câu 1 thì *quá khứ hoàn thành*, câu 2 thì *quá khứ hoàn thành tiếp diễn*. Không có khái niệm cấp độ. |
| Luyện phát âm (`pronunciation_screen.dart`) | Chọn **ngẫu nhiên 1 dòng lyric** bất kỳ trong mọi bài hát | Độ khó dòng lyric rất chênh lệch, không lọc được. |
| Phonics (12 bài) | Đã có thứ tự 1→12 | Hợp với người mới, chỉ cần bàn tay chỉ vào bài kế tiếp. |
| Học nói (AI Voice Chat) | System prompt **cố định** "an intermediate English learner" (`gemini_live_direct_client.dart`, proxy `backend/gemini-proxy`, fallback `backend/fallback-pipeline/llm.py`) | Người mới bị AI nói quá nhanh/khó, còn người luyện IELTS thì thấy quá dễ. |
| Bàn tay trên Home | Chỉ hiện ở tile gợi ý đầu tiên (`isTopPick`), "Tự học" thì không có gợi ý nào — **logic đã đúng yêu cầu** | **Lỗi ẩn**: persona chỉ tải 1 lần từ Supabase lúc mở app (`learningPathChoiceProvider`), gặp lỗi mạng thì nuốt lỗi và trả `null`, cũng không tải lại khi đăng nhập/đổi tài khoản. Nếu mở app lúc mất mạng hoặc trước khi đăng nhập xong, bàn tay **mất cho đến lần mở app sau**. Đây nhiều khả năng là lý do bàn tay "lúc có lúc không". |

## 2. Khung mức độ: 6 persona → 3 cấp học

Không nên để mỗi màn tự suy luận từ 6 persona. Đề xuất gom về **1 enum
`LearnerLevel` duy nhất** (suy ra từ persona) để mọi feature đọc chung, bám
theo khung CEFR:

| Persona (khảo sát) | Cấp học | CEFR tương ứng | Từ vựng hiển thị |
|---|---|---|---|
| Mất gốc | **Cơ bản** | A1–A2 | chỉ `common` |
| Giao tiếp hằng ngày | **Trung cấp** | A2–B1 | `common` + `medium` |
| Ôn tập toàn diện (ngữ pháp) | **Trung cấp** | A2–B1 | `common` + `medium` |
| Tiếng Anh công sở | **Nâng cao** | B1–B2 | `medium` + `rare` |
| Luyện thi TOEIC | **Nâng cao** | B1–B2 | `medium` + `rare` |
| Luyện thi IELTS | **Nâng cao** | B2–C1 | `medium` + `rare` |
| Tự học / chưa chọn | *(không có)* | — | tất cả, không gợi ý |

Vì sao Nâng cao ẩn `common`: người đã đi làm hoặc luyện thi gần như chắc chắn
đã biết từ kiểu "mother", "water". Hiện chúng ra chỉ làm loãng danh sách.

### Hiệu chỉnh nhãn common/medium/rare theo chuẩn (khuyến nghị)

Vì nhãn hiện tại là cảm tính, nên đối chiếu 1 lần với danh sách từ theo CEFR:

- **CEFR-J Wordlist** (Tono Laboratory, ĐH Ngoại ngữ Tokyo – TUFS): **cho
  phép dùng thương mại miễn phí, chỉ cần trích dẫn nguồn.** Mỗi từ gắn cấp
  A1–B2 kèm từ loại (bổ sung C1–C2 qua Octanove Vocabulary Profile, giấy
  phép CC BY-SA 4.0). Có bản chuyển sẵn trên GitHub
  (`openlanguageprofiles/olp-en-cefrj`).
  Quy đổi đề xuất: A1 → `common`, A2–B1 → `medium`, B2 hoặc không có trong
  danh sách → `rare`.
- **KHÔNG dùng Oxford 3000/5000**: bản quyền của Oxford University Press,
  điều khoản cấm tái sử dụng nội dung trong ứng dụng.
- Cách làm: viết 1 script chạy offline (không đưa file CEFR-J vào app), so
  nhãn hiện tại với CEFR-J rồi **chỉ in ra danh sách từ lệch** để người soạn
  duyệt tay. Không tự động ghi đè. Ghi nguồn CEFR-J vào
  `ATTRIBUTION.md` và màn ghi công (`attribution_data.dart`).

## 3. Từ vựng theo chủ đề

1. **Lưới chủ đề** (`vocabulary_topics_screen.dart`): số từ trên mỗi thẻ
   chỉ đếm những từ thuộc cấp đang học. Ở cấp Cơ bản thì **ẩn chủ đề có dưới
   10 từ common** (Art, Common Idioms, Construction & Tools, Jewelry,
   Appearance) và **xếp chủ đề nhiều từ common lên đầu**: Daily Routines
   (74), Actions (69), Food (52), Time (47), Holidays & Festivals (42),
   School Supplies (41)… Bàn tay chỉ vào chủ đề gợi ý đầu tiên.
2. **Màn chi tiết**: thanh tab chỉ hiện các mức thuộc cấp đang học (Cơ bản
   chỉ còn "Thông dụng", nên có thể ẩn luôn thanh tab). Khi chọn "Tự học" thì
   giữ nguyên 4 tab như hiện nay.
3. **Nhãn của từ đã chọn vào danh sách "Học hôm nay"/quiz** không cần đổi,
   vì dữ liệu `DailyWordEntry` không phụ thuộc cấp.

## 4. Luyện viết

### 4a. Chế độ Gõ từ

| | Cơ bản | Trung cấp | Nâng cao |
|---|---|---|---|
| Nguồn từ | common | common + medium | medium + rare |
| Số từ / vòng | 10 | 15 | 20 |
| Gợi ý | chữ cái đầu + số ký tự + nút nghe | số ký tự | không gợi ý |
| Chấm điểm | lỗi chính tả nhẹ (`closeTypo`) vẫn tính đúng | như hiện tại | như hiện tại |

(Hiện tại là cả ~100 từ/vòng, không có gợi ý nào.)

### 4b. Chế độ Đoạn văn: chia lại theo cấp

Cấu trúc mỗi cấp bám theo trình tự ngữ pháp CEFR phổ biến (British Council /
EAQUALS Core Inventory, Cambridge English Grammar Profile):

| | Cơ bản (A1–A2) | Trung cấp (A2–B1) | Nâng cao (B1–C1) |
|---|---|---|---|
| Thì / cấu trúc | hiện tại đơn, hiện tại tiếp diễn, quá khứ đơn, tương lai đơn, *going to*, *can* | thêm: hiện tại hoàn thành, quá khứ tiếp diễn, so sánh hơn/nhất, câu điều kiện loại 1, bị động đơn giản | thêm: các thì hoàn thành tiếp diễn, quá khứ hoàn thành, tương lai tiếp diễn/hoàn thành, điều kiện loại 2–3, mệnh đề quan hệ, bị động phức |
| Độ dài câu | 5–8 từ | 8–12 từ | 12–20 từ |
| Số câu / bài | 4–5 | 5–6 | 6–8 |
| Từ vựng | common | common + medium | medium + rare |
| Liên từ | and, but | because, so, when, if | although, however, which, unless… |
| Văn phong | câu đời sống, ngôi "tôi" | kể chuyện, mô tả | email công sở (Công sở/TOEIC), lập luận (IELTS) |

Có thể tận dụng dữ liệu cũ: 60/144 câu hiện có đang dùng thì cấp Cơ bản
(hiện tại đơn/tiếp diễn, quá khứ đơn, tương lai đơn, *going to*), chuyển
sang ngân hàng Cơ bản được. Các câu thì hoàn thành đưa lên Trung cấp/Nâng
cao.

### 4c. Mục tiêu 20–30 bài mỗi chủ đề

Đề xuất **24 bài / chủ đề = 8 Cơ bản + 8 Trung cấp + 8 Nâng cao**, "bài" = 1
đoạn văn như hiện nay. Nhờ vậy mỗi cấp có đủ 8 bài để luyện, không hết bài
sau vài ngày.

Khối lượng nội dung phải soạn (quan trọng, cần chốt trước):

- 24 chủ đề × 24 bài = **576 đoạn ≈ 3.300 câu** song ngữ (hiện có 144 câu).
- Nên chia đợt: **Đợt 1** làm 8 chủ đề đời sống gần với người mới (Gia đình,
  Đồ ăn, Mua sắm, Thời tiết, Sở thích, Du lịch, Sức khoẻ, Công việc) × 24 bài
  = 192 đoạn. **Đợt 2** làm 16 chủ đề còn lại.
- Đổi tên chủ đề Đoạn văn cho **khớp với chủ đề Từ vựng** (vd `Traffic` ↔
  `Transportation`, `Finance` ↔ `Money & Banking`) để từ vừa học ở Từ vựng
  xuất hiện lại trong bài viết cùng chủ đề.
- **Chấm điểm**: hiện chỉ chấp nhận đúng 1 câu tham chiếu. Với 3.000+ câu,
  người học sẽ bị chấm sai oan nhiều, nên thêm trường `alternatives`
  (1–3 cách viết đúng khác cho mỗi câu). Riêng cấp Nâng cao có thể cân nhắc
  chấm thêm bằng LanguageTool (skill `grammar-check`).
- Model dữ liệu: thêm `level` vào `WritingParagraph` và `topicId` để nhóm các
  bài; test hiện tại (`writing_paragraph_data_test.dart`, đang ép "đúng 24
  đoạn × 6 câu, đủ 12 thì") phải viết lại theo quy tắc mới (mỗi cấp chỉ
  dùng thì thuộc cấp đó).

## 5. Luyện phát âm

| | Cơ bản | Trung cấp | Nâng cao |
|---|---|---|---|
| Nội dung luyện | từ đơn common + cụm 3–6 từ | câu 6–12 từ | câu 12+ từ, có nối âm |
| Tốc độ đọc mẫu (TTS) | chậm (~0,4) | bình thường | bình thường |
| Ngưỡng "đạt" | dễ (~60%) | ~70% | ~80% |
| Trọng tâm | Phonics bài 1–7 (âm đơn, âm cuối) | trọng âm từ/câu (bài 8–9) | ngữ điệu, nối âm (bài 10–11) |

- **Nguồn câu**: dùng lại chính **ngân hàng câu Đoạn văn cùng cấp** ở mục 4,
  vì câu đã được kiểm soát độ dài, thì và từ vựng. Một nguồn nội dung phục vụ
  được cả Viết lẫn Phát âm, không phải soạn thêm.
- Lyric vẫn giữ làm lựa chọn "Đổi câu", nhưng có thể lọc sơ theo độ dài dòng
  (số từ) và tỉ lệ từ thuộc nhóm `common` trong kho từ vựng.
- Phonics: không lọc bài nào, chỉ đặt bàn tay vào bài kế tiếp chưa học (Cơ
  bản bắt đầu từ bài 1, Nâng cao gợi ý thẳng bài 10–11).

## 6. Học nói (AI Voice Chat)

Chỉ cần đổi system prompt theo cấp, không cần tính năng mới. Phải sửa **cả 3
nơi** đang có prompt (client gọi thẳng Gemini, proxy Node, pipeline fallback
Python):

- **Cơ bản**: AI nói chậm, câu ≤ 8 từ, chỉ dùng từ A1–A2. Hỏi dạng Có/Không
  hoặc chọn 1 trong 2 ("Do you like tea or coffee?"). Mỗi lượt chỉ sửa **1
  lỗi quan trọng nhất**, được phép gợi ý 1 từ tiếng Việt khi người học bí.
- **Trung cấp**: như prompt hiện tại (sửa lỗi mỗi lượt, tốc độ tự nhiên).
- **Nâng cao**: tốc độ bản ngữ, có thành ngữ. Nhập vai theo persona: họp,
  email, phỏng vấn (Công sở/TOEIC) hoặc IELTS Speaking Part 1–3. Ngoài sửa
  lỗi còn gợi ý "cách nói tự nhiên hơn".
- Tự học: dùng prompt Trung cấp như hiện nay.

## 7. Bàn tay gợi ý & chế độ Tự học

1. **Tự học / chưa chọn**: không lọc, không sao, không bàn tay ở mọi màn.
2. **Đã chọn gợi ý**: bàn tay **luôn hiện** (không tắt sau lần bấm) ở:
   tile gợi ý đầu trên Home (đã có); chủ đề từ vựng gợi ý đầu tiên; chế độ
   Viết gợi ý (Cơ bản → Gõ từ, còn lại → Đoạn văn, lấy theo
   `kLearningPathStages`); bài Phonics kế tiếp; bài Đoạn văn chưa làm đầu
   tiên của cấp.
3. **Sửa lỗi bàn tay mất** (mục 1): lưu persona vào bộ nhớ máy
   (SharedPreferences) mỗi khi chọn/tải thành công, rồi đọc bản lưu trên máy
   trước, đồng bộ Supabase sau. Cho `learningPathChoiceProvider` tải lại khi
   trạng thái đăng nhập đổi (`authStateProvider`). Như vậy bàn tay hiện ngay
   cả khi mất mạng lúc mở app.
4. Nên có 1 nhãn nhỏ ở đầu mỗi màn đã lọc, ví dụ *"Đang hiển thị: Cơ bản ·
   Đổi"*, bấm vào mở lại khảo sát. Người dùng luôn biết vì sao chỉ thấy một
   phần nội dung, và đổi được mà không phải quay về Home.

## 8. Kế hoạch triển khai đề xuất

**Trạng thái (12/09/2026):**
- Xong bước 1–3: `LearnerLevel` + `learnerLevelProvider`, cache persona trên
  máy + tải lại khi đăng nhập/đăng xuất, lọc Từ vựng/Gõ từ + bàn tay + nhãn
  "Đang hiển thị cấp", prompt AI theo cấp ở cả 3 nơi.
- Xong bước 5 (Đoạn văn Đợt 1): `app/lib/features/writing/data/bank/` — 8
  chủ đề × 24 bài = 192 bài, 1.090 câu, mỗi câu có nhãn ngữ pháp + cách viết
  đúng khác (`alternatives`). Quy tắc cấp (số câu, số từ, cấu trúc được phép)
  nằm ở `writing_grammar.dart` và được `writing_bank_test.dart` kiểm tra. Bộ
  24 đoạn cũ giữ lại thành mục "Ôn tổng hợp 12 thì" (chỉ hiện với Tự học/Nâng
  cao). Tiến độ bài đã làm lưu trên máy (`writing_progress.dart`).
- Xong mục 5 (Phát âm): câu luyện lấy ngẫu nhiên từ ngân hàng Đoạn văn cùng
  cấp; Tự học vẫn dùng lyric.
- Xong bước 4: `scripts/check_vocab_cefr.py` (tải CEFR-J 1.5 lúc chạy, không
  đưa dữ liệu vào repo). Kết quả lần chạy 12/09/2026: 2.002/6.063 từ có trong
  CEFR-J, 994 từ lệch nhãn. **Không áp tự động** vì CEFR-J soạn cho người học
  Nhật (xếp "motorbike", "karaoke", "laptop", "rainbow", "friendly" là B2 —
  với người Việt đây là từ quen thuộc). Đã duyệt tay nhóm nghiêm trọng nhất
  (83 từ gắn common nhưng CEFR-J là B2) và hạ 34 từ thật sự khó với người mới
  xuống medium: client, contract, investment, profit, commute, drought,
  percentage, punctual, navigate, decade, vaccine, malaria… Nhóm common→medium
  (500 từ, ranh giới A1/A2) để duyệt dần. Đã ghi công CEFR-J ở `ATTRIBUTION.md`.
- Xong bước 6 (Đoạn văn Đợt 2): 16 chủ đề còn lại (Công nghệ, Môi trường,
  Học tập, Thể thao, Giao thông, Tiền bạc, Âm nhạc, Phim ảnh, Thú cưng, Bạn
  bè, Internet, Thành phố, Miền quê, Lễ hội, Sách, Khoa học) — đủ đúng 24 chủ
  đề khớp với bộ "Ôn tổng hợp 12 thì" cũ. **Tất cả 6 bước trong kế hoạch đã
  hoàn thành.**

Tổng kết ngân hàng Đoạn văn: **24 chủ đề × 24 bài = 576 bài, 3.266 câu song
ngữ** (`app/lib/features/writing/data/bank/`), mỗi câu có nhãn ngữ pháp +
1-3 cách viết đúng khác. Toàn bộ được `writing_bank_test.dart` kiểm tra tự
động: đúng số bài/cấp, đúng độ dài câu/cấu trúc ngữ pháp cho phép theo cấp,
không chứa chữ số, và chấm điểm 100 cho mọi đáp án hợp lệ.

1. **Nền tảng**: `LearnerLevel` + `learnerLevelProvider` (suy từ persona, có
   cache máy), sửa lỗi bàn tay mất. *(nhỏ)* — **Xong**
2. **Từ vựng + Gõ từ**: lọc/sắp xếp chủ đề, tab mặc định, số từ/vòng, gợi
   ý. *(nhỏ, dữ liệu đã có sẵn)* — **Xong**
3. **AI Voice Chat**: 3 bộ prompt theo cấp ở cả 3 nơi. *(nhỏ)* — **Xong**
4. **Script đối chiếu CEFR-J** và duyệt tay danh sách từ lệch. *(vừa)* —
   **Xong**
5. **Đoạn văn Đợt 1**: model `level`, 8 chủ đề × 24 bài, test mới, dùng
   làm nguồn câu Phát âm. *(lớn: phần soạn nội dung)* — **Xong**
6. **Đoạn văn Đợt 2**: 16 chủ đề còn lại. *(lớn)* — **Xong**

## 9. Đố vui: đã bổ sung

Ba chủ đề trước chỉ có 1–2 câu, nay đã lên **25 câu mỗi chủ đề**
(`quiz_data.dart`). Nội dung tự soạn, đáp án không trùng với các chủ đề sẵn
có:

- **Cuộc sống (Life)**: 1 → 25
- **Bảng chữ cái (Alphabet)**: 1 → 25 (âm đọc giống chữ cái, vị trí chữ,
  chữ câm, số La Mã…)
- **Trái cây & xe cộ (Fruits & Vehicles)**: 2 → 25 (trái cây nhiệt đới như
  sầu riêng, thanh long, vải, mít, khế và xe cộ như xích lô, cáp treo, phà…,
  không lặp với bộ "Trái cây & rau củ" và "Phương tiện giao thông")

Test mới `app/test/quiz_data_test.dart` kiểm tra: đủ 3 phương án nhiễu,
không trùng đáp án, không lặp câu, và 3 chủ đề trên có 20–30 câu.

## Nguồn

- CEFR-J Wordlist, giấy phép dùng thương mại có trích dẫn:
  https://github.com/openlanguageprofiles/olp-en-cefrj
- Oxford 3000 (bản quyền OUP, không dùng):
  https://www.oxfordlearnersdictionaries.com/external/pdf/wordlists/oxford-3000-5000/American_Oxford_3000.pdf
- Điều khoản Oxford Dictionaries API:
  https://developer.oxforddictionaries.com/api-terms-and-conditions

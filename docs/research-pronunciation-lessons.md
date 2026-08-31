# Nghiên cứu: Bài học phát âm "từ A đến Z" (curriculum có cấu trúc)

## 1. Có chuẩn sư phạm "A-Z" không?

Có, nhưng KHÔNG phải là học tên 26 chữ cái (A, B, C... đọc là "ây, bi, xi") — đó chỉ là bảng chữ cái (alphabet), gần như vô dụng cho phát âm thực tế vì tên chữ cái khác hoàn toàn với âm nó tạo ra trong từ (chữ "C" đọc "xi" nhưng trong "cat" lại phát âm /k/). Các giáo trình ESL/phonics nghiêm túc (Cambridge, Oxford, BBC Learning English, EnglishClub...) đều dạy theo **~44 âm vị (phoneme)** của tiếng Anh (theo bảng IPA rút gọn cho English — không phải toàn bộ IPA quốc tế), chia làm:

- 24 phụ âm (consonants)
- 20 nguyên âm/nguyên âm đôi (12 monophthongs + 8 diphthongs)

Trình tự chuẩn phổ biến: (1) nguyên âm đơn ngắn/dài → (2) nguyên âm đôi → (3) phụ âm theo cặp tương phản (voiced/voiceless: /p/-/b/, /t/-/d/, /s/-/z/...) → (4) các âm khó với người học cụ thể (với người Việt: /θ/-/ð/ "th", /r/-/l/, phụ âm cuối bị nuốt âm, /v/-/w/, trọng âm từ) → (5) trọng âm câu, ngữ điệu, nối âm (connected speech) ở cấp cao hơn. Đây chính là cấu trúc nên dùng thay vì "A đến Z" theo nghĩa đen.

## 2. Nguồn dữ liệu miễn phí, license an toàn cho thương mại

| Nguồn | Nội dung | License | Kết luận |
|---|---|---|---|
| **CMU Pronouncing Dictionary** (cmudict) | ~135k từ tiếng Anh Mỹ kèm phiên âm ARPAbet (quy đổi được sang IPA) | Bản quyền CMU 1993-2014 nhưng cho phép dùng **không giới hạn cho cả nghiên cứu và thương mại**; bản fork cmusphinx/cmudict dùng BSD 2-clause | **DÙNG ĐƯỢC** — nguồn tốt nhất, an toàn tuyệt đối, không ràng buộc chia sẻ ngược |
| **Wiktionary** (dữ liệu IPA) | IPA cho từ tiếng Anh (và nhiều ngôn ngữ), có cả biến thể Anh-Anh/Anh-Mỹ | CC BY-SA 4.0 | Dùng được thương mại **nhưng bắt buộc ghi công + mọi phần dẫn xuất phải giữ cùng license (share-alike)** — cần cân nhắc nếu app có mã nguồn đóng, chỉ áp dụng share-alike cho phần dữ liệu trích xuất, không lan sang code app |
| **open-dict-data/ipa-dict** (GitHub) | Wordlist IPA đóng gói sẵn JSON/CSV, nhiều ngôn ngữ | Bản thân repo: MIT; nhưng dữ liệu tiếng Anh trong đó lấy nguồn gốc từ CMUdict/Wiktionary tùy ngôn ngữ — cần kiểm tra file nguồn cụ thể | Dùng được nếu bản tiếng Anh bắt nguồn từ CMUdict (an toàn); tránh nếu bắt nguồn từ phần CC-BY-SA của Wiktionary mà không muốn ràng buộc share-alike |
| **IPA Chart chính thức (International Phonetic Association)** | Bảng IPA gốc | Từ 2015 đã chuyển sang **Creative Commons** (không phải phi thương mại) | Dùng được để hiển thị bảng IPA tham khảo trong app, chỉ cần ghi công đúng phiên bản CC áp dụng |
| **Open Source Phonics / OER Commons (phonics)** | Giáo trình phonics tiếng Anh (thường hướng tới trẻ em bản ngữ, không phải ESL) | Đa số ghi "free for teachers/tutors" — KHÔNG có tuyên bố license rõ ràng kiểu CC0/CC-BY | **CHƯA XÁC MINH — không dùng nguyên trạng**, chỉ tham khảo cấu trúc bài học rồi tự biên soạn lại nội dung |
| **Danh sách minimal pairs từ các trang SLP/ESL** (speech-language-therapy.com, thepedispeechie...) | Danh sách từ cặp tối thiểu (ship/sheep, think/sink...) | Phần lớn ghi "for personal/educational use", không có license thương mại rõ ràng | **REJECTED nếu copy nguyên văn** — chỉ dùng làm tài liệu tham khảo ý tưởng, tự biên soạn lại danh sách từ bằng tay (từ vựng tiếng Anh cơ bản là dữ kiện ngôn ngữ, không có bản quyền, nhưng *cách chọn/sắp xếp cặp từ cụ thể của tác giả* thì có) |
| **Nguồn Vietnamese-specific problem sounds** (bài báo ngôn ngữ học, tài liệu ĐH Sư phạm/Ngoại ngữ VN về lỗi phát âm người Việt học tiếng Anh) | Kiến thức mô tả lỗi phổ biến (âm cuối, th, r/l, trọng âm) | Đây là **kiến thức ngôn ngữ học chung**, không phải dữ liệu có bản quyền cụ thể | An toàn dùng làm căn cứ tự biên soạn nội dung bài học, không cần trích dẫn nguyên văn |

**Kết luận nguồn dữ liệu**: Kết hợp **CMU Pronouncing Dictionary (an toàn tuyệt đối, để tra phiên âm IPA/ARPAbet cho từ bất kỳ)** + **tự biên soạn thủ công nội dung bài học, ví dụ minh họa, danh sách minimal pairs** dựa trên kiến thức ngôn ngữ học công khai. Không nhúng nguyên văn bảng minimal-pair hay giáo trình phonics của bên thứ ba vì license không rõ ràng.

## 3. Đề xuất outline 12 bài học (feature mới, gợi ý đặt tên "Phonics Path" hoặc "Âm chuẩn A-Z")

1. **Giới thiệu**: Phân biệt "tên chữ cái" vs "âm vị" (bảng chữ cái không phải phát âm) — hand-authored (nội dung giải thích + audio TTS `flutter_tts`).
2. **12 nguyên âm đơn** (/iː/, /ɪ/, /e/, /æ/, /ʌ/, /ɑː/, /ɒ/, /ɔː/, /ʊ/, /uː/, /ɜː/, /ə/) — data-driven: từ ví dụ tra từ CMU dict theo âm vị mục tiêu.
3. **8 nguyên âm đôi** (/eɪ/, /aɪ/, /ɔɪ/, /aʊ/, /əʊ/, /ɪə/, /eə/, /ʊə/) — data-driven như trên.
4. **Phụ âm tắc (plosives)** /p b t d k g/ theo cặp voiced/voiceless — data-driven + minimal pairs tự biên soạn.
5. **Phụ âm xát (fricatives)** /f v θ ð s z ʃ ʒ h/ — trọng tâm /θ/-/ð/ ("th") vì đây là âm khó nhất với người Việt — hand-authored (mẹo đặt lưỡi, video/hình minh họa).
6. **Phụ âm mũi & tiếp cận** /m n ŋ l r w j/ — trọng tâm /r/-/l/ và /v/-/w/ (lỗi phổ biến người Việt) — hand-authored.
7. **Phụ âm cuối từ (final consonants)** — vấn đề đặc thù người Việt hay nuốt âm cuối (final /t/, /d/, /s/, cụm phụ âm cuối "-sts", "-nds") — hand-authored, ví dụ lấy từ chính lyric bài hát trong app (tận dụng nội dung sẵn có).
8. **Trọng âm từ (word stress)** — quy tắc cơ bản (danh từ 2 âm tiết trọng âm 1, động từ trọng âm 2...) — hand-authored quy tắc + data-driven ví dụ (CMU dict có đánh dấu trọng âm bằng số 0/1/2 trong ARPAbet).
9. **Trọng âm câu (sentence stress)** — content word vs function word — hand-authored.
10. **Ngữ điệu (intonation)** — câu hỏi Yes/No lên giọng, Wh-question xuống giọng — hand-authored.
11. **Nối âm (connected speech)**: liaison, elision, assimilation (ví dụ "want to" → "wanna") — hand-authored, nội dung nâng cao.
12. **Ôn tập tổng hợp qua bài hát**: chọn 1 bài hát đã có trong app, phân tích toàn bộ các hiện tượng ở bài 1-11 xuất hiện trong lời bài hát đó — hand-authored, tận dụng module lyric sẵn có + tích hợp với feature Pronunciation Practice để luyện và chấm điểm.

(Có thể rút gọn còn 10 bài bằng cách gộp bài 8+9 và 10+11 nếu muốn MVP nhỏ hơn.)

## Khuyến nghị triển khai

- Dùng **CMU Pronouncing Dictionary** làm nguồn tra IPA/trọng âm on-device (đóng gói file dữ liệu trong app, không cần API, không cần backend) — nhẹ, offline, miễn phí, license an toàn tuyệt đối cho thương mại.
- Nội dung giải thích, mẹo phát âm, ví dụ minimal-pairs, bài tập: **tự biên soạn thủ công** (giống cách đã làm với nhạc CC0/CC-BY chọn lọc thủ công), không copy nguyên văn từ các trang phonics/SLP có license không rõ.
- Tận dụng lại hạ tầng đã có: `flutter_tts` (đọc mẫu âm), `speech_to_text` + logic chấm điểm đã có trong `app/lib/features/pronunciation/` (luyện tập theo từng bài học), module lyric-sync (bài 12 dùng lại bài hát có sẵn).
- Đề xuất đặt feature mới trong `app/lib/features/pronunciation/lessons/` (cùng feature Pronunciation, khác submodule) để tái dùng logic ghi âm/chấm điểm.

## Nguồn tham khảo

- [CMU Pronouncing Dictionary license discussion — Kaggle](https://www.kaggle.com/datasets/rtatman/cmu-pronouncing-dictionary/tasks)
- [cmusphinx/cmudict — GitHub](https://github.com/cmusphinx/cmudict)
- [CMU Pronouncing Dictionary — Wikipedia](https://en.wikipedia.org/wiki/CMU_Pronouncing_Dictionary)
- [Wiktionary — Wikipedia (CC BY-SA licensing)](https://en.wikipedia.org/wiki/Wiktionary)
- [open-dict-data/ipa-dict — GitHub](https://github.com/open-dict-data/ipa-dict)
- [open-dict-data — Open-licensed dictionary data](https://open-dict-data.github.io/)
- [IPA Chart now under Creative Commons license — Journal of the IPA](https://www.cambridge.org/core/journals/journal-of-the-international-phonetic-association/article/ipa-chart-now-under-creative-commons-license/F6F557051ABF7E5F89C02F8EB7D32158)
- [Full IPA Chart — International Phonetic Association](https://www.internationalphoneticassociation.org/content/full-ipa-chart)
- [Homepage — Open Source Phonics](https://www.opensourcephonics.org/)
- [Word Lists: Minimal Pairs — speech-language-therapy.com](https://speech-language-therapy.com/index.php?option=com_content&view=article&id=134%3Amp2&catid=9%3Aresources&Itemid=108)
- [Minimal Pairs by Phonological Process — thepedispeechie.com](https://thepedispeechie.com/2026/02/minimal-pairs-by-phonological-processes-free-lists-for-slps.html)

## Các file liên quan trong repo

- `docs/research-pronunciation.md` (nghiên cứu hiện có về chấm điểm phát âm, khác chủ đề nhưng liên quan)
- `docs/research-ai-voice.md` (giải thích giới hạn ASR ở mức âm vị)
- `app/lib/features/pronunciation/` (nơi nên đặt feature "bài học phát âm" mới)

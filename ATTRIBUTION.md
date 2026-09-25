# Ghi công (Attribution)

File này liệt kê ghi công bắt buộc cho các track nhạc CC-BY dùng trong app,
theo quy tắc bắt buộc trong [CLAUDE.md](CLAUDE.md#nguồn-nhạc--quan-trọng-về-bản-quyền).

## Josh Woodward — CC-BY 4.0

Tác giả: **Josh Woodward** — https://www.joshwoodward.com/
Giấy phép: Creative Commons Attribution 4.0 (https://creativecommons.org/licenses/by/4.0/)
Điều khoản license đầy đủ của tác giả: http://www.joshwoodward.com/licenses

Các bài hát sau được dùng trong app, âm thanh host tại `content/audio/`:

- **"Don't Close Your Eyes"** — Josh Woodward, album *The Simple Life* (2007) — https://www.joshwoodward.com/song/DontCloseYourEyes
- **"Circles"** — Josh Woodward — https://www.joshwoodward.com/song/Circles
- **"Same Boat"** — Josh Woodward, album *The Shade from Our Trees* (2019) — https://www.joshwoodward.com/song/SameBoat
- **"A Thousand Years"** — Josh Woodward — https://www.joshwoodward.com/song/AThousandYears
- **"California Lullabye"** — Josh Woodward, album *The Beautiful Machine* — https://www.joshwoodward.com/song/CaliforniaLullabye
- **"Cherubs"** — Josh Woodward, album *Ashes* — https://www.joshwoodward.com/song/Cherubs
- **"Crazy Glue"** — Josh Woodward, album *The Wake* — https://www.joshwoodward.com/song/CrazyGlue
- **"Flickering Flame"** — Josh Woodward — https://www.joshwoodward.com/song/FlickeringFlame
- **"Goodbye to Spring"** — Josh Woodward, album *Only Whispering* — https://www.joshwoodward.com/song/GoodbyeToSpring
- **"I'm Letting Go"** — Josh Woodward, album *The Simple Life* — https://www.joshwoodward.com/song/ImLettingGo
- **"Let It In"** — Josh Woodward, album *Ashes* — https://www.joshwoodward.com/song/LetItIn
- **"My Favorite Regret"** — Josh Woodward feat. Katie Pederson — https://www.joshwoodward.com/song/MyFavoriteRegret
- **"Release"** — Josh Woodward — https://www.joshwoodward.com/song/Release
- **"Saboteurs"** — Josh Woodward — https://www.joshwoodward.com/song/Saboteurs
- **"She Dreams in Blue"** — Josh Woodward, album *Not Quite Connected* — https://www.joshwoodward.com/song/SheDreamsinBlue
- **"Swansong"** — Josh Woodward, album *Breadcrumbs* — https://www.joshwoodward.com/song/Swansong
- **"The Box"** — Josh Woodward — https://www.joshwoodward.com/song/TheBox
- **"The Long Fade"** — Josh Woodward — https://www.joshwoodward.com/song/TheLongFade
- **"The Maze"** — Josh Woodward — https://www.joshwoodward.com/song/TheMaze
- **"The Nest"** — Josh Woodward — https://www.joshwoodward.com/song/TheNest

Lời bài hát (lyrics) trích từ dữ liệu `MusicComposition` (schema.org JSON-LD)
công khai trên chính trang bài hát của tác giả, dùng cho mục đích học ngôn ngữ
theo đúng phạm vi cho phép của CC-BY 4.0 (cho phép sao chép, chuyển thể, dùng
thương mại, miễn có ghi công như trên).

## CEFR-J Wordlist

Nhãn mức độ từ vựng (Thông dụng/Thường gặp/Ít gặp) trong
`app/lib/features/vocabulary/data/vocabulary_data.dart` được đối chiếu và
hiệu chỉnh thủ công với CEFR-J Wordlist bằng `scripts/check_vocab_cefr.py`.

Lộ trình tiếng Anh A1 → C1 dùng cấp CEFR của CEFR-J để xếp từ vựng vào từng
Stage/Unit trong Content Pack (`app/assets/english_path/pack.json`, sinh bởi
`scripts/english_path_pipeline.py`). Pack chỉ chứa cấp CEFR của các từ đã
chọn, không chứa bản sao file CEFR-J. File CSV gốc không được đưa vào repo;
script tải trực tiếp mỗi lần chạy.

- The CEFR-J Wordlist Version 1.5. Compiled by Yukio Tono, Tokyo University of
  Foreign Studies. http://www.cefr-j.org/ — bản phân phối:
  https://github.com/openlanguageprofiles/olp-en-cefrj
- Điều khoản: được dùng cho nghiên cứu và thương mại miễn phí, với điều kiện
  trích dẫn nguồn như trên. Bản quyền thuộc Tono Laboratory, TUFS.

## Tatoeba — CC BY 2.0 FR

Lộ trình tiếng Anh dùng các cặp câu Anh–Việt từ Tatoeba (https://tatoeba.org) cho dạng câu Gap-fill. Mỗi item giữ số hiệu câu gốc trong trường `sourceRef` (`tatoeba:eng#<id>/vie#<id>`), trỏ tới https://tatoeba.org/en/sentences/show/<id>, là nơi ghi tên người đóng góp từng câu.

- Nguồn: Tatoeba, bản export theo ngôn ngữ (eng, vie, liên kết vie-eng): https://tatoeba.org/en/downloads
- Giấy phép: Creative Commons Attribution 2.0 France (CC BY 2.0 FR): https://creativecommons.org/licenses/by/2.0/fr/
- Snapshot đã lọc (câu ≤ 12 từ, không có tên riêng): `scripts/english_path/data/tatoeba_eng_vie.tsv`. Một số bản dịch tiếng Việt được chỉnh lại sau review, ghi trong `scripts/english_path/review/exclusions.json`.

## New Academic Word List (NAWL) — CC BY-SA 4.0

Bậc C1 của lộ trình tiếng Anh gồm các từ học thuật có trong NAWL nhưng nằm ngoài danh sách A1–B2 của CEFR-J. Nghĩa tiếng Việt, IPA và câu ví dụ của các từ này là nội dung tự soạn của GymTalk; NAWL chỉ được dùng để chọn từ.

- Browne, C., Culligan, B., & Phillips, J. (2013). *New Academic Word List 1.2*. https://www.newgeneralservicelist.com/new-academic-word-list
- Giấy phép: Creative Commons Attribution-ShareAlike 4.0 (https://creativecommons.org/licenses/by-sa/4.0/).
- Danh sách headword được lưu **trong một file riêng** là `scripts/english_path/data/nawl_headwords.txt`, và file đó giữ nguyên giấy phép CC BY-SA 4.0.


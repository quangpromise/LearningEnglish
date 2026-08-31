import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// 12 bai hoc phat am co cau truc, di tu am vi co ban den trong am/ngu dieu/
/// noi am - xem docs/research-pronunciation-lessons.md cho ly do chon cau
/// truc nay (day theo ~44 am vi tieng Anh, KHONG phai day ten 26 chu cai -
/// ten chu cai gan nhu vo dung cho phat am thuc te). Toan bo giai thich,
/// meo phat am va vi du trong file nay la noi dung TU BIEN SOAN (khong sao
/// chep tu bat ky giao trinh/website cu the nao) - ky hieu IPA va kien thuc
/// ngu am hoc la kien thuc giao duc pho thong, khong thuoc ban quyen cua ai.
class PhonicsExample {
  const PhonicsExample({required this.en, required this.vi});

  /// Tu/cau vi du tieng Anh - co the dua vao AppTts.speak() de nghe mau.
  final String en;

  /// Ghi chu tieng Viet ngan (nghia hoac cach doc gan dung).
  final String vi;
}

/// 1 am/quy tac trong 1 bai hoc, vd am vi "/θ/" hoac quy tac "Danh tu 2 am
/// tiet -> trong am 1".
class PhonicsItem {
  const PhonicsItem({
    required this.label,
    required this.description,
    this.examples = const [],
  });

  final String label;
  final String description;
  final List<PhonicsExample> examples;
}

class PhonicsLesson {
  const PhonicsLesson({
    required this.title,
    required this.titleEn,
    required this.icon,
    required this.color,
    required this.intro,
    required this.items,
  });

  final String title;
  final String titleEn;
  final IconData icon;
  final Color color;

  /// Doan gioi thieu ngan cho ca bai hoc.
  final String intro;
  final List<PhonicsItem> items;
}

const kPhonicsLessons = <PhonicsLesson>[
  PhonicsLesson(
    title: 'Tên chữ cái ≠ Âm phát âm',
    titleEn: 'Letter Names vs. Sounds',
    icon: Icons.abc_rounded,
    color: AppColors.blue,
    intro:
        'Đọc thuộc bảng chữ cái A, B, C... không giúp phát âm đúng, vì tên '
        'chữ cái khác hoàn toàn với âm nó tạo ra khi đứng trong từ. 44 bài '
        'học tiếp theo sẽ đi thẳng vào các ÂM (phoneme) thật sự dùng khi nói.',
    items: [
      PhonicsItem(
        label: 'C',
        description:
            'Tên chữ đọc là "xi" nhưng trong từ lại có 2 âm hoàn toàn khác '
            'nhau tuỳ từ: /k/ hoặc /s/.',
        examples: [
          PhonicsExample(en: 'cat', vi: '/kæt/ — con mèo'),
          PhonicsExample(en: 'city', vi: '/ˈsɪti/ — thành phố'),
        ],
      ),
      PhonicsItem(
        label: 'A',
        description:
            'Tên chữ đọc "ây" nhưng trong từ có thể là 1 trong nhiều âm '
            'khác nhau, tuỳ từng từ cụ thể.',
        examples: [
          PhonicsExample(en: 'cat', vi: '/æ/'),
          PhonicsExample(en: 'cake', vi: '/eɪ/'),
          PhonicsExample(en: 'car', vi: '/ɑː/'),
        ],
      ),
    ],
  ),
  PhonicsLesson(
    title: '12 nguyên âm đơn',
    titleEn: 'Monophthong Vowels',
    icon: Icons.graphic_eq_rounded,
    color: AppColors.teal,
    intro:
        'Nguyên âm đơn là 1 âm giữ nguyên từ đầu đến cuối (không đổi hình '
        'miệng giữa chừng như nguyên âm đôi). Đây là nền tảng quan trọng '
        'nhất vì xuất hiện trong hầu hết mọi từ tiếng Anh.',
    items: [
      PhonicsItem(
        label: '/iː/',
        description: 'Âm dài, môi kéo ngang như đang mỉm cười.',
        examples: [
          PhonicsExample(en: 'see', vi: 'nhìn thấy'),
          PhonicsExample(en: 'tea', vi: 'trà'),
        ],
      ),
      PhonicsItem(
        label: '/ɪ/',
        description: 'Âm ngắn hơn /iː/ rất nhiều, miệng mở hẹp hơn.',
        examples: [
          PhonicsExample(en: 'sit', vi: 'ngồi'),
          PhonicsExample(en: 'big', vi: 'to lớn'),
        ],
      ),
      PhonicsItem(
        label: '/e/',
        description: 'Gần giống "e" tiếng Việt nhưng ngắn và gọn hơn.',
        examples: [
          PhonicsExample(en: 'bed', vi: 'giường'),
          PhonicsExample(en: 'pen', vi: 'bút'),
        ],
      ),
      PhonicsItem(
        label: '/æ/',
        description:
            'Miệng mở rộng hơn /e/, không có âm tương đương trong '
            'tiếng Việt — hay bị người Việt đọc nhầm thành /e/.',
        examples: [
          PhonicsExample(en: 'cat', vi: 'con mèo'),
          PhonicsExample(en: 'bad', vi: 'tệ'),
        ],
      ),
      PhonicsItem(
        label: '/ʌ/',
        description: 'Âm ngắn, giữa lưỡi, hơi giống "ă" nhưng mở hơn.',
        examples: [
          PhonicsExample(en: 'cup', vi: 'cái tách'),
          PhonicsExample(en: 'love', vi: 'yêu'),
        ],
      ),
      PhonicsItem(
        label: '/ɑː/',
        description: 'Âm dài, miệng mở to, lưỡi hạ thấp ra sau.',
        examples: [
          PhonicsExample(en: 'car', vi: 'xe hơi'),
          PhonicsExample(en: 'father', vi: 'cha'),
        ],
      ),
      PhonicsItem(
        label: '/ɒ/',
        description: 'Âm ngắn, tròn môi, gần giống "o" tiếng Việt.',
        examples: [
          PhonicsExample(en: 'hot', vi: 'nóng'),
          PhonicsExample(en: 'dog', vi: 'con chó'),
        ],
      ),
      PhonicsItem(
        label: '/ɔː/',
        description: 'Âm dài, tròn môi hơn /ɒ/, kéo dài hơn.',
        examples: [
          PhonicsExample(en: 'saw', vi: 'đã nhìn thấy'),
          PhonicsExample(en: 'door', vi: 'cửa'),
        ],
      ),
      PhonicsItem(
        label: '/ʊ/',
        description: 'Âm ngắn, tròn môi nhẹ, gần giống "ư" nhưng tròn môi.',
        examples: [
          PhonicsExample(en: 'book', vi: 'sách'),
          PhonicsExample(en: 'put', vi: 'đặt'),
        ],
      ),
      PhonicsItem(
        label: '/uː/',
        description: 'Âm dài, tròn môi rõ, môi đưa ra phía trước.',
        examples: [
          PhonicsExample(en: 'food', vi: 'thức ăn'),
          PhonicsExample(en: 'blue', vi: 'màu xanh'),
        ],
      ),
      PhonicsItem(
        label: '/ɜː/',
        description:
            'Âm dài, giữa lưỡi, môi hơi kéo dẹt — không có âm '
            'tương đương trong tiếng Việt.',
        examples: [
          PhonicsExample(en: 'bird', vi: 'con chim'),
          PhonicsExample(en: 'girl', vi: 'cô gái'),
        ],
      ),
      PhonicsItem(
        label: '/ə/ (schwa)',
        description:
            'Âm phổ biến nhất trong tiếng Anh — âm "lười", phát ra tự nhiên '
            'khi miệng thả lỏng, chỉ xuất hiện ở âm tiết KHÔNG có trọng âm.',
        examples: [
          PhonicsExample(en: 'about', vi: 'khoảng, về'),
          PhonicsExample(en: 'sofa', vi: 'ghế sofa'),
        ],
      ),
    ],
  ),
  PhonicsLesson(
    title: '8 nguyên âm đôi',
    titleEn: 'Diphthong Vowels',
    icon: Icons.multiline_chart_rounded,
    color: AppColors.purple,
    intro:
        'Nguyên âm đôi là 2 nguyên âm trượt liền nhau trong CÙNG 1 âm tiết, '
        'miệng đổi hình dạng dần dần từ âm này sang âm kia.',
    items: [
      PhonicsItem(
        label: '/eɪ/',
        description: 'Trượt từ /e/ sang /ɪ/.',
        examples: [
          PhonicsExample(en: 'day', vi: 'ngày'),
          PhonicsExample(en: 'name', vi: 'tên'),
        ],
      ),
      PhonicsItem(
        label: '/aɪ/',
        description: 'Trượt từ /a/ sang /ɪ/.',
        examples: [
          PhonicsExample(en: 'my', vi: 'của tôi'),
          PhonicsExample(en: 'time', vi: 'thời gian'),
        ],
      ),
      PhonicsItem(
        label: '/ɔɪ/',
        description: 'Trượt từ /ɔ/ sang /ɪ/.',
        examples: [
          PhonicsExample(en: 'boy', vi: 'con trai'),
          PhonicsExample(en: 'toy', vi: 'đồ chơi'),
        ],
      ),
      PhonicsItem(
        label: '/aʊ/',
        description: 'Trượt từ /a/ sang /ʊ/.',
        examples: [
          PhonicsExample(en: 'now', vi: 'bây giờ'),
          PhonicsExample(en: 'house', vi: 'ngôi nhà'),
        ],
      ),
      PhonicsItem(
        label: '/əʊ/',
        description: 'Trượt từ /ə/ sang /ʊ/ (giọng Anh-Mỹ thường đọc là /oʊ/).',
        examples: [
          PhonicsExample(en: 'go', vi: 'đi'),
          PhonicsExample(en: 'home', vi: 'nhà'),
        ],
      ),
      PhonicsItem(
        label: '/ɪə/',
        description: 'Trượt từ /ɪ/ sang /ə/.',
        examples: [
          PhonicsExample(en: 'here', vi: 'ở đây'),
          PhonicsExample(en: 'near', vi: 'gần'),
        ],
      ),
      PhonicsItem(
        label: '/eə/',
        description: 'Trượt từ /e/ sang /ə/.',
        examples: [
          PhonicsExample(en: 'hair', vi: 'tóc'),
          PhonicsExample(en: 'care', vi: 'quan tâm'),
        ],
      ),
      PhonicsItem(
        label: '/ʊə/',
        description: 'Trượt từ /ʊ/ sang /ə/ — khá hiếm gặp.',
        examples: [
          PhonicsExample(en: 'tour', vi: 'chuyến tham quan'),
          PhonicsExample(en: 'pure', vi: 'tinh khiết'),
        ],
      ),
    ],
  ),
  PhonicsLesson(
    title: 'Phụ âm tắc (Plosives)',
    titleEn: 'Plosive Consonants',
    icon: Icons.bolt_rounded,
    color: AppColors.amber,
    intro:
        'Phụ âm tắc được tạo ra bằng cách chặn luồng khí hoàn toàn rồi bật '
        'ra đột ngột. Mỗi âm đi theo cặp: 1 vô thanh (không rung dây thanh) '
        'và 1 hữu thanh (có rung dây thanh) — đặt tay lên cổ họng để cảm '
        'nhận sự rung khi phát âm.',
    items: [
      PhonicsItem(
        label: '/p/ – /b/',
        description: '/p/ vô thanh, /b/ hữu thanh — cùng vị trí môi.',
        examples: [
          PhonicsExample(en: 'pin', vi: 'cái ghim'),
          PhonicsExample(en: 'bin', vi: 'thùng rác'),
        ],
      ),
      PhonicsItem(
        label: '/t/ – /d/',
        description: '/t/ vô thanh, /d/ hữu thanh — đầu lưỡi chạm lợi trên.',
        examples: [
          PhonicsExample(en: 'town', vi: 'thị trấn'),
          PhonicsExample(en: 'down', vi: 'xuống'),
        ],
      ),
      PhonicsItem(
        label: '/k/ – /g/',
        description:
            '/k/ vô thanh, /g/ hữu thanh — gốc lưỡi chạm vòm miệng '
            'mềm.',
        examples: [
          PhonicsExample(en: 'cold', vi: 'lạnh'),
          PhonicsExample(en: 'gold', vi: 'vàng'),
        ],
      ),
    ],
  ),
  PhonicsLesson(
    title: 'Phụ âm xát (Fricatives)',
    titleEn: 'Fricative Consonants',
    icon: Icons.air_rounded,
    color: AppColors.pink,
    intro:
        'Phụ âm xát tạo ra bằng cách cho luồng khí cọ xát qua 1 khe hẹp '
        '(không chặn hoàn toàn như phụ âm tắc). Cặp /θ/-/ð/ ("th") là khó '
        'nhất với người Việt vì tiếng Việt không có âm tương đương.',
    items: [
      PhonicsItem(
        label: '/f/ – /v/',
        description: 'Răng trên chạm môi dưới, /f/ vô thanh, /v/ hữu thanh.',
        examples: [
          PhonicsExample(en: 'fan', vi: 'cái quạt'),
          PhonicsExample(en: 'van', vi: 'xe tải nhỏ'),
        ],
      ),
      PhonicsItem(
        label: '/θ/ – /ð/ ("th")',
        description:
            'Đặt đầu lưỡi giữa 2 hàm răng, thổi hơi nhẹ ra ngoài (/θ/) hoặc '
            'rung dây thanh (/ð/). Lỗi rất phổ biến: người Việt hay thay '
            'bằng "t"/"s" (think → "tink"/"sink").',
        examples: [
          PhonicsExample(en: 'think', vi: '/θ/ — suy nghĩ'),
          PhonicsExample(en: 'this', vi: '/ð/ — cái này'),
        ],
      ),
      PhonicsItem(
        label: '/s/ – /z/',
        description: 'Đầu lưỡi gần lợi trên, /s/ vô thanh, /z/ hữu thanh.',
        examples: [
          PhonicsExample(en: 'sip', vi: 'nhấp một ngụm'),
          PhonicsExample(en: 'zip', vi: 'kéo khoá'),
        ],
      ),
      PhonicsItem(
        label: '/ʃ/ – /ʒ/',
        description:
            '/ʃ/ như "s" trong "she", /ʒ/ hiếm hơn, xuất hiện '
            'giữa từ.',
        examples: [
          PhonicsExample(en: 'she', vi: '/ʃ/ — cô ấy'),
          PhonicsExample(en: 'measure', vi: '/ʒ/ — đo lường'),
        ],
      ),
    ],
  ),
  PhonicsLesson(
    title: 'Phụ âm mũi & tiếp cận',
    titleEn: 'Nasals & Approximants',
    icon: Icons.waves_rounded,
    color: AppColors.blue,
    intro:
        'Nhóm này gồm các âm "mềm" hơn phụ âm tắc/xát. Cặp /r/-/l/ và '
        '/v/-/w/ là 2 lỗi phổ biến nhất của người Việt khi học tiếng Anh.',
    items: [
      PhonicsItem(
        label: '/m/ – /n/ – /ŋ/',
        description:
            'Phụ âm mũi: /m/ (môi khép), /n/ (lưỡi chạm lợi), /ŋ/ '
            '(gốc lưỡi, như "ng" tiếng Việt, luôn ở CUỐI âm tiết).',
        examples: [
          PhonicsExample(en: 'sum', vi: '/m/ — tổng'),
          PhonicsExample(en: 'sun', vi: '/n/ — mặt trời'),
          PhonicsExample(en: 'sung', vi: '/ŋ/ — đã hát'),
        ],
      ),
      PhonicsItem(
        label: '/l/ – /r/',
        description:
            '/l/: đầu lưỡi chạm lợi trên, luồng khí đi 2 bên lưỡi. /r/: '
            'lưỡi cong lên nhưng KHÔNG chạm vào đâu cả — đây là điểm khác '
            'biệt lớn nhất khiến người Việt hay lẫn lộn 2 âm này.',
        examples: [
          PhonicsExample(en: 'light', vi: '/l/ — ánh sáng'),
          PhonicsExample(en: 'right', vi: '/r/ — đúng, bên phải'),
        ],
      ),
      PhonicsItem(
        label: '/v/ – /w/',
        description:
            '/v/: răng trên chạm môi dưới (giống /f/ nhưng rung dây thanh). '
            '/w/: tròn môi, không chạm răng — người Việt hay phát âm cả 2 '
            'giống nhau.',
        examples: [
          PhonicsExample(en: 'vet', vi: '/v/ — bác sĩ thú y'),
          PhonicsExample(en: 'wet', vi: '/w/ — ướt'),
        ],
      ),
    ],
  ),
  PhonicsLesson(
    title: 'Âm cuối từ',
    titleEn: 'Final Consonants',
    icon: Icons.stop_circle_rounded,
    color: AppColors.teal,
    intro:
        'Đây là lỗi phổ biến NHẤT của người Việt: tiếng Việt hầu như không '
        'kết thúc âm tiết bằng phụ âm bật hơi, nên người học hay bỏ hẳn âm '
        'cuối tiếng Anh, khiến người nghe bản ngữ khó hiểu hoặc hiểu nhầm '
        'sang từ khác.',
    items: [
      PhonicsItem(
        label: 'Âm cuối đơn: /t/, /d/, /s/, /z/',
        description:
            'Không cần bật hơi mạnh, nhưng PHẢI giữ lại — bỏ mất âm cuối '
            'khiến "cat" nghe thành "ca", "dogs" nghe thành "dog".',
        examples: [
          PhonicsExample(en: 'cat', vi: 'con mèo (giữ /t/ cuối)'),
          PhonicsExample(en: 'dogs', vi: 'những con chó (giữ /z/ cuối)'),
        ],
      ),
      PhonicsItem(
        label: 'Cụm phụ âm cuối (consonant clusters)',
        description:
            'Nhiều phụ âm đứng liền nhau ở cuối từ — phải đọc đủ TỪNG âm, '
            'không được lược bớt hay biến thành 1 âm duy nhất.',
        examples: [
          PhonicsExample(en: 'months', vi: '/mʌnθs/ — những tháng'),
          PhonicsExample(en: 'asked', vi: '/ɑːskt/ — đã hỏi'),
        ],
      ),
    ],
  ),
  PhonicsLesson(
    title: 'Trọng âm từ',
    titleEn: 'Word Stress',
    icon: Icons.format_bold_rounded,
    color: AppColors.amber,
    intro:
        'Trọng âm là âm tiết được đọc to hơn, dài hơn, rõ hơn các âm tiết '
        'khác trong từ. Đặt sai trọng âm khiến người bản ngữ khó nhận ra '
        'từ, dù từng âm phát âm đúng.',
    items: [
      PhonicsItem(
        label: 'Danh từ 2 âm tiết → trọng âm 1',
        description: 'Nhiều danh/tính từ 2 âm tiết nhấn vào âm tiết ĐẦU.',
        examples: [
          PhonicsExample(en: 'PREsent', vi: '(n) món quà'),
          PhonicsExample(en: 'REcord', vi: '(n) kỷ lục, bản ghi'),
        ],
      ),
      PhonicsItem(
        label: 'Động từ 2 âm tiết → trọng âm 2',
        description:
            'Cùng 1 từ nhưng khi làm động từ lại nhấn vào âm tiết SAU — '
            'khác nghĩa hoàn toàn với dạng danh từ ở trên.',
        examples: [
          PhonicsExample(en: 'preSENT', vi: '(v) trình bày, tặng'),
          PhonicsExample(en: 'reCORD', vi: '(v) ghi âm'),
        ],
      ),
      PhonicsItem(
        label: 'Đuôi -tion, -sion, -ic → trọng âm ngay trước đuôi',
        description: 'Quy tắc khá ổn định, áp dụng được cho rất nhiều từ.',
        examples: [
          PhonicsExample(en: 'inforMAtion', vi: 'thông tin'),
          PhonicsExample(en: 'ecoNOMic', vi: 'thuộc kinh tế'),
        ],
      ),
    ],
  ),
  PhonicsLesson(
    title: 'Trọng âm câu',
    titleEn: 'Sentence Stress',
    icon: Icons.short_text_rounded,
    color: AppColors.purple,
    intro:
        'Tiếng Anh là ngôn ngữ "stress-timed": trong 1 câu, chỉ những từ '
        'mang nghĩa chính mới được nhấn mạnh, các từ ngữ pháp đọc rất nhẹ '
        'và nhanh — khác hẳn tiếng Việt, nơi mọi âm tiết thường được đọc '
        'với độ dài gần bằng nhau.',
    items: [
      PhonicsItem(
        label: 'Content words — nhấn mạnh',
        description:
            'Danh từ, động từ chính, tính từ, trạng từ mang nghĩa '
            'chính của câu.',
        examples: [
          PhonicsExample(
            en: 'I WANT to BUY a NEW CAR.',
            vi: 'Các từ viết hoa được nhấn mạnh',
          ),
        ],
      ),
      PhonicsItem(
        label: 'Function words — đọc nhẹ, hay rút gọn',
        description:
            'Giới từ, mạo từ, đại từ, trợ động từ — gần như "lướt qua", '
            'nguyên âm thường biến thành /ə/ (schwa).',
        examples: [
          PhonicsExample(en: 'to', vi: 'thường đọc nhẹ thành /tə/'),
          PhonicsExample(en: 'a', vi: 'thường đọc nhẹ thành /ə/'),
        ],
      ),
    ],
  ),
  PhonicsLesson(
    title: 'Ngữ điệu',
    titleEn: 'Intonation',
    icon: Icons.trending_up_rounded,
    color: AppColors.blue,
    intro:
        'Ngữ điệu (lên/xuống giọng) truyền tải thông tin quan trọng như câu '
        'hỏi hay câu khẳng định, thậm chí cả thái độ của người nói.',
    items: [
      PhonicsItem(
        label: 'Câu hỏi Yes/No → lên giọng cuối câu',
        description: '',
        examples: [
          PhonicsExample(en: 'Are you coming? ↗', vi: 'Bạn có đến không?'),
        ],
      ),
      PhonicsItem(
        label: 'Câu hỏi Wh- → xuống giọng cuối câu',
        description: '',
        examples: [
          PhonicsExample(en: 'Where are you going? ↘', vi: 'Bạn đi đâu vậy?'),
        ],
      ),
      PhonicsItem(
        label: 'Liệt kê → lên giọng giữa danh sách, xuống ở mục cuối',
        description: '',
        examples: [
          PhonicsExample(
            en: 'I bought apples ↗, bananas ↗, and oranges ↘.',
            vi: 'Tôi đã mua táo, chuối và cam.',
          ),
        ],
      ),
    ],
  ),
  PhonicsLesson(
    title: 'Nối âm',
    titleEn: 'Connected Speech',
    icon: Icons.link_rounded,
    color: AppColors.teal,
    intro:
        'Khi nói tự nhiên, người bản ngữ không phát âm rời rạc từng từ mà '
        'nối/rút gọn/biến đổi âm giữa các từ liền nhau — đây là lý do người '
        'học nghe hiểu từng từ riêng lẻ được nhưng nghe hội thoại thật lại '
        'rất khó.',
    items: [
      PhonicsItem(
        label: 'Nối âm (liaison)',
        description:
            'Phụ âm cuối từ trước nối liền với nguyên âm đầu từ '
            'sau, nghe như 1 từ duy nhất.',
        examples: [PhonicsExample(en: 'an apple', vi: 'nghe như "a-napple"')],
      ),
      PhonicsItem(
        label: 'Rút gọn (elision)',
        description: 'Một số cụm từ quen thuộc bị rút ngắn khi nói nhanh.',
        examples: [
          PhonicsExample(en: 'want to → wanna', vi: 'muốn'),
          PhonicsExample(en: 'going to → gonna', vi: 'sắp, định'),
        ],
      ),
      PhonicsItem(
        label: 'Đồng hoá âm (assimilation)',
        description: 'Âm cuối biến đổi để dễ nối với âm đầu từ tiếp theo.',
        examples: [PhonicsExample(en: 'handbag', vi: 'nghe gần như "hambag"')],
      ),
    ],
  ),
  PhonicsLesson(
    title: 'Ôn tập qua bài hát',
    titleEn: 'Review Through Songs',
    icon: Icons.library_music_rounded,
    color: AppColors.pink,
    intro:
        'Bài học cuối không có âm mới — hãy quay lại màn Trang chủ, chọn 1 '
        'bài hát bất kỳ, vừa nghe vừa để ý các hiện tượng đã học ở 10 bài '
        'trước, sau đó dùng tính năng Luyện phát âm để tự thu âm và so '
        'sánh.',
    items: [
      PhonicsItem(
        label: 'Checklist khi nghe lại 1 bài hát',
        description:
            'Ca sĩ có giữ âm cuối không, hay lướt nhẹ đi? Từ nào được nhấn '
            'mạnh nhất trong câu? Có nghe thấy nối âm giữa 2 từ liền nhau '
            'không? Ngữ điệu lên/xuống ở đâu?',
      ),
      PhonicsItem(
        label: 'Luyện lại bằng chính giọng của bạn',
        description:
            'Mở 1 câu lyric trong Luyện phát âm, thu âm, nghe lại và so với '
            'bản gốc — chú ý đúng những điểm vừa để ý ở trên thay vì chỉ '
            'đọc đúng từng từ riêng lẻ.',
      ),
    ],
  ),
];

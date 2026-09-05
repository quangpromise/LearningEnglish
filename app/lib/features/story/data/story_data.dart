import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../vocabulary/data/vocabulary_data.dart';

/// Nhom chu de cho micro-story - phong theo cach cac trang luyen nghe pho
/// bien (vd dailydictation.com) chia muc, nhung TOAN BO NOI DUNG o day la
/// TU VIET MOI, khong sao chep transcript that cua bat ky nguon nao (tranh
/// van de ban quyen cua cac transcript phim/TED/tin tuc that).
enum StoryCategory {
  shortStories,
  conversations,
  kidsStories,
  toeic,
  ielts,
  randomVideos,
  news,
  ted,
  toefl,
  medical,
  ipa,
  numbers,
  spellingNames,
}

extension StoryCategoryLabel on StoryCategory {
  /// Key i18n tuong ung (xem app_strings.dart, tien to `story_category_`).
  String get labelKey => switch (this) {
    StoryCategory.shortStories => 'story_category_short_stories',
    StoryCategory.conversations => 'story_category_conversations',
    StoryCategory.kidsStories => 'story_category_kids_stories',
    StoryCategory.toeic => 'story_category_toeic',
    StoryCategory.ielts => 'story_category_ielts',
    StoryCategory.randomVideos => 'story_category_random_videos',
    StoryCategory.news => 'story_category_news',
    StoryCategory.ted => 'story_category_ted',
    StoryCategory.toefl => 'story_category_toefl',
    StoryCategory.medical => 'story_category_medical',
    StoryCategory.ipa => 'story_category_ipa',
    StoryCategory.numbers => 'story_category_numbers',
    StoryCategory.spellingNames => 'story_category_spelling_names',
  };
}

/// 1 đoạn trong micro-story - KHÔNG có mốc thời gian (khác `LyricLine` của
/// bài hát): narration đọc TUẦN TỰ bằng TTS (giống `ReadingScreen`, xem
/// `story_screen.dart`), không phải audio đã canh thời gian trước, nên
/// không có "giây bắt đầu" nào để lưu - đoạn đang đọc là đoạn đang có chỉ số
/// hiện tại, không phải đoạn có mốc thời gian gần nhất.
class StorySegment {
  const StorySegment({
    required this.id,
    required this.en,
    required this.vi,
    this.speaker,
  });

  /// Khoá ổn định cho 1 đoạn (dùng làm `ValueKey` khi cuộn tới) - KHÔNG phải
  /// thứ hiển thị.
  final String id;
  final String en;
  final String vi;

  /// Tên người nói - CHỈ dùng cho story dạng hội thoại nhiều người (vd
  /// Conversations, Medical), `null` cho narration 1 người kể (Short
  /// Stories, News...).
  final String? speaker;
}

/// 1 micro-story tự viết, chia theo [category] (xem `StoryCategory`) - xem
/// docs/architecture-multimedia-platform.md Phase 1/§E (MVP-1). Nội dung
/// GỐC, không trích từ nguồn nào nên không cần mục trong `ATTRIBUTION.md`
/// (khác 20 bài hát CC-BY, xem features/attribution/).
class Story {
  const Story({
    required this.id,
    required this.title,
    required this.category,
    required this.level,
    required this.color,
    required this.segments,
    required this.vocabulary,
  });

  /// Slug ổn định, dùng làm `lesson_id` khi ghi tiến độ
  /// (`user_lesson_progress`, migration 0026) - KHÔNG BAO GIỜ đổi sau khi
  /// phát hành, giống quy tắc `Song.audioUrl` không đổi.
  final String id;
  final String title;
  final StoryCategory category;

  /// Nhãn hiển thị (vd 'B1') - ánh xạ tạm theo §F.1 của tài liệu kiến trúc,
  /// KHÔNG phải enum CEFR đầy đủ (nằm ngoài phạm vi lát cắt này).
  final String level;
  final Color color;
  final List<StorySegment> segments;

  /// Tái dùng thẳng `VocabWord` (vocabulary_data.dart) - không cần model
  /// riêng, cùng 1 hình dạng (en/ipa/vi/câu ví dụ).
  final List<VocabWord> vocabulary;
}

const kStories = <Story>[
  // ============================= Short Stories =============================
  Story(
    id: 'a-rainy-morning',
    title: 'A Rainy Morning',
    category: StoryCategory.shortStories,
    level: 'B1',
    color: AppColors.teal,
    segments: [
      StorySegment(
        id: 'a-rainy-morning-01',
        en: 'It was a rainy morning in October.',
        vi: 'Đó là một buổi sáng mưa vào tháng Mười.',
      ),
      StorySegment(
        id: 'a-rainy-morning-02',
        en: 'Mai woke up late and had to hurry.',
        vi: 'Mai thức dậy muộn và phải vội vàng.',
      ),
      StorySegment(
        id: 'a-rainy-morning-03',
        en: 'She grabbed her bag and ran to the bus station.',
        vi: 'Cô ấy vớ lấy túi xách và chạy đến bến xe buýt.',
      ),
      StorySegment(
        id: 'a-rainy-morning-04',
        en: 'The rain was falling harder every minute.',
        vi: 'Mưa mỗi phút một nặng hạt hơn.',
      ),
      StorySegment(
        id: 'a-rainy-morning-05',
        en: 'When Mai arrived, the bus was already leaving.',
        vi: 'Khi Mai đến nơi, xe buýt đã bắt đầu rời bến.',
      ),
      StorySegment(
        id: 'a-rainy-morning-06',
        en: 'She stood there, cold and completely wet.',
        vi: 'Cô đứng đó, lạnh và ướt sũng.',
      ),
      StorySegment(
        id: 'a-rainy-morning-07',
        en: 'An old man nearby noticed her and smiled.',
        vi: 'Một ông cụ gần đó để ý thấy cô và mỉm cười.',
      ),
      StorySegment(
        id: 'a-rainy-morning-08',
        en: 'He offered to share his umbrella with her.',
        vi: 'Ông đề nghị cho cô đi chung ô với mình.',
      ),
      StorySegment(
        id: 'a-rainy-morning-09',
        en: 'Mai thanked him and they waited together.',
        vi: 'Mai cảm ơn ông và họ cùng nhau chờ đợi.',
      ),
      StorySegment(
        id: 'a-rainy-morning-10',
        en: 'They talked about the weather and their day.',
        vi: 'Họ nói chuyện về thời tiết và một ngày của mình.',
      ),
      StorySegment(
        id: 'a-rainy-morning-11',
        en:
            'The old man said his name was Mr. Long, and he used to be a '
            'teacher.',
        vi:
            'Ông cụ nói tên mình là ông Long, và trước đây từng là một '
            'giáo viên.',
      ),
      StorySegment(
        id: 'a-rainy-morning-12',
        en:
            'Mai told him about her new job and how nervous she felt on her '
            'first week.',
        vi:
            'Mai kể cho ông nghe về công việc mới của mình và cảm giác lo '
            'lắng trong tuần đầu tiên.',
      ),
      StorySegment(
        id: 'a-rainy-morning-13',
        en: 'Mr. Long laughed gently and said everyone feels that way at first.',
        vi:
            'Ông Long cười nhẹ và nói ai cũng cảm thấy như vậy lúc mới bắt '
            'đầu.',
      ),
      StorySegment(
        id: 'a-rainy-morning-14',
        en: 'The next bus finally arrived a few minutes later.',
        vi: 'Chuyến xe buýt tiếp theo cuối cùng cũng đến sau vài phút.',
      ),
      StorySegment(
        id: 'a-rainy-morning-15',
        en: 'Before stepping on, Mai turned and thanked him one more time.',
        vi: 'Trước khi bước lên xe, Mai quay lại và cảm ơn ông thêm lần nữa.',
      ),
      StorySegment(
        id: 'a-rainy-morning-16',
        en:
            'Mai smiled and realized kindness can turn a bad morning into a '
            'good one.',
        vi:
            'Mai mỉm cười và nhận ra rằng lòng tốt có thể biến một buổi sáng '
            'tồi tệ thành một buổi sáng tốt đẹp.',
      ),
    ],
    vocabulary: [
      VocabWord(
        en: 'rainy',
        ipa: '/ˈreɪni/',
        vi: 'có mưa',
        exampleEn: "It's rainy today, so bring an umbrella.",
        exampleVi: 'Hôm nay trời mưa, vậy hãy mang theo ô.',
      ),
      VocabWord(
        en: 'hurry',
        ipa: '/ˈhʌri/',
        vi: 'vội vàng',
        exampleEn: "Don't hurry, we have enough time.",
        exampleVi: 'Đừng vội, chúng ta có đủ thời gian.',
      ),
      VocabWord(
        en: 'station',
        ipa: '/ˈsteɪʃn/',
        vi: 'bến, ga',
        exampleEn: 'Meet me at the bus station.',
        exampleVi: 'Gặp tôi ở bến xe buýt nhé.',
      ),
      VocabWord(
        en: 'arrive',
        ipa: '/əˈraɪv/',
        vi: 'đến nơi',
        exampleEn: 'The train will arrive at six.',
        exampleVi: 'Tàu sẽ đến lúc sáu giờ.',
      ),
      VocabWord(
        en: 'wet',
        ipa: '/wet/',
        vi: 'ướt',
        exampleEn: 'My shoes are wet from the rain.',
        exampleVi: 'Giày của tôi bị ướt vì mưa.',
      ),
      VocabWord(
        en: 'notice',
        ipa: '/ˈnəʊtɪs/',
        vi: 'để ý, nhận ra',
        exampleEn: 'I noticed a new café on my street.',
        exampleVi: 'Tôi để ý thấy một quán cà phê mới trên phố mình.',
      ),
      VocabWord(
        en: 'offer',
        ipa: '/ˈɒfə(r)/',
        vi: 'đề nghị',
        exampleEn: 'He offered to help me carry the bags.',
        exampleVi: 'Anh ấy đề nghị giúp tôi xách túi.',
      ),
      VocabWord(
        en: 'share',
        ipa: '/ʃeə(r)/',
        vi: 'chia sẻ, dùng chung',
        exampleEn: 'Can we share this umbrella?',
        exampleVi: 'Chúng ta có thể dùng chung cái ô này không?',
      ),
      VocabWord(
        en: 'umbrella',
        ipa: '/ʌmˈbrelə/',
        vi: 'cái ô, cái dù',
        exampleEn: 'I forgot my umbrella at home.',
        exampleVi: 'Tôi quên cái ô ở nhà rồi.',
      ),
      VocabWord(
        en: 'nervous',
        ipa: '/ˈnɜːvəs/',
        vi: 'lo lắng, hồi hộp',
        exampleEn: 'She felt nervous before the interview.',
        exampleVi: 'Cô ấy cảm thấy lo lắng trước buổi phỏng vấn.',
      ),
      VocabWord(
        en: 'gently',
        ipa: '/ˈdʒentli/',
        vi: 'nhẹ nhàng',
        exampleEn: 'He closed the door gently.',
        exampleVi: 'Anh ấy đóng cửa một cách nhẹ nhàng.',
      ),
      VocabWord(
        en: 'kindness',
        ipa: '/ˈkaɪndnəs/',
        vi: 'lòng tốt',
        exampleEn: "A small act of kindness can make someone's day.",
        exampleVi: 'Một hành động tử tế nhỏ có thể làm ngày của ai đó tốt hơn.',
      ),
    ],
  ),
  Story(
    id: 'the-letter-from-grandma',
    title: 'The Letter from Grandma',
    category: StoryCategory.shortStories,
    level: 'B1',
    color: AppColors.amber,
    segments: [
      StorySegment(
        id: 'the-letter-from-grandma-01',
        en: 'Linh was cleaning her grandmother\'s old wooden desk.',
        vi: 'Linh đang dọn dẹp chiếc bàn gỗ cũ của bà mình.',
      ),
      StorySegment(
        id: 'the-letter-from-grandma-02',
        en: 'Inside one drawer, she found a yellow, folded letter.',
        vi: 'Bên trong một ngăn kéo, cô tìm thấy một lá thư đã ố vàng, gấp lại.',
      ),
      StorySegment(
        id: 'the-letter-from-grandma-03',
        en: 'The letter was written a very long time ago, before Linh was born.',
        vi: 'Lá thư được viết từ rất lâu rồi, trước khi Linh ra đời.',
      ),
      StorySegment(
        id: 'the-letter-from-grandma-04',
        en: 'It was from her grandmother to a friend who had moved far away.',
        vi: 'Đó là thư của bà gửi cho một người bạn đã chuyển đi rất xa.',
      ),
      StorySegment(
        id: 'the-letter-from-grandma-05',
        en:
            'In the letter, her grandmother described a small village by '
            'the river.',
        vi: 'Trong thư, bà kể về một ngôi làng nhỏ bên dòng sông.',
      ),
      StorySegment(
        id: 'the-letter-from-grandma-06',
        en: 'She wrote about the sound of boats and the smell of fresh rice.',
        vi: 'Bà viết về tiếng thuyền và mùi lúa mới thơm.',
      ),
      StorySegment(
        id: 'the-letter-from-grandma-07',
        en: 'Linh had never heard these stories before.',
        vi: 'Linh chưa từng nghe những câu chuyện này bao giờ.',
      ),
      StorySegment(
        id: 'the-letter-from-grandma-08',
        en: 'She realized her grandmother had lived a whole life before this one.',
        vi: 'Cô nhận ra bà mình đã từng có cả một cuộc đời khác trước đây.',
      ),
      StorySegment(
        id: 'the-letter-from-grandma-09',
        en:
            'That evening, Linh sat with her grandmother and asked about '
            'the letter.',
        vi: 'Tối hôm đó, Linh ngồi cùng bà và hỏi về lá thư.',
      ),
      StorySegment(
        id: 'the-letter-from-grandma-10',
        en: 'Her grandmother\'s eyes lit up as she remembered the old days.',
        vi: 'Mắt bà sáng lên khi nhớ lại những ngày xưa cũ.',
      ),
      StorySegment(
        id: 'the-letter-from-grandma-11',
        en: 'She told Linh stories for almost two hours without stopping.',
        vi: 'Bà kể chuyện cho Linh nghe suốt gần hai tiếng đồng hồ không ngừng.',
      ),
      StorySegment(
        id: 'the-letter-from-grandma-12',
        en:
            'Linh decided to write down every story so she would never '
            'forget them.',
        vi:
            'Linh quyết định ghi lại mọi câu chuyện để không bao giờ quên '
            'chúng.',
      ),
      StorySegment(
        id: 'the-letter-from-grandma-13',
        en: 'That old letter had opened a door to a part of her family\'s past.',
        vi: 'Lá thư cũ đó đã mở ra cánh cửa tới một phần quá khứ của gia đình cô.',
      ),
    ],
    vocabulary: [
      VocabWord(
        en: 'drawer',
        ipa: '/drɔː(r)/',
        vi: 'ngăn kéo',
        exampleEn: 'She kept old photos in the top drawer.',
        exampleVi: 'Cô ấy cất ảnh cũ trong ngăn kéo trên cùng.',
      ),
      VocabWord(
        en: 'fold',
        ipa: '/fəʊld/',
        vi: 'gấp lại',
        exampleEn: 'He folded the letter and put it in his pocket.',
        exampleVi: 'Anh ấy gấp lá thư lại và bỏ vào túi.',
      ),
      VocabWord(
        en: 'village',
        ipa: '/ˈvɪlɪdʒ/',
        vi: 'ngôi làng',
        exampleEn: 'They grew up in a small village.',
        exampleVi: 'Họ lớn lên ở một ngôi làng nhỏ.',
      ),
      VocabWord(
        en: 'describe',
        ipa: '/dɪˈskraɪb/',
        vi: 'mô tả',
        exampleEn: 'Can you describe what happened?',
        exampleVi: 'Bạn có thể mô tả chuyện gì đã xảy ra không?',
      ),
      VocabWord(
        en: 'remember',
        ipa: '/rɪˈmembə(r)/',
        vi: 'nhớ lại',
        exampleEn: 'She remembered her childhood home clearly.',
        exampleVi: 'Cô ấy nhớ rõ ngôi nhà thời thơ ấu của mình.',
      ),
      VocabWord(
        en: 'past',
        ipa: '/pɑːst/',
        vi: 'quá khứ',
        exampleEn: 'He rarely talks about the past.',
        exampleVi: 'Anh ấy hiếm khi nói về quá khứ.',
      ),
    ],
  ),

  // ============================= Conversations =============================
  Story(
    id: 'at-the-coffee-shop',
    title: 'At the Coffee Shop',
    category: StoryCategory.conversations,
    level: 'A2',
    color: AppColors.blue,
    segments: [
      StorySegment(
        id: 'at-the-coffee-shop-01',
        speaker: 'A',
        en: 'Good morning. What would you like to order?',
        vi: 'Chào buổi sáng. Bạn muốn gọi món gì?',
      ),
      StorySegment(
        id: 'at-the-coffee-shop-02',
        speaker: 'B',
        en: 'A warm cup of tea, please. Not too strong.',
        vi: 'Cho tôi một tách trà ấm, đừng đậm quá.',
      ),
      StorySegment(
        id: 'at-the-coffee-shop-03',
        speaker: 'A',
        en: 'Of course. Would you like some sugar with that?',
        vi: 'Được ạ. Bạn có muốn thêm đường không?',
      ),
      StorySegment(
        id: 'at-the-coffee-shop-04',
        speaker: 'B',
        en: 'Just a little, thank you. Also, is there a table by the window?',
        vi: 'Một chút thôi, cảm ơn. Ngoài ra, có bàn nào gần cửa sổ không?',
      ),
      StorySegment(
        id: 'at-the-coffee-shop-05',
        speaker: 'A',
        en: 'Yes, table number four is free right now.',
        vi: 'Có ạ, bàn số bốn đang trống đó.',
      ),
      StorySegment(
        id: 'at-the-coffee-shop-06',
        speaker: 'B',
        en: 'Perfect. And could I get the wifi password?',
        vi: 'Tuyệt. Và tôi có thể xin mật khẩu wifi không?',
      ),
      StorySegment(
        id: 'at-the-coffee-shop-07',
        speaker: 'A',
        en: "It's printed on the back of your receipt.",
        vi: 'Nó được in ở mặt sau hóa đơn của bạn đó.',
      ),
      StorySegment(
        id: 'at-the-coffee-shop-08',
        speaker: 'B',
        en: 'Great, thank you so much for your help.',
        vi: 'Tuyệt vời, cảm ơn bạn rất nhiều vì đã giúp đỡ.',
      ),
      StorySegment(
        id: 'at-the-coffee-shop-09',
        speaker: 'A',
        en: 'Here you are. Please take your time.',
        vi: 'Đây ạ. Mời bạn dùng từ từ.',
      ),
      StorySegment(
        id: 'at-the-coffee-shop-10',
        speaker: 'B',
        en: 'Thank you. This is exactly what I needed.',
        vi: 'Cảm ơn. Đây đúng là thứ tôi cần.',
      ),
    ],
    vocabulary: [
      VocabWord(
        en: 'order',
        ipa: '/ˈɔːdə(r)/',
        vi: 'gọi món, đặt hàng',
        exampleEn: 'Are you ready to order?',
        exampleVi: 'Bạn đã sẵn sàng gọi món chưa?',
      ),
      VocabWord(
        en: 'warm',
        ipa: '/wɔːm/',
        vi: 'ấm',
        exampleEn: 'I like my tea warm, not hot.',
        exampleVi: 'Tôi thích trà ấm, không phải nóng.',
      ),
      VocabWord(
        en: 'sugar',
        ipa: '/ˈʃʊɡə(r)/',
        vi: 'đường',
        exampleEn: 'No sugar for me, thanks.',
        exampleVi: 'Đừng cho đường vào của tôi nhé, cảm ơn.',
      ),
      VocabWord(
        en: 'receipt',
        ipa: '/rɪˈsiːt/',
        vi: 'hóa đơn',
        exampleEn: 'Can I have the receipt, please?',
        exampleVi: 'Cho tôi xin hóa đơn được không?',
      ),
      VocabWord(
        en: 'password',
        ipa: '/ˈpɑːswɜːd/',
        vi: 'mật khẩu',
        exampleEn: "What's the wifi password here?",
        exampleVi: 'Mật khẩu wifi ở đây là gì vậy?',
      ),
      VocabWord(
        en: 'take your time',
        ipa: '/teɪk jɔː(r) taɪm/',
        vi: 'cứ từ từ, không cần vội',
        exampleEn: "It's okay, take your time.",
        exampleVi: 'Không sao, cứ từ từ nhé.',
      ),
    ],
  ),
  Story(
    id: 'asking-for-directions',
    title: 'Asking for Directions',
    category: StoryCategory.conversations,
    level: 'A2',
    color: AppColors.teal,
    segments: [
      StorySegment(
        id: 'asking-for-directions-01',
        speaker: 'Tourist',
        en: 'Excuse me, could you help me? I think I\'m lost.',
        vi: 'Xin lỗi, bạn có thể giúp tôi không? Tôi nghĩ tôi bị lạc đường.',
      ),
      StorySegment(
        id: 'asking-for-directions-02',
        speaker: 'Local',
        en: 'Sure, where are you trying to go?',
        vi: 'Được thôi, bạn đang muốn đến đâu vậy?',
      ),
      StorySegment(
        id: 'asking-for-directions-03',
        speaker: 'Tourist',
        en: 'I\'m looking for the central market.',
        vi: 'Tôi đang tìm chợ trung tâm.',
      ),
      StorySegment(
        id: 'asking-for-directions-04',
        speaker: 'Local',
        en: 'Ah, it\'s not far. Go straight for two blocks.',
        vi: 'À, không xa đâu. Bạn đi thẳng qua hai dãy nhà.',
      ),
      StorySegment(
        id: 'asking-for-directions-05',
        speaker: 'Local',
        en: 'Then turn left at the traffic light.',
        vi: 'Sau đó rẽ trái ở đèn giao thông.',
      ),
      StorySegment(
        id: 'asking-for-directions-06',
        speaker: 'Tourist',
        en: 'Straight for two blocks, then turn left. Got it.',
        vi: 'Đi thẳng hai dãy nhà, rồi rẽ trái. Tôi hiểu rồi.',
      ),
      StorySegment(
        id: 'asking-for-directions-07',
        speaker: 'Local',
        en: 'The market will be right in front of you, next to a bank.',
        vi: 'Chợ sẽ nằm ngay trước mặt bạn, cạnh một ngân hàng.',
      ),
      StorySegment(
        id: 'asking-for-directions-08',
        speaker: 'Tourist',
        en: 'How long will it take to walk there?',
        vi: 'Đi bộ tới đó mất bao lâu vậy?',
      ),
      StorySegment(
        id: 'asking-for-directions-09',
        speaker: 'Local',
        en: 'About ten minutes, maybe less.',
        vi: 'Khoảng mười phút, có khi ít hơn.',
      ),
      StorySegment(
        id: 'asking-for-directions-10',
        speaker: 'Tourist',
        en: 'Thank you so much. You\'ve been very kind.',
        vi: 'Cảm ơn bạn rất nhiều. Bạn thật tốt bụng.',
      ),
      StorySegment(
        id: 'asking-for-directions-11',
        speaker: 'Local',
        en: 'No problem at all. Enjoy your visit!',
        vi: 'Không có gì cả. Chúc bạn có chuyến đi vui vẻ!',
      ),
    ],
    vocabulary: [
      VocabWord(
        en: 'lost',
        ipa: '/lɒst/',
        vi: 'bị lạc',
        exampleEn: 'We got lost on our way to the hotel.',
        exampleVi: 'Chúng tôi bị lạc đường trên đường đến khách sạn.',
      ),
      VocabWord(
        en: 'block',
        ipa: '/blɒk/',
        vi: 'dãy nhà, khu phố',
        exampleEn: 'The store is two blocks away.',
        exampleVi: 'Cửa hàng cách đây hai dãy nhà.',
      ),
      VocabWord(
        en: 'turn left',
        ipa: '/tɜːn left/',
        vi: 'rẽ trái',
        exampleEn: 'Turn left at the next corner.',
        exampleVi: 'Rẽ trái ở góc đường tiếp theo.',
      ),
      VocabWord(
        en: 'traffic light',
        ipa: '/ˈtræfɪk laɪt/',
        vi: 'đèn giao thông',
        exampleEn: 'Stop at the traffic light.',
        exampleVi: 'Dừng lại ở đèn giao thông.',
      ),
      VocabWord(
        en: 'in front of',
        ipa: '/ɪn frʌnt əv/',
        vi: 'ở phía trước',
        exampleEn: 'The bus stop is in front of the school.',
        exampleVi: 'Trạm xe buýt nằm ở phía trước trường học.',
      ),
      VocabWord(
        en: 'kind',
        ipa: '/kaɪnd/',
        vi: 'tốt bụng',
        exampleEn: 'It was very kind of you to help.',
        exampleVi: 'Bạn thật tốt bụng khi đã giúp đỡ.',
      ),
    ],
  ),

  // ============================= Stories for Kids =============================
  Story(
    id: 'the-little-cloud',
    title: 'The Little Cloud',
    category: StoryCategory.kidsStories,
    level: 'A2',
    color: AppColors.purple,
    segments: [
      StorySegment(
        id: 'the-little-cloud-01',
        en: 'Once, there was a little cloud who could not find her way home.',
        vi: 'Ngày xửa ngày xưa, có một đám mây nhỏ không tìm được đường về nhà.',
      ),
      StorySegment(
        id: 'the-little-cloud-02',
        en: 'She floated slowly over the mountains, feeling a little lost.',
        vi: 'Cô bay chầm chậm qua những ngọn núi, cảm thấy hơi lạc lối.',
      ),
      StorySegment(
        id: 'the-little-cloud-03',
        en: 'Below her, birds flew in the opposite direction, singing loudly.',
        vi: 'Bên dưới, những chú chim bay ngược hướng, hót thật to.',
      ),
      StorySegment(
        id: 'the-little-cloud-04',
        en: '"Excuse me," said the little cloud, "have you seen my family?"',
        vi: '"Xin lỗi," đám mây nhỏ hỏi, "các bạn có thấy gia đình tôi không?"',
      ),
      StorySegment(
        id: 'the-little-cloud-05',
        en: 'The birds shook their heads and flew on without stopping.',
        vi: 'Những chú chim lắc đầu và bay tiếp mà không dừng lại.',
      ),
      StorySegment(
        id: 'the-little-cloud-06',
        en: 'A gentle wind came and said, "Follow me, little cloud."',
        vi: 'Một cơn gió nhẹ đến và nói, "Hãy theo tôi, đám mây nhỏ ơi."',
      ),
      StorySegment(
        id: 'the-little-cloud-07',
        en: 'The little cloud felt a bit scared, but she trusted the wind.',
        vi: 'Đám mây nhỏ cảm thấy hơi sợ, nhưng cô tin tưởng cơn gió.',
      ),
      StorySegment(
        id: 'the-little-cloud-08',
        en:
            'Together, they floated across the sky until the stars '
            'appeared.',
        vi:
            'Cùng nhau, họ bay ngang bầu trời cho đến khi những vì sao '
            'xuất hiện.',
      ),
      StorySegment(
        id: 'the-little-cloud-09',
        en: 'Down below, she could see the twinkling lights of a sleepy town.',
        vi: 'Bên dưới, cô có thể thấy ánh đèn lấp lánh của một thị trấn buồn ngủ.',
      ),
      StorySegment(
        id: 'the-little-cloud-10',
        en:
            'At last, the little cloud found her family, resting above the '
            'quiet sea.',
        vi:
            'Cuối cùng, đám mây nhỏ tìm thấy gia đình mình, đang nghỉ ngơi '
            'trên mặt biển yên tĩnh.',
      ),
      StorySegment(
        id: 'the-little-cloud-11',
        en: 'She learned that even when we feel lost, help can appear when we need it.',
        vi:
            'Cô học được rằng dù có lúc cảm thấy lạc lối, sự giúp đỡ vẫn sẽ '
            'xuất hiện khi ta cần.',
      ),
    ],
    vocabulary: [
      VocabWord(
        en: 'cloud',
        ipa: '/klaʊd/',
        vi: 'đám mây',
        exampleEn: 'Look at that big white cloud.',
        exampleVi: 'Nhìn đám mây trắng to kia kìa.',
      ),
      VocabWord(
        en: 'float',
        ipa: '/fləʊt/',
        vi: 'trôi nổi, bay lơ lửng',
        exampleEn: 'The leaf floated down the river.',
        exampleVi: 'Chiếc lá trôi dọc theo dòng sông.',
      ),
      VocabWord(
        en: 'gentle',
        ipa: '/ˈdʒentl/',
        vi: 'nhẹ nhàng',
        exampleEn: 'She has a gentle voice.',
        exampleVi: 'Cô ấy có giọng nói nhẹ nhàng.',
      ),
      VocabWord(
        en: 'trust',
        ipa: '/trʌst/',
        vi: 'tin tưởng',
        exampleEn: 'You can trust him completely.',
        exampleVi: 'Bạn có thể hoàn toàn tin tưởng anh ấy.',
      ),
      VocabWord(
        en: 'twinkle',
        ipa: '/ˈtwɪŋkl/',
        vi: 'lấp lánh',
        exampleEn: 'The stars twinkled in the dark sky.',
        exampleVi: 'Những vì sao lấp lánh trên bầu trời tối.',
      ),
      VocabWord(
        en: 'appear',
        ipa: '/əˈpɪə(r)/',
        vi: 'xuất hiện',
        exampleEn: 'The moon appeared behind the clouds.',
        exampleVi: 'Mặt trăng xuất hiện sau những đám mây.',
      ),
    ],
  ),
  Story(
    id: 'the-brave-little-turtle',
    title: 'The Brave Little Turtle',
    category: StoryCategory.kidsStories,
    level: 'A2',
    color: AppColors.blue,
    segments: [
      StorySegment(
        id: 'the-brave-little-turtle-01',
        en: 'Tim the turtle lived at the edge of a big, blue pond.',
        vi: 'Rùa Tim sống ở ven một cái ao lớn màu xanh.',
      ),
      StorySegment(
        id: 'the-brave-little-turtle-02',
        en: 'Every day, he watched the other animals swim and play.',
        vi: 'Mỗi ngày, cậu nhìn các con vật khác bơi lội và chơi đùa.',
      ),
      StorySegment(
        id: 'the-brave-little-turtle-03',
        en: 'But Tim was afraid of the deep water in the middle of the pond.',
        vi: 'Nhưng Tim sợ vùng nước sâu ở giữa ao.',
      ),
      StorySegment(
        id: 'the-brave-little-turtle-04',
        en: 'One day, his little sister swam too far and could not get back.',
        vi: 'Một ngày nọ, em gái nhỏ của cậu bơi quá xa và không thể quay lại.',
      ),
      StorySegment(
        id: 'the-brave-little-turtle-05',
        en: '"Help! Help!" she called, and Tim\'s heart began to race.',
        vi: '"Cứu với! Cứu với!" em kêu lên, và tim Tim đập nhanh hơn.',
      ),
      StorySegment(
        id: 'the-brave-little-turtle-06',
        en: 'Tim took a deep breath and jumped into the deep water.',
        vi: 'Tim hít một hơi thật sâu và nhảy xuống vùng nước sâu.',
      ),
      StorySegment(
        id: 'the-brave-little-turtle-07',
        en: 'He swam as fast as his little legs could go.',
        vi: 'Cậu bơi nhanh hết mức đôi chân nhỏ của mình có thể.',
      ),
      StorySegment(
        id: 'the-brave-little-turtle-08',
        en: 'He reached his sister and helped her float back to safety.',
        vi: 'Cậu đến chỗ em gái và giúp em bơi trở lại nơi an toàn.',
      ),
      StorySegment(
        id: 'the-brave-little-turtle-09',
        en: 'All the other animals cheered for brave little Tim.',
        vi: 'Tất cả các con vật khác đều reo hò cổ vũ chú Tim dũng cảm.',
      ),
      StorySegment(
        id: 'the-brave-little-turtle-10',
        en: 'From that day, Tim was never afraid of the deep water again.',
        vi: 'Từ ngày đó, Tim không bao giờ còn sợ vùng nước sâu nữa.',
      ),
    ],
    vocabulary: [
      VocabWord(
        en: 'pond',
        ipa: '/pɒnd/',
        vi: 'cái ao',
        exampleEn: 'Ducks were swimming in the pond.',
        exampleVi: 'Những chú vịt đang bơi trong ao.',
      ),
      VocabWord(
        en: 'afraid',
        ipa: '/əˈfreɪd/',
        vi: 'sợ hãi',
        exampleEn: 'Don\'t be afraid, I\'m here with you.',
        exampleVi: 'Đừng sợ, tôi ở đây với bạn.',
      ),
      VocabWord(
        en: 'deep',
        ipa: '/diːp/',
        vi: 'sâu',
        exampleEn: 'The lake is very deep here.',
        exampleVi: 'Hồ ở đây rất sâu.',
      ),
      VocabWord(
        en: 'brave',
        ipa: '/breɪv/',
        vi: 'dũng cảm',
        exampleEn: 'It was brave of you to speak up.',
        exampleVi: 'Bạn thật dũng cảm khi dám lên tiếng.',
      ),
      VocabWord(
        en: 'safety',
        ipa: '/ˈseɪfti/',
        vi: 'sự an toàn',
        exampleEn: 'The children reached safety quickly.',
        exampleVi: 'Bọn trẻ đã đến nơi an toàn nhanh chóng.',
      ),
      VocabWord(
        en: 'cheer',
        ipa: '/tʃɪə(r)/',
        vi: 'reo hò, cổ vũ',
        exampleEn: 'The crowd cheered for the team.',
        exampleVi: 'Đám đông reo hò cổ vũ cho đội bóng.',
      ),
    ],
  ),

  // ============================= TOEIC Listening =============================
  Story(
    id: 'office-meeting-notice',
    title: 'Office Meeting Notice',
    category: StoryCategory.toeic,
    level: 'B1',
    color: AppColors.amber,
    segments: [
      StorySegment(
        id: 'office-meeting-notice-01',
        en: 'Attention, all staff.',
        vi: 'Xin lưu ý toàn thể nhân viên.',
      ),
      StorySegment(
        id: 'office-meeting-notice-02',
        en:
            'The meeting room on the third floor will be closed for '
            'cleaning this afternoon.',
        vi: 'Phòng họp tầng ba sẽ đóng cửa để dọn dẹp vào chiều nay.',
      ),
      StorySegment(
        id: 'office-meeting-notice-03',
        en: 'Please use the room on the second floor instead.',
        vi: 'Vui lòng sử dụng phòng ở tầng hai thay thế.',
      ),
      StorySegment(
        id: 'office-meeting-notice-04',
        en: 'The two o\'clock meeting will move there as well.',
        vi: 'Buổi họp lúc hai giờ cũng sẽ chuyển đến đó.',
      ),
      StorySegment(
        id: 'office-meeting-notice-05',
        en: 'The parking garage will also be limited to visitors only today.',
        vi: 'Bãi đỗ xe hôm nay cũng sẽ chỉ dành riêng cho khách.',
      ),
      StorySegment(
        id: 'office-meeting-notice-06',
        en: 'Staff members are asked to park on the street instead.',
        vi: 'Nhân viên được yêu cầu đỗ xe ngoài đường thay vào đó.',
      ),
      StorySegment(
        id: 'office-meeting-notice-07',
        en: 'The IT department will also update all computers this evening.',
        vi: 'Phòng IT cũng sẽ cập nhật toàn bộ máy tính vào tối nay.',
      ),
      StorySegment(
        id: 'office-meeting-notice-08',
        en: 'Please save your work and log off before you leave the office.',
        vi: 'Vui lòng lưu công việc và đăng xuất trước khi rời văn phòng.',
      ),
      StorySegment(
        id: 'office-meeting-notice-09',
        en: 'We apologize for any inconvenience this may cause.',
        vi: 'Chúng tôi xin lỗi vì bất kỳ sự bất tiện nào gây ra.',
      ),
      StorySegment(
        id: 'office-meeting-notice-10',
        en: 'Thank you for your understanding and cooperation.',
        vi: 'Cảm ơn sự thông cảm và hợp tác của mọi người.',
      ),
    ],
    vocabulary: [
      VocabWord(
        en: 'attention',
        ipa: '/əˈtenʃn/',
        vi: 'sự chú ý',
        exampleEn: 'May I have your attention, please?',
        exampleVi: 'Xin mọi người chú ý một chút được không?',
      ),
      VocabWord(
        en: 'staff',
        ipa: '/stɑːf/',
        vi: 'nhân viên (nói chung)',
        exampleEn: 'All staff must wear an ID card.',
        exampleVi: 'Toàn thể nhân viên phải đeo thẻ ID.',
      ),
      VocabWord(
        en: 'instead',
        ipa: '/ɪnˈsted/',
        vi: 'thay vào đó',
        exampleEn: 'The shop was closed, so we went home instead.',
        exampleVi: 'Cửa hàng đóng cửa, nên chúng tôi về nhà thay vào đó.',
      ),
      VocabWord(
        en: 'log off',
        ipa: '/lɒɡ ɒf/',
        vi: 'đăng xuất',
        exampleEn: 'Remember to log off before you leave.',
        exampleVi: 'Nhớ đăng xuất trước khi bạn rời đi.',
      ),
      VocabWord(
        en: 'apologize',
        ipa: '/əˈpɒlədʒaɪz/',
        vi: 'xin lỗi',
        exampleEn: 'We apologize for the delay.',
        exampleVi: 'Chúng tôi xin lỗi vì sự chậm trễ.',
      ),
      VocabWord(
        en: 'cooperation',
        ipa: '/kəʊˌɒpəˈreɪʃn/',
        vi: 'sự hợp tác',
        exampleEn: 'Thank you for your cooperation.',
        exampleVi: 'Cảm ơn sự hợp tác của bạn.',
      ),
    ],
  ),
  Story(
    id: 'package-delivery-update',
    title: 'Package Delivery Update',
    category: StoryCategory.toeic,
    level: 'B1',
    color: AppColors.pink,
    segments: [
      StorySegment(
        id: 'package-delivery-update-01',
        en: 'Good afternoon, this is a message about your recent order.',
        vi: 'Chào buổi chiều, đây là tin nhắn về đơn hàng gần đây của bạn.',
      ),
      StorySegment(
        id: 'package-delivery-update-02',
        en: 'Your package has left our warehouse and is on its way.',
        vi: 'Gói hàng của bạn đã rời kho và đang trên đường vận chuyển.',
      ),
      StorySegment(
        id: 'package-delivery-update-03',
        en: 'The expected delivery date is this Friday afternoon.',
        vi: 'Ngày giao hàng dự kiến là chiều thứ Sáu này.',
      ),
      StorySegment(
        id: 'package-delivery-update-04',
        en: 'If no one is home, the driver will leave a notice at the door.',
        vi: 'Nếu không có ai ở nhà, tài xế sẽ để lại thông báo tại cửa.',
      ),
      StorySegment(
        id: 'package-delivery-update-05',
        en: 'You can also choose to pick up the package at our local office.',
        vi: 'Bạn cũng có thể chọn nhận gói hàng tại văn phòng địa phương.',
      ),
      StorySegment(
        id: 'package-delivery-update-06',
        en: 'To change your delivery address, please contact us today.',
        vi: 'Để thay đổi địa chỉ giao hàng, vui lòng liên hệ chúng tôi hôm nay.',
      ),
      StorySegment(
        id: 'package-delivery-update-07',
        en: 'You can track your package anytime using the order number.',
        vi: 'Bạn có thể theo dõi gói hàng bất cứ lúc nào bằng mã đơn hàng.',
      ),
      StorySegment(
        id: 'package-delivery-update-08',
        en: 'Thank you for shopping with us, and have a wonderful day.',
        vi: 'Cảm ơn bạn đã mua sắm cùng chúng tôi, chúc bạn một ngày tuyệt vời.',
      ),
    ],
    vocabulary: [
      VocabWord(
        en: 'warehouse',
        ipa: '/ˈweəhaʊs/',
        vi: 'nhà kho',
        exampleEn: 'The goods are stored in a large warehouse.',
        exampleVi: 'Hàng hóa được lưu trữ trong một nhà kho lớn.',
      ),
      VocabWord(
        en: 'delivery',
        ipa: '/dɪˈlɪvəri/',
        vi: 'sự giao hàng',
        exampleEn: 'Delivery usually takes three days.',
        exampleVi: 'Giao hàng thường mất ba ngày.',
      ),
      VocabWord(
        en: 'pick up',
        ipa: '/pɪk ʌp/',
        vi: 'lấy, nhận (hàng)',
        exampleEn: "I'll pick up the package tomorrow.",
        exampleVi: 'Tôi sẽ đến lấy gói hàng vào ngày mai.',
      ),
      VocabWord(
        en: 'contact',
        ipa: '/ˈkɒntækt/',
        vi: 'liên hệ',
        exampleEn: 'Please contact us if you have questions.',
        exampleVi: 'Vui lòng liên hệ chúng tôi nếu bạn có câu hỏi.',
      ),
      VocabWord(
        en: 'track',
        ipa: '/træk/',
        vi: 'theo dõi (đơn hàng)',
        exampleEn: 'You can track your order online.',
        exampleVi: 'Bạn có thể theo dõi đơn hàng của mình trực tuyến.',
      ),
    ],
  ),

  // ============================= IELTS Listening =============================
  Story(
    id: 'university-library-tour',
    title: 'University Library Tour',
    category: StoryCategory.ielts,
    level: 'B1',
    color: AppColors.pink,
    segments: [
      StorySegment(
        id: 'university-library-tour-01',
        en: 'Welcome to the university library.',
        vi: 'Chào mừng đến thư viện trường.',
      ),
      StorySegment(
        id: 'university-library-tour-02',
        en: 'This building has four floors.',
        vi: 'Tòa nhà này có bốn tầng.',
      ),
      StorySegment(
        id: 'university-library-tour-03',
        en:
            'The ground floor is for quiet study, and the top floor has '
            'group discussion rooms.',
        vi:
            'Tầng trệt dành cho học yên tĩnh, và tầng trên cùng có phòng '
            'thảo luận nhóm.',
      ),
      StorySegment(
        id: 'university-library-tour-04',
        en: 'The second floor holds our science and technology collection.',
        vi: 'Tầng hai chứa bộ sưu tập sách về khoa học và công nghệ.',
      ),
      StorySegment(
        id: 'university-library-tour-05',
        en: 'The third floor is dedicated to literature and history books.',
        vi: 'Tầng ba dành riêng cho sách văn học và lịch sử.',
      ),
      StorySegment(
        id: 'university-library-tour-06',
        en: 'The library opens at eight and closes at nine in the evening.',
        vi: 'Thư viện mở cửa lúc tám giờ và đóng cửa lúc chín giờ tối.',
      ),
      StorySegment(
        id: 'university-library-tour-07',
        en: 'During exam weeks, it stays open until midnight.',
        vi: 'Trong tuần thi, thư viện mở cửa đến tận nửa đêm.',
      ),
      StorySegment(
        id: 'university-library-tour-08',
        en: 'Students may borrow up to five books at one time.',
        vi: 'Sinh viên được mượn tối đa năm cuốn sách cùng một lúc.',
      ),
      StorySegment(
        id: 'university-library-tour-09',
        en: 'Please remember to bring your student card every time you visit.',
        vi: 'Xin nhớ mang theo thẻ sinh viên mỗi khi đến đây.',
      ),
      StorySegment(
        id: 'university-library-tour-10',
        en: 'If you have any questions, the front desk staff are happy to help.',
        vi: 'Nếu có bất kỳ câu hỏi nào, nhân viên bàn lễ tân luôn sẵn lòng giúp đỡ.',
      ),
    ],
    vocabulary: [
      VocabWord(
        en: 'welcome',
        ipa: '/ˈwelkəm/',
        vi: 'chào mừng',
        exampleEn: 'Welcome to our school.',
        exampleVi: 'Chào mừng bạn đến trường của chúng tôi.',
      ),
      VocabWord(
        en: 'floor',
        ipa: '/flɔː(r)/',
        vi: 'tầng (nhà)',
        exampleEn: 'My office is on the fifth floor.',
        exampleVi: 'Văn phòng của tôi ở tầng năm.',
      ),
      VocabWord(
        en: 'collection',
        ipa: '/kəˈlekʃn/',
        vi: 'bộ sưu tập',
        exampleEn: 'The museum has a large art collection.',
        exampleVi: 'Bảo tàng có một bộ sưu tập nghệ thuật lớn.',
      ),
      VocabWord(
        en: 'borrow',
        ipa: '/ˈbɒrəʊ/',
        vi: 'mượn',
        exampleEn: 'Can I borrow your pen?',
        exampleVi: 'Tôi có thể mượn bút của bạn không?',
      ),
      VocabWord(
        en: 'discussion',
        ipa: '/dɪˈskʌʃn/',
        vi: 'sự thảo luận',
        exampleEn: 'We had a good discussion about the project.',
        exampleVi: 'Chúng tôi đã có một buổi thảo luận tốt về dự án.',
      ),
      VocabWord(
        en: 'remember',
        ipa: '/rɪˈmembə(r)/',
        vi: 'nhớ',
        exampleEn: 'Remember to bring your card.',
        exampleVi: 'Nhớ mang theo thẻ của bạn.',
      ),
    ],
  ),
  Story(
    id: 'airport-announcement',
    title: 'Airport Announcement',
    category: StoryCategory.ielts,
    level: 'B1',
    color: AppColors.blue,
    segments: [
      StorySegment(
        id: 'airport-announcement-01',
        en: 'Good morning, passengers, welcome to the international terminal.',
        vi: 'Chào buổi sáng, quý khách, chào mừng đến ga quốc tế.',
      ),
      StorySegment(
        id: 'airport-announcement-02',
        en: 'Please have your boarding pass and passport ready for inspection.',
        vi: 'Vui lòng chuẩn bị sẵn thẻ lên máy bay và hộ chiếu để kiểm tra.',
      ),
      StorySegment(
        id: 'airport-announcement-03',
        en: 'Flight 204 to Tokyo is now boarding at gate twelve.',
        vi: 'Chuyến bay 204 đi Tokyo hiện đang mời hành khách lên máy bay tại cổng số mười hai.',
      ),
      StorySegment(
        id: 'airport-announcement-04',
        en: 'Passengers with young children may board first.',
        vi: 'Hành khách có trẻ nhỏ có thể lên máy bay trước.',
      ),
      StorySegment(
        id: 'airport-announcement-05',
        en: 'Please make sure all carry-on bags fit under your seat.',
        vi: 'Vui lòng đảm bảo mọi hành lý xách tay vừa dưới ghế ngồi của bạn.',
      ),
      StorySegment(
        id: 'airport-announcement-06',
        en: 'The flight will depart in approximately thirty minutes.',
        vi: 'Chuyến bay sẽ khởi hành trong khoảng ba mươi phút nữa.',
      ),
      StorySegment(
        id: 'airport-announcement-07',
        en: 'If you need any assistance, please speak to our staff at the gate.',
        vi: 'Nếu cần hỗ trợ, vui lòng nói chuyện với nhân viên tại cổng.',
      ),
      StorySegment(
        id: 'airport-announcement-08',
        en: 'We wish you a pleasant and comfortable flight today.',
        vi: 'Chúng tôi chúc quý khách một chuyến bay dễ chịu và thoải mái hôm nay.',
      ),
    ],
    vocabulary: [
      VocabWord(
        en: 'passenger',
        ipa: '/ˈpæsɪndʒə(r)/',
        vi: 'hành khách',
        exampleEn: 'All passengers must show their tickets.',
        exampleVi: 'Tất cả hành khách phải xuất trình vé.',
      ),
      VocabWord(
        en: 'boarding pass',
        ipa: '/ˈbɔːdɪŋ pɑːs/',
        vi: 'thẻ lên máy bay',
        exampleEn: 'Don\'t forget your boarding pass.',
        exampleVi: 'Đừng quên thẻ lên máy bay của bạn.',
      ),
      VocabWord(
        en: 'gate',
        ipa: '/ɡeɪt/',
        vi: 'cổng (ra máy bay)',
        exampleEn: 'Our flight leaves from gate nine.',
        exampleVi: 'Chuyến bay của chúng tôi khởi hành từ cổng số chín.',
      ),
      VocabWord(
        en: 'carry-on',
        ipa: '/ˈkæri ɒn/',
        vi: 'hành lý xách tay',
        exampleEn: 'This bag is small enough for carry-on.',
        exampleVi: 'Túi này đủ nhỏ để làm hành lý xách tay.',
      ),
      VocabWord(
        en: 'depart',
        ipa: '/dɪˈpɑːt/',
        vi: 'khởi hành',
        exampleEn: 'The train will depart shortly.',
        exampleVi: 'Tàu sẽ khởi hành ngay sau đây.',
      ),
      VocabWord(
        en: 'assistance',
        ipa: '/əˈsɪstəns/',
        vi: 'sự hỗ trợ, giúp đỡ',
        exampleEn: 'Please ask if you need assistance.',
        exampleVi: 'Vui lòng hỏi nếu bạn cần hỗ trợ.',
      ),
    ],
  ),

  // ============================= Random Videos =============================
  Story(
    id: 'evening-walk-vlog',
    title: 'Evening Walk Vlog',
    category: StoryCategory.randomVideos,
    level: 'B1',
    color: AppColors.blue,
    segments: [
      StorySegment(
        id: 'evening-walk-vlog-01',
        en: 'Hey everyone, welcome back to my channel.',
        vi: 'Chào mọi người, chào mừng quay lại kênh của mình.',
      ),
      StorySegment(
        id: 'evening-walk-vlog-02',
        en: 'Today, I just want to share a quiet moment from my evening walk.',
        vi:
            'Hôm nay, mình chỉ muốn chia sẻ một khoảnh khắc yên bình từ '
            'buổi đi bộ tối nay.',
      ),
      StorySegment(
        id: 'evening-walk-vlog-03',
        en: 'The air was cool, and the streets were almost empty.',
        vi: 'Không khí mát mẻ, và đường phố gần như vắng người.',
      ),
      StorySegment(
        id: 'evening-walk-vlog-04',
        en: 'I passed a small bakery that was just closing for the night.',
        vi: 'Mình đi ngang qua một tiệm bánh nhỏ vừa đóng cửa cho buổi tối.',
      ),
      StorySegment(
        id: 'evening-walk-vlog-05',
        en: 'The smell of fresh bread followed me for almost a block.',
        vi: 'Mùi bánh mì mới ra lò theo mình suốt gần một dãy phố.',
      ),
      StorySegment(
        id: 'evening-walk-vlog-06',
        en: 'A few people were sitting outside, talking quietly over coffee.',
        vi: 'Vài người ngồi bên ngoài, trò chuyện khẽ khàng bên tách cà phê.',
      ),
      StorySegment(
        id: 'evening-walk-vlog-07',
        en: 'It was the perfect time to slow down and just breathe.',
        vi: 'Đó là thời điểm hoàn hảo để chậm lại và chỉ hít thở thôi.',
      ),
      StorySegment(
        id: 'evening-walk-vlog-08',
        en: 'Sometimes the simplest moments make the best memories.',
        vi: 'Đôi khi những khoảnh khắc đơn giản nhất lại tạo nên kỷ niệm đẹp nhất.',
      ),
      StorySegment(
        id: 'evening-walk-vlog-09',
        en: "That's it for today's video. Thanks so much for watching.",
        vi: 'Video hôm nay đến đây thôi. Cảm ơn mọi người rất nhiều vì đã xem.',
      ),
    ],
    vocabulary: [
      VocabWord(
        en: 'channel',
        ipa: '/ˈtʃænl/',
        vi: 'kênh (video)',
        exampleEn: 'Please subscribe to my channel.',
        exampleVi: 'Hãy đăng ký kênh của mình nhé.',
      ),
      VocabWord(
        en: 'bakery',
        ipa: '/ˈbeɪkəri/',
        vi: 'tiệm bánh',
        exampleEn: 'This bakery makes the best bread in town.',
        exampleVi: 'Tiệm bánh này làm bánh mì ngon nhất thị trấn.',
      ),
      VocabWord(
        en: 'empty',
        ipa: '/ˈempti/',
        vi: 'trống, vắng',
        exampleEn: 'The street was empty at midnight.',
        exampleVi: 'Con phố vắng vẻ lúc nửa đêm.',
      ),
      VocabWord(
        en: 'slow down',
        ipa: '/sləʊ daʊn/',
        vi: 'chậm lại',
        exampleEn: "Let's slow down and enjoy the view.",
        exampleVi: 'Hãy chậm lại và tận hưởng khung cảnh.',
      ),
      VocabWord(
        en: 'memory',
        ipa: '/ˈmeməri/',
        vi: 'kỷ niệm',
        exampleEn: 'This trip will be a great memory.',
        exampleVi: 'Chuyến đi này sẽ là một kỷ niệm tuyệt vời.',
      ),
      VocabWord(
        en: 'breathe',
        ipa: '/briːð/',
        vi: 'hít thở',
        exampleEn: 'Take a moment to breathe.',
        exampleVi: 'Hãy dành một chút để hít thở.',
      ),
    ],
  ),
  Story(
    id: 'weekend-cooking-vlog',
    title: 'Weekend Cooking Vlog',
    category: StoryCategory.randomVideos,
    level: 'B1',
    color: AppColors.amber,
    segments: [
      StorySegment(
        id: 'weekend-cooking-vlog-01',
        en: "What's up, everyone? Today we're cooking something simple.",
        vi: 'Chào mọi người? Hôm nay chúng ta sẽ nấu một món đơn giản.',
      ),
      StorySegment(
        id: 'weekend-cooking-vlog-02',
        en: "First, let's gather all the ingredients we need.",
        vi: 'Đầu tiên, hãy chuẩn bị tất cả nguyên liệu chúng ta cần.',
      ),
      StorySegment(
        id: 'weekend-cooking-vlog-03',
        en: 'We need some vegetables, garlic, and a little olive oil.',
        vi: 'Chúng ta cần một ít rau củ, tỏi, và một chút dầu ô liu.',
      ),
      StorySegment(
        id: 'weekend-cooking-vlog-04',
        en: 'Start by chopping the vegetables into small pieces.',
        vi: 'Bắt đầu bằng cách cắt rau củ thành những miếng nhỏ.',
      ),
      StorySegment(
        id: 'weekend-cooking-vlog-05',
        en: 'Heat the oil in the pan over medium heat.',
        vi: 'Đun nóng dầu trong chảo với lửa vừa.',
      ),
      StorySegment(
        id: 'weekend-cooking-vlog-06',
        en: 'Add the garlic first, then the vegetables a minute later.',
        vi: 'Cho tỏi vào trước, rồi cho rau củ vào sau một phút.',
      ),
      StorySegment(
        id: 'weekend-cooking-vlog-07',
        en: 'Stir everything together for about five minutes.',
        vi: 'Đảo đều mọi thứ trong khoảng năm phút.',
      ),
      StorySegment(
        id: 'weekend-cooking-vlog-08',
        en: "And that's it! A quick, healthy meal in under fifteen minutes.",
        vi: 'Và xong rồi! Một bữa ăn nhanh và lành mạnh trong vòng chưa đầy mười lăm phút.',
      ),
      StorySegment(
        id: 'weekend-cooking-vlog-09',
        en: 'Let me know in the comments what you\'d like to see next.',
        vi: 'Hãy cho mình biết trong phần bình luận bạn muốn xem gì tiếp theo nhé.',
      ),
    ],
    vocabulary: [
      VocabWord(
        en: 'ingredient',
        ipa: '/ɪnˈɡriːdiənt/',
        vi: 'nguyên liệu',
        exampleEn: 'Sugar is the main ingredient in this cake.',
        exampleVi: 'Đường là nguyên liệu chính trong chiếc bánh này.',
      ),
      VocabWord(
        en: 'chop',
        ipa: '/tʃɒp/',
        vi: 'cắt, thái',
        exampleEn: 'Chop the onions finely.',
        exampleVi: 'Thái hành thật nhỏ.',
      ),
      VocabWord(
        en: 'pan',
        ipa: '/pæn/',
        vi: 'cái chảo',
        exampleEn: 'Put the pan on the stove.',
        exampleVi: 'Đặt cái chảo lên bếp.',
      ),
      VocabWord(
        en: 'stir',
        ipa: '/stɜː(r)/',
        vi: 'khuấy, đảo',
        exampleEn: 'Stir the soup slowly.',
        exampleVi: 'Khuấy súp thật chậm.',
      ),
      VocabWord(
        en: 'healthy',
        ipa: '/ˈhelθi/',
        vi: 'lành mạnh, tốt cho sức khỏe',
        exampleEn: 'Try to eat healthy food every day.',
        exampleVi: 'Cố gắng ăn thực phẩm lành mạnh mỗi ngày.',
      ),
      VocabWord(
        en: 'comment',
        ipa: '/ˈkɒment/',
        vi: 'bình luận',
        exampleEn: 'Leave a comment below.',
        exampleVi: 'Để lại bình luận bên dưới.',
      ),
    ],
  ),

  // ============================= News =============================
  Story(
    id: 'park-reopens',
    title: 'Community Park Reopens',
    category: StoryCategory.news,
    level: 'B1',
    color: AppColors.teal,
    segments: [
      StorySegment(
        id: 'park-reopens-01',
        en: 'This is a practice news report. The story is not real.',
        vi: 'Đây là bài luyện nghe kiểu tin tức. Nội dung không phải sự thật.',
      ),
      StorySegment(
        id: 'park-reopens-02',
        en:
            'A small community park reopened this week after several '
            'months of renovation.',
        vi:
            'Một công viên cộng đồng nhỏ đã mở cửa trở lại tuần này sau '
            'nhiều tháng cải tạo.',
      ),
      StorySegment(
        id: 'park-reopens-03',
        en:
            'Local residents say they are happy to have a quiet green '
            'space again.',
        vi:
            'Người dân địa phương cho biết họ vui vì lại có một không gian '
            'xanh yên tĩnh.',
      ),
      StorySegment(
        id: 'park-reopens-04',
        en: 'One resident said the new walking path is smoother and safer.',
        vi: 'Một cư dân cho biết lối đi bộ mới bằng phẳng và an toàn hơn.',
      ),
      StorySegment(
        id: 'park-reopens-05',
        en: 'The park also added new benches and better lighting at night.',
        vi: 'Công viên cũng lắp thêm ghế ngồi mới và ánh sáng tốt hơn vào ban đêm.',
      ),
      StorySegment(
        id: 'park-reopens-06',
        en: 'Officials say the project cost less than originally planned.',
        vi: 'Các quan chức cho biết dự án tốn ít chi phí hơn dự kiến ban đầu.',
      ),
      StorySegment(
        id: 'park-reopens-07',
        en: 'The park will now stay open every evening until nine o\'clock.',
        vi: 'Công viên hiện sẽ mở cửa mỗi tối đến chín giờ.',
      ),
      StorySegment(
        id: 'park-reopens-08',
        en: 'A small opening celebration is planned for this weekend.',
        vi: 'Một buổi lễ khai trương nhỏ được lên kế hoạch vào cuối tuần này.',
      ),
    ],
    vocabulary: [
      VocabWord(
        en: 'community',
        ipa: '/kəˈmjuːnəti/',
        vi: 'cộng đồng',
        exampleEn: 'This is a small, friendly community.',
        exampleVi: 'Đây là một cộng đồng nhỏ, thân thiện.',
      ),
      VocabWord(
        en: 'renovation',
        ipa: '/ˌrenəˈveɪʃn/',
        vi: 'sự cải tạo, tu sửa',
        exampleEn: 'The building is closed for renovation.',
        exampleVi: 'Tòa nhà đóng cửa để cải tạo.',
      ),
      VocabWord(
        en: 'resident',
        ipa: '/ˈrezɪdənt/',
        vi: 'cư dân',
        exampleEn: 'Local residents attended the meeting.',
        exampleVi: 'Cư dân địa phương đã tham dự buổi họp.',
      ),
      VocabWord(
        en: 'official',
        ipa: '/əˈfɪʃl/',
        vi: 'quan chức',
        exampleEn: 'City officials announced the plan.',
        exampleVi: 'Các quan chức thành phố đã công bố kế hoạch.',
      ),
      VocabWord(
        en: 'celebration',
        ipa: '/ˌselɪˈbreɪʃn/',
        vi: 'lễ kỷ niệm, buổi ăn mừng',
        exampleEn: 'They held a celebration for the new school.',
        exampleVi: 'Họ tổ chức một buổi lễ ăn mừng cho ngôi trường mới.',
      ),
    ],
  ),
  Story(
    id: 'library-wins-award',
    title: 'Local Library Wins an Award',
    category: StoryCategory.news,
    level: 'B1',
    color: AppColors.purple,
    segments: [
      StorySegment(
        id: 'library-wins-award-01',
        en: 'This is a practice news report. The story is not real.',
        vi: 'Đây là bài luyện nghe kiểu tin tức. Nội dung không phải sự thật.',
      ),
      StorySegment(
        id: 'library-wins-award-02',
        en: 'A small town library has won a national award for community service.',
        vi: 'Một thư viện thị trấn nhỏ đã giành giải thưởng quốc gia về phục vụ cộng đồng.',
      ),
      StorySegment(
        id: 'library-wins-award-03',
        en: 'The library was recognized for its free after-school reading program.',
        vi: 'Thư viện được ghi nhận nhờ chương trình đọc sách miễn phí sau giờ học.',
      ),
      StorySegment(
        id: 'library-wins-award-04',
        en: 'More than two hundred children take part in the program each week.',
        vi: 'Hơn hai trăm trẻ em tham gia chương trình này mỗi tuần.',
      ),
      StorySegment(
        id: 'library-wins-award-05',
        en: 'The head librarian said the award belongs to the volunteers.',
        vi: 'Trưởng thư viện nói giải thưởng này thuộc về các tình nguyện viên.',
      ),
      StorySegment(
        id: 'library-wins-award-06',
        en: 'Parents say the program has helped their children love reading.',
        vi: 'Các phụ huynh cho biết chương trình đã giúp con họ yêu thích việc đọc sách.',
      ),
      StorySegment(
        id: 'library-wins-award-07',
        en: 'The library plans to use the prize money to buy new books.',
        vi: 'Thư viện dự định dùng tiền thưởng để mua thêm sách mới.',
      ),
    ],
    vocabulary: [
      VocabWord(
        en: 'award',
        ipa: '/əˈwɔːd/',
        vi: 'giải thưởng',
        exampleEn: 'She received an award for her hard work.',
        exampleVi: 'Cô ấy nhận được giải thưởng cho sự chăm chỉ của mình.',
      ),
      VocabWord(
        en: 'recognize',
        ipa: '/ˈrekəɡnaɪz/',
        vi: 'ghi nhận, công nhận',
        exampleEn: 'The company recognized his effort.',
        exampleVi: 'Công ty đã ghi nhận nỗ lực của anh ấy.',
      ),
      VocabWord(
        en: 'volunteer',
        ipa: '/ˌvɒlənˈtɪə(r)/',
        vi: 'tình nguyện viên',
        exampleEn: 'Many volunteers helped clean the beach.',
        exampleVi: 'Nhiều tình nguyện viên đã giúp dọn dẹp bãi biển.',
      ),
      VocabWord(
        en: 'librarian',
        ipa: '/laɪˈbreəriən/',
        vi: 'thủ thư',
        exampleEn: 'Ask the librarian for help finding a book.',
        exampleVi: 'Hãy hỏi thủ thư để được giúp tìm sách.',
      ),
      VocabWord(
        en: 'prize',
        ipa: '/praɪz/',
        vi: 'phần thưởng',
        exampleEn: 'They won a prize at the competition.',
        exampleVi: 'Họ đã giành được phần thưởng ở cuộc thi.',
      ),
    ],
  ),

  // ============================= TED =============================
  Story(
    id: 'on-curiosity',
    title: 'On Curiosity',
    category: StoryCategory.ted,
    level: 'C1',
    color: AppColors.purple,
    segments: [
      StorySegment(
        id: 'on-curiosity-01',
        en:
            'I want to talk to you today about a very simple idea: '
            'curiosity.',
        vi:
            'Hôm nay tôi muốn nói với các bạn về một ý tưởng rất đơn giản: '
            'sự tò mò.',
      ),
      StorySegment(
        id: 'on-curiosity-02',
        en: 'When we stop asking questions, we stop growing.',
        vi: 'Khi chúng ta ngừng đặt câu hỏi, chúng ta ngừng phát triển.',
      ),
      StorySegment(
        id: 'on-curiosity-03',
        en:
            'But when we allow ourselves to wonder, even about small '
            'things, something changes.',
        vi:
            'Nhưng khi chúng ta cho phép mình thắc mắc, dù về những điều '
            'nhỏ bé, điều gì đó sẽ thay đổi.',
      ),
      StorySegment(
        id: 'on-curiosity-04',
        en: 'Think about the last time you asked "why" without needing a reason.',
        vi: 'Hãy nghĩ về lần cuối cùng bạn hỏi "tại sao" mà không cần một lý do nào.',
      ),
      StorySegment(
        id: 'on-curiosity-05',
        en: 'For most adults, that moment happened a long time ago.',
        vi: 'Với hầu hết người trưởng thành, khoảnh khắc đó đã xảy ra từ rất lâu rồi.',
      ),
      StorySegment(
        id: 'on-curiosity-06',
        en: 'Children ask hundreds of questions a day, and we call it normal.',
        vi: 'Trẻ em đặt hàng trăm câu hỏi mỗi ngày, và chúng ta gọi đó là bình thường.',
      ),
      StorySegment(
        id: 'on-curiosity-07',
        en: 'But somewhere along the way, we learn to stop asking.',
        vi: 'Nhưng đâu đó trên chặng đường, chúng ta học cách ngừng hỏi.',
      ),
      StorySegment(
        id: 'on-curiosity-08',
        en:
            'We begin to see the world not as fixed, but as full of '
            'possibility.',
        vi:
            'Chúng ta bắt đầu nhìn thế giới không phải là cố định, mà đầy '
            'khả năng.',
      ),
      StorySegment(
        id: 'on-curiosity-09',
        en: 'So today, I invite you to ask one question you\'ve been afraid to ask.',
        vi: 'Vì vậy hôm nay, tôi mời các bạn đặt một câu hỏi mà bạn vẫn ngại hỏi.',
      ),
    ],
    vocabulary: [
      VocabWord(
        en: 'curiosity',
        ipa: '/ˌkjʊəriˈɒsəti/',
        vi: 'sự tò mò',
        exampleEn: 'Children are full of curiosity.',
        exampleVi: 'Trẻ em rất tò mò.',
      ),
      VocabWord(
        en: 'wonder',
        ipa: '/ˈwʌndə(r)/',
        vi: 'thắc mắc, tự hỏi',
        exampleEn: 'I wonder what that place looks like.',
        exampleVi: 'Tôi tự hỏi nơi đó trông như thế nào.',
      ),
      VocabWord(
        en: 'possibility',
        ipa: '/ˌpɒsəˈbɪləti/',
        vi: 'khả năng, sự có thể xảy ra',
        exampleEn: 'There are many possibilities to consider.',
        exampleVi: 'Có nhiều khả năng cần xem xét.',
      ),
      VocabWord(
        en: 'fixed',
        ipa: '/fɪkst/',
        vi: 'cố định',
        exampleEn: 'The price is fixed and cannot change.',
        exampleVi: 'Giá này cố định và không thể thay đổi.',
      ),
      VocabWord(
        en: 'invite',
        ipa: '/ɪnˈvaɪt/',
        vi: 'mời gọi',
        exampleEn: 'I invite you to think differently.',
        exampleVi: 'Tôi mời bạn hãy suy nghĩ theo cách khác.',
      ),
      VocabWord(
        en: 'grow',
        ipa: '/ɡrəʊ/',
        vi: 'phát triển, lớn lên',
        exampleEn: 'We learn and grow from our mistakes.',
        exampleVi: 'Chúng ta học hỏi và phát triển từ những sai lầm của mình.',
      ),
    ],
  ),
  Story(
    id: 'power-of-small-habits',
    title: 'The Power of Small Habits',
    category: StoryCategory.ted,
    level: 'C1',
    color: AppColors.teal,
    segments: [
      StorySegment(
        id: 'power-of-small-habits-01',
        en: 'We often believe that big change requires big effort.',
        vi: 'Chúng ta thường tin rằng thay đổi lớn cần nỗ lực lớn.',
      ),
      StorySegment(
        id: 'power-of-small-habits-02',
        en: 'But real, lasting change usually comes from something much smaller.',
        vi: 'Nhưng thay đổi thật sự và lâu dài thường đến từ điều gì đó nhỏ hơn nhiều.',
      ),
      StorySegment(
        id: 'power-of-small-habits-03',
        en: 'It comes from a habit repeated quietly, day after day.',
        vi: 'Nó đến từ một thói quen được lặp lại âm thầm, ngày qua ngày.',
      ),
      StorySegment(
        id: 'power-of-small-habits-04',
        en:
            'One percent better every day does not feel impressive in the '
            'moment.',
        vi: 'Tốt hơn một phần trăm mỗi ngày không có vẻ ấn tượng vào lúc đó.',
      ),
      StorySegment(
        id: 'power-of-small-habits-05',
        en: 'But over a year, those small steps add up to something remarkable.',
        vi: 'Nhưng qua một năm, những bước nhỏ đó cộng dồn thành điều đáng kể.',
      ),
      StorySegment(
        id: 'power-of-small-habits-06',
        en: 'The problem is, most people quit before the results appear.',
        vi: 'Vấn đề là, hầu hết mọi người bỏ cuộc trước khi kết quả xuất hiện.',
      ),
      StorySegment(
        id: 'power-of-small-habits-07',
        en: 'They expect fast results, and when they don\'t come, they give up.',
        vi: 'Họ mong đợi kết quả nhanh, và khi nó không đến, họ từ bỏ.',
      ),
      StorySegment(
        id: 'power-of-small-habits-08',
        en: 'So my message today is simple: trust the process, not the timeline.',
        vi: 'Vì vậy thông điệp của tôi hôm nay rất đơn giản: hãy tin vào quá trình, không phải thời gian.',
      ),
    ],
    vocabulary: [
      VocabWord(
        en: 'habit',
        ipa: '/ˈhæbɪt/',
        vi: 'thói quen',
        exampleEn: 'Reading before bed is a good habit.',
        exampleVi: 'Đọc sách trước khi ngủ là một thói quen tốt.',
      ),
      VocabWord(
        en: 'impressive',
        ipa: '/ɪmˈpresɪv/',
        vi: 'ấn tượng',
        exampleEn: 'Her results were very impressive.',
        exampleVi: 'Kết quả của cô ấy rất ấn tượng.',
      ),
      VocabWord(
        en: 'remarkable',
        ipa: '/rɪˈmɑːkəbl/',
        vi: 'đáng chú ý, đáng kể',
        exampleEn: 'They made remarkable progress this year.',
        exampleVi: 'Họ đã có tiến bộ đáng kể trong năm nay.',
      ),
      VocabWord(
        en: 'quit',
        ipa: '/kwɪt/',
        vi: 'từ bỏ, bỏ cuộc',
        exampleEn: "Don't quit when things get hard.",
        exampleVi: 'Đừng bỏ cuộc khi mọi thứ trở nên khó khăn.',
      ),
      VocabWord(
        en: 'process',
        ipa: '/ˈprəʊses/',
        vi: 'quá trình',
        exampleEn: 'Learning a language is a slow process.',
        exampleVi: 'Học một ngôn ngữ là một quá trình chậm rãi.',
      ),
    ],
  ),

  // ============================= TOEFL Listening =============================
  Story(
    id: 'ocean-currents',
    title: 'Ocean Currents',
    category: StoryCategory.toefl,
    level: 'B2',
    color: AppColors.amber,
    segments: [
      StorySegment(
        id: 'ocean-currents-01',
        en: 'Today, we will briefly discuss ocean currents.',
        vi: 'Hôm nay, chúng ta sẽ thảo luận ngắn gọn về hải lưu.',
      ),
      StorySegment(
        id: 'ocean-currents-02',
        en: 'Ocean currents move warm and cold water around the planet.',
        vi: 'Hải lưu di chuyển nước ấm và nước lạnh khắp hành tinh.',
      ),
      StorySegment(
        id: 'ocean-currents-03',
        en: 'This movement affects weather patterns in many different regions.',
        vi:
            'Sự di chuyển này ảnh hưởng đến kiểu thời tiết ở nhiều khu vực '
            'khác nhau.',
      ),
      StorySegment(
        id: 'ocean-currents-04',
        en: 'Some currents are driven by wind, while others are driven by temperature.',
        vi: 'Một số hải lưu do gió tạo ra, số khác do nhiệt độ tạo ra.',
      ),
      StorySegment(
        id: 'ocean-currents-05',
        en: 'One well-known example is the Gulf Stream in the Atlantic Ocean.',
        vi: 'Một ví dụ nổi tiếng là dòng Gulf Stream ở Đại Tây Dương.',
      ),
      StorySegment(
        id: 'ocean-currents-06',
        en: 'It carries warm water from the tropics up toward Europe.',
        vi: 'Nó mang nước ấm từ vùng nhiệt đới lên hướng châu Âu.',
      ),
      StorySegment(
        id: 'ocean-currents-07',
        en: 'This is one reason why parts of Europe have milder winters.',
        vi: 'Đây là một lý do vì sao một số vùng của châu Âu có mùa đông ôn hòa hơn.',
      ),
      StorySegment(
        id: 'ocean-currents-08',
        en: 'Scientists continue to study how currents may change over time.',
        vi: 'Các nhà khoa học tiếp tục nghiên cứu cách hải lưu có thể thay đổi theo thời gian.',
      ),
    ],
    vocabulary: [
      VocabWord(
        en: 'current',
        ipa: '/ˈkʌrənt/',
        vi: 'dòng chảy, hải lưu',
        exampleEn: 'The current in this river is very strong.',
        exampleVi: 'Dòng chảy trên con sông này rất mạnh.',
      ),
      VocabWord(
        en: 'planet',
        ipa: '/ˈplænɪt/',
        vi: 'hành tinh',
        exampleEn: 'Earth is our home planet.',
        exampleVi: 'Trái Đất là hành tinh nhà của chúng ta.',
      ),
      VocabWord(
        en: 'region',
        ipa: '/ˈriːdʒən/',
        vi: 'khu vực, vùng',
        exampleEn: 'This fruit grows in warm regions.',
        exampleVi: 'Loại quả này mọc ở những vùng ấm áp.',
      ),
      VocabWord(
        en: 'tropics',
        ipa: '/ˈtrɒpɪks/',
        vi: 'vùng nhiệt đới',
        exampleEn: 'It rains often in the tropics.',
        exampleVi: 'Ở vùng nhiệt đới thường xuyên có mưa.',
      ),
      VocabWord(
        en: 'mild',
        ipa: '/maɪld/',
        vi: 'ôn hòa, dịu nhẹ',
        exampleEn: 'We had a mild winter this year.',
        exampleVi: 'Năm nay chúng tôi có một mùa đông ôn hòa.',
      ),
    ],
  ),
  Story(
    id: 'the-water-cycle',
    title: 'The Water Cycle',
    category: StoryCategory.toefl,
    level: 'B2',
    color: AppColors.blue,
    segments: [
      StorySegment(
        id: 'the-water-cycle-01',
        en: 'Let\'s take a look at the water cycle, one of nature\'s key processes.',
        vi: 'Hãy cùng xem xét vòng tuần hoàn nước, một trong những quá trình quan trọng của tự nhiên.',
      ),
      StorySegment(
        id: 'the-water-cycle-02',
        en: 'The cycle begins when the sun heats water in oceans and lakes.',
        vi: 'Vòng tuần hoàn bắt đầu khi mặt trời làm nóng nước trong đại dương và hồ.',
      ),
      StorySegment(
        id: 'the-water-cycle-03',
        en: 'This heat causes the water to evaporate into the air as vapor.',
        vi: 'Sức nóng này làm nước bốc hơi vào không khí dưới dạng hơi nước.',
      ),
      StorySegment(
        id: 'the-water-cycle-04',
        en: 'As the vapor rises, it cools and forms clouds.',
        vi: 'Khi hơi nước bay lên, nó nguội đi và tạo thành mây.',
      ),
      StorySegment(
        id: 'the-water-cycle-05',
        en: 'Eventually, the water falls back to earth as rain or snow.',
        vi: 'Cuối cùng, nước rơi trở lại mặt đất dưới dạng mưa hoặc tuyết.',
      ),
      StorySegment(
        id: 'the-water-cycle-06',
        en: 'Some of this water flows into rivers, and some soaks into the ground.',
        vi: 'Một phần nước này chảy vào sông, và một phần thấm xuống lòng đất.',
      ),
      StorySegment(
        id: 'the-water-cycle-07',
        en: 'Eventually, it makes its way back to the ocean, and the cycle repeats.',
        vi: 'Cuối cùng, nó lại quay trở về đại dương, và vòng tuần hoàn lặp lại.',
      ),
    ],
    vocabulary: [
      VocabWord(
        en: 'evaporate',
        ipa: '/ɪˈvæpəreɪt/',
        vi: 'bốc hơi',
        exampleEn: 'The water evaporated in the hot sun.',
        exampleVi: 'Nước bốc hơi dưới ánh nắng nóng.',
      ),
      VocabWord(
        en: 'vapor',
        ipa: '/ˈveɪpə(r)/',
        vi: 'hơi nước',
        exampleEn: 'You can see water vapor above the kettle.',
        exampleVi: 'Bạn có thể thấy hơi nước bốc lên trên ấm đun nước.',
      ),
      VocabWord(
        en: 'soak',
        ipa: '/səʊk/',
        vi: 'thấm, ngấm',
        exampleEn: 'The rainwater soaked into the soil.',
        exampleVi: 'Nước mưa thấm vào đất.',
      ),
      VocabWord(
        en: 'cycle',
        ipa: '/ˈsaɪkl/',
        vi: 'vòng tuần hoàn, chu kỳ',
        exampleEn: 'The seasons follow a yearly cycle.',
        exampleVi: 'Các mùa theo một chu kỳ hàng năm.',
      ),
      VocabWord(
        en: 'eventually',
        ipa: '/ɪˈventʃuəli/',
        vi: 'cuối cùng',
        exampleEn: 'Eventually, the rain stopped.',
        exampleVi: 'Cuối cùng, cơn mưa đã ngừng.',
      ),
    ],
  ),

  // ============================= Medical English =============================
  Story(
    id: 'nurse-patient-checkup',
    title: 'A Quiet Checkup',
    category: StoryCategory.medical,
    level: 'B1',
    color: AppColors.pink,
    segments: [
      StorySegment(
        id: 'nurse-patient-checkup-01',
        speaker: 'Nurse',
        en: 'How are you feeling this evening?',
        vi: 'Tối nay bạn cảm thấy thế nào?',
      ),
      StorySegment(
        id: 'nurse-patient-checkup-02',
        speaker: 'Patient',
        en: 'A little tired, but the pain has become much less.',
        vi: 'Hơi mệt, nhưng cơn đau đã giảm đi nhiều rồi.',
      ),
      StorySegment(
        id: 'nurse-patient-checkup-03',
        speaker: 'Nurse',
        en: 'That\'s good to hear. Let me check your temperature quickly.',
        vi: 'Nghe vậy tốt quá. Để tôi kiểm tra nhiệt độ của bạn một chút.',
      ),
      StorySegment(
        id: 'nurse-patient-checkup-04',
        speaker: 'Nurse',
        en: 'Your temperature is normal now, which is great news.',
        vi: 'Nhiệt độ của bạn bây giờ bình thường rồi, đó là tin tốt.',
      ),
      StorySegment(
        id: 'nurse-patient-checkup-05',
        speaker: 'Patient',
        en: 'Does that mean I can go home soon?',
        vi: 'Vậy có nghĩa là tôi sắp được về nhà không?',
      ),
      StorySegment(
        id: 'nurse-patient-checkup-06',
        speaker: 'Nurse',
        en: 'The doctor will check on you tomorrow morning to confirm.',
        vi: 'Bác sĩ sẽ đến kiểm tra bạn vào sáng mai để xác nhận.',
      ),
      StorySegment(
        id: 'nurse-patient-checkup-07',
        speaker: 'Nurse',
        en: 'For now, try to get some rest tonight.',
        vi: 'Bây giờ, cố gắng nghỉ ngơi tối nay nhé.',
      ),
      StorySegment(
        id: 'nurse-patient-checkup-08',
        speaker: 'Patient',
        en: 'Thank you. I will.',
        vi: 'Cảm ơn cô. Tôi sẽ cố gắng.',
      ),
    ],
    vocabulary: [
      VocabWord(
        en: 'nurse',
        ipa: '/nɜːs/',
        vi: 'y tá',
        exampleEn: 'The nurse checked my temperature.',
        exampleVi: 'Y tá đã kiểm tra nhiệt độ của tôi.',
      ),
      VocabWord(
        en: 'patient',
        ipa: '/ˈpeɪʃnt/',
        vi: 'bệnh nhân',
        exampleEn: 'The doctor is with a patient right now.',
        exampleVi: 'Bác sĩ đang khám cho một bệnh nhân.',
      ),
      VocabWord(
        en: 'temperature',
        ipa: '/ˈtemprətʃə(r)/',
        vi: 'nhiệt độ (cơ thể)',
        exampleEn: 'Your temperature is a little high.',
        exampleVi: 'Nhiệt độ của bạn hơi cao.',
      ),
      VocabWord(
        en: 'confirm',
        ipa: '/kənˈfɜːm/',
        vi: 'xác nhận',
        exampleEn: 'The doctor will confirm the results tomorrow.',
        exampleVi: 'Bác sĩ sẽ xác nhận kết quả vào ngày mai.',
      ),
      VocabWord(
        en: 'rest',
        ipa: '/rest/',
        vi: 'nghỉ ngơi',
        exampleEn: 'You need to get some rest.',
        exampleVi: 'Bạn cần nghỉ ngơi một chút.',
      ),
    ],
  ),
  Story(
    id: 'visit-to-the-pharmacy',
    title: 'A Visit to the Pharmacy',
    category: StoryCategory.medical,
    level: 'B1',
    color: AppColors.teal,
    segments: [
      StorySegment(
        id: 'visit-to-the-pharmacy-01',
        speaker: 'Customer',
        en: 'Hi, I have a prescription from my doctor.',
        vi: 'Chào chị, tôi có đơn thuốc từ bác sĩ.',
      ),
      StorySegment(
        id: 'visit-to-the-pharmacy-02',
        speaker: 'Pharmacist',
        en: 'Sure, let me take a look at it.',
        vi: 'Được ạ, để tôi xem qua nhé.',
      ),
      StorySegment(
        id: 'visit-to-the-pharmacy-03',
        speaker: 'Pharmacist',
        en: 'This medicine should be taken twice a day, after meals.',
        vi: 'Thuốc này nên uống hai lần một ngày, sau bữa ăn.',
      ),
      StorySegment(
        id: 'visit-to-the-pharmacy-04',
        speaker: 'Customer',
        en: 'Are there any side effects I should know about?',
        vi: 'Có tác dụng phụ nào tôi cần biết không?',
      ),
      StorySegment(
        id: 'visit-to-the-pharmacy-05',
        speaker: 'Pharmacist',
        en: 'It might cause mild drowsiness, so avoid driving after taking it.',
        vi: 'Nó có thể gây buồn ngủ nhẹ, nên tránh lái xe sau khi uống.',
      ),
      StorySegment(
        id: 'visit-to-the-pharmacy-06',
        speaker: 'Customer',
        en: 'Understood. How long should I take this for?',
        vi: 'Tôi hiểu rồi. Tôi nên uống trong bao lâu?',
      ),
      StorySegment(
        id: 'visit-to-the-pharmacy-07',
        speaker: 'Pharmacist',
        en: 'For one full week, even if you start feeling better.',
        vi: 'Trong đúng một tuần, dù bạn có cảm thấy khỏe hơn sớm.',
      ),
      StorySegment(
        id: 'visit-to-the-pharmacy-08',
        speaker: 'Customer',
        en: 'Got it. Thank you very much for your help.',
        vi: 'Tôi hiểu rồi. Cảm ơn chị rất nhiều vì đã giúp đỡ.',
      ),
    ],
    vocabulary: [
      VocabWord(
        en: 'prescription',
        ipa: '/prɪˈskrɪpʃn/',
        vi: 'đơn thuốc',
        exampleEn: 'You need a prescription for this medicine.',
        exampleVi: 'Bạn cần đơn thuốc để mua loại thuốc này.',
      ),
      VocabWord(
        en: 'medicine',
        ipa: '/ˈmedsn/',
        vi: 'thuốc',
        exampleEn: 'Take this medicine before bed.',
        exampleVi: 'Uống thuốc này trước khi đi ngủ.',
      ),
      VocabWord(
        en: 'side effect',
        ipa: '/saɪd ɪˈfekt/',
        vi: 'tác dụng phụ',
        exampleEn: 'This drug has few side effects.',
        exampleVi: 'Loại thuốc này ít tác dụng phụ.',
      ),
      VocabWord(
        en: 'drowsiness',
        ipa: '/ˈdraʊzinəs/',
        vi: 'sự buồn ngủ',
        exampleEn: 'The medicine may cause drowsiness.',
        exampleVi: 'Thuốc có thể gây buồn ngủ.',
      ),
      VocabWord(
        en: 'avoid',
        ipa: '/əˈvɔɪd/',
        vi: 'tránh',
        exampleEn: 'Avoid eating spicy food for now.',
        exampleVi: 'Tránh ăn đồ cay trong lúc này.',
      ),
    ],
  ),

  // ============================= IPA / Pronunciation =============================
  Story(
    id: 'minimal-pairs-practice',
    title: 'Minimal Pairs Practice',
    category: StoryCategory.ipa,
    level: 'A1',
    color: AppColors.blue,
    segments: [
      StorySegment(
        id: 'minimal-pairs-practice-01',
        en: 'Listen and repeat slowly.',
        vi: 'Nghe và lặp lại thật chậm.',
      ),
      StorySegment(
        id: 'minimal-pairs-practice-02',
        en: 'Ship. Sheep. Ship. Sheep.',
        vi: 'Ship. Sheep. Ship. Sheep.',
      ),
      StorySegment(
        id: 'minimal-pairs-practice-03',
        en: 'Full. Fool. Full. Fool.',
        vi: 'Full. Fool. Full. Fool.',
      ),
      StorySegment(
        id: 'minimal-pairs-practice-04',
        en: 'Bit. Beat. Bit. Beat.',
        vi: 'Bit. Beat. Bit. Beat.',
      ),
      StorySegment(
        id: 'minimal-pairs-practice-05',
        en: 'Seat. Sit. Seat. Sit.',
        vi: 'Seat. Sit. Seat. Sit.',
      ),
      StorySegment(
        id: 'minimal-pairs-practice-06',
        en: 'Cheap. Chip. Cheap. Chip.',
        vi: 'Cheap. Chip. Cheap. Chip.',
      ),
      StorySegment(
        id: 'minimal-pairs-practice-07',
        en: 'Good. Now breathe, and relax your voice.',
        vi: 'Tốt. Giờ hãy hít thở, và thả lỏng giọng nói.',
      ),
    ],
    vocabulary: [
      VocabWord(
        en: 'ship',
        ipa: '/ʃɪp/',
        vi: 'con tàu',
        exampleEn: 'The ship left the port at noon.',
        exampleVi: 'Con tàu rời cảng vào buổi trưa.',
      ),
      VocabWord(
        en: 'sheep',
        ipa: '/ʃiːp/',
        vi: 'con cừu',
        exampleEn: 'There are many sheep on the farm.',
        exampleVi: 'Có nhiều con cừu trong trang trại.',
      ),
      VocabWord(
        en: 'seat',
        ipa: '/siːt/',
        vi: 'chỗ ngồi',
        exampleEn: 'Please take a seat.',
        exampleVi: 'Xin mời ngồi.',
      ),
      VocabWord(
        en: 'cheap',
        ipa: '/tʃiːp/',
        vi: 'rẻ',
        exampleEn: 'This market sells cheap fruit.',
        exampleVi: 'Chợ này bán trái cây rẻ.',
      ),
      VocabWord(
        en: 'relax',
        ipa: '/rɪˈlæks/',
        vi: 'thả lỏng, thư giãn',
        exampleEn: 'Relax your shoulders and breathe.',
        exampleVi: 'Thả lỏng vai và hít thở.',
      ),
    ],
  ),
  Story(
    id: 'word-stress-practice',
    title: 'Word Stress Practice',
    category: StoryCategory.ipa,
    level: 'A2',
    color: AppColors.purple,
    segments: [
      StorySegment(
        id: 'word-stress-practice-01',
        en: 'In English, one syllable in a word is usually stressed, or louder.',
        vi: 'Trong tiếng Anh, một âm tiết trong từ thường được nhấn, hay to hơn.',
      ),
      StorySegment(
        id: 'word-stress-practice-02',
        en: 'Listen to this word: PRE-sent. The stress is on the first part.',
        vi: 'Nghe từ này: PRE-sent. Trọng âm rơi vào phần đầu.',
      ),
      StorySegment(
        id: 'word-stress-practice-03',
        en: 'This means a gift, like a birthday present.',
        vi: 'Từ này có nghĩa là một món quà, như quà sinh nhật.',
      ),
      StorySegment(
        id: 'word-stress-practice-04',
        en: 'Now listen: pre-SENT. The stress moves to the second part.',
        vi: 'Bây giờ nghe: pre-SENT. Trọng âm chuyển sang phần thứ hai.',
      ),
      StorySegment(
        id: 'word-stress-practice-05',
        en: 'This means to show or give something, like presenting a project.',
        vi: 'Từ này có nghĩa là trình bày hoặc trao tặng thứ gì đó, như trình bày một dự án.',
      ),
      StorySegment(
        id: 'word-stress-practice-06',
        en: 'The word is spelled the same, but the stress changes the meaning.',
        vi: 'Từ được viết giống nhau, nhưng trọng âm thay đổi ý nghĩa.',
      ),
      StorySegment(
        id: 'word-stress-practice-07',
        en: 'Let\'s try one more: REC-ord and re-CORD. Listen carefully.',
        vi: 'Hãy thử thêm một từ nữa: REC-ord và re-CORD. Hãy nghe thật kỹ.',
      ),
    ],
    vocabulary: [
      VocabWord(
        en: 'stress',
        ipa: '/stres/',
        vi: 'trọng âm',
        exampleEn: 'Word stress can change the meaning.',
        exampleVi: 'Trọng âm của từ có thể làm thay đổi ý nghĩa.',
      ),
      VocabWord(
        en: 'syllable',
        ipa: '/ˈsɪləbl/',
        vi: 'âm tiết',
        exampleEn: 'The word "banana" has three syllables.',
        exampleVi: 'Từ "banana" có ba âm tiết.',
      ),
      VocabWord(
        en: 'present (noun)',
        ipa: '/ˈpreznt/',
        vi: 'món quà',
        exampleEn: 'She gave me a lovely present.',
        exampleVi: 'Cô ấy đã tặng tôi một món quà đáng yêu.',
      ),
      VocabWord(
        en: 'present (verb)',
        ipa: '/prɪˈzent/',
        vi: 'trình bày, trao',
        exampleEn: "I'll present my ideas tomorrow.",
        exampleVi: 'Tôi sẽ trình bày ý tưởng của mình vào ngày mai.',
      ),
      VocabWord(
        en: 'record (noun)',
        ipa: '/ˈrekɔːd/',
        vi: 'kỷ lục, bản ghi',
        exampleEn: 'She broke the world record.',
        exampleVi: 'Cô ấy đã phá kỷ lục thế giới.',
      ),
    ],
  ),

  // ============================= Numbers =============================
  Story(
    id: 'listening-to-numbers',
    title: 'Listening to Numbers',
    category: StoryCategory.numbers,
    level: 'A1',
    color: AppColors.teal,
    segments: [
      StorySegment(
        id: 'listening-to-numbers-01',
        en: 'Listen slowly to these numbers.',
        vi: 'Nghe thật chậm những con số sau.',
      ),
      StorySegment(
        id: 'listening-to-numbers-02',
        en: 'One. Three. Seven.',
        vi: 'Một. Ba. Bảy.',
      ),
      StorySegment(
        id: 'listening-to-numbers-03',
        en: 'Twelve. Twenty. One hundred.',
        vi: 'Mười hai. Hai mươi. Một trăm.',
      ),
      StorySegment(
        id: 'listening-to-numbers-04',
        en: 'My phone number is zero, nine, one, two, three, four, five, six.',
        vi: 'Số điện thoại của tôi là không, chín, một, hai, ba, bốn, năm, sáu.',
      ),
      StorySegment(
        id: 'listening-to-numbers-05',
        en: 'Now let\'s try a date: the fourteenth of March.',
        vi: 'Bây giờ hãy thử một ngày tháng: ngày mười bốn tháng Ba.',
      ),
      StorySegment(
        id: 'listening-to-numbers-06',
        en: 'And a time: it is half past six in the evening.',
        vi: 'Và một mốc giờ: bây giờ là sáu giờ rưỡi tối.',
      ),
      StorySegment(
        id: 'listening-to-numbers-07',
        en: 'Well done. Let\'s move on to something a little harder.',
        vi: 'Làm tốt lắm. Hãy chuyển sang thứ gì đó khó hơn một chút.',
      ),
    ],
    vocabulary: [
      VocabWord(
        en: 'number',
        ipa: '/ˈnʌmbə(r)/',
        vi: 'con số',
        exampleEn: 'What is your phone number?',
        exampleVi: 'Số điện thoại của bạn là gì?',
      ),
      VocabWord(
        en: 'hundred',
        ipa: '/ˈhʌndrəd/',
        vi: 'một trăm',
        exampleEn: 'There were a hundred people at the event.',
        exampleVi: 'Có một trăm người tại sự kiện đó.',
      ),
      VocabWord(
        en: 'date',
        ipa: '/deɪt/',
        vi: 'ngày tháng',
        exampleEn: "What's the date today?",
        exampleVi: 'Hôm nay là ngày mấy?',
      ),
      VocabWord(
        en: 'half past',
        ipa: '/hɑːf pɑːst/',
        vi: '(giờ) rưỡi',
        exampleEn: "It's half past nine.",
        exampleVi: 'Bây giờ là chín giờ rưỡi.',
      ),
      VocabWord(
        en: 'twenty',
        ipa: '/ˈtwenti/',
        vi: 'hai mươi',
        exampleEn: 'She is twenty years old.',
        exampleVi: 'Cô ấy hai mươi tuổi.',
      ),
    ],
  ),
  Story(
    id: 'prices-and-numbers',
    title: 'Prices and Numbers',
    category: StoryCategory.numbers,
    level: 'A2',
    color: AppColors.amber,
    segments: [
      StorySegment(
        id: 'prices-and-numbers-01',
        speaker: 'Customer',
        en: 'How much is this shirt?',
        vi: 'Cái áo này giá bao nhiêu vậy?',
      ),
      StorySegment(
        id: 'prices-and-numbers-02',
        speaker: 'Seller',
        en: 'That one is fifteen dollars.',
        vi: 'Cái đó giá mười lăm đô la.',
      ),
      StorySegment(
        id: 'prices-and-numbers-03',
        speaker: 'Customer',
        en: 'And how much are these shoes?',
        vi: 'Vậy đôi giày này bao nhiêu?',
      ),
      StorySegment(
        id: 'prices-and-numbers-04',
        speaker: 'Seller',
        en: 'The shoes are forty-two dollars.',
        vi: 'Đôi giày này giá bốn mươi hai đô la.',
      ),
      StorySegment(
        id: 'prices-and-numbers-05',
        speaker: 'Customer',
        en: 'If I buy both, is there a discount?',
        vi: 'Nếu tôi mua cả hai thì có được giảm giá không?',
      ),
      StorySegment(
        id: 'prices-and-numbers-06',
        speaker: 'Seller',
        en: 'Yes, together they will be fifty dollars.',
        vi: 'Có chứ, mua chung sẽ là năm mươi đô la.',
      ),
      StorySegment(
        id: 'prices-and-numbers-07',
        speaker: 'Customer',
        en: 'Great, I\'ll take both, please.',
        vi: 'Tuyệt, vậy cho tôi lấy cả hai nhé.',
      ),
    ],
    vocabulary: [
      VocabWord(
        en: 'price',
        ipa: '/praɪs/',
        vi: 'giá cả',
        exampleEn: 'The price is very reasonable.',
        exampleVi: 'Giá này rất hợp lý.',
      ),
      VocabWord(
        en: 'discount',
        ipa: '/ˈdɪskaʊnt/',
        vi: 'giảm giá',
        exampleEn: 'We offer a discount for students.',
        exampleVi: 'Chúng tôi có giảm giá cho sinh viên.',
      ),
      VocabWord(
        en: 'both',
        ipa: '/bəʊθ/',
        vi: 'cả hai',
        exampleEn: 'I like both colors.',
        exampleVi: 'Tôi thích cả hai màu.',
      ),
      VocabWord(
        en: 'together',
        ipa: '/təˈɡeðə(r)/',
        vi: 'cùng nhau, gộp lại',
        exampleEn: 'Let\'s add these together.',
        exampleVi: 'Hãy cộng những thứ này lại với nhau.',
      ),
      VocabWord(
        en: 'reasonable',
        ipa: '/ˈriːznəbl/',
        vi: 'hợp lý',
        exampleEn: 'That sounds like a reasonable price.',
        exampleVi: 'Nghe có vẻ như đó là một mức giá hợp lý.',
      ),
    ],
  ),

  // ============================= Spelling Names =============================
  Story(
    id: 'spelling-names',
    title: 'Spelling Names',
    category: StoryCategory.spellingNames,
    level: 'A1',
    color: AppColors.purple,
    segments: [
      StorySegment(
        id: 'spelling-names-01',
        en: 'Listen to this name, spelled slowly.',
        vi: 'Nghe tên này, được đánh vần thật chậm.',
      ),
      StorySegment(
        id: 'spelling-names-02',
        en: 'My name is Anna. A, N, N, A. Anna.',
        vi: 'Tên tôi là Anna. A, N, N, A. Anna.',
      ),
      StorySegment(
        id: 'spelling-names-03',
        en: 'Her name is Daniel. D, A, N, I, E, L. Daniel.',
        vi: 'Tên cô ấy là Daniel. D, A, N, I, E, L. Daniel.',
      ),
      StorySegment(
        id: 'spelling-names-04',
        en: 'His family name is Wilson. W, I, L, S, O, N. Wilson.',
        vi: 'Họ của anh ấy là Wilson. W, I, L, S, O, N. Wilson.',
      ),
      StorySegment(
        id: 'spelling-names-05',
        en: 'One more: the city is called Boston. B, O, S, T, O, N. Boston.',
        vi: 'Thêm một cái nữa: thành phố tên là Boston. B, O, S, T, O, N. Boston.',
      ),
      StorySegment(
        id: 'spelling-names-06',
        en: 'Now, can you spell your own name?',
        vi: 'Bây giờ, bạn có thể đánh vần tên của mình không?',
      ),
    ],
    vocabulary: [
      VocabWord(
        en: 'name',
        ipa: '/neɪm/',
        vi: 'tên',
        exampleEn: 'What is your name?',
        exampleVi: 'Tên bạn là gì?',
      ),
      VocabWord(
        en: 'spell',
        ipa: '/spel/',
        vi: 'đánh vần',
        exampleEn: 'Can you spell that word for me?',
        exampleVi: 'Bạn có thể đánh vần từ đó cho tôi không?',
      ),
      VocabWord(
        en: 'letter',
        ipa: '/ˈletə(r)/',
        vi: 'chữ cái',
        exampleEn: 'The word "cat" has three letters.',
        exampleVi: 'Từ "cat" có ba chữ cái.',
      ),
      VocabWord(
        en: 'family name',
        ipa: '/ˈfæməli neɪm/',
        vi: 'họ',
        exampleEn: 'Please write your family name first.',
        exampleVi: 'Vui lòng viết họ của bạn trước.',
      ),
      VocabWord(
        en: 'own',
        ipa: '/əʊn/',
        vi: 'của riêng mình',
        exampleEn: 'Everyone has their own name.',
        exampleVi: 'Mỗi người đều có tên riêng của mình.',
      ),
    ],
  ),
  Story(
    id: 'spelling-email-addresses',
    title: 'Spelling Email Addresses',
    category: StoryCategory.spellingNames,
    level: 'A2',
    color: AppColors.blue,
    segments: [
      StorySegment(
        id: 'spelling-email-addresses-01',
        speaker: 'Staff',
        en: 'Could you give me your email address, please?',
        vi: 'Bạn có thể cho tôi địa chỉ email của bạn được không?',
      ),
      StorySegment(
        id: 'spelling-email-addresses-02',
        speaker: 'Customer',
        en: 'Sure. It\'s lisa, L, I, S, A, dot chen, C, H, E, N.',
        vi: 'Được ạ. Đó là lisa, L, I, S, A, chấm chen, C, H, E, N.',
      ),
      StorySegment(
        id: 'spelling-email-addresses-03',
        speaker: 'Staff',
        en: 'Lisa dot Chen, got it. And what comes after that?',
        vi: 'Lisa chấm Chen, tôi ghi rồi. Và sau đó là gì ạ?',
      ),
      StorySegment(
        id: 'spelling-email-addresses-04',
        speaker: 'Customer',
        en: 'At symbol, then mailbox, M, A, I, L, B, O, X.',
        vi: 'Ký hiệu @, sau đó là mailbox, M, A, I, L, B, O, X.',
      ),
      StorySegment(
        id: 'spelling-email-addresses-05',
        speaker: 'Staff',
        en: 'Mailbox... and finally?',
        vi: 'Mailbox... và cuối cùng là gì ạ?',
      ),
      StorySegment(
        id: 'spelling-email-addresses-06',
        speaker: 'Customer',
        en: 'Dot com. So altogether: lisa dot chen at mailbox dot com.',
        vi: 'Chấm com. Vậy toàn bộ là: lisa chấm chen a-còng mailbox chấm com.',
      ),
      StorySegment(
        id: 'spelling-email-addresses-07',
        speaker: 'Staff',
        en: 'Perfect, thank you for spelling that out clearly.',
        vi: 'Hoàn hảo, cảm ơn bạn đã đánh vần rõ ràng như vậy.',
      ),
    ],
    vocabulary: [
      VocabWord(
        en: 'email address',
        ipa: '/ˈiːmeɪl əˈdres/',
        vi: 'địa chỉ email',
        exampleEn: 'Please send it to my email address.',
        exampleVi: 'Vui lòng gửi nó đến địa chỉ email của tôi.',
      ),
      VocabWord(
        en: 'at symbol',
        ipa: '/æt ˈsɪmbl/',
        vi: 'ký hiệu a-còng (@)',
        exampleEn: 'Don\'t forget the at symbol in the address.',
        exampleVi: 'Đừng quên ký hiệu a-còng trong địa chỉ.',
      ),
      VocabWord(
        en: 'dot',
        ipa: '/dɒt/',
        vi: 'dấu chấm',
        exampleEn: 'The website ends in dot com.',
        exampleVi: 'Trang web kết thúc bằng chấm com.',
      ),
      VocabWord(
        en: 'clearly',
        ipa: '/ˈklɪəli/',
        vi: 'một cách rõ ràng',
        exampleEn: 'Please speak clearly.',
        exampleVi: 'Vui lòng nói một cách rõ ràng.',
      ),
      VocabWord(
        en: 'altogether',
        ipa: '/ˌɔːltəˈɡeðə(r)/',
        vi: 'tổng cộng, toàn bộ',
        exampleEn: 'Altogether, it costs thirty dollars.',
        exampleVi: 'Tổng cộng, nó có giá ba mươi đô la.',
      ),
    ],
  ),
];

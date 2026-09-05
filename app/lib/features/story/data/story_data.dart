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
        en: 'The next bus finally arrived a few minutes later.',
        vi: 'Chuyến xe buýt tiếp theo cuối cùng cũng đến sau vài phút.',
      ),
      StorySegment(
        id: 'a-rainy-morning-12',
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
        en: 'kindness',
        ipa: '/ˈkaɪndnəs/',
        vi: 'lòng tốt',
        exampleEn: "A small act of kindness can make someone's day.",
        exampleVi: 'Một hành động tử tế nhỏ có thể làm ngày của ai đó tốt hơn.',
      ),
    ],
  ),
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
        en: 'Just a little, thank you.',
        vi: 'Một chút thôi, cảm ơn.',
      ),
      StorySegment(
        id: 'at-the-coffee-shop-05',
        speaker: 'A',
        en: 'Here you are. Please take your time.',
        vi: 'Đây ạ. Mời bạn dùng từ từ.',
      ),
      StorySegment(
        id: 'at-the-coffee-shop-06',
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
        en: 'strong',
        ipa: '/strɒŋ/',
        vi: 'đậm, mạnh',
        exampleEn: 'This coffee is too strong for me.',
        exampleVi: 'Cà phê này đậm quá đối với tôi.',
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
        en: 'A gentle wind came and said, "Follow me, little cloud."',
        vi: 'Một cơn gió nhẹ đến và nói, "Hãy theo tôi, đám mây nhỏ ơi."',
      ),
      StorySegment(
        id: 'the-little-cloud-04',
        en:
            'Together, they floated across the sky until the stars '
            'appeared.',
        vi:
            'Cùng nhau, họ bay ngang bầu trời cho đến khi những vì sao '
            'xuất hiện.',
      ),
      StorySegment(
        id: 'the-little-cloud-05',
        en:
            'At last, the little cloud found her family, resting above the '
            'quiet sea.',
        vi:
            'Cuối cùng, đám mây nhỏ tìm thấy gia đình mình, đang nghỉ ngơi '
            'trên mặt biển yên tĩnh.',
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
        en: 'follow',
        ipa: '/ˈfɒləʊ/',
        vi: 'đi theo',
        exampleEn: 'Please follow me this way.',
        exampleVi: 'Xin hãy đi theo tôi lối này.',
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
        en: 'We apologize for any inconvenience this may cause.',
        vi: 'Chúng tôi xin lỗi vì bất kỳ sự bất tiện nào gây ra.',
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
        exampleEn: "The shop was closed, so we went home instead.",
        exampleVi: 'Cửa hàng đóng cửa, nên chúng tôi về nhà thay vào đó.',
      ),
      VocabWord(
        en: 'apologize',
        ipa: '/əˈpɒlədʒaɪz/',
        vi: 'xin lỗi',
        exampleEn: 'We apologize for the delay.',
        exampleVi: 'Chúng tôi xin lỗi vì sự chậm trễ.',
      ),
      VocabWord(
        en: 'inconvenience',
        ipa: '/ˌɪnkənˈviːniəns/',
        vi: 'sự bất tiện',
        exampleEn: 'Sorry for the inconvenience.',
        exampleVi: 'Xin lỗi vì sự bất tiện này.',
      ),
    ],
  ),
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
        en: 'The library opens at eight and closes at nine in the evening.',
        vi: 'Thư viện mở cửa lúc tám giờ và đóng cửa lúc chín giờ tối.',
      ),
      StorySegment(
        id: 'university-library-tour-05',
        en: 'Please remember to bring your student card every time you visit.',
        vi: 'Xin nhớ mang theo thẻ sinh viên mỗi khi đến đây.',
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
        en: 'quiet',
        ipa: '/ˈkwaɪət/',
        vi: 'yên tĩnh',
        exampleEn: 'Please keep quiet in the library.',
        exampleVi: 'Xin giữ yên tĩnh trong thư viện.',
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
        en: 'It was the perfect time to slow down and just breathe.',
        vi: 'Đó là thời điểm hoàn hảo để chậm lại và chỉ hít thở thôi.',
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
        en: 'share',
        ipa: '/ʃeə(r)/',
        vi: 'chia sẻ',
        exampleEn: 'I want to share something with you.',
        exampleVi: 'Tôi muốn chia sẻ điều gì đó với bạn.',
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
        exampleEn: 'Let\'s slow down and enjoy the view.',
        exampleVi: 'Hãy chậm lại và tận hưởng khung cảnh.',
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
        en: 'The park will now stay open every evening until nine o\'clock.',
        vi: 'Công viên hiện sẽ mở cửa mỗi tối đến chín giờ.',
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
        en: 'reopen',
        ipa: '/ˌriːˈəʊpən/',
        vi: 'mở cửa trở lại',
        exampleEn: 'The store will reopen on Monday.',
        exampleVi: 'Cửa hàng sẽ mở cửa lại vào thứ Hai.',
      ),
      VocabWord(
        en: 'space',
        ipa: '/speɪs/',
        vi: 'không gian',
        exampleEn: 'We need more green space in the city.',
        exampleVi: 'Chúng ta cần thêm không gian xanh trong thành phố.',
      ),
    ],
  ),
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
        en:
            'We begin to see the world not as fixed, but as full of '
            'possibility.',
        vi:
            'Chúng ta bắt đầu nhìn thế giới không phải là cố định, mà đầy '
            'khả năng.',
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
        en: 'grow',
        ipa: '/ɡrəʊ/',
        vi: 'phát triển, lớn lên',
        exampleEn: 'We learn and grow from our mistakes.',
        exampleVi: 'Chúng ta học hỏi và phát triển từ những sai lầm của mình.',
      ),
    ],
  ),
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
        en: 'movement',
        ipa: '/ˈmuːvmənt/',
        vi: 'sự di chuyển, chuyển động',
        exampleEn: 'The movement of the clouds was slow.',
        exampleVi: 'Chuyển động của những đám mây rất chậm.',
      ),
      VocabWord(
        en: 'region',
        ipa: '/ˈriːdʒən/',
        vi: 'khu vực, vùng',
        exampleEn: 'This fruit grows in warm regions.',
        exampleVi: 'Loại quả này mọc ở những vùng ấm áp.',
      ),
      VocabWord(
        en: 'temperature',
        ipa: '/ˈtemprətʃə(r)/',
        vi: 'nhiệt độ',
        exampleEn: 'The temperature dropped at night.',
        exampleVi: 'Nhiệt độ giảm xuống vào ban đêm.',
      ),
    ],
  ),
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
        en: 'That\'s good to hear. Try to get some rest tonight.',
        vi: 'Nghe vậy tốt quá. Cố gắng nghỉ ngơi tối nay nhé.',
      ),
      StorySegment(
        id: 'nurse-patient-checkup-04',
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
        en: 'pain',
        ipa: '/peɪn/',
        vi: 'cơn đau',
        exampleEn: 'The pain in my back is gone now.',
        exampleVi: 'Cơn đau ở lưng tôi đã hết rồi.',
      ),
      VocabWord(
        en: 'rest',
        ipa: '/rest/',
        vi: 'nghỉ ngơi',
        exampleEn: 'You need to get some rest.',
        exampleVi: 'Bạn cần nghỉ ngơi một chút.',
      ),
      VocabWord(
        en: 'feel',
        ipa: '/fiːl/',
        vi: 'cảm thấy',
        exampleEn: 'How do you feel today?',
        exampleVi: 'Hôm nay bạn cảm thấy thế nào?',
      ),
    ],
  ),
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
        en: 'full',
        ipa: '/fʊl/',
        vi: 'đầy',
        exampleEn: 'My cup is full.',
        exampleVi: 'Cốc của tôi đầy rồi.',
      ),
      VocabWord(
        en: 'fool',
        ipa: '/fuːl/',
        vi: 'kẻ ngốc',
        exampleEn: "Don't act like a fool.",
        exampleVi: 'Đừng cư xử như một kẻ ngốc.',
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
        en: 'zero',
        ipa: '/ˈzɪərəʊ/',
        vi: 'số không',
        exampleEn: 'The score was zero to zero.',
        exampleVi: 'Tỷ số là không đều.',
      ),
      VocabWord(
        en: 'twelve',
        ipa: '/twelv/',
        vi: 'mười hai',
        exampleEn: 'There are twelve months in a year.',
        exampleVi: 'Có mười hai tháng trong một năm.',
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
        en: 'capital',
        ipa: '/ˈkæpɪtl/',
        vi: 'chữ in hoa',
        exampleEn: 'Start the name with a capital letter.',
        exampleVi: 'Bắt đầu tên bằng một chữ in hoa.',
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
];

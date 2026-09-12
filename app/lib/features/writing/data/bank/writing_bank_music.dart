import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../learning_path/data/learning_path_models.dart';
import '../writing_bank.dart';
import '../writing_grammar.dart';
import '../writing_paragraph_data.dart';

// Noi dung TU SOAN - quy uoc: xem writing_bank_family.dart.

const _b = LearnerLevel.basic;
const _i = LearnerLevel.intermediate;
const _a = LearnerLevel.advanced;

const kWritingBankMusic = WritingTopic(
  id: 'music',
  titleVi: 'Âm nhạc',
  titleEn: 'Music',
  icon: Icons.music_note_rounded,
  color: AppColors.purple,
  paragraphs: [
    // ---------------- Co ban ----------------
    WritingParagraph(
      id: 'music_b1',
      level: _b,
      titleVi: 'Bài hát yêu thích',
      titleEn: 'My favorite song',
      sentences: [
        WritingSentence.of(
          'Tôi rất thích âm nhạc.',
          'I love music.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi nghe nhạc mỗi ngày.',
          'I listen to music every day.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Bài hát yêu thích của tôi rất vui.',
          'My favorite song is very happy.',
          G.presentSimple,
          alternatives: ['My favourite song is very happy.'],
        ),
        WritingSentence.of(
          'Tôi có thể hát cả bài.',
          'I can sing the whole song.',
          G.modal,
        ),
        WritingSentence.of(
          'Em gái tôi cũng thích nó.',
          'My sister likes it too.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'music_b2',
      level: _b,
      titleVi: 'Học đàn piano',
      titleEn: 'Piano lessons',
      sentences: [
        WritingSentence.of(
          'Em trai tôi đang học đàn piano.',
          'My brother is learning the piano.',
          G.presentContinuous,
          alternatives: ['My younger brother is learning to play the piano.'],
        ),
        WritingSentence.of(
          'Nó học vào mỗi thứ tư.',
          'He has lessons every Wednesday.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Bây giờ nó đang tập một bài mới.',
          'Now he is practicing a new song.',
          G.presentContinuous,
          alternatives: ['Now he is practising a new song.'],
        ),
        WritingSentence.of(
          'Tiếng đàn rất hay.',
          'The music sounds very nice.',
          G.presentSimple,
          alternatives: ['It sounds very nice.'],
        ),
        WritingSentence.of(
          'Mẹ tôi đang lắng nghe.',
          'My mother is listening.',
          G.presentContinuous,
          alternatives: ['My mom is listening.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'music_b3',
      level: _b,
      titleVi: 'Buổi hoà nhạc',
      titleEn: 'The concert',
      sentences: [
        WritingSentence.of(
          'Tối qua tôi đã đi xem hoà nhạc.',
          'Last night I went to a concert.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Ca sĩ đã hát rất hay.',
          'The singer sang very well.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Mọi người đã nhảy và hát theo.',
          'Everyone danced and sang along.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Buổi hoà nhạc kết thúc lúc mười giờ.',
          'The concert ended at ten o\'clock.',
          G.pastSimple,
          alternatives: ['The concert finished at ten.'],
        ),
        WritingSentence.of(
          'Tôi đã rất vui.',
          'I had a great time.',
          G.pastSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'music_b4',
      level: _b,
      titleVi: 'Hát karaoke',
      titleEn: 'Karaoke night',
      sentences: [
        WritingSentence.of(
          'Gia đình tôi thích hát karaoke.',
          'My family likes singing karaoke.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tối nay chúng tôi định hát ở nhà.',
          'Tonight we are going to sing at home.',
          G.goingTo,
        ),
        WritingSentence.of(
          'Bố tôi sẽ hát một bài cũ.',
          'My father will sing an old song.',
          G.futureSimple,
          alternatives: ['My dad will sing an old song.'],
        ),
        WritingSentence.of(
          'Tôi sẽ hát một bài tiếng Anh.',
          'I will sing an English song.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Chúng tôi không nên hát quá to.',
          'We should not sing too loudly.',
          G.modal,
          alternatives: ['We shouldn\'t sing too loud.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'music_b5',
      level: _b,
      titleVi: 'Nhạc cụ',
      titleEn: 'Musical instruments',
      sentences: [
        WritingSentence.of(
          'Tôi có một cây đàn guitar.',
          'I have a guitar.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Bạn tôi có một cái trống.',
          'My friend has a drum.',
          G.presentSimple,
          alternatives: ['My friend has drums.'],
        ),
        WritingSentence.of(
          'Chúng tôi chơi nhạc cùng nhau.',
          'We play music together.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Chúng tôi muốn lập một ban nhạc.',
          'We want to start a band.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Chúng tôi cần một ca sĩ.',
          'We need a singer.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'music_b6',
      level: _b,
      titleVi: 'Nghe nhạc khi học',
      titleEn: 'Music while studying',
      sentences: [
        WritingSentence.of(
          'Tôi thường nghe nhạc khi học bài.',
          'I often listen to music when I study.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi thích nhạc nhẹ.',
          'I like soft music.',
          G.presentSimple,
          alternatives: ['I like light music.'],
        ),
        WritingSentence.of(
          'Bây giờ tôi đang nghe piano.',
          'Now I am listening to piano music.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Nó giúp tôi tập trung.',
          'It helps me focus.',
          G.presentSimple,
          alternatives: ['It helps me concentrate.'],
        ),
        WritingSentence.of(
          'Tôi không thể học với nhạc rock.',
          'I cannot study with rock music.',
          G.modal,
          alternatives: ['I can\'t study with rock music.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'music_b7',
      level: _b,
      titleVi: 'Văn nghệ ở trường',
      titleEn: 'The school show',
      sentences: [
        WritingSentence.of(
          'Tuần trước trường tôi có một buổi văn nghệ.',
          'Last week my school had a music show.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Lớp tôi đã hát một bài dân ca.',
          'My class sang a folk song.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã chơi đàn guitar.',
          'I played the guitar.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Lúc đầu tôi đã rất lo lắng.',
          'At first I was very nervous.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Nhưng mọi thứ đã rất tốt.',
          'But everything went very well.',
          G.pastSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'music_b8',
      level: _b,
      titleVi: 'Học tiếng Anh qua bài hát',
      titleEn: 'Learning English with songs',
      sentences: [
        WritingSentence.of(
          'Tôi học tiếng Anh qua bài hát.',
          'I learn English through songs.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi đọc lời bài hát khi nghe.',
          'I read the lyrics while I listen.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi học được nhiều từ mới mỗi tuần.',
          'I learn many new words every week.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tuần này, tôi định học ba bài hát.',
          'This week, I am going to learn three songs.',
          G.goingTo,
        ),
        WritingSentence.of(
          'Bạn cũng nên thử cách này.',
          'You should try this too.',
          G.modal,
        ),
      ],
    ),

    // ---------------- Trung cap ----------------
    WritingParagraph(
      id: 'music_i1',
      level: _i,
      titleVi: 'Ban nhạc của chúng tôi',
      titleEn: 'Our band',
      sentences: [
        WritingSentence.of(
          'Tôi và ba người bạn đã lập một ban nhạc được một năm.',
          'Three friends and I have had a band for a year.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Chúng tôi tập ở gara nhà tôi mỗi cuối tuần.',
          'We practice in my garage every weekend.',
          G.presentSimple,
          alternatives: ['We practise in my garage every weekend.'],
        ),
        WritingSentence.of(
          'Hầu hết các bài hát được viết bởi tay trống.',
          'Most of our songs are written by the drummer.',
          G.passive,
        ),
        WritingSentence.of(
          'Tuần trước, trong khi chúng tôi đang tập, hàng xóm sang phàn nàn.',
          'Last week, while we were practicing, a neighbor came to complain.',
          G.pastContinuous,
          alternatives: [
            'Last week, while we were practising, a neighbour came to complain.',
          ],
        ),
        WritingSentence.of(
          'Bây giờ chúng tôi chơi nhỏ hơn trước.',
          'Now we play more quietly than before.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu chúng tôi thắng cuộc thi, chúng tôi sẽ thu âm một album.',
          'If we win the contest, we will record an album.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'music_i2',
      level: _i,
      titleVi: 'Nhạc Trịnh',
      titleEn: 'Trinh Cong Son\'s music',
      sentences: [
        WritingSentence.of(
          'Trịnh Công Sơn là một trong những nhạc sĩ nổi tiếng nhất Việt Nam.',
          'Trinh Cong Son is one of the most famous Vietnamese songwriters.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nhạc của ông vẫn được hát khắp nơi.',
          'His songs are still sung everywhere.',
          G.passive,
        ),
        WritingSentence.of(
          'Bố tôi đã nghe nhạc Trịnh từ khi còn trẻ.',
          'My father has listened to his music since he was young.',
          G.presentPerfect,
          alternatives: [
            'My dad has listened to his music since he was young.',
          ],
        ),
        WritingSentence.of(
          'Tối qua, khi bố đang hát, cả nhà ngồi im lắng nghe.',
          'Last night, while Dad was singing, the whole family sat and listened quietly.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Lời bài hát của ông sâu sắc hơn nhiều bài hát bây giờ.',
          'His lyrics are deeper than many songs today.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu bạn muốn hiểu Việt Nam, bạn nên nghe nhạc của ông.',
          'If you want to understand Vietnam, you should listen to his music.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'music_i3',
      level: _i,
      titleVi: 'Lễ hội âm nhạc',
      titleEn: 'A music festival',
      sentences: [
        WritingSentence.of(
          'Tháng trước, tôi đã đi một lễ hội âm nhạc ở Đà Lạt.',
          'Last month, I went to a music festival in Da Lat.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Lễ hội năm nay đông hơn năm ngoái rất nhiều.',
          'This year\'s festival was much bigger than last year\'s.',
          G.comparison,
        ),
        WritingSentence.of(
          'Sân khấu được dựng giữa một đồi thông.',
          'The stage was built in the middle of a pine forest.',
          G.passive,
        ),
        WritingSentence.of(
          'Trong khi ban nhạc yêu thích của tôi đang biểu diễn, trời bắt đầu mưa.',
          'While my favorite band was playing, it started to rain.',
          G.pastContinuous,
          alternatives: [
            'While my favourite band was playing, it started to rain.',
          ],
        ),
        WritingSentence.of(
          'Tôi chưa bao giờ hát to như vậy.',
          'I have never sung so loudly.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu năm sau có lễ hội, tôi sẽ rủ bạn bè đi cùng.',
          'If there is a festival next year, I will bring my friends.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'music_i4',
      level: _i,
      titleVi: 'Nhạc cụ dân tộc',
      titleEn: 'Traditional instruments',
      sentences: [
        WritingSentence.of(
          'Đàn bầu là một nhạc cụ đặc biệt của Việt Nam.',
          'The dan bau is a special Vietnamese instrument.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Nó chỉ có một dây nhưng có thể tạo ra nhiều âm thanh.',
          'It has only one string, but it can make many sounds.',
          G.modal,
        ),
        WritingSentence.of(
          'Âm thanh của nó buồn hơn đàn guitar.',
          'Its sound is sadder than the guitar\'s.',
          G.comparison,
          alternatives: ['It sounds sadder than a guitar.'],
        ),
        WritingSentence.of(
          'Tôi đã học đàn bầu được sáu tháng.',
          'I have learned the dan bau for six months.',
          G.presentPerfect,
          alternatives: [
            'I have learnt the dan bau for six months.',
            'I have studied the dan bau for six months.',
          ],
        ),
        WritingSentence.of(
          'Nhiều nhạc cụ dân tộc đang được giới trẻ quan tâm trở lại.',
          'Many traditional instruments are being rediscovered by young people.',
          G.passive,
        ),
        WritingSentence.of(
          'Nếu tôi chơi giỏi, tôi sẽ biểu diễn cho khách du lịch.',
          'If I play well, I will perform for tourists.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'music_i5',
      level: _i,
      titleVi: 'Nghe nhạc trực tuyến',
      titleEn: 'Streaming music',
      sentences: [
        WritingSentence.of(
          'Ngày nay, hầu hết mọi người nghe nhạc trên điện thoại.',
          'Today, most people listen to music on their phones.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Nghe nhạc trực tuyến tiện hơn mua đĩa.',
          'Streaming music is more convenient than buying CDs.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tôi đã tạo hơn hai mươi danh sách phát.',
          'I have made more than twenty playlists.',
          G.presentPerfect,
          alternatives: ['I have created more than twenty playlists.'],
        ),
        WritingSentence.of(
          'Mỗi bài hát được gợi ý dựa trên sở thích của tôi.',
          'Every song is suggested based on my taste.',
          G.passive,
        ),
        WritingSentence.of(
          'Tối qua, khi tôi đang nghe nhạc, ứng dụng gợi ý một ca sĩ Hàn Quốc.',
          'Last night, while I was listening, the app suggested a Korean singer.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nếu thích anh ấy, tôi sẽ mua vé xem hoà nhạc.',
          'If I like him, I will buy a concert ticket.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'music_i6',
      level: _i,
      titleVi: 'Thi hát',
      titleEn: 'A singing contest',
      sentences: [
        WritingSentence.of(
          'Chị tôi vừa đăng ký một cuộc thi hát trên truyền hình.',
          'My sister has just signed up for a TV singing contest.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Chị ấy hát hay nhất trong gia đình tôi.',
          'She is the best singer in my family.',
          G.comparison,
        ),
        WritingSentence.of(
          'Các thí sinh được chấm điểm bởi bốn giám khảo.',
          'The contestants are judged by four judges.',
          G.passive,
        ),
        WritingSentence.of(
          'Trong khi chị ấy đang hát ở vòng một, micro bị hỏng.',
          'While she was singing in the first round, the microphone broke.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Chị ấy vẫn tiếp tục hát mà không dừng lại.',
          'She kept singing without stopping.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Nếu chị ấy vào chung kết, cả nhà sẽ đến xem.',
          'If she reaches the final, the whole family will come to watch.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'music_i7',
      level: _i,
      titleVi: 'Nghệ sĩ đường phố',
      titleEn: 'A street musician',
      sentences: [
        WritingSentence.of(
          'Có một nghệ sĩ đường phố hát ở phố đi bộ mỗi tối.',
          'A street musician sings on the walking street every evening.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Anh ấy đã hát ở đó được hai năm.',
          'He has sung there for two years.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Giọng hát của anh ấy hay hơn nhiều ca sĩ nổi tiếng.',
          'His voice is better than many famous singers\'.',
          G.comparison,
          alternatives: [
            'His voice is better than that of many famous singers.',
          ],
        ),
        WritingSentence.of(
          'Tối qua, khi anh ấy đang hát, một đám đông vây quanh.',
          'Last night, while he was singing, a crowd gathered around him.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Video của anh ấy được chia sẻ hàng nghìn lần.',
          'His video was shared thousands of times.',
          G.passive,
        ),
        WritingSentence.of(
          'Nếu có công ty ký hợp đồng, anh ấy sẽ trở thành ngôi sao.',
          'If a company signs him, he will become a star.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'music_i8',
      level: _i,
      titleVi: 'Nhạc và cảm xúc',
      titleEn: 'Music and feelings',
      sentences: [
        WritingSentence.of(
          'Âm nhạc có thể thay đổi tâm trạng của chúng ta.',
          'Music can change our mood.',
          G.modal,
        ),
        WritingSentence.of(
          'Khi buồn, tôi nghe những bài hát chậm hơn.',
          'When I am sad, I listen to slower songs.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tôi đã nghe bài hát này hàng trăm lần.',
          'I have listened to this song hundreds of times.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nó được viết bởi ca sĩ mà tôi yêu thích nhất.',
          'It was written by my favorite singer.',
          G.passive,
          alternatives: ['It was written by my favourite singer.'],
        ),
        WritingSentence.of(
          'Năm ngoái, khi tôi đang đợi cô ấy ký tên, tôi run đến mức làm rơi cây bút.',
          'Last year, while I was waiting for her autograph, I dropped my pen.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nếu gặp lại cô ấy, tôi sẽ nói lời cảm ơn.',
          'If I meet her again, I will thank her.',
          G.conditional1,
        ),
      ],
    ),

    // ---------------- Nang cao ----------------
    WritingParagraph(
      id: 'music_a1',
      level: _a,
      titleVi: 'Âm nhạc và trí nhớ',
      titleEn: 'Music and memory',
      sentences: [
        WritingSentence.of(
          'Các nhà khoa học đã phát hiện rằng âm nhạc có thể giúp bệnh nhân mất trí nhớ nhớ lại quá khứ.',
          'Scientists have found that music can help patients with memory loss recall the past.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Bà tôi, người không còn nhận ra con cháu, vẫn hát được những bài hát thời trẻ.',
          'My grandmother, who no longer recognizes her grandchildren, can still sing songs from her youth.',
          G.relativeClause,
          alternatives: [
            'My grandmother, who no longer recognises her grandchildren, can still sing songs from her youth.',
          ],
        ),
        WritingSentence.of(
          'Chúng tôi đã mở nhạc cho bà nghe mỗi tối suốt ba tháng qua.',
          'We have been playing music for her every evening for the past three months.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Bác sĩ nói rằng âm nhạc giúp bà bình tĩnh hơn bất kỳ loại thuốc nào.',
          'The doctor said that music calmed her better than any medicine.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu chúng tôi biết điều này sớm hơn, bà đã bớt lo âu trong những năm qua.',
          'If we had known this earlier, she would have been less anxious over the past years.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Tôi đang ghi âm lại những bài hát bà thích để giữ làm kỷ niệm.',
          'I am recording the songs she loves to keep as a memory.',
          G.presentContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'music_a2',
      level: _a,
      titleVi: 'Bản quyền âm nhạc',
      titleEn: 'Music copyright',
      sentences: [
        WritingSentence.of(
          'Nhiều nhạc sĩ trẻ không được trả tiền khi bài hát của họ bị dùng trái phép.',
          'Many young songwriters are not paid when their songs are used illegally.',
          G.passive,
        ),
        WritingSentence.of(
          'Bạn tôi, người viết nhạc cho quảng cáo, từng phát hiện bài hát của mình trong một bộ phim.',
          'My friend, who writes music for adverts, once found her song in a film.',
          G.relativeClause,
          alternatives: [
            'My friend, who writes music for ads, once found her song in a movie.',
          ],
        ),
        WritingSentence.of(
          'Công ty sản xuất đã dùng bài hát suốt nhiều tháng trước khi cô ấy biết.',
          'The production company had been using the song for months before she found out.',
          G.pastPerfectContinuous,
        ),
        WritingSentence.of(
          'Luật sư của cô ấy nói rằng họ phải bồi thường cho cô.',
          'Her lawyer said that they had to pay her compensation.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu cô ấy không đăng ký bản quyền, cô đã không thể đòi lại quyền lợi.',
          'If she had not registered the copyright, she could not have won the case.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Các nền tảng nghe nhạc đã và đang dùng công nghệ để phát hiện vi phạm bản quyền.',
          'Streaming platforms have been using technology to detect copyright violations.',
          G.presentPerfectContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'music_a3',
      level: _a,
      titleVi: 'Hành trình của một ca sĩ',
      titleEn: 'A singer\'s journey',
      sentences: [
        WritingSentence.of(
          'Ca sĩ mà tôi yêu thích nhất bắt đầu sự nghiệp bằng cách hát ở các quán cà phê nhỏ.',
          'The singer I like most started her career by singing in small coffee shops.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Cô ấy đã hát ở đó suốt năm năm trước khi được một nhà sản xuất phát hiện.',
          'She had been singing there for five years before a producer discovered her.',
          G.pastPerfectContinuous,
        ),
        WritingSentence.of(
          'Trong một bài phỏng vấn, cô kể rằng cô từng muốn bỏ nghề nhiều lần.',
          'In an interview, she said that she had wanted to quit many times.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu cô ấy bỏ cuộc, chúng ta đã không có những bài hát tuyệt vời như bây giờ.',
          'If she had given up, we would never have had her wonderful songs.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Album mới nhất của cô đã được nghe hơn một trăm triệu lần.',
          'Her latest album has been streamed more than a hundred million times.',
          G.passive,
        ),
        WritingSentence.of(
          'Vào giờ này tháng sau, cô ấy sẽ đang lưu diễn ở châu Âu.',
          'This time next month, she will be touring Europe.',
          G.futureContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'music_a4',
      level: _a,
      titleVi: 'Âm nhạc truyền thống và giới trẻ',
      titleEn: 'Young people and traditional music',
      sentences: [
        WritingSentence.of(
          'Ca trù, một loại hình nghệ thuật có từ hàng trăm năm trước, từng có nguy cơ biến mất.',
          'Ca tru, which is an art form that is hundreds of years old, was once in danger of disappearing.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Trước khi được UNESCO công nhận, rất ít người trẻ biết đến ca trù.',
          'Before UNESCO recognized it, very few young people had heard of ca tru.',
          G.pastPerfect,
          alternatives: [
            'Before UNESCO recognised it, very few young people had heard of ca tru.',
          ],
        ),
        WritingSentence.of(
          'Một nghệ nhân lớn tuổi nói với tôi rằng bà đã dạy ca trù miễn phí suốt ba mươi năm.',
          'An elderly artist told me that she had taught ca tru for free for thirty years.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Gần đây, một số nghệ sĩ trẻ đã và đang kết hợp ca trù với nhạc điện tử.',
          'Recently, some young artists have been mixing ca tru with electronic music.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Nếu nhạc truyền thống được dạy ở trường, nhiều bạn trẻ sẽ yêu thích nó hơn.',
          'If traditional music were taught at school, more young people would love it.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Tôi tin rằng những loại hình này sẽ tiếp tục sống nếu chúng biết thay đổi.',
          'I believe these art forms will survive if they are willing to change.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'music_a5',
      level: _a,
      titleVi: 'Học sản xuất âm nhạc',
      titleEn: 'Learning music production',
      sentences: [
        WritingSentence.of(
          'Anh trai tôi, người chưa từng học nhạc chính quy, tự học sản xuất âm nhạc qua mạng.',
          'My brother, who never studied music formally, taught himself music production online.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Anh ấy đã làm nhạc trong phòng ngủ suốt hai năm qua.',
          'He has been making music in his bedroom for the past two years.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Khi bài hát đầu tiên của anh được phát hành, anh đã viết lại nó hơn hai mươi lần.',
          'By the time his first song was released, he had rewritten it more than twenty times.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Một nhà sản xuất nổi tiếng khuyên anh rằng anh nên tìm phong cách riêng.',
          'A famous producer advised him that he should find his own style.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu anh ấy có một phòng thu chuyên nghiệp, chất lượng âm thanh sẽ tốt hơn nhiều.',
          'If he had a professional studio, the sound quality would be much better.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Đến cuối năm, anh ấy sẽ phát hành xong album đầu tay.',
          'By the end of the year, he will have released his first album.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'music_a6',
      level: _a,
      titleVi: 'Âm nhạc chữa lành',
      titleEn: 'Music therapy',
      sentences: [
        WritingSentence.of(
          'Liệu pháp âm nhạc, vốn phổ biến ở nhiều nước, đang dần được biết đến ở Việt Nam.',
          'Music therapy, which is common in many countries, is slowly becoming known in Vietnam.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Cô tôi đã làm chuyên viên trị liệu âm nhạc tại một bệnh viện nhi được năm năm.',
          'My aunt has been working as a music therapist at a children\'s hospital for five years.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Cô kể rằng một cậu bé đã nói những từ đầu tiên sau nhiều tháng hát cùng cô.',
          'She told me that a little boy had spoken his first words after months of singing with her.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Trước khi đến với nghề này, cô đã từng là giáo viên piano.',
          'Before she started this job, she had been a piano teacher.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Nếu có thêm chuyên viên như cô, nhiều bệnh nhân sẽ được giúp đỡ.',
          'If there were more therapists like her, many more patients could be helped.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Năm sau, cô sẽ đang đào tạo nhóm chuyên viên đầu tiên của bệnh viện.',
          'Next year, she will be training the hospital\'s first team of therapists.',
          G.futureContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'music_a7',
      level: _a,
      titleVi: 'Nhạc sống hay nhạc thu âm',
      titleEn: 'Live or recorded',
      sentences: [
        WritingSentence.of(
          'Nhiều người cho rằng nghe nhạc sống mang lại cảm xúc mà bản thu âm không thể có.',
          'Many people believe that live music gives feelings that recordings cannot.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Buổi hoà nhạc đầu tiên mà tôi xem đã thay đổi cách tôi nghe nhạc.',
          'The first concert that I went to changed the way I listen to music.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Trước đó, tôi chỉ nghe nhạc qua tai nghe rẻ tiền.',
          'Before that, I had only listened to music through cheap headphones.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Bạn tôi hỏi liệu giá vé đắt như vậy có đáng không.',
          'My friend asked me whether such expensive tickets were worth it.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu vé rẻ hơn, tôi sẽ đi xem hoà nhạc mỗi tháng.',
          'If tickets were cheaper, I would go to a concert every month.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Tôi đã tiết kiệm tiền cho buổi diễn tiếp theo từ đầu năm.',
          'I have been saving for the next concert since the beginning of the year.',
          G.presentPerfectContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'music_a8',
      level: _a,
      titleVi: 'Âm nhạc kết nối',
      titleEn: 'Music brings people together',
      sentences: [
        WritingSentence.of(
          'Khi tôi du học ở Canada, âm nhạc là thứ giúp tôi kết bạn nhanh nhất.',
          'When I studied in Canada, music was what helped me make friends fastest.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tôi gia nhập một dàn hợp xướng mà các thành viên đến từ hơn mười quốc gia.',
          'I joined a choir whose members came from more than ten countries.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Chúng tôi đã tập suốt ba tháng khi được mời hát ở một lễ hội lớn.',
          'We had been rehearsing for three months when we were invited to sing at a big festival.',
          G.pastPerfectContinuous,
        ),
        WritingSentence.of(
          'Người chỉ huy nói rằng giọng hát của chúng tôi hoà quyện như một gia đình.',
          'The conductor said that our voices blended like a family.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu tôi không tham gia dàn hợp xướng, có lẽ tôi đã cảm thấy rất cô đơn.',
          'If I had not joined the choir, I might have felt very lonely.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Mùa hè này, các bạn ấy sẽ đến Việt Nam thăm tôi.',
          'This summer, they are going to visit me in Vietnam.',
          G.goingTo,
        ),
      ],
    ),
  ],
);

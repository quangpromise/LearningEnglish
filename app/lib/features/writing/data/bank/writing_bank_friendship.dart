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

const kWritingBankFriendship = WritingTopic(
  id: 'friendship',
  titleVi: 'Bạn bè',
  titleEn: 'Friendship',
  icon: Icons.diversity_3_rounded,
  color: AppColors.blue,
  paragraphs: [
    // ---------------- Co ban ----------------
    WritingParagraph(
      id: 'friendship_b1',
      level: _b,
      titleVi: 'Bạn thân của tôi',
      titleEn: 'My best friend',
      sentences: [
        WritingSentence.of(
          'Tôi có một bạn thân.',
          'I have a best friend.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Cô ấy học cùng lớp với tôi.',
          'She is in my class.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Chúng tôi chơi cùng nhau mỗi ngày.',
          'We play together every day.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Cô ấy rất tốt bụng.',
          'She is very kind.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi rất yêu quý cô ấy.',
          'I love her very much.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'friendship_b2',
      level: _b,
      titleVi: 'Chơi cùng nhau',
      titleEn: 'Playing together',
      sentences: [
        WritingSentence.of(
          'Bây giờ tôi đang chơi với bạn.',
          'Now I am playing with my friend.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Chúng tôi đang chơi cờ.',
          'We are playing chess.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Cậu ấy đang thắng.',
          'He is winning.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Tôi có thể chơi giỏi hơn lần sau.',
          'I can play better next time.',
          G.modal,
        ),
        WritingSentence.of(
          'Chúng tôi sẽ chơi lại vào ngày mai.',
          'We will play again tomorrow.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'friendship_b3',
      level: _b,
      titleVi: 'Bạn mới',
      titleEn: 'A new friend',
      sentences: [
        WritingSentence.of(
          'Hôm qua tôi đã gặp một người bạn mới.',
          'Yesterday I met a new friend.',
          G.pastSimple,
          alternatives: ['I met a new friend yesterday.'],
        ),
        WritingSentence.of(
          'Cậu ấy vừa chuyển đến lớp tôi.',
          'He just moved to my class.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Chúng tôi đã nói chuyện suốt giờ ra chơi.',
          'We talked all through break time.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã mời cậu ấy về nhà chơi.',
          'I invited him to my house.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Chúng tôi đã trở thành bạn tốt.',
          'We became good friends.',
          G.pastSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'friendship_b4',
      level: _b,
      titleVi: 'Cãi nhau với bạn',
      titleEn: 'A fight with a friend',
      sentences: [
        WritingSentence.of(
          'Tuần trước tôi đã cãi nhau với bạn thân.',
          'Last week I had a fight with my best friend.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Chúng tôi đã không nói chuyện với nhau ba ngày.',
          'We did not talk to each other for three days.',
          G.pastSimple,
          alternatives: ['We didn\'t talk to each other for three days.'],
        ),
        WritingSentence.of(
          'Tôi đã cảm thấy rất buồn.',
          'I felt very sad.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã xin lỗi cô ấy trước.',
          'I said sorry to her first.',
          G.pastSimple,
          alternatives: ['I apologized to her first.'],
        ),
        WritingSentence.of(
          'Chúng tôi đã làm hoà.',
          'We made up.',
          G.pastSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'friendship_b5',
      level: _b,
      titleVi: 'Sinh nhật bạn',
      titleEn: 'My friend\'s birthday',
      sentences: [
        WritingSentence.of(
          'Ngày mai là sinh nhật bạn tôi.',
          'Tomorrow is my friend\'s birthday.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi định mua một món quà.',
          'I am going to buy a present.',
          G.goingTo,
          alternatives: ['I am going to buy a gift.'],
        ),
        WritingSentence.of(
          'Tôi sẽ viết một tấm thiệp.',
          'I will write a card.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Chúng tôi sẽ ăn bánh cùng nhau.',
          'We will eat cake together.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Cậu ấy sẽ rất vui.',
          'He will be very happy.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'friendship_b6',
      level: _b,
      titleVi: 'Giúp đỡ bạn bè',
      titleEn: 'Helping a friend',
      sentences: [
        WritingSentence.of(
          'Bạn tôi đang gặp khó khăn với bài tập.',
          'My friend is having trouble with her homework.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Tôi có thể giúp cô ấy.',
          'I can help her.',
          G.modal,
        ),
        WritingSentence.of(
          'Chúng ta nên giúp đỡ bạn bè.',
          'We should help our friends.',
          G.modal,
        ),
        WritingSentence.of(
          'Tối nay tôi sẽ gọi điện cho cô ấy.',
          'Tonight I will call her.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Chúng tôi sẽ học cùng nhau.',
          'We will study together.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'friendship_b7',
      level: _b,
      titleVi: 'Người bạn ở xa',
      titleEn: 'A faraway friend',
      sentences: [
        WritingSentence.of(
          'Bạn thân của tôi đã chuyển đi thành phố khác.',
          'My best friend moved to another city.',
          G.pastSimple,
        ),
        WritingSentence.of('Tôi đã rất buồn.', 'I was very sad.', G.pastSimple),
        WritingSentence.of(
          'Bây giờ chúng tôi đang nhắn tin cho nhau.',
          'Now we are texting each other.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Chúng tôi gọi video mỗi tuần.',
          'We video call every week.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Mùa hè này, tôi sẽ đến thăm cậu ấy.',
          'This summer, I will visit him.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'friendship_b8',
      level: _b,
      titleVi: 'Nhóm bạn thân',
      titleEn: 'A group of friends',
      sentences: [
        WritingSentence.of(
          'Tôi có ba người bạn thân.',
          'I have three best friends.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Chúng tôi luôn đi học cùng nhau.',
          'We always go to school together.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Chúng tôi ăn trưa cùng bàn.',
          'We eat lunch at the same table.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Chúng tôi có thể kể mọi bí mật cho nhau.',
          'We can tell each other every secret.',
          G.modal,
        ),
        WritingSentence.of(
          'Tôi rất may mắn có họ.',
          'I am very lucky to have them.',
          G.presentSimple,
        ),
      ],
    ),

    // ---------------- Trung cap ----------------
    WritingParagraph(
      id: 'friendship_i1',
      level: _i,
      titleVi: 'Bạn từ thời mẫu giáo',
      titleEn: 'A friend since kindergarten',
      sentences: [
        WritingSentence.of(
          'Tôi và Lan đã là bạn từ khi còn học mẫu giáo.',
          'Lan and I have been friends since kindergarten.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Chúng tôi biết nhau lâu hơn bất kỳ ai khác trong lớp.',
          'We have known each other longer than anyone else in class.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nhiều bí mật của tôi chỉ được kể cho cô ấy.',
          'Many of my secrets are only shared with her.',
          G.passive,
        ),
        WritingSentence.of(
          'Năm ngoái, trong khi chúng tôi đang học chung, cô ấy giúp tôi hiểu bài toán khó.',
          'Last year, while we were studying together, she helped me understand a hard math problem.',
          G.pastContinuous,
          alternatives: [
            'Last year, while we were studying together, she helped me understand a hard maths problem.',
          ],
        ),
        WritingSentence.of(
          'Tình bạn của chúng tôi bền hơn tôi tưởng.',
          'Our friendship is stronger than I thought.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu chúng tôi học khác trường, tôi sẽ vẫn giữ liên lạc.',
          'If we go to different schools, I will still keep in touch.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'friendship_i2',
      level: _i,
      titleVi: 'Bạn bè trên mạng',
      titleEn: 'Online friends',
      sentences: [
        WritingSentence.of(
          'Tôi đã quen một người bạn qua một trò chơi trực tuyến.',
          'I have made a friend through an online game.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Chúng tôi chưa bao giờ gặp nhau ngoài đời.',
          'We have never met in person.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Cậu ấy sống ở một nước khác được tôi biết qua trò chuyện.',
          'I learned that he lives in another country through our chats.',
          G.pastSimple,
          alternatives: [
            'I learnt that he lives in another country through our chats.',
          ],
        ),
        WritingSentence.of(
          'Tối qua, trong khi chúng tôi đang chơi, mạng của tôi bị mất.',
          'Last night, while we were playing, my internet went down.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tình bạn trên mạng khác tình bạn ngoài đời.',
          'Online friendship is different from real-life friendship.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu có dịp, tôi sẽ gặp cậu ấy ngoài đời.',
          'If I get the chance, I will meet him in person.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'friendship_i3',
      level: _i,
      titleVi: 'Xin lỗi bạn',
      titleEn: 'Apologizing to a friend',
      sentences: [
        WritingSentence.of(
          'Tuần trước, tôi đã nói điều gì đó khiến bạn tôi buồn.',
          'Last week, I said something that hurt my friend\'s feelings.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Cô ấy đã không nhắn tin cho tôi suốt hai ngày.',
          'She did not text me for two days.',
          G.pastSimple,
          alternatives: ['She didn\'t text me for two days.'],
        ),
        WritingSentence.of(
          'Trong khi tôi đang viết tin nhắn xin lỗi, tôi đã xoá đi viết lại ba lần.',
          'While I was writing an apology message, I deleted and rewrote it three times.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Cuối cùng, lời xin lỗi được cô ấy chấp nhận.',
          'In the end, my apology was accepted by her.',
          G.passive,
        ),
        WritingSentence.of(
          'Tình bạn của chúng tôi đã trở nên bền chặt hơn sau đó.',
          'Our friendship has become stronger since then.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu tôi làm sai lần nữa, tôi sẽ xin lỗi ngay lập tức.',
          'If I make a mistake again, I will apologize right away.',
          G.conditional1,
          alternatives: [
            'If I make a mistake again, I will apologise right away.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'friendship_i4',
      level: _i,
      titleVi: 'Bạn cùng phòng',
      titleEn: 'My roommate',
      sentences: [
        WritingSentence.of(
          'Tôi đã sống cùng bạn cùng phòng được một học kỳ.',
          'I have lived with my roommate for one semester.',
          G.presentPerfect,
          alternatives: ['I have lived with my roommate for a term.'],
        ),
        WritingSentence.of(
          'Lúc đầu, chúng tôi khác nhau hơn tôi nghĩ.',
          'At first, we were more different than I thought.',
          G.comparison,
        ),
        WritingSentence.of(
          'Phòng luôn được dọn dẹp bởi cả hai chúng tôi.',
          'The room is always cleaned by both of us.',
          G.passive,
        ),
        WritingSentence.of(
          'Tuần trước, trong khi tôi đang ngủ, cậu ấy học bài đến rất khuya.',
          'Last week, while I was sleeping, he studied very late.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Giờ chúng tôi hiểu nhau hơn nhiều.',
          'Now we understand each other much better.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu năm sau khác lớp, chúng tôi vẫn sẽ ăn trưa cùng nhau.',
          'If we are in different classes next year, we will still have lunch together.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'friendship_i5',
      level: _i,
      titleVi: 'Bạn tốt trong lúc khó khăn',
      titleEn: 'A friend in need',
      sentences: [
        WritingSentence.of(
          'Năm ngoái, tôi bị ốm nặng và phải nghỉ học một tuần.',
          'Last year, I was seriously ill and had to miss school for a week.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Bài vở của tôi được bạn thân chép hộ.',
          'My lessons were copied for me by my best friend.',
          G.passive,
        ),
        WritingSentence.of(
          'Cô ấy đã đến thăm tôi mỗi ngày sau giờ học.',
          'She visited me every day after school.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Trong khi tôi đang nằm nghỉ, cô ấy đọc truyện cho tôi nghe.',
          'While I was resting, she read stories to me.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi chưa bao giờ có một người bạn tốt như vậy.',
          'I have never had such a good friend.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu cô ấy cần tôi, tôi sẽ luôn ở bên cạnh.',
          'If she needs me, I will always be there for her.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'friendship_i6',
      level: _i,
      titleVi: 'Kết bạn ở môi trường mới',
      titleEn: 'Making friends in a new place',
      sentences: [
        WritingSentence.of(
          'Khi tôi chuyển đến thành phố mới, tôi không quen ai cả.',
          'When I moved to a new city, I did not know anyone.',
          G.pastSimple,
          alternatives: ['When I moved to a new city, I didn\'t know anyone.'],
        ),
        WritingSentence.of(
          'Kết bạn ở đây khó hơn tôi tưởng.',
          'Making friends here was harder than I expected.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tôi được một người bạn cùng lớp mời đi ăn trưa.',
          'I was invited to lunch by a classmate.',
          G.passive,
        ),
        WritingSentence.of(
          'Trong khi chúng tôi đang ăn, chúng tôi phát hiện có nhiều sở thích chung.',
          'While we were eating, we found out that we had a lot in common.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Từ đó, chúng tôi đã trở thành bạn thân.',
          'Since then, we have become close friends.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu bạn mới đến một nơi, bạn nên chủ động bắt chuyện.',
          'If you are new somewhere, you should start conversations yourself.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'friendship_i7',
      level: _i,
      titleVi: 'Ghen tị với bạn',
      titleEn: 'Feeling jealous of a friend',
      sentences: [
        WritingSentence.of(
          'Tuần trước, bạn tôi đã đạt điểm cao hơn tôi trong kỳ thi.',
          'Last week, my friend got a higher score than me on the exam.',
          G.comparison,
        ),
        WritingSentence.of(
          'Lúc đầu, tôi đã cảm thấy hơi ghen tị.',
          'At first, I felt a little jealous.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Trong khi tôi đang buồn, cô ấy đề nghị giúp tôi ôn tập.',
          'While I was feeling sad, she offered to help me study.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi đã nhận ra rằng ghen tị không giúp ích được gì.',
          'I have realized that jealousy does not help at all.',
          G.presentPerfect,
          alternatives: ['I have realised that jealousy does not help at all.'],
        ),
        WritingSentence.of(
          'Bây giờ chúng tôi học cùng nhau nhiều hơn.',
          'Now we study together more than before.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu tôi cảm thấy ghen tị lần nữa, tôi sẽ nói chuyện thẳng thắn với cô ấy.',
          'If I feel jealous again, I will talk to her honestly.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'friendship_i8',
      level: _i,
      titleVi: 'Tình bạn giữa các thế hệ',
      titleEn: 'Friends of different ages',
      sentences: [
        WritingSentence.of(
          'Tôi có một người bạn già hơn tôi ba mươi tuổi.',
          'I have a friend who is thirty years older than me.',
          G.comparison,
        ),
        WritingSentence.of(
          'Chúng tôi đã quen nhau tại một câu lạc bộ làm vườn.',
          'We met each other at a gardening club.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Ông ấy dạy tôi trồng rau, còn tôi dạy ông dùng điện thoại.',
          'He teaches me gardening, and I teach him how to use his phone.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Hôm qua, trong khi chúng tôi đang tưới cây, ông kể về thời trẻ của mình.',
          'Yesterday, while we were watering the plants, he told me about his youth.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Ông ấy là người kiên nhẫn nhất tôi từng gặp.',
          'He is the most patient person I have ever met.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu ông cần giúp đỡ, tôi sẽ luôn đến ngay.',
          'If he needs help, I will always come right away.',
          G.conditional1,
        ),
      ],
    ),

    // ---------------- Nang cao ----------------
    WritingParagraph(
      id: 'friendship_a1',
      level: _a,
      titleVi: 'Người bạn thay đổi cuộc đời tôi',
      titleEn: 'A friend who changed my life',
      sentences: [
        WritingSentence.of(
          'Bạn cùng lớp, người từng ngồi cạnh tôi vào năm lớp mười, đã hoàn toàn thay đổi cách tôi nhìn về tương lai.',
          'The classmate who sat next to me in tenth grade completely changed the way I saw my future.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Trước khi gặp cậu ấy, tôi chưa từng nghĩ mình có thể học đại học.',
          'Before I met him, I had never thought I could go to university.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Cậu ấy nói với tôi rằng xuất thân không quyết định được tương lai của một người.',
          'He told me that where you came from did not decide your future.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu tôi không có người bạn đó, có lẽ tôi đã bỏ học từ năm lớp mười một.',
          'If I had not had that friend, I might have dropped out in eleventh grade.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Chúng tôi đã giữ liên lạc suốt mười năm dù học ở hai trường đại học khác nhau.',
          'We have kept in touch for ten years despite studying at different universities.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Đến khi cả hai tốt nghiệp, chúng tôi sẽ đã là bạn được mười lăm năm.',
          'By the time we both graduate, we will have been friends for fifteen years.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'friendship_a2',
      level: _a,
      titleVi: 'Xa cách vì công việc',
      titleEn: 'Drifting apart',
      sentences: [
        WritingSentence.of(
          'Từ khi bắt đầu công việc mới, tôi đã dần xa cách với những người bạn cũ.',
          'Since starting my new job, I have gradually drifted apart from my old friends.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Chúng tôi từng gặp nhau mỗi tuần, nhưng giờ chỉ nhắn tin thỉnh thoảng.',
          'We used to meet every week, but now we only text occasionally.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Một người bạn nói với tôi rằng cô ấy cảm thấy tôi đã thay đổi.',
          'One friend told me that she felt I had changed.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Trước khi nghe câu đó, tôi chưa từng nhận ra mình xao nhãng bạn bè đến vậy.',
          'Before I heard that, I had never realized how much I had neglected my friends.',
          G.pastPerfect,
          alternatives: [
            'Before I heard that, I had never realised how much I had neglected my friends.',
          ],
        ),
        WritingSentence.of(
          'Nếu tôi sắp xếp thời gian tốt hơn, tình bạn của chúng tôi sẽ không phai nhạt.',
          'If I managed my time better, our friendships would not fade.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Kể từ đó, tôi đã cố gắng gặp bạn bè ít nhất một lần mỗi tháng.',
          'Since then, I have been trying to meet my friends at least once a month.',
          G.presentPerfectContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'friendship_a3',
      level: _a,
      titleVi: 'Tình bạn xuyên biên giới',
      titleEn: 'A friendship across borders',
      sentences: [
        WritingSentence.of(
          'Tôi gặp Sarah, người sau này trở thành bạn thân nhất của tôi, trong một chương trình trao đổi sinh viên.',
          'I met Sarah, who later became my closest friend, on a student exchange program.',
          G.relativeClause,
          alternatives: [
            'I met Sarah, who later became my closest friend, on a student exchange programme.',
          ],
        ),
        WritingSentence.of(
          'Chúng tôi đã sống cùng phòng ký túc xá suốt một học kỳ.',
          'We had lived in the same dorm room for a whole semester.',
          G.pastPerfect,
          alternatives: [
            'We had lived in the same dormitory room for a whole term.',
          ],
        ),
        WritingSentence.of(
          'Cô ấy hứa rằng chúng tôi sẽ gặp lại nhau, dù ở bất cứ đâu trên thế giới.',
          'She promised that we would meet again, wherever we were in the world.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu không có mạng xã hội, có lẽ chúng tôi đã mất liên lạc từ lâu.',
          'If it were not for social media, we might have lost touch long ago.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Chúng tôi đã đến thăm nhau ba lần trong năm năm qua.',
          'We have visited each other three times in the past five years.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Mùa hè năm sau, chúng tôi sẽ đang đi du lịch cùng nhau ở châu Âu.',
          'Next summer, we will be traveling together in Europe.',
          G.futureContinuous,
          alternatives: [
            'Next summer, we will be travelling together in Europe.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'friendship_a4',
      level: _a,
      titleVi: 'Khi tình bạn kết thúc',
      titleEn: 'The end of a friendship',
      sentences: [
        WritingSentence.of(
          'Một trong những điều khó nhất tôi từng trải qua là chấm dứt một tình bạn kéo dài mười năm.',
          'One of the hardest things I have ever experienced was ending a ten year friendship.',
          G.comparison,
          alternatives: [
            'One of the hardest things I have ever experienced was ending a ten-year friendship.',
          ],
        ),
        WritingSentence.of(
          'Chúng tôi đã dần xa cách suốt hai năm trước khi nói ra sự thật.',
          'We had been drifting apart for two years before we admitted the truth.',
          G.pastPerfectContinuous,
        ),
        WritingSentence.of(
          'Cô ấy nói rằng cô cũng đã cảm thấy điều tương tự từ lâu.',
          'She said that she had felt the same way for a long time too.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu chúng tôi nói chuyện thẳng thắn hơn từ đầu, có lẽ mọi thứ đã khác.',
          'If we had communicated more honestly from the start, things might have been different.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Dù buồn, tôi vẫn biết ơn những kỷ niệm mà chúng tôi từng chia sẻ.',
          'Although I was sad, I was still grateful for the memories we had shared.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Đôi khi, để một tình bạn kết thúc lại là điều tốt nhất cho cả hai người.',
          'Sometimes, letting a friendship end is the best thing for both people.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'friendship_a5',
      level: _a,
      titleVi: 'Bạn tốt trong khủng hoảng',
      titleEn: 'A friend in a crisis',
      sentences: [
        WritingSentence.of(
          'Khi công ty tôi phá sản, hầu hết người quen đều tránh mặt tôi.',
          'When my company went bankrupt, most people I knew avoided me.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Một người bạn đại học, người tôi đã không gặp suốt nhiều năm, bất ngờ gọi điện hỏi thăm.',
          'A university friend, whom I had not seen for years, unexpectedly called to check on me.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Cậu ấy nói rằng cậu đã từng trải qua điều tương tự và hiểu cảm giác của tôi.',
          'He said that he had once gone through the same thing and understood how I felt.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu cậu ấy không gọi hôm đó, có lẽ tôi đã chìm sâu hơn trong tuyệt vọng.',
          'If he had not called that day, I might have sunk deeper into despair.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Kể từ đó, chúng tôi đã trở nên thân thiết hơn bất kỳ ai khác trong nhóm bạn cũ.',
          'Since then, we have become closer than anyone else in our old group of friends.',
          G.comparison,
        ),
        WritingSentence.of(
          'Trải nghiệm đó đã dạy tôi rằng bạn thật sự được nhận ra trong lúc khó khăn.',
          'That experience taught me that true friends are revealed in hard times.',
          G.passive,
        ),
      ],
    ),
    WritingParagraph(
      id: 'friendship_a6',
      level: _a,
      titleVi: 'Tình bạn nơi công sở',
      titleEn: 'Friendship at work',
      sentences: [
        WritingSentence.of(
          'Nhiều chuyên gia tranh luận về việc liệu đồng nghiệp có thể trở thành bạn thân thật sự hay không.',
          'Many experts debate whether colleagues can become truly close friends.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi và một đồng nghiệp, người từng cạnh tranh với tôi cho cùng một vị trí, giờ là bạn thân nhất của nhau.',
          'A colleague, who once competed with me for the same position, and I are now each other\'s closest friend.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Trước khi trở thành bạn, chúng tôi đã tránh nói chuyện với nhau suốt nhiều tháng.',
          'Before we became friends, we had avoided talking to each other for months.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Cô ấy thừa nhận rằng cô đã từng ghen tị với tôi.',
          'She admitted that she had once been jealous of me.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu chúng tôi tiếp tục coi nhau là đối thủ, cả hai đã bỏ lỡ một tình bạn quý giá.',
          'If we had kept seeing each other as rivals, we would both have missed out on a valuable friendship.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Đến khi một trong hai chuyển việc, tôi tin tình bạn này vẫn sẽ tiếp tục.',
          'By the time either of us changes jobs, I believe this friendship will still continue.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'friendship_a7',
      level: _a,
      titleVi: 'Bạn thời thơ ấu gặp lại',
      titleEn: 'A childhood friend reunited',
      sentences: [
        WritingSentence.of(
          'Sau hai mươi năm, tôi tình cờ gặp lại người bạn thân nhất thời thơ ấu tại một hội chợ sách.',
          'After twenty years, I ran into my closest childhood friend by chance at a book fair.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Chúng tôi đã không gặp nhau kể từ khi gia đình cậu ấy chuyển đi.',
          'We had not seen each other since his family moved away.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Cậu ấy hầu như không thay đổi so với những gì tôi nhớ.',
          'He had hardly changed from what I remembered.',
          G.comparison,
        ),
        WritingSentence.of(
          'Trong khi chúng tôi đang uống cà phê, chúng tôi nhớ lại hàng chục kỷ niệm cũ.',
          'While we were having coffee, we recalled dozens of old memories.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Cậu ấy nói rằng cậu vẫn giữ một bức thư tôi từng viết hồi lớp năm.',
          'He said that he had kept a letter I had written back in fifth grade.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu chúng tôi không gặp lại nhau hôm đó, tình bạn này có lẽ đã mãi mãi bị lãng quên.',
          'If we had not met again that day, this friendship might have been forgotten forever.',
          G.conditional3,
        ),
      ],
    ),
    WritingParagraph(
      id: 'friendship_a8',
      level: _a,
      titleVi: 'Ý nghĩa thật sự của tình bạn',
      titleEn: 'What friendship really means',
      sentences: [
        WritingSentence.of(
          'Khi còn nhỏ, tôi nghĩ tình bạn có nghĩa là làm mọi thứ giống nhau.',
          'As a child, I thought friendship meant doing everything the same way.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Bây giờ tôi hiểu rằng những người bạn tốt nhất là những người thách thức tôi trở nên tốt hơn.',
          'Now I understand that the best friends are those who challenge me to become better.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Người bạn tôi tôn trọng nhất chưa bao giờ ngại nói với tôi những điều tôi không muốn nghe.',
          'The friend I respect most has never been afraid to tell me things I do not want to hear.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Nếu bạn bè lúc nào cũng đồng ý với tôi, tôi sẽ không bao giờ trưởng thành.',
          'If my friends always agreed with me, I would never grow.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Qua nhiều năm, tôi đã học được rằng tình bạn thật sự cần cả sự trung thực lẫn lòng kiên nhẫn.',
          'Over the years, I have learned that real friendship needs both honesty and patience.',
          G.presentPerfect,
          alternatives: [
            'Over the years, I have learnt that real friendship needs both honesty and patience.',
          ],
        ),
        WritingSentence.of(
          'Tôi hy vọng mình sẽ tiếp tục học hỏi từ những người bạn xung quanh suốt cả cuộc đời.',
          'I hope I will continue learning from the friends around me for my whole life.',
          G.futureSimple,
        ),
      ],
    ),
  ],
);

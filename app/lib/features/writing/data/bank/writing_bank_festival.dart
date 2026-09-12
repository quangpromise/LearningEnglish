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

const kWritingBankFestival = WritingTopic(
  id: 'festival',
  titleVi: 'Lễ hội',
  titleEn: 'Festivals',
  icon: Icons.celebration_rounded,
  color: AppColors.pink,
  paragraphs: [
    // ---------------- Co ban ----------------
    WritingParagraph(
      id: 'festival_b1',
      level: _b,
      titleVi: 'Tết Nguyên Đán',
      titleEn: 'Lunar New Year',
      sentences: [
        WritingSentence.of(
          'Tết là lễ hội lớn nhất ở Việt Nam.',
          'Tet is the biggest festival in Vietnam.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Mọi người dọn dẹp nhà cửa trước Tết.',
          'People clean their houses before Tet.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Chúng tôi ăn bánh chưng.',
          'We eat banh chung.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Trẻ em nhận được tiền mừng tuổi.',
          'Children receive lucky money.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi rất thích Tết.',
          'I love Tet.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'festival_b2',
      level: _b,
      titleVi: 'Chuẩn bị đón Tết',
      titleEn: 'Getting ready for Tet',
      sentences: [
        WritingSentence.of(
          'Bây giờ mẹ tôi đang gói bánh chưng.',
          'Now my mother is wrapping banh chung.',
          G.presentContinuous,
          alternatives: ['My mom is wrapping banh chung now.'],
        ),
        WritingSentence.of(
          'Bố tôi đang mua hoa đào.',
          'My father is buying peach blossoms.',
          G.presentContinuous,
          alternatives: ['My dad is buying peach blossoms.'],
        ),
        WritingSentence.of(
          'Tôi đang dọn phòng của mình.',
          'I am cleaning my room.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Em gái tôi đang trang trí nhà.',
          'My sister is decorating the house.',
          G.presentContinuous,
          alternatives: ['My younger sister is decorating the house.'],
        ),
        WritingSentence.of(
          'Cả nhà rất bận rộn.',
          'The whole family is very busy.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'festival_b3',
      level: _b,
      titleVi: 'Tết trung thu',
      titleEn: 'Mid-Autumn Festival',
      sentences: [
        WritingSentence.of(
          'Tết trung thu là lễ hội cho trẻ em.',
          'The Mid-Autumn Festival is a festival for children.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Chúng tôi ăn bánh trung thu.',
          'We eat mooncakes.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Trẻ em rước đèn lồng.',
          'Children carry lanterns.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Chúng tôi ngắm trăng vào buổi tối.',
          'We watch the moon in the evening.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi rất thích trăng tròn.',
          'I love the full moon.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'festival_b4',
      level: _b,
      titleVi: 'Lễ hội hoa',
      titleEn: 'A flower festival',
      sentences: [
        WritingSentence.of(
          'Tuần trước tôi đã đi lễ hội hoa.',
          'Last week I went to a flower festival.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Có rất nhiều loại hoa đẹp.',
          'There were many beautiful flowers.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã chụp nhiều ảnh.',
          'I took many photos.',
          G.pastSimple,
          alternatives: ['I took many pictures.'],
        ),
        WritingSentence.of(
          'Mẹ tôi đã mua một chậu hoa.',
          'My mother bought a pot of flowers.',
          G.pastSimple,
          alternatives: ['My mom bought a pot of flowers.'],
        ),
        WritingSentence.of(
          'Chúng tôi đã có một ngày tuyệt vời.',
          'We had a wonderful day.',
          G.pastSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'festival_b5',
      level: _b,
      titleVi: 'Lễ hội pháo hoa',
      titleEn: 'A fireworks festival',
      sentences: [
        WritingSentence.of(
          'Cuối tuần này thành phố tôi có bắn pháo hoa.',
          'This weekend my city has a fireworks show.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi định đi xem cùng gia đình.',
          'I am going to watch it with my family.',
          G.goingTo,
        ),
        WritingSentence.of(
          'Chúng tôi sẽ đến sớm để có chỗ tốt.',
          'We will arrive early to get a good spot.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Pháo hoa sẽ bắt đầu lúc chín giờ.',
          'The fireworks will start at nine o\'clock.',
          G.futureSimple,
          alternatives: ['The fireworks will start at nine.'],
        ),
        WritingSentence.of(
          'Chắc chắn sẽ rất đẹp.',
          'It will surely be beautiful.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'festival_b6',
      level: _b,
      titleVi: 'Giáng sinh',
      titleEn: 'Christmas',
      sentences: [
        WritingSentence.of(
          'Nhiều người Việt Nam thích Giáng sinh.',
          'Many Vietnamese people like Christmas.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Đường phố có nhiều đèn màu.',
          'The streets have many colorful lights.',
          G.presentSimple,
          alternatives: ['The streets have many colourful lights.'],
        ),
        WritingSentence.of(
          'Tôi thích chụp ảnh với cây thông.',
          'I like taking photos with the Christmas tree.',
          G.presentSimple,
          alternatives: ['I like taking pictures with the Christmas tree.'],
        ),
        WritingSentence.of(
          'Chúng tôi sẽ đi dạo phố tối nay.',
          'We will walk around the streets tonight.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Tôi rất thích không khí lễ hội.',
          'I love the festive atmosphere.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'festival_b7',
      level: _b,
      titleVi: 'Ngày lễ ở trường',
      titleEn: 'A school festival',
      sentences: [
        WritingSentence.of(
          'Trường tôi tổ chức một ngày lễ mỗi năm.',
          'My school holds a festival every year.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Học sinh mặc trang phục dân tộc.',
          'Students wear traditional costumes.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Bây giờ chúng tôi đang chơi trò chơi dân gian.',
          'Now we are playing folk games.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Sau đó tôi sẽ tham gia thi nấu ăn.',
          'After that I will join a cooking contest.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Tôi mong sẽ thắng.',
          'I hope I will win.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'festival_b8',
      level: _b,
      titleVi: 'Lễ hội đua thuyền',
      titleEn: 'A boat race festival',
      sentences: [
        WritingSentence.of(
          'Hè năm ngoái tôi đã xem đua thuyền.',
          'Last summer I watched a boat race.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Nhiều đội đã tham gia cuộc thi.',
          'Many teams took part in the race.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Mọi người đã hò reo cổ vũ.',
          'Everyone cheered loudly.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Đội của làng tôi đã thắng.',
          'My village\'s team won.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Chúng tôi đã ăn mừng suốt buổi tối.',
          'We celebrated all evening.',
          G.pastSimple,
        ),
      ],
    ),

    // ---------------- Trung cap ----------------
    WritingParagraph(
      id: 'festival_i1',
      level: _i,
      titleVi: 'Ý nghĩa của Tết',
      titleEn: 'The meaning of Tet',
      sentences: [
        WritingSentence.of(
          'Tết quan trọng hơn bất kỳ ngày lễ nào khác ở Việt Nam.',
          'Tet is more important than any other holiday in Vietnam.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nhiều món ăn truyền thống được chuẩn bị từ nhiều ngày trước.',
          'Many traditional dishes are prepared days in advance.',
          G.passive,
        ),
        WritingSentence.of(
          'Tôi đã trở về quê ăn Tết mỗi năm.',
          'I have gone home for Tet every year.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Năm ngoái, trong khi cả nhà đang gói bánh, ông kể về Tết thời chiến tranh.',
          'Last year, while the family was wrapping cakes, my grandfather told stories about wartime Tet.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tết bây giờ hiện đại hơn Tết ngày xưa.',
          'Tet today is more modern than Tet in the past.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu tôi ở nước ngoài, tôi sẽ vẫn tổ chức Tết theo cách riêng.',
          'If I live abroad, I will still celebrate Tet in my own way.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'festival_i2',
      level: _i,
      titleVi: 'Lễ hội chùa Hương',
      titleEn: 'The Perfume Pagoda festival',
      sentences: [
        WritingSentence.of(
          'Lễ hội chùa Hương được tổ chức mỗi mùa xuân.',
          'The Perfume Pagoda festival is held every spring.',
          G.passive,
        ),
        WritingSentence.of(
          'Hàng nghìn du khách đã đến đó trong tháng trước.',
          'Thousands of visitors have gone there in the past month.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Đường lên chùa dốc hơn tôi tưởng.',
          'The path to the pagoda was steeper than I expected.',
          G.comparison,
        ),
        WritingSentence.of(
          'Trong khi chúng tôi đang đi thuyền trên suối, tôi ngắm những ngọn núi đá vôi.',
          'While we were boating on the stream, I admired the limestone mountains.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi chưa bao giờ thấy nhiều người hành hương như vậy.',
          'I have never seen so many pilgrims.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu năm sau có dịp, tôi sẽ đi lại vào lúc vắng hơn.',
          'If I get the chance next year, I will go again at a quieter time.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'festival_i3',
      level: _i,
      titleVi: 'Halloween ở trường',
      titleEn: 'Halloween at school',
      sentences: [
        WritingSentence.of(
          'Trường quốc tế nơi bạn tôi học tổ chức tiệc Halloween mỗi năm.',
          'The international school where my friend studies holds a Halloween party every year.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Lớp học được trang trí bằng bí ngô và nhện giả.',
          'The classroom is decorated with pumpkins and fake spiders.',
          G.passive,
        ),
        WritingSentence.of(
          'Trang phục của cô ấy sáng tạo hơn năm ngoái.',
          'Her costume was more creative than last year\'s.',
          G.comparison,
        ),
        WritingSentence.of(
          'Trong khi mọi người đang chơi trò xin kẹo, có một học sinh làm rơi giỏ kẹo.',
          'While everyone was trick-or-treating, one student dropped their candy basket.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Cô ấy đã thắng giải trang phục đẹp nhất.',
          'She has won the best costume award.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu trường tôi cũng tổ chức, tôi sẽ hoá trang thành phù thuỷ.',
          'If my school also holds one, I will dress up as a witch.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'festival_i4',
      level: _i,
      titleVi: 'Tết Đoan Ngọ',
      titleEn: 'Doan Ngo festival',
      sentences: [
        WritingSentence.of(
          'Tết Đoan Ngọ được tổ chức vào tháng năm âm lịch.',
          'Doan Ngo festival is held in the fifth lunar month.',
          G.passive,
        ),
        WritingSentence.of(
          'Người ta ăn rượu nếp để diệt sâu bọ.',
          'People eat fermented sticky rice to kill parasites.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Truyền thống này cổ hơn nhiều lễ hội khác.',
          'This tradition is older than many other festivals.',
          G.comparison,
        ),
        WritingSentence.of(
          'Sáng nay, trong khi bà đang chuẩn bị rượu nếp, tôi hỏi về nguồn gốc lễ hội.',
          'This morning, while my grandmother was preparing the rice wine, I asked about its origin.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi đã học được nhiều điều thú vị.',
          'I have learned many interesting things.',
          G.presentPerfect,
          alternatives: ['I have learnt many interesting things.'],
        ),
        WritingSentence.of(
          'Nếu tôi có con, tôi sẽ dạy chúng về ngày lễ này.',
          'If I have children, I will teach them about this festival.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'festival_i5',
      level: _i,
      titleVi: 'Lễ hội âm nhạc mùa hè',
      titleEn: 'A summer music festival',
      sentences: [
        WritingSentence.of(
          'Lễ hội âm nhạc năm nay đông hơn năm ngoái rất nhiều.',
          'This year\'s music festival was much bigger than last year\'s.',
          G.comparison,
        ),
        WritingSentence.of(
          'Vé đã được bán hết trong một tuần.',
          'The tickets were sold out within a week.',
          G.passive,
        ),
        WritingSentence.of(
          'Tôi đã chờ đợi sự kiện này suốt sáu tháng.',
          'I have waited for this event for six months.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Trong khi ban nhạc yêu thích của tôi đang biểu diễn, trời đổ mưa nhẹ.',
          'While my favorite band was performing, it started to drizzle.',
          G.pastContinuous,
          alternatives: [
            'While my favourite band was performing, it started to drizzle.',
          ],
        ),
        WritingSentence.of(
          'Mưa không làm ai bỏ về.',
          'The rain did not make anyone leave.',
          G.pastSimple,
          alternatives: ['The rain didn\'t make anyone leave.'],
        ),
        WritingSentence.of(
          'Nếu năm sau vẫn có lễ hội, tôi sẽ mua vé sớm hơn.',
          'If the festival happens again next year, I will buy tickets earlier.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'festival_i6',
      level: _i,
      titleVi: 'Lễ giỗ tổ Hùng Vương',
      titleEn: 'Hung Kings\' Festival',
      sentences: [
        WritingSentence.of(
          'Giỗ tổ Hùng Vương được tổ chức vào ngày mùng mười tháng ba âm lịch.',
          'The Hung Kings\' Festival is held on the tenth day of the third lunar month.',
          G.passive,
        ),
        WritingSentence.of(
          'Hàng triệu người đã hành hương về đền Hùng.',
          'Millions of people have made a pilgrimage to the Hung Temple.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Đường lên đền dài hơn tôi tưởng.',
          'The path up to the temple was longer than I expected.',
          G.comparison,
        ),
        WritingSentence.of(
          'Trong khi tôi đang leo lên bậc thang, tôi nghĩ về lịch sử dân tộc.',
          'While I was climbing the steps, I thought about our nation\'s history.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi đã cảm thấy tự hào hơn bao giờ hết.',
          'I felt prouder than ever.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu có dịp, tôi sẽ đưa con mình đến đây khi chúng lớn hơn.',
          'If I get the chance, I will bring my children here when they are older.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'festival_i7',
      level: _i,
      titleVi: 'Lễ Vu Lan',
      titleEn: 'Vu Lan Festival',
      sentences: [
        WritingSentence.of(
          'Lễ Vu Lan được tổ chức để tưởng nhớ công ơn cha mẹ.',
          'Vu Lan Festival is held to honor parents.',
          G.passive,
          alternatives: ['Vu Lan Festival is held to honour parents.'],
        ),
        WritingSentence.of(
          'Nhiều người đến chùa cài hoa hồng lên áo.',
          'Many people go to pagodas to pin a rose on their shirts.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Ý nghĩa của lễ này sâu sắc hơn tôi từng nghĩ.',
          'The meaning of this festival is deeper than I once thought.',
          G.comparison,
        ),
        WritingSentence.of(
          'Trong khi tôi đang nghe bài giảng, tôi đã khóc vì nhớ đến mẹ.',
          'While I was listening to the sermon, I cried thinking about my mother.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi đã gọi điện cho mẹ ngay sau đó.',
          'I called my mother right after.',
          G.pastSimple,
          alternatives: ['I called my mom right after.'],
        ),
        WritingSentence.of(
          'Nếu có thời gian, tôi sẽ về thăm mẹ nhiều hơn.',
          'If I have time, I will visit my mother more often.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'festival_i8',
      level: _i,
      titleVi: 'Hội chợ Giáng sinh',
      titleEn: 'A Christmas market',
      sentences: [
        WritingSentence.of(
          'Một hội chợ Giáng sinh vừa được mở ở trung tâm thành phố.',
          'A Christmas market has just been opened in the city center.',
          G.passive,
          alternatives: [
            'A Christmas market has just been opened in the city centre.',
          ],
        ),
        WritingSentence.of(
          'Nó lớn hơn hội chợ năm ngoái nhiều.',
          'It is much bigger than last year\'s market.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tôi đã mua vài món quà nhỏ ở đó.',
          'I have bought a few small gifts there.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Trong khi tôi đang xem các gian hàng, một dàn hợp xướng bắt đầu hát.',
          'While I was browsing the stalls, a choir started singing.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Không khí ở đó ấm áp hơn tôi tưởng dù trời lạnh.',
          'The atmosphere there was warmer than I expected, even though it was cold.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu bạn đến thành phố tôi vào tháng mười hai, bạn nên ghé thăm nó.',
          'If you come to my city in December, you should visit it.',
          G.conditional1,
        ),
      ],
    ),

    // ---------------- Nang cao ----------------
    WritingParagraph(
      id: 'festival_a1',
      level: _a,
      titleVi: 'Tết xa nhà',
      titleEn: 'Tet away from home',
      sentences: [
        WritingSentence.of(
          'Năm nay là năm đầu tiên tôi đón Tết ở nước ngoài, xa gia đình đã nuôi tôi khôn lớn.',
          'This year is the first time I have celebrated Tet abroad, away from the family that raised me.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Tôi đã cố gắng nấu một bữa cơm giống hệt bữa cơm mẹ tôi từng làm mỗi năm.',
          'I tried to cook a meal exactly like the one my mother used to make every year.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Trong khi tôi đang gói bánh chưng bằng lá chuối đông lạnh, tôi nhớ nhà hơn bao giờ hết.',
          'While I was wrapping banh chung with frozen banana leaves, I missed home more than ever.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Mẹ tôi gọi video và nói rằng bà cũng đang khóc.',
          'My mother video called and said that she was crying too.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu tôi biết trước sẽ nhớ nhà đến vậy, có lẽ tôi đã về nước dịp Tết.',
          'If I had known I would miss home this much, I might have gone back for Tet.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Dù xa nhà, tôi đã học được rằng truyền thống có thể được mang theo bất cứ đâu.',
          'Even far from home, I have learned that traditions can be carried anywhere.',
          G.presentPerfect,
          alternatives: [
            'Even far from home, I have learnt that traditions can be carried anywhere.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'festival_a2',
      level: _a,
      titleVi: 'Thương mại hoá lễ hội',
      titleEn: 'The commercialization of festivals',
      sentences: [
        WritingSentence.of(
          'Nhiều người lớn tuổi lo ngại rằng ý nghĩa thiêng liêng của Tết đang bị thay thế bởi mua sắm và tiêu dùng.',
          'Many older people worry that the sacred meaning of Tet is being replaced by shopping and consumption.',
          G.passive,
        ),
        WritingSentence.of(
          'Trước khi có mạng xã hội, các gia đình chưa từng cảm thấy áp lực phải mua sắm quá mức cho Tết.',
          'Before social media existed, families had never felt pressure to overspend for Tet.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Một nhà xã hội học giải thích rằng quảng cáo đã khiến người tiêu dùng liên tưởng lễ hội với việc mua sắm.',
          'A sociologist explained that advertising had made consumers associate festivals with shopping.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu các gia đình tập trung nhiều hơn vào việc đoàn tụ thay vì quà cáp, Tết sẽ giữ được ý nghĩa gốc.',
          'If families focused more on reunion than on gifts, Tet would keep its original meaning.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Một số cộng đồng đã và đang cố gắng khôi phục các nghi lễ truyền thống đơn giản hơn.',
          'Some communities have been trying to revive simpler traditional rituals.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Đến khi thế hệ tiếp theo lớn lên, ý nghĩa thật sự của lễ hội có thể sẽ đã bị lu mờ hoàn toàn.',
          'By the time the next generation grows up, the true meaning of the festival may have been completely overshadowed.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'festival_a3',
      level: _a,
      titleVi: 'Lễ hội và bản sắc dân tộc',
      titleEn: 'Festivals and national identity',
      sentences: [
        WritingSentence.of(
          'Lễ hội, những dịp mà cả cộng đồng cùng nhau tưởng nhớ tổ tiên, đóng vai trò quan trọng trong việc gìn giữ bản sắc dân tộc.',
          'Festivals, occasions when the whole community remembers its ancestors together, play a key role in preserving national identity.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Nhiều nghi lễ đã được truyền lại qua hàng trăm năm mà không thay đổi nhiều.',
          'Many rituals have been passed down for hundreds of years without changing much.',
          G.passive,
        ),
        WritingSentence.of(
          'Một nhà nhân học nói rằng cộng đồng người Việt ở nước ngoài giữ gìn lễ hội chặt chẽ hơn cả người trong nước.',
          'An anthropologist said that overseas Vietnamese communities preserved festivals more strictly than people at home.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Trước khi rời quê hương, nhiều người chưa từng nhận ra họ sẽ nhớ những lễ hội này đến vậy.',
          'Before leaving their homeland, many people had never realized how much they would miss these festivals.',
          G.pastPerfect,
          alternatives: [
            'Before leaving their homeland, many people had never realised how much they would miss these festivals.',
          ],
        ),
        WritingSentence.of(
          'Nếu không có những cộng đồng hải ngoại này, một số truyền thống có lẽ đã dần biến mất.',
          'Without these overseas communities, some traditions might have gradually disappeared.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Tôi tin rằng lễ hội sẽ luôn là sợi dây kết nối người Việt dù họ ở bất cứ đâu trên thế giới.',
          'I believe that festivals will always be the thread that connects Vietnamese people, wherever they are in the world.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'festival_a4',
      level: _a,
      titleVi: 'Lễ hội bị lãng quên',
      titleEn: 'A forgotten festival',
      sentences: [
        WritingSentence.of(
          'Có những lễ hội địa phương đã dần bị lãng quên khi giới trẻ chuyển đến thành phố.',
          'There are local festivals that have gradually been forgotten as young people move to the cities.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Một cụ già trong làng kể rằng lễ hội này từng thu hút cả vùng đến tham dự.',
          'An elderly villager told me that this festival had once attracted the whole region.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Trước khi ông kể lại, tôi chưa từng nghe nói đến lễ hội này.',
          'Before he told me, I had never heard of this festival.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Nếu không có người ghi chép lại, những chi tiết này có thể sẽ biến mất mãi mãi.',
          'If no one records these details, they may disappear forever.',
          G.conditional1,
        ),
        WritingSentence.of(
          'Gần đây, một nhóm sinh viên đã và đang phỏng vấn người già để lưu giữ ký ức về lễ hội.',
          'Recently, a group of students has been interviewing elderly people to preserve memories of the festival.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Nếu dự án này thành công, lễ hội có thể được khôi phục vào năm sau.',
          'If this project succeeds, the festival could be revived next year.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'festival_a5',
      level: _a,
      titleVi: 'Lễ hội quốc tế',
      titleEn: 'An international festival',
      sentences: [
        WritingSentence.of(
          'Liên hoan pháo hoa quốc tế Đà Nẵng, sự kiện thu hút hàng chục nghìn du khách mỗi năm, đã trở thành niềm tự hào của thành phố.',
          'The Da Nang International Fireworks Festival, an event that attracts tens of thousands of visitors each year, has become the city\'s pride.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Các đội đến từ nhiều quốc gia đã cạnh tranh để trình diễn màn trình diễn ấn tượng nhất.',
          'Teams from many countries have competed to put on the most impressive show.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Ban tổ chức nói rằng sự kiện này đã được chuẩn bị suốt gần một năm.',
          'The organizers said that the event had been prepared for almost a year.',
          G.reportedSpeech,
          alternatives: [
            'The organisers said that the event had been prepared for almost a year.',
          ],
        ),
        WritingSentence.of(
          'Nếu thời tiết xấu, toàn bộ chương trình sẽ phải hoãn lại.',
          'If the weather is bad, the whole show will have to be postponed.',
          G.conditional1,
        ),
        WritingSentence.of(
          'Trước khi sự kiện này ra đời, thành phố ít được biết đến trên bản đồ du lịch quốc tế.',
          'Before this event was created, the city had been little known on the international tourism map.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Đến năm sau, lễ hội này sẽ được tổ chức lần thứ hai mươi.',
          'By next year, this festival will have been held for the twentieth time.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'festival_a6',
      level: _a,
      titleVi: 'Áp lực du lịch lễ hội',
      titleEn: 'Overtourism at festivals',
      sentences: [
        WritingSentence.of(
          'Một số lễ hội truyền thống, vốn từng chỉ dành cho người dân địa phương, giờ thu hút hàng triệu du khách.',
          'Some traditional festivals, which used to be just for local people, now attract millions of tourists.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Cơ sở hạ tầng địa phương thường không được thiết kế để chịu được lượng khách như vậy.',
          'Local infrastructure is often not designed to handle such crowds.',
          G.passive,
        ),
        WritingSentence.of(
          'Một người dân địa phương phàn nàn rằng ý nghĩa tâm linh của lễ hội đã bị lu mờ bởi đám đông chụp ảnh.',
          'A local resident complained that the spiritual meaning of the festival had been overshadowed by crowds taking photos.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu số lượng khách được giới hạn, trải nghiệm sẽ trở nên ý nghĩa hơn cho tất cả mọi người.',
          'If visitor numbers were limited, the experience would become more meaningful for everyone.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Chính quyền địa phương đã và đang cân nhắc bán vé có giới hạn số lượng.',
          'Local authorities have been considering selling a limited number of tickets.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Nếu không có giải pháp phù hợp, một số lễ hội có thể mất đi chính bản sắc đã làm nên chúng.',
          'Without a proper solution, some festivals may lose the very identity that made them special.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'festival_a7',
      level: _a,
      titleVi: 'Lễ hội của người dân tộc thiểu số',
      titleEn: 'An ethnic minority festival',
      sentences: [
        WritingSentence.of(
          'Lễ hội Gầu Tào của người Hmông, được tổ chức để cầu mùa màng bội thu, đã tồn tại qua nhiều thế kỷ.',
          'The Gau Tao festival of the Hmong people, which is held to pray for a good harvest, has existed for centuries.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Khi tôi đến thăm bản làng, dân làng đã chuẩn bị lễ hội suốt nhiều tuần trước đó.',
          'By the time I visited the village, the villagers had been preparing the festival for weeks.',
          G.pastPerfectContinuous,
        ),
        WritingSentence.of(
          'Một già làng giải thích rằng mỗi nghi lễ đều mang một ý nghĩa sâu sắc mà người ngoài khó hiểu hết.',
          'A village elder explained that every ritual carried a deep meaning that outsiders found hard to fully understand.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu du khách hiểu rõ hơn về văn hoá bản địa, họ sẽ tôn trọng những nghi lễ này hơn.',
          'If tourists understood indigenous culture better, they would respect these rituals more.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Trang phục truyền thống mà người phụ nữ mặc được thêu tay suốt nhiều tháng.',
          'The traditional costumes that women wore had been hand embroidered over many months.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Trải nghiệm đó đã dạy tôi rằng mỗi cộng đồng đều có cách riêng để ăn mừng cuộc sống.',
          'That experience taught me that every community has its own way of celebrating life.',
          G.passive,
        ),
      ],
    ),
    WritingParagraph(
      id: 'festival_a8',
      level: _a,
      titleVi: 'Lễ hội trong tương lai',
      titleEn: 'The future of festivals',
      sentences: [
        WritingSentence.of(
          'Với sự phát triển của công nghệ, một số lễ hội đang bắt đầu diễn ra dưới hình thức trực tuyến.',
          'With the growth of technology, some festivals are beginning to take place online.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Năm ngoái, hàng nghìn người đã theo dõi lễ đón giao thừa qua một buổi phát trực tiếp.',
          'Last year, thousands of people watched the New Year countdown through a live stream.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Một nhà tổ chức sự kiện nói rằng công nghệ thực tế ảo có thể giúp người ở xa cảm nhận không khí lễ hội.',
          'An event organizer said that virtual reality could help people far away feel the festival atmosphere.',
          G.reportedSpeech,
          alternatives: [
            'An event organiser said that virtual reality could help people far away feel the festival atmosphere.',
          ],
        ),
        WritingSentence.of(
          'Nếu công nghệ này phát triển hơn, những người xa quê sẽ không còn cảm thấy bị bỏ lỡ.',
          'If this technology develops further, people far from home will no longer feel left out.',
          G.conditional1,
        ),
        WritingSentence.of(
          'Tuy nhiên, nhiều người vẫn tin rằng không gì có thể thay thế được việc tụ họp trực tiếp.',
          'However, many people still believe that nothing can replace gathering in person.',
          G.modal,
        ),
        WritingSentence.of(
          'Đến khi con cháu chúng ta lớn lên, lễ hội có lẽ sẽ đã kết hợp cả truyền thống lẫn công nghệ.',
          'By the time our grandchildren grow up, festivals will probably have blended both tradition and technology.',
          G.futurePerfect,
        ),
      ],
    ),
  ],
);

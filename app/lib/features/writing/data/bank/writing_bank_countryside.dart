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

const kWritingBankCountryside = WritingTopic(
  id: 'countryside',
  titleVi: 'Miền quê',
  titleEn: 'The Countryside',
  icon: Icons.grass_rounded,
  color: AppColors.teal,
  paragraphs: [
    // ---------------- Co ban ----------------
    WritingParagraph(
      id: 'countryside_b1',
      level: _b,
      titleVi: 'Quê ngoại của tôi',
      titleEn: 'My grandmother\'s village',
      sentences: [
        WritingSentence.of(
          'Quê ngoại tôi ở một ngôi làng nhỏ.',
          'My grandmother\'s village is small.',
          G.presentSimple,
          alternatives: ['My grandma\'s village is small.'],
        ),
        WritingSentence.of(
          'Ở đó có nhiều cánh đồng lúa.',
          'There are many rice fields there.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Không khí ở quê rất trong lành.',
          'The air in the countryside is very fresh.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi thích thăm quê vào mùa hè.',
          'I like visiting the countryside in summer.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Cuộc sống ở đó rất yên bình.',
          'Life there is very peaceful.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'countryside_b2',
      level: _b,
      titleVi: 'Cánh đồng lúa',
      titleEn: 'The rice fields',
      sentences: [
        WritingSentence.of(
          'Bây giờ nông dân đang gặt lúa.',
          'Now the farmers are harvesting rice.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Trâu đang ăn cỏ trên đồng.',
          'The buffalo is eating grass in the field.',
          G.presentContinuous,
          alternatives: ['The buffalo is grazing in the field.'],
        ),
        WritingSentence.of(
          'Cánh đồng có màu vàng đẹp.',
          'The fields have a beautiful yellow color.',
          G.presentSimple,
          alternatives: ['The fields have a beautiful yellow colour.'],
        ),
        WritingSentence.of(
          'Tôi có thể ngửi thấy mùi lúa mới.',
          'I can smell the fresh rice.',
          G.modal,
        ),
        WritingSentence.of(
          'Tôi sẽ giúp bà gặt lúa.',
          'I will help my grandmother harvest rice.',
          G.futureSimple,
          alternatives: ['I will help my grandma harvest rice.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'countryside_b3',
      level: _b,
      titleVi: 'Nhà tranh của ông bà',
      titleEn: 'My grandparents\' cottage',
      sentences: [
        WritingSentence.of(
          'Nhà ông bà tôi rất đơn giản.',
          'My grandparents\' house is very simple.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Nó có một khu vườn nhỏ.',
          'It has a small garden.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Ông trồng rau trong vườn.',
          'My grandfather grows vegetables in the garden.',
          G.presentSimple,
          alternatives: ['My grandpa grows vegetables in the garden.'],
        ),
        WritingSentence.of(
          'Bà nuôi vài con gà.',
          'My grandmother keeps a few chickens.',
          G.presentSimple,
          alternatives: ['My grandma keeps a few chickens.'],
        ),
        WritingSentence.of(
          'Tôi rất thích ở đó.',
          'I really like it there.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'countryside_b4',
      level: _b,
      titleVi: 'Kỳ nghỉ ở quê',
      titleEn: 'A holiday in the countryside',
      sentences: [
        WritingSentence.of(
          'Mùa hè năm ngoái tôi đã về quê.',
          'Last summer I went back to the countryside.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã bắt cá cùng anh họ.',
          'I caught fish with my cousin.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Chúng tôi đã đi chăn trâu.',
          'We took the buffalo out to graze.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã ngủ dưới bầu trời đầy sao.',
          'I slept under a sky full of stars.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Kỳ nghỉ đó rất tuyệt.',
          'That holiday was wonderful.',
          G.pastSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'countryside_b5',
      level: _b,
      titleVi: 'Chợ quê',
      titleEn: 'A village market',
      sentences: [
        WritingSentence.of(
          'Chợ quê họp mỗi sáng sớm.',
          'The village market opens every early morning.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Người ta bán rau và cá tươi.',
          'People sell vegetables and fresh fish.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Ngày mai bà tôi định đi chợ sớm.',
          'Tomorrow my grandmother is going to the market early.',
          G.goingTo,
          alternatives: ['Tomorrow my grandma is going to the market early.'],
        ),
        WritingSentence.of(
          'Tôi sẽ đi cùng bà.',
          'I will go with her.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Chúng tôi sẽ mua rau tươi.',
          'We will buy fresh vegetables.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'countryside_b6',
      level: _b,
      titleVi: 'Con sông gần nhà',
      titleEn: 'The river near the house',
      sentences: [
        WritingSentence.of(
          'Có một con sông gần nhà bà tôi.',
          'There is a river near my grandmother\'s house.',
          G.presentSimple,
          alternatives: ['There is a river near my grandma\'s house.'],
        ),
        WritingSentence.of(
          'Nước sông rất trong.',
          'The river water is very clear.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Trẻ em đang bơi ở đó.',
          'Children are swimming there.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Tôi có thể nhìn thấy cá bơi.',
          'I can see fish swimming.',
          G.modal,
        ),
        WritingSentence.of(
          'Chiều nay tôi sẽ bơi ở đó.',
          'This afternoon I will swim there.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'countryside_b7',
      level: _b,
      titleVi: 'Buổi tối ở quê',
      titleEn: 'An evening in the countryside',
      sentences: [
        WritingSentence.of(
          'Buổi tối ở quê rất yên tĩnh.',
          'Evenings in the countryside are very quiet.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Không có nhiều ánh đèn.',
          'There are not many lights.',
          G.presentSimple,
          alternatives: ['There aren\'t many lights.'],
        ),
        WritingSentence.of(
          'Tôi có thể nhìn thấy rất nhiều sao.',
          'I can see so many stars.',
          G.modal,
        ),
        WritingSentence.of(
          'Cả nhà đang ngồi ngoài sân.',
          'The whole family is sitting in the yard.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Chúng tôi đang kể chuyện.',
          'We are telling stories.',
          G.presentContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'countryside_b8',
      level: _b,
      titleVi: 'Vụ mùa',
      titleEn: 'The harvest',
      sentences: [
        WritingSentence.of(
          'Tháng này là mùa gặt.',
          'This month is harvest time.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Cả làng đang bận rộn.',
          'The whole village is busy.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Bố tôi đã về quê giúp ông.',
          'My father went home to help my grandfather.',
          G.pastSimple,
          alternatives: ['My dad went home to help my grandpa.'],
        ),
        WritingSentence.of(
          'Họ đã gặt xong hết cánh đồng.',
          'They finished harvesting the whole field.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Mọi người đã rất mệt nhưng vui.',
          'Everyone was tired but happy.',
          G.pastSimple,
        ),
      ],
    ),

    // ---------------- Trung cap ----------------
    WritingParagraph(
      id: 'countryside_i1',
      level: _i,
      titleVi: 'Cuộc sống ở quê thay đổi',
      titleEn: 'Life in the village is changing',
      sentences: [
        WritingSentence.of(
          'Cuộc sống ở quê tôi đã thay đổi rất nhiều trong mười năm qua.',
          'Life in my village has changed a lot over the past ten years.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nhiều con đường được trải nhựa gần đây.',
          'Many roads have been paved recently.',
          G.passive,
        ),
        WritingSentence.of(
          'Bây giờ nhà nào cũng có điện và internet.',
          'Now every house has electricity and internet.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Đường ở đây tốt hơn trước rất nhiều.',
          'The roads here are much better than before.',
          G.comparison,
        ),
        WritingSentence.of(
          'Hôm qua, trong khi tôi đang đi dạo, tôi thấy một quán cà phê wifi mới mở.',
          'Yesterday, while I was walking, I saw a new wifi café that had just opened.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nếu quê tôi tiếp tục phát triển, giới trẻ sẽ ở lại thay vì lên thành phố.',
          'If my village keeps developing, young people will stay instead of moving to the city.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'countryside_i2',
      level: _i,
      titleVi: 'Nghề trồng trọt của ông',
      titleEn: 'My grandfather\'s farming',
      sentences: [
        WritingSentence.of(
          'Ông tôi đã làm nông được hơn năm mươi năm.',
          'My grandfather has been a farmer for over fifty years.',
          G.presentPerfect,
          alternatives: ['My grandpa has been a farmer for over fifty years.'],
        ),
        WritingSentence.of(
          'Ông biết cách trồng lúa tốt hơn ai hết.',
          'He knows how to grow rice better than anyone.',
          G.comparison,
        ),
        WritingSentence.of(
          'Ruộng của ông được tưới bằng nước từ con kênh gần nhà.',
          'His fields are watered with water from the nearby canal.',
          G.passive,
        ),
        WritingSentence.of(
          'Sáng nay, trong khi ông đang kiểm tra ruộng, trời bắt đầu mưa.',
          'This morning, while he was checking the fields, it started to rain.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Mưa tốt cho lúa hơn nắng gắt.',
          'Rain is better for the rice than harsh sun.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu mưa tiếp tục, vụ mùa năm nay sẽ được mùa.',
          'If the rain continues, this year\'s crop will be good.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'countryside_i3',
      level: _i,
      titleVi: 'Trẻ em rời làng',
      titleEn: 'Young people leaving the village',
      sentences: [
        WritingSentence.of(
          'Nhiều thanh niên đã rời làng để tìm việc ở thành phố.',
          'Many young people have left the village to find work in the city.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Làng bây giờ ít người trẻ hơn trước.',
          'The village now has fewer young people than before.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nhiều cánh đồng chỉ được chăm sóc bởi người già.',
          'Many fields are now cared for only by the elderly.',
          G.passive,
        ),
        WritingSentence.of(
          'Tuần trước, trong khi tôi đang thăm bà, bà kể về những nhà bỏ trống.',
          'Last week, while I was visiting, she told me about the empty houses.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Cuộc sống ở làng khó khăn hơn cuộc sống ở thành phố về mặt kinh tế.',
          'Village life is harder than city life economically.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu có nhiều việc làm hơn ở quê, ít người sẽ phải rời đi.',
          'If there were more jobs in the countryside, fewer people would have to leave.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'countryside_i4',
      level: _i,
      titleVi: 'Du lịch sinh thái',
      titleEn: 'Ecotourism',
      sentences: [
        WritingSentence.of(
          'Ngày càng nhiều khách du lịch muốn trải nghiệm cuộc sống nông thôn.',
          'More and more tourists want to experience rural life.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Một homestay mới được mở gần nhà bà tôi.',
          'A new homestay has been opened near my grandmother\'s house.',
          G.passive,
        ),
        WritingSentence.of(
          'Nó thu hút nhiều khách hơn tôi tưởng.',
          'It attracts more guests than I expected.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tuần trước, trong khi tôi đang giúp bà nấu ăn, một nhóm khách nước ngoài đến thăm.',
          'Last week, while I was helping my grandmother cook, a group of foreign guests visited.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Họ đã học cách làm bánh xèo cùng bà tôi.',
          'They learned how to make banh xeo with my grandmother.',
          G.pastSimple,
          alternatives: [
            'They learnt how to make banh xeo with my grandmother.',
          ],
        ),
        WritingSentence.of(
          'Nếu du lịch phát triển, người dân sẽ có thêm thu nhập.',
          'If tourism develops, local people will have extra income.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'countryside_i5',
      level: _i,
      titleVi: 'Nghỉ hè ở quê',
      titleEn: 'Summer at grandma\'s',
      sentences: [
        WritingSentence.of(
          'Tôi đã dành mùa hè này ở quê với bà.',
          'I have spent this summer at my grandmother\'s.',
          G.presentPerfect,
          alternatives: ['I have spent this summer at my grandma\'s.'],
        ),
        WritingSentence.of(
          'Cuộc sống chậm hơn ở thành phố rất nhiều.',
          'Life here is much slower than in the city.',
          G.comparison,
        ),
        WritingSentence.of(
          'Bữa cơm luôn được nấu bằng rau tự trồng.',
          'Meals are always cooked with home grown vegetables.',
          G.passive,
          alternatives: ['Meals are always cooked with home-grown vegetables.'],
        ),
        WritingSentence.of(
          'Sáng qua, trong khi tôi đang cho gà ăn, tôi bị một con gà mổ.',
          'Yesterday morning, while I was feeding the chickens, I got pecked by one.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi ngủ ngon hơn ở thành phố nhiều.',
          'I sleep much better here than in the city.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu có thể, tôi sẽ ở lại thêm một tuần.',
          'If I can, I will stay for one more week.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'countryside_i6',
      level: _i,
      titleVi: 'Lễ hội làng',
      titleEn: 'A village festival',
      sentences: [
        WritingSentence.of(
          'Mỗi năm làng tôi tổ chức một lễ hội lớn.',
          'Every year my village holds a big festival.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Sân đình được trang trí bằng cờ và đèn lồng.',
          'The communal house yard is decorated with flags and lanterns.',
          G.passive,
        ),
        WritingSentence.of(
          'Lễ hội này lớn hơn lễ hội năm ngoái.',
          'This festival is bigger than last year\'s.',
          G.comparison,
        ),
        WritingSentence.of(
          'Trong khi mọi người đang xem múa lân, tôi gặp lại bạn học cũ.',
          'While everyone was watching the lion dance, I met an old classmate.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Chúng tôi đã trò chuyện suốt cả buổi tối hôm đó.',
          'We talked all evening that day.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Nếu năm sau có lễ hội, tôi sẽ về quê tham gia.',
          'If there is a festival next year, I will go home to join it.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'countryside_i7',
      level: _i,
      titleVi: 'Trồng cây ăn quả',
      titleEn: 'Growing fruit trees',
      sentences: [
        WritingSentence.of(
          'Vườn của ông tôi có nhiều cây ăn quả hơn vườn nhà hàng xóm.',
          'My grandfather\'s garden has more fruit trees than the neighbors\'.',
          G.comparison,
          alternatives: [
            'My grandpa\'s garden has more fruit trees than the neighbours\'.',
          ],
        ),
        WritingSentence.of(
          'Cây xoài được trồng cách đây hai mươi năm.',
          'The mango tree was planted twenty years ago.',
          G.passive,
        ),
        WritingSentence.of(
          'Tôi đã trèo cây này từ khi còn nhỏ.',
          'I have climbed this tree since I was little.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Mùa hè năm ngoái, khi tôi đang trèo cây, tôi suýt ngã.',
          'Last summer, while I was climbing the tree, I almost fell.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Trái xoài ở vườn ông ngọt hơn xoài mua ở chợ.',
          'The mangoes in his garden are sweeter than the ones from the market.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu cây ra quả sớm, chúng tôi sẽ hái vào tháng tới.',
          'If the tree fruits early, we will pick them next month.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'countryside_i8',
      level: _i,
      titleVi: 'Chăn nuôi gia đình',
      titleEn: 'Raising farm animals',
      sentences: [
        WritingSentence.of(
          'Gia đình chú tôi nuôi lợn và gà để bán.',
          'My uncle\'s family raises pigs and chickens to sell.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Chuồng lợn được dọn dẹp mỗi ngày.',
          'The pigsty is cleaned every day.',
          G.passive,
        ),
        WritingSentence.of(
          'Chú tôi đã nuôi lợn được mười năm.',
          'My uncle has raised pigs for ten years.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Tuần trước, trong khi chú đang cho lợn ăn, một con lợn con chạy trốn.',
          'Last week, while my uncle was feeding the pigs, a piglet ran away.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Giá lợn năm nay cao hơn năm ngoái.',
          'This year\'s pig prices are higher than last year\'s.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu giá tiếp tục tăng, chú sẽ nuôi thêm nhiều lợn.',
          'If prices keep rising, my uncle will raise more pigs.',
          G.conditional1,
        ),
      ],
    ),

    // ---------------- Nang cao ----------------
    WritingParagraph(
      id: 'countryside_a1',
      level: _a,
      titleVi: 'Nông nghiệp hữu cơ ở làng',
      titleEn: 'Organic farming in the village',
      sentences: [
        WritingSentence.of(
          'Một nhóm nông dân trẻ, những người từng làm việc ở thành phố, đã trở về quê để làm nông nghiệp hữu cơ.',
          'A group of young farmers, who used to work in the city, have returned to farm organically.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Trước khi bắt đầu, họ đã học kỹ thuật canh tác không dùng thuốc trừ sâu suốt hai năm.',
          'Before starting, they had studied pesticide free farming techniques for two years.',
          G.pastPerfect,
          alternatives: [
            'Before starting, they had studied pesticide-free farming techniques for two years.',
          ],
        ),
        WritingSentence.of(
          'Một người trong nhóm nói rằng đất của họ giờ màu mỡ hơn nhiều so với khi mới bắt đầu.',
          'One of them said that their soil was now much richer than when they had started.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu nhiều nông dân làm theo cách này, môi trường nông thôn sẽ được cải thiện đáng kể.',
          'If more farmers followed this method, the rural environment would improve significantly.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Họ đã và đang bán rau trực tiếp cho các nhà hàng trong thành phố qua mạng.',
          'They have been selling vegetables directly to city restaurants online.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Đến năm sau, mô hình này sẽ mở rộng ra ba làng lân cận.',
          'By next year, this model will have expanded to three neighboring villages.',
          G.futurePerfect,
          alternatives: [
            'By next year, this model will have expanded to three neighbouring villages.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'countryside_a2',
      level: _a,
      titleVi: 'Làng nghề truyền thống',
      titleEn: 'A traditional craft village',
      sentences: [
        WritingSentence.of(
          'Làng gốm Bát Tràng, nơi đã tồn tại hơn năm trăm năm, đang phải đối mặt với sự cạnh tranh từ hàng công nghiệp.',
          'Bat Trang pottery village, which has existed for over five hundred years, is facing competition from mass-produced goods.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Nhiều nghệ nhân đã truyền nghề cho con cháu suốt nhiều thế hệ.',
          'Many artisans have passed down the craft to their children for generations.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Một người thợ gốm lớn tuổi nói rằng giới trẻ ngày nay ít muốn theo nghề hơn trước.',
          'An elderly potter said that young people today were less willing to follow the trade than before.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Trước khi có máy móc hiện đại, mỗi sản phẩm được làm hoàn toàn bằng tay.',
          'Before modern machines arrived, every product had been made entirely by hand.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Nếu du lịch trải nghiệm được phát triển tốt hơn, nghề gốm sẽ tồn tại lâu dài hơn.',
          'If experiential tourism were developed better, the pottery trade would survive much longer.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Đến khi thế hệ nghệ nhân hiện tại nghỉ hưu, kỹ thuật cổ có thể sẽ bị mai một.',
          'By the time this generation of artisans retires, the traditional techniques may have been lost.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'countryside_a3',
      level: _a,
      titleVi: 'Xâm nhập mặn ở đồng bằng',
      titleEn: 'Saltwater intrusion',
      sentences: [
        WritingSentence.of(
          'Ruộng lúa của ông tôi, mảnh đất đã nuôi sống gia đình suốt ba thế hệ, giờ đang bị nhiễm mặn.',
          'My grandfather\'s rice fields, which have fed our family for three generations, are now becoming salty.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Nước biển đã xâm nhập sâu hơn vào đất liền mỗi năm.',
          'Seawater has been moving further inland every year.',
          G.presentPerfectContinuous,
          alternatives: ['Seawater has been moving farther inland every year.'],
        ),
        WritingSentence.of(
          'Một chuyên gia nông nghiệp giải thích rằng lúa không thể sống nếu độ mặn vượt quá một mức nhất định.',
          'An agricultural expert explained that rice could not survive if salinity exceeded a certain level.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu ông tôi không chuyển sang giống lúa chịu mặn, vụ mùa năm nay có lẽ đã mất trắng.',
          'If my grandfather had not switched to a salt-tolerant rice variety, this year\'s crop might have failed completely.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Nhiều gia đình láng giềng đã chuyển từ trồng lúa sang nuôi tôm nước mặn.',
          'Many neighboring families have switched from growing rice to raising saltwater shrimp.',
          G.presentPerfect,
          alternatives: [
            'Many neighbouring families have switched from growing rice to raising saltwater shrimp.',
          ],
        ),
        WritingSentence.of(
          'Nếu tình trạng này tiếp diễn, cả vùng đồng bằng có thể sẽ phải thay đổi hoàn toàn cách canh tác.',
          'If this continues, the whole delta region may have to change its farming methods entirely.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'countryside_a4',
      level: _a,
      titleVi: 'Về quê khởi nghiệp',
      titleEn: 'Starting over in the countryside',
      sentences: [
        WritingSentence.of(
          'Anh họ tôi, người từng làm việc mười năm ở một ngân hàng lớn, đã quyết định bỏ phố về quê.',
          'My cousin, who had worked for ten years at a big bank, decided to leave the city for the countryside.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Trước khi đưa ra quyết định đó, anh đã cân nhắc suốt gần một năm.',
          'Before making that decision, he had considered it for almost a year.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Anh nói với gia đình rằng anh muốn sống chậm lại và gần gũi với thiên nhiên hơn.',
          'He told his family that he wanted to slow down and be closer to nature.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu anh không có chút vốn tiết kiệm, việc bắt đầu lại sẽ khó khăn hơn nhiều.',
          'If he had had no savings, starting over would have been much harder.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Từ khi về quê, anh đã và đang xây dựng một trang trại nhỏ trồng rau hữu cơ.',
          'Since moving back, he has been building a small organic vegetable farm.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Đến năm sau, trang trại của anh sẽ đủ lớn để cung cấp rau cho cả một thị trấn nhỏ.',
          'By next year, his farm will have grown big enough to supply a small town.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'countryside_a5',
      level: _a,
      titleVi: 'Giáo dục ở vùng nông thôn',
      titleEn: 'Education in rural areas',
      sentences: [
        WritingSentence.of(
          'Trường học ở làng tôi, nơi tôi từng học suốt chín năm, hiện chỉ còn một nửa số học sinh so với trước đây.',
          'The school in my village, where I studied for nine years, now has only half as many students as before.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Nhiều gia đình đã chuyển con đến trường thành phố vì chất lượng giáo dục tốt hơn.',
          'Many families have moved their children to city schools because of better education quality.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Hiệu trưởng nói rằng nhà trường đang thiếu giáo viên dạy tiếng Anh trầm trọng.',
          'The headteacher said that the school was seriously short of English teachers.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu chính phủ đầu tư nhiều hơn vào giáo dục nông thôn, khoảng cách này sẽ được thu hẹp.',
          'If the government invested more in rural education, this gap would be narrowed.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Một số tình nguyện viên đã và đang dạy tiếng Anh trực tuyến miễn phí cho học sinh vùng quê.',
          'Some volunteers have been teaching English online for free to rural students.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Nếu chương trình này thành công, nó có thể được nhân rộng ra nhiều tỉnh khác.',
          'If this program succeeds, it could be expanded to many other provinces.',
          G.conditional1,
          alternatives: [
            'If this programme succeeds, it could be expanded to many other provinces.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'countryside_a6',
      level: _a,
      titleVi: 'Người già ở lại',
      titleEn: 'The elderly left behind',
      sentences: [
        WritingSentence.of(
          'Khi con cái đều lên thành phố làm việc, nhiều người già ở quê phải sống một mình.',
          'When their children move to the city for work, many elderly people in the countryside have to live alone.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Bà hàng xóm của tôi, người đã sống một mình được năm năm, chỉ gặp con cháu vào dịp Tết.',
          'My elderly neighbor, who has lived alone for five years, only sees her children and grandchildren at Tet.',
          G.relativeClause,
          alternatives: [
            'My elderly neighbour, who has lived alone for five years, only sees her children and grandchildren at Tet.',
          ],
        ),
        WritingSentence.of(
          'Bà kể rằng bà đã học cách tự chăm sóc bản thân từ khi ông mất.',
          'She told me that she had learned to take care of herself since her husband had died.',
          G.reportedSpeech,
          alternatives: [
            'She told me that she had learnt to take care of herself since her husband had died.',
          ],
        ),
        WritingSentence.of(
          'Nếu có nhiều dịch vụ chăm sóc người già ở nông thôn hơn, cuộc sống của họ sẽ dễ dàng hơn.',
          'If there were more elderly care services in rural areas, their lives would be easier.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Một số con cháu đã bắt đầu gọi video cho ông bà mỗi ngày để bớt lo lắng.',
          'Some grandchildren have started video calling their grandparents every day to worry less.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Tôi tin rằng khoảng cách giữa các thế hệ sẽ tiếp tục là một vấn đề lớn ở nông thôn.',
          'I believe that the generation gap will continue to be a big issue in rural areas.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'countryside_a7',
      level: _a,
      titleVi: 'Bảo tồn giống lúa cổ',
      titleEn: 'Preserving heirloom rice',
      sentences: [
        WritingSentence.of(
          'Một số nông dân đang cố gắng bảo tồn những giống lúa cổ mà cha ông họ từng trồng.',
          'Some farmers are trying to preserve heirloom rice varieties that their ancestors used to grow.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Những giống lúa này đã gần như biến mất khi giống lúa lai năng suất cao được đưa vào.',
          'These varieties had almost disappeared when high-yield hybrid rice was introduced.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Một nhà nghiên cứu nói rằng những giống cổ này chịu hạn tốt hơn giống hiện đại.',
          'A researcher said that these old varieties tolerated drought better than modern ones.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu biến đổi khí hậu tiếp tục, những giống lúa chịu hạn này sẽ trở nên quan trọng hơn bao giờ hết.',
          'If climate change continues, these drought-resistant varieties will become more important than ever.',
          G.conditional1,
        ),
        WritingSentence.of(
          'Một ngân hàng gen đã và đang thu thập hạt giống từ khắp các vùng quê.',
          'A gene bank has been collecting seeds from villages across the country.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Nếu không có nỗ lực này, có lẽ chúng ta đã mất vĩnh viễn nhiều giống lúa quý.',
          'Without this effort, we might have permanently lost many valuable rice varieties.',
          G.conditional3,
        ),
      ],
    ),
    WritingParagraph(
      id: 'countryside_a8',
      level: _a,
      titleVi: 'Hai thế giới của tôi',
      titleEn: 'My two worlds',
      sentences: [
        WritingSentence.of(
          'Tôi lớn lên giữa hai thế giới: thành phố ồn ào và ngôi làng yên tĩnh nơi bà tôi sống.',
          'I grew up between two worlds: the noisy city and the quiet village where my grandmother lives.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Mỗi kỳ nghỉ hè, tôi đã dành ít nhất một tháng ở quê trước khi trở lại trường.',
          'Every summer, I spent at least a month in the countryside before returning to school.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Bạn bè thành phố của tôi từng hỏi tôi liệu tôi có thấy nhàm chán ở đó không.',
          'My city friends used to ask me whether I found it boring there.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu tôi chỉ lớn lên ở thành phố, tôi đã không bao giờ học được cách trồng rau hay câu cá.',
          'If I had only grown up in the city, I would never have learned to grow vegetables or fish.',
          G.conditional3,
          alternatives: [
            'If I had only grown up in the city, I would never have learnt to grow vegetables or fish.',
          ],
        ),
        WritingSentence.of(
          'Hai thế giới này, dù khác nhau hoàn toàn, đã cùng định hình con người tôi hôm nay.',
          'These two worlds, though completely different, have together shaped who I am today.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Sau này, tôi hy vọng con mình cũng sẽ có cơ hội trải nghiệm cả hai như tôi.',
          'In the future, I hope my children will also have the chance to experience both, like I did.',
          G.futureSimple,
        ),
      ],
    ),
  ],
);

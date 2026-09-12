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

const kWritingBankWeather = WritingTopic(
  id: 'weather',
  titleVi: 'Thời tiết',
  titleEn: 'Weather',
  icon: Icons.wb_sunny_rounded,
  color: AppColors.teal,
  paragraphs: [
    // ---------------- Co ban ----------------
    WritingParagraph(
      id: 'weather_b1',
      level: _b,
      titleVi: 'Một ngày nắng',
      titleEn: 'A sunny day',
      sentences: [
        WritingSentence.of(
          'Hôm nay trời nắng.',
          'It is sunny today.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Bầu trời rất xanh.',
          'The sky is very blue.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Trẻ em đang chơi ở công viên.',
          'Children are playing in the park.',
          G.presentContinuous,
          alternatives: ['The children are playing in the park.'],
        ),
        WritingSentence.of(
          'Tôi đang đội mũ.',
          'I am wearing a hat.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Tôi sẽ uống nhiều nước.',
          'I will drink a lot of water.',
          G.futureSimple,
          alternatives: ['I will drink lots of water.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'weather_b2',
      level: _b,
      titleVi: 'Mùa mưa',
      titleEn: 'The rainy season',
      sentences: [
        WritingSentence.of(
          'Bây giờ là mùa mưa.',
          'It is the rainy season now.',
          G.presentSimple,
          alternatives: ['Now it is the rainy season.'],
        ),
        WritingSentence.of(
          'Trời mưa gần như mỗi ngày.',
          'It rains almost every day.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi luôn mang theo áo mưa.',
          'I always carry a raincoat.',
          G.presentSimple,
          alternatives: ['I always bring a raincoat.'],
        ),
        WritingSentence.of(
          'Đường phố thường rất ướt.',
          'The streets are often very wet.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Bạn nên đi chậm khi trời mưa.',
          'You should go slowly when it rains.',
          G.modal,
          alternatives: [
            'You should drive slowly when it rains.',
            'You should ride slowly when it rains.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'weather_b3',
      level: _b,
      titleVi: 'Mùa đông ở Hà Nội',
      titleEn: 'Winter in Hanoi',
      sentences: [
        WritingSentence.of(
          'Mùa đông ở Hà Nội rất lạnh.',
          'Winter in Hanoi is very cold.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi mặc áo khoác mỗi ngày.',
          'I wear a coat every day.',
          G.presentSimple,
          alternatives: ['I wear a jacket every day.'],
        ),
        WritingSentence.of(
          'Mẹ tôi thường nấu súp nóng.',
          'My mother often cooks hot soup.',
          G.presentSimple,
          alternatives: [
            'My mom often cooks hot soup.',
            'My mother often makes hot soup.',
          ],
        ),
        WritingSentence.of(
          'Chúng tôi uống trà gừng vào buổi tối.',
          'We drink ginger tea in the evening.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi không thích mùa đông.',
          'I do not like winter.',
          G.presentSimple,
          alternatives: ['I don\'t like winter.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'weather_b4',
      level: _b,
      titleVi: 'Dự báo thời tiết',
      titleEn: 'The weather forecast',
      sentences: [
        WritingSentence.of(
          'Ngày mai trời sẽ mưa.',
          'It will rain tomorrow.',
          G.futureSimple,
          alternatives: ['Tomorrow it will rain.'],
        ),
        WritingSentence.of(
          'Trời sẽ có gió rất to.',
          'It will be very windy.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Tôi định ở nhà.',
          'I am going to stay at home.',
          G.goingTo,
          alternatives: ['I am going to stay home.'],
        ),
        WritingSentence.of(
          'Tôi định xem phim.',
          'I am going to watch a movie.',
          G.goingTo,
          alternatives: ['I am going to watch a film.'],
        ),
        WritingSentence.of(
          'Chủ nhật trời sẽ đẹp.',
          'The weather will be nice on Sunday.',
          G.futureSimple,
          alternatives: ['Sunday will be nice.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'weather_b5',
      level: _b,
      titleVi: 'Một cơn bão',
      titleEn: 'A storm',
      sentences: [
        WritingSentence.of(
          'Tuần trước có một cơn bão lớn.',
          'There was a big storm last week.',
          G.pastSimple,
          alternatives: ['Last week there was a big storm.'],
        ),
        WritingSentence.of(
          'Gió thổi rất mạnh.',
          'The wind blew very hard.',
          G.pastSimple,
          alternatives: ['The wind was very strong.'],
        ),
        WritingSentence.of(
          'Nhiều cây đã đổ.',
          'Many trees fell down.',
          G.pastSimple,
          alternatives: ['A lot of trees fell down.'],
        ),
        WritingSentence.of(
          'Chúng tôi đã ở trong nhà cả ngày.',
          'We stayed inside all day.',
          G.pastSimple,
          alternatives: [
            'We stayed indoors all day.',
            'We stayed at home all day.',
          ],
        ),
        WritingSentence.of(
          'May mắn là mọi người đều an toàn.',
          'Luckily, everyone was safe.',
          G.pastSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'weather_b6',
      level: _b,
      titleVi: 'Mùa hè',
      titleEn: 'Summer',
      sentences: [
        WritingSentence.of(
          'Tôi rất thích mùa hè.',
          'I love summer.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Mùa hè ở Việt Nam rất nóng.',
          'Summer in Vietnam is very hot.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Chúng tôi thường đi bơi.',
          'We often go swimming.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi có thể bơi rất nhanh.',
          'I can swim very fast.',
          G.modal,
        ),
        WritingSentence.of(
          'Mùa hè này, tôi định học đạp xe.',
          'This summer, I am going to learn to cycle.',
          G.goingTo,
          alternatives: ['This summer, I am going to learn to ride a bike.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'weather_b7',
      level: _b,
      titleVi: 'Một buổi sáng lạnh',
      titleEn: 'A cold morning',
      sentences: [
        WritingSentence.of(
          'Sáng nay trời rất lạnh.',
          'It is very cold this morning.',
          G.presentSimple,
          alternatives: ['This morning it is very cold.'],
        ),
        WritingSentence.of(
          'Em gái tôi đang đeo găng tay.',
          'My sister is wearing gloves.',
          G.presentContinuous,
          alternatives: ['My younger sister is wearing gloves.'],
        ),
        WritingSentence.of(
          'Bố tôi đang uống cà phê nóng.',
          'My father is drinking hot coffee.',
          G.presentContinuous,
          alternatives: ['My dad is drinking hot coffee.'],
        ),
        WritingSentence.of(
          'Tôi không muốn ra khỏi giường.',
          'I do not want to get out of bed.',
          G.presentSimple,
          alternatives: ['I don\'t want to get out of bed.'],
        ),
        WritingSentence.of(
          'Nhưng tôi phải đi học.',
          'But I must go to school.',
          G.modal,
          alternatives: ['But I have to go to school.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'weather_b8',
      level: _b,
      titleVi: 'Cầu vồng',
      titleEn: 'A rainbow',
      sentences: [
        WritingSentence.of(
          'Chiều hôm qua trời mưa.',
          'It rained yesterday afternoon.',
          G.pastSimple,
          alternatives: ['Yesterday afternoon it rained.'],
        ),
        WritingSentence.of(
          'Sau đó mặt trời xuất hiện.',
          'Then the sun came out.',
          G.pastSimple,
          alternatives: ['After that, the sun came out.'],
        ),
        WritingSentence.of(
          'Tôi đã nhìn thấy một cầu vồng.',
          'I saw a rainbow.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Nó có bảy màu.',
          'It had seven colors.',
          G.pastSimple,
          alternatives: ['It had seven colours.'],
        ),
        WritingSentence.of(
          'Tôi đã chụp một bức ảnh.',
          'I took a photo.',
          G.pastSimple,
          alternatives: ['I took a picture.'],
        ),
      ],
    ),

    // ---------------- Trung cap ----------------
    WritingParagraph(
      id: 'weather_i1',
      level: _i,
      titleVi: 'Bốn mùa ở miền Bắc',
      titleEn: 'Four seasons in the North',
      sentences: [
        WritingSentence.of(
          'Miền Bắc Việt Nam có bốn mùa rõ rệt.',
          'Northern Vietnam has four distinct seasons.',
          G.presentSimple,
          alternatives: ['The north of Vietnam has four distinct seasons.'],
        ),
        WritingSentence.of(
          'Mùa thu là mùa đẹp nhất trong năm.',
          'Autumn is the most beautiful season of the year.',
          G.comparison,
          alternatives: ['Fall is the most beautiful season of the year.'],
        ),
        WritingSentence.of(
          'Mùa hè nóng hơn và ẩm hơn mùa xuân.',
          'Summer is hotter and more humid than spring.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tôi đã sống ở Hà Nội được năm năm.',
          'I have lived in Hanoi for five years.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Năm ngoái, người ta đã nhìn thấy tuyết ở Sa Pa.',
          'Last year, snow was seen in Sa Pa.',
          G.passive,
          alternatives: ['Last year, snow was seen in Sapa.'],
        ),
        WritingSentence.of(
          'Nếu mùa đông năm nay có tuyết, tôi sẽ lên đó.',
          'If it snows this winter, I will go up there.',
          G.conditional1,
          alternatives: ['If there is snow this winter, I will go there.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'weather_i2',
      level: _i,
      titleVi: 'Đợt nắng nóng',
      titleEn: 'A heatwave',
      sentences: [
        WritingSentence.of(
          'Tuần này là tuần nóng nhất trong năm.',
          'This week is the hottest week of the year.',
          G.comparison,
          alternatives: ['This is the hottest week of the year.'],
        ),
        WritingSentence.of(
          'Nhiệt độ đã lên tới bốn mươi độ.',
          'The temperature has reached forty degrees.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Mọi người được khuyên nên ở trong nhà.',
          'People are advised to stay indoors.',
          G.passive,
          alternatives: ['People are told to stay inside.'],
        ),
        WritingSentence.of(
          'Hôm qua, trong khi tôi đang đi bộ về nhà, tôi cảm thấy chóng mặt.',
          'Yesterday, while I was walking home, I felt dizzy.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Phòng có điều hoà mát hơn bên ngoài rất nhiều.',
          'The room with air conditioning is much cooler than outside.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu trời vẫn nóng như vậy, chúng tôi sẽ đi biển.',
          'If it stays this hot, we will go to the beach.',
          G.conditional1,
          alternatives: ['If it is still this hot, we will go to the beach.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'weather_i3',
      level: _i,
      titleVi: 'Bị mắc mưa',
      titleEn: 'Caught in the rain',
      sentences: [
        WritingSentence.of(
          'Chiều qua, trong khi tôi đang đạp xe về nhà, trời bắt đầu mưa to.',
          'Yesterday afternoon, while I was cycling home, it started to rain heavily.',
          G.pastContinuous,
          alternatives: [
            'Yesterday afternoon, while I was cycling home, it started raining heavily.',
            'Yesterday afternoon, while I was cycling home, it began to rain heavily.',
          ],
        ),
        WritingSentence.of(
          'Tôi đã quên mang áo mưa.',
          'I forgot to bring my raincoat.',
          G.pastSimple,
          alternatives: ['I forgot my raincoat.'],
        ),
        WritingSentence.of(
          'Quần áo và cặp sách của tôi ướt hết.',
          'My clothes and my school bag got completely wet.',
          G.pastSimple,
          alternatives: ['My clothes and schoolbag got completely wet.'],
        ),
        WritingSentence.of(
          'Tôi chưa bao giờ bị ướt như vậy.',
          'I have never been so wet.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Sáng nay, tôi thấy mệt hơn bình thường.',
          'This morning, I feel more tired than usual.',
          G.comparison,
          alternatives: ['This morning, I felt more tired than usual.'],
        ),
        WritingSentence.of(
          'Nếu tôi bị ốm, tôi sẽ nghỉ học một ngày.',
          'If I get sick, I will take a day off school.',
          G.conditional1,
          alternatives: ['If I get ill, I will take a day off school.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'weather_i4',
      level: _i,
      titleVi: 'Đà Lạt mộng mơ',
      titleEn: 'Dreamy Da Lat',
      sentences: [
        WritingSentence.of(
          'Đà Lạt mát hơn hầu hết các thành phố khác ở Việt Nam.',
          'Da Lat is cooler than most other cities in Vietnam.',
          G.comparison,
          alternatives: ['Dalat is cooler than most other cities in Vietnam.'],
        ),
        WritingSentence.of(
          'Thành phố được gọi là thành phố ngàn hoa.',
          'The city is called the city of a thousand flowers.',
          G.passive,
          alternatives: ['It is called the city of a thousand flowers.'],
        ),
        WritingSentence.of(
          'Tôi đã đến Đà Lạt ba lần.',
          'I have been to Da Lat three times.',
          G.presentPerfect,
          alternatives: ['I have been to Dalat three times.'],
        ),
        WritingSentence.of(
          'Lần gần nhất, trong khi chúng tôi đang đi dạo quanh hồ, sương mù phủ kín khắp nơi.',
          'Last time, while we were walking around the lake, fog covered everything.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Buổi sáng ở đó thường lạnh hơn buổi chiều.',
          'Mornings there are usually colder than afternoons.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu bạn đi vào tháng mười hai, bạn nên mang áo ấm.',
          'If you go in December, you should bring warm clothes.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'weather_i5',
      level: _i,
      titleVi: 'Thời tiết thất thường',
      titleEn: 'Unpredictable weather',
      sentences: [
        WritingSentence.of(
          'Thời tiết năm nay thất thường hơn mọi năm.',
          'The weather this year is more unpredictable than usual.',
          G.comparison,
        ),
        WritingSentence.of(
          'Mùa đông năm nay đến muộn hơn năm ngoái.',
          'Winter came later this year than last year.',
          G.comparison,
          alternatives: ['This year, winter came later than last year.'],
        ),
        WritingSentence.of(
          'Vài cơn bão đã được dự báo cho tháng tới.',
          'Several storms have been forecast for next month.',
          G.passive,
        ),
        WritingSentence.of(
          'Tôi đã bắt đầu xem dự báo thời tiết mỗi sáng.',
          'I have started checking the weather forecast every morning.',
          G.presentPerfect,
          alternatives: [
            'I have started to check the weather forecast every morning.',
          ],
        ),
        WritingSentence.of(
          'Tuần trước, khi tôi đang làm việc ở văn phòng, trời đột nhiên trở lạnh.',
          'Last week, while I was working at the office, it suddenly turned cold.',
          G.pastContinuous,
          alternatives: [
            'Last week, while I was working at the office, it suddenly got cold.',
          ],
        ),
        WritingSentence.of(
          'Nếu thời tiết cứ thay đổi như vậy, nông dân sẽ gặp nhiều khó khăn.',
          'If the weather keeps changing like this, farmers will face many difficulties.',
          G.conditional1,
          alternatives: [
            'If the weather keeps changing like this, farmers will have many problems.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'weather_i6',
      level: _i,
      titleVi: 'Mùa xuân',
      titleEn: 'Spring',
      sentences: [
        WritingSentence.of(
          'Mùa xuân là mùa tôi yêu thích.',
          'Spring is my favorite season.',
          G.presentSimple,
          alternatives: ['Spring is my favourite season.'],
        ),
        WritingSentence.of(
          'Thời tiết ấm hơn mùa đông nhưng không nóng bằng mùa hè.',
          'The weather is warmer than in winter, but not as hot as in summer.',
          G.comparison,
        ),
        WritingSentence.of(
          'Cây cối được phủ đầy lá xanh non.',
          'The trees are covered with fresh green leaves.',
          G.passive,
          alternatives: ['The trees are covered in fresh green leaves.'],
        ),
        WritingSentence.of(
          'Gần như sáng nào cũng có mưa phùn nhẹ.',
          'There is light drizzle almost every morning.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi đã trồng vài chậu hoa trên ban công.',
          'I have planted a few pots of flowers on the balcony.',
          G.presentPerfect,
          alternatives: ['I have planted some flowers on the balcony.'],
        ),
        WritingSentence.of(
          'Nếu trời vẫn ấm, hoa sẽ nở vào tuần sau.',
          'If it stays warm, the flowers will bloom next week.',
          G.conditional1,
          alternatives: [
            'If it is still warm, the flowers will bloom next week.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'weather_i7',
      level: _i,
      titleVi: 'Lũ lụt miền Trung',
      titleEn: 'Floods in central Vietnam',
      sentences: [
        WritingSentence.of(
          'Tháng mười năm ngoái, miền Trung bị lũ lụt nặng.',
          'Last October, central Vietnam had serious floods.',
          G.pastSimple,
          alternatives: [
            'Last October, central Vietnam suffered serious floods.',
          ],
        ),
        WritingSentence.of(
          'Hàng nghìn ngôi nhà bị ngập.',
          'Thousands of houses were flooded.',
          G.passive,
          alternatives: ['Thousands of homes were flooded.'],
        ),
        WritingSentence.of(
          'Trong khi nước đang dâng lên, người dân mang đồ đạc lên tầng trên.',
          'While the water was rising, people carried their things upstairs.',
          G.pastContinuous,
          alternatives: [
            'While the water was rising, people moved their belongings upstairs.',
          ],
        ),
        WritingSentence.of(
          'Nhiều tình nguyện viên đã đến giúp đỡ họ.',
          'Many volunteers came to help them.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Đó là trận lũ tồi tệ nhất trong hai mươi năm.',
          'It was the worst flood in twenty years.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu có lũ lần nữa, chính quyền sẽ sơ tán người dân sớm hơn.',
          'If there is another flood, the authorities will evacuate people earlier.',
          G.conditional1,
          alternatives: [
            'If there is another flood, the government will move people out earlier.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'weather_i8',
      level: _i,
      titleVi: 'Ngắm hoàng hôn',
      titleEn: 'Watching the sunset',
      sentences: [
        WritingSentence.of(
          'Tôi rất thích ngắm hoàng hôn trên biển.',
          'I love watching the sunset over the sea.',
          G.presentSimple,
          alternatives: ['I like watching the sunset over the sea.'],
        ),
        WritingSentence.of(
          'Hoàng hôn ở đây đẹp hơn ở thành phố.',
          'Sunsets here are more beautiful than in the city.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tối qua, khi chúng tôi đang ngồi trên bãi biển, bầu trời chuyển sang màu cam.',
          'Last night, while we were sitting on the beach, the sky turned orange.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nhiều bức ảnh đẹp đã được chụp.',
          'Many beautiful photos were taken.',
          G.passive,
        ),
        WritingSentence.of(
          'Tôi đã ngắm nhiều lần hoàng hôn, nhưng lần này đẹp nhất.',
          'I have seen many sunsets, but this was the best.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu ngày mai trời quang, chúng tôi sẽ dậy sớm ngắm bình minh.',
          'If the sky is clear tomorrow, we will get up early to watch the sunrise.',
          G.conditional1,
          alternatives: [
            'If it is clear tomorrow, we will get up early to see the sunrise.',
          ],
        ),
      ],
    ),

    // ---------------- Nang cao ----------------
    WritingParagraph(
      id: 'weather_a1',
      level: _a,
      titleVi: 'Biến đổi khí hậu',
      titleEn: 'Climate change',
      sentences: [
        WritingSentence.of(
          'Biến đổi khí hậu, vốn từng được xem là vấn đề của tương lai, giờ đã ảnh hưởng đến cuộc sống hằng ngày.',
          'Climate change, which was once seen as a future problem, now affects our daily lives.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Các nhà khoa học đã và đang cảnh báo về vấn đề này trong nhiều thập kỷ.',
          'Scientists have been warning about this problem for decades.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Mực nước biển đã dâng lên đáng kể từ khi ông bà tôi còn trẻ.',
          'Sea levels have risen significantly since my grandparents were young.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu chúng ta giảm khí thải từ hai mươi năm trước, tình hình đã không trở nên nghiêm trọng như vậy.',
          'If we had reduced emissions twenty years ago, the situation would not have become so serious.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Đến giữa thế kỷ này, nhiều thành phố ven biển sẽ bị ngập một phần.',
          'By the middle of this century, many coastal cities will have been partly flooded.',
          G.futurePerfect,
        ),
        WritingSentence.of(
          'Mỗi người có thể góp phần bằng những thay đổi nhỏ trong thói quen hằng ngày.',
          'Everyone can contribute by making small changes to their daily habits.',
          G.modal,
        ),
      ],
    ),
    WritingParagraph(
      id: 'weather_a2',
      level: _a,
      titleVi: 'Mùa bão ở quê',
      titleEn: 'Storm season back home',
      sentences: [
        WritingSentence.of(
          'Quê tôi ở Quảng Bình, nơi hầu như năm nào cũng có bão.',
          'My hometown is in Quang Binh, where there are storms almost every year.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Năm tôi mười tuổi, một cơn bão lớn đã quét qua làng trước khi mọi người kịp chuẩn bị xong.',
          'When I was ten, a huge storm hit the village before anyone had finished preparing.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Trời đã mưa suốt ba ngày thì nước sông bắt đầu tràn vào nhà.',
          'It had been raining for three days when the river began to flood our house.',
          G.pastPerfectContinuous,
        ),
        WritingSentence.of(
          'Bố tôi kể rằng ông chưa bao giờ thấy nước lên nhanh đến vậy.',
          'My father said that he had never seen the water rise so quickly.',
          G.reportedSpeech,
          alternatives: [
            'My dad said that he had never seen the water rise so quickly.',
          ],
        ),
        WritingSentence.of(
          'Nếu khi đó có hệ thống cảnh báo sớm, nhiều gia đình đã không mất hết tài sản.',
          'If there had been an early warning system, many families would not have lost everything.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Ngày nay, người dân được hướng dẫn cách gia cố nhà cửa trước mùa bão.',
          'Today, people are taught how to strengthen their houses before the storm season.',
          G.passive,
        ),
      ],
    ),
    WritingParagraph(
      id: 'weather_a3',
      level: _a,
      titleVi: 'Ô nhiễm không khí',
      titleEn: 'Air pollution',
      sentences: [
        WritingSentence.of(
          'Vào những ngày chất lượng không khí kém, bầu trời Hà Nội bị phủ bởi một lớp khói mù.',
          'On days when the air quality is poor, the sky over Hanoi is covered by a layer of smog.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Cả tháng nay, tôi đều đeo khẩu trang mỗi khi ra ngoài.',
          'I have been wearing a mask whenever I go out all month.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Bác sĩ nói với tôi rằng bụi mịn có thể gây ra các bệnh về phổi.',
          'My doctor told me that fine dust could cause lung diseases.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu nhiều người đi phương tiện công cộng hơn, không khí sẽ sạch hơn nhiều.',
          'If more people used public transport, the air would be much cleaner.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Thành phố đã trồng hàng nghìn cây xanh trong những năm gần đây.',
          'The city has planted thousands of trees in recent years.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Vào giờ này năm sau, tuyến tàu điện mới sẽ đang chở hàng nghìn hành khách mỗi ngày.',
          'This time next year, the new metro line will be carrying thousands of passengers every day.',
          G.futureContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'weather_a4',
      level: _a,
      titleVi: 'Chuyến leo núi gặp mưa',
      titleEn: 'A hike in the rain',
      sentences: [
        WritingSentence.of(
          'Chúng tôi đã leo được nửa đường lên Fansipan thì mây đen kéo đến.',
          'We had climbed halfway up Fansipan when dark clouds appeared.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Người hướng dẫn, người đã leo ngọn núi này hàng trăm lần, bảo chúng tôi dừng lại.',
          'Our guide, who had climbed the mountain hundreds of times, told us to stop.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Anh ấy giải thích rằng đường mòn sẽ rất trơn sau cơn mưa.',
          'He explained that the trail would be very slippery after the rain.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Chúng tôi đã đợi trong một túp lều nhỏ gần hai tiếng đồng hồ.',
          'We waited in a small hut for nearly two hours.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Nếu chúng tôi cứ tiếp tục leo, có lẽ đã có người bị thương.',
          'If we had kept climbing, someone might have been injured.',
          G.conditional3,
          alternatives: [
            'If we had continued climbing, someone might have got hurt.',
          ],
        ),
        WritingSentence.of(
          'Lần sau, tôi sẽ xem dự báo thời tiết kỹ hơn trước khi đi.',
          'Next time, I will check the weather forecast more carefully before going.',
          G.futureSimple,
          alternatives: [
            'Next time, I will check the weather forecast more carefully before I go.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'weather_a5',
      level: _a,
      titleVi: 'Nghề dự báo thời tiết',
      titleEn: 'Life as a weather forecaster',
      sentences: [
        WritingSentence.of(
          'Chị họ tôi, người làm dự báo viên thời tiết, luôn phải theo dõi bản đồ vệ tinh.',
          'My cousin, who works as a weather forecaster, always has to follow satellite maps.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Chị ấy đã làm công việc này được hơn tám năm.',
          'She has been doing this job for over eight years.',
          G.presentPerfectContinuous,
          alternatives: [
            'She has been doing this job for more than eight years.',
          ],
        ),
        WritingSentence.of(
          'Chị kể với tôi rằng dự báo bây giờ chính xác hơn trước rất nhiều.',
          'She told me that forecasts were much more accurate now than before.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Tuy vậy, bão vẫn có thể đổi hướng bất ngờ chỉ trong vài giờ.',
          'However, storms can still change direction unexpectedly within a few hours.',
          G.modal,
        ),
        WritingSentence.of(
          'Nếu một bản dự báo bị sai, hàng nghìn người có thể gặp nguy hiểm.',
          'If a forecast were wrong, thousands of people could be in danger.',
          G.conditional2,
          alternatives: [
            'If a forecast was wrong, thousands of people could be in danger.',
          ],
        ),
        WritingSentence.of(
          'Đến tối nay, chị ấy sẽ làm việc liên tục được mười hai tiếng vì cơn bão sắp đổ bộ.',
          'By tonight, she will have worked for twelve hours straight because of the coming storm.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'weather_a6',
      level: _a,
      titleVi: 'Mùa khô ở Tây Nguyên',
      titleEn: 'The dry season in the Central Highlands',
      sentences: [
        WritingSentence.of(
          'Tây Nguyên, nơi trồng phần lớn cà phê của Việt Nam, có một mùa khô rất khắc nghiệt.',
          'The Central Highlands, where most of Vietnam\'s coffee is grown, has a very harsh dry season.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Năm ngoái, trời không mưa suốt bốn tháng liền.',
          'Last year, it did not rain for four months in a row.',
          G.pastSimple,
          alternatives: [
            'Last year, it didn\'t rain for four months in a row.',
          ],
        ),
        WritingSentence.of(
          'Đến khi mưa cuối cùng cũng tới, nhiều cây cà phê đã chết khô.',
          'By the time the rain finally came, many coffee plants had died.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Nông dân đã phải khoan giếng sâu hơn mỗi năm.',
          'Farmers have had to dig deeper wells every year.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu nhà nước đầu tư vào hệ thống tưới tiêu, nông dân sẽ bớt phụ thuộc vào mưa.',
          'If the government invested in irrigation, farmers would depend less on rain.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Một số chuyên gia đã đề xuất rằng nông dân nên trồng xen cây ăn quả để giữ ẩm cho đất.',
          'Some experts have suggested that farmers should grow fruit trees among the coffee to keep the soil moist.',
          G.reportedSpeech,
        ),
      ],
    ),
    WritingParagraph(
      id: 'weather_a7',
      level: _a,
      titleVi: 'Tuyết đầu mùa ở Nhật',
      titleEn: 'My first snow in Japan',
      sentences: [
        WritingSentence.of(
          'Trước khi sang Nhật du học, tôi chưa bao giờ nhìn thấy tuyết.',
          'Before I went to study in Japan, I had never seen snow.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Sáng hôm đó, khi tôi thức dậy, tuyết đã rơi suốt cả đêm.',
          'That morning, it had been snowing all night when I woke up.',
          G.pastPerfectContinuous,
        ),
        WritingSentence.of(
          'Cả thành phố được phủ một lớp trắng dày.',
          'The whole city was covered in a thick white layer.',
          G.passive,
        ),
        WritingSentence.of(
          'Bạn cùng phòng người Nhật nói với tôi rằng năm đó tuyết đến sớm hơn thường lệ.',
          'My Japanese roommate told me that the snow had come earlier than usual that year.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu tôi không đi du học, có lẽ tôi đã không bao giờ có trải nghiệm đó.',
          'If I had not studied abroad, I might never have had that experience.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Mùa đông năm sau, tôi sẽ đang trượt tuyết ở Hokkaido cùng các bạn.',
          'Next winter, I will be skiing in Hokkaido with my friends.',
          G.futureContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'weather_a8',
      level: _a,
      titleVi: 'Thời tiết và tâm trạng',
      titleEn: 'Weather and mood',
      sentences: [
        WritingSentence.of(
          'Nhiều nghiên cứu đã chỉ ra rằng thời tiết có thể ảnh hưởng đến tâm trạng của chúng ta.',
          'Many studies have shown that the weather can affect our mood.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Những người sống ở nơi ít nắng thường dễ buồn hơn vào mùa đông.',
          'People who live in places with little sunshine often feel sadder in winter.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Tôi nhận ra rằng mình đã thấy mệt mỏi suốt cả tuần mưa vừa rồi.',
          'I realized that I had been feeling tired throughout the whole rainy week.',
          G.pastPerfectContinuous,
          alternatives: [
            'I realised that I had been feeling tired throughout the whole rainy week.',
          ],
        ),
        WritingSentence.of(
          'Nếu trời nắng hơn, có lẽ tôi đã ra ngoài tập thể dục thay vì nằm ở nhà.',
          'If it had been sunnier, I would probably have gone out to exercise instead of lying at home.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Bác sĩ khuyên tôi nên ra ngoài ít nhất ba mươi phút mỗi ngày.',
          'My doctor advised me to go outside for at least thirty minutes a day.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Từ nay, dù thời tiết thế nào, tôi sẽ cố gắng giữ tinh thần tích cực.',
          'From now on, whatever the weather, I will try to stay positive.',
          G.futureSimple,
        ),
      ],
    ),
  ],
);

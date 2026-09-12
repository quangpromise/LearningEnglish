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

const kWritingBankCity = WritingTopic(
  id: 'city',
  titleVi: 'Thành phố',
  titleEn: 'The City',
  icon: Icons.location_city_rounded,
  color: AppColors.blue,
  paragraphs: [
    // ---------------- Co ban ----------------
    WritingParagraph(
      id: 'city_b1',
      level: _b,
      titleVi: 'Thành phố của tôi',
      titleEn: 'My city',
      sentences: [
        WritingSentence.of(
          'Tôi sống ở một thành phố lớn.',
          'I live in a big city.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Có nhiều toà nhà cao ở đây.',
          'There are many tall buildings here.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Đường phố luôn đông đúc.',
          'The streets are always busy.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi thích sống ở thành phố.',
          'I like living in the city.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Có nhiều việc để làm ở đây.',
          'There are many things to do here.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'city_b2',
      level: _b,
      titleVi: 'Đi dạo phố',
      titleEn: 'A walk in the city',
      sentences: [
        WritingSentence.of(
          'Bây giờ tôi đang đi dạo phố.',
          'Now I am walking in the city.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Nhiều người đang mua sắm.',
          'Many people are shopping.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Đèn đường đang bật sáng.',
          'The street lights are turning on.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Tôi có thể nghe tiếng còi xe.',
          'I can hear car horns.',
          G.modal,
        ),
        WritingSentence.of(
          'Tôi sẽ ăn tối ở một nhà hàng.',
          'I will have dinner at a restaurant.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'city_b3',
      level: _b,
      titleVi: 'Công viên trung tâm',
      titleEn: 'The central park',
      sentences: [
        WritingSentence.of(
          'Thành phố tôi có một công viên lớn.',
          'My city has a big park.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi thường đến đó vào cuối tuần.',
          'I often go there at the weekend.',
          G.presentSimple,
          alternatives: ['I often go there on the weekend.'],
        ),
        WritingSentence.of(
          'Trẻ em chơi ở đó mỗi ngày.',
          'Children play there every day.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi đã đi dạo ở đó hôm qua.',
          'I walked there yesterday.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Nó rất yên tĩnh và xanh mát.',
          'It was very peaceful and green.',
          G.pastSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'city_b4',
      level: _b,
      titleVi: 'Chuyển đến thành phố',
      titleEn: 'Moving to the city',
      sentences: [
        WritingSentence.of(
          'Năm ngoái gia đình tôi đã chuyển đến thành phố.',
          'Last year my family moved to the city.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Chúng tôi đã sống ở quê trước đó.',
          'We lived in the countryside before.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Lúc đầu tôi đã nhớ nhà.',
          'At first I missed home.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Bây giờ tôi thích cuộc sống ở đây.',
          'Now I like life here.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi đã có nhiều bạn mới.',
          'I made many new friends.',
          G.pastSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'city_b5',
      level: _b,
      titleVi: 'Toà nhà cao nhất',
      titleEn: 'The tallest building',
      sentences: [
        WritingSentence.of(
          'Thành phố tôi có một toà nhà rất cao.',
          'My city has a very tall building.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi chưa từng lên đó.',
          'I did not go to the top before.',
          G.pastSimple,
          alternatives: ['I didn\'t go to the top before.'],
        ),
        WritingSentence.of(
          'Cuối tuần này, tôi định lên tầng thượng.',
          'This weekend, I am going to go to the rooftop.',
          G.goingTo,
        ),
        WritingSentence.of(
          'Tôi sẽ chụp nhiều ảnh.',
          'I will take many photos.',
          G.futureSimple,
          alternatives: ['I will take many pictures.'],
        ),
        WritingSentence.of(
          'Cảnh sẽ rất đẹp vào buổi tối.',
          'The view will be beautiful at night.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'city_b6',
      level: _b,
      titleVi: 'Phố đi bộ',
      titleEn: 'The walking street',
      sentences: [
        WritingSentence.of(
          'Cuối tuần thành phố tôi có phố đi bộ.',
          'My city has a walking street on weekends.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tối qua tôi đã đi cùng bạn bè.',
          'Last night I went with my friends.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Chúng tôi đã xem một buổi biểu diễn.',
          'We watched a performance.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã ăn nhiều món ăn đường phố.',
          'I ate a lot of street food.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Chúng tôi đã rất vui.',
          'We had a great time.',
          G.pastSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'city_b7',
      level: _b,
      titleVi: 'Đường phố về đêm',
      titleEn: 'The city at night',
      sentences: [
        WritingSentence.of(
          'Bây giờ trời đã tối.',
          'It is dark now.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Đèn ở khắp mọi nơi đang bật sáng.',
          'Lights are shining everywhere.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Người ta đang đi ăn tối.',
          'People are going out for dinner.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Tôi thích ngắm thành phố về đêm.',
          'I like watching the city at night.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Nó trông rất đẹp.',
          'It looks very beautiful.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'city_b8',
      level: _b,
      titleVi: 'Chợ đêm',
      titleEn: 'A night market',
      sentences: [
        WritingSentence.of(
          'Thành phố tôi có một chợ đêm.',
          'My city has a night market.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Nó mở cửa từ sáu giờ tối.',
          'It opens from six in the evening.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Có rất nhiều quầy hàng ở đó.',
          'There are many stalls there.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi định đi vào tối mai.',
          'I am going to go there tomorrow night.',
          G.goingTo,
        ),
        WritingSentence.of(
          'Tôi sẽ mua quà cho bạn bè.',
          'I will buy gifts for my friends.',
          G.futureSimple,
        ),
      ],
    ),

    // ---------------- Trung cap ----------------
    WritingParagraph(
      id: 'city_i1',
      level: _i,
      titleVi: 'Chi phí sống ở thành phố',
      titleEn: 'The cost of city life',
      sentences: [
        WritingSentence.of(
          'Sống ở thành phố đắt đỏ hơn ở quê rất nhiều.',
          'Living in the city is much more expensive than in the countryside.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tiền thuê nhà đã tăng trong năm nay.',
          'Rent has increased this year.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nhiều căn hộ được xây gần các tuyến tàu điện.',
          'Many apartments are built near metro lines.',
          G.passive,
        ),
        WritingSentence.of(
          'Tôi đã sống ở thành phố được hai năm.',
          'I have lived in the city for two years.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Tuần trước, trong khi tôi đang tìm nhà, tôi gặp một người bạn cũ.',
          'Last week, while I was looking for an apartment, I met an old friend.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nếu giá thuê tiếp tục tăng, tôi sẽ chuyển ra ngoại ô.',
          'If rent keeps rising, I will move to the suburbs.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'city_i2',
      level: _i,
      titleVi: 'Kiến trúc cổ giữa lòng thành phố',
      titleEn: 'Old architecture in the city',
      sentences: [
        WritingSentence.of(
          'Nhiều ngôi nhà cổ đã bị phá bỏ để xây các toà nhà mới.',
          'Many old houses have been demolished to build new buildings.',
          G.passive,
        ),
        WritingSentence.of(
          'Khu phố cổ nhỏ hơn tôi tưởng.',
          'The old quarter was smaller than I imagined.',
          G.comparison,
        ),
        WritingSentence.of(
          'Một số toà nhà được xây từ thời Pháp thuộc.',
          'Some buildings were built during the French colonial period.',
          G.passive,
        ),
        WritingSentence.of(
          'Trong khi tôi đang đi bộ, tôi phát hiện một quán cà phê rất cổ.',
          'While I was walking, I discovered a very old café.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi đã chụp nhiều ảnh để lưu giữ.',
          'I have taken many photos to keep as memories.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu thành phố không bảo tồn những nơi này, chúng ta sẽ mất lịch sử.',
          'If the city does not preserve these places, we will lose our history.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'city_i3',
      level: _i,
      titleVi: 'Tắc đường giờ cao điểm',
      titleEn: 'Rush hour in the city',
      sentences: [
        WritingSentence.of(
          'Giờ cao điểm ở thành phố tồi tệ hơn tôi tưởng.',
          'Rush hour in the city is worse than I expected.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nhiều tuyến đường được mở rộng gần đây.',
          'Many roads have been widened recently.',
          G.passive,
        ),
        WritingSentence.of(
          'Tôi đã đi làm bằng tàu điện được một tháng.',
          'I have commuted by metro for a month.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Sáng qua, trong khi tôi đang đợi tàu, tôi gặp một đồng nghiệp cũ.',
          'Yesterday morning, while I was waiting for the train, I met an old colleague.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Đi tàu điện nhanh hơn đi xe máy vào giờ cao điểm.',
          'The metro is faster than a motorbike during rush hour.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu thành phố có thêm tuyến tàu, giao thông sẽ đỡ tắc hơn.',
          'If the city builds more metro lines, traffic will be less congested.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'city_i4',
      level: _i,
      titleVi: 'Không gian xanh trong thành phố',
      titleEn: 'Green space in the city',
      sentences: [
        WritingSentence.of(
          'Thành phố tôi có ít cây xanh hơn nhiều thành phố khác.',
          'My city has less greenery than many other cities.',
          G.comparison,
        ),
        WritingSentence.of(
          'Một dự án trồng cây mới đã được khởi động năm nay.',
          'A new tree planting project has been launched this year.',
          G.passive,
        ),
        WritingSentence.of(
          'Tôi đã tham gia trồng cây ở khu phố mình.',
          'I have joined a tree planting event in my neighborhood.',
          G.presentPerfect,
          alternatives: [
            'I have joined a tree planting event in my neighbourhood.',
          ],
        ),
        WritingSentence.of(
          'Trong khi chúng tôi đang trồng cây, một nhóm học sinh đến giúp.',
          'While we were planting trees, a group of students came to help.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Không khí sạch hơn ở những khu vực nhiều cây xanh.',
          'The air is cleaner in areas with more trees.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu thành phố trồng thêm cây, mùa hè sẽ mát hơn.',
          'If the city plants more trees, summers will be cooler.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'city_i5',
      level: _i,
      titleVi: 'Sống trong căn hộ nhỏ',
      titleEn: 'Living in a small apartment',
      sentences: [
        WritingSentence.of(
          'Căn hộ của tôi nhỏ hơn phòng tôi ở quê rất nhiều.',
          'My apartment is much smaller than my room back home.',
          G.comparison,
        ),
        WritingSentence.of(
          'Đồ đạc được sắp xếp gọn gàng để tiết kiệm không gian.',
          'Furniture is arranged neatly to save space.',
          G.passive,
        ),
        WritingSentence.of(
          'Tôi đã học được cách sống tối giản.',
          'I have learned to live minimally.',
          G.presentPerfect,
          alternatives: ['I have learnt to live minimally.'],
        ),
        WritingSentence.of(
          'Tuần trước, trong khi tôi đang dọn dẹp, tôi tìm thấy nhiều thứ không cần thiết.',
          'Last week, while I was cleaning, I found many unnecessary things.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Sống nhỏ gọn giúp tôi tiết kiệm tiền hơn.',
          'Living small helps me save more money.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu tôi cần thêm không gian, tôi sẽ chuyển đến căn hộ lớn hơn.',
          'If I need more space, I will move to a bigger apartment.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'city_i6',
      level: _i,
      titleVi: 'Cầu vượt cho người đi bộ',
      titleEn: 'A pedestrian bridge',
      sentences: [
        WritingSentence.of(
          'Một cây cầu vượt mới đã được xây gần trường tôi.',
          'A new pedestrian bridge has been built near my school.',
          G.passive,
        ),
        WritingSentence.of(
          'Nó an toàn hơn băng qua đường trực tiếp.',
          'It is safer than crossing the road directly.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tôi đã dùng nó mỗi ngày kể từ khi được xây.',
          'I have used it every day since it was built.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Sáng nay, trong khi tôi đang đi qua cầu, tôi thấy toàn cảnh con phố.',
          'This morning, while I was crossing the bridge, I saw the whole street.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nhiều người già vẫn thích băng qua đường trực tiếp hơn.',
          'Many elderly people still prefer to cross the road directly.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu có thêm cầu vượt, số tai nạn sẽ giảm.',
          'If there are more bridges, the number of accidents will fall.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'city_i7',
      level: _i,
      titleVi: 'Người vô gia cư trong thành phố',
      titleEn: 'Homelessness in the city',
      sentences: [
        WritingSentence.of(
          'Số người vô gia cư đã tăng trong mùa đông này.',
          'The number of homeless people has increased this winter.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Một trung tâm hỗ trợ mới được mở gần công viên.',
          'A new support center has been opened near the park.',
          G.passive,
          alternatives: ['A new support centre has been opened near the park.'],
        ),
        WritingSentence.of(
          'Tôi đã làm tình nguyện viên ở đó được một tháng.',
          'I have volunteered there for a month.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Tối qua, trong khi tôi đang phát cơm, tôi nói chuyện với một cụ ông.',
          'Last night, while I was handing out meals, I talked with an old man.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Cuộc sống của ông ấy khó khăn hơn tôi tưởng.',
          'His life was harder than I imagined.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu tôi có thời gian, tôi sẽ tình nguyện thường xuyên hơn.',
          'If I have time, I will volunteer more often.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'city_i8',
      level: _i,
      titleVi: 'Chợ truyền thống',
      titleEn: 'A traditional market',
      sentences: [
        WritingSentence.of(
          'Chợ truyền thống ở giữa thành phố cũ hơn siêu thị rất nhiều.',
          'The traditional market in the middle of the city is much older than the supermarket.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nhiều gian hàng được truyền qua nhiều thế hệ.',
          'Many stalls have been passed down through generations.',
          G.passive,
        ),
        WritingSentence.of(
          'Tôi đã đi chợ này từ khi còn nhỏ.',
          'I have gone to this market since I was little.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Sáng nay, trong khi tôi đang mua rau, một cô bán hàng nhận ra tôi.',
          'This morning, while I was buying vegetables, a seller recognized me.',
          G.pastContinuous,
          alternatives: [
            'This morning, while I was buying vegetables, a seller recognised me.',
          ],
        ),
        WritingSentence.of(
          'Đồ ở đây rẻ hơn ở các cửa hàng lớn.',
          'Things here are cheaper than at big stores.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu chợ bị dỡ bỏ, nhiều gia đình sẽ mất công việc.',
          'If the market is torn down, many families will lose their jobs.',
          G.conditional1,
        ),
      ],
    ),

    // ---------------- Nang cao ----------------
    WritingParagraph(
      id: 'city_a1',
      level: _a,
      titleVi: 'Đô thị hoá',
      titleEn: 'Urbanization',
      sentences: [
        WritingSentence.of(
          'Trong ba mươi năm qua, hàng triệu người đã rời nông thôn để đến các thành phố lớn.',
          'Over the past thirty years, millions of people have left the countryside for big cities.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Những khu vực từng là ruộng lúa, nơi ông bà tôi từng làm việc, giờ là các khu công nghiệp.',
          'The areas that were once rice fields, where my grandparents used to work, are now industrial zones.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Trước khi thành phố mở rộng, làng của ông bà tôi đã có hơn một trăm năm lịch sử.',
          'Before the city expanded, my grandparents\' village had had over a hundred years of history.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Một nhà quy hoạch đô thị nói rằng tốc độ đô thị hoá nhanh hơn khả năng xây dựng hạ tầng.',
          'An urban planner said that the pace of urbanization was faster than the ability to build infrastructure.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu quy hoạch được làm cẩn thận hơn, thành phố sẽ tránh được nhiều vấn đề như ngập lụt và tắc đường.',
          'If planning were done more carefully, the city would avoid many problems like flooding and traffic jams.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Đến năm hai nghìn năm mươi, phần lớn dân số thế giới sẽ sống ở thành phố.',
          'By the middle of the century, most of the world\'s population will be living in cities.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'city_a2',
      level: _a,
      titleVi: 'Thành phố thông minh',
      titleEn: 'Smart cities',
      sentences: [
        WritingSentence.of(
          'Khái niệm thành phố thông minh, nơi cảm biến theo dõi mọi thứ từ giao thông đến rác thải, đang được nhiều nước theo đuổi.',
          'The concept of smart cities, where sensors track everything from traffic to waste, is being pursued by many countries.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Một số thành phố đã và đang lắp camera thông minh để giảm ùn tắc.',
          'Some cities have been installing smart cameras to reduce congestion.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Một quan chức thành phố nói rằng dữ liệu này sẽ giúp lập kế hoạch giao thông chính xác hơn.',
          'A city official said that this data would help plan traffic more accurately.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Tuy nhiên, một số công dân lo ngại rằng quyền riêng tư của họ sẽ bị xâm phạm.',
          'However, some citizens worry that their privacy will be violated.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Nếu dữ liệu được bảo vệ đúng cách, lợi ích sẽ lớn hơn rủi ro.',
          'If the data is protected properly, the benefits will outweigh the risks.',
          G.conditional1,
        ),
        WritingSentence.of(
          'Đến khi công nghệ này phổ biến, cách chúng ta sống trong thành phố sẽ đã thay đổi đáng kể.',
          'By the time this technology becomes common, the way we live in cities will have changed significantly.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'city_a3',
      level: _a,
      titleVi: 'Gentrification',
      titleEn: 'Gentrification',
      sentences: [
        WritingSentence.of(
          'Khu phố nơi tôi lớn lên, từng là nơi ở của các gia đình lao động, giờ đầy những quán cà phê sang trọng.',
          'The neighborhood where I grew up, which used to be home to working class families, is now full of upscale cafés.',
          G.relativeClause,
          alternatives: [
            'The neighbourhood where I grew up, which used to be home to working-class families, is now full of upscale cafés.',
          ],
        ),
        WritingSentence.of(
          'Giá thuê nhà đã tăng gấp đôi trong năm năm qua.',
          'Rent has doubled over the past five years.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nhiều gia đình sống lâu năm đã buộc phải chuyển đi nơi khác.',
          'Many long-time families have been forced to move elsewhere.',
          G.passive,
        ),
        WritingSentence.of(
          'Một cư dân lâu năm nói rằng bà đã không còn nhận ra khu phố của mình nữa.',
          'A long-time resident said that she no longer recognized her own neighborhood.',
          G.reportedSpeech,
          alternatives: [
            'A long-time resident said that she no longer recognised her own neighbourhood.',
          ],
        ),
        WritingSentence.of(
          'Nếu chính quyền kiểm soát giá thuê, những gia đình này sẽ không bị đẩy đi.',
          'If the authorities controlled rents, these families would not be pushed out.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Trước khi khu phố thay đổi, cộng đồng ở đây đã gắn bó với nhau suốt nhiều thế hệ.',
          'Before the neighborhood changed, the community here had been close for generations.',
          G.pastPerfect,
          alternatives: [
            'Before the neighbourhood changed, the community here had been close for generations.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'city_a4',
      level: _a,
      titleVi: 'Hội chứng cô đơn đô thị',
      titleEn: 'Urban loneliness',
      sentences: [
        WritingSentence.of(
          'Nghịch lý là sống giữa hàng triệu người lại có thể khiến ta cảm thấy cô đơn hơn ở nơi vắng vẻ.',
          'Ironically, living among millions of people can make you feel lonelier than in an isolated place.',
          G.comparison,
        ),
        WritingSentence.of(
          'Một nghiên cứu gần đây cho thấy người trẻ ở thành phố báo cáo mức độ cô đơn cao hơn người già ở nông thôn.',
          'A recent study has found that young people in cities report higher levels of loneliness than older people in rural areas.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Hàng xóm của tôi, người sống một mình suốt mười năm, thừa nhận rằng anh hiếm khi nói chuyện với ai ngoài công việc.',
          'My neighbor, who has lived alone for ten years, admitted that he rarely talked to anyone outside work.',
          G.relativeClause,
          alternatives: [
            'My neighbour, who has lived alone for ten years, admitted that he rarely talked to anyone outside work.',
          ],
        ),
        WritingSentence.of(
          'Nếu các khu chung cư có nhiều không gian chung hơn, hàng xóm sẽ dễ kết nối hơn.',
          'If apartment complexes had more shared spaces, neighbors would connect more easily.',
          G.conditional2,
          alternatives: [
            'If apartment complexes had more shared spaces, neighbours would connect more easily.',
          ],
        ),
        WritingSentence.of(
          'Một số thành phố đã và đang tổ chức các sự kiện cộng đồng để kết nối cư dân.',
          'Some cities have been organizing community events to connect residents.',
          G.presentPerfectContinuous,
          alternatives: [
            'Some cities have been organising community events to connect residents.',
          ],
        ),
        WritingSentence.of(
          'Trước khi chuyển đến chung cư này, tôi chưa từng nghĩ mình sẽ nhớ những cuộc trò chuyện đơn giản đến vậy.',
          'Before I moved into this building, I had never thought I would miss simple conversations so much.',
          G.pastPerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'city_a5',
      level: _a,
      titleVi: 'Bảo tồn di sản đô thị',
      titleEn: 'Preserving urban heritage',
      sentences: [
        WritingSentence.of(
          'Khu phố cổ, nơi mỗi con phố mang tên một mặt hàng truyền thống, đang đối mặt với áp lực phát triển.',
          'The old quarter, where every street is named after a traditional trade, is facing development pressure.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Nhiều ngôi nhà cổ đã bị bán cho các nhà đầu tư trước khi luật bảo tồn được ban hành.',
          'Many old houses had been sold to investors before preservation laws were passed.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Một kiến trúc sư giải thích rằng việc sửa chữa nhà cổ tốn kém hơn xây mới rất nhiều.',
          'An architect explained that restoring old houses cost much more than building new ones.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu chính phủ hỗ trợ tài chính cho việc bảo tồn, nhiều chủ nhà sẽ chọn giữ lại kiến trúc cũ.',
          'If the government provided financial support for preservation, more homeowners would choose to keep the old architecture.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Một số tổ chức phi chính phủ đã và đang ghi lại hình ảnh những ngôi nhà có nguy cơ biến mất.',
          'Some NGOs have been documenting houses at risk of disappearing.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Nếu không hành động sớm, thế hệ sau sẽ chỉ biết đến khu phố này qua ảnh cũ.',
          'If action is not taken soon, future generations will only know this quarter through old photos.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'city_a6',
      level: _a,
      titleVi: 'Ô nhiễm ánh sáng',
      titleEn: 'Light pollution',
      sentences: [
        WritingSentence.of(
          'Trẻ em sống ở thành phố lớn hiếm khi nhìn thấy các ngôi sao vào ban đêm.',
          'Children living in big cities rarely see stars at night.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Ánh sáng nhân tạo đã che khuất bầu trời đêm trong nhiều thập kỷ.',
          'Artificial light has been blocking out the night sky for decades.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Một nhà thiên văn học nói rằng ông đã phải lái xe hàng giờ để tìm được bầu trời tối thật sự.',
          'An astronomer said that he had had to drive for hours to find a truly dark sky.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu thành phố dùng đèn được thiết kế tốt hơn, ô nhiễm ánh sáng sẽ giảm đáng kể.',
          'If cities used better designed lighting, light pollution would decrease significantly.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Trước khi có đèn đường điện, con người từng nhìn thấy dải Ngân Hà mỗi đêm.',
          'Before electric street lighting existed, people used to see the Milky Way every night.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Một số thành phố đã bắt đầu tắt bớt đèn công cộng vào ban đêm để tiết kiệm năng lượng và giảm ô nhiễm ánh sáng.',
          'Some cities have started turning off some public lights at night to save energy and reduce light pollution.',
          G.presentPerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'city_a7',
      level: _a,
      titleVi: 'Khu ổ chuột và cải tạo đô thị',
      titleEn: 'Slums and urban renewal',
      sentences: [
        WritingSentence.of(
          'Khu vực ven kênh, nơi từng là một trong những khu nghèo nhất thành phố, đã được cải tạo hoàn toàn.',
          'The area along the canal, which used to be one of the poorest parts of the city, has been completely renovated.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Trước khi dự án bắt đầu, hàng trăm gia đình đã sống trong những căn nhà tạm bợ ven bờ kênh.',
          'Before the project started, hundreds of families had lived in makeshift houses along the canal bank.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Chính quyền cam kết rằng mọi gia đình sẽ được cấp nhà tái định cư.',
          'The authorities promised that every family would be given resettlement housing.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu quá trình di dời không được thực hiện công bằng, nhiều gia đình sẽ mất kế sinh nhai.',
          'If the relocation process is not carried out fairly, many families will lose their livelihoods.',
          G.conditional1,
        ),
        WritingSentence.of(
          'Con kênh, thứ từng bốc mùi hôi thối, giờ được bao quanh bởi những con đường đi bộ sạch đẹp.',
          'The canal, which used to smell terrible, is now surrounded by clean walking paths.',
          G.passive,
        ),
        WritingSentence.of(
          'Đến năm sau, toàn bộ dự án cải tạo sẽ hoàn thành.',
          'By next year, the whole renewal project will have been completed.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'city_a8',
      level: _a,
      titleVi: 'Tương lai của thành phố',
      titleEn: 'The future of the city',
      sentences: [
        WritingSentence.of(
          'Các nhà quy hoạch tin rằng thành phố trong tương lai sẽ được thiết kế xoay quanh con người thay vì ô tô.',
          'Planners believe that future cities will be designed around people rather than cars.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Khái niệm "thành phố mười lăm phút", nơi mọi thứ cần thiết nằm trong tầm đi bộ, đang thu hút sự chú ý.',
          'The "fifteen minute city" concept, where everything needed is within walking distance, is attracting attention.',
          G.relativeClause,
          alternatives: [
            'The "fifteen-minute city" concept, where everything needed is within walking distance, is attracting attention.',
          ],
        ),
        WritingSentence.of(
          'Một số thành phố ở châu Âu đã và đang thử nghiệm mô hình này.',
          'Some cities in Europe have been testing this model.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Nếu ý tưởng này thành công, chúng ta sẽ ít phụ thuộc vào xe hơi hơn nhiều.',
          'If this idea succeeds, we will depend much less on cars.',
          G.conditional1,
        ),
        WritingSentence.of(
          'Trước khi mô hình này được thử nghiệm, hầu hết các thành phố hiện đại đã được xây dựng dựa trên giao thông ô tô.',
          'Before this model was tested, most modern cities had been built around car traffic.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Tôi tin rằng đến khi tôi già đi, các thành phố sẽ trở nên xanh hơn và dễ sống hơn nhiều.',
          'I believe that by the time I am old, cities will have become much greener and more livable.',
          G.futurePerfect,
        ),
      ],
    ),
  ],
);

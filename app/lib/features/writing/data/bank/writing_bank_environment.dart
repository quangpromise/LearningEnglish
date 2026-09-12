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

const kWritingBankEnvironment = WritingTopic(
  id: 'environment',
  titleVi: 'Môi trường',
  titleEn: 'Environment',
  icon: Icons.eco_rounded,
  color: AppColors.teal,
  paragraphs: [
    // ---------------- Co ban ----------------
    WritingParagraph(
      id: 'environment_b1',
      level: _b,
      titleVi: 'Giữ trường sạch đẹp',
      titleEn: 'A clean school',
      sentences: [
        WritingSentence.of(
          'Trường tôi rất sạch.',
          'My school is very clean.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Chúng tôi không vứt rác trên sân.',
          'We do not throw rubbish in the yard.',
          G.presentSimple,
          alternatives: [
            'We don\'t throw trash in the yard.',
            'We do not throw litter in the yard.',
          ],
        ),
        WritingSentence.of(
          'Mỗi lớp có một thùng rác.',
          'Every class has a rubbish bin.',
          G.presentSimple,
          alternatives: [
            'Every class has a trash can.',
            'Each class has a bin.',
          ],
        ),
        WritingSentence.of(
          'Hôm nay chúng tôi đang trồng cây.',
          'Today we are planting trees.',
          G.presentContinuous,
          alternatives: ['We are planting trees today.'],
        ),
        WritingSentence.of(
          'Chúng ta nên bảo vệ cây xanh.',
          'We should protect trees.',
          G.modal,
          alternatives: ['We should protect the trees.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'environment_b2',
      level: _b,
      titleVi: 'Tiết kiệm nước',
      titleEn: 'Saving water',
      sentences: [
        WritingSentence.of(
          'Nước rất quan trọng.',
          'Water is very important.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi tắt vòi khi đánh răng.',
          'I turn off the tap when I brush my teeth.',
          G.presentSimple,
          alternatives: ['I turn off the faucet when I brush my teeth.'],
        ),
        WritingSentence.of(
          'Mẹ tôi dùng nước rửa rau để tưới cây.',
          'My mother waters the plants with used water.',
          G.presentSimple,
          alternatives: ['My mom waters the plants with used water.'],
        ),
        WritingSentence.of(
          'Chúng ta không nên lãng phí nước.',
          'We should not waste water.',
          G.modal,
          alternatives: ['We shouldn\'t waste water.'],
        ),
        WritingSentence.of(
          'Tôi sẽ nhắc bạn bè làm như vậy.',
          'I will tell my friends to do the same.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'environment_b3',
      level: _b,
      titleVi: 'Dọn bãi biển',
      titleEn: 'Cleaning the beach',
      sentences: [
        WritingSentence.of(
          'Chủ nhật tuần trước, lớp tôi đã đi dọn bãi biển.',
          'Last Sunday, my class cleaned the beach.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Chúng tôi đã nhặt rất nhiều chai nhựa.',
          'We picked up a lot of plastic bottles.',
          G.pastSimple,
          alternatives: ['We collected a lot of plastic bottles.'],
        ),
        WritingSentence.of(
          'Tôi đã tìm thấy một chiếc dép cũ.',
          'I found an old sandal.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Bãi biển trở nên sạch đẹp.',
          'The beach became clean and beautiful.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Chúng tôi đã rất tự hào.',
          'We were very proud.',
          G.pastSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'environment_b4',
      level: _b,
      titleVi: 'Phân loại rác',
      titleEn: 'Sorting rubbish',
      sentences: [
        WritingSentence.of(
          'Nhà tôi có hai thùng rác.',
          'My house has two bins.',
          G.presentSimple,
          alternatives: ['We have two bins at home.'],
        ),
        WritingSentence.of(
          'Một thùng dành cho giấy và nhựa.',
          'One is for paper and plastic.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Thùng kia dành cho thức ăn thừa.',
          'The other is for food waste.',
          G.presentSimple,
          alternatives: ['The other one is for food waste.'],
        ),
        WritingSentence.of(
          'Em trai tôi đang học cách phân loại rác.',
          'My brother is learning to sort rubbish.',
          G.presentContinuous,
          alternatives: ['My brother is learning how to sort the trash.'],
        ),
        WritingSentence.of(
          'Nó có thể làm rất tốt.',
          'He can do it very well.',
          G.modal,
        ),
      ],
    ),
    WritingParagraph(
      id: 'environment_b5',
      level: _b,
      titleVi: 'Đi xe đạp',
      titleEn: 'Riding a bike',
      sentences: [
        WritingSentence.of(
          'Tôi đi học bằng xe đạp.',
          'I go to school by bike.',
          G.presentSimple,
          alternatives: [
            'I ride my bike to school.',
            'I go to school by bicycle.',
          ],
        ),
        WritingSentence.of(
          'Xe đạp không làm ô nhiễm không khí.',
          'Bikes do not pollute the air.',
          G.presentSimple,
          alternatives: ['Bicycles don\'t pollute the air.'],
        ),
        WritingSentence.of(
          'Nó cũng tốt cho sức khỏe.',
          'It is also good for your health.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Năm sau, anh trai tôi định đi xe đạp đi làm.',
          'Next year, my brother is going to cycle to work.',
          G.goingTo,
          alternatives: [
            'Next year, my brother is going to ride a bike to work.',
          ],
        ),
        WritingSentence.of(
          'Bố tôi sẽ đi xe buýt.',
          'My father will take the bus.',
          G.futureSimple,
          alternatives: ['My dad will take the bus.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'environment_b6',
      level: _b,
      titleVi: 'Túi vải',
      titleEn: 'A cloth bag',
      sentences: [
        WritingSentence.of(
          'Mẹ tôi luôn mang túi vải khi đi chợ.',
          'My mother always takes a cloth bag to the market.',
          G.presentSimple,
          alternatives: ['My mom always takes a cloth bag to the market.'],
        ),
        WritingSentence.of(
          'Mẹ không dùng túi ni lông.',
          'She does not use plastic bags.',
          G.presentSimple,
          alternatives: ['She doesn\'t use plastic bags.'],
        ),
        WritingSentence.of(
          'Túi ni lông có hại cho môi trường.',
          'Plastic bags are bad for the environment.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi đang trang trí một chiếc túi vải.',
          'I am decorating a cloth bag.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Tôi sẽ tặng nó cho bà.',
          'I will give it to my grandmother.',
          G.futureSimple,
          alternatives: ['I will give it to my grandma.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'environment_b7',
      level: _b,
      titleVi: 'Ngày Trái Đất',
      titleEn: 'Earth Day',
      sentences: [
        WritingSentence.of(
          'Hôm nay là Ngày Trái Đất.',
          'Today is Earth Day.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Chúng tôi tắt đèn trong một giờ.',
          'We turn off the lights for one hour.',
          G.presentSimple,
          alternatives: ['We switch off the lights for an hour.'],
        ),
        WritingSentence.of(
          'Cả nhà đang ngồi ngoài ban công.',
          'My family is sitting on the balcony.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Chúng tôi có thể nhìn thấy các ngôi sao.',
          'We can see the stars.',
          G.modal,
        ),
        WritingSentence.of(
          'Tôi thích Ngày Trái Đất.',
          'I like Earth Day.',
          G.presentSimple,
          alternatives: ['I love Earth Day.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'environment_b8',
      level: _b,
      titleVi: 'Công viên gần nhà',
      titleEn: 'The park near my house',
      sentences: [
        WritingSentence.of(
          'Gần nhà tôi có một công viên.',
          'There is a park near my house.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Công viên có nhiều cây và hoa.',
          'The park has many trees and flowers.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Hôm qua, tôi đã thấy rác ở đó.',
          'Yesterday, I saw rubbish there.',
          G.pastSimple,
          alternatives: [
            'Yesterday, I saw trash there.',
            'Yesterday, I saw litter there.',
          ],
        ),
        WritingSentence.of(
          'Tôi đã nhặt nó và bỏ vào thùng.',
          'I picked it up and put it in the bin.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Mọi người phải giữ công viên sạch sẽ.',
          'Everyone must keep the park clean.',
          G.modal,
        ),
      ],
    ),

    // ---------------- Trung cap ----------------
    WritingParagraph(
      id: 'environment_i1',
      level: _i,
      titleVi: 'Rác nhựa',
      titleEn: 'Plastic waste',
      sentences: [
        WritingSentence.of(
          'Rác nhựa là một trong những vấn đề lớn nhất hiện nay.',
          'Plastic waste is one of the biggest problems today.',
          G.comparison,
        ),
        WritingSentence.of(
          'Hàng triệu tấn nhựa bị thải ra biển mỗi năm.',
          'Millions of tons of plastic are dumped into the sea every year.',
          G.passive,
          alternatives: [
            'Millions of tonnes of plastic are dumped into the sea every year.',
          ],
        ),
        WritingSentence.of(
          'Tôi đã ngừng dùng ống hút nhựa được sáu tháng.',
          'I have not used plastic straws for six months.',
          G.presentPerfect,
          alternatives: ['I haven\'t used plastic straws for six months.'],
        ),
        WritingSentence.of(
          'Ống hút tre bền hơn tôi nghĩ.',
          'Bamboo straws are stronger than I thought.',
          G.comparison,
        ),
        WritingSentence.of(
          'Hôm qua, khi tôi đang đi dạo trên biển, tôi thấy một con rùa mắc lưới.',
          'Yesterday, while I was walking on the beach, I saw a trapped turtle.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nếu mọi người giảm dùng nhựa, biển sẽ sạch hơn.',
          'If people use less plastic, the sea will be cleaner.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'environment_i2',
      level: _i,
      titleVi: 'Trồng cây gây rừng',
      titleEn: 'Planting a forest',
      sentences: [
        WritingSentence.of(
          'Câu lạc bộ của tôi đã trồng hơn năm trăm cây.',
          'My club has planted more than five hundred trees.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Những cái cây được trồng trên một ngọn đồi trống.',
          'The trees were planted on a bare hill.',
          G.passive,
        ),
        WritingSentence.of(
          'Ngọn đồi bây giờ xanh hơn trước nhiều.',
          'The hill is much greener than before.',
          G.comparison,
        ),
        WritingSentence.of(
          'Trong khi chúng tôi đang đào hố, trời bắt đầu mưa.',
          'While we were digging holes, it started to rain.',
          G.pastContinuous,
          alternatives: ['While we were digging holes, it began to rain.'],
        ),
        WritingSentence.of(
          'Mưa giúp cây non lớn nhanh hơn.',
          'The rain helps young trees grow faster.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu có thêm tình nguyện viên, chúng tôi sẽ trồng một khu rừng nhỏ.',
          'If we get more volunteers, we will plant a small forest.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'environment_i3',
      level: _i,
      titleVi: 'Dòng sông quê tôi',
      titleEn: 'The river in my hometown',
      sentences: [
        WritingSentence.of(
          'Dòng sông ở quê tôi đã bị ô nhiễm nhiều năm.',
          'The river in my hometown has been polluted for years.',
          G.passive,
        ),
        WritingSentence.of(
          'Ngày xưa, nước sông trong hơn bây giờ rất nhiều.',
          'In the past, the water was much clearer than it is now.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nhiều nhà máy đã xả nước thải xuống sông.',
          'Many factories have released waste water into the river.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Hè năm ngoái, khi tôi đang câu cá, tôi thấy nhiều cá chết.',
          'Last summer, while I was fishing, I saw many dead fish.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Người dân đã viết thư cho chính quyền.',
          'Local people have written to the authorities.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu các nhà máy không thay đổi, dòng sông sẽ chết.',
          'If the factories do not change, the river will die.',
          G.conditional1,
          alternatives: ['If the factories don\'t change, the river will die.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'environment_i4',
      level: _i,
      titleVi: 'Tiết kiệm điện',
      titleEn: 'Saving electricity',
      sentences: [
        WritingSentence.of(
          'Hoá đơn tiền điện tháng này cao hơn tháng trước.',
          'This month\'s electricity bill is higher than last month\'s.',
          G.comparison,
        ),
        WritingSentence.of(
          'Điều hoà được bật gần như cả ngày.',
          'The air conditioner was turned on almost all day.',
          G.passive,
          alternatives: ['The air conditioner was on almost all day.'],
        ),
        WritingSentence.of(
          'Gia đình tôi đã quyết định tiết kiệm điện.',
          'My family has decided to save electricity.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Tối qua, trong khi chúng tôi đang xem ti vi, bố tắt hết những bóng đèn thừa.',
          'Last night, while we were watching TV, Dad turned off the extra lights.',
          G.pastContinuous,
          alternatives: [
            'Last night, while we were watching TV, Dad switched off the extra lights.',
          ],
        ),
        WritingSentence.of(
          'Bóng đèn LED tiết kiệm điện hơn bóng đèn cũ.',
          'LED bulbs use less electricity than old bulbs.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu chúng tôi cố gắng, hoá đơn tháng sau sẽ thấp hơn.',
          'If we try hard, next month\'s bill will be lower.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'environment_i5',
      level: _i,
      titleVi: 'Ô nhiễm tiếng ồn',
      titleEn: 'Noise pollution',
      sentences: [
        WritingSentence.of(
          'Khu phố của tôi ồn ào hơn trước rất nhiều.',
          'My neighborhood is much noisier than it used to be.',
          G.comparison,
          alternatives: [
            'My neighbourhood is much noisier than it used to be.',
          ],
        ),
        WritingSentence.of(
          'Một toà nhà mới đang được xây ở cuối phố.',
          'A new building is being built at the end of the street.',
          G.passive,
        ),
        WritingSentence.of(
          'Tôi đã không ngủ ngon suốt một tháng nay.',
          'I have not slept well for a month.',
          G.presentPerfect,
          alternatives: ['I haven\'t slept well for a month.'],
        ),
        WritingSentence.of(
          'Sáng nay, trong khi tôi đang học, máy khoan chạy suốt hai tiếng.',
          'This morning, while I was studying, a drill was running for two hours.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tiếng ồn có thể gây hại cho sức khỏe.',
          'Noise can be harmful to our health.',
          G.modal,
        ),
        WritingSentence.of(
          'Nếu tiếng ồn tiếp tục, chúng tôi sẽ báo với phường.',
          'If the noise continues, we will complain to the local office.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'environment_i6',
      level: _i,
      titleVi: 'Vườn rau ở trường',
      titleEn: 'The school garden',
      sentences: [
        WritingSentence.of(
          'Trường tôi vừa làm một vườn rau nhỏ.',
          'My school has just made a small vegetable garden.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Rau được tưới bằng nước mưa.',
          'The vegetables are watered with rainwater.',
          G.passive,
        ),
        WritingSentence.of(
          'Rau ở đây ngon hơn rau ngoài chợ.',
          'The vegetables here taste better than those at the market.',
          G.comparison,
        ),
        WritingSentence.of(
          'Hôm qua, trong khi chúng tôi đang nhổ cỏ, một con giun bò lên tay tôi.',
          'Yesterday, while we were pulling weeds, a worm crawled onto my hand.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi đã học được nhiều điều về thiên nhiên.',
          'I have learned a lot about nature.',
          G.presentPerfect,
          alternatives: ['I have learnt a lot about nature.'],
        ),
        WritingSentence.of(
          'Nếu vườn phát triển tốt, chúng tôi sẽ bán rau gây quỹ.',
          'If the garden grows well, we will sell vegetables to raise money.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'environment_i7',
      level: _i,
      titleVi: 'Động vật hoang dã',
      titleEn: 'Wild animals',
      sentences: [
        WritingSentence.of(
          'Nhiều loài động vật đang bị đe doạ vì mất rừng.',
          'Many animals are threatened because of forest loss.',
          G.passive,
        ),
        WritingSentence.of(
          'Tê giác Java đã biến mất khỏi Việt Nam.',
          'The Javan rhino has disappeared from Vietnam.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Voọc chà vá là một trong những loài linh trưởng đẹp nhất thế giới.',
          'The douc langur is one of the most beautiful primates in the world.',
          G.comparison,
        ),
        WritingSentence.of(
          'Khi chúng tôi đang đi bộ ở Sơn Trà, chúng tôi đã nhìn thấy một đàn voọc.',
          'While we were hiking in Son Tra, we saw a group of langurs.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Chúng hiếm hơn tôi tưởng.',
          'They are rarer than I thought.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu rừng bị chặt, những loài này sẽ biến mất.',
          'If the forests are cut down, these animals will disappear.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'environment_i8',
      level: _i,
      titleVi: 'Tái chế đồ cũ',
      titleEn: 'Upcycling old things',
      sentences: [
        WritingSentence.of(
          'Chị tôi thích biến đồ cũ thành đồ mới.',
          'My sister loves turning old things into new ones.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Chị ấy đã làm nhiều chậu cây từ chai nhựa.',
          'She has made many plant pots from plastic bottles.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Chiếc đèn này được làm từ một cái lọ thuỷ tinh.',
          'This lamp was made from a glass jar.',
          G.passive,
        ),
        WritingSentence.of(
          'Nó đẹp hơn những chiếc đèn trong cửa hàng.',
          'It is more beautiful than the lamps in the shops.',
          G.comparison,
        ),
        WritingSentence.of(
          'Hôm qua, trong khi chị ấy đang cắt chai, chị bị đứt tay.',
          'Yesterday, while she was cutting a bottle, she cut her finger.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nếu chị ấy mở một lớp học, tôi sẽ đăng ký đầu tiên.',
          'If she opens a class, I will be the first to sign up.',
          G.conditional1,
        ),
      ],
    ),

    // ---------------- Nang cao ----------------
    WritingParagraph(
      id: 'environment_a1',
      level: _a,
      titleVi: 'Rừng ngập mặn',
      titleEn: 'Mangrove forests',
      sentences: [
        WritingSentence.of(
          'Rừng ngập mặn, nơi nhiều loài cá sinh sản, bảo vệ bờ biển khỏi bão và sóng lớn.',
          'Mangrove forests, where many fish breed, protect the coast from storms and big waves.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Trong nhiều thập kỷ, rừng ngập mặn ở Cà Mau đã bị chặt để làm đầm nuôi tôm.',
          'For decades, mangroves in Ca Mau have been cut down to make shrimp farms.',
          G.passive,
        ),
        WritingSentence.of(
          'Khi các nhà khoa học nhận ra hậu quả, bờ biển đã bị xói mòn nghiêm trọng.',
          'By the time scientists realized the consequences, the coast had been badly eroded.',
          G.pastPerfect,
          alternatives: [
            'By the time scientists realised the consequences, the coast had been badly eroded.',
          ],
        ),
        WritingSentence.of(
          'Một người dân địa phương kể rằng làng anh đã mất gần một trăm mét đất.',
          'A local man told us that his village had lost almost a hundred meters of land.',
          G.reportedSpeech,
          alternatives: [
            'A local man told us that his village had lost almost a hundred metres of land.',
          ],
        ),
        WritingSentence.of(
          'Nếu rừng được bảo vệ từ sớm, những ngôi làng ấy đã không phải di dời.',
          'If the forests had been protected earlier, those villages would not have had to move.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Gần đây, các tình nguyện viên đã và đang trồng lại hàng nghìn cây đước.',
          'Recently, volunteers have been replanting thousands of mangrove trees.',
          G.presentPerfectContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'environment_a2',
      level: _a,
      titleVi: 'Sống không rác thải',
      titleEn: 'Living with zero waste',
      sentences: [
        WritingSentence.of(
          'Chị họ tôi, người sống một mình ở Đà Nẵng, đã theo lối sống không rác thải được hai năm.',
          'My cousin, who lives alone in Da Nang, has followed a zero waste lifestyle for two years.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Toàn bộ rác chị ấy thải ra trong một năm vừa đủ một chiếc lọ nhỏ.',
          'All the rubbish she produces in a year fits into one small jar.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Trước khi thay đổi, chị ấy đã mua đồ ăn mang về gần như mỗi ngày.',
          'Before she changed, she had bought takeaway food almost every day.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Chị nói với tôi rằng điều khó nhất là từ chối những món quà được gói bằng nhựa.',
          'She told me that the hardest thing was refusing gifts wrapped in plastic.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu ai cũng sống như chị ấy, các bãi rác sẽ nhỏ hơn rất nhiều.',
          'If everyone lived like her, landfills would be much smaller.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Tháng sau, chị ấy sẽ đang hướng dẫn một hội thảo về tiêu dùng bền vững.',
          'Next month, she will be leading a workshop on sustainable living.',
          G.futureContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'environment_a3',
      level: _a,
      titleVi: 'Nước biển dâng ở đồng bằng',
      titleEn: 'Rising seas in the delta',
      sentences: [
        WritingSentence.of(
          'Đồng bằng sông Cửu Long, vựa lúa lớn nhất Việt Nam, đang bị đe doạ bởi nước biển dâng.',
          'The Mekong Delta, which is Vietnam\'s biggest rice bowl, is threatened by rising seas.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Nước mặn đã và đang xâm nhập sâu hơn vào đất liền mỗi mùa khô.',
          'Salt water has been moving further inland every dry season.',
          G.presentPerfectContinuous,
          alternatives: [
            'Salt water has been moving farther inland every dry season.',
          ],
        ),
        WritingSentence.of(
          'Nhiều nông dân đã chuyển sang nuôi tôm vì lúa không thể sống trong nước mặn.',
          'Many farmers have switched to shrimp farming because rice cannot grow in salty water.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Các chuyên gia cảnh báo rằng một phần lớn đồng bằng có thể bị ngập vào cuối thế kỷ.',
          'Experts have warned that a large part of the delta could be flooded by the end of the century.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu các nước giảm khí thải mạnh mẽ, tốc độ nước biển dâng sẽ chậm lại.',
          'If countries cut emissions sharply, sea levels would rise more slowly.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Đến lúc con tôi lớn, bản đồ vùng đồng bằng có lẽ đã thay đổi đáng kể.',
          'By the time my children grow up, the map of the delta will probably have changed significantly.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'environment_a4',
      level: _a,
      titleVi: 'Thời trang nhanh',
      titleEn: 'Fast fashion',
      sentences: [
        WritingSentence.of(
          'Ngành thời trang nhanh, vốn sản xuất quần áo giá rẻ với số lượng lớn, gây ô nhiễm nghiêm trọng.',
          'The fast fashion industry, which produces cheap clothes in huge amounts, causes serious pollution.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Người ta ước tính rằng phải cần hàng nghìn lít nước để làm một chiếc quần jean.',
          'It is estimated that thousands of liters of water are needed to make one pair of jeans.',
          G.passive,
          alternatives: [
            'It is estimated that thousands of litres of water are needed to make one pair of jeans.',
          ],
        ),
        WritingSentence.of(
          'Trước khi xem một bộ phim tài liệu, tôi chưa từng nghĩ về nguồn gốc quần áo của mình.',
          'Before watching a documentary, I had never thought about where my clothes came from.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Bạn tôi hỏi liệu mua đồ cũ có thực sự giúp được môi trường không.',
          'My friend asked whether buying second hand clothes really helped the environment.',
          G.reportedSpeech,
          alternatives: [
            'My friend asked whether buying second-hand clothes really helped the environment.',
          ],
        ),
        WritingSentence.of(
          'Nếu người tiêu dùng mua ít nhưng chất lượng hơn, lượng rác thải dệt may sẽ giảm mạnh.',
          'If consumers bought fewer but better clothes, textile waste would fall dramatically.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Từ đầu năm, tôi đã mua tất cả quần áo ở các cửa hàng đồ cũ.',
          'Since the start of the year, I have bought all my clothes from second hand shops.',
          G.presentPerfect,
          alternatives: [
            'Since the start of the year, I have bought all my clothes from second-hand shops.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'environment_a5',
      level: _a,
      titleVi: 'Cháy rừng',
      titleEn: 'Forest fires',
      sentences: [
        WritingSentence.of(
          'Mùa khô năm ngoái, một đám cháy lớn đã thiêu rụi hàng trăm héc-ta rừng.',
          'Last dry season, a huge fire destroyed hundreds of hectares of forest.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Đám cháy đã âm ỉ suốt nhiều ngày trước khi người ta phát hiện ra.',
          'The fire had been burning for days before anyone noticed it.',
          G.pastPerfectContinuous,
        ),
        WritingSentence.of(
          'Lính cứu hoả, những người làm việc không nghỉ suốt một tuần, cuối cùng đã dập tắt được lửa.',
          'The firefighters, who worked without rest for a week, finally put the fire out.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Chính quyền nói rằng đám cháy có thể do người dân đốt rác gây ra.',
          'The authorities said that the fire might have been caused by people burning rubbish.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu có hệ thống cảnh báo sớm, khu rừng có lẽ đã được cứu.',
          'If there had been an early warning system, the forest might have been saved.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Phải mất nhiều thập kỷ nữa khu rừng mới có thể phục hồi hoàn toàn.',
          'It will take decades for the forest to recover completely.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'environment_a6',
      level: _a,
      titleVi: 'Thành phố xanh',
      titleEn: 'A greener city',
      sentences: [
        WritingSentence.of(
          'Singapore, nơi cây xanh phủ gần một nửa diện tích, thường được gọi là thành phố trong vườn.',
          'Singapore, where trees cover almost half the land, is often called a city in a garden.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Chính phủ nước này đã trồng cây trên mái nhà và tường của nhiều toà nhà.',
          'Its government has planted trees on the roofs and walls of many buildings.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Một kiến trúc sư nói với chúng tôi rằng cây xanh giúp giảm nhiệt độ thành phố vài độ.',
          'An architect told us that plants helped to lower the city\'s temperature by several degrees.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu Hà Nội có nhiều không gian xanh hơn, mùa hè ở đây sẽ dễ chịu hơn nhiều.',
          'If Hanoi had more green spaces, summers here would be much more pleasant.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Gần đây, thành phố đã và đang biến những bãi đất trống thành công viên nhỏ.',
          'Recently, the city has been turning empty plots of land into small parks.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Đến năm sau, khu phố tôi sẽ có thêm ba công viên mới.',
          'By next year, three new parks will have opened in my neighborhood.',
          G.futurePerfect,
          alternatives: [
            'By next year, three new parks will have opened in my neighbourhood.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'environment_a7',
      level: _a,
      titleVi: 'Một nhà hoạt động trẻ',
      titleEn: 'A young activist',
      sentences: [
        WritingSentence.of(
          'Bạn cùng lớp tôi, người mới mười bảy tuổi, đã khởi xướng một chiến dịch chống rác nhựa ở trường.',
          'My classmate, who is only seventeen, has started a campaign against plastic waste at school.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Cô ấy đã thu thập chữ ký của học sinh suốt ba tháng qua.',
          'She has been collecting signatures from students for the past three months.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Trước khi chiến dịch bắt đầu, căng tin đã dùng hàng trăm hộp xốp mỗi ngày.',
          'Before the campaign began, the canteen had used hundreds of foam boxes every day.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Hiệu trưởng hứa rằng nhà trường sẽ cấm đồ nhựa dùng một lần từ học kỳ sau.',
          'The headteacher promised that the school would ban single use plastics from next term.',
          G.reportedSpeech,
          alternatives: [
            'The headteacher promised that the school would ban single-use plastics from next term.',
          ],
        ),
        WritingSentence.of(
          'Nếu cô ấy không kiên trì, có lẽ không có gì thay đổi cả.',
          'If she had not kept going, nothing might have changed.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Tôi ngưỡng mộ cô ấy hơn bất kỳ ai trong lớp.',
          'I admire her more than anyone else in my class.',
          G.comparison,
        ),
      ],
    ),
    WritingParagraph(
      id: 'environment_a8',
      level: _a,
      titleVi: 'Năng lượng tái tạo',
      titleEn: 'Renewable energy',
      sentences: [
        WritingSentence.of(
          'Việt Nam đã trở thành một trong những nước dẫn đầu khu vực về điện mặt trời.',
          'Vietnam has become one of the leading countries in the region for solar power.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Những cánh đồng điện gió ở Bạc Liêu, nơi gió thổi mạnh quanh năm, thu hút rất nhiều du khách.',
          'The wind farms in Bac Lieu, where the wind blows strongly all year, attract many visitors.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Tuy nhiên, một kỹ sư giải thích rằng lưới điện chưa đủ mạnh để truyền hết lượng điện.',
          'However, an engineer explained that the power grid was not strong enough to carry all the electricity.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu chính phủ nâng cấp lưới điện, nhiều nhà máy than có thể đóng cửa.',
          'If the government upgraded the grid, many coal plants could close.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Các công ty năng lượng đã và đang đầu tư mạnh vào pin lưu trữ.',
          'Energy companies have been investing heavily in storage batteries.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Đến giữa thế kỷ này, đất nước sẽ cắt giảm được phần lớn khí thải.',
          'By the middle of the century, the country will have cut most of its emissions.',
          G.futurePerfect,
        ),
      ],
    ),
  ],
);

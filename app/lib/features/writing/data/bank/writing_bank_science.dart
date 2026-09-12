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

const kWritingBankScience = WritingTopic(
  id: 'science',
  titleVi: 'Khoa học',
  titleEn: 'Science',
  icon: Icons.science_rounded,
  color: AppColors.purple,
  paragraphs: [
    // ---------------- Co ban ----------------
    WritingParagraph(
      id: 'science_b1',
      level: _b,
      titleVi: 'Giờ học khoa học',
      titleEn: 'Science class',
      sentences: [
        WritingSentence.of(
          'Tôi thích giờ học khoa học.',
          'I like science class.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Chúng tôi học về cây cối và động vật.',
          'We learn about plants and animals.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Bây giờ chúng tôi đang làm thí nghiệm.',
          'Now we are doing an experiment.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Cô giáo đang giải thích kết quả.',
          'The teacher is explaining the result.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Tôi thấy nó rất thú vị.',
          'I find it very interesting.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'science_b2',
      level: _b,
      titleVi: 'Thí nghiệm núi lửa',
      titleEn: 'A volcano experiment',
      sentences: [
        WritingSentence.of(
          'Hôm qua chúng tôi đã làm mô hình núi lửa.',
          'Yesterday we made a volcano model.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Chúng tôi đã trộn giấm và bột nở.',
          'We mixed vinegar and baking soda.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Nó đã phun trào rất mạnh.',
          'It erupted very strongly.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Cả lớp đã reo hò.',
          'The whole class cheered.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Đó là bài học tôi thích nhất.',
          'That was my favorite lesson.',
          G.pastSimple,
          alternatives: ['That was my favourite lesson.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'science_b3',
      level: _b,
      titleVi: 'Hệ mặt trời',
      titleEn: 'The solar system',
      sentences: [
        WritingSentence.of(
          'Có tám hành tinh trong hệ mặt trời.',
          'There are eight planets in the solar system.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Trái Đất là hành tinh của chúng ta.',
          'Earth is our planet.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Mặt trời rất nóng.',
          'The sun is very hot.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Mặt trăng quay quanh Trái Đất.',
          'The moon goes around the Earth.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi muốn học thêm về vũ trụ.',
          'I want to learn more about space.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'science_b4',
      level: _b,
      titleVi: 'Trồng cây trong lớp',
      titleEn: 'Growing a plant in class',
      sentences: [
        WritingSentence.of(
          'Tuần trước chúng tôi đã trồng một hạt đậu.',
          'Last week we planted a bean seed.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Chúng tôi đã tưới nước mỗi ngày.',
          'We watered it every day.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Nó đã mọc lên rất nhanh.',
          'It grew very quickly.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Bây giờ nó có ba chiếc lá.',
          'Now it has three leaves.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi sẽ chăm sóc nó thật tốt.',
          'I will take good care of it.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'science_b5',
      level: _b,
      titleVi: 'Nam châm',
      titleEn: 'Magnets',
      sentences: [
        WritingSentence.of(
          'Nam châm có thể hút kim loại.',
          'Magnets can attract metal.',
          G.modal,
        ),
        WritingSentence.of(
          'Tôi đang thử nghiệm với một nam châm.',
          'I am experimenting with a magnet.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Nó có thể nhấc một cái kẹp giấy.',
          'It can lift a paperclip.',
          G.modal,
        ),
        WritingSentence.of(
          'Nó không thể hút gỗ.',
          'It cannot attract wood.',
          G.modal,
          alternatives: ['It can\'t attract wood.'],
        ),
        WritingSentence.of(
          'Tôi sẽ thử với các vật khác.',
          'I will try it with other objects.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'science_b6',
      level: _b,
      titleVi: 'Bảo tàng khoa học',
      titleEn: 'A science museum',
      sentences: [
        WritingSentence.of(
          'Tuần sau lớp tôi sẽ đi bảo tàng khoa học.',
          'Next week my class will go to a science museum.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Tôi định xem trưng bày về khủng long.',
          'I am going to see the dinosaur exhibit.',
          G.goingTo,
        ),
        WritingSentence.of(
          'Chúng tôi sẽ chạm vào các mô hình.',
          'We will touch the models.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Tôi có thể học được nhiều điều mới.',
          'I can learn many new things.',
          G.modal,
        ),
        WritingSentence.of(
          'Tôi rất mong chờ chuyến đi.',
          'I am really looking forward to the trip.',
          G.presentContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'science_b7',
      level: _b,
      titleVi: 'Nước sôi và nước đá',
      titleEn: 'Boiling and freezing water',
      sentences: [
        WritingSentence.of(
          'Nước sôi ở một trăm độ.',
          'Water boils at one hundred degrees.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Nước đóng băng ở không độ.',
          'Water freezes at zero degrees.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Bây giờ nước đang sôi trên bếp.',
          'The water is boiling on the stove now.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Chúng ta phải cẩn thận với nước sôi.',
          'We must be careful with boiling water.',
          G.modal,
        ),
        WritingSentence.of(
          'Tôi sẽ đợi nó nguội.',
          'I will wait for it to cool down.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'science_b8',
      level: _b,
      titleVi: 'Khủng long',
      titleEn: 'Dinosaurs',
      sentences: [
        WritingSentence.of(
          'Em trai tôi rất thích khủng long.',
          'My brother loves dinosaurs.',
          G.presentSimple,
          alternatives: ['My younger brother loves dinosaurs.'],
        ),
        WritingSentence.of(
          'Nó biết tên nhiều loại khủng long.',
          'He knows the names of many dinosaurs.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Khủng long đã sống cách đây rất lâu.',
          'Dinosaurs lived a very long time ago.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Chúng đã biến mất khỏi Trái Đất.',
          'They disappeared from Earth.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi thích xem phim về chúng.',
          'I like watching films about them.',
          G.presentSimple,
          alternatives: ['I like watching movies about them.'],
        ),
      ],
    ),

    // ---------------- Trung cap ----------------
    WritingParagraph(
      id: 'science_i1',
      level: _i,
      titleVi: 'Thí nghiệm hoá học',
      titleEn: 'A chemistry experiment',
      sentences: [
        WritingSentence.of(
          'Thí nghiệm này khó hơn tôi tưởng.',
          'This experiment is harder than I expected.',
          G.comparison,
        ),
        WritingSentence.of(
          'Hoá chất được đo rất cẩn thận trước khi trộn.',
          'The chemicals are measured very carefully before mixing.',
          G.passive,
        ),
        WritingSentence.of(
          'Tôi đã làm thí nghiệm này ba lần.',
          'I have done this experiment three times.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Trong khi tôi đang đổ chất lỏng, nó đổi màu ngay lập tức.',
          'While I was pouring the liquid, it changed color immediately.',
          G.pastContinuous,
          alternatives: [
            'While I was pouring the liquid, it changed colour immediately.',
          ],
        ),
        WritingSentence.of(
          'Chúng ta phải đeo kính bảo hộ khi làm thí nghiệm.',
          'We must wear safety glasses when doing experiments.',
          G.modal,
        ),
        WritingSentence.of(
          'Nếu tôi trộn sai tỉ lệ, phản ứng sẽ không xảy ra.',
          'If I mix the wrong ratio, the reaction will not happen.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'science_i2',
      level: _i,
      titleVi: 'Bảo tàng thiên văn',
      titleEn: 'An astronomy museum',
      sentences: [
        WritingSentence.of(
          'Tuần trước, tôi đã đến một bảo tàng thiên văn.',
          'Last week, I visited an astronomy museum.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Vũ trụ rộng lớn hơn tôi có thể tưởng tượng.',
          'The universe is bigger than I can imagine.',
          G.comparison,
        ),
        WritingSentence.of(
          'Mô hình các hành tinh được treo từ trần nhà.',
          'The planet models are hung from the ceiling.',
          G.passive,
        ),
        WritingSentence.of(
          'Trong khi tôi đang xem mô hình sao Hoả, một hướng dẫn viên giải thích về bề mặt của nó.',
          'While I was looking at the Mars model, a guide explained its surface.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi chưa bao giờ biết nhiều về vũ trụ đến vậy.',
          'I have never known so much about the universe.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu có cơ hội, tôi sẽ học thiên văn học ở đại học.',
          'If I get the chance, I will study astronomy at university.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'science_i3',
      level: _i,
      titleVi: 'Robot tự chế',
      titleEn: 'A homemade robot',
      sentences: [
        WritingSentence.of(
          'Nhóm tôi đã chế tạo một robot đơn giản cho hội chợ khoa học.',
          'My group has built a simple robot for the science fair.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nó được điều khiển bằng một chiếc điều khiển từ xa nhỏ.',
          'It is controlled by a small remote control.',
          G.passive,
        ),
        WritingSentence.of(
          'Robot của chúng tôi chậm hơn robot của nhóm khác.',
          'Our robot is slower than the other group\'s robot.',
          G.comparison,
        ),
        WritingSentence.of(
          'Trong khi chúng tôi đang thử nghiệm, một dây điện bị đứt.',
          'While we were testing it, a wire broke.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Chúng tôi đã sửa nó kịp thời trước cuộc thi.',
          'We fixed it in time before the competition.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Nếu chúng tôi thắng, chúng tôi sẽ chế tạo một robot phức tạp hơn.',
          'If we win, we will build a more complex robot.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'science_i4',
      level: _i,
      titleVi: 'Vắc xin',
      titleEn: 'Vaccines',
      sentences: [
        WritingSentence.of(
          'Vắc xin giúp cơ thể chống lại bệnh tật.',
          'Vaccines help the body fight disease.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Nhiều bệnh nguy hiểm đã được kiểm soát nhờ vắc xin.',
          'Many dangerous diseases have been controlled thanks to vaccines.',
          G.passive,
        ),
        WritingSentence.of(
          'Tôi đã tiêm vắc xin cúm tuần trước.',
          'I got a flu vaccine last week.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Trong khi y tá đang tiêm cho tôi, tôi đã nhìn đi chỗ khác.',
          'While the nurse was giving me the injection, I looked away.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nó ít đau hơn tôi tưởng.',
          'It hurt less than I expected.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu bạn chưa tiêm, bạn nên đi tiêm sớm.',
          'If you have not been vaccinated, you should get it soon.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'science_i5',
      level: _i,
      titleVi: 'Năng lượng mặt trời',
      titleEn: 'Solar energy',
      sentences: [
        WritingSentence.of(
          'Năng lượng mặt trời sạch hơn năng lượng từ than đá.',
          'Solar energy is cleaner than energy from coal.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tấm pin mặt trời được lắp trên mái nhà.',
          'Solar panels are installed on the roof.',
          G.passive,
        ),
        WritingSentence.of(
          'Gia đình tôi đã dùng năng lượng mặt trời được một năm.',
          'My family has used solar energy for a year.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Trong khi trời đang nắng, các tấm pin sản xuất rất nhiều điện.',
          'While it is sunny, the panels produce a lot of electricity.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Hoá đơn tiền điện của chúng tôi thấp hơn trước rất nhiều.',
          'Our electricity bill is much lower than before.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu nhiều nhà lắp pin mặt trời, môi trường sẽ tốt hơn.',
          'If more houses install solar panels, the environment will be better.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'science_i6',
      level: _i,
      titleVi: 'Nhật thực',
      titleEn: 'A solar eclipse',
      sentences: [
        WritingSentence.of(
          'Tháng trước, có một hiện tượng nhật thực.',
          'Last month, there was a solar eclipse.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Bầu trời trở nên tối hơn bình thường.',
          'The sky became darker than usual.',
          G.comparison,
        ),
        WritingSentence.of(
          'Mọi người được khuyên nên đeo kính đặc biệt.',
          'Everyone was advised to wear special glasses.',
          G.passive,
        ),
        WritingSentence.of(
          'Trong khi mặt trăng đang che khuất mặt trời, đám đông reo hò.',
          'While the moon was blocking the sun, the crowd cheered.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi chưa bao giờ thấy hiện tượng nào kỳ diệu như vậy.',
          'I have never seen anything so amazing.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu có nhật thực lần nữa, tôi sẽ chuẩn bị kính từ sớm.',
          'If there is another eclipse, I will prepare glasses early.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'science_i7',
      level: _i,
      titleVi: 'Hội chợ khoa học',
      titleEn: 'A science fair',
      sentences: [
        WritingSentence.of(
          'Trường tôi tổ chức hội chợ khoa học mỗi năm.',
          'My school holds a science fair every year.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Mỗi dự án được chấm điểm bởi ba giám khảo.',
          'Each project is judged by three judges.',
          G.passive,
        ),
        WritingSentence.of(
          'Dự án của tôi năm nay tốt hơn năm ngoái.',
          'My project this year is better than last year\'s.',
          G.comparison,
        ),
        WritingSentence.of(
          'Trong khi tôi đang trình bày, giám khảo hỏi tôi một câu khó.',
          'While I was presenting, a judge asked me a hard question.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi đã trả lời được nhờ đã chuẩn bị kỹ.',
          'I was able to answer because I had prepared well.',
          G.modal,
        ),
        WritingSentence.of(
          'Nếu tôi đạt giải, tôi sẽ tham gia hội chợ cấp thành phố.',
          'If I win a prize, I will join the city-level fair.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'science_i8',
      level: _i,
      titleVi: 'Kính hiển vi',
      titleEn: 'A microscope',
      sentences: [
        WritingSentence.of(
          'Trường tôi vừa mua kính hiển vi mới.',
          'My school has just bought new microscopes.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Chúng mạnh hơn kính hiển vi cũ rất nhiều.',
          'They are much more powerful than the old microscopes.',
          G.comparison,
        ),
        WritingSentence.of(
          'Mẫu vật được đặt dưới kính rất cẩn thận.',
          'The sample is placed under the lens very carefully.',
          G.passive,
        ),
        WritingSentence.of(
          'Trong khi tôi đang nhìn qua kính, tôi thấy những tế bào đang di chuyển.',
          'While I was looking through it, I saw cells moving.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi chưa bao giờ nhìn thấy thứ gì nhỏ như vậy.',
          'I have never seen anything so tiny.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu tôi có kính hiển vi ở nhà, tôi sẽ quan sát mọi thứ.',
          'If I had a microscope at home, I would observe everything.',
          G.conditional1,
        ),
      ],
    ),

    // ---------------- Nang cao ----------------
    WritingParagraph(
      id: 'science_a1',
      level: _a,
      titleVi: 'Chỉnh sửa gen',
      titleEn: 'Gene editing',
      sentences: [
        WritingSentence.of(
          'Công nghệ chỉnh sửa gen, thứ cho phép các nhà khoa học thay đổi DNA một cách chính xác, đang mở ra những khả năng chưa từng có.',
          'Gene editing technology, which allows scientists to alter DNA precisely, is opening up unprecedented possibilities.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Một nhà nghiên cứu giải thích rằng công nghệ này có thể chữa được các bệnh di truyền hiếm gặp.',
          'A researcher explained that this technology could cure rare genetic diseases.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Trước khi công nghệ này ra đời, nhiều bệnh di truyền được coi là không thể chữa được.',
          'Before this technology existed, many genetic diseases had been considered incurable.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Nếu công nghệ này bị lạm dụng, nó có thể dẫn đến những hậu quả đạo đức nghiêm trọng.',
          'If this technology were misused, it could lead to serious ethical consequences.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Nhiều nhà khoa học đã và đang tranh luận về ranh giới đạo đức của việc chỉnh sửa gen ở người.',
          'Many scientists have been debating the ethical limits of editing human genes.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Đến năm hai nghìn năm mươi, công nghệ này có lẽ sẽ đã trở thành phương pháp điều trị phổ biến.',
          'By the middle of the century, this technology will probably have become a common treatment.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'science_a2',
      level: _a,
      titleVi: 'Khám phá hành tinh mới',
      titleEn: 'Discovering a new planet',
      sentences: [
        WritingSentence.of(
          'Các nhà thiên văn học vừa phát hiện một hành tinh mà có thể chứa nước lỏng.',
          'Astronomers have just discovered a planet that may contain liquid water.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Họ đã quan sát ngôi sao này suốt nhiều năm trước khi tìm ra hành tinh đó.',
          'They had been observing this star for years before finding the planet.',
          G.pastPerfectContinuous,
        ),
        WritingSentence.of(
          'Một nhà khoa học nói rằng phát hiện này có thể thay đổi cách chúng ta tìm kiếm sự sống ngoài Trái Đất.',
          'A scientist said that this discovery could change how we search for life beyond Earth.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu hành tinh này thực sự có nước, nó sẽ trở thành mục tiêu quan trọng cho các sứ mệnh tương lai.',
          'If this planet really has water, it will become an important target for future missions.',
          G.conditional1,
        ),
        WritingSentence.of(
          'Kính viễn vọng mới, thứ mạnh hơn bất kỳ kính viễn vọng nào trước đó, sẽ giúp nghiên cứu sâu hơn.',
          'The new telescope, which is more powerful than any before it, will help study it further.',
          G.comparison,
        ),
        WritingSentence.of(
          'Đến khi tàu thăm dò đến nơi, chúng ta sẽ đã chờ đợi kết quả này hơn hai mươi năm.',
          'By the time the probe arrives, we will have been waiting for these results for over twenty years.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'science_a3',
      level: _a,
      titleVi: 'Nhà khoa học nữ tiên phong',
      titleEn: 'A pioneering female scientist',
      sentences: [
        WritingSentence.of(
          'Nhà khoa học mà tôi ngưỡng mộ nhất đã phải đấu tranh để được công nhận trong một ngành do nam giới thống trị.',
          'The scientist I admire most had to fight to be recognized in a male-dominated field.',
          G.relativeClause,
          alternatives: [
            'The scientist I admire most had to fight to be recognised in a male-dominated field.',
          ],
        ),
        WritingSentence.of(
          'Trước khi công trình của bà được công nhận, nhiều đồng nghiệp nam đã nhận công lao thay bà.',
          'Before her work was recognized, many male colleagues had taken credit for it.',
          G.pastPerfect,
          alternatives: [
            'Before her work was recognised, many male colleagues had taken credit for it.',
          ],
        ),
        WritingSentence.of(
          'Bà từng nói rằng khoa học không có giới tính, chỉ có sự tò mò.',
          'She once said that science had no gender, only curiosity.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu bà bỏ cuộc vì bị coi thường, có lẽ khám phá quan trọng đó đã không bao giờ xảy ra.',
          'If she had given up because of being underestimated, that important discovery might never have happened.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Ngày nay, ngày càng nhiều phụ nữ trẻ được truyền cảm hứng để theo đuổi khoa học nhờ câu chuyện của bà.',
          'Today, more and more young women are inspired to pursue science because of her story.',
          G.passive,
        ),
        WritingSentence.of(
          'Đến khi tôi tốt nghiệp đại học, tôi hy vọng lĩnh vực này sẽ cân bằng giới tính hơn nhiều.',
          'By the time I graduate from university, I hope this field will have become much more gender balanced.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'science_a4',
      level: _a,
      titleVi: 'Trí tuệ nhân tạo và khoa học',
      titleEn: 'AI in scientific research',
      sentences: [
        WritingSentence.of(
          'Trí tuệ nhân tạo đang giúp các nhà khoa học phân tích lượng dữ liệu khổng lồ nhanh hơn con người rất nhiều.',
          'Artificial intelligence is helping scientists analyze huge amounts of data much faster than humans.',
          G.comparison,
          alternatives: [
            'Artificial intelligence is helping scientists analyse huge amounts of data much faster than humans.',
          ],
        ),
        WritingSentence.of(
          'Một chương trình AI đã dự đoán cấu trúc của hàng nghìn loại protein chỉ trong vài tháng.',
          'An AI program has predicted the structure of thousands of proteins in just a few months.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Trước khi có công cụ này, các nhà khoa học đã phải mất nhiều năm để nghiên cứu một cấu trúc protein duy nhất.',
          'Before this tool existed, scientists had taken years to study a single protein structure.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Một nhà sinh học phân tử nói rằng công cụ này đã đẩy nhanh nghiên cứu thuốc mới lên rất nhiều.',
          'A molecular biologist said that this tool had sped up new drug research enormously.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu AI tiếp tục phát triển với tốc độ này, nhiều bệnh nan y có thể có thuốc chữa trong vài thập kỷ tới.',
          'If AI continues to develop at this rate, many incurable diseases may have treatments within a few decades.',
          G.conditional1,
        ),
        WritingSentence.of(
          'Tuy nhiên, một số nhà khoa học nhắc nhở rằng AI vẫn cần được con người kiểm chứng cẩn thận.',
          'However, some scientists remind us that AI still needs to be carefully verified by humans.',
          G.passive,
        ),
      ],
    ),
    WritingParagraph(
      id: 'science_a5',
      level: _a,
      titleVi: 'Nghiên cứu vắc xin thần tốc',
      titleEn: 'Rapid vaccine research',
      sentences: [
        WritingSentence.of(
          'Trong đại dịch, các nhà khoa học đã phát triển vắc xin trong thời gian ngắn kỷ lục.',
          'During the pandemic, scientists developed vaccines in record time.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Trước đại dịch, quá trình này thường mất từ năm đến mười năm.',
          'Before the pandemic, this process had usually taken five to ten years.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Một nhà virus học nói rằng thành công này chỉ có thể đạt được nhờ hợp tác quốc tế chưa từng có.',
          'A virologist said that this success had only been possible because of unprecedented international cooperation.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu các quốc gia không chia sẻ dữ liệu nghiên cứu, vắc xin sẽ mất nhiều thời gian hơn để ra đời.',
          'If countries had not shared research data, the vaccine would have taken much longer to develop.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Kể từ đó, các nhà khoa học đã và đang áp dụng phương pháp này cho các bệnh khác.',
          'Since then, scientists have been applying this method to other diseases.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Đến năm sau, một loại vắc xin ung thư mới có thể sẽ được thử nghiệm trên người.',
          'By next year, a new cancer vaccine may be tested on humans.',
          G.passive,
        ),
      ],
    ),
    WritingParagraph(
      id: 'science_a6',
      level: _a,
      titleVi: 'Khoa học công dân',
      titleEn: 'Citizen science',
      sentences: [
        WritingSentence.of(
          'Khoa học công dân, nơi những người không chuyên đóng góp dữ liệu cho các nghiên cứu lớn, đang phát triển nhanh chóng.',
          'Citizen science, where non-experts contribute data to major research, is growing rapidly.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Hàng nghìn người bình thường đã giúp các nhà thiên văn học phân loại hàng triệu bức ảnh thiên hà.',
          'Thousands of ordinary people have helped astronomers classify millions of galaxy photos.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Một người tham gia kể rằng cô đã phát hiện ra một hành tinh mới trong khi làm tình nguyện tại nhà.',
          'A participant said that she had discovered a new planet while volunteering from home.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Trước khi có dự án này, cô chưa từng nghĩ mình có thể đóng góp cho khoa học vũ trụ.',
          'Before this project, she had never thought she could contribute to space science.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Nếu nhiều người tham gia hơn, các nhà khoa học sẽ có nhiều dữ liệu hơn để phân tích.',
          'If more people participate, scientists will have more data to analyze.',
          G.conditional1,
          alternatives: [
            'If more people participate, scientists will have more data to analyse.',
          ],
        ),
        WritingSentence.of(
          'Những dự án này chứng minh rằng khoa học không chỉ dành riêng cho những người có bằng cấp cao.',
          'These projects prove that science is not only for people with advanced degrees.',
          G.passive,
        ),
      ],
    ),
    WritingParagraph(
      id: 'science_a7',
      level: _a,
      titleVi: 'Đạo đức trong nghiên cứu động vật',
      titleEn: 'Animal research ethics',
      sentences: [
        WritingSentence.of(
          'Trong nhiều thập kỷ, động vật đã được sử dụng để thử nghiệm thuốc trước khi đưa vào thử trên người.',
          'For decades, animals have been used to test drugs before they are tried on humans.',
          G.passive,
        ),
        WritingSentence.of(
          'Nhiều nhà hoạt động vì quyền động vật cho rằng phương pháp này gây đau đớn không cần thiết.',
          'Many animal rights activists argue that this method causes unnecessary suffering.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Một nhà khoa học giải thích rằng các phương pháp thay thế, như mô nuôi cấy, đang ngày càng được phát triển.',
          'A scientist explained that alternative methods, such as lab-grown tissue, were being developed more and more.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Trước khi những công nghệ này ra đời, thử nghiệm trên động vật gần như là lựa chọn duy nhất.',
          'Before these technologies existed, animal testing had been almost the only option.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Nếu công nghệ mô nuôi cấy phát triển đủ nhanh, thử nghiệm trên động vật có thể sẽ giảm đáng kể.',
          'If lab-grown tissue technology develops fast enough, animal testing may decrease significantly.',
          G.conditional1,
        ),
        WritingSentence.of(
          'Cuộc tranh luận giữa tiến bộ y học và quyền lợi động vật vẫn tiếp tục cho đến ngày nay.',
          'The debate between medical progress and animal welfare continues to this day.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'science_a8',
      level: _a,
      titleVi: 'Khoa học và niềm tin',
      titleEn: 'Science and belief',
      sentences: [
        WritingSentence.of(
          'Trong suốt lịch sử, những khám phá khoa học mới thường bị chống đối bởi những người tin vào ý tưởng cũ.',
          'Throughout history, new scientific discoveries have often been resisted by people who believed in old ideas.',
          G.passive,
        ),
        WritingSentence.of(
          'Nhà khoa học từng bị chế giễu vì đề xuất rằng Trái Đất quay quanh mặt trời sau này được chứng minh là đúng.',
          'The scientist who was once mocked for suggesting the Earth orbited the sun was later proven right.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Trước khi ý tưởng đó được chấp nhận rộng rãi, ông đã phải chịu đựng sự chỉ trích suốt nhiều năm.',
          'Before that idea was widely accepted, he had endured criticism for many years.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Một sử gia khoa học nói rằng tiến bộ thường đến từ những người dám thách thức niềm tin phổ biến.',
          'A science historian said that progress often came from people who dared to challenge popular belief.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu không ai dám nghi ngờ những gì được coi là chân lý, khoa học sẽ không bao giờ tiến bộ.',
          'If no one dared to question what was considered truth, science would never advance.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Tôi tin rằng sự tò mò và sẵn sàng đặt câu hỏi luôn là động lực thật sự của khoa học.',
          'I believe that curiosity and a willingness to question are always the true driving force of science.',
          G.presentSimple,
        ),
      ],
    ),
  ],
);

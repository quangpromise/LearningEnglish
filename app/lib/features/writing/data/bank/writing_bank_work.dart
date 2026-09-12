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

const kWritingBankWork = WritingTopic(
  id: 'work',
  titleVi: 'Công việc',
  titleEn: 'Work',
  icon: Icons.work_rounded,
  color: AppColors.amber,
  paragraphs: [
    // ---------------- Co ban ----------------
    WritingParagraph(
      id: 'work_b1',
      level: _b,
      titleVi: 'Công việc của tôi',
      titleEn: 'My job',
      sentences: [
        WritingSentence.of(
          'Tôi là nhân viên văn phòng.',
          'I am an office worker.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi làm việc ở một công ty nhỏ.',
          'I work at a small company.',
          G.presentSimple,
          alternatives: [
            'I work in a small company.',
            'I work for a small company.',
          ],
        ),
        WritingSentence.of(
          'Tôi bắt đầu làm việc lúc tám giờ.',
          'I start work at eight o\'clock.',
          G.presentSimple,
          alternatives: [
            'I start work at eight.',
            'I start working at eight o\'clock.',
          ],
        ),
        WritingSentence.of(
          'Tôi ăn trưa với đồng nghiệp.',
          'I have lunch with my colleagues.',
          G.presentSimple,
          alternatives: ['I eat lunch with my coworkers.'],
        ),
        WritingSentence.of(
          'Tôi về nhà lúc năm giờ rưỡi.',
          'I go home at half past five.',
          G.presentSimple,
          alternatives: ['I go home at five thirty.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'work_b2',
      level: _b,
      titleVi: 'Một ngày bận rộn',
      titleEn: 'A busy day',
      sentences: [
        WritingSentence.of(
          'Hôm nay tôi rất bận.',
          'I am very busy today.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi đang viết một bản báo cáo.',
          'I am writing a report.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Sếp của tôi đang gọi điện cho khách hàng.',
          'My boss is calling a customer.',
          G.presentContinuous,
          alternatives: ['My boss is calling a client.'],
        ),
        WritingSentence.of(
          'Các đồng nghiệp của tôi đang họp.',
          'My colleagues are having a meeting.',
          G.presentContinuous,
          alternatives: ['My coworkers are having a meeting.'],
        ),
        WritingSentence.of(
          'Tôi phải làm xong trước sáu giờ.',
          'I must finish before six o\'clock.',
          G.modal,
          alternatives: [
            'I have to finish before six.',
            'I must finish before six.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'work_b3',
      level: _b,
      titleVi: 'Ngày đầu đi làm',
      titleEn: 'My first day at work',
      sentences: [
        WritingSentence.of(
          'Hôm qua là ngày đầu tiên tôi đi làm.',
          'Yesterday was my first day at work.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã rất lo lắng.',
          'I was very nervous.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Mọi người đã chào đón tôi.',
          'Everyone welcomed me.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Quản lý đã dẫn tôi đi xem văn phòng.',
          'My manager showed me around the office.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã học được nhiều điều mới.',
          'I learned many new things.',
          G.pastSimple,
          alternatives: [
            'I learnt many new things.',
            'I learned a lot of new things.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'work_b4',
      level: _b,
      titleVi: 'Kế hoạch tuần sau',
      titleEn: 'Next week\'s plan',
      sentences: [
        WritingSentence.of(
          'Tuần sau, tôi định đi gặp một khách hàng.',
          'Next week, I am going to visit a client.',
          G.goingTo,
          alternatives: ['Next week, I am going to meet a client.'],
        ),
        WritingSentence.of(
          'Tôi sẽ đi Hải Phòng bằng tàu hoả.',
          'I will go to Hai Phong by train.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Tôi định mang theo máy tính xách tay.',
          'I am going to bring my laptop.',
          G.goingTo,
        ),
        WritingSentence.of(
          'Cuộc họp sẽ bắt đầu lúc chín giờ.',
          'The meeting will start at nine o\'clock.',
          G.futureSimple,
          alternatives: ['The meeting will start at nine.'],
        ),
        WritingSentence.of(
          'Tôi sẽ về vào thứ sáu.',
          'I will come back on Friday.',
          G.futureSimple,
          alternatives: ['I will be back on Friday.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'work_b5',
      level: _b,
      titleVi: 'Công việc làm thêm',
      titleEn: 'A part-time job',
      sentences: [
        WritingSentence.of(
          'Tôi là sinh viên.',
          'I am a student.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi làm thêm ở một quán cà phê.',
          'I work part time at a coffee shop.',
          G.presentSimple,
          alternatives: ['I work part-time at a coffee shop.'],
        ),
        WritingSentence.of(
          'Tôi pha cà phê và dọn bàn.',
          'I make coffee and clean the tables.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Công việc hơi mệt.',
          'The work is a bit tiring.',
          G.presentSimple,
          alternatives: ['The job is a little tiring.'],
        ),
        WritingSentence.of(
          'Nhưng tôi có thể tiết kiệm tiền.',
          'But I can save money.',
          G.modal,
        ),
      ],
    ),
    WritingParagraph(
      id: 'work_b6',
      level: _b,
      titleVi: 'Nghề mơ ước',
      titleEn: 'My dream job',
      sentences: [
        WritingSentence.of(
          'Tôi muốn trở thành phi công.',
          'I want to become a pilot.',
          G.presentSimple,
          alternatives: ['I want to be a pilot.'],
        ),
        WritingSentence.of(
          'Phi công có thể bay đến nhiều nước.',
          'Pilots can fly to many countries.',
          G.modal,
        ),
        WritingSentence.of(
          'Tôi rất thích máy bay.',
          'I love planes.',
          G.presentSimple,
          alternatives: ['I really like airplanes.'],
        ),
        WritingSentence.of(
          'Tôi đang học tiếng Anh chăm chỉ.',
          'I am studying English hard.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Một ngày nào đó, tôi sẽ bay trên bầu trời.',
          'One day, I will fly in the sky.',
          G.futureSimple,
          alternatives: ['Someday, I will fly in the sky.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'work_b7',
      level: _b,
      titleVi: 'Làm việc ở nhà',
      titleEn: 'Working from home',
      sentences: [
        WritingSentence.of(
          'Hôm nay tôi làm việc ở nhà.',
          'Today I work from home.',
          G.presentSimple,
          alternatives: ['I work from home today.'],
        ),
        WritingSentence.of(
          'Con mèo đang ngồi trên bàn phím.',
          'The cat is sitting on my keyboard.',
          G.presentContinuous,
          alternatives: ['The cat is sitting on the keyboard.'],
        ),
        WritingSentence.of(
          'Tôi đang có một cuộc họp trực tuyến.',
          'I am having an online meeting.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Mọi người có thể nghe thấy tiếng chó sủa.',
          'Everyone can hear a dog barking.',
          G.modal,
          alternatives: ['People can hear a dog barking.'],
        ),
        WritingSentence.of(
          'Tôi không thích làm việc ở nhà lắm.',
          'I do not really like working from home.',
          G.presentSimple,
          alternatives: ['I don\'t really like working at home.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'work_b8',
      level: _b,
      titleVi: 'Gặp khách hàng',
      titleEn: 'Meeting a client',
      sentences: [
        WritingSentence.of(
          'Sáng qua tôi đã gặp một khách hàng mới.',
          'Yesterday morning I met a new client.',
          G.pastSimple,
          alternatives: ['Yesterday morning I met a new customer.'],
        ),
        WritingSentence.of(
          'Chúng tôi đã uống cà phê cùng nhau.',
          'We had coffee together.',
          G.pastSimple,
          alternatives: ['We drank coffee together.'],
        ),
        WritingSentence.of(
          'Tôi đã giới thiệu sản phẩm của công ty.',
          'I introduced our company\'s products.',
          G.pastSimple,
          alternatives: ['I presented our company\'s products.'],
        ),
        WritingSentence.of(
          'Ông ấy đã hỏi rất nhiều câu hỏi.',
          'He asked a lot of questions.',
          G.pastSimple,
          alternatives: ['He asked many questions.'],
        ),
        WritingSentence.of(
          'Cuối cùng, ông ấy đã ký hợp đồng.',
          'In the end, he signed the contract.',
          G.pastSimple,
          alternatives: ['Finally, he signed the contract.'],
        ),
      ],
    ),

    // ---------------- Trung cap ----------------
    WritingParagraph(
      id: 'work_i1',
      level: _i,
      titleVi: 'Phỏng vấn xin việc',
      titleEn: 'A job interview',
      sentences: [
        WritingSentence.of(
          'Tuần trước, tôi đã có một buổi phỏng vấn xin việc.',
          'Last week, I had a job interview.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tháng này tôi đã nộp đơn vào mười công ty.',
          'I have applied to ten companies this month.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Tôi được hỏi về kinh nghiệm làm việc của mình.',
          'I was asked about my work experience.',
          G.passive,
        ),
        WritingSentence.of(
          'Trong khi tôi đang trả lời, điện thoại của tôi reo.',
          'While I was answering, my phone rang.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Đó là khoảnh khắc xấu hổ nhất trong đời tôi.',
          'It was the most embarrassing moment of my life.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu họ gọi lại, tôi sẽ nhận việc ngay.',
          'If they call me back, I will accept the job immediately.',
          G.conditional1,
          alternatives: [
            'If they call me back, I will accept the job right away.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'work_i2',
      level: _i,
      titleVi: 'Đồng nghiệp mới',
      titleEn: 'A new colleague',
      sentences: [
        WritingSentence.of(
          'Một đồng nghiệp mới vừa gia nhập nhóm của chúng tôi.',
          'A new colleague has just joined our team.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Cô ấy trẻ hơn tất cả chúng tôi.',
          'She is younger than all of us.',
          G.comparison,
        ),
        WritingSentence.of(
          'Trước đây cô ấy từng làm việc ở Singapore hai năm.',
          'She worked in Singapore for two years before.',
          G.pastSimple,
          alternatives: ['She used to work in Singapore for two years.'],
        ),
        WritingSentence.of(
          'Hôm qua, trong khi chúng tôi đang ăn trưa, cô ấy kể về cuộc sống ở đó.',
          'Yesterday, while we were having lunch, she told us about life there.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Cô ấy được mọi người quý mến ngay từ đầu.',
          'She was liked by everyone from the start.',
          G.passive,
          alternatives: ['She was liked by everyone from the beginning.'],
        ),
        WritingSentence.of(
          'Nếu cần giúp đỡ, cô ấy có thể hỏi tôi.',
          'If she needs help, she can ask me.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'work_i3',
      level: _i,
      titleVi: 'Làm thêm giờ',
      titleEn: 'Working overtime',
      sentences: [
        WritingSentence.of(
          'Tháng này, gần như tối nào tôi cũng làm thêm giờ.',
          'This month, I have worked overtime almost every evening.',
          G.presentPerfect,
          alternatives: [
            'This month, I have worked overtime almost every night.',
          ],
        ),
        WritingSentence.of(
          'Dự án này khó hơn các dự án trước.',
          'This project is harder than the previous ones.',
          G.comparison,
          alternatives: [
            'This project is more difficult than the previous ones.',
          ],
        ),
        WritingSentence.of(
          'Tối qua, khi tôi đang làm việc, cả toà nhà mất điện.',
          'Last night, while I was working, the whole building lost power.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Hạn chót đã được lùi lại một tuần.',
          'The deadline has been pushed back by a week.',
          G.passive,
          alternatives: ['The deadline has been moved back by a week.'],
        ),
        WritingSentence.of(
          'Tôi mệt hơn bao giờ hết.',
          'I am more tired than ever.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu dự án thành công, cả nhóm sẽ được thưởng.',
          'If the project succeeds, the whole team will get a bonus.',
          G.conditional1,
          alternatives: [
            'If the project succeeds, the whole team will be rewarded.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'work_i4',
      level: _i,
      titleVi: 'Buổi thuyết trình',
      titleEn: 'Giving a presentation',
      sentences: [
        WritingSentence.of(
          'Hôm qua, tôi đã thuyết trình trước cả phòng.',
          'Yesterday, I gave a presentation to the whole department.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Các trang chiếu được chuẩn bị rất cẩn thận.',
          'The slides were prepared very carefully.',
          G.passive,
        ),
        WritingSentence.of(
          'Trong khi tôi đang nói, máy chiếu đột nhiên tắt.',
          'While I was speaking, the projector suddenly turned off.',
          G.pastContinuous,
          alternatives: [
            'While I was speaking, the projector suddenly switched off.',
          ],
        ),
        WritingSentence.of(
          'Tôi đã thuyết trình nhiều lần, nhưng lần này là khó nhất.',
          'I have given many presentations, but this one was the hardest.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Sếp nói bài thuyết trình tốt hơn lần trước.',
          'My boss said the presentation was better than last time.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu có cơ hội, tôi sẽ thuyết trình trước khách hàng.',
          'If I get the chance, I will present to our clients.',
          G.conditional1,
          alternatives: [
            'If I have the chance, I will present to our clients.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'work_i5',
      level: _i,
      titleVi: 'Chuyển việc',
      titleEn: 'Changing jobs',
      sentences: [
        WritingSentence.of(
          'Tôi đã làm ở công ty này được năm năm.',
          'I have worked at this company for five years.',
          G.presentPerfect,
          alternatives: ['I have worked for this company for five years.'],
        ),
        WritingSentence.of(
          'Công việc mới trả lương cao hơn nhưng xa nhà hơn.',
          'The new job pays more, but it is farther from home.',
          G.comparison,
          alternatives: ['The new job pays more, but it is further from home.'],
        ),
        WritingSentence.of(
          'Tôi đã được mời đến phỏng vấn vòng hai.',
          'I have been invited to a second interview.',
          G.passive,
        ),
        WritingSentence.of(
          'Tối qua, trong khi tôi đang suy nghĩ, vợ tôi nói tôi nên thử.',
          'Last night, while I was thinking about it, my wife said I should try.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Đây là quyết định khó khăn nhất trong sự nghiệp của tôi.',
          'This is the most difficult decision of my career.',
          G.comparison,
          alternatives: ['This is the hardest decision of my career.'],
        ),
        WritingSentence.of(
          'Nếu tôi nhận việc mới, tôi sẽ phải dậy sớm hơn.',
          'If I take the new job, I will have to get up earlier.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'work_i6',
      level: _i,
      titleVi: 'Họp trực tuyến',
      titleEn: 'Online meetings',
      sentences: [
        WritingSentence.of(
          'Công ty tôi họp trực tuyến vào mỗi sáng thứ hai.',
          'My company has an online meeting every Monday morning.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Họp trực tuyến tiện hơn họp trực tiếp.',
          'Online meetings are more convenient than meetings in person.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tuy nhiên, kết nối mạng đôi khi chậm hơn bình thường.',
          'However, the internet connection is sometimes slower than usual.',
          G.comparison,
        ),
        WritingSentence.of(
          'Sáng nay, trong khi sếp đang nói, màn hình của tôi bị đơ.',
          'This morning, while my boss was speaking, my screen froze.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Cuộc họp được ghi lại để mọi người xem sau.',
          'The meeting was recorded so that everyone could watch it later.',
          G.passive,
        ),
        WritingSentence.of(
          'Nếu mạng lại bị lỗi, tôi sẽ đến văn phòng.',
          'If the internet goes down again, I will go to the office.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'work_i7',
      level: _i,
      titleVi: 'Tiệm hoa của chị gái',
      titleEn: 'My sister\'s flower shop',
      sentences: [
        WritingSentence.of(
          'Chị tôi vừa mở một tiệm hoa nhỏ.',
          'My sister has just opened a small flower shop.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Cửa hàng được trang trí bằng gỗ và cây xanh.',
          'The shop is decorated with wood and plants.',
          G.passive,
        ),
        WritingSentence.of(
          'Chị ấy đã để dành tiền cho cửa hàng này suốt ba năm.',
          'She has saved money for this shop for three years.',
          G.presentPerfect,
          alternatives: [
            'She has been saving money for this shop for three years.',
          ],
        ),
        WritingSentence.of(
          'Hoa ở cửa hàng chị ấy tươi hơn hoa ngoài chợ.',
          'The flowers in her shop are fresher than at the market.',
          G.comparison,
        ),
        WritingSentence.of(
          'Hôm khai trương, trong khi chị ấy đang cắt băng, trời bắt đầu mưa.',
          'On the opening day, while she was cutting the ribbon, it started to rain.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nếu cửa hàng đông khách, chị ấy sẽ thuê thêm một nhân viên.',
          'If the shop is busy, she will hire another worker.',
          G.conditional1,
          alternatives: [
            'If the shop is busy, she will hire another employee.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'work_i8',
      level: _i,
      titleVi: 'Giờ làm việc linh hoạt',
      titleEn: 'Flexible hours',
      sentences: [
        WritingSentence.of(
          'Công ty tôi vừa áp dụng giờ làm việc linh hoạt.',
          'My company has just introduced flexible working hours.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Giờ đây nhân viên được phép bắt đầu làm việc lúc bảy hoặc mười giờ.',
          'Now employees are allowed to start work at seven or ten.',
          G.passive,
        ),
        WritingSentence.of(
          'Tôi thích bắt đầu sớm hơn để tránh tắc đường.',
          'I prefer to start earlier to avoid traffic jams.',
          G.comparison,
          alternatives: ['I prefer to start earlier to avoid the traffic.'],
        ),
        WritingSentence.of(
          'Hôm qua, khi tôi đang đi làm, đường vắng hơn nhiều.',
          'Yesterday, while I was going to work, the roads were much emptier.',
          G.pastContinuous,
          alternatives: [
            'Yesterday, while I was going to work, the roads were much quieter.',
          ],
        ),
        WritingSentence.of(
          'Mọi người có vẻ vui vẻ và làm việc hiệu quả hơn.',
          'Everyone seems happier and more productive.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu chính sách này hiệu quả, công ty sẽ giữ nó lâu dài.',
          'If this policy works, the company will keep it permanently.',
          G.conditional1,
          alternatives: [
            'If this policy is successful, the company will keep it permanently.',
          ],
        ),
      ],
    ),

    // ---------------- Nang cao ----------------
    WritingParagraph(
      id: 'work_a1',
      level: _a,
      titleVi: 'Làm việc từ xa',
      titleEn: 'Remote work',
      sentences: [
        WritingSentence.of(
          'Làm việc từ xa, thứ từng được xem là một đặc quyền, giờ đã trở nên phổ biến ở nhiều công ty.',
          'Remote work, which was once seen as a privilege, has become common in many companies.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Tôi đã làm việc tại nhà được gần hai năm và hiếm khi đến văn phòng.',
          'I have been working from home for almost two years and rarely go to the office.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Trước đó, tôi từng mất gần hai tiếng mỗi ngày để đi lại.',
          'Before that, I had spent almost two hours a day commuting.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Quản lý của tôi nói rằng năng suất của nhóm đã tăng lên đáng kể.',
          'My manager said that our team\'s productivity had increased significantly.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu công ty yêu cầu mọi người quay lại văn phòng, nhiều nhân viên có lẽ sẽ nghỉ việc.',
          'If the company asked everyone to return to the office, many employees would probably quit.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Tuy vậy, tôi thừa nhận rằng đôi khi tôi nhớ những cuộc trò chuyện với đồng nghiệp.',
          'However, I admit that I sometimes miss chatting with my colleagues.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'work_a2',
      level: _a,
      titleVi: 'Trí tuệ nhân tạo và việc làm',
      titleEn: 'AI and jobs',
      sentences: [
        WritingSentence.of(
          'Trí tuệ nhân tạo đang thay đổi cách chúng ta làm việc nhanh hơn bất kỳ ai dự đoán.',
          'Artificial intelligence is changing the way we work faster than anyone predicted.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nhiều công việc mà trước đây do con người làm giờ được máy móc đảm nhận.',
          'Many tasks that used to be done by people are now handled by machines.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Từ đầu năm, công ty tôi đã và đang dùng AI để trả lời email của khách hàng.',
          'My company has been using AI to answer customer emails since the beginning of the year.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Một chuyên gia nói với chúng tôi rằng kỹ năng sáng tạo sẽ trở nên quan trọng hơn bao giờ hết.',
          'An expert told us that creative skills would become more important than ever.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu tôi không học cách dùng các công cụ mới, tôi có thể sẽ bị tụt lại phía sau.',
          'If I do not learn to use the new tools, I may fall behind.',
          G.conditional1,
          alternatives: [
            'If I don\'t learn to use the new tools, I may fall behind.',
          ],
        ),
        WritingSentence.of(
          'Đến cuối năm nay, tôi sẽ hoàn thành hai khoá học trực tuyến về AI.',
          'By the end of this year, I will have completed two online courses on AI.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'work_a3',
      level: _a,
      titleVi: 'Khởi nghiệp',
      titleEn: 'Starting a business',
      sentences: [
        WritingSentence.of(
          'Ba năm trước, anh trai tôi bỏ một công việc ổn định để tự khởi nghiệp.',
          'My brother left a stable job to start his own business three years ago.',
          G.pastSimple,
          alternatives: [
            'Three years ago, my brother left a stable job to start his own business.',
          ],
        ),
        WritingSentence.of(
          'Trước khi ra mắt sản phẩm thành công đầu tiên, anh ấy đã thất bại hai lần.',
          'Before launching his first successful product, he had failed twice.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Công ty mà anh ấy thành lập giờ có hơn năm mươi nhân viên.',
          'The company that he founded now has more than fifty employees.',
          G.relativeClause,
          alternatives: [
            'The company he founded now has more than fifty employees.',
          ],
        ),
        WritingSentence.of(
          'Anh ấy nói với tôi rằng thất bại đã dạy anh nhiều hơn thành công.',
          'He told me that failure had taught him more than success.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu anh ấy bỏ cuộc sau lần thất bại đầu tiên, công ty đã không bao giờ tồn tại.',
          'If he had given up after his first failure, the company would never have existed.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Vào giờ này năm sau, có lẽ anh ấy sẽ đang mở văn phòng thứ hai ở Đà Nẵng.',
          'This time next year, he will probably be opening a second office in Da Nang.',
          G.futureContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'work_a4',
      level: _a,
      titleVi: 'Cân bằng công việc và cuộc sống',
      titleEn: 'Work-life balance',
      sentences: [
        WritingSentence.of(
          'Nhiều người trẻ ở các thành phố lớn làm việc hơn mười tiếng mỗi ngày.',
          'Many young people in big cities work more than ten hours a day.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi đã làm việc như vậy suốt nhiều tháng trước khi bắt đầu bị mất ngủ.',
          'I had been working like that for months before I started having trouble sleeping.',
          G.pastPerfectContinuous,
        ),
        WritingSentence.of(
          'Bác sĩ khuyên tôi rằng tôi nên dành thời gian cho bản thân mỗi ngày.',
          'The doctor advised me that I should spend some time on myself every day.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Những người được nghỉ ngơi hợp lý thường làm việc hiệu quả hơn.',
          'People who rest properly usually work more effectively.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Nếu tôi nhận ra điều này sớm hơn, tôi đã không kiệt sức như vậy.',
          'If I had realized this earlier, I would not have burned out.',
          G.conditional3,
          alternatives: [
            'If I had realised this earlier, I would not have burnt out.',
            'If I had realized this earlier, I wouldn\'t have burned out.',
          ],
        ),
        WritingSentence.of(
          'Giờ tôi luôn tắt email công việc sau bảy giờ tối.',
          'Now I always turn off my work email after seven in the evening.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'work_a5',
      level: _a,
      titleVi: 'Thực tập ở nước ngoài',
      titleEn: 'An internship abroad',
      sentences: [
        WritingSentence.of(
          'Mùa hè năm ngoái, tôi thực tập ba tháng ở một công ty công nghệ tại Singapore.',
          'Last summer, I did a three-month internship at a tech company in Singapore.',
          G.pastSimple,
          alternatives: [
            'Last summer, I did a three month internship at a tech company in Singapore.',
          ],
        ),
        WritingSentence.of(
          'Công việc ở đó nhanh và áp lực hơn nhiều so với những gì tôi quen.',
          'The work there was much faster and more stressful than I was used to.',
          G.comparison,
        ),
        WritingSentence.of(
          'Trước khi đến đó, tôi chưa từng làm việc với người nước ngoài.',
          'Before going there, I had never worked with foreigners.',
          G.pastPerfect,
          alternatives: [
            'Before going there, I had never worked with people from other countries.',
          ],
        ),
        WritingSentence.of(
          'Người hướng dẫn của tôi, một người rất nghiêm khắc, đã giúp tôi tiến bộ rất nhiều.',
          'My supervisor, who was very strict, helped me improve a lot.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Cô ấy nói rằng tôi có thể quay lại làm việc sau khi tốt nghiệp.',
          'She said that I could come back and work there after I graduated.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu tôi nhận lời, tôi sẽ phải chuyển ra nước ngoài vài năm.',
          'If I accept her offer, I will have to move abroad for a few years.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'work_a6',
      level: _a,
      titleVi: 'Bố tôi nghỉ hưu',
      titleEn: 'My father\'s retirement',
      sentences: [
        WritingSentence.of(
          'Bố tôi, người đã dạy học suốt ba mươi năm, sẽ nghỉ hưu vào tháng sau.',
          'My father, who has taught for thirty years, will retire next month.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Đến lúc đó, bố sẽ dạy được hàng nghìn học sinh.',
          'By then, he will have taught thousands of students.',
          G.futurePerfect,
        ),
        WritingSentence.of(
          'Bố nói rằng bố đã lên kế hoạch cho những năm nghỉ hưu từ lâu.',
          'He said that he had been planning his retirement for a long time.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Bố muốn học vẽ và đi du lịch khắp Việt Nam cùng mẹ.',
          'He wants to learn to paint and travel around Vietnam with my mother.',
          G.presentSimple,
          alternatives: [
            'He wants to learn to paint and travel around Vietnam with my mom.',
          ],
        ),
        WritingSentence.of(
          'Nếu bố không có sức khỏe tốt, những kế hoạch này sẽ khó thực hiện.',
          'If he were not in good health, these plans would be hard to carry out.',
          G.conditional2,
          alternatives: [
            'If he was not in good health, these plans would be hard to carry out.',
          ],
        ),
        WritingSentence.of(
          'Vào giờ này năm sau, có lẽ bố mẹ tôi sẽ đang đi dạo trên một bãi biển nào đó.',
          'This time next year, my parents will probably be walking on a beach somewhere.',
          G.futureContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'work_a7',
      level: _a,
      titleVi: 'Lương cao hay đam mê',
      titleEn: 'Salary or passion',
      sentences: [
        WritingSentence.of(
          'Khi tốt nghiệp, tôi phải chọn giữa một công việc lương cao và một công việc tôi thật sự yêu thích.',
          'When I graduated, I had to choose between a well-paid job and one I really loved.',
          G.pastSimple,
          alternatives: [
            'When I graduated, I had to choose between a well paid job and one I really loved.',
          ],
        ),
        WritingSentence.of(
          'Công việc lương cao, vốn ở một ngân hàng lớn, đòi hỏi làm việc đến tối muộn mỗi ngày.',
          'The well-paid job, which was at a big bank, required working late every day.',
          G.relativeClause,
          alternatives: [
            'The well paid job, which was at a big bank, required working late every day.',
          ],
        ),
        WritingSentence.of(
          'Cuối cùng, tôi chọn làm việc cho một tổ chức bảo vệ môi trường.',
          'In the end, I chose to work for an environmental organization.',
          G.pastSimple,
          alternatives: [
            'In the end, I chose to work for an environmental organisation.',
          ],
        ),
        WritingSentence.of(
          'Bạn bè hỏi tôi liệu tôi có hối hận về quyết định đó không.',
          'My friends asked me whether I regretted that decision.',
          G.reportedSpeech,
          alternatives: ['My friends asked me if I regretted that decision.'],
        ),
        WritingSentence.of(
          'Nếu tôi chọn ngân hàng, có lẽ tôi đã giàu hơn, nhưng không hạnh phúc hơn.',
          'If I had chosen the bank, I might have become richer, but not happier.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Tôi đã làm công việc này được bốn năm và chưa bao giờ muốn thay đổi.',
          'I have been doing this job for four years and have never wanted to change.',
          G.presentPerfectContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'work_a8',
      level: _a,
      titleVi: 'Tương lai của công việc',
      titleEn: 'The future of work',
      sentences: [
        WritingSentence.of(
          'Các chuyên gia dự đoán rằng nhiều công việc hiện nay sẽ không còn tồn tại trong hai mươi năm tới.',
          'Experts predict that many of today\'s jobs will no longer exist in twenty years.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Những người sẵn sàng học kỹ năng mới sẽ có nhiều cơ hội hơn.',
          'People who are willing to learn new skills will have more opportunities.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Công ty tôi đã và đang đào tạo lại nhân viên cho các vị trí mới.',
          'My company has been retraining its staff for new positions.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Trong buổi họp tuần trước, giám đốc nói rằng sẽ không ai mất việc vì công nghệ.',
          'At last week\'s meeting, the director said that nobody would lose their job because of technology.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu tôi có nhiều thời gian hơn, tôi sẽ học lập trình vào buổi tối.',
          'If I had more time, I would learn to code in the evenings.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Đến năm sau, tôi sẽ hoàn thành một khoá học phân tích dữ liệu.',
          'By next year, I will have finished a course in data analysis.',
          G.futurePerfect,
        ),
      ],
    ),
  ],
);

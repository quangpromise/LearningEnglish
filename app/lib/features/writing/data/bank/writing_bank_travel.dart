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

const kWritingBankTravel = WritingTopic(
  id: 'travel',
  titleVi: 'Du lịch',
  titleEn: 'Travel',
  icon: Icons.flight_takeoff_rounded,
  color: AppColors.blue,
  paragraphs: [
    // ---------------- Co ban ----------------
    WritingParagraph(
      id: 'travel_b1',
      level: _b,
      titleVi: 'Chuyến đi Hạ Long',
      titleEn: 'A trip to Ha Long',
      sentences: [
        WritingSentence.of(
          'Tuần trước, tôi đã đi Hạ Long.',
          'Last week, I went to Ha Long.',
          G.pastSimple,
          alternatives: ['Last week, I went to Halong.'],
        ),
        WritingSentence.of(
          'Tôi đã đi bằng xe buýt.',
          'I went by bus.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Biển rất đẹp.',
          'The sea was very beautiful.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Chúng tôi đã đi thuyền quanh vịnh.',
          'We took a boat around the bay.',
          G.pastSimple,
          alternatives: ['We went on a boat around the bay.'],
        ),
        WritingSentence.of(
          'Tôi đã rất vui.',
          'I was very happy.',
          G.pastSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'travel_b2',
      level: _b,
      titleVi: 'Ở sân bay',
      titleEn: 'At the airport',
      sentences: [
        WritingSentence.of(
          'Bây giờ tôi đang ở sân bay.',
          'I am at the airport now.',
          G.presentSimple,
          alternatives: ['Now I am at the airport.'],
        ),
        WritingSentence.of(
          'Tôi đang chờ chuyến bay.',
          'I am waiting for my flight.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Chuyến bay của tôi đi Đà Nẵng.',
          'My flight goes to Da Nang.',
          G.presentSimple,
          alternatives: [
            'My flight is to Da Nang.',
            'My flight goes to Danang.',
          ],
        ),
        WritingSentence.of(
          'Nó cất cánh lúc mười giờ.',
          'It takes off at ten o\'clock.',
          G.presentSimple,
          alternatives: ['It leaves at ten o\'clock.', 'It takes off at ten.'],
        ),
        WritingSentence.of(
          'Tôi phải xuất trình vé.',
          'I must show my ticket.',
          G.modal,
          alternatives: ['I have to show my ticket.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'travel_b3',
      level: _b,
      titleVi: 'Kỳ nghỉ sắp tới',
      titleEn: 'My next holiday',
      sentences: [
        WritingSentence.of(
          'Tháng sau, tôi định đi Phú Quốc.',
          'Next month, I am going to visit Phu Quoc.',
          G.goingTo,
        ),
        WritingSentence.of(
          'Tôi sẽ đi với gia đình.',
          'I will go with my family.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Chúng tôi định ở gần biển.',
          'We are going to stay near the beach.',
          G.goingTo,
          alternatives: ['We are going to stay near the sea.'],
        ),
        WritingSentence.of(
          'Tôi sẽ bơi mỗi ngày.',
          'I will swim every day.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Tôi rất mong chờ chuyến đi.',
          'I am really looking forward to the trip.',
          G.presentContinuous,
          alternatives: ['I am looking forward to the trip.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'travel_b4',
      level: _b,
      titleVi: 'Hỏi đường',
      titleEn: 'Asking for directions',
      sentences: [
        WritingSentence.of(
          'Xin lỗi, bảo tàng ở đâu ạ?',
          'Excuse me, where is the museum?',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Bạn đi thẳng đường này.',
          'Go straight along this road.',
          G.presentSimple,
          alternatives: ['Go straight on this road.'],
        ),
        WritingSentence.of(
          'Sau đó rẽ trái ở ngân hàng.',
          'Then turn left at the bank.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Bảo tàng ở bên phải.',
          'The museum is on the right.',
          G.presentSimple,
          alternatives: ['The museum is on your right.'],
        ),
        WritingSentence.of(
          'Bạn có thể đi bộ đến đó.',
          'You can walk there.',
          G.modal,
        ),
      ],
    ),
    WritingParagraph(
      id: 'travel_b5',
      level: _b,
      titleVi: 'Xếp hành lý',
      titleEn: 'Packing',
      sentences: [
        WritingSentence.of(
          'Ngày mai tôi sẽ đi du lịch.',
          'I will go on a trip tomorrow.',
          G.futureSimple,
          alternatives: ['Tomorrow I will go on a trip.'],
        ),
        WritingSentence.of(
          'Tôi đang xếp đồ vào vali.',
          'I am packing my suitcase.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Tôi cần mang theo áo ấm.',
          'I need to bring warm clothes.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Mẹ tôi đang kiểm tra hộ chiếu.',
          'My mother is checking my passport.',
          G.presentContinuous,
          alternatives: [
            'My mom is checking my passport.',
            'My mother is checking the passport.',
          ],
        ),
        WritingSentence.of(
          'Tôi không được quên điện thoại.',
          'I must not forget my phone.',
          G.modal,
          alternatives: ['I mustn\'t forget my phone.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'travel_b6',
      level: _b,
      titleVi: 'Khách sạn',
      titleEn: 'The hotel',
      sentences: [
        WritingSentence.of(
          'Khách sạn của chúng tôi rất sạch.',
          'Our hotel is very clean.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Phòng của tôi ở tầng năm.',
          'My room is on the fifth floor.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Từ cửa sổ, tôi có thể nhìn thấy biển.',
          'From the window, I can see the sea.',
          G.modal,
        ),
        WritingSentence.of(
          'Bữa sáng bắt đầu lúc bảy giờ.',
          'Breakfast starts at seven o\'clock.',
          G.presentSimple,
          alternatives: ['Breakfast starts at seven.'],
        ),
        WritingSentence.of(
          'Nhân viên rất thân thiện.',
          'The staff are very friendly.',
          G.presentSimple,
          alternatives: ['The staff is very friendly.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'travel_b7',
      level: _b,
      titleVi: 'Đi tàu hoả',
      titleEn: 'By train',
      sentences: [
        WritingSentence.of(
          'Tôi thích đi du lịch bằng tàu hoả.',
          'I like traveling by train.',
          G.presentSimple,
          alternatives: ['I like travelling by train.'],
        ),
        WritingSentence.of(
          'Bây giờ tàu đang chạy qua những cánh đồng.',
          'Now the train is passing through the fields.',
          G.presentContinuous,
          alternatives: ['The train is going through the fields now.'],
        ),
        WritingSentence.of(
          'Một người đàn ông đang bán đồ uống.',
          'A man is selling drinks.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Em gái tôi đang ngủ.',
          'My sister is sleeping.',
          G.presentContinuous,
          alternatives: ['My younger sister is sleeping.'],
        ),
        WritingSentence.of(
          'Chúng tôi sẽ đến Huế vào buổi chiều.',
          'We will arrive in Hue in the afternoon.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'travel_b8',
      level: _b,
      titleVi: 'Tấm bưu thiếp',
      titleEn: 'A postcard',
      sentences: [
        WritingSentence.of(
          'Chào mẹ, con đang ở Sa Pa.',
          'Hi Mom, I am in Sa Pa.',
          G.presentSimple,
          alternatives: ['Hi Mum, I am in Sa Pa.', 'Hi Mom, I am in Sapa.'],
        ),
        WritingSentence.of(
          'Ở đây trời lạnh nhưng rất đẹp.',
          'It is cold here, but it is very beautiful.',
          G.presentSimple,
          alternatives: ['It is cold but very beautiful here.'],
        ),
        WritingSentence.of(
          'Hôm qua con đã leo núi.',
          'Yesterday I climbed a mountain.',
          G.pastSimple,
          alternatives: ['I climbed a mountain yesterday.'],
        ),
        WritingSentence.of(
          'Con đã mua cho mẹ một chiếc khăn.',
          'I bought you a scarf.',
          G.pastSimple,
          alternatives: ['I bought a scarf for you.'],
        ),
        WritingSentence.of(
          'Con sẽ về nhà vào thứ hai.',
          'I will come home on Monday.',
          G.futureSimple,
          alternatives: ['I will be home on Monday.'],
        ),
      ],
    ),

    // ---------------- Trung cap ----------------
    WritingParagraph(
      id: 'travel_i1',
      level: _i,
      titleVi: 'Lần đầu đi máy bay',
      titleEn: 'My first flight',
      sentences: [
        WritingSentence.of(
          'Năm ngoái, tôi đã đi máy bay lần đầu tiên.',
          'Last year, I flew for the first time.',
          G.pastSimple,
          alternatives: ['Last year, I took a plane for the first time.'],
        ),
        WritingSentence.of(
          'Tôi lo lắng hơn tôi tưởng.',
          'I was more nervous than I expected.',
          G.comparison,
          alternatives: ['I was more nervous than I thought.'],
        ),
        WritingSentence.of(
          'Trong khi máy bay đang cất cánh, tôi nắm chặt tay mẹ.',
          'While the plane was taking off, I held my mother\'s hand tightly.',
          G.pastContinuous,
          alternatives: [
            'While the plane was taking off, I held my mom\'s hand tightly.',
          ],
        ),
        WritingSentence.of(
          'Bữa ăn được phục vụ sau một giờ bay.',
          'A meal was served after an hour of flying.',
          G.passive,
        ),
        WritingSentence.of(
          'Kể từ đó, tôi đã bay thêm năm lần nữa.',
          'Since then, I have flown five more times.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu có đủ tiền, tôi sẽ bay ra nước ngoài vào năm sau.',
          'If I have enough money, I will fly abroad next year.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'travel_i2',
      level: _i,
      titleVi: 'Phố cổ Hội An',
      titleEn: 'Hoi An Ancient Town',
      sentences: [
        WritingSentence.of(
          'Hội An là một trong những thị trấn đẹp nhất Việt Nam.',
          'Hoi An is one of the most beautiful towns in Vietnam.',
          G.comparison,
        ),
        WritingSentence.of(
          'Phố cổ đã được UNESCO công nhận là di sản thế giới.',
          'The old town has been recognized as a World Heritage Site by UNESCO.',
          G.passive,
          alternatives: [
            'The old town has been recognised as a World Heritage Site by UNESCO.',
          ],
        ),
        WritingSentence.of(
          'Tôi đã đến Hội An hai lần.',
          'I have been to Hoi An twice.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Buổi tối, những chiếc đèn lồng khiến phố cổ lung linh hơn ban ngày.',
          'In the evening, the lanterns make the town more magical than in the daytime.',
          G.comparison,
          alternatives: [
            'In the evening, the lanterns make the town more magical than during the day.',
          ],
        ),
        WritingSentence.of(
          'Khi chúng tôi đang thả đèn hoa đăng trên sông, vài du khách cất tiếng hát.',
          'While we were floating lanterns on the river, some tourists sang a song.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nếu bạn đến Hội An, bạn nên may một bộ áo dài.',
          'If you visit Hoi An, you should have an ao dai made.',
          G.conditional1,
          alternatives: ['If you go to Hoi An, you should get an ao dai made.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'travel_i3',
      level: _i,
      titleVi: 'Mất hộ chiếu',
      titleEn: 'Losing my passport',
      sentences: [
        WritingSentence.of(
          'Trong chuyến đi Thái Lan, tôi đã làm mất hộ chiếu.',
          'During my trip to Thailand, I lost my passport.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Trong khi tôi đang mua sắm ở chợ, túi của tôi bị mở ra.',
          'While I was shopping at the market, my bag was opened.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi chưa bao giờ sợ hãi như vậy.',
          'I have never been so scared.',
          G.presentPerfect,
          alternatives: ['I have never been so frightened.'],
        ),
        WritingSentence.of(
          'Một cảnh sát tốt bụng đã giúp tôi gọi cho đại sứ quán.',
          'A kind police officer helped me call the embassy.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Hộ chiếu mới được cấp trong ba ngày.',
          'A new passport was issued in three days.',
          G.passive,
          alternatives: ['A new passport was made in three days.'],
        ),
        WritingSentence.of(
          'Nếu tôi đi du lịch lần nữa, tôi sẽ cẩn thận hơn.',
          'If I travel again, I will be more careful.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'travel_i4',
      level: _i,
      titleVi: 'Đi Hà Giang bằng xe máy',
      titleEn: 'Riding to Ha Giang',
      sentences: [
        WritingSentence.of(
          'Mùa hè năm ngoái, tôi và hai người bạn đã đi xe máy lên Hà Giang.',
          'Last summer, two friends and I rode motorbikes to Ha Giang.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Đường ở đó hẹp hơn và dốc hơn đường thành phố.',
          'The roads there are narrower and steeper than city roads.',
          G.comparison,
        ),
        WritingSentence.of(
          'Trong khi chúng tôi đang leo đèo Mã Pí Lèng, trời bắt đầu có sương mù.',
          'While we were riding up Ma Pi Leng Pass, it started to get foggy.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Phong cảnh ở đó đẹp nhất mà tôi từng thấy.',
          'The scenery there was the most beautiful I have ever seen.',
          G.comparison,
        ),
        WritingSentence.of(
          'Chúng tôi đã đi hơn năm trăm ki-lô-mét.',
          'We rode more than five hundred kilometers.',
          G.pastSimple,
          alternatives: ['We rode more than five hundred kilometres.'],
        ),
        WritingSentence.of(
          'Nếu có thời gian, năm nay chúng tôi sẽ quay lại.',
          'If we have time, we will go back this year.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'travel_i5',
      level: _i,
      titleVi: 'Homestay ở Mai Châu',
      titleEn: 'A homestay in Mai Chau',
      sentences: [
        WritingSentence.of(
          'Chúng tôi đã ở trong một ngôi nhà sàn ở Mai Châu.',
          'We stayed in a stilt house in Mai Chau.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Ngôi nhà được làm bằng gỗ và tre.',
          'The house was made of wood and bamboo.',
          G.passive,
          alternatives: ['The house was built of wood and bamboo.'],
        ),
        WritingSentence.of(
          'Chủ nhà thân thiện hơn nhân viên khách sạn nhiều.',
          'The hosts were much friendlier than hotel staff.',
          G.comparison,
          alternatives: ['The host was much friendlier than hotel staff.'],
        ),
        WritingSentence.of(
          'Buổi tối, trong khi chúng tôi đang ăn tối, họ hát những bài dân ca.',
          'In the evening, while we were having dinner, they sang folk songs.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi chưa bao giờ ngủ ngon như vậy.',
          'I have never slept so well.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu bạn muốn hiểu văn hoá địa phương, bạn nên ở homestay.',
          'If you want to understand the local culture, you should stay in a homestay.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'travel_i6',
      level: _i,
      titleVi: 'Du lịch một mình',
      titleEn: 'Traveling alone',
      sentences: [
        WritingSentence.of(
          'Tôi đã đi du lịch một mình ba lần.',
          'I have traveled alone three times.',
          G.presentPerfect,
          alternatives: ['I have travelled alone three times.'],
        ),
        WritingSentence.of(
          'Đi một mình tự do hơn đi theo nhóm.',
          'Traveling alone is freer than traveling in a group.',
          G.comparison,
          alternatives: [
            'Travelling alone is freer than travelling in a group.',
          ],
        ),
        WritingSentence.of(
          'Tuy nhiên, nó cũng nguy hiểm hơn một chút.',
          'However, it is also a little more dangerous.',
          G.comparison,
          alternatives: ['However, it is also a bit more dangerous.'],
        ),
        WritingSentence.of(
          'Chuyến trước, trong khi tôi đang đợi xe buýt, tôi đã quen một cô gái người Pháp.',
          'Last time, while I was waiting for a bus, I met a French girl.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Từ đó đến nay, chúng tôi vẫn giữ liên lạc.',
          'We have kept in touch since then.',
          G.presentPerfect,
          alternatives: ['We have stayed in touch since then.'],
        ),
        WritingSentence.of(
          'Nếu cô ấy đến Việt Nam, tôi sẽ đưa cô ấy đi thăm Hà Nội.',
          'If she comes to Vietnam, I will show her around Hanoi.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'travel_i7',
      level: _i,
      titleVi: 'Kế hoạch đi Nhật',
      titleEn: 'Planning a trip to Japan',
      sentences: [
        WritingSentence.of(
          'Tôi đã để dành tiền cho chuyến đi Nhật được một năm.',
          'I have saved money for a trip to Japan for a year.',
          G.presentPerfect,
          alternatives: [
            'I have been saving money for a trip to Japan for a year.',
          ],
        ),
        WritingSentence.of(
          'Vé máy bay đã được đặt từ tháng trước.',
          'The plane tickets were booked last month.',
          G.passive,
          alternatives: ['The flight tickets were booked last month.'],
        ),
        WritingSentence.of(
          'Nhật Bản đắt đỏ hơn các nước Đông Nam Á.',
          'Japan is more expensive than Southeast Asian countries.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tôi đã học được vài câu tiếng Nhật đơn giản.',
          'I have learned a few simple Japanese phrases.',
          G.presentPerfect,
          alternatives: ['I have learnt a few simple Japanese phrases.'],
        ),
        WritingSentence.of(
          'Hôm qua, khi tôi đang xem bản đồ Tokyo, bạn tôi gọi đến.',
          'Yesterday, while I was looking at a map of Tokyo, my friend called.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nếu thời tiết đẹp, chúng tôi sẽ leo núi Phú Sĩ.',
          'If the weather is good, we will climb Mount Fuji.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'travel_i8',
      level: _i,
      titleVi: 'Chuyến bay bị huỷ',
      titleEn: 'A cancelled flight',
      sentences: [
        WritingSentence.of(
          'Tuần trước, chuyến bay của chúng tôi bị huỷ vì bão.',
          'Last week, our flight was cancelled because of a storm.',
          G.passive,
          alternatives: [
            'Last week, our flight was canceled because of a storm.',
          ],
        ),
        WritingSentence.of(
          'Chúng tôi đã đợi ở sân bay suốt sáu tiếng.',
          'We waited at the airport for six hours.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Trong khi mọi người đang phàn nàn, một nhân viên mang nước đến cho chúng tôi.',
          'While everyone was complaining, a staff member brought us some water.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Đó là ngày dài nhất trong kỳ nghỉ của tôi.',
          'It was the longest day of my holiday.',
          G.comparison,
          alternatives: ['It was the longest day of my vacation.'],
        ),
        WritingSentence.of(
          'Tôi đã học được cách kiên nhẫn hơn.',
          'I have learned to be more patient.',
          G.presentPerfect,
          alternatives: ['I have learnt to be more patient.'],
        ),
        WritingSentence.of(
          'Nếu chuyến bay lại bị huỷ, tôi sẽ đi tàu hoả.',
          'If my flight is cancelled again, I will take the train.',
          G.conditional1,
          alternatives: [
            'If my flight is canceled again, I will take the train.',
          ],
        ),
      ],
    ),

    // ---------------- Nang cao ----------------
    WritingParagraph(
      id: 'travel_a1',
      level: _a,
      titleVi: 'Du lịch bền vững',
      titleEn: 'Sustainable tourism',
      sentences: [
        WritingSentence.of(
          'Du lịch bền vững, vốn khuyến khích bảo vệ môi trường và văn hoá địa phương, đang ngày càng phổ biến.',
          'Sustainable tourism, which encourages protecting the environment and local culture, is becoming more popular.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Nhiều bãi biển nổi tiếng đã bị ô nhiễm nặng vì quá đông khách.',
          'Many famous beaches have been badly polluted because of too many tourists.',
          G.passive,
        ),
        WritingSentence.of(
          'Một hướng dẫn viên nói với chúng tôi rằng gần một nửa rạn san hô ở đây đã chết.',
          'A tour guide told us that almost half of the coral reef here had died.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu du khách không xả rác, những nơi này sẽ giữ được vẻ đẹp lâu hơn.',
          'If tourists did not leave litter, these places would stay beautiful for longer.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Gần đây, nhiều công ty du lịch đã và đang giới hạn số lượng khách mỗi ngày.',
          'Recently, many travel companies have been limiting the number of visitors each day.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Đến năm sau, hòn đảo này sẽ cấm hoàn toàn đồ nhựa dùng một lần.',
          'By next year, this island will have banned single-use plastic completely.',
          G.futurePerfect,
          alternatives: [
            'By next year, this island will have banned single use plastic completely.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'travel_a2',
      level: _a,
      titleVi: 'Lạc đường ở Venice',
      titleEn: 'Lost in Venice',
      sentences: [
        WritingSentence.of(
          'Trước khi đến Venice, tôi đã đọc rất nhiều về thành phố này.',
          'By the time I arrived in Venice, I had read a lot about the city.',
          G.pastPerfect,
          alternatives: [
            'Before I arrived in Venice, I had read a lot about the city.',
          ],
        ),
        WritingSentence.of(
          'Tuy vậy, chưa cuốn sách nào chuẩn bị cho tôi trước mê cung những con hẻm nhỏ.',
          'However, no book had prepared me for its maze of narrow streets.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Tôi đã đi bộ hàng giờ thì mới nhận ra mình quay lại đúng chỗ ban đầu.',
          'I had been walking for hours when I realized I was back where I started.',
          G.pastPerfectContinuous,
          alternatives: [
            'I had been walking for hours when I realised I was back where I started.',
          ],
        ),
        WritingSentence.of(
          'Một bà cụ, người không nói được tiếng Anh, đã vẽ cho tôi tấm bản đồ trên giấy ăn.',
          'An old woman, who could not speak English, drew me a map on a napkin.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Nếu tôi không bị lạc, tôi đã không bao giờ tìm ra quán cà phê nhỏ tuyệt vời ấy.',
          'If I had not got lost, I would never have discovered that wonderful little coffee shop.',
          G.conditional3,
          alternatives: [
            'If I had not gotten lost, I would never have discovered that wonderful little coffee shop.',
          ],
        ),
        WritingSentence.of(
          'Giờ tôi tin rằng lạc đường đôi khi là cách tốt nhất để khám phá một thành phố.',
          'Now I believe that getting lost is sometimes the best way to explore a city.',
          G.comparison,
        ),
      ],
    ),
    WritingParagraph(
      id: 'travel_a3',
      level: _a,
      titleVi: 'Anh trai đi du học',
      titleEn: 'My brother abroad',
      sentences: [
        WritingSentence.of(
          'Anh trai tôi, người đang học thạc sĩ ở Úc, sẽ về nước vào tháng sau.',
          'My brother, who is doing a master\'s degree in Australia, will come home next month.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Anh ấy đã sống ở Melbourne được gần hai năm.',
          'He has been living in Melbourne for almost two years.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Trước khi đi, anh ấy chưa bao giờ phải tự nấu ăn hay giặt đồ.',
          'Before he left, he had never had to cook or do his own laundry.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Anh kể rằng tuần đầu tiên là khoảng thời gian khó khăn nhất.',
          'He told us that the first week had been the hardest time.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu tôi giành được học bổng, tôi cũng sẽ đi du học như anh ấy.',
          'If I got a scholarship, I would also study abroad like him.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Vào giờ này tuần sau, chúng tôi sẽ đang đón anh ấy ở sân bay.',
          'This time next week, we will be picking him up at the airport.',
          G.futureContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'travel_a4',
      level: _a,
      titleVi: 'Xuyên Việt bằng tàu hoả',
      titleEn: 'Across Vietnam by train',
      sentences: [
        WritingSentence.of(
          'Tuyến đường sắt Bắc Nam, được xây dựng từ thời Pháp thuộc, dài hơn một nghìn bảy trăm ki-lô-mét.',
          'The North South railway, which was built in the French colonial period, is over seventeen hundred kilometers long.',
          G.relativeClause,
          alternatives: [
            'The North-South railway, which was built in the French colonial period, is over seventeen hundred kilometers long.',
            'The North South railway, which was built in the French colonial period, is over seventeen hundred kilometres long.',
          ],
        ),
        WritingSentence.of(
          'Năm ngoái, tôi đã đi hết tuyến đường này trong ba ngày hai đêm.',
          'Last year, I traveled the whole route in three days and two nights.',
          G.pastSimple,
          alternatives: [
            'Last year, I travelled the whole route in three days and two nights.',
          ],
        ),
        WritingSentence.of(
          'Trong khi tàu đang chạy dọc bờ biển miền Trung, tôi ngắm bình minh qua cửa sổ.',
          'While the train was running along the central coast, I watched the sunrise from the window.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Một cụ ông ngồi cùng khoang kể rằng ông đã đi tuyến tàu này hơn năm mươi lần.',
          'An old man in my compartment said that he had taken this train more than fifty times.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu có tàu cao tốc, hành trình sẽ chỉ mất vài giờ.',
          'If there were a high-speed train, the journey would take only a few hours.',
          G.conditional2,
          alternatives: [
            'If there was a high-speed train, the journey would take only a few hours.',
            'If there were a high speed train, the journey would take only a few hours.',
          ],
        ),
        WritingSentence.of(
          'Tuy nhiên, tôi nghĩ đi chậm giúp ta cảm nhận đất nước sâu sắc hơn.',
          'However, I think slow travel helps you experience the country more deeply.',
          G.comparison,
        ),
      ],
    ),
    WritingParagraph(
      id: 'travel_a5',
      level: _a,
      titleVi: 'Nghề hướng dẫn viên',
      titleEn: 'Life as a tour guide',
      sentences: [
        WritingSentence.of(
          'Chị họ tôi đã làm hướng dẫn viên du lịch được mười năm.',
          'My cousin has been working as a tour guide for ten years.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Chị ấy đã dẫn khách từ hơn ba mươi quốc gia đi khắp Việt Nam.',
          'She has guided visitors from more than thirty countries around Vietnam.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Vị khách mà chị ấy nhớ nhất là một cụ bà người Mỹ đã tám mươi tuổi.',
          'The visitor she remembers most is an American woman who was eighty years old.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Cụ bà nói rằng bà đã chờ cả đời để được đến thăm Việt Nam.',
          'The old woman said that she had waited her whole life to visit Vietnam.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu chị ấy không học tiếng Anh từ sớm, chị đã không có được công việc này.',
          'If she had not learned English early, she would not have got this job.',
          G.conditional3,
          alternatives: [
            'If she had not learnt English early, she would not have got this job.',
            'If she had not learned English early, she would not have gotten this job.',
          ],
        ),
        WritingSentence.of(
          'Mùa hè này, chị ấy sẽ đang dẫn một đoàn khách châu Âu đi khắp vùng núi phía Bắc.',
          'This summer, she will be leading a group of European tourists around the northern mountains.',
          G.futureContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'travel_a6',
      level: _a,
      titleVi: 'Du lịch và mạng xã hội',
      titleEn: 'Travel and social media',
      sentences: [
        WritingSentence.of(
          'Nhiều người trẻ chọn điểm đến dựa trên những bức ảnh mà họ thấy trên mạng.',
          'Many young people choose destinations based on photos that they see online.',
          G.relativeClause,
          alternatives: [
            'Many young people choose destinations based on photos they see online.',
          ],
        ),
        WritingSentence.of(
          'Một số nơi từng yên bình giờ đã trở nên đông đúc vì được chia sẻ quá nhiều.',
          'Some places that used to be peaceful have become crowded because they have been shared so much.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Khi tôi đến một hồ nước nổi tiếng, hàng chục người đã xếp hàng chờ chụp ảnh.',
          'When I arrived at a famous lake, dozens of people had already lined up to take photos.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Nếu biết trước điều đó, tôi đã đến vào sáng sớm.',
          'If I had known that beforehand, I would have gone early in the morning.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Giờ tôi thường tắt điện thoại khi đi du lịch để tận hưởng khoảnh khắc.',
          'Now I often turn off my phone while traveling to enjoy the moment.',
          G.presentSimple,
          alternatives: [
            'Now I often turn off my phone while travelling to enjoy the moment.',
          ],
        ),
        WritingSentence.of(
          'Bạn tôi hỏi liệu du lịch mà không đăng ảnh có còn vui không.',
          'My friend asked me whether traveling was still fun without posting photos.',
          G.reportedSpeech,
          alternatives: [
            'My friend asked me whether travelling was still fun without posting photos.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'travel_a7',
      level: _a,
      titleVi: 'Chuyến đi thay đổi tôi',
      titleEn: 'A trip that changed me',
      sentences: [
        WritingSentence.of(
          'Hai năm trước, tôi dành một tháng làm tình nguyện ở một ngôi làng vùng cao.',
          'Two years ago, I spent a month volunteering in a mountain village.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Trước chuyến đi đó, tôi chưa từng sống thiếu internet dù chỉ một ngày.',
          'Before that trip, I had never lived without the internet for even a day.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Trẻ em ở đó, những em phải đi bộ hai tiếng đến trường, không bao giờ than phiền.',
          'The children there, who had to walk two hours to school, never complained.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Khi tôi rời đi, tôi đã sống ở đó được bốn tuần và nói được chút tiếng H\'Mông.',
          'By the time I left, I had lived there for four weeks and could speak a little Hmong.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Nếu tôi không đi chuyến đó, có lẽ tôi đã không bao giờ trân trọng những gì mình có.',
          'If I had not gone on that trip, I might never have appreciated what I had.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Năm sau, tôi định quay lại để giúp xây một thư viện nhỏ cho các em.',
          'Next year, I am going to go back to help build a small library for the children.',
          G.goingTo,
        ),
      ],
    ),
    WritingParagraph(
      id: 'travel_a8',
      level: _a,
      titleVi: 'Du lịch trong tương lai',
      titleEn: 'The future of travel',
      sentences: [
        WritingSentence.of(
          'Trong vài thập kỷ tới, cách con người đi du lịch có thể sẽ thay đổi hoàn toàn.',
          'In the next few decades, the way people travel may change completely.',
          G.modal,
        ),
        WritingSentence.of(
          'Một số công ty đã và đang thử nghiệm máy bay chạy bằng điện.',
          'Some companies have been testing planes that run on electricity.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Các chuyên gia dự đoán rằng du lịch vũ trụ sẽ trở nên rẻ hơn nhiều.',
          'Experts predict that space travel will become much cheaper.',
          G.comparison,
        ),
        WritingSentence.of(
          'Đến cuối thế kỷ này, có lẽ con người sẽ đặt chân lên sao Hoả.',
          'By the end of this century, humans will probably have landed on Mars.',
          G.futurePerfect,
        ),
        WritingSentence.of(
          'Nếu tôi có đủ tiền, tôi sẽ đặt vé cho một chuyến bay vào không gian.',
          'If I had enough money, I would book a flight into space.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Dù vậy, tôi tin rằng những chuyến đi giản dị cùng người thân vẫn là quý giá nhất.',
          'Even so, I believe that simple trips with loved ones are still the most precious.',
          G.comparison,
        ),
      ],
    ),
  ],
);

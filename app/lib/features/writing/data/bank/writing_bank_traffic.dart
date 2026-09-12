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

const kWritingBankTraffic = WritingTopic(
  id: 'traffic',
  titleVi: 'Giao thông',
  titleEn: 'Traffic & Transport',
  icon: Icons.directions_bus_rounded,
  color: AppColors.amber,
  paragraphs: [
    // ---------------- Co ban ----------------
    WritingParagraph(
      id: 'traffic_b1',
      level: _b,
      titleVi: 'Đường đến trường',
      titleEn: 'My way to school',
      sentences: [
        WritingSentence.of(
          'Tôi đi học bằng xe buýt.',
          'I go to school by bus.',
          G.presentSimple,
          alternatives: ['I take the bus to school.'],
        ),
        WritingSentence.of(
          'Xe buýt đến lúc sáu giờ bốn mươi lăm.',
          'The bus comes at six forty five.',
          G.presentSimple,
          alternatives: [
            'The bus comes at six forty-five.',
            'The bus arrives at six forty five.',
          ],
        ),
        WritingSentence.of(
          'Chuyến đi mất hai mươi phút.',
          'The trip takes twenty minutes.',
          G.presentSimple,
          alternatives: ['The journey takes twenty minutes.'],
        ),
        WritingSentence.of(
          'Tôi thường nghe nhạc trên xe.',
          'I often listen to music on the bus.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi không bao giờ đi học muộn.',
          'I am never late for school.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'traffic_b2',
      level: _b,
      titleVi: 'Tắc đường',
      titleEn: 'A traffic jam',
      sentences: [
        WritingSentence.of(
          'Bây giờ là giờ cao điểm.',
          'It is rush hour now.',
          G.presentSimple,
          alternatives: ['Now it is rush hour.'],
        ),
        WritingSentence.of(
          'Đường phố rất đông xe.',
          'The streets are very busy.',
          G.presentSimple,
          alternatives: ['The streets are full of traffic.'],
        ),
        WritingSentence.of(
          'Chúng tôi đang bị kẹt xe.',
          'We are stuck in traffic.',
          G.presentSimple,
          alternatives: ['We are in a traffic jam.'],
        ),
        WritingSentence.of(
          'Mọi người đang bấm còi.',
          'People are honking their horns.',
          G.presentContinuous,
          alternatives: ['Everyone is honking.'],
        ),
        WritingSentence.of(
          'Chúng tôi sẽ về nhà muộn.',
          'We will get home late.',
          G.futureSimple,
          alternatives: ['We will be home late.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'traffic_b3',
      level: _b,
      titleVi: 'Luật giao thông',
      titleEn: 'Traffic rules',
      sentences: [
        WritingSentence.of(
          'Chúng ta phải đội mũ bảo hiểm.',
          'We must wear a helmet.',
          G.modal,
          alternatives: ['We must wear helmets.', 'We have to wear a helmet.'],
        ),
        WritingSentence.of(
          'Chúng ta phải dừng lại khi đèn đỏ.',
          'We must stop at a red light.',
          G.modal,
          alternatives: ['We must stop at red lights.'],
        ),
        WritingSentence.of(
          'Chúng ta không nên dùng điện thoại khi lái xe.',
          'We should not use phones while driving.',
          G.modal,
          alternatives: ['We shouldn\'t use our phones while driving.'],
        ),
        WritingSentence.of(
          'Trẻ em nên đi trên vỉa hè.',
          'Children should walk on the pavement.',
          G.modal,
          alternatives: ['Children should walk on the sidewalk.'],
        ),
        WritingSentence.of(
          'Luật giao thông giữ chúng ta an toàn.',
          'Traffic rules keep us safe.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'traffic_b4',
      level: _b,
      titleVi: 'Đi tàu điện',
      titleEn: 'Riding the metro',
      sentences: [
        WritingSentence.of(
          'Hôm qua tôi đã đi tàu điện lần đầu tiên.',
          'Yesterday I took the metro for the first time.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tàu rất sạch và mát.',
          'The train was very clean and cool.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã mua vé ở nhà ga.',
          'I bought a ticket at the station.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Chuyến đi chỉ mất mười lăm phút.',
          'The trip only took fifteen minutes.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã rất thích nó.',
          'I really liked it.',
          G.pastSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'traffic_b5',
      level: _b,
      titleVi: 'Học lái xe',
      titleEn: 'Learning to drive',
      sentences: [
        WritingSentence.of(
          'Chị tôi đang học lái ô tô.',
          'My sister is learning to drive a car.',
          G.presentContinuous,
          alternatives: ['My sister is learning to drive.'],
        ),
        WritingSentence.of(
          'Chị ấy học vào mỗi sáng Chủ nhật.',
          'She has lessons every Sunday morning.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Chị ấy lái rất cẩn thận.',
          'She drives very carefully.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tháng sau, chị ấy định thi bằng lái.',
          'Next month, she is going to take her driving test.',
          G.goingTo,
        ),
        WritingSentence.of(
          'Tôi nghĩ chị ấy sẽ đỗ.',
          'I think she will pass.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'traffic_b6',
      level: _b,
      titleVi: 'Xe ôm công nghệ',
      titleEn: 'A ride app',
      sentences: [
        WritingSentence.of(
          'Tôi thường đặt xe bằng điện thoại.',
          'I often book a ride on my phone.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tài xế đến trong năm phút.',
          'The driver comes in five minutes.',
          G.presentSimple,
          alternatives: ['The driver arrives in five minutes.'],
        ),
        WritingSentence.of(
          'Tôi có thể trả tiền bằng thẻ.',
          'I can pay by card.',
          G.modal,
        ),
        WritingSentence.of(
          'Bây giờ tôi đang chờ xe.',
          'Now I am waiting for my ride.',
          G.presentContinuous,
          alternatives: ['I am waiting for my ride now.'],
        ),
        WritingSentence.of(
          'Tài xế đang gọi cho tôi.',
          'The driver is calling me.',
          G.presentContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'traffic_b7',
      level: _b,
      titleVi: 'Chiếc xe đạp mới',
      titleEn: 'A new bike',
      sentences: [
        WritingSentence.of(
          'Tuần trước bố đã mua cho tôi một chiếc xe đạp.',
          'Last week my father bought me a bike.',
          G.pastSimple,
          alternatives: ['Last week my dad bought me a bicycle.'],
        ),
        WritingSentence.of(
          'Nó màu xanh dương.',
          'It is blue.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi đạp xe quanh khu phố mỗi chiều.',
          'I ride around my neighborhood every afternoon.',
          G.presentSimple,
          alternatives: ['I ride around my neighbourhood every afternoon.'],
        ),
        WritingSentence.of(
          'Hôm qua tôi đã bị ngã.',
          'Yesterday I fell off.',
          G.pastSimple,
          alternatives: ['I fell off yesterday.'],
        ),
        WritingSentence.of(
          'Lần sau tôi sẽ đi chậm lại.',
          'Next time I will ride slowly.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'traffic_b8',
      level: _b,
      titleVi: 'Chuyến xe khách',
      titleEn: 'A long bus ride',
      sentences: [
        WritingSentence.of(
          'Tối mai tôi định về quê bằng xe khách.',
          'Tomorrow night I am going to take a coach home.',
          G.goingTo,
          alternatives: ['Tomorrow night I am going to take a bus home.'],
        ),
        WritingSentence.of(
          'Chuyến đi sẽ mất tám tiếng.',
          'The trip will take eight hours.',
          G.futureSimple,
          alternatives: ['The journey will take eight hours.'],
        ),
        WritingSentence.of(
          'Tôi sẽ ngủ trên xe.',
          'I will sleep on the bus.',
          G.futureSimple,
          alternatives: ['I will sleep on the coach.'],
        ),
        WritingSentence.of(
          'Tôi phải mang theo gối.',
          'I must bring a pillow.',
          G.modal,
          alternatives: ['I have to bring a pillow.'],
        ),
        WritingSentence.of(
          'Mẹ tôi sẽ đón tôi ở bến xe.',
          'My mother will pick me up at the bus station.',
          G.futureSimple,
          alternatives: ['My mom will pick me up at the bus station.'],
        ),
      ],
    ),

    // ---------------- Trung cap ----------------
    WritingParagraph(
      id: 'traffic_i1',
      level: _i,
      titleVi: 'Giao thông Hà Nội',
      titleEn: 'Traffic in Hanoi',
      sentences: [
        WritingSentence.of(
          'Giao thông ở Hà Nội đông đúc hơn ở quê tôi nhiều.',
          'Traffic in Hanoi is much heavier than in my hometown.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tôi đã sống ở đây được ba năm.',
          'I have lived here for three years.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nhiều con đường được mở rộng trong năm nay.',
          'Many roads have been widened this year.',
          G.passive,
        ),
        WritingSentence.of(
          'Sáng qua, khi tôi đang đi làm, một chiếc xe máy đâm vào tôi.',
          'Yesterday morning, while I was riding to work, a motorbike hit me.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'May mắn là tôi chỉ bị thương nhẹ.',
          'Luckily, I was only slightly hurt.',
          G.passive,
        ),
        WritingSentence.of(
          'Nếu mọi người lái xe cẩn thận hơn, sẽ có ít tai nạn hơn.',
          'If people drive more carefully, there will be fewer accidents.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'traffic_i2',
      level: _i,
      titleVi: 'Tuyến tàu điện mới',
      titleEn: 'The new metro line',
      sentences: [
        WritingSentence.of(
          'Tuyến tàu điện mới vừa được mở vào tháng trước.',
          'The new metro line was opened last month.',
          G.passive,
        ),
        WritingSentence.of(
          'Nó nhanh hơn xe buýt rất nhiều.',
          'It is much faster than the bus.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tôi đã đi tàu điện đi làm được hai tuần.',
          'I have taken the metro to work for two weeks.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Hôm qua, trong khi tàu đang chạy, nó đột ngột dừng lại.',
          'Yesterday, while the train was moving, it suddenly stopped.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Đó là mười phút dài nhất trong ngày của tôi.',
          'Those were the longest ten minutes of my day.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu có thêm tuyến mới, tôi sẽ bán xe máy.',
          'If more lines open, I will sell my motorbike.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'traffic_i3',
      level: _i,
      titleVi: 'Bị phạt',
      titleEn: 'Getting a fine',
      sentences: [
        WritingSentence.of(
          'Tuần trước, anh trai tôi đã bị cảnh sát phạt.',
          'Last week, my brother was fined by the police.',
          G.passive,
        ),
        WritingSentence.of(
          'Anh ấy đã vượt đèn đỏ.',
          'He ran a red light.',
          G.pastSimple,
          alternatives: ['He went through a red light.'],
        ),
        WritingSentence.of(
          'Trong khi anh ấy đang nghe điện thoại, đèn chuyển sang màu đỏ.',
          'While he was talking on the phone, the light turned red.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Mức phạt cao hơn anh ấy tưởng.',
          'The fine was higher than he expected.',
          G.comparison,
        ),
        WritingSentence.of(
          'Kể từ đó, anh ấy chưa bao giờ dùng điện thoại khi lái xe.',
          'Since then, he has never used his phone while riding.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu anh ấy vi phạm lần nữa, anh sẽ bị tước bằng lái.',
          'If he breaks the law again, he will lose his licence.',
          G.conditional1,
          alternatives: [
            'If he breaks the law again, he will lose his license.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'traffic_i4',
      level: _i,
      titleVi: 'Xe buýt điện',
      titleEn: 'Electric buses',
      sentences: [
        WritingSentence.of(
          'Thành phố tôi vừa đưa vào hoạt động xe buýt điện.',
          'My city has just introduced electric buses.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Xe buýt điện êm hơn và sạch hơn xe buýt cũ.',
          'Electric buses are quieter and cleaner than the old ones.',
          G.comparison,
        ),
        WritingSentence.of(
          'Mỗi xe được sạc qua đêm ở bến.',
          'Each bus is charged overnight at the depot.',
          G.passive,
        ),
        WritingSentence.of(
          'Sáng nay, khi tôi đang đợi xe, một người nước ngoài hỏi đường tôi.',
          'This morning, while I was waiting for the bus, a foreigner asked me for directions.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi đã giúp anh ấy tìm đúng tuyến xe.',
          'I helped him find the right bus.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Nếu vé rẻ, nhiều người sẽ đi xe buýt hơn.',
          'If tickets are cheap, more people will take the bus.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'traffic_i5',
      level: _i,
      titleVi: 'Đường về quê ngày Tết',
      titleEn: 'Going home for Tet',
      sentences: [
        WritingSentence.of(
          'Mỗi dịp Tết, hàng triệu người rời thành phố về quê.',
          'Every Tet, millions of people leave the cities to go home.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Vé tàu đã được bán hết từ hai tháng trước.',
          'The train tickets were sold out two months ago.',
          G.passive,
        ),
        WritingSentence.of(
          'Đường cao tốc đông hơn ngày thường rất nhiều.',
          'The highway is much more crowded than usual.',
          G.comparison,
          alternatives: ['The motorway is much more crowded than usual.'],
        ),
        WritingSentence.of(
          'Năm ngoái, trong khi chúng tôi đang đi, xe bị thủng lốp.',
          'Last year, while we were driving, the car got a flat tire.',
          G.pastContinuous,
          alternatives: [
            'Last year, while we were driving, the car got a flat tyre.',
          ],
        ),
        WritingSentence.of(
          'Chúng tôi đã về đến nhà lúc nửa đêm.',
          'We got home at midnight.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Nếu năm nay đi sớm, chúng tôi sẽ tránh được tắc đường.',
          'If we leave early this year, we will avoid the traffic.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'traffic_i6',
      level: _i,
      titleVi: 'Đi bộ an toàn',
      titleEn: 'Walking safely',
      sentences: [
        WritingSentence.of(
          'Qua đường ở Việt Nam là một kỹ năng khó.',
          'Crossing the road in Vietnam is a difficult skill.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Người đi bộ được khuyên nên đi chậm và đều.',
          'Pedestrians are advised to walk slowly and steadily.',
          G.passive,
        ),
        WritingSentence.of(
          'Đi chậm an toàn hơn chạy qua đường.',
          'Walking slowly is safer than running across.',
          G.comparison,
        ),
        WritingSentence.of(
          'Bạn tôi người Anh đã học được cách qua đường.',
          'My English friend has learned how to cross the road.',
          G.presentPerfect,
          alternatives: ['My English friend has learnt how to cross the road.'],
        ),
        WritingSentence.of(
          'Lần đầu, trong khi anh ấy đang qua đường, anh ấy dừng lại giữa đường.',
          'The first time, while he was crossing, he stopped in the middle.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nếu bạn đến Việt Nam, bạn nên tập qua đường trước.',
          'If you come to Vietnam, you should practice crossing the road.',
          G.conditional1,
          alternatives: [
            'If you come to Vietnam, you should practise crossing the road.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'traffic_i7',
      level: _i,
      titleVi: 'Mua ô tô',
      titleEn: 'Buying a car',
      sentences: [
        WritingSentence.of(
          'Gia đình tôi vừa mua chiếc ô tô đầu tiên.',
          'My family has just bought our first car.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nó được sản xuất tại một nhà máy ở Việt Nam.',
          'It was made in a factory in Vietnam.',
          G.passive,
        ),
        WritingSentence.of(
          'Đi ô tô thoải mái hơn đi xe máy khi trời mưa.',
          'A car is more comfortable than a motorbike when it rains.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tuy nhiên, tìm chỗ đỗ xe khó hơn nhiều.',
          'However, finding a parking space is much harder.',
          G.comparison,
        ),
        WritingSentence.of(
          'Hôm qua, trong khi bố đang tìm chỗ đỗ, chúng tôi lỡ bộ phim.',
          'Yesterday, while Dad was looking for parking, we missed the film.',
          G.pastContinuous,
          alternatives: [
            'Yesterday, while Dad was looking for parking, we missed the movie.',
          ],
        ),
        WritingSentence.of(
          'Nếu đi xa, chúng tôi sẽ dùng ô tô.',
          'If we travel far, we will use the car.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'traffic_i8',
      level: _i,
      titleVi: 'Phà sang đảo',
      titleEn: 'The ferry to the island',
      sentences: [
        WritingSentence.of(
          'Chúng tôi đã đi phà ra đảo Cát Bà.',
          'We took a ferry to Cat Ba Island.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Chiếc phà lớn hơn tôi tưởng.',
          'The ferry was bigger than I expected.',
          G.comparison,
        ),
        WritingSentence.of(
          'Cả ô tô và xe máy đều được chở trên phà.',
          'Both cars and motorbikes were carried on the ferry.',
          G.passive,
        ),
        WritingSentence.of(
          'Trong khi chúng tôi đang ngắm biển, một đàn cá heo xuất hiện.',
          'While we were looking at the sea, a group of dolphins appeared.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi chưa bao giờ nhìn thấy cá heo ngoài tự nhiên.',
          'I have never seen dolphins in the wild before.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu biển êm, chúng tôi sẽ đi phà về vào ngày mai.',
          'If the sea is calm, we will take the ferry back tomorrow.',
          G.conditional1,
        ),
      ],
    ),

    // ---------------- Nang cao ----------------
    WritingParagraph(
      id: 'traffic_a1',
      level: _a,
      titleVi: 'Cấm xe máy',
      titleEn: 'Banning motorbikes',
      sentences: [
        WritingSentence.of(
          'Hà Nội, thành phố có hơn sáu triệu xe máy, đang cân nhắc cấm xe máy ở trung tâm.',
          'Hanoi, which has over six million motorbikes, is considering a ban in the city centre.',
          G.relativeClause,
          alternatives: [
            'Hanoi, which has over six million motorbikes, is considering a ban in the city center.',
          ],
        ),
        WritingSentence.of(
          'Các chuyên gia đã và đang tranh luận về kế hoạch này suốt nhiều năm.',
          'Experts have been debating this plan for years.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Một người bán hàng rong nói với tôi rằng cô sẽ mất kế sinh nhai nếu không có xe máy.',
          'A street vendor told me that she would lose her income without her motorbike.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu hệ thống giao thông công cộng tốt hơn, người dân sẽ sẵn sàng bỏ xe máy.',
          'If public transport were better, people would be willing to give up their motorbikes.',
          G.conditional2,
          alternatives: [
            'If public transport was better, people would be willing to give up their motorbikes.',
          ],
        ),
        WritingSentence.of(
          'Trước khi các tuyến tàu điện được xây, lệnh cấm này gần như không thể thực hiện.',
          'Before the metro lines were built, such a ban had been almost impossible.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Đến cuối thập kỷ, bộ mặt giao thông thủ đô có lẽ đã thay đổi hoàn toàn.',
          'By the end of the decade, traffic in the capital will probably have changed completely.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'traffic_a2',
      level: _a,
      titleVi: 'Tai nạn vì rượu bia',
      titleEn: 'Drink driving',
      sentences: [
        WritingSentence.of(
          'Từ khi luật mới có hiệu lực, số vụ tai nạn do rượu bia đã giảm đáng kể.',
          'Since the new law came into effect, the number of drink driving accidents has fallen significantly.',
          G.presentPerfect,
          alternatives: [
            'Since the new law came into effect, the number of drink-driving accidents has fallen significantly.',
          ],
        ),
        WritingSentence.of(
          'Theo luật mới, người lái xe sẽ bị phạt dù chỉ uống một cốc bia.',
          'Under the new law, drivers are fined even if they have had only one beer.',
          G.passive,
        ),
        WritingSentence.of(
          'Chú tôi đã uống rượu ở đám cưới trước khi bị cảnh sát dừng xe.',
          'My uncle had been drinking at a wedding before the police stopped him.',
          G.pastPerfectContinuous,
        ),
        WritingSentence.of(
          'Chú thừa nhận rằng chú đã nghĩ mình vẫn đủ tỉnh táo để lái xe.',
          'He admitted that he had thought he was sober enough to drive.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu chú gọi taxi, chú đã không bị tước bằng lái hai năm.',
          'If he had called a taxi, he would not have lost his licence for two years.',
          G.conditional3,
          alternatives: [
            'If he had called a taxi, he would not have lost his license for two years.',
          ],
        ),
        WritingSentence.of(
          'Giờ chú là người luôn nhắc bạn bè không lái xe sau khi uống rượu.',
          'Now he is the one who always reminds friends not to drive after drinking.',
          G.relativeClause,
        ),
      ],
    ),
    WritingParagraph(
      id: 'traffic_a3',
      level: _a,
      titleVi: 'Đường sắt cao tốc',
      titleEn: 'High speed rail',
      sentences: [
        WritingSentence.of(
          'Tuyến đường sắt cao tốc Bắc Nam, dự án lớn nhất lịch sử đất nước, đang được lên kế hoạch.',
          'The North South high speed railway, which is the biggest project in the country\'s history, is being planned.',
          G.relativeClause,
          alternatives: [
            'The North-South high-speed railway, which is the biggest project in the country\'s history, is being planned.',
          ],
        ),
        WritingSentence.of(
          'Nếu tuyến đường hoàn thành, hành trình từ Hà Nội vào Sài Gòn sẽ chỉ mất khoảng năm tiếng.',
          'If the line were finished, the trip from Hanoi to Saigon would take only about five hours.',
          G.conditional2,
          alternatives: [
            'If the line was finished, the trip from Hanoi to Saigon would take only about five hours.',
          ],
        ),
        WritingSentence.of(
          'Các kỹ sư đã nghiên cứu những tuyến tương tự ở Nhật Bản và Trung Quốc.',
          'Engineers have studied similar lines in Japan and China.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Một quan chức nói rằng dự án sẽ tạo ra hàng trăm nghìn việc làm.',
          'An official said that the project would create hundreds of thousands of jobs.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Tuy nhiên, nhiều người lo ngại rằng chi phí sẽ cao hơn dự tính.',
          'However, many people worry that the cost will be higher than expected.',
          G.comparison,
        ),
        WritingSentence.of(
          'Vào thời điểm tàu chạy chuyến đầu tiên, tôi có lẽ đã ngoài bốn mươi tuổi.',
          'By the time the first train runs, I will probably have turned forty.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'traffic_a4',
      level: _a,
      titleVi: 'Ngập lụt và giao thông',
      titleEn: 'Flooded streets',
      sentences: [
        WritingSentence.of(
          'Mỗi khi mưa lớn, nhiều tuyến phố ở Sài Gòn bị ngập sâu đến đầu gối.',
          'Whenever it rains heavily, many streets in Saigon are flooded up to the knee.',
          G.passive,
        ),
        WritingSentence.of(
          'Tối qua, trời đã mưa suốt ba tiếng khi tôi rời văn phòng.',
          'Last night, it had been raining for three hours when I left the office.',
          G.pastPerfectContinuous,
        ),
        WritingSentence.of(
          'Chiếc xe máy mà tôi mới mua bị chết máy giữa đường.',
          'The motorbike that I had just bought broke down in the middle of the road.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Một người lạ, người đang dắt xe bên cạnh, đã giúp tôi đẩy xe về nhà.',
          'A stranger, who was pushing his own bike nearby, helped me push mine home.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Nếu thành phố có hệ thống thoát nước tốt hơn, chuyện này sẽ không xảy ra thường xuyên.',
          'If the city had a better drainage system, this would not happen so often.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Thành phố đã và đang xây những hồ chứa nước ngầm khổng lồ.',
          'The city has been building huge underground water tanks.',
          G.presentPerfectContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'traffic_a5',
      level: _a,
      titleVi: 'Thành phố của xe đạp',
      titleEn: 'A city of bicycles',
      sentences: [
        WritingSentence.of(
          'Amsterdam, nơi có nhiều xe đạp hơn dân số, là mô hình mà nhiều thành phố muốn học theo.',
          'Amsterdam, which has more bikes than people, is a model that many cities want to follow.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Trước khi đến đó, tôi chưa từng thấy làn đường dành riêng cho xe đạp rộng như vậy.',
          'Before I went there, I had never seen such wide bike lanes.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Người hướng dẫn giải thích rằng thành phố đã đầu tư vào xe đạp từ những năm bảy mươi.',
          'Our guide explained that the city had invested in cycling since the seventies.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu Việt Nam có nhiều làn xe đạp hơn, tôi sẽ đạp xe đi làm mỗi ngày.',
          'If Vietnam had more bike lanes, I would cycle to work every day.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Một số quận ở Hà Nội đã thử nghiệm dịch vụ xe đạp công cộng.',
          'Some districts in Hanoi have tried a public bike sharing service.',
          G.presentPerfect,
          alternatives: [
            'Some districts in Hanoi have tried a public bike-sharing service.',
          ],
        ),
        WritingSentence.of(
          'Vào giờ này năm sau, có lẽ nhiều người sẽ đang đạp xe quanh Hồ Gươm vào cuối tuần.',
          'This time next year, many people will probably be cycling around Hoan Kiem Lake at weekends.',
          G.futureContinuous,
          alternatives: [
            'This time next year, many people will probably be cycling around Hoan Kiem Lake on weekends.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'traffic_a6',
      level: _a,
      titleVi: 'Chuyến bay bị lỡ',
      titleEn: 'A missed flight',
      sentences: [
        WritingSentence.of(
          'Tuần trước, tôi lỡ chuyến bay đi Đà Nẵng vì tắc đường trên đường ra sân bay.',
          'Last week, I missed my flight to Da Nang because of a traffic jam on the way to the airport.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Khi tôi đến quầy làm thủ tục, cửa lên máy bay đã đóng được mười phút.',
          'When I reached the check in desk, the gate had already closed ten minutes earlier.',
          G.pastPerfect,
          alternatives: [
            'When I reached the check-in desk, the gate had already closed ten minutes earlier.',
          ],
        ),
        WritingSentence.of(
          'Nhân viên nói rằng tôi phải trả thêm tiền để đổi sang chuyến sau.',
          'The staff said that I had to pay extra to change to a later flight.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu tôi đi tàu điện ra sân bay, tôi đã không bị muộn.',
          'If I had taken the metro to the airport, I would not have been late.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Chuyến bay tiếp theo, vốn cất cánh lúc nửa đêm, chật kín hành khách.',
          'The next flight, which left at midnight, was completely full.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Từ giờ, tôi sẽ luôn ra sân bay sớm hơn ít nhất một tiếng.',
          'From now on, I will always leave for the airport at least an hour earlier.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'traffic_a7',
      level: _a,
      titleVi: 'Văn hoá giao thông',
      titleEn: 'Traffic culture',
      sentences: [
        WritingSentence.of(
          'Nhiều du khách nước ngoài nói rằng giao thông Việt Nam vừa hỗn loạn vừa kỳ diệu.',
          'Many foreign visitors say that traffic in Vietnam is both chaotic and amazing.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Một người bạn Đức kể với tôi rằng anh đã đứng mười phút mà không dám qua đường.',
          'A German friend told me that he had stood for ten minutes without daring to cross the road.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Người lái xe ở đây giao tiếp bằng còi, thứ mà ở châu Âu thường bị coi là bất lịch sự.',
          'Drivers here communicate with their horns, which is often considered rude in Europe.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Nếu mọi người tuân thủ luật lệ hơn, giao thông sẽ an toàn và dễ đoán hơn.',
          'If people followed the rules more closely, traffic would be safer and more predictable.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Các trường học đã và đang đưa giáo dục an toàn giao thông vào chương trình học.',
          'Schools have been adding road safety education to their lessons.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Tôi tin rằng thế hệ trẻ sẽ thay đổi văn hoá giao thông của đất nước.',
          'I believe that the younger generation will change the country\'s traffic culture.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'traffic_a8',
      level: _a,
      titleVi: 'Làm tài xế công nghệ',
      titleEn: 'Life as a ride app driver',
      sentences: [
        WritingSentence.of(
          'Anh hàng xóm của tôi, người từng là kỹ sư, giờ đã chạy xe ôm công nghệ được hai năm.',
          'My neighbor, who used to be an engineer, has been working as a ride app driver for two years.',
          G.presentPerfectContinuous,
          alternatives: [
            'My neighbour, who used to be an engineer, has been working as a ride app driver for two years.',
          ],
        ),
        WritingSentence.of(
          'Anh ấy bỏ công việc cũ sau khi công ty cắt giảm nhân sự.',
          'He left his old job after his company had cut staff.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Anh nói rằng mỗi ngày anh phải chạy hơn mười tiếng để đủ tiền nuôi gia đình.',
          'He said that he had to ride for over ten hours a day to support his family.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Những ngày mưa, anh kiếm được nhiều tiền hơn nhưng cũng nguy hiểm hơn.',
          'On rainy days, he earns more money, but it is also more dangerous.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu có cơ hội, anh ấy sẽ quay lại làm kỹ sư.',
          'If he got the chance, he would go back to engineering.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Đến cuối năm, anh ấy sẽ tiết kiệm đủ tiền để mở một tiệm sửa xe.',
          'By the end of the year, he will have saved enough to open a repair shop.',
          G.futurePerfect,
        ),
      ],
    ),
  ],
);

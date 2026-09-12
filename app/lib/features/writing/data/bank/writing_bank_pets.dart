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

const kWritingBankPets = WritingTopic(
  id: 'pets',
  titleVi: 'Thú cưng',
  titleEn: 'Pets',
  icon: Icons.pets_rounded,
  color: AppColors.teal,
  paragraphs: [
    // ---------------- Co ban ----------------
    WritingParagraph(
      id: 'pets_b1',
      level: _b,
      titleVi: 'Con chó của tôi',
      titleEn: 'My dog',
      sentences: [
        WritingSentence.of(
          'Tôi có một con chó.',
          'I have a dog.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Nó tên là Bông.',
          'Its name is Bong.',
          G.presentSimple,
          alternatives: ['His name is Bong.'],
        ),
        WritingSentence.of(
          'Nó có bộ lông màu trắng.',
          'It has white fur.',
          G.presentSimple,
          alternatives: ['He has white fur.'],
        ),
        WritingSentence.of(
          'Nó thích chạy trong vườn.',
          'It likes running in the garden.',
          G.presentSimple,
          alternatives: ['He likes running in the garden.'],
        ),
        WritingSentence.of(
          'Nó là người bạn tốt nhất của tôi.',
          'It is my best friend.',
          G.presentSimple,
          alternatives: ['He is my best friend.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'pets_b2',
      level: _b,
      titleVi: 'Con mèo lười',
      titleEn: 'A lazy cat',
      sentences: [
        WritingSentence.of(
          'Bà tôi nuôi một con mèo.',
          'My grandmother has a cat.',
          G.presentSimple,
          alternatives: ['My grandma has a cat.'],
        ),
        WritingSentence.of(
          'Nó ngủ gần như cả ngày.',
          'It sleeps almost all day.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Bây giờ nó đang nằm trên ghế sô pha.',
          'Now it is lying on the sofa.',
          G.presentContinuous,
          alternatives: ['It is lying on the sofa now.'],
        ),
        WritingSentence.of(
          'Nó rất thích ăn cá.',
          'It really likes eating fish.',
          G.presentSimple,
          alternatives: ['It loves eating fish.'],
        ),
        WritingSentence.of(
          'Nó có thể bắt chuột.',
          'It can catch mice.',
          G.modal,
        ),
      ],
    ),
    WritingParagraph(
      id: 'pets_b3',
      level: _b,
      titleVi: 'Cho cá ăn',
      titleEn: 'Feeding the fish',
      sentences: [
        WritingSentence.of(
          'Nhà tôi có một bể cá nhỏ.',
          'We have a small fish tank at home.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Có năm con cá vàng trong bể.',
          'There are five goldfish in the tank.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi cho cá ăn mỗi sáng.',
          'I feed the fish every morning.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Chúng ta không nên cho cá ăn quá nhiều.',
          'We should not feed them too much.',
          G.modal,
          alternatives: ['We shouldn\'t feed them too much.'],
        ),
        WritingSentence.of(
          'Cuối tuần này, tôi sẽ rửa bể cá.',
          'This weekend, I will clean the tank.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'pets_b4',
      level: _b,
      titleVi: 'Chú chó con mới',
      titleEn: 'A new puppy',
      sentences: [
        WritingSentence.of(
          'Hôm qua bố tôi đã mang về một chú chó con.',
          'Yesterday my father brought home a puppy.',
          G.pastSimple,
          alternatives: ['Yesterday my dad brought home a puppy.'],
        ),
        WritingSentence.of(
          'Nó rất nhỏ và dễ thương.',
          'It was very small and cute.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Nó đã khóc suốt đêm.',
          'It cried all night.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã cho nó uống sữa.',
          'I gave it some milk.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Sáng nay nó đã ngủ trên chân tôi.',
          'This morning it slept on my feet.',
          G.pastSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'pets_b5',
      level: _b,
      titleVi: 'Dắt chó đi dạo',
      titleEn: 'Walking the dog',
      sentences: [
        WritingSentence.of(
          'Tôi dắt chó đi dạo mỗi chiều.',
          'I walk my dog every afternoon.',
          G.presentSimple,
          alternatives: ['I take my dog for a walk every afternoon.'],
        ),
        WritingSentence.of(
          'Chúng tôi đi đến công viên.',
          'We go to the park.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Bây giờ nó đang chơi với một con chó khác.',
          'Now it is playing with another dog.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Tôi phải mang theo túi nhặt phân.',
          'I must bring a bag to clean up after it.',
          G.modal,
          alternatives: ['I have to bring a bag to clean up after it.'],
        ),
        WritingSentence.of(
          'Chúng ta nên giữ công viên sạch sẽ.',
          'We should keep the park clean.',
          G.modal,
        ),
      ],
    ),
    WritingParagraph(
      id: 'pets_b6',
      level: _b,
      titleVi: 'Con thỏ của em gái',
      titleEn: 'My sister\'s rabbit',
      sentences: [
        WritingSentence.of(
          'Em gái tôi muốn nuôi một con thỏ.',
          'My sister wants a pet rabbit.',
          G.presentSimple,
          alternatives: ['My younger sister wants a rabbit.'],
        ),
        WritingSentence.of(
          'Cuối tuần này, mẹ định mua cho em ấy một con.',
          'This weekend, Mom is going to buy her one.',
          G.goingTo,
          alternatives: ['This weekend, our mother is going to buy her one.'],
        ),
        WritingSentence.of(
          'Em ấy sẽ đặt tên nó là Mây.',
          'She will name it May.',
          G.futureSimple,
          alternatives: ['She will call it May.'],
        ),
        WritingSentence.of(
          'Thỏ thích ăn cà rốt và rau xanh.',
          'Rabbits like carrots and green vegetables.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Em ấy phải chăm sóc nó mỗi ngày.',
          'She must take care of it every day.',
          G.modal,
          alternatives: ['She has to look after it every day.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'pets_b7',
      level: _b,
      titleVi: 'Đưa mèo đi khám',
      titleEn: 'A trip to the vet',
      sentences: [
        WritingSentence.of(
          'Hôm qua con mèo của tôi bị ốm.',
          'Yesterday my cat was sick.',
          G.pastSimple,
          alternatives: ['My cat was ill yesterday.'],
        ),
        WritingSentence.of(
          'Nó đã không ăn gì cả.',
          'It did not eat anything.',
          G.pastSimple,
          alternatives: ['It didn\'t eat anything.'],
        ),
        WritingSentence.of(
          'Tôi đã đưa nó đến bác sĩ thú y.',
          'I took it to the vet.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Bác sĩ đã cho nó thuốc.',
          'The vet gave it some medicine.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Hôm nay nó đã khoẻ hơn — nó lại chạy nhảy.',
          'Today it is running around again.',
          G.presentContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'pets_b8',
      level: _b,
      titleVi: 'Chú vẹt biết nói',
      titleEn: 'A talking parrot',
      sentences: [
        WritingSentence.of(
          'Chú tôi có một con vẹt.',
          'My uncle has a parrot.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Nó có lông màu xanh lá và màu vàng.',
          'It has green and yellow feathers.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Nó có thể nói "xin chào".',
          'It can say hello.',
          G.modal,
        ),
        WritingSentence.of(
          'Bây giờ nó đang hát theo ti vi.',
          'Now it is singing along with the TV.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Tôi sẽ dạy nó một từ tiếng Anh mới.',
          'I will teach it a new English word.',
          G.futureSimple,
        ),
      ],
    ),

    // ---------------- Trung cap ----------------
    WritingParagraph(
      id: 'pets_i1',
      level: _i,
      titleVi: 'Nhận nuôi chó',
      titleEn: 'Adopting a dog',
      sentences: [
        WritingSentence.of(
          'Gia đình tôi vừa nhận nuôi một chú chó từ trạm cứu hộ.',
          'My family has just adopted a dog from a shelter.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nó đã bị bỏ rơi bên đường.',
          'It was abandoned by the side of the road.',
          G.passive,
        ),
        WritingSentence.of(
          'Nó nhút nhát hơn những con chó khác.',
          'It is shyer than other dogs.',
          G.comparison,
          alternatives: ['It is more shy than other dogs.'],
        ),
        WritingSentence.of(
          'Tối qua, trong khi chúng tôi đang ăn tối, nó lần đầu tiên vẫy đuôi.',
          'Last night, while we were having dinner, it wagged its tail for the first time.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nhận nuôi tốt hơn mua chó ở cửa hàng.',
          'Adopting is better than buying a dog from a shop.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu có không gian, chúng tôi sẽ nhận nuôi thêm một con nữa.',
          'If we have enough space, we will adopt another one.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'pets_i2',
      level: _i,
      titleVi: 'Mèo đi lạc',
      titleEn: 'The missing cat',
      sentences: [
        WritingSentence.of(
          'Tuần trước, con mèo của tôi đã đi lạc.',
          'Last week, my cat went missing.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Chúng tôi đã tìm nó khắp khu phố.',
          'We searched for it all over the neighborhood.',
          G.pastSimple,
          alternatives: ['We searched for it all over the neighbourhood.'],
        ),
        WritingSentence.of(
          'Ảnh của nó được chia sẻ trên mạng xã hội.',
          'Its photo was shared on social media.',
          G.passive,
        ),
        WritingSentence.of(
          'Hai ngày sau, khi tôi đang đi học về, tôi nghe thấy tiếng kêu từ trên cây.',
          'Two days later, while I was walking home, I heard a cry from a tree.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi chưa bao giờ vui như vậy.',
          'I have never been so happy.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu nó lại đi lạc, tôi sẽ đeo vòng định vị cho nó.',
          'If it gets lost again, I will put a tracker on its collar.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'pets_i3',
      level: _i,
      titleVi: 'Chó hay mèo',
      titleEn: 'Dogs or cats',
      sentences: [
        WritingSentence.of(
          'Nhiều người thích chó hơn mèo.',
          'Many people prefer dogs to cats.',
          G.comparison,
        ),
        WritingSentence.of(
          'Chó trung thành hơn nhưng cần nhiều thời gian hơn.',
          'Dogs are more loyal, but they need more time.',
          G.comparison,
        ),
        WritingSentence.of(
          'Mèo được coi là độc lập hơn chó.',
          'Cats are considered more independent than dogs.',
          G.passive,
        ),
        WritingSentence.of(
          'Tôi đã nuôi cả chó và mèo.',
          'I have had both dogs and cats.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Một lần, khi con chó đang ngủ, con mèo đã lấy mất đồ chơi của nó.',
          'Once, while the dog was sleeping, the cat stole its toy.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nếu bạn bận rộn, bạn nên nuôi mèo.',
          'If you are busy, you should get a cat.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'pets_i4',
      level: _i,
      titleVi: 'Huấn luyện chó',
      titleEn: 'Training my dog',
      sentences: [
        WritingSentence.of(
          'Tôi đã huấn luyện chó của tôi được ba tháng.',
          'I have trained my dog for three months.',
          G.presentPerfect,
          alternatives: ['I have been training my dog for three months.'],
        ),
        WritingSentence.of(
          'Bây giờ nó nghe lời hơn trước nhiều.',
          'Now it is much more obedient than before.',
          G.comparison,
        ),
        WritingSentence.of(
          'Mỗi lần làm đúng, nó được thưởng một miếng bánh.',
          'Every time it does something right, it is given a treat.',
          G.passive,
        ),
        WritingSentence.of(
          'Hôm qua, khi chúng tôi đang tập ở công viên, nó chạy theo một con chim.',
          'Yesterday, while we were practicing in the park, it ran after a bird.',
          G.pastContinuous,
          alternatives: [
            'Yesterday, while we were practising in the park, it ran after a bird.',
          ],
        ),
        WritingSentence.of(
          'Huấn luyện chó cần rất nhiều kiên nhẫn.',
          'Training a dog needs a lot of patience.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Nếu nó học được lệnh mới, tôi sẽ quay video khoe bạn bè.',
          'If it learns a new command, I will film it for my friends.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'pets_i5',
      level: _i,
      titleVi: 'Chăm thú cưng khi đi vắng',
      titleEn: 'Pet sitting',
      sentences: [
        WritingSentence.of(
          'Hàng xóm nhờ tôi trông mèo khi họ đi du lịch.',
          'My neighbors asked me to look after their cat while they travel.',
          G.presentSimple,
          alternatives: [
            'My neighbours asked me to look after their cat while they travel.',
          ],
        ),
        WritingSentence.of(
          'Con mèo của họ lớn hơn mèo của tôi nhiều.',
          'Their cat is much bigger than mine.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nó được cho ăn đồ ăn đặc biệt hai lần một ngày.',
          'It is fed special food twice a day.',
          G.passive,
        ),
        WritingSentence.of(
          'Sáng nay, khi tôi đang mở cửa, nó chạy ra ngoài hành lang.',
          'This morning, while I was opening the door, it ran into the hallway.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi đã mất mười phút để bắt nó lại.',
          'It took me ten minutes to catch it.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Nếu họ cần giúp lần nữa, tôi sẽ cẩn thận hơn.',
          'If they need help again, I will be more careful.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'pets_i6',
      level: _i,
      titleVi: 'Tiệm cắt tỉa lông',
      titleEn: 'At the pet groomer',
      sentences: [
        WritingSentence.of(
          'Chó của chị tôi vừa được cắt tỉa lông.',
          'My sister\'s dog has just had a haircut.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nó được tắm và chải lông bởi một nhân viên rất nhẹ nhàng.',
          'It was washed and brushed by a very gentle worker.',
          G.passive,
        ),
        WritingSentence.of(
          'Bây giờ nó trông nhỏ hơn và mát hơn.',
          'Now it looks smaller and cooler.',
          G.comparison,
        ),
        WritingSentence.of(
          'Trong khi nó đang được sấy khô, nó ngủ gật.',
          'While it was being dried, it fell asleep.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tiệm này sạch sẽ nhất trong khu vực.',
          'This shop is the cleanest in the area.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu trời nóng hơn, chị ấy sẽ cắt lông cho nó ngắn hơn nữa.',
          'If it gets hotter, she will have its fur cut even shorter.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'pets_i7',
      level: _i,
      titleVi: 'Nuôi gà ở quê',
      titleEn: 'Chickens at grandma\'s house',
      sentences: [
        WritingSentence.of(
          'Bà tôi đã nuôi gà ở quê nhiều năm nay.',
          'My grandmother has kept chickens in the countryside for many years.',
          G.presentPerfect,
          alternatives: [
            'My grandma has kept chickens in the countryside for many years.',
          ],
        ),
        WritingSentence.of(
          'Trứng gà của bà ngon hơn trứng ở siêu thị.',
          'Her eggs taste better than the ones from the supermarket.',
          G.comparison,
        ),
        WritingSentence.of(
          'Gà được thả trong vườn suốt cả ngày.',
          'The chickens are kept free in the garden all day.',
          G.passive,
        ),
        WritingSentence.of(
          'Hôm qua, khi tôi đang nhặt trứng, một con gà mổ vào tay tôi.',
          'Yesterday, while I was collecting eggs, a hen pecked my hand.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi đã học được cách chăm sóc gà.',
          'I have learned how to look after chickens.',
          G.presentPerfect,
          alternatives: ['I have learnt how to look after chickens.'],
        ),
        WritingSentence.of(
          'Nếu nhà tôi có vườn, tôi cũng sẽ nuôi vài con.',
          'If we get a garden, I will keep a few chickens too.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'pets_i8',
      level: _i,
      titleVi: 'Chó già',
      titleEn: 'An old dog',
      sentences: [
        WritingSentence.of(
          'Chó của chúng tôi đã sống với gia đình được mười lăm năm.',
          'Our dog has lived with our family for fifteen years.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Bây giờ nó đi chậm hơn và ngủ nhiều hơn.',
          'Now it walks more slowly and sleeps more.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nó được bác sĩ thú y khám mỗi tháng.',
          'It is checked by the vet every month.',
          G.passive,
        ),
        WritingSentence.of(
          'Tối qua, khi tôi đang đọc sách, nó nằm tựa đầu vào chân tôi.',
          'Last night, while I was reading, it rested its head on my feet.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nó là thành viên già nhất trong nhà.',
          'It is the oldest member of our family.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu nó cảm thấy đau, chúng tôi sẽ đưa nó đi khám ngay.',
          'If it feels any pain, we will take it to the vet at once.',
          G.conditional1,
        ),
      ],
    ),

    // ---------------- Nang cao ----------------
    WritingParagraph(
      id: 'pets_a1',
      level: _a,
      titleVi: 'Trạm cứu hộ động vật',
      titleEn: 'An animal shelter',
      sentences: [
        WritingSentence.of(
          'Trạm cứu hộ nơi tôi làm tình nguyện đang chăm sóc hơn hai trăm con chó và mèo.',
          'The shelter where I volunteer is caring for more than two hundred dogs and cats.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Nhiều con đã bị chủ bỏ rơi sau khi chúng không còn là thú cưng nhỏ dễ thương.',
          'Many of them were abandoned after they had stopped being cute little pets.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Người quản lý nói rằng số động vật bị bỏ rơi tăng mạnh sau mỗi dịp Tết.',
          'The manager said that the number of abandoned animals rose sharply after every Tet.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu mọi người suy nghĩ kỹ trước khi nuôi thú cưng, những trạm như thế này sẽ không quá tải.',
          'If people thought carefully before getting a pet, shelters like this would not be so full.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Tôi đã dành mỗi sáng Chủ nhật ở đó suốt hai năm qua.',
          'I have been spending every Sunday morning there for the past two years.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Đến cuối năm, trạm hy vọng sẽ tìm được nhà cho một trăm con vật.',
          'By the end of the year, the shelter hopes it will have found homes for a hundred animals.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'pets_a2',
      level: _a,
      titleVi: 'Chó nghiệp vụ',
      titleEn: 'Working dogs',
      sentences: [
        WritingSentence.of(
          'Chó nghiệp vụ, những con được huấn luyện đặc biệt, giúp cảnh sát tìm ma tuý và người mất tích.',
          'Police dogs, which receive special training, help officers find drugs and missing people.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Mỗi con chó được huấn luyện ít nhất một năm trước khi bắt đầu làm việc.',
          'Each dog is trained for at least a year before it starts working.',
          G.passive,
        ),
        WritingSentence.of(
          'Người huấn luyện kể rằng con chó của anh đã cứu một bé gái bị lạc trong rừng.',
          'The trainer told us that his dog had saved a little girl lost in the forest.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Đội cứu hộ đã tìm kiếm suốt hai ngày trước khi con chó phát hiện ra cô bé.',
          'The rescue team had been searching for two days before the dog found her.',
          G.pastPerfectContinuous,
        ),
        WritingSentence.of(
          'Nếu không có con chó đó, có lẽ cô bé đã không sống sót.',
          'If it had not been for that dog, the girl might not have survived.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Khi nghỉ hưu, những con chó này thường được chính người huấn luyện nhận nuôi.',
          'When they retire, these dogs are often adopted by their own trainers.',
          G.passive,
        ),
      ],
    ),
    WritingParagraph(
      id: 'pets_a3',
      level: _a,
      titleVi: 'Thú cưng và sức khỏe tinh thần',
      titleEn: 'Pets and mental health',
      sentences: [
        WritingSentence.of(
          'Nhiều nghiên cứu đã chỉ ra rằng nuôi thú cưng giúp giảm căng thẳng và cô đơn.',
          'Many studies have shown that keeping a pet reduces stress and loneliness.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Bạn tôi, người sống một mình ở thành phố, đã nhận nuôi một chú mèo năm ngoái.',
          'My friend, who lives alone in the city, adopted a cat last year.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Trước khi có mèo, cô ấy đã cảm thấy buồn chán suốt nhiều tháng.',
          'Before she got the cat, she had been feeling down for months.',
          G.pastPerfectContinuous,
        ),
        WritingSentence.of(
          'Cô kể rằng tiếng mèo kêu mỗi sáng khiến cô muốn thức dậy.',
          'She said that the cat\'s meowing every morning made her want to get up.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu cô ấy không nhận nuôi nó, có lẽ cô vẫn đang rất cô đơn.',
          'If she had not adopted it, she might still be very lonely.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Một số bệnh viện đã bắt đầu dùng chó trị liệu để giúp bệnh nhân.',
          'Some hospitals have started using therapy dogs to help patients.',
          G.presentPerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'pets_a4',
      level: _a,
      titleVi: 'Buôn bán động vật hoang dã',
      titleEn: 'The exotic pet trade',
      sentences: [
        WritingSentence.of(
          'Nuôi động vật hoang dã làm thú cưng, như khỉ hay rùa quý, đang trở thành trào lưu nguy hiểm.',
          'Keeping wild animals as pets, such as monkeys or rare turtles, is becoming a dangerous trend.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Nhiều con vật bị bắt khỏi rừng khi còn rất nhỏ.',
          'Many of these animals are taken from the forest when they are very young.',
          G.passive,
        ),
        WritingSentence.of(
          'Một nhà bảo tồn giải thích rằng hầu hết chúng chết trước khi đến tay người mua.',
          'A conservationist explained that most of them died before they reached the buyer.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Người hàng xóm của tôi, người từng nuôi một con khỉ, đã phải giao nó cho trung tâm cứu hộ.',
          'My neighbor, who used to keep a monkey, had to hand it over to a rescue centre.',
          G.relativeClause,
          alternatives: [
            'My neighbour, who used to keep a monkey, had to hand it over to a rescue center.',
          ],
        ),
        WritingSentence.of(
          'Nếu không có người mua, nạn buôn bán này sẽ biến mất.',
          'If there were no buyers, this trade would disappear.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Chính phủ đã và đang tăng mức phạt cho những ai buôn bán động vật hoang dã.',
          'The government has been raising fines for anyone who trades wild animals.',
          G.presentPerfectContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'pets_a5',
      level: _a,
      titleVi: 'Bác sĩ thú y',
      titleEn: 'Life as a vet',
      sentences: [
        WritingSentence.of(
          'Chị họ tôi đã làm bác sĩ thú y được tám năm.',
          'My cousin has been working as a vet for eight years.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Phòng khám mà chị ấy mở chuyên chữa trị cho chó mèo bị bỏ rơi.',
          'The clinic that she opened specializes in treating abandoned cats and dogs.',
          G.relativeClause,
          alternatives: [
            'The clinic that she opened specialises in treating abandoned cats and dogs.',
          ],
        ),
        WritingSentence.of(
          'Khi còn học đại học, chị đã từng muốn bỏ ngành vì quá khó.',
          'When she was at university, she had wanted to quit because it was too hard.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Chị nói với tôi rằng phần khó nhất của công việc là nói lời tạm biệt với những con vật không thể cứu.',
          'She told me that the hardest part was saying goodbye to animals she could not save.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu chị ấy bỏ cuộc hồi đó, hàng nghìn con vật đã không được cứu sống.',
          'If she had given up back then, thousands of animals would not have been saved.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Tháng sau, chị ấy sẽ đang tổ chức một đợt tiêm phòng miễn phí.',
          'Next month, she will be running a free vaccination day.',
          G.futureContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'pets_a6',
      level: _a,
      titleVi: 'Thú cưng ở chung cư',
      titleEn: 'Pets in apartments',
      sentences: [
        WritingSentence.of(
          'Nhiều chung cư mới không cho phép cư dân nuôi chó mèo.',
          'Many new apartment buildings do not allow residents to keep dogs or cats.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Toà nhà nơi tôi sống đã thay đổi quy định sau nhiều cuộc họp căng thẳng.',
          'The building where I live has changed its rules after many tense meetings.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Một số hàng xóm phàn nàn rằng chó sủa làm họ mất ngủ.',
          'Some neighbors complained that barking dogs kept them awake.',
          G.reportedSpeech,
          alternatives: [
            'Some neighbours complained that barking dogs kept them awake.',
          ],
        ),
        WritingSentence.of(
          'Giờ đây, thú cưng phải được đăng ký và đeo rọ mõm ở khu vực chung.',
          'Now pets must be registered and muzzled in shared areas.',
          G.passive,
        ),
        WritingSentence.of(
          'Nếu mọi chủ nuôi đều có trách nhiệm, sẽ không cần những quy định nghiêm ngặt như vậy.',
          'If all owners were responsible, such strict rules would not be necessary.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Tôi đã dắt chó đi dạo bằng thang máy chở hàng suốt từ khi có quy định mới.',
          'I have been taking my dog out in the service lift since the new rules started.',
          G.presentPerfectContinuous,
          alternatives: [
            'I have been taking my dog out in the service elevator since the new rules started.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'pets_a7',
      level: _a,
      titleVi: 'Mất đi người bạn nhỏ',
      titleEn: 'Losing a pet',
      sentences: [
        WritingSentence.of(
          'Tháng trước, con chó mà gia đình tôi nuôi suốt mười bốn năm đã qua đời.',
          'Last month, the dog that my family had kept for fourteen years passed away.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Nó đã yếu dần suốt nhiều tuần trước khi chúng tôi nhận ra nó bị bệnh nặng.',
          'It had been getting weaker for weeks before we realized it was seriously ill.',
          G.pastPerfectContinuous,
          alternatives: [
            'It had been getting weaker for weeks before we realised it was seriously ill.',
          ],
        ),
        WritingSentence.of(
          'Bác sĩ thú y nói rằng chúng tôi đã cho nó một cuộc đời hạnh phúc.',
          'The vet said that we had given it a happy life.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu chúng tôi đưa nó đi khám sớm hơn, có lẽ nó đã sống thêm được một thời gian.',
          'If we had taken it to the vet earlier, it might have lived a little longer.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Ngôi nhà giờ yên lặng hơn bao giờ hết.',
          'The house is quieter now than it has ever been.',
          G.comparison,
        ),
        WritingSentence.of(
          'Khi đã sẵn sàng, chúng tôi sẽ nhận nuôi một chú chó khác từ trạm cứu hộ.',
          'When we are ready, we will adopt another dog from a shelter.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'pets_a8',
      level: _a,
      titleVi: 'Chi phí nuôi thú cưng',
      titleEn: 'The cost of a pet',
      sentences: [
        WritingSentence.of(
          'Nhiều người không nhận ra rằng nuôi thú cưng tốn kém hơn họ tưởng rất nhiều.',
          'Many people do not realize that keeping a pet is much more expensive than they think.',
          G.comparison,
          alternatives: [
            'Many people do not realise that keeping a pet is much more expensive than they think.',
          ],
        ),
        WritingSentence.of(
          'Khi tôi nhận nuôi mèo, tôi chưa từng tính đến tiền tiêm phòng và thức ăn.',
          'When I adopted my cat, I had never thought about the cost of vaccines and food.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Một bác sĩ thú y khuyên rằng chủ nuôi nên để dành một khoản cho những trường hợp khẩn cấp.',
          'A vet advised that owners should save some money for emergencies.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu tôi biết trước những chi phí đó, tôi đã chuẩn bị kỹ hơn.',
          'If I had known about those costs, I would have prepared better.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Mèo của tôi, con vật tôi yêu nhất trên đời, đáng giá từng đồng tôi bỏ ra.',
          'My cat, which I love more than anything, is worth every penny.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Đến cuối năm nay, tôi sẽ tiết kiệm đủ tiền cho bảo hiểm thú cưng.',
          'By the end of this year, I will have saved enough for pet insurance.',
          G.futurePerfect,
        ),
      ],
    ),
  ],
);

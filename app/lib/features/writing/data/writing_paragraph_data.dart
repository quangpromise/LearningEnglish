// Noi dung Luyen Viet - che do "Doan van": 24 doan, moi doan 6 cau NGAN GON
// (dung yeu cau "khong dai dong") = 144 cau, rai deu de ca 12 thi trong
// kAllTenseLabels deu xuat hien (moi thi 12 lan - cac doan xen ke 2 nhom
// thi: nhom A gom 6 thi hien tai/qua khu don gian, nhom B gom 6 thi hoan
// thanh/tuong lai). Tu soan moi hoan toan, khong sao chep tu nguon nao - dap
// an tieng Anh ([WritingSentence.en]) la CHUAN THAM CHIEU DUY NHAT dung de
// cham diem (xem writing_scoring.dart), khong chap nhan cau dong nghia khac
// cau truc.

import '../../learning_path/data/learning_path_models.dart';

class WritingSentence {
  const WritingSentence({
    required this.id,
    required this.vi,
    required this.en,
    required this.tenseLabel,
    this.alternatives = const [],
  });

  /// Dang gon cho ngan hang bai theo cap (writing_bank_*.dart) - khong can
  /// id rieng tung cau (UI khong dung toi, chi bo 24 doan cu co id de test
  /// cu van giu nguyen).
  const WritingSentence.of(
    this.vi,
    this.en,
    this.tenseLabel, {
    this.alternatives = const [],
  }) : id = '';

  final String id;
  final String vi;

  /// Dap an tham chieu CHINH dung de cham diem va hien "Dap an dung".
  final String en;

  /// Cac cach viet dung KHAC cung cau truc (vd "mom" thay "mother") - cham
  /// diem lay ket qua cao nhat giua [en] va cac cau nay (xem
  /// scoreSentenceBest), tranh cham sai oan khi 1 cau co nhieu cach dich.
  final List<String> alternatives;

  /// Ten thi/cau truc ngu phap - hien sau khi cham de giai thich vi sao
  /// dung/sai. Bo 24 doan cu chi dung 12 thi (kAllTenseLabels); ngan hang
  /// theo cap dung them cac cau truc khac (xem kGrammarLabelsByLevel).
  final String tenseLabel;
}

class WritingParagraph {
  const WritingParagraph({
    required this.id,
    required this.titleVi,
    required this.titleEn,
    required this.sentences,
    this.level,
  });

  final String id;
  final String titleVi;
  final String titleEn;
  final List<WritingSentence> sentences;

  /// Cap cua bai (ngan hang theo cap) - null = bo 24 doan "Tong hop 12 thi"
  /// cu, tron nhieu thi trong 1 doan.
  final LearnerLevel? level;
}

/// 12 thi co dinh cua tieng Anh - dung lam nhan giai thich va de test kiem
/// tra khong soan thieu sot 1 thi nao.
const kAllTenseLabels = [
  'Hiện tại đơn',
  'Hiện tại tiếp diễn',
  'Hiện tại hoàn thành',
  'Hiện tại hoàn thành tiếp diễn',
  'Quá khứ đơn',
  'Quá khứ tiếp diễn',
  'Quá khứ hoàn thành',
  'Quá khứ hoàn thành tiếp diễn',
  'Tương lai đơn',
  'Tương lai gần (going to)',
  'Tương lai tiếp diễn',
  'Tương lai hoàn thành',
];

const kWritingParagraphs = <WritingParagraph>[
  WritingParagraph(
    id: 'family',
    titleVi: 'Gia đình',
    titleEn: 'Family',
    sentences: [
      WritingSentence(
        id: 'family_1',
        vi: 'Gia đình tôi sống ở Đà Nẵng.',
        en: 'My family lives in Da Nang.',
        tenseLabel: 'Hiện tại đơn',
      ),
      WritingSentence(
        id: 'family_2',
        vi: 'Bố tôi đang nấu bữa tối trong bếp.',
        en: 'My father is cooking dinner in the kitchen.',
        tenseLabel: 'Hiện tại tiếp diễn',
      ),
      WritingSentence(
        id: 'family_3',
        vi: 'Tôi đã sống ở đây được ba năm rồi.',
        en: 'I have lived here for three years.',
        tenseLabel: 'Hiện tại hoàn thành',
      ),
      WritingSentence(
        id: 'family_4',
        vi: 'Mẹ tôi đã làm vườn suốt cả buổi sáng.',
        en: 'My mother has been gardening all morning.',
        tenseLabel: 'Hiện tại hoàn thành tiếp diễn',
      ),
      WritingSentence(
        id: 'family_5',
        vi: 'Năm ngoái, cả nhà tôi đi du lịch Đà Lạt.',
        en: 'Last year, my whole family traveled to Da Lat.',
        tenseLabel: 'Quá khứ đơn',
      ),
      WritingSentence(
        id: 'family_6',
        vi: 'Lúc 8 giờ tối qua, chúng tôi đang ăn tối cùng nhau.',
        en: 'At 8 p.m. last night, we were having dinner together.',
        tenseLabel: 'Quá khứ tiếp diễn',
      ),
    ],
  ),
  WritingParagraph(
    id: 'work',
    titleVi: 'Công việc',
    titleEn: 'Work',
    sentences: [
      WritingSentence(
        id: 'work_1',
        vi: 'Trước khi tôi đến, sếp đã rời văn phòng.',
        en: 'Before I arrived, my boss had left the office.',
        tenseLabel: 'Quá khứ hoàn thành',
      ),
      WritingSentence(
        id: 'work_2',
        vi: 'Anh ấy đã làm việc suốt năm giờ trước khi nghỉ giải lao.',
        en: 'He had been working for five hours before he took a break.',
        tenseLabel: 'Quá khứ hoàn thành tiếp diễn',
      ),
      WritingSentence(
        id: 'work_3',
        vi: 'Tôi sẽ hoàn thành báo cáo vào ngày mai.',
        en: 'I will finish the report tomorrow.',
        tenseLabel: 'Tương lai đơn',
      ),
      WritingSentence(
        id: 'work_4',
        vi: 'Công ty sắp tổ chức một cuộc họp quan trọng.',
        en: 'The company is going to hold an important meeting.',
        tenseLabel: 'Tương lai gần (going to)',
      ),
      WritingSentence(
        id: 'work_5',
        vi: 'Vào lúc này ngày mai, tôi sẽ đang thuyết trình.',
        en: 'At this time tomorrow, I will be giving a presentation.',
        tenseLabel: 'Tương lai tiếp diễn',
      ),
      WritingSentence(
        id: 'work_6',
        vi: 'Đến cuối năm nay, tôi sẽ hoàn thành dự án này.',
        en: 'By the end of this year, I will have completed this project.',
        tenseLabel: 'Tương lai hoàn thành',
      ),
    ],
  ),
  WritingParagraph(
    id: 'travel',
    titleVi: 'Du lịch',
    titleEn: 'Travel',
    sentences: [
      WritingSentence(
        id: 'travel_1',
        vi: 'Tôi thích khám phá những thành phố mới.',
        en: 'I like exploring new cities.',
        tenseLabel: 'Hiện tại đơn',
      ),
      WritingSentence(
        id: 'travel_2',
        vi: 'Chúng tôi đang lên kế hoạch cho chuyến đi Nhật Bản.',
        en: 'We are planning a trip to Japan.',
        tenseLabel: 'Hiện tại tiếp diễn',
      ),
      WritingSentence(
        id: 'travel_3',
        vi: 'Tôi đã đến thăm năm quốc gia châu Á.',
        en: 'I have visited five countries in Asia.',
        tenseLabel: 'Hiện tại hoàn thành',
      ),
      WritingSentence(
        id: 'travel_4',
        vi: 'Cô ấy đã chuẩn bị hành lý suốt cả tuần nay.',
        en: 'She has been packing her luggage all week.',
        tenseLabel: 'Hiện tại hoàn thành tiếp diễn',
      ),
      WritingSentence(
        id: 'travel_5',
        vi: 'Chúng tôi bay đến Bangkok vào tháng trước.',
        en: 'We flew to Bangkok last month.',
        tenseLabel: 'Quá khứ đơn',
      ),
      WritingSentence(
        id: 'travel_6',
        vi: 'Khi máy bay hạ cánh, trời đang mưa to.',
        en: 'When the plane landed, it was raining heavily.',
        tenseLabel: 'Quá khứ tiếp diễn',
      ),
    ],
  ),
  WritingParagraph(
    id: 'health',
    titleVi: 'Sức khỏe',
    titleEn: 'Health',
    sentences: [
      WritingSentence(
        id: 'health_1',
        vi: 'Trước khi đi khám, anh ấy đã uống thuốc giảm đau.',
        en: 'Before seeing the doctor, he had taken a painkiller.',
        tenseLabel: 'Quá khứ hoàn thành',
      ),
      WritingSentence(
        id: 'health_2',
        vi: 'Cô ấy đã tập yoga được hai năm trước khi bị chấn thương.',
        en: 'She had been practicing yoga for two years before she got injured.',
        tenseLabel: 'Quá khứ hoàn thành tiếp diễn',
      ),
      WritingSentence(
        id: 'health_3',
        vi: 'Tôi sẽ đi khám sức khỏe định kỳ vào tuần sau.',
        en: 'I will have a regular check-up next week.',
        tenseLabel: 'Tương lai đơn',
      ),
      WritingSentence(
        id: 'health_4',
        vi: 'Bác sĩ sắp kê đơn thuốc mới cho tôi.',
        en: 'The doctor is going to prescribe new medicine for me.',
        tenseLabel: 'Tương lai gần (going to)',
      ),
      WritingSentence(
        id: 'health_5',
        vi: 'Vào giờ này ngày mai, tôi sẽ đang chạy bộ trong công viên.',
        en: 'At this time tomorrow, I will be jogging in the park.',
        tenseLabel: 'Tương lai tiếp diễn',
      ),
      WritingSentence(
        id: 'health_6',
        vi: 'Đến năm sau, tôi sẽ giảm được năm cân.',
        en: 'By next year, I will have lost five kilograms.',
        tenseLabel: 'Tương lai hoàn thành',
      ),
    ],
  ),
  WritingParagraph(
    id: 'weather',
    titleVi: 'Thời tiết',
    titleEn: 'Weather',
    sentences: [
      WritingSentence(
        id: 'weather_1',
        vi: 'Mùa hè ở Việt Nam thường rất nóng.',
        en: 'Summer in Vietnam is usually very hot.',
        tenseLabel: 'Hiện tại đơn',
      ),
      WritingSentence(
        id: 'weather_2',
        vi: 'Trời đang mưa rất to bên ngoài.',
        en: 'It is raining heavily outside.',
        tenseLabel: 'Hiện tại tiếp diễn',
      ),
      WritingSentence(
        id: 'weather_3',
        vi: 'Nhiệt độ đã tăng lên đáng kể trong tuần này.',
        en: 'The temperature has risen significantly this week.',
        tenseLabel: 'Hiện tại hoàn thành',
      ),
      WritingSentence(
        id: 'weather_4',
        vi: 'Trời đã nắng liên tục suốt cả tháng nay.',
        en: 'It has been sunny continuously all month.',
        tenseLabel: 'Hiện tại hoàn thành tiếp diễn',
      ),
      WritingSentence(
        id: 'weather_5',
        vi: 'Hôm qua có một cơn bão lớn đổ bộ vào miền Trung.',
        en: 'Yesterday, a big storm hit the central region.',
        tenseLabel: 'Quá khứ đơn',
      ),
      WritingSentence(
        id: 'weather_6',
        vi: 'Lúc chúng tôi ra ngoài, gió đang thổi rất mạnh.',
        en: 'When we went outside, the wind was blowing very strongly.',
        tenseLabel: 'Quá khứ tiếp diễn',
      ),
    ],
  ),
  WritingParagraph(
    id: 'technology',
    titleVi: 'Công nghệ',
    titleEn: 'Technology',
    sentences: [
      WritingSentence(
        id: 'technology_1',
        vi: 'Trước khi điện thoại thông minh xuất hiện, mọi người đã dùng điện thoại bàn.',
        en: 'Before smartphones appeared, people had used landline phones.',
        tenseLabel: 'Quá khứ hoàn thành',
      ),
      WritingSentence(
        id: 'technology_2',
        vi: 'Các kỹ sư đã phát triển ứng dụng này suốt một năm trước khi ra mắt.',
        en: 'The engineers had been developing this app for a year before the launch.',
        tenseLabel: 'Quá khứ hoàn thành tiếp diễn',
      ),
      WritingSentence(
        id: 'technology_3',
        vi: 'Trí tuệ nhân tạo sẽ thay đổi cách chúng ta làm việc.',
        en: 'Artificial intelligence will change the way we work.',
        tenseLabel: 'Tương lai đơn',
      ),
      WritingSentence(
        id: 'technology_4',
        vi: 'Công ty sắp phát hành một chiếc điện thoại mới.',
        en: 'The company is going to release a new phone.',
        tenseLabel: 'Tương lai gần (going to)',
      ),
      WritingSentence(
        id: 'technology_5',
        vi: 'Vào năm sau, robot sẽ đang thực hiện nhiều công việc nhà máy.',
        en: 'Next year, robots will be doing many factory jobs.',
        tenseLabel: 'Tương lai tiếp diễn',
      ),
      WritingSentence(
        id: 'technology_6',
        vi: 'Đến năm 2030, công nghệ sẽ thay đổi hoàn toàn cuộc sống của chúng ta.',
        en: 'By 2030, technology will have completely changed our lives.',
        tenseLabel: 'Tương lai hoàn thành',
      ),
    ],
  ),
  WritingParagraph(
    id: 'hobbies',
    titleVi: 'Sở thích',
    titleEn: 'Hobbies',
    sentences: [
      WritingSentence(
        id: 'hobbies_1',
        vi: 'Tôi thích đọc sách vào buổi tối.',
        en: 'I like reading books in the evening.',
        tenseLabel: 'Hiện tại đơn',
      ),
      WritingSentence(
        id: 'hobbies_2',
        vi: 'Em gái tôi đang học chơi đàn guitar.',
        en: 'My sister is learning to play the guitar.',
        tenseLabel: 'Hiện tại tiếp diễn',
      ),
      WritingSentence(
        id: 'hobbies_3',
        vi: 'Tôi đã sưu tầm tem trong nhiều năm.',
        en: 'I have collected stamps for many years.',
        tenseLabel: 'Hiện tại hoàn thành',
      ),
      WritingSentence(
        id: 'hobbies_4',
        vi: 'Anh ấy đã vẽ tranh suốt cả buổi chiều nay.',
        en: 'He has been painting all afternoon.',
        tenseLabel: 'Hiện tại hoàn thành tiếp diễn',
      ),
      WritingSentence(
        id: 'hobbies_5',
        vi: 'Tuần trước, tôi tham gia một lớp học nấu ăn.',
        en: 'Last week, I joined a cooking class.',
        tenseLabel: 'Quá khứ đơn',
      ),
      WritingSentence(
        id: 'hobbies_6',
        vi: 'Lúc bạn gọi điện, tôi đang chơi cờ vua với bố.',
        en: 'When you called, I was playing chess with my father.',
        tenseLabel: 'Quá khứ tiếp diễn',
      ),
    ],
  ),
  WritingParagraph(
    id: 'environment',
    titleVi: 'Môi trường',
    titleEn: 'Environment',
    sentences: [
      WritingSentence(
        id: 'environment_1',
        vi: 'Trước khi luật mới được ban hành, nhà máy đã xả thải trực tiếp ra sông.',
        en: 'Before the new law was passed, the factory had discharged waste directly into the river.',
        tenseLabel: 'Quá khứ hoàn thành',
      ),
      WritingSentence(
        id: 'environment_2',
        vi: 'Người dân đã phản đối kế hoạch này suốt nhiều tháng trước khi nó bị hủy bỏ.',
        en: 'Residents had been protesting the plan for months before it was cancelled.',
        tenseLabel: 'Quá khứ hoàn thành tiếp diễn',
      ),
      WritingSentence(
        id: 'environment_3',
        vi: 'Chúng ta sẽ trồng thêm cây xanh trong công viên này.',
        en: 'We will plant more trees in this park.',
        tenseLabel: 'Tương lai đơn',
      ),
      WritingSentence(
        id: 'environment_4',
        vi: 'Chính phủ sắp ban hành chính sách bảo vệ môi trường mới.',
        en: 'The government is going to introduce a new environmental policy.',
        tenseLabel: 'Tương lai gần (going to)',
      ),
      WritingSentence(
        id: 'environment_5',
        vi: 'Vào tuần tới, tình nguyện viên sẽ đang dọn rác trên bãi biển.',
        en: 'Next week, volunteers will be cleaning up the beach.',
        tenseLabel: 'Tương lai tiếp diễn',
      ),
      WritingSentence(
        id: 'environment_6',
        vi: 'Đến năm 2050, con người sẽ giảm được một nửa lượng khí thải.',
        en: 'By 2050, people will have reduced emissions by half.',
        tenseLabel: 'Tương lai hoàn thành',
      ),
    ],
  ),
  WritingParagraph(
    id: 'education',
    titleVi: 'Giáo dục',
    titleEn: 'Education',
    sentences: [
      WritingSentence(
        id: 'education_1',
        vi: 'Tôi học tại một trường đại học ở Hà Nội.',
        en: 'I study at a university in Hanoi.',
        tenseLabel: 'Hiện tại đơn',
      ),
      WritingSentence(
        id: 'education_2',
        vi: 'Cô giáo đang giảng bài về lịch sử thế giới.',
        en: 'The teacher is explaining a lesson about world history.',
        tenseLabel: 'Hiện tại tiếp diễn',
      ),
      WritingSentence(
        id: 'education_3',
        vi: 'Tôi đã học tiếng Anh được năm năm rồi.',
        en: 'I have learned English for five years.',
        tenseLabel: 'Hiện tại hoàn thành',
      ),
      WritingSentence(
        id: 'education_4',
        vi: 'Sinh viên đã ôn thi suốt cả tuần nay.',
        en: 'The students have been reviewing for the exam all week.',
        tenseLabel: 'Hiện tại hoàn thành tiếp diễn',
      ),
      WritingSentence(
        id: 'education_5',
        vi: 'Năm ngoái, tôi tốt nghiệp trung học phổ thông.',
        en: 'Last year, I graduated from high school.',
        tenseLabel: 'Quá khứ đơn',
      ),
      WritingSentence(
        id: 'education_6',
        vi: 'Khi giáo viên bước vào lớp, học sinh đang làm bài tập.',
        en: 'When the teacher entered the classroom, the students were doing their exercises.',
        tenseLabel: 'Quá khứ tiếp diễn',
      ),
    ],
  ),
  WritingParagraph(
    id: 'food',
    titleVi: 'Ẩm thực',
    titleEn: 'Food',
    sentences: [
      WritingSentence(
        id: 'food_1',
        vi: 'Trước khi khách đến, đầu bếp đã chuẩn bị xong món tráng miệng.',
        en: 'Before the guests arrived, the chef had prepared the dessert.',
        tenseLabel: 'Quá khứ hoàn thành',
      ),
      WritingSentence(
        id: 'food_2',
        vi: 'Cô ấy đã nấu ăn suốt ba giờ trước khi khách đến.',
        en: 'She had been cooking for three hours before the guests arrived.',
        tenseLabel: 'Quá khứ hoàn thành tiếp diễn',
      ),
      WritingSentence(
        id: 'food_3',
        vi: 'Tôi sẽ thử món phở mới ở nhà hàng đó.',
        en: 'I will try the new pho dish at that restaurant.',
        tenseLabel: 'Tương lai đơn',
      ),
      WritingSentence(
        id: 'food_4',
        vi: 'Chúng tôi sắp mở một quán cà phê nhỏ.',
        en: 'We are going to open a small coffee shop.',
        tenseLabel: 'Tương lai gần (going to)',
      ),
      WritingSentence(
        id: 'food_5',
        vi: 'Vào giờ này tối mai, tôi sẽ đang nấu bữa tối cho gia đình.',
        en: 'At this time tomorrow evening, I will be cooking dinner for my family.',
        tenseLabel: 'Tương lai tiếp diễn',
      ),
      WritingSentence(
        id: 'food_6',
        vi: 'Đến cuối tuần này, tôi sẽ hoàn thành công thức món bánh mới.',
        en: 'By the end of this week, I will have finished the new cake recipe.',
        tenseLabel: 'Tương lai hoàn thành',
      ),
    ],
  ),
  WritingParagraph(
    id: 'sports',
    titleVi: 'Thể thao',
    titleEn: 'Sports',
    sentences: [
      WritingSentence(
        id: 'sports_1',
        vi: 'Tôi chơi bóng đá vào mỗi cuối tuần.',
        en: 'I play football every weekend.',
        tenseLabel: 'Hiện tại đơn',
      ),
      WritingSentence(
        id: 'sports_2',
        vi: 'Đội tuyển đang tập luyện cho giải đấu sắp tới.',
        en: 'The team is training for the upcoming tournament.',
        tenseLabel: 'Hiện tại tiếp diễn',
      ),
      WritingSentence(
        id: 'sports_3',
        vi: 'Tôi đã tham gia câu lạc bộ bơi lội được hai năm.',
        en: 'I have joined the swimming club for two years.',
        tenseLabel: 'Hiện tại hoàn thành',
      ),
      WritingSentence(
        id: 'sports_4',
        vi: 'Anh ấy đã chạy bộ suốt cả buổi sáng nay.',
        en: 'He has been running all morning.',
        tenseLabel: 'Hiện tại hoàn thành tiếp diễn',
      ),
      WritingSentence(
        id: 'sports_5',
        vi: 'Đội của tôi thắng trận đấu cuối tuần trước.',
        en: 'My team won the match last weekend.',
        tenseLabel: 'Quá khứ đơn',
      ),
      WritingSentence(
        id: 'sports_6',
        vi: 'Khi trọng tài thổi còi, các cầu thủ đang khởi động.',
        en: 'When the referee blew the whistle, the players were warming up.',
        tenseLabel: 'Quá khứ tiếp diễn',
      ),
    ],
  ),
  WritingParagraph(
    id: 'shopping',
    titleVi: 'Mua sắm',
    titleEn: 'Shopping',
    sentences: [
      WritingSentence(
        id: 'shopping_1',
        vi: 'Trước khi tôi đến cửa hàng, chiếc áo đó đã hết size.',
        en: 'Before I got to the shop, that shirt had sold out in my size.',
        tenseLabel: 'Quá khứ hoàn thành',
      ),
      WritingSentence(
        id: 'shopping_2',
        vi: 'Cô ấy đã tìm kiếm chiếc váy đó suốt nhiều tuần trước khi tìm thấy nó.',
        en: 'She had been searching for that dress for weeks before she found it.',
        tenseLabel: 'Quá khứ hoàn thành tiếp diễn',
      ),
      WritingSentence(
        id: 'shopping_3',
        vi: 'Tôi sẽ mua một chiếc máy tính mới vào tháng sau.',
        en: 'I will buy a new computer next month.',
        tenseLabel: 'Tương lai đơn',
      ),
      WritingSentence(
        id: 'shopping_4',
        vi: 'Siêu thị sắp giảm giá lớn vào cuối tuần.',
        en: 'The supermarket is going to have a big sale this weekend.',
        tenseLabel: 'Tương lai gần (going to)',
      ),
      WritingSentence(
        id: 'shopping_5',
        vi: 'Vào lúc này chiều mai, tôi sẽ đang mua sắm ở trung tâm thương mại.',
        en: 'At this time tomorrow afternoon, I will be shopping at the mall.',
        tenseLabel: 'Tương lai tiếp diễn',
      ),
      WritingSentence(
        id: 'shopping_6',
        vi: 'Đến sinh nhật con gái, tôi sẽ mua xong hết quà tặng.',
        en: "By my daughter's birthday, I will have bought all the presents.",
        tenseLabel: 'Tương lai hoàn thành',
      ),
    ],
  ),
  WritingParagraph(
    id: 'traffic',
    titleVi: 'Giao thông',
    titleEn: 'Traffic',
    sentences: [
      WritingSentence(
        id: 'traffic_1',
        vi: 'Giao thông ở thành phố này rất đông đúc vào giờ cao điểm.',
        en: 'Traffic in this city is very heavy during rush hour.',
        tenseLabel: 'Hiện tại đơn',
      ),
      WritingSentence(
        id: 'traffic_2',
        vi: 'Xe cộ đang di chuyển rất chậm trên đường này.',
        en: 'The traffic is moving very slowly on this road.',
        tenseLabel: 'Hiện tại tiếp diễn',
      ),
      WritingSentence(
        id: 'traffic_3',
        vi: 'Thành phố đã xây thêm ba cây cầu mới trong năm nay.',
        en: 'The city has built three new bridges this year.',
        tenseLabel: 'Hiện tại hoàn thành',
      ),
      WritingSentence(
        id: 'traffic_4',
        vi: 'Công nhân đã sửa chữa con đường này suốt hai tháng nay.',
        en: 'Workers have been repairing this road for two months.',
        tenseLabel: 'Hiện tại hoàn thành tiếp diễn',
      ),
      WritingSentence(
        id: 'traffic_5',
        vi: 'Hôm qua tôi bị kẹt xe gần hai tiếng đồng hồ.',
        en: 'Yesterday I got stuck in traffic for nearly two hours.',
        tenseLabel: 'Quá khứ đơn',
      ),
      WritingSentence(
        id: 'traffic_6',
        vi: 'Khi tai nạn xảy ra, tôi đang lái xe về nhà.',
        en: 'When the accident happened, I was driving home.',
        tenseLabel: 'Quá khứ tiếp diễn',
      ),
    ],
  ),
  WritingParagraph(
    id: 'finance',
    titleVi: 'Tài chính',
    titleEn: 'Finance',
    sentences: [
      WritingSentence(
        id: 'finance_1',
        vi: 'Trước khi thị trường sụp đổ, anh ấy đã bán hết cổ phiếu.',
        en: 'Before the market crashed, he had sold all his shares.',
        tenseLabel: 'Quá khứ hoàn thành',
      ),
      WritingSentence(
        id: 'finance_2',
        vi: 'Cô ấy đã tiết kiệm tiền suốt nhiều năm trước khi mua nhà.',
        en: 'She had been saving money for many years before she bought a house.',
        tenseLabel: 'Quá khứ hoàn thành tiếp diễn',
      ),
      WritingSentence(
        id: 'finance_3',
        vi: 'Tôi sẽ mở một tài khoản tiết kiệm mới.',
        en: 'I will open a new savings account.',
        tenseLabel: 'Tương lai đơn',
      ),
      WritingSentence(
        id: 'finance_4',
        vi: 'Ngân hàng sắp ra mắt một dịch vụ cho vay mới.',
        en: 'The bank is going to launch a new loan service.',
        tenseLabel: 'Tương lai gần (going to)',
      ),
      WritingSentence(
        id: 'finance_5',
        vi: 'Vào thời điểm này năm sau, tôi sẽ đang đầu tư vào bất động sản.',
        en: 'At this time next year, I will be investing in real estate.',
        tenseLabel: 'Tương lai tiếp diễn',
      ),
      WritingSentence(
        id: 'finance_6',
        vi: 'Đến khi nghỉ hưu, tôi sẽ tiết kiệm đủ tiền để mua nhà.',
        en: 'By the time I retire, I will have saved enough money to buy a house.',
        tenseLabel: 'Tương lai hoàn thành',
      ),
    ],
  ),
  WritingParagraph(
    id: 'music',
    titleVi: 'Âm nhạc',
    titleEn: 'Music',
    sentences: [
      WritingSentence(
        id: 'music_1',
        vi: 'Tôi nghe nhạc mỗi khi đi làm.',
        en: 'I listen to music every time I go to work.',
        tenseLabel: 'Hiện tại đơn',
      ),
      WritingSentence(
        id: 'music_2',
        vi: 'Ban nhạc đang biểu diễn trên sân khấu.',
        en: 'The band is performing on stage.',
        tenseLabel: 'Hiện tại tiếp diễn',
      ),
      WritingSentence(
        id: 'music_3',
        vi: 'Tôi đã học chơi piano được một năm.',
        en: 'I have learned to play the piano for one year.',
        tenseLabel: 'Hiện tại hoàn thành',
      ),
      WritingSentence(
        id: 'music_4',
        vi: 'Cô ấy đã luyện thanh nhạc suốt cả buổi tối nay.',
        en: 'She has been practicing singing all evening.',
        tenseLabel: 'Hiện tại hoàn thành tiếp diễn',
      ),
      WritingSentence(
        id: 'music_5',
        vi: 'Tôi đi xem một buổi hòa nhạc tuần trước.',
        en: 'I went to a concert last week.',
        tenseLabel: 'Quá khứ đơn',
      ),
      WritingSentence(
        id: 'music_6',
        vi: 'Khi tôi bước vào phòng, anh ấy đang chơi guitar.',
        en: 'When I walked into the room, he was playing the guitar.',
        tenseLabel: 'Quá khứ tiếp diễn',
      ),
    ],
  ),
  WritingParagraph(
    id: 'movies',
    titleVi: 'Điện ảnh',
    titleEn: 'Movies',
    sentences: [
      WritingSentence(
        id: 'movies_1',
        vi: 'Trước khi bộ phim bắt đầu, chúng tôi đã mua bỏng ngô.',
        en: 'Before the movie started, we had bought some popcorn.',
        tenseLabel: 'Quá khứ hoàn thành',
      ),
      WritingSentence(
        id: 'movies_2',
        vi: 'Đạo diễn đã quay bộ phim này suốt hai năm trước khi phát hành.',
        en: 'The director had been filming this movie for two years before its release.',
        tenseLabel: 'Quá khứ hoàn thành tiếp diễn',
      ),
      WritingSentence(
        id: 'movies_3',
        vi: 'Tôi sẽ xem bộ phim mới vào cuối tuần này.',
        en: 'I will watch the new movie this weekend.',
        tenseLabel: 'Tương lai đơn',
      ),
      WritingSentence(
        id: 'movies_4',
        vi: 'Rạp chiếu phim sắp công chiếu một bộ phim hành động.',
        en: 'The cinema is going to premiere an action movie.',
        tenseLabel: 'Tương lai gần (going to)',
      ),
      WritingSentence(
        id: 'movies_5',
        vi: 'Vào giờ này tối mai, tôi sẽ đang xem phim ở rạp.',
        en: 'At this time tomorrow evening, I will be watching a movie at the cinema.',
        tenseLabel: 'Tương lai tiếp diễn',
      ),
      WritingSentence(
        id: 'movies_6',
        vi: 'Đến cuối năm, đạo diễn sẽ hoàn thành xong bộ phim mới.',
        en: 'By the end of the year, the director will have finished the new film.',
        tenseLabel: 'Tương lai hoàn thành',
      ),
    ],
  ),
  WritingParagraph(
    id: 'pets',
    titleVi: 'Thú cưng',
    titleEn: 'Pets',
    sentences: [
      WritingSentence(
        id: 'pets_1',
        vi: 'Tôi nuôi một chú chó nhỏ ở nhà.',
        en: 'I keep a small dog at home.',
        tenseLabel: 'Hiện tại đơn',
      ),
      WritingSentence(
        id: 'pets_2',
        vi: 'Con mèo của tôi đang ngủ trên ghế sofa.',
        en: 'My cat is sleeping on the sofa.',
        tenseLabel: 'Hiện tại tiếp diễn',
      ),
      WritingSentence(
        id: 'pets_3',
        vi: 'Tôi đã nuôi chú chó này được ba năm.',
        en: 'I have had this dog for three years.',
        tenseLabel: 'Hiện tại hoàn thành',
      ),
      WritingSentence(
        id: 'pets_4',
        vi: 'Nó đã sủa liên tục suốt cả buổi sáng nay.',
        en: 'It has been barking continuously all morning.',
        tenseLabel: 'Hiện tại hoàn thành tiếp diễn',
      ),
      WritingSentence(
        id: 'pets_5',
        vi: 'Tuần trước, tôi đưa mèo đi khám bác sĩ thú y.',
        en: 'Last week, I took my cat to the vet.',
        tenseLabel: 'Quá khứ đơn',
      ),
      WritingSentence(
        id: 'pets_6',
        vi: 'Khi tôi về nhà, con chó đang chờ ở cửa.',
        en: 'When I got home, the dog was waiting at the door.',
        tenseLabel: 'Quá khứ tiếp diễn',
      ),
    ],
  ),
  WritingParagraph(
    id: 'friendship',
    titleVi: 'Tình bạn',
    titleEn: 'Friendship',
    sentences: [
      WritingSentence(
        id: 'friendship_1',
        vi: 'Trước khi tôi chuyển nhà, chúng tôi đã trở thành bạn thân.',
        en: 'Before I moved house, we had become close friends.',
        tenseLabel: 'Quá khứ hoàn thành',
      ),
      WritingSentence(
        id: 'friendship_2',
        vi: 'Chúng tôi đã trò chuyện suốt hàng giờ trước khi chia tay.',
        en: 'We had been chatting for hours before we said goodbye.',
        tenseLabel: 'Quá khứ hoàn thành tiếp diễn',
      ),
      WritingSentence(
        id: 'friendship_3',
        vi: 'Tôi sẽ gặp lại bạn cũ vào tuần sau.',
        en: 'I will meet my old friend again next week.',
        tenseLabel: 'Tương lai đơn',
      ),
      WritingSentence(
        id: 'friendship_4',
        vi: 'Chúng tôi sắp tổ chức một buổi họp mặt bạn bè.',
        en: "We are going to organize a friends' reunion.",
        tenseLabel: 'Tương lai gần (going to)',
      ),
      WritingSentence(
        id: 'friendship_5',
        vi: 'Vào giờ này chủ nhật tới, tôi sẽ đang trò chuyện với bạn bè.',
        en: 'At this time next Sunday, I will be chatting with my friends.',
        tenseLabel: 'Tương lai tiếp diễn',
      ),
      WritingSentence(
        id: 'friendship_6',
        vi: 'Đến cuối tháng, chúng tôi sẽ hoàn thành kế hoạch chuyến đi cùng nhau.',
        en: 'By the end of the month, we will have finished planning the trip together.',
        tenseLabel: 'Tương lai hoàn thành',
      ),
    ],
  ),
  WritingParagraph(
    id: 'internet',
    titleVi: 'Internet',
    titleEn: 'Internet',
    sentences: [
      WritingSentence(
        id: 'internet_1',
        vi: 'Tôi sử dụng Internet mỗi ngày để làm việc.',
        en: 'I use the Internet every day for work.',
        tenseLabel: 'Hiện tại đơn',
      ),
      WritingSentence(
        id: 'internet_2',
        vi: 'Anh ấy đang tải một bộ phim từ mạng.',
        en: 'He is downloading a movie from the Internet.',
        tenseLabel: 'Hiện tại tiếp diễn',
      ),
      WritingSentence(
        id: 'internet_3',
        vi: 'Tôi đã tạo tài khoản mạng xã hội này được sáu năm.',
        en: 'I have had this social media account for six years.',
        tenseLabel: 'Hiện tại hoàn thành',
      ),
      WritingSentence(
        id: 'internet_4',
        vi: 'Cô ấy đã lướt mạng suốt cả buổi tối nay.',
        en: 'She has been browsing the Internet all evening.',
        tenseLabel: 'Hiện tại hoàn thành tiếp diễn',
      ),
      WritingSentence(
        id: 'internet_5',
        vi: 'Hôm qua mạng Internet bị gián đoạn trong hai giờ.',
        en: 'Yesterday the Internet was down for two hours.',
        tenseLabel: 'Quá khứ đơn',
      ),
      WritingSentence(
        id: 'internet_6',
        vi: 'Khi mất điện, tôi đang xem video trực tuyến.',
        en: 'When the power went out, I was watching an online video.',
        tenseLabel: 'Quá khứ tiếp diễn',
      ),
    ],
  ),
  WritingParagraph(
    id: 'city',
    titleVi: 'Thành phố',
    titleEn: 'City',
    sentences: [
      WritingSentence(
        id: 'city_1',
        vi: 'Trước khi tòa nhà này được xây, đây từng là một cánh đồng.',
        en: 'Before this building was built, this had been a field.',
        tenseLabel: 'Quá khứ hoàn thành',
      ),
      WritingSentence(
        id: 'city_2',
        vi: 'Thành phố đã phát triển nhanh chóng suốt mười năm trước khi trở nên đông đúc.',
        en: 'The city had been developing rapidly for ten years before it became crowded.',
        tenseLabel: 'Quá khứ hoàn thành tiếp diễn',
      ),
      WritingSentence(
        id: 'city_3',
        vi: 'Thành phố sẽ xây thêm một công viên mới.',
        en: 'The city will build a new park.',
        tenseLabel: 'Tương lai đơn',
      ),
      WritingSentence(
        id: 'city_4',
        vi: 'Chính quyền sắp khánh thành một tuyến tàu điện ngầm.',
        en: 'The government is going to open a new subway line.',
        tenseLabel: 'Tương lai gần (going to)',
      ),
      WritingSentence(
        id: 'city_5',
        vi: 'Vào năm tới lúc này, thành phố sẽ đang tổ chức lễ hội ánh sáng.',
        en: 'At this time next year, the city will be holding a light festival.',
        tenseLabel: 'Tương lai tiếp diễn',
      ),
      WritingSentence(
        id: 'city_6',
        vi: 'Đến năm 2035, thành phố sẽ hoàn thành xong hệ thống giao thông công cộng.',
        en: 'By 2035, the city will have completed its public transport system.',
        tenseLabel: 'Tương lai hoàn thành',
      ),
    ],
  ),
  WritingParagraph(
    id: 'countryside',
    titleVi: 'Nông thôn',
    titleEn: 'Countryside',
    sentences: [
      WritingSentence(
        id: 'countryside_1',
        vi: 'Ông bà tôi sống ở một ngôi làng nhỏ.',
        en: 'My grandparents live in a small village.',
        tenseLabel: 'Hiện tại đơn',
      ),
      WritingSentence(
        id: 'countryside_2',
        vi: 'Nông dân đang thu hoạch lúa ngoài đồng.',
        en: 'The farmers are harvesting rice in the field.',
        tenseLabel: 'Hiện tại tiếp diễn',
      ),
      WritingSentence(
        id: 'countryside_3',
        vi: 'Tôi đã về thăm quê được ba lần trong năm nay.',
        en: 'I have visited my hometown three times this year.',
        tenseLabel: 'Hiện tại hoàn thành',
      ),
      WritingSentence(
        id: 'countryside_4',
        vi: 'Bác tôi đã trồng rau suốt cả mùa xuân nay.',
        en: 'My uncle has been growing vegetables all this spring.',
        tenseLabel: 'Hiện tại hoàn thành tiếp diễn',
      ),
      WritingSentence(
        id: 'countryside_5',
        vi: 'Mùa hè năm ngoái, tôi ở quê một tháng.',
        en: 'Last summer, I stayed in the countryside for a month.',
        tenseLabel: 'Quá khứ đơn',
      ),
      WritingSentence(
        id: 'countryside_6',
        vi: 'Khi mặt trời lặn, đàn trâu đang trở về chuồng.',
        en: 'When the sun set, the buffalo were returning to the barn.',
        tenseLabel: 'Quá khứ tiếp diễn',
      ),
    ],
  ),
  WritingParagraph(
    id: 'festival',
    titleVi: 'Lễ hội',
    titleEn: 'Festival',
    sentences: [
      WritingSentence(
        id: 'festival_1',
        vi: 'Trước khi lễ hội bắt đầu, dân làng đã trang trí xong đường phố.',
        en: 'Before the festival started, the villagers had decorated the streets.',
        tenseLabel: 'Quá khứ hoàn thành',
      ),
      WritingSentence(
        id: 'festival_2',
        vi: 'Họ đã chuẩn bị cho lễ hội suốt cả tháng trước khi nó diễn ra.',
        en: 'They had been preparing for the festival for a month before it took place.',
        tenseLabel: 'Quá khứ hoàn thành tiếp diễn',
      ),
      WritingSentence(
        id: 'festival_3',
        vi: 'Chúng tôi sẽ tham gia lễ hội pháo hoa vào cuối năm.',
        en: 'We will attend the fireworks festival at the end of the year.',
        tenseLabel: 'Tương lai đơn',
      ),
      WritingSentence(
        id: 'festival_4',
        vi: 'Thị trấn sắp tổ chức một lễ hội ẩm thực đường phố.',
        en: 'The town is going to hold a street food festival.',
        tenseLabel: 'Tương lai gần (going to)',
      ),
      WritingSentence(
        id: 'festival_5',
        vi: 'Vào giờ này tối thứ Bảy, chúng tôi sẽ đang xem pháo hoa.',
        en: 'At this time on Saturday evening, we will be watching fireworks.',
        tenseLabel: 'Tương lai tiếp diễn',
      ),
      WritingSentence(
        id: 'festival_6',
        vi: 'Đến khi lễ hội kết thúc, hàng nghìn người sẽ đã ghé thăm.',
        en: 'By the time the festival ends, thousands of people will have visited.',
        tenseLabel: 'Tương lai hoàn thành',
      ),
    ],
  ),
  WritingParagraph(
    id: 'books',
    titleVi: 'Sách báo',
    titleEn: 'Books',
    sentences: [
      WritingSentence(
        id: 'books_1',
        vi: 'Tôi đọc báo mỗi sáng trước khi đi làm.',
        en: 'I read the newspaper every morning before work.',
        tenseLabel: 'Hiện tại đơn',
      ),
      WritingSentence(
        id: 'books_2',
        vi: 'Cô ấy đang viết một cuốn tiểu thuyết mới.',
        en: 'She is writing a new novel.',
        tenseLabel: 'Hiện tại tiếp diễn',
      ),
      WritingSentence(
        id: 'books_3',
        vi: 'Tôi đã đọc hơn năm mươi cuốn sách trong năm nay.',
        en: 'I have read more than fifty books this year.',
        tenseLabel: 'Hiện tại hoàn thành',
      ),
      WritingSentence(
        id: 'books_4',
        vi: 'Anh ấy đã nghiên cứu chủ đề này suốt nhiều tháng nay.',
        en: 'He has been researching this topic for months.',
        tenseLabel: 'Hiện tại hoàn thành tiếp diễn',
      ),
      WritingSentence(
        id: 'books_5',
        vi: 'Tôi mua ba cuốn sách mới ở hội chợ sách tuần trước.',
        en: 'I bought three new books at the book fair last week.',
        tenseLabel: 'Quá khứ đơn',
      ),
      WritingSentence(
        id: 'books_6',
        vi: 'Khi tôi gọi, cô ấy đang đọc sách trong thư viện.',
        en: 'When I called, she was reading a book in the library.',
        tenseLabel: 'Quá khứ tiếp diễn',
      ),
    ],
  ),
  WritingParagraph(
    id: 'science',
    titleVi: 'Khoa học',
    titleEn: 'Science',
    sentences: [
      WritingSentence(
        id: 'science_1',
        vi: 'Trước khi công bố kết quả, các nhà khoa học đã kiểm tra dữ liệu nhiều lần.',
        en: 'Before announcing the results, the scientists had checked the data many times.',
        tenseLabel: 'Quá khứ hoàn thành',
      ),
      WritingSentence(
        id: 'science_2',
        vi: 'Nhóm nghiên cứu đã thử nghiệm loại vắc-xin này suốt ba năm trước khi thành công.',
        en: 'The research team had been testing this vaccine for three years before they succeeded.',
        tenseLabel: 'Quá khứ hoàn thành tiếp diễn',
      ),
      WritingSentence(
        id: 'science_3',
        vi: 'Các nhà khoa học sẽ công bố phát hiện mới vào tháng sau.',
        en: 'Scientists will announce a new discovery next month.',
        tenseLabel: 'Tương lai đơn',
      ),
      WritingSentence(
        id: 'science_4',
        vi: 'Trường đại học sắp khai trương một phòng thí nghiệm hiện đại.',
        en: 'The university is going to open a modern laboratory.',
        tenseLabel: 'Tương lai gần (going to)',
      ),
      WritingSentence(
        id: 'science_5',
        vi: 'Vào thời điểm này năm sau, họ sẽ đang thử nghiệm loại thuốc mới.',
        en: 'At this time next year, they will be testing the new drug.',
        tenseLabel: 'Tương lai tiếp diễn',
      ),
      WritingSentence(
        id: 'science_6',
        vi: 'Đến năm 2040, các nhà khoa học sẽ tìm ra cách chữa nhiều căn bệnh hiện nay.',
        en: 'By 2040, scientists will have found cures for many current diseases.',
        tenseLabel: 'Tương lai hoàn thành',
      ),
    ],
  ),
];

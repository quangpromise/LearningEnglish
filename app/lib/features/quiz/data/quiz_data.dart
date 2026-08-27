/// Dữ liệu câu đố lấy từ kho đố vui tiếng Anh tham khảo tại
/// vn.elsaspeak.com/do-vui-tieng-anh (nội dung tĩnh, không có sẵn hệ thống
/// điểm/xếp hạng — phần game hoá bên dưới do app này tự thiết kế thêm).
class Riddle {
  const Riddle({
    required this.category,
    required this.en,
    required this.vi,
    required this.answer,
    required this.distractors,
  });
  final String category;
  final String en;
  final String vi;
  final String answer;
  final List<String> distractors;
}

const kCategories = [
  'Chơi chữ',
  'Suy luận',
  'Động vật',
  'Cuộc sống',
  'Bảng chữ cái',
  'Trái cây & xe cộ',
];

const kRiddles = [
  Riddle(
    category: 'Suy luận',
    en: 'What has an eye, but cannot see?',
    vi: 'Cái gì có mắt nhưng không nhìn được?',
    answer: 'A needle',
    distractors: ['A sponge', 'A bottle', 'A cat'],
  ),
  Riddle(
    category: 'Chơi chữ',
    en: 'Who always drives his customers away?',
    vi: 'Ai luôn "đuổi" khách hàng của mình đi?',
    answer: 'A taxi-driver',
    distractors: ['A waiter', 'A pilot', 'A teacher'],
  ),
  Riddle(
    category: 'Động vật',
    en: 'I have a long nose and love peanuts. What am I?',
    vi: 'Tôi có vòi dài và thích ăn lạc. Tôi là con gì?',
    answer: 'An elephant',
    distractors: ['A dog', 'A giraffe', 'A pig'],
  ),
  Riddle(
    category: 'Cuộc sống',
    en: 'What is full of holes but still holds water?',
    vi: 'Cái gì đầy lỗ nhưng vẫn giữ được nước?',
    answer: 'A sponge',
    distractors: ['A net', 'A basket', 'A cup'],
  ),
  Riddle(
    category: 'Động vật',
    en: "I say 'Meow' and love to chase mice. What am I?",
    vi: 'Tôi kêu "Meo meo" và thích rượt chuột. Tôi là con gì?',
    answer: 'A cat',
    distractors: ['A dog', 'A bird', 'A rabbit'],
  ),
  Riddle(
    category: 'Bảng chữ cái',
    en: 'I am a letter that sounds like a bee. What am I?',
    vi: 'Tôi là chữ cái phát âm giống con ong. Tôi là chữ gì?',
    answer: 'B',
    distractors: ['C', 'E', 'G'],
  ),
  Riddle(
    category: 'Trái cây & xe cộ',
    en: 'I am a green fruit that is big and has a black seed. What am I?',
    vi: 'Tôi là quả to màu xanh, có hạt đen. Tôi là quả gì?',
    answer: 'Watermelon',
    distractors: ['Apple', 'Grape', 'Mango'],
  ),
  Riddle(
    category: 'Trái cây & xe cộ',
    en: 'I am a vehicle that has two wheels and pedals. What am I?',
    vi: 'Tôi là phương tiện có hai bánh và bàn đạp. Tôi là gì?',
    answer: 'Bicycle',
    distractors: ['Car', 'Bus', 'Motorbike'],
  ),
  Riddle(
    category: 'Chơi chữ',
    en: 'What has a neck without a head?',
    vi: 'Cái gì có cổ nhưng không có đầu?',
    answer: 'A bottle',
    distractors: ['A shirt', 'A guitar', 'A snake'],
  ),
];

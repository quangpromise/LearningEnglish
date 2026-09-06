import 'package:flutter/material.dart';

import 'toeic_models.dart';

/// Du lieu 1 de thi thu TOEIC day du 7 phan (200 cau, dung ty le that:
/// Listening 6+25+39+30=100, Reading 30+16+54=100) - NOI DUNG TU VIET HOAN
/// TOAN MOI (chi tham khao dung format/do kho/cau truc cau hoi that qua 1
/// file PDF nguoi dung gui, KHONG copy nguyen van bat ky cau nao) de tranh
/// rui ro ban quyen (nhieu de thi thu TOEIC luu hanh lai tren mang trung voi
/// de thi thu chinh thuc cua ETS - xem CLAUDE.md nguyen tac ve ban quyen).
///
/// `kToeicTests` la List (so nhieu) tu dau du hien chi co 1 de - them de #2
/// sau nay chi la them 1 ToeicTest(...) moi vao list, khong doi code.
final List<ToeicTest> kToeicTests = [
  ToeicTest(
    id: 'toeic-test-1',
    titleVi: 'Đề thi thử TOEIC số 1',
    questions: [
      ..._part1Questions,
      ..._part2Questions,
      ..._part3Questions,
      ..._part4Questions,
      ..._part5Questions,
      ..._part6Questions,
      ..._part7Questions,
    ],
    audioScripts: {
      for (final s in [..._part3Scripts, ..._part4Scripts]) s.id: s,
    },
    passages: {
      for (final p in [..._part6Passages, ..._part7Passages]) p.id: p,
    },
  ),
];

// ============================================================================
// PART 1 - Photographs (6 cau). Moi cau: 1 "anh" minh hoa ve bang Icon +
// 4 phuong an mo ta duoc doc len (khong hien chu, giong thi that).
// ============================================================================

final _part1Questions = <ToeicQuestion>[
  ToeicQuestion(
    id: 'p1-q1',
    part: ToeicPartNumber.p1,
    illustration: ToeicIllustrationSpec(
      backgroundColor: const Color(0xFF2C5F8A),
      icons: const [
        ToeicSceneIcon(
          icon: Icons.laptop_mac_rounded,
          dx: 0.5,
          dy: 0.55,
          size: 64,
        ),
        ToeicSceneIcon(icon: Icons.person_rounded, dx: 0.22, dy: 0.4, size: 56),
        ToeicSceneIcon(
          icon: Icons.local_florist_rounded,
          dx: 0.82,
          dy: 0.3,
          size: 36,
        ),
      ],
    ),
    options: const [
      'She is typing on a laptop.',
      'She is talking on the phone.',
      'She is watering a plant.',
      'She is closing the laptop.',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: Bức ảnh mô tả một người phụ nữ ngồi trước máy tính xách tay. '
        '· Đáp án: A. She is typing on a laptop. '
        '· Giải thích: Hành động đúng với hình là đang gõ máy tính. Các lựa chọn '
        'khác nhắc tới điện thoại, tưới cây, hoặc đóng máy - đều không khớp với '
        'hành động trong ảnh. '
        '· Dịch: Cô ấy đang gõ trên máy tính xách tay.',
  ),
  ToeicQuestion(
    id: 'p1-q2',
    part: ToeicPartNumber.p1,
    illustration: ToeicIllustrationSpec(
      backgroundColor: const Color(0xFF3E7C59),
      icons: const [
        ToeicSceneIcon(icon: Icons.person_rounded, dx: 0.35, dy: 0.5, size: 56),
        ToeicSceneIcon(icon: Icons.person_rounded, dx: 0.62, dy: 0.5, size: 56),
        ToeicSceneIcon(
          icon: Icons.handshake_rounded,
          dx: 0.48,
          dy: 0.65,
          size: 40,
        ),
      ],
    ),
    options: const [
      'They are signing a document.',
      'They are shaking hands.',
      'They are drinking coffee.',
      'They are leaving the room.',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Hai người trong ảnh đang bắt tay nhau. '
        '· Đáp án: B. They are shaking hands. '
        '· Giải thích: Hình vẽ tay bắt tay là chi tiết trung tâm, các đáp án '
        'khác (ký giấy tờ, uống cà phê, rời phòng) không xuất hiện trong ảnh. '
        '· Dịch: Họ đang bắt tay nhau.',
  ),
  ToeicQuestion(
    id: 'p1-q3',
    part: ToeicPartNumber.p1,
    illustration: ToeicIllustrationSpec(
      backgroundColor: const Color(0xFF6B5B95),
      icons: const [
        ToeicSceneIcon(
          icon: Icons.directions_car_filled_rounded,
          dx: 0.3,
          dy: 0.6,
          size: 52,
        ),
        ToeicSceneIcon(
          icon: Icons.directions_car_filled_rounded,
          dx: 0.65,
          dy: 0.6,
          size: 52,
        ),
        ToeicSceneIcon(
          icon: Icons.traffic_rounded,
          dx: 0.9,
          dy: 0.35,
          size: 36,
        ),
      ],
    ),
    options: const [
      'The street is completely empty.',
      'A truck is being loaded with boxes.',
      'Some cars are parked along the street.',
      'Workers are repairing the road.',
    ],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: Ảnh cho thấy vài chiếc ô tô đậu dọc đường. '
        '· Đáp án: C. Some cars are parked along the street. '
        '· Giải thích: Có ô tô trong ảnh nên "đường trống hoàn toàn" (A) sai; '
        'không có xe tải hay công nhân sửa đường nên B, D cũng sai. '
        '· Dịch: Vài chiếc ô tô đang đậu dọc theo con đường.',
  ),
  ToeicQuestion(
    id: 'p1-q4',
    part: ToeicPartNumber.p1,
    illustration: ToeicIllustrationSpec(
      backgroundColor: const Color(0xFF8A5A2C),
      icons: const [
        ToeicSceneIcon(
          icon: Icons.inventory_2_rounded,
          dx: 0.3,
          dy: 0.55,
          size: 50,
        ),
        ToeicSceneIcon(
          icon: Icons.inventory_2_rounded,
          dx: 0.5,
          dy: 0.4,
          size: 50,
        ),
        ToeicSceneIcon(
          icon: Icons.warehouse_rounded,
          dx: 0.72,
          dy: 0.6,
          size: 56,
        ),
      ],
    ),
    options: const [
      'A worker is unloading a truck.',
      'Boxes are stacked against the wall.',
      'The shelves are completely empty.',
      'A man is sweeping the floor.',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Trong kho, các thùng hàng được xếp chồng lên nhau sát tường. '
        '· Đáp án: B. Boxes are stacked against the wall. '
        '· Giải thích: Không có xe tải, người quét dọn, hay kệ trống trong ảnh - '
        'chỉ có các thùng hàng xếp chồng. '
        '· Dịch: Các thùng hàng được xếp chồng lên sát tường.',
  ),
  ToeicQuestion(
    id: 'p1-q5',
    part: ToeicPartNumber.p1,
    illustration: ToeicIllustrationSpec(
      backgroundColor: const Color(0xFF2E8B7A),
      icons: const [
        ToeicSceneIcon(
          icon: Icons.directions_bike_rounded,
          dx: 0.45,
          dy: 0.55,
          size: 56,
        ),
        ToeicSceneIcon(icon: Icons.park_rounded, dx: 0.8, dy: 0.35, size: 44),
      ],
    ),
    options: const [
      'A man is fixing a bicycle.',
      'Two men are walking their bikes.',
      'A man is riding a bicycle.',
      'The bicycle is parked near a tree.',
    ],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: Một người đàn ông đang đạp xe đạp trong công viên. '
        '· Đáp án: C. A man is riding a bicycle. '
        '· Giải thích: Chỉ có 1 người và xe đang được đạp (không phải sửa, dắt '
        'bộ, hay đậu sẵn). '
        '· Dịch: Một người đàn ông đang đạp xe đạp.',
  ),
  ToeicQuestion(
    id: 'p1-q6',
    part: ToeicPartNumber.p1,
    illustration: ToeicIllustrationSpec(
      backgroundColor: const Color(0xFF4A4A6A),
      icons: const [
        ToeicSceneIcon(
          icon: Icons.event_seat_rounded,
          dx: 0.28,
          dy: 0.55,
          size: 44,
        ),
        ToeicSceneIcon(
          icon: Icons.event_seat_rounded,
          dx: 0.5,
          dy: 0.55,
          size: 44,
        ),
        ToeicSceneIcon(icon: Icons.person_rounded, dx: 0.72, dy: 0.4, size: 48),
      ],
    ),
    options: const [
      'The chairs are all empty.',
      'People are sitting in a waiting area.',
      'A receptionist is greeting a visitor.',
      'People are standing in line.',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Có người đang ngồi trên ghế trong khu vực chờ. '
        '· Đáp án: B. People are sitting in a waiting area. '
        '· Giải thích: Ghế không trống (có người ngồi), không ai đứng xếp hàng '
        'hay chào đón khách. '
        '· Dịch: Mọi người đang ngồi trong khu vực chờ.',
  ),
];

// ============================================================================
// PART 2 - Question-Response (25 cau). Moi cau: 1 cau hoi/cau noi duoc doc
// len + 3 phuong an tra loi (A-C), chon phan hoi phu hop nhat.
// ============================================================================

final _part2Questions = <ToeicQuestion>[
  ToeicQuestion(
    id: 'p2-q1',
    part: ToeicPartNumber.p2,
    promptEn: 'When does the new office open?',
    options: const [
      'Next Monday morning.',
      'It has three floors.',
      'Yes, I have a key.',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: When does the new office open? '
        '· Đáp án: A. Next Monday morning. '
        '· Giải thích: Câu hỏi bắt đầu bằng "When" cần trả lời về thời gian - '
        'chỉ đáp án A nói về thời điểm. '
        '· Dịch: Văn phòng mới mở cửa vào khi nào? → Sáng thứ Hai tới.',
  ),
  ToeicQuestion(
    id: 'p2-q2',
    part: ToeicPartNumber.p2,
    promptEn: 'Who is in charge of the marketing budget this year?',
    options: const [
      'Sometime next week.',
      'Mr. Alvarez took over in January.',
      'About two thousand dollars.',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Who is in charge of the marketing budget this year? '
        '· Đáp án: B. Mr. Alvarez took over in January. '
        '· Giải thích: Câu hỏi "Who" cần câu trả lời chỉ người - chỉ đáp án B '
        'nêu tên người. '
        '· Dịch: Ai phụ trách ngân sách marketing năm nay? → Ông Alvarez đã '
        'tiếp quản từ tháng Một.',
  ),
  ToeicQuestion(
    id: 'p2-q3',
    part: ToeicPartNumber.p2,
    promptEn: 'Where should I leave the delivery boxes?',
    options: const [
      'Just inside the back door, please.',
      'They arrived this morning.',
      'No, I ordered them last week.',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: Where should I leave the delivery boxes? '
        '· Đáp án: A. Just inside the back door, please. '
        '· Giải thích: "Where" hỏi về địa điểm, chỉ đáp án A nêu vị trí cụ thể. '
        '· Dịch: Tôi nên để các thùng hàng giao ở đâu? → Ngay bên trong cửa '
        'sau nhé.',
  ),
  ToeicQuestion(
    id: 'p2-q4',
    part: ToeicPartNumber.p2,
    promptEn: 'Why was the meeting rescheduled?',
    options: const [
      'In the main conference room.',
      'The client had a scheduling conflict.',
      'For about an hour.',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Why was the meeting rescheduled? '
        '· Đáp án: B. The client had a scheduling conflict. '
        '· Giải thích: "Why" cần lý do - chỉ đáp án B đưa ra nguyên nhân. '
        '· Dịch: Vì sao cuộc họp bị dời lịch? → Khách hàng bị trùng lịch.',
  ),
  ToeicQuestion(
    id: 'p2-q5',
    part: ToeicPartNumber.p2,
    promptEn: 'How long will the renovation take?',
    options: const [
      'It belongs to the design team.',
      'Roughly three weeks.',
      'Because the paint was defective.',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: How long will the renovation take? '
        '· Đáp án: B. Roughly three weeks. '
        '· Giải thích: "How long" hỏi về khoảng thời gian - chỉ đáp án B nêu '
        'thời lượng. '
        '· Dịch: Việc sửa chữa sẽ mất bao lâu? → Khoảng ba tuần.',
  ),
  ToeicQuestion(
    id: 'p2-q6',
    part: ToeicPartNumber.p2,
    promptEn: 'Did you send the invoice to the supplier yet?',
    options: const [
      'Yes, I sent it this morning.',
      'It costs about fifty dollars.',
      'Next to the printer.',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: Did you send the invoice to the supplier yet? '
        '· Đáp án: A. Yes, I sent it this morning. '
        '· Giải thích: Câu hỏi Yes/No cần bắt đầu bằng Yes/No hợp lý - chỉ A '
        'phù hợp và trả lời đúng trọng tâm. '
        '· Dịch: Bạn đã gửi hoá đơn cho nhà cung cấp chưa? → Rồi, tôi gửi sáng '
        'nay rồi.',
  ),
  ToeicQuestion(
    id: 'p2-q7',
    part: ToeicPartNumber.p2,
    promptEn: 'Would you like tea or coffee with your breakfast?',
    options: const [
      'I\'ll have coffee, please.',
      'Breakfast starts at seven.',
      'The hotel has two restaurants.',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: Would you like tea or coffee with your breakfast? '
        '· Đáp án: A. I\'ll have coffee, please. '
        '· Giải thích: Câu hỏi lựa chọn (A or B) cần chọn 1 trong 2 - chỉ A '
        'chọn "coffee" hợp lý. '
        '· Dịch: Bạn muốn trà hay cà phê cùng bữa sáng? → Tôi dùng cà phê nhé.',
  ),
  ToeicQuestion(
    id: 'p2-q8',
    part: ToeicPartNumber.p2,
    promptEn: 'The printer on the third floor is out of toner again.',
    options: const [
      'I\'ll order a replacement cartridge today.',
      'It was printed in color.',
      'Three copies should be enough.',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: The printer on the third floor is out of toner again. '
        '· Đáp án: A. I\'ll order a replacement cartridge today. '
        '· Giải thích: Đây là câu trần thuật (không phải câu hỏi) báo vấn đề - '
        'phản hồi hợp lý nhất là đề xuất giải quyết. '
        '· Dịch: Máy in ở tầng ba lại hết mực rồi. → Tôi sẽ đặt hộp mực mới '
        'hôm nay.',
  ),
  ToeicQuestion(
    id: 'p2-q9',
    part: ToeicPartNumber.p2,
    promptEn: 'Isn\'t the annual report due by Friday?',
    options: const [
      'Yes, but we got a short extension.',
      'It has twenty pages.',
      'On the shared drive.',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: Isn\'t the annual report due by Friday? '
        '· Đáp án: A. Yes, but we got a short extension. '
        '· Giải thích: Câu hỏi phủ định vẫn cần trả lời Yes/No hợp lý theo sự '
        'thật - A xác nhận đúng deadline nhưng bổ sung thông tin gia hạn. '
        '· Dịch: Báo cáo thường niên không phải hạn thứ Sáu sao? → Đúng vậy, '
        'nhưng chúng tôi được gia hạn thêm ít ngày.',
  ),
  ToeicQuestion(
    id: 'p2-q10',
    part: ToeicPartNumber.p2,
    promptEn: 'Which conference room did you book for the interview?',
    options: const [
      'The one on the fifth floor.',
      'At two o\'clock sharp.',
      'She has five years of experience.',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: Which conference room did you book for the interview? '
        '· Đáp án: A. The one on the fifth floor. '
        '· Giải thích: "Which" hỏi chọn cái nào trong số các phòng họp - chỉ A '
        'nêu rõ phòng cụ thể. '
        '· Dịch: Bạn đã đặt phòng họp nào cho buổi phỏng vấn? → Phòng ở tầng '
        'năm.',
  ),
  ToeicQuestion(
    id: 'p2-q11',
    part: ToeicPartNumber.p2,
    promptEn: 'Could you forward me the client\'s contact information?',
    options: const [
      'Sure, I\'ll email it right away.',
      'The client called twice.',
      'It\'s a long-term contract.',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: Could you forward me the client\'s contact information? '
        '· Đáp án: A. Sure, I\'ll email it right away. '
        '· Giải thích: Đây là câu yêu cầu lịch sự (request) - phản hồi hợp lý '
        'là đồng ý/từ chối thực hiện yêu cầu, chỉ A phù hợp. '
        '· Dịch: Bạn gửi giúp tôi thông tin liên hệ của khách hàng được không? '
        '→ Được, tôi gửi email ngay đây.',
  ),
  ToeicQuestion(
    id: 'p2-q12',
    part: ToeicPartNumber.p2,
    promptEn: 'What time does the shuttle bus leave for the airport?',
    options: const [
      'Every hour, on the hour.',
      'It seats twenty passengers.',
      'The airport is quite far.',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: What time does the shuttle bus leave for the airport? '
        '· Đáp án: A. Every hour, on the hour. '
        '· Giải thích: "What time" cần thông tin thời gian/tần suất - chỉ A '
        'trả lời đúng trọng tâm. '
        '· Dịch: Xe buýt đưa đón sân bay chạy lúc mấy giờ? → Mỗi giờ chạy một '
        'chuyến, đúng giờ.',
  ),
  ToeicQuestion(
    id: 'p2-q13',
    part: ToeicPartNumber.p2,
    promptEn: 'Haven\'t you finished the sales presentation yet?',
    options: const [
      'Almost - just a few slides left.',
      'The sales team is very large.',
      'It was presented last quarter.',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: Haven\'t you finished the sales presentation yet? '
        '· Đáp án: A. Almost - just a few slides left. '
        '· Giải thích: Câu hỏi phủ định về tiến độ - A trả lời trực tiếp về '
        'mức độ hoàn thành. '
        '· Dịch: Bạn chưa làm xong bài thuyết trình bán hàng à? → Gần xong '
        'rồi, còn vài slide nữa thôi.',
  ),
  ToeicQuestion(
    id: 'p2-q14',
    part: ToeicPartNumber.p2,
    promptEn: 'Do you want me to pick up lunch or should we order delivery?',
    options: const [
      'Let\'s just order delivery today.',
      'I had lunch already.',
      'The restaurant closes at nine.',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: Do you want me to pick up lunch or should we order '
        'delivery? '
        '· Đáp án: A. Let\'s just order delivery today. '
        '· Giải thích: Câu hỏi lựa chọn cần chọn 1 phương án - chỉ A chọn rõ '
        '"delivery". '
        '· Dịch: Bạn muốn tôi đi mua đồ ăn trưa hay đặt giao hàng? → Hôm nay '
        'đặt giao hàng đi.',
  ),
  ToeicQuestion(
    id: 'p2-q15',
    part: ToeicPartNumber.p2,
    promptEn: 'The new software update keeps crashing on my computer.',
    options: const [
      'Let\'s ask IT to take a look.',
      'It was released last month.',
      'The update took an hour.',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: The new software update keeps crashing on my computer. '
        '· Đáp án: A. Let\'s ask IT to take a look. '
        '· Giải thích: Câu trần thuật nêu vấn đề kỹ thuật - phản hồi hợp lý '
        'nhất là đề xuất hướng giải quyết. '
        '· Dịch: Bản cập nhật phần mềm mới cứ bị treo trên máy tôi. → Hay nhờ '
        'bộ phận IT kiểm tra xem sao.',
  ),
  ToeicQuestion(
    id: 'p2-q16',
    part: ToeicPartNumber.p2,
    promptEn: 'Where did you park the company car?',
    options: const [
      'In the lot behind the building.',
      'It runs on diesel.',
      'I borrowed it for two days.',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: Where did you park the company car? '
        '· Đáp án: A. In the lot behind the building. '
        '· Giải thích: "Where" hỏi vị trí - chỉ A nêu địa điểm đỗ xe. '
        '· Dịch: Bạn đậu xe công ty ở đâu? → Ở bãi đậu phía sau toà nhà.',
  ),
  ToeicQuestion(
    id: 'p2-q17',
    part: ToeicPartNumber.p2,
    promptEn: 'Who\'s going to represent our department at the conference?',
    options: const [
      'Probably Ms. Reyes and I.',
      'It\'s held every spring.',
      'The tickets were expensive.',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: Who\'s going to represent our department at the '
        'conference? '
        '· Đáp án: A. Probably Ms. Reyes and I. '
        '· Giải thích: "Who" cần câu trả lời chỉ người - chỉ A nêu tên người '
        'cụ thể. '
        '· Dịch: Ai sẽ đại diện phòng ban mình tham dự hội nghị? → Chắc là cô '
        'Reyes và tôi.',
  ),
  ToeicQuestion(
    id: 'p2-q18',
    part: ToeicPartNumber.p2,
    promptEn: 'You\'re coming to the retirement party on Friday, aren\'t you?',
    options: const [
      'Of course, I wouldn\'t miss it.',
      'He retired last year.',
      'The party lasted two hours.',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: You\'re coming to the retirement party on Friday, aren\'t '
        'you? '
        '· Đáp án: A. Of course, I wouldn\'t miss it. '
        '· Giải thích: Câu hỏi đuôi (tag question) xác nhận thông tin - A trả '
        'lời trực tiếp việc có tham dự hay không. '
        '· Dịch: Bạn sẽ đến tiệc chia tay hưu vào thứ Sáu, đúng không? → Tất '
        'nhiên rồi, tôi không bỏ lỡ đâu.',
  ),
  ToeicQuestion(
    id: 'p2-q19',
    part: ToeicPartNumber.p2,
    promptEn: 'How much did the new office chairs cost?',
    options: const [
      'About two hundred dollars each.',
      'They\'re very comfortable.',
      'We ordered twenty of them.',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: How much did the new office chairs cost? '
        '· Đáp án: A. About two hundred dollars each. '
        '· Giải thích: "How much" hỏi về giá tiền - chỉ A trả lời bằng con số '
        'tiền. '
        '· Dịch: Ghế văn phòng mới giá bao nhiêu? → Khoảng hai trăm đô một '
        'cái.',
  ),
  ToeicQuestion(
    id: 'p2-q20',
    part: ToeicPartNumber.p2,
    promptEn: 'Should we cancel the outdoor event if it rains?',
    options: const [
      'Yes, we\'ll move it indoors instead.',
      'It rained all last week.',
      'The event starts at noon.',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: Should we cancel the outdoor event if it rains? '
        '· Đáp án: A. Yes, we\'ll move it indoors instead. '
        '· Giải thích: Câu hỏi Yes/No về quyết định - A trả lời rõ ràng kèm '
        'phương án thay thế. '
        '· Dịch: Có nên huỷ sự kiện ngoài trời nếu trời mưa không? → Có, '
        'chúng ta sẽ chuyển vào trong nhà.',
  ),
  ToeicQuestion(
    id: 'p2-q21',
    part: ToeicPartNumber.p2,
    promptEn: 'This coffee machine hasn\'t been working since Monday.',
    options: const [
      'I\'ll call the repair service now.',
      'I don\'t drink coffee.',
      'It was purchased last year.',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: This coffee machine hasn\'t been working since Monday. '
        '· Đáp án: A. I\'ll call the repair service now. '
        '· Giải thích: Câu trần thuật báo hỏng hóc - phản hồi hợp lý nhất là '
        'đề xuất gọi sửa. '
        '· Dịch: Máy pha cà phê này hỏng từ thứ Hai rồi. → Tôi sẽ gọi dịch vụ '
        'sửa chữa ngay.',
  ),
  ToeicQuestion(
    id: 'p2-q22',
    part: ToeicPartNumber.p2,
    promptEn: 'When will the survey results be available?',
    options: const [
      'By the end of this week.',
      'Over five hundred people responded.',
      'The survey had ten questions.',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: When will the survey results be available? '
        '· Đáp án: A. By the end of this week. '
        '· Giải thích: "When" hỏi thời điểm - chỉ A nêu mốc thời gian. '
        '· Dịch: Khi nào có kết quả khảo sát? → Trước cuối tuần này.',
  ),
  ToeicQuestion(
    id: 'p2-q23',
    part: ToeicPartNumber.p2,
    promptEn: 'Why don\'t we take a short break before the next session?',
    options: const [
      'That sounds like a good idea.',
      'The session lasted an hour.',
      'We took a break yesterday.',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: Why don\'t we take a short break before the next session? '
        '· Đáp án: A. That sounds like a good idea. '
        '· Giải thích: "Why don\'t we..." là cách đề nghị - phản hồi hợp lý là '
        'đồng ý/từ chối đề nghị đó, chỉ A phù hợp. '
        '· Dịch: Sao mình không nghỉ giải lao ngắn trước phiên tiếp theo nhỉ? '
        '→ Nghe hay đấy.',
  ),
  ToeicQuestion(
    id: 'p2-q24',
    part: ToeicPartNumber.p2,
    promptEn: 'Has the vendor confirmed the delivery date yet?',
    options: const [
      'Not yet, I\'ll follow up today.',
      'The vendor is based overseas.',
      'The delivery fee is included.',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: Has the vendor confirmed the delivery date yet? '
        '· Đáp án: A. Not yet, I\'ll follow up today. '
        '· Giải thích: Câu hỏi Yes/No về việc đã xác nhận hay chưa - A trả '
        'lời trực tiếp bằng "Not yet". '
        '· Dịch: Nhà cung cấp đã xác nhận ngày giao hàng chưa? → Chưa, tôi sẽ '
        'theo sát hôm nay.',
  ),
  ToeicQuestion(
    id: 'p2-q25',
    part: ToeicPartNumber.p2,
    promptEn: 'Would you rather work from home or come into the office today?',
    options: const [
      'I\'d prefer to come into the office.',
      'The office is on Main Street.',
      'I worked from home yesterday.',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: Would you rather work from home or come into the office '
        'today? '
        '· Đáp án: A. I\'d prefer to come into the office. '
        '· Giải thích: Câu hỏi lựa chọn - chỉ A chọn rõ 1 phương án được hỏi. '
        '· Dịch: Bạn muốn làm ở nhà hay đến văn phòng hôm nay? → Tôi thích '
        'đến văn phòng hơn.',
  ),
];

// ============================================================================
// PART 3 - Conversations (13 hoi thoai x 3 cau = 39 cau). Moi hoi thoai la 1
// ToeicAudioScript dung chung boi 3 ToeicQuestion.
// ============================================================================

final _part3Scripts = <ToeicAudioScript>[
  const ToeicAudioScript(
    id: 'p3-conv1',
    speakerLabels: ['Man', 'Woman'],
    lines: [
      ToeicAudioLine(
        speakerIndex: 0,
        textEn:
            'Hi, I wanted to check if the conference room on the third '
            'floor is free tomorrow morning.',
      ),
      ToeicAudioLine(
        speakerIndex: 1,
        textEn:
            'Let me check the schedule. It looks open until eleven, but '
            'the sales team has it booked after that.',
      ),
      ToeicAudioLine(
        speakerIndex: 0,
        textEn:
            'That works. I only need it from nine to ten for a client call.',
      ),
      ToeicAudioLine(
        speakerIndex: 1,
        textEn: 'Great, I\'ll reserve it under your name right now.',
      ),
    ],
  ),
  const ToeicAudioScript(
    id: 'p3-conv2',
    speakerLabels: ['Woman', 'Man'],
    lines: [
      ToeicAudioLine(
        speakerIndex: 1,
        textEn:
            'Excuse me, I bought this blender last week, but it stopped '
            'working this morning.',
      ),
      ToeicAudioLine(
        speakerIndex: 0,
        textEn:
            'I\'m sorry to hear that. Do you have your receipt with you? '
            'We can exchange it or give you a refund.',
      ),
      ToeicAudioLine(
        speakerIndex: 1,
        textEn: 'Yes, here it is. I\'d prefer an exchange, if possible.',
      ),
      ToeicAudioLine(
        speakerIndex: 0,
        textEn: 'No problem. Let me grab a new one from the storeroom for you.',
      ),
    ],
  ),
  const ToeicAudioScript(
    id: 'p3-conv3',
    speakerLabels: ['Man', 'Woman'],
    lines: [
      ToeicAudioLine(
        speakerIndex: 0,
        textEn:
            'Hello, I\'d like to make a reservation for four people this '
            'Saturday evening.',
      ),
      ToeicAudioLine(
        speakerIndex: 1,
        textEn:
            'Of course. We have an opening at seven or at eight-thirty. '
            'Which would you prefer?',
      ),
      ToeicAudioLine(speakerIndex: 0, textEn: 'Seven works better for us.'),
      ToeicAudioLine(
        speakerIndex: 1,
        textEn:
            'Perfect, I\'ve booked a table for four at seven. Can I get a '
            'name for the reservation?',
      ),
    ],
  ),
  const ToeicAudioScript(
    id: 'p3-conv4',
    speakerLabels: ['Woman', 'Man'],
    lines: [
      ToeicAudioLine(
        speakerIndex: 1,
        textEn: 'The printer on our floor is jammed again. This is the third time this week.',
      ),
      ToeicAudioLine(
        speakerIndex: 0,
        textEn:
            'I noticed that too. Maybe we should just replace it instead '
            'of repairing it again.',
      ),
      ToeicAudioLine(
        speakerIndex: 1,
        textEn: 'Good idea. I\'ll ask the office manager to order a new one.',
      ),
      ToeicAudioLine(
        speakerIndex: 0,
        textEn: 'Thanks. In the meantime, we can use the printer on the second floor.',
      ),
    ],
  ),
  const ToeicAudioScript(
    id: 'p3-conv5',
    speakerLabels: ['Man', 'Woman'],
    lines: [
      ToeicAudioLine(
        speakerIndex: 0,
        textEn:
            'Thank you for coming in again. We were impressed with your '
            'interview last week.',
      ),
      ToeicAudioLine(
        speakerIndex: 1,
        textEn: 'Thank you, I really enjoyed meeting the team.',
      ),
      ToeicAudioLine(
        speakerIndex: 0,
        textEn:
            'We\'d like to offer you the position. Would you be able to '
            'start in two weeks?',
      ),
      ToeicAudioLine(
        speakerIndex: 1,
        textEn: 'Yes, that timing works perfectly for me.',
      ),
    ],
  ),
  const ToeicAudioScript(
    id: 'p3-conv6',
    speakerLabels: ['Woman', 'Man'],
    lines: [
      ToeicAudioLine(
        speakerIndex: 1,
        textEn:
            'We\'ve reviewed your proposal, and the pricing looks '
            'reasonable, but the timeline seems tight.',
      ),
      ToeicAudioLine(
        speakerIndex: 0,
        textEn:
            'I understand your concern. We could extend the delivery date '
            'by two weeks if needed.',
      ),
      ToeicAudioLine(
        speakerIndex: 1,
        textEn: 'That would help a lot. Could you send an updated contract?',
      ),
      ToeicAudioLine(
        speakerIndex: 0,
        textEn: 'Absolutely, I\'ll have it in your inbox by tomorrow morning.',
      ),
    ],
  ),
  const ToeicAudioScript(
    id: 'p3-conv7',
    speakerLabels: ['Man', 'Woman'],
    lines: [
      ToeicAudioLine(
        speakerIndex: 0,
        textEn: 'Are you still planning to attend the conference in Chicago next month?',
      ),
      ToeicAudioLine(
        speakerIndex: 1,
        textEn:
            'I am, but I haven\'t booked my flight yet. Ticket prices keep '
            'going up.',
      ),
      ToeicAudioLine(
        speakerIndex: 0,
        textEn:
            'You should book soon. I heard prices usually rise sharply '
            'after this weekend.',
      ),
      ToeicAudioLine(
        speakerIndex: 1,
        textEn: 'Thanks for the heads-up. I\'ll book tonight.',
      ),
    ],
  ),
  const ToeicAudioScript(
    id: 'p3-conv8',
    speakerLabels: ['Woman', 'Man'],
    lines: [
      ToeicAudioLine(
        speakerIndex: 1,
        textEn: 'Hi, I have a reservation under Park, but the room key isn\'t working.',
      ),
      ToeicAudioLine(
        speakerIndex: 0,
        textEn:
            'I apologize for the inconvenience. Let me reprogram a new '
            'key for you right away.',
      ),
      ToeicAudioLine(
        speakerIndex: 1,
        textEn: 'Thank you. Also, is the pool still open at this hour?',
      ),
      ToeicAudioLine(
        speakerIndex: 0,
        textEn: 'Yes, it\'s open until ten o\'clock tonight.',
      ),
    ],
  ),
  const ToeicAudioScript(
    id: 'p3-conv9',
    speakerLabels: ['Man', 'Woman'],
    lines: [
      ToeicAudioLine(
        speakerIndex: 0,
        textEn: 'The shipment from our supplier hasn\'t arrived yet, and it was due yesterday.',
      ),
      ToeicAudioLine(
        speakerIndex: 1,
        textEn:
            'I just spoke with them. They said a customs delay pushed it '
            'back by two days.',
      ),
      ToeicAudioLine(
        speakerIndex: 0,
        textEn: 'That\'s going to affect our production schedule.',
      ),
      ToeicAudioLine(
        speakerIndex: 1,
        textEn:
            'I\'ll let the production manager know so we can adjust the plan.',
      ),
    ],
  ),
  const ToeicAudioScript(
    id: 'p3-conv10',
    speakerLabels: ['Woman', 'Man'],
    lines: [
      ToeicAudioLine(
        speakerIndex: 1,
        textEn:
            'I need to reschedule my appointment with Dr. Osei. Something '
            'came up at work.',
      ),
      ToeicAudioLine(
        speakerIndex: 0,
        textEn:
            'No problem. The next available slot is Thursday at three, or '
            'Friday at ten.',
      ),
      ToeicAudioLine(
        speakerIndex: 1,
        textEn: 'Friday at ten works better for me.',
      ),
      ToeicAudioLine(
        speakerIndex: 0,
        textEn: 'Great, I\'ve moved your appointment to Friday at ten.',
      ),
    ],
  ),
  const ToeicAudioScript(
    id: 'p3-conv11',
    speakerLabels: ['Man', 'Woman'],
    lines: [
      ToeicAudioLine(
        speakerIndex: 0,
        textEn: 'IT support, how can I help you?',
      ),
      ToeicAudioLine(
        speakerIndex: 1,
        textEn:
            'My computer won\'t connect to the office network this morning.',
      ),
      ToeicAudioLine(
        speakerIndex: 0,
        textEn:
            'Let\'s try restarting your router first. Can you unplug it '
            'for about ten seconds?',
      ),
      ToeicAudioLine(
        speakerIndex: 1,
        textEn: 'Okay, one moment... it\'s connecting now. Thank you!',
      ),
    ],
  ),
  const ToeicAudioScript(
    id: 'p3-conv12',
    speakerLabels: ['Woman', 'Man'],
    lines: [
      ToeicAudioLine(
        speakerIndex: 1,
        textEn:
            'We need to cut ten percent from the department budget before '
            'the next fiscal year.',
      ),
      ToeicAudioLine(
        speakerIndex: 0,
        textEn:
            'That\'s significant. We could reduce travel expenses and '
            'delay the software upgrade.',
      ),
      ToeicAudioLine(
        speakerIndex: 1,
        textEn: 'That sounds reasonable. Can you put together a revised budget by Friday?',
      ),
      ToeicAudioLine(
        speakerIndex: 0,
        textEn: 'Sure, I\'ll have a draft ready for you to review.',
      ),
    ],
  ),
  const ToeicAudioScript(
    id: 'p3-conv13',
    speakerLabels: ['Man', 'Woman'],
    lines: [
      ToeicAudioLine(
        speakerIndex: 0,
        textEn: 'Hi, my flight to Boston was just canceled. Can you help me find another one?',
      ),
      ToeicAudioLine(
        speakerIndex: 1,
        textEn:
            'I\'m sorry about that. There\'s another flight leaving in two '
            'hours with two seats left.',
      ),
      ToeicAudioLine(
        speakerIndex: 0,
        textEn: 'That works for me. Can I keep the same seat number?',
      ),
      ToeicAudioLine(
        speakerIndex: 1,
        textEn:
            'Let me check... yes, that seat is available on this flight too.',
      ),
    ],
  ),
];

final _part3Questions = <ToeicQuestion>[
  // --- Hoi thoai 1: dat phong hop ---
  ToeicQuestion(
    id: 'p3-q1',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv1',
    promptEn: 'What does the man want to do?',
    options: const [
      'Cancel a meeting',
      'Book a conference room',
      'Buy new furniture',
      'Interview a candidate',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What does the man want to do? '
        '· Đáp án: B. Book a conference room '
        '· Giải thích: Người nam mở đầu hỏi phòng họp tầng 3 có trống vào '
        'sáng mai không - tức muốn đặt phòng họp. '
        '· Dịch: Người đàn ông muốn làm gì? → Đặt một phòng họp.',
  ),
  ToeicQuestion(
    id: 'p3-q2',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv1',
    promptEn: 'When does the sales team need the room?',
    options: const [
      'Before nine',
      'From nine to ten',
      'After eleven',
      'All day',
    ],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: When does the sales team need the room? '
        '· Đáp án: C. After eleven '
        '· Giải thích: Người nữ nói phòng trống đến 11 giờ, sau đó đội sales '
        'đã đặt. '
        '· Dịch: Đội sales cần phòng khi nào? → Sau 11 giờ.',
  ),
  ToeicQuestion(
    id: 'p3-q3',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv1',
    promptEn: 'What will the woman do next?',
    options: const [
      'Cancel the client call',
      'Reserve the room',
      'Move to another floor',
      'Contact the sales team',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What will the woman do next? '
        '· Đáp án: B. Reserve the room '
        '· Giải thích: Câu cuối người nữ nói sẽ đặt phòng ngay dưới tên '
        'người nam. '
        '· Dịch: Người phụ nữ sẽ làm gì tiếp theo? → Đặt phòng họp.',
  ),

  // --- Hoi thoai 2: doi tra hang ---
  ToeicQuestion(
    id: 'p3-q4',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv2',
    promptEn: 'What problem does the woman mention?',
    options: const [
      'She lost her receipt.',
      'A product stopped working.',
      'She was overcharged.',
      'An item was out of stock.',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What problem does the woman mention? '
        '· Đáp án: B. A product stopped working. '
        '· Giải thích: Người nữ nói máy xay bị hỏng ngay sáng nay. '
        '· Dịch: Người phụ nữ gặp vấn đề gì? → Một sản phẩm ngừng hoạt động.',
  ),
  ToeicQuestion(
    id: 'p3-q5',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv2',
    promptEn: 'What does the man ask for?',
    options: const [
      'A photo of the item',
      'The receipt',
      'A phone number',
      'The manager\'s approval',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What does the man ask for? '
        '· Đáp án: B. The receipt '
        '· Giải thích: Nhân viên hỏi khách có hoá đơn không để đổi/trả hàng. '
        '· Dịch: Người đàn ông yêu cầu gì? → Hoá đơn mua hàng.',
  ),
  ToeicQuestion(
    id: 'p3-q6',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv2',
    promptEn: 'What does the woman prefer?',
    options: const ['A refund', 'A store credit', 'An exchange', 'A discount'],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: What does the woman prefer? '
        '· Đáp án: C. An exchange '
        '· Giải thích: Người nữ nói rõ "I\'d prefer an exchange". '
        '· Dịch: Người phụ nữ muốn gì hơn? → Đổi hàng.',
  ),

  // --- Hoi thoai 3: dat ban nha hang ---
  ToeicQuestion(
    id: 'p3-q7',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv3',
    promptEn: 'Why is the man calling?',
    options: const [
      'To cancel a reservation',
      'To make a reservation',
      'To ask about a menu',
      'To complain about service',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Why is the man calling? '
        '· Đáp án: B. To make a reservation '
        '· Giải thích: Người nam mở đầu nói muốn đặt bàn cho 4 người tối '
        'thứ Bảy. '
        '· Dịch: Vì sao người đàn ông gọi điện? → Để đặt bàn.',
  ),
  ToeicQuestion(
    id: 'p3-q8',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv3',
    promptEn: 'How many people is the reservation for?',
    options: const ['Two', 'Three', 'Four', 'Six'],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: How many people is the reservation for? '
        '· Đáp án: C. Four '
        '· Giải thích: Người nam nói rõ "for four people". '
        '· Dịch: Bàn đặt cho bao nhiêu người? → Bốn người.',
  ),
  ToeicQuestion(
    id: 'p3-q9',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv3',
    promptEn: 'What time will the reservation be?',
    options: const [
      'Six o\'clock',
      'Seven o\'clock',
      'Eight-thirty',
      'Nine o\'clock',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What time will the reservation be? '
        '· Đáp án: B. Seven o\'clock '
        '· Giải thích: Người nam chọn khung giờ 7 giờ thay vì 8:30. '
        '· Dịch: Giờ đặt bàn là mấy giờ? → Bảy giờ.',
  ),

  // --- Hoi thoai 4: may in hong ---
  ToeicQuestion(
    id: 'p3-q10',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv4',
    promptEn: 'What are the speakers mainly discussing?',
    options: const [
      'A broken printer',
      'A new hire',
      'A delayed delivery',
      'A budget report',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: What are the speakers mainly discussing? '
        '· Đáp án: A. A broken printer '
        '· Giải thích: Cả đoạn hội thoại xoay quanh máy in bị kẹt giấy liên '
        'tục. '
        '· Dịch: Hai người chủ yếu bàn về điều gì? → Một chiếc máy in bị '
        'hỏng.',
  ),
  ToeicQuestion(
    id: 'p3-q11',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv4',
    promptEn: 'What does the man suggest?',
    options: const [
      'Repairing the printer again',
      'Replacing the printer',
      'Buying more paper',
      'Calling a technician',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What does the man suggest? '
        '· Đáp án: B. Replacing the printer '
        '· Giải thích: Người nam đề xuất thay máy mới thay vì sửa tiếp. '
        '· Dịch: Người đàn ông đề xuất gì? → Thay máy in mới.',
  ),
  ToeicQuestion(
    id: 'p3-q12',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv4',
    promptEn: 'What will the speakers do in the meantime?',
    options: const [
      'Work from home',
      'Use the printer on another floor',
      'Print fewer documents',
      'Ask coworkers for help',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What will the speakers do in the meantime? '
        '· Đáp án: B. Use the printer on another floor '
        '· Giải thích: Câu cuối nhắc dùng tạm máy in ở tầng 2. '
        '· Dịch: Trong lúc chờ, họ sẽ làm gì? → Dùng máy in ở tầng khác.',
  ),

  // --- Hoi thoai 5: nhan viec ---
  ToeicQuestion(
    id: 'p3-q13',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv5',
    promptEn: 'What is the purpose of this conversation?',
    options: const [
      'To schedule an interview',
      'To offer a job',
      'To discuss a resignation',
      'To review a performance report',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What is the purpose of this conversation? '
        '· Đáp án: B. To offer a job '
        '· Giải thích: Người nam nói rõ "We\'d like to offer you the '
        'position". '
        '· Dịch: Mục đích của cuộc hội thoại là gì? → Để đề nghị công việc.',
  ),
  ToeicQuestion(
    id: 'p3-q14',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv5',
    promptEn: 'When does the man ask the woman to start?',
    options: const ['Immediately', 'In one week', 'In two weeks', 'Next month'],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: When does the man ask the woman to start? '
        '· Đáp án: C. In two weeks '
        '· Giải thích: Người nam hỏi liệu bắt đầu trong 2 tuần được không. '
        '· Dịch: Người đàn ông đề nghị bắt đầu khi nào? → Trong hai tuần.',
  ),
  ToeicQuestion(
    id: 'p3-q15',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv5',
    promptEn: 'How does the woman respond to the offer?',
    options: const [
      'She declines it.',
      'She asks for more time.',
      'She accepts the timing.',
      'She negotiates the salary.',
    ],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: How does the woman respond to the offer? '
        '· Đáp án: C. She accepts the timing. '
        '· Giải thích: Người nữ nói "that timing works perfectly for me". '
        '· Dịch: Người phụ nữ phản hồi thế nào? → Cô ấy đồng ý với thời gian '
        'đó.',
  ),

  // --- Hoi thoai 6: dam phan hop dong ---
  ToeicQuestion(
    id: 'p3-q16',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv6',
    promptEn: 'What concern does the woman raise?',
    options: const [
      'The price is too high.',
      'The timeline is too tight.',
      'The quality is poor.',
      'The contract is missing.',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What concern does the woman raise? '
        '· Đáp án: B. The timeline is too tight. '
        '· Giải thích: Người nữ nói giá ổn nhưng thời hạn hơi gấp. '
        '· Dịch: Người phụ nữ lo ngại điều gì? → Thời hạn quá gấp.',
  ),
  ToeicQuestion(
    id: 'p3-q17',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv6',
    promptEn: 'What does the man offer to do?',
    options: const [
      'Lower the price',
      'Extend the delivery date',
      'Cancel the order',
      'Send a sample',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What does the man offer to do? '
        '· Đáp án: B. Extend the delivery date '
        '· Giải thích: Người nam đề nghị gia hạn ngày giao thêm 2 tuần. '
        '· Dịch: Người đàn ông đề nghị làm gì? → Gia hạn ngày giao hàng.',
  ),
  ToeicQuestion(
    id: 'p3-q18',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv6',
    promptEn: 'What will the man send tomorrow?',
    options: const [
      'A sample product',
      'An updated contract',
      'A price list',
      'A meeting invitation',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What will the man send tomorrow? '
        '· Đáp án: B. An updated contract '
        '· Giải thích: Người nam hứa gửi hợp đồng cập nhật vào sáng mai. '
        '· Dịch: Người đàn ông sẽ gửi gì vào ngày mai? → Bản hợp đồng cập '
        'nhật.',
  ),

  // --- Hoi thoai 7: dat ve may bay hoi nghi ---
  ToeicQuestion(
    id: 'p3-q19',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv7',
    promptEn: 'What are the speakers talking about?',
    options: const [
      'A product launch',
      'An upcoming conference',
      'A job opening',
      'A company merger',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What are the speakers talking about? '
        '· Đáp án: B. An upcoming conference '
        '· Giải thích: Người nam hỏi về hội nghị ở Chicago tháng tới. '
        '· Dịch: Hai người đang nói về điều gì? → Một hội nghị sắp tới.',
  ),
  ToeicQuestion(
    id: 'p3-q20',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv7',
    promptEn: 'What has the woman not done yet?',
    options: const [
      'Registered for the conference',
      'Booked a flight',
      'Packed her bags',
      'Reserved a hotel',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What has the woman not done yet? '
        '· Đáp án: B. Booked a flight '
        '· Giải thích: Người nữ nói chưa đặt vé máy bay. '
        '· Dịch: Người phụ nữ chưa làm gì? → Đặt vé máy bay.',
  ),
  ToeicQuestion(
    id: 'p3-q21',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv7',
    promptEn: 'What does the man recommend?',
    options: const [
      'Booking soon',
      'Waiting for a discount',
      'Traveling by train',
      'Canceling the trip',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: What does the man recommend? '
        '· Đáp án: A. Booking soon '
        '· Giải thích: Người nam khuyên nên đặt vé sớm vì giá sắp tăng. '
        '· Dịch: Người đàn ông khuyên gì? → Nên đặt vé sớm.',
  ),

  // --- Hoi thoai 8: nhan phong khach san ---
  ToeicQuestion(
    id: 'p3-q22',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv8',
    promptEn: 'What problem does the woman report?',
    options: const [
      'Her room is too noisy.',
      'Her key card doesn\'t work.',
      'Her reservation was lost.',
      'Her room is not ready.',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What problem does the woman report? '
        '· Đáp án: B. Her key card doesn\'t work. '
        '· Giải thích: Người nữ nói thẻ phòng không hoạt động. '
        '· Dịch: Người phụ nữ báo vấn đề gì? → Thẻ phòng của cô không hoạt '
        'động.',
  ),
  ToeicQuestion(
    id: 'p3-q23',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv8',
    promptEn: 'What will the man do?',
    options: const [
      'Upgrade her room',
      'Reprogram a new key',
      'Call security',
      'Offer a refund',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What will the man do? '
        '· Đáp án: B. Reprogram a new key '
        '· Giải thích: Nhân viên lễ tân nói sẽ làm lại thẻ mới ngay. '
        '· Dịch: Người đàn ông sẽ làm gì? → Làm lại thẻ phòng mới.',
  ),
  ToeicQuestion(
    id: 'p3-q24',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv8',
    promptEn: 'What does the woman ask about?',
    options: const [
      'Breakfast hours',
      'The pool\'s opening hours',
      'Parking availability',
      'Room service',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What does the woman ask about? '
        '· Đáp án: B. The pool\'s opening hours '
        '· Giải thích: Người nữ hỏi hồ bơi còn mở giờ này không. '
        '· Dịch: Người phụ nữ hỏi về điều gì? → Giờ mở cửa hồ bơi.',
  ),

  // --- Hoi thoai 9: giao hang tre ---
  ToeicQuestion(
    id: 'p3-q25',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv9',
    promptEn: 'What is the man concerned about?',
    options: const [
      'A missing invoice',
      'A late shipment',
      'A damaged product',
      'A canceled order',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What is the man concerned about? '
        '· Đáp án: B. A late shipment '
        '· Giải thích: Người nam lo lắng vì lô hàng chưa tới dù đã đến hạn '
        'hôm qua. '
        '· Dịch: Người đàn ông lo lắng về điều gì? → Một lô hàng bị giao '
        'trễ.',
  ),
  ToeicQuestion(
    id: 'p3-q26',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv9',
    promptEn: 'Why was the shipment delayed?',
    options: const [
      'Bad weather',
      'A customs delay',
      'A labor strike',
      'A vehicle breakdown',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Why was the shipment delayed? '
        '· Đáp án: B. A customs delay '
        '· Giải thích: Người nữ nói nhà cung cấp báo bị chậm do hải quan. '
        '· Dịch: Vì sao lô hàng bị chậm? → Do chậm trễ ở hải quan.',
  ),
  ToeicQuestion(
    id: 'p3-q27',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv9',
    promptEn: 'What will the woman do next?',
    options: const [
      'Contact the supplier again',
      'Cancel the shipment',
      'Inform the production manager',
      'Request a refund',
    ],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: What will the woman do next? '
        '· Đáp án: C. Inform the production manager '
        '· Giải thích: Người nữ nói sẽ báo cho quản lý sản xuất để điều '
        'chỉnh kế hoạch. '
        '· Dịch: Người phụ nữ sẽ làm gì tiếp theo? → Báo cho quản lý sản '
        'xuất.',
  ),

  // --- Hoi thoai 10: doi lich hen bac si ---
  ToeicQuestion(
    id: 'p3-q28',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv10',
    promptEn: 'Why does the woman call?',
    options: const [
      'To cancel an appointment',
      'To reschedule an appointment',
      'To ask about test results',
      'To request a prescription',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Why does the woman call? '
        '· Đáp án: B. To reschedule an appointment '
        '· Giải thích: Người nữ nói cần đổi lịch hẹn với bác sĩ Osei. '
        '· Dịch: Vì sao người phụ nữ gọi điện? → Để đổi lịch hẹn.',
  ),
  ToeicQuestion(
    id: 'p3-q29',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv10',
    promptEn: 'Why does she need to reschedule?',
    options: const [
      'She is feeling better.',
      'Something came up at work.',
      'The clinic is closed.',
      'She is traveling.',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Why does she need to reschedule? '
        '· Đáp án: B. Something came up at work. '
        '· Giải thích: Người nữ nói có việc phát sinh ở công ty. '
        '· Dịch: Vì sao cô ấy cần đổi lịch? → Có việc phát sinh ở chỗ làm.',
  ),
  ToeicQuestion(
    id: 'p3-q30',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv10',
    promptEn: 'What day is the new appointment?',
    options: const ['Wednesday', 'Thursday', 'Friday', 'Monday'],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: What day is the new appointment? '
        '· Đáp án: C. Friday '
        '· Giải thích: Người nữ chọn khung giờ 10 giờ thứ Sáu. '
        '· Dịch: Lịch hẹn mới vào ngày nào? → Thứ Sáu.',
  ),

  // --- Hoi thoai 11: ho tro IT ---
  ToeicQuestion(
    id: 'p3-q31',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv11',
    promptEn: 'What is the woman\'s problem?',
    options: const [
      'Her computer won\'t turn on.',
      'Her computer can\'t connect to the network.',
      'Her password doesn\'t work.',
      'Her screen is broken.',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What is the woman\'s problem? '
        '· Đáp án: B. Her computer can\'t connect to the network. '
        '· Giải thích: Người nữ nói máy tính không kết nối được mạng công '
        'ty. '
        '· Dịch: Vấn đề của người phụ nữ là gì? → Máy tính không kết nối '
        'được mạng.',
  ),
  ToeicQuestion(
    id: 'p3-q32',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv11',
    promptEn: 'What does the man suggest doing first?',
    options: const [
      'Restarting the computer',
      'Restarting the router',
      'Calling a technician',
      'Updating the software',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What does the man suggest doing first? '
        '· Đáp án: B. Restarting the router '
        '· Giải thích: Nhân viên IT đề nghị khởi động lại router trước. '
        '· Dịch: Người đàn ông đề nghị làm gì trước? → Khởi động lại router.',
  ),
  ToeicQuestion(
    id: 'p3-q33',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv11',
    promptEn: 'What happens at the end of the conversation?',
    options: const [
      'The problem is fixed.',
      'A technician is scheduled to visit.',
      'The woman gives up.',
      'The call is transferred.',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: What happens at the end of the conversation? '
        '· Đáp án: A. The problem is fixed. '
        '· Giải thích: Người nữ xác nhận máy đã kết nối lại được. '
        '· Dịch: Điều gì xảy ra cuối đoạn hội thoại? → Vấn đề đã được khắc '
        'phục.',
  ),

  // --- Hoi thoai 12: cat giam ngan sach ---
  ToeicQuestion(
    id: 'p3-q34',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv12',
    promptEn: 'What are the speakers discussing?',
    options: const [
      'Hiring new staff',
      'Cutting the department budget',
      'Launching a new product',
      'Planning a company trip',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What are the speakers discussing? '
        '· Đáp án: B. Cutting the department budget '
        '· Giải thích: Người nữ mở đầu nói cần cắt giảm 10% ngân sách. '
        '· Dịch: Hai người đang bàn về điều gì? → Cắt giảm ngân sách phòng '
        'ban.',
  ),
  ToeicQuestion(
    id: 'p3-q35',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv12',
    promptEn: 'What does the man suggest reducing?',
    options: const [
      'Staff salaries',
      'Travel expenses and a software upgrade',
      'Office supplies',
      'Marketing spending',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What does the man suggest reducing? '
        '· Đáp án: B. Travel expenses and a software upgrade '
        '· Giải thích: Người nam đề xuất giảm chi phí đi lại và hoãn nâng '
        'cấp phần mềm. '
        '· Dịch: Người đàn ông đề nghị giảm gì? → Chi phí đi lại và việc '
        'nâng cấp phần mềm.',
  ),
  ToeicQuestion(
    id: 'p3-q36',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv12',
    promptEn: 'What will the man do by Friday?',
    options: const [
      'Hire a consultant',
      'Prepare a revised budget',
      'Meet with the CEO',
      'Cancel the software contract',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What will the man do by Friday? '
        '· Đáp án: B. Prepare a revised budget '
        '· Giải thích: Người nam đồng ý chuẩn bị bản ngân sách sửa đổi vào '
        'thứ Sáu. '
        '· Dịch: Người đàn ông sẽ làm gì trước thứ Sáu? → Chuẩn bị bản ngân '
        'sách sửa đổi.',
  ),

  // --- Hoi thoai 13: doi chuyen bay ---
  ToeicQuestion(
    id: 'p3-q37',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv13',
    promptEn: 'What is the man\'s problem?',
    options: const [
      'His luggage is lost.',
      'His flight was canceled.',
      'His seat was given away.',
      'His passport expired.',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What is the man\'s problem? '
        '· Đáp án: B. His flight was canceled. '
        '· Giải thích: Người nam nói chuyến bay đi Boston vừa bị huỷ. '
        '· Dịch: Vấn đề của người đàn ông là gì? → Chuyến bay của anh bị '
        'huỷ.',
  ),
  ToeicQuestion(
    id: 'p3-q38',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv13',
    promptEn: 'When does the next available flight leave?',
    options: const [
      'In one hour',
      'In two hours',
      'Tomorrow morning',
      'Tonight',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: When does the next available flight leave? '
        '· Đáp án: B. In two hours '
        '· Giải thích: Nhân viên nói còn chuyến bay khác cất cánh sau 2 '
        'giờ nữa. '
        '· Dịch: Chuyến bay tiếp theo cất cánh khi nào? → Sau hai giờ nữa.',
  ),
  ToeicQuestion(
    id: 'p3-q39',
    part: ToeicPartNumber.p3,
    audioScriptId: 'p3-conv13',
    promptEn: 'What does the man ask about?',
    options: const [
      'Keeping the same seat number',
      'Getting a refund',
      'Upgrading to first class',
      'Checking extra luggage',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: What does the man ask about? '
        '· Đáp án: A. Keeping the same seat number '
        '· Giải thích: Người nam hỏi có giữ được số ghế cũ không. '
        '· Dịch: Người đàn ông hỏi về điều gì? → Việc giữ nguyên số ghế cũ.',
  ),
];

// ============================================================================
// PART 4 - Talks (10 bai noi x 3 cau = 30 cau). Moi bai la 1 nguoi noi
// (speakerIndex 0 - giong narrator).
// ============================================================================

final _part4Scripts = <ToeicAudioScript>[
  const ToeicAudioScript(
    id: 'p4-talk1',
    lines: [
      ToeicAudioLine(
        speakerIndex: 0,
        textEn:
            'Attention shoppers, for the next thirty minutes only, all '
            'kitchen appliances are twenty percent off in aisle five. '
            'This offer applies to blenders, toasters, and coffee makers. '
            'Please see a staff member if you have any questions.',
      ),
    ],
  ),
  const ToeicAudioScript(
    id: 'p4-talk2',
    lines: [
      ToeicAudioLine(
        speakerIndex: 0,
        textEn:
            'Good morning, listeners. Today will be mostly sunny with a '
            'high of twenty-four degrees. However, we expect scattered '
            'showers after six this evening, so drivers should be careful '
            'on their way home from work.',
      ),
    ],
  ),
  const ToeicAudioScript(
    id: 'p4-talk3',
    lines: [
      ToeicAudioLine(
        speakerIndex: 0,
        textEn:
            'Hi, this is Carla from Bright Path Dental calling to confirm '
            'your appointment tomorrow at two o\'clock. If you need to '
            'reschedule, please call our office before nine tomorrow '
            'morning. We look forward to seeing you.',
      ),
    ],
  ),
  const ToeicAudioScript(
    id: 'p4-talk4',
    lines: [
      ToeicAudioLine(
        speakerIndex: 0,
        textEn:
            'Welcome to Hillcrest Botanical Garden. Our guided tour will '
            'begin in ten minutes at the main fountain. Please remember '
            'that photography is allowed everywhere except inside the '
            'orchid greenhouse.',
      ),
    ],
  ),
  const ToeicAudioScript(
    id: 'p4-talk5',
    lines: [
      ToeicAudioLine(
        speakerIndex: 0,
        textEn:
            'Good afternoon, everyone. Before we end today\'s meeting, I '
            'want to remind you that the new expense reporting system '
            'goes live on Monday. Training sessions will be held Thursday '
            'and Friday in the main conference room.',
      ),
    ],
  ),
  const ToeicAudioScript(
    id: 'p4-talk6',
    lines: [
      ToeicAudioLine(
        speakerIndex: 0,
        textEn:
            'Looking for a reliable car at an affordable price? Visit '
            'Redwood Motors this weekend for our biggest sale of the '
            'year. Every vehicle on the lot comes with a free two-year '
            'maintenance package.',
      ),
    ],
  ),
  const ToeicAudioScript(
    id: 'p4-talk7',
    lines: [
      ToeicAudioLine(
        speakerIndex: 0,
        textEn:
            'May I have your attention, please. Flight two-eight-two to '
            'Denver has been delayed by forty-five minutes due to '
            'weather conditions. We apologize for the inconvenience and '
            'will provide updates as they become available.',
      ),
    ],
  ),
  const ToeicAudioScript(
    id: 'p4-talk8',
    lines: [
      ToeicAudioLine(
        speakerIndex: 0,
        textEn:
            'Welcome to the modern art wing. The painting in front of you '
            'was completed in nineteen sixty-two and remains one of the '
            'artist\'s most celebrated works. Press the green button for '
            'more information in your language.',
      ),
    ],
  ),
  const ToeicAudioScript(
    id: 'p4-talk9',
    lines: [
      ToeicAudioLine(
        speakerIndex: 0,
        textEn:
            'Welcome to your first day at Larkspur Media. This morning, '
            'you\'ll meet your team and set up your workstation. After '
            'lunch, we\'ll cover our safety policies and give you a tour '
            'of the building.',
      ),
    ],
  ),
  const ToeicAudioScript(
    id: 'p4-talk10',
    lines: [
      ToeicAudioLine(
        speakerIndex: 0,
        textEn:
            'This is an important notice for owners of the CM-4 electric '
            'kettle. Due to a wiring defect, customers are asked to stop '
            'using the product immediately and contact our support line '
            'for a full refund.',
      ),
    ],
  ),
];

final _part4Questions = <ToeicQuestion>[
  // --- Bai noi 1: khuyen mai sieu thi ---
  ToeicQuestion(
    id: 'p4-q40',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk1',
    promptEn: 'Where is this announcement most likely being made?',
    options: const [
      'In a restaurant',
      'In a supermarket',
      'In a bank',
      'In a hotel',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Where is this announcement most likely being made? '
        '· Đáp án: B. In a supermarket '
        '· Giải thích: Thông báo nhắc "aisle five" (dãy kệ số 5) và đồ gia '
        'dụng nhà bếp - đặc trưng của siêu thị. '
        '· Dịch: Thông báo này có khả năng được phát ở đâu? → Trong siêu '
        'thị.',
  ),
  ToeicQuestion(
    id: 'p4-q41',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk1',
    promptEn: 'How long will the sale last?',
    options: const ['Ten minutes', 'Thirty minutes', 'One hour', 'All day'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: How long will the sale last? '
        '· Đáp án: B. Thirty minutes '
        '· Giải thích: Thông báo nói rõ ưu đãi chỉ trong 30 phút tới. '
        '· Dịch: Chương trình giảm giá kéo dài bao lâu? → Ba mươi phút.',
  ),
  ToeicQuestion(
    id: 'p4-q42',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk1',
    promptEn: 'What should customers do if they have questions?',
    options: const [
      'Call customer service',
      'Speak to a staff member',
      'Visit the website',
      'Check the receipt',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What should customers do if they have questions? '
        '· Đáp án: B. Speak to a staff member '
        '· Giải thích: Thông báo nói "please see a staff member". '
        '· Dịch: Khách hàng nên làm gì nếu có thắc mắc? → Hỏi nhân viên.',
  ),

  // --- Bai noi 2: du bao thoi tiet ---
  ToeicQuestion(
    id: 'p4-q43',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk2',
    promptEn: 'What is the weather like this morning?',
    options: const ['Rainy', 'Mostly sunny', 'Snowy', 'Foggy'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What is the weather like this morning? '
        '· Đáp án: B. Mostly sunny '
        '· Giải thích: Bản tin nói hôm nay chủ yếu nắng. '
        '· Dịch: Thời tiết sáng nay thế nào? → Chủ yếu nắng.',
  ),
  ToeicQuestion(
    id: 'p4-q44',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk2',
    promptEn: 'When is rain expected?',
    options: const [
      'This morning',
      'At noon',
      'After six in the evening',
      'Tomorrow',
    ],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: When is rain expected? '
        '· Đáp án: C. After six in the evening '
        '· Giải thích: Bản tin dự báo mưa rải rác sau 6 giờ tối. '
        '· Dịch: Mưa được dự báo vào lúc nào? → Sau sáu giờ tối.',
  ),
  ToeicQuestion(
    id: 'p4-q45',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk2',
    promptEn: 'Who is this announcement likely for?',
    options: const ['Farmers', 'Drivers', 'Students', 'Pilots'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Who is this announcement likely for? '
        '· Đáp án: B. Drivers '
        '· Giải thích: Bản tin nhắc tài xế cẩn thận khi lái xe về nhà. '
        '· Dịch: Thông báo này có khả năng dành cho ai? → Người lái xe.',
  ),

  // --- Bai noi 3: nhac lich hen nha khoa ---
  ToeicQuestion(
    id: 'p4-q46',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk3',
    promptEn: 'Why is Carla calling?',
    options: const [
      'To cancel an appointment',
      'To confirm an appointment',
      'To request payment',
      'To offer a discount',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Why is Carla calling? '
        '· Đáp án: B. To confirm an appointment '
        '· Giải thích: Carla gọi để xác nhận lịch hẹn ngày mai lúc 2 giờ. '
        '· Dịch: Vì sao Carla gọi điện? → Để xác nhận lịch hẹn.',
  ),
  ToeicQuestion(
    id: 'p4-q47',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk3',
    promptEn: 'What time is the appointment?',
    options: const ['Nine o\'clock', 'Noon', 'Two o\'clock', 'Four o\'clock'],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: What time is the appointment? '
        '· Đáp án: C. Two o\'clock '
        '· Giải thích: Tin nhắn nói rõ lịch hẹn vào 2 giờ chiều mai. '
        '· Dịch: Lịch hẹn vào lúc mấy giờ? → Hai giờ.',
  ),
  ToeicQuestion(
    id: 'p4-q48',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk3',
    promptEn: 'What should the listener do to reschedule?',
    options: const [
      'Reply by text',
      'Call before nine tomorrow morning',
      'Visit the office in person',
      'Send an email',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What should the listener do to reschedule? '
        '· Đáp án: B. Call before nine tomorrow morning '
        '· Giải thích: Tin nhắn yêu cầu gọi lại trước 9 giờ sáng mai nếu '
        'cần đổi lịch. '
        '· Dịch: Người nghe nên làm gì để đổi lịch? → Gọi điện trước 9 giờ '
        'sáng mai.',
  ),

  // --- Bai noi 4: huong dan tham quan vuon thuc vat ---
  ToeicQuestion(
    id: 'p4-q49',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk4',
    promptEn: 'Where does this announcement take place?',
    options: const ['A museum', 'A botanical garden', 'A zoo', 'A theater'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Where does this announcement take place? '
        '· Đáp án: B. A botanical garden '
        '· Giải thích: Thông báo chào mừng tới Hillcrest Botanical Garden. '
        '· Dịch: Thông báo này diễn ra ở đâu? → Một vườn thực vật.',
  ),
  ToeicQuestion(
    id: 'p4-q50',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk4',
    promptEn: 'When will the tour begin?',
    options: const ['Immediately', 'In ten minutes', 'In one hour', 'Tomorrow'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: When will the tour begin? '
        '· Đáp án: B. In ten minutes '
        '· Giải thích: Thông báo nói tour bắt đầu sau 10 phút nữa. '
        '· Dịch: Tour tham quan sẽ bắt đầu khi nào? → Sau mười phút.',
  ),
  ToeicQuestion(
    id: 'p4-q51',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk4',
    promptEn: 'Where is photography not allowed?',
    options: const [
      'Near the fountain',
      'Inside the orchid greenhouse',
      'In the parking lot',
      'At the entrance',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Where is photography not allowed? '
        '· Đáp án: B. Inside the orchid greenhouse '
        '· Giải thích: Thông báo nói chụp ảnh được phép ở mọi nơi trừ nhà '
        'kính lan. '
        '· Dịch: Ở đâu không được phép chụp ảnh? → Bên trong nhà kính lan.',
  ),

  // --- Bai noi 5: hop toan cong ty ---
  ToeicQuestion(
    id: 'p4-q52',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk5',
    promptEn: 'What is being introduced on Monday?',
    options: const [
      'A new office location',
      'A new expense reporting system',
      'A new manager',
      'A new holiday schedule',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What is being introduced on Monday? '
        '· Đáp án: B. A new expense reporting system '
        '· Giải thích: Người nói nhắc hệ thống báo cáo chi phí mới sẽ chạy '
        'từ thứ Hai. '
        '· Dịch: Điều gì sẽ được áp dụng vào thứ Hai? → Một hệ thống báo cáo '
        'chi phí mới.',
  ),
  ToeicQuestion(
    id: 'p4-q53',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk5',
    promptEn: 'When will training sessions be held?',
    options: const [
      'Monday and Tuesday',
      'Wednesday only',
      'Thursday and Friday',
      'Next month',
    ],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: When will training sessions be held? '
        '· Đáp án: C. Thursday and Friday '
        '· Giải thích: Người nói nêu rõ buổi đào tạo diễn ra thứ Năm và thứ '
        'Sáu. '
        '· Dịch: Buổi đào tạo diễn ra khi nào? → Thứ Năm và thứ Sáu.',
  ),
  ToeicQuestion(
    id: 'p4-q54',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk5',
    promptEn: 'Where will the training take place?',
    options: const [
      'In the main conference room',
      'At an outside venue',
      'Online',
      'In the cafeteria',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: Where will the training take place? '
        '· Đáp án: A. In the main conference room '
        '· Giải thích: Người nói nói rõ địa điểm là phòng họp chính. '
        '· Dịch: Buổi đào tạo diễn ra ở đâu? → Ở phòng họp chính.',
  ),

  // --- Bai noi 6: quang cao xe hoi ---
  ToeicQuestion(
    id: 'p4-q55',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk6',
    promptEn: 'What is being advertised?',
    options: const [
      'A car dealership',
      'A repair shop',
      'A car rental service',
      'An insurance company',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: What is being advertised? '
        '· Đáp án: A. A car dealership '
        '· Giải thích: Quảng cáo mời tới Redwood Motors mua xe. '
        '· Dịch: Quảng cáo này về gì? → Một đại lý xe hơi.',
  ),
  ToeicQuestion(
    id: 'p4-q56',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk6',
    promptEn: 'What comes free with every vehicle?',
    options: const [
      'A full tank of gas',
      'A two-year maintenance package',
      'Free insurance',
      'A set of new tires',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What comes free with every vehicle? '
        '· Đáp án: B. A two-year maintenance package '
        '· Giải thích: Quảng cáo nói mỗi xe đi kèm gói bảo dưỡng 2 năm miễn '
        'phí. '
        '· Dịch: Mỗi xe được tặng kèm gì? → Gói bảo dưỡng hai năm miễn phí.',
  ),
  ToeicQuestion(
    id: 'p4-q57',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk6',
    promptEn: 'When is the sale happening?',
    options: const [
      'This weekend',
      'Next month',
      'Every day',
      'Only on Monday',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: When is the sale happening? '
        '· Đáp án: A. This weekend '
        '· Giải thích: Quảng cáo mời khách ghé cuối tuần này. '
        '· Dịch: Chương trình giảm giá diễn ra khi nào? → Cuối tuần này.',
  ),

  // --- Bai noi 7: thong bao san bay ---
  ToeicQuestion(
    id: 'p4-q58',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk7',
    promptEn: 'What is the announcement about?',
    options: const [
      'A canceled flight',
      'A delayed flight',
      'A gate change',
      'A lost bag',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What is the announcement about? '
        '· Đáp án: B. A delayed flight '
        '· Giải thích: Thông báo nói chuyến bay 282 bị hoãn 45 phút. '
        '· Dịch: Thông báo này về điều gì? → Một chuyến bay bị hoãn.',
  ),
  ToeicQuestion(
    id: 'p4-q59',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk7',
    promptEn: 'Why was the flight affected?',
    options: const [
      'Mechanical issues',
      'Weather conditions',
      'Staff shortage',
      'A security check',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Why was the flight affected? '
        '· Đáp án: B. Weather conditions '
        '· Giải thích: Thông báo nêu lý do là điều kiện thời tiết. '
        '· Dịch: Vì sao chuyến bay bị ảnh hưởng? → Do điều kiện thời tiết.',
  ),
  ToeicQuestion(
    id: 'p4-q60',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk7',
    promptEn: 'How long is the delay?',
    options: const [
      'Fifteen minutes',
      'Thirty minutes',
      'Forty-five minutes',
      'Two hours',
    ],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: How long is the delay? '
        '· Đáp án: C. Forty-five minutes '
        '· Giải thích: Thông báo nói rõ trễ 45 phút. '
        '· Dịch: Chuyến bay bị trễ bao lâu? → Bốn mươi lăm phút.',
  ),

  // --- Bai noi 8: huong dan bao tang ---
  ToeicQuestion(
    id: 'p4-q61',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk8',
    promptEn: 'Where would this talk most likely be heard?',
    options: const ['A museum', 'A library', 'A concert hall', 'A classroom'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: Where would this talk most likely be heard? '
        '· Đáp án: A. A museum '
        '· Giải thích: Bài nói giới thiệu tranh trong khu nghệ thuật hiện '
        'đại - đặc trưng bảo tàng. '
        '· Dịch: Bài nói này có khả năng được nghe ở đâu? → Trong bảo tàng.',
  ),
  ToeicQuestion(
    id: 'p4-q62',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk8',
    promptEn: 'When was the painting completed?',
    options: const ['1952', '1962', '1972', '1982'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: When was the painting completed? '
        '· Đáp án: B. 1962 '
        '· Giải thích: Bài nói nói bức tranh hoàn thành năm 1962. '
        '· Dịch: Bức tranh được hoàn thành năm nào? → Năm 1962.',
  ),
  ToeicQuestion(
    id: 'p4-q63',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk8',
    promptEn: 'What should visitors do for more information?',
    options: const [
      'Ask a guide',
      'Press the green button',
      'Scan a code',
      'Read a pamphlet',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What should visitors do for more information? '
        '· Đáp án: B. Press the green button '
        '· Giải thích: Bài nói hướng dẫn bấm nút xanh để nghe thêm thông tin. '
        '· Dịch: Khách tham quan nên làm gì để biết thêm thông tin? → Bấm '
        'nút màu xanh lá.',
  ),

  // --- Bai noi 9: dinh huong nhan vien moi ---
  ToeicQuestion(
    id: 'p4-q64',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk9',
    promptEn: 'Who is this talk intended for?',
    options: const [
      'New employees',
      'Job applicants',
      'Retiring staff',
      'Visiting clients',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: Who is this talk intended for? '
        '· Đáp án: A. New employees '
        '· Giải thích: Bài nói chào mừng "your first day at Larkspur '
        'Media" - dành cho nhân viên mới. '
        '· Dịch: Bài nói này dành cho ai? → Nhân viên mới.',
  ),
  ToeicQuestion(
    id: 'p4-q65',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk9',
    promptEn: 'What will happen this morning?',
    options: const [
      'A safety training',
      'Meeting the team and setting up a workstation',
      'A building tour',
      'A performance review',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What will happen this morning? '
        '· Đáp án: B. Meeting the team and setting up a workstation '
        '· Giải thích: Bài nói nói sáng nay sẽ gặp đội nhóm và setup chỗ '
        'làm việc. '
        '· Dịch: Điều gì sẽ diễn ra vào sáng nay? → Gặp gỡ đội nhóm và setup '
        'chỗ làm việc.',
  ),
  ToeicQuestion(
    id: 'p4-q66',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk9',
    promptEn: 'What will happen after lunch?',
    options: const [
      'A safety policy briefing and building tour',
      'A team lunch outing',
      'A performance review',
      'A client meeting',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: What will happen after lunch? '
        '· Đáp án: A. A safety policy briefing and building tour '
        '· Giải thích: Bài nói nói sau bữa trưa sẽ học chính sách an toàn '
        'và tham quan toà nhà. '
        '· Dịch: Điều gì sẽ diễn ra sau bữa trưa? → Học chính sách an toàn '
        'và tham quan toà nhà.',
  ),

  // --- Bai noi 10: thu hoi san pham ---
  ToeicQuestion(
    id: 'p4-q67',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk10',
    promptEn: 'What is the purpose of this notice?',
    options: const [
      'To advertise a new product',
      'To announce a product recall',
      'To announce a price increase',
      'To thank customers',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What is the purpose of this notice? '
        '· Đáp án: B. To announce a product recall '
        '· Giải thích: Thông báo yêu cầu ngừng dùng ấm điện do lỗi dây dẫn - '
        'đây là thông báo thu hồi sản phẩm. '
        '· Dịch: Mục đích của thông báo này là gì? → Để thông báo thu hồi '
        'sản phẩm.',
  ),
  ToeicQuestion(
    id: 'p4-q68',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk10',
    promptEn: 'What is the defect with the product?',
    options: const [
      'A wiring defect',
      'A cracked lid',
      'A weak handle',
      'A leaking base',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: What is the defect with the product? '
        '· Đáp án: A. A wiring defect '
        '· Giải thích: Thông báo nêu rõ lỗi dây điện. '
        '· Dịch: Lỗi của sản phẩm là gì? → Lỗi dây điện.',
  ),
  ToeicQuestion(
    id: 'p4-q69',
    part: ToeicPartNumber.p4,
    audioScriptId: 'p4-talk10',
    promptEn: 'What should customers do?',
    options: const [
      'Continue using it carefully',
      'Stop using it and contact support',
      'Return it to any store',
      'Wait for a replacement part',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What should customers do? '
        '· Đáp án: B. Stop using it and contact support '
        '· Giải thích: Thông báo yêu cầu ngừng sử dụng ngay và liên hệ '
        'đường dây hỗ trợ để được hoàn tiền. '
        '· Dịch: Khách hàng nên làm gì? → Ngừng sử dụng và liên hệ bộ phận '
        'hỗ trợ.',
  ),
];

// ============================================================================
// PART 5 - Incomplete Sentences (30 cau ngu phap/tu vung).
// ============================================================================

final _part5Questions = <ToeicQuestion>[
  ToeicQuestion(
    id: 'p5-q101',
    part: ToeicPartNumber.p5,
    promptEn:
        'The marketing team must submit the campaign proposal ------- '
        'Friday afternoon.',
    options: const ['by', 'since', 'during', 'among'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: The marketing team must submit the campaign proposal '
        '------- Friday afternoon. '
        '· Đáp án: A. by '
        '· Giải thích: "By + thời điểm" nghĩa là "trước hoặc đến hạn đó" - '
        'phù hợp với deadline nộp bài. "Since" cần mốc bắt đầu, "during"/'
        '"among" không đi với 1 thời điểm cụ thể như vậy. '
        '· Dịch: Đội marketing phải nộp đề xuất chiến dịch trước chiều thứ Sáu.',
  ),
  ToeicQuestion(
    id: 'p5-q102',
    part: ToeicPartNumber.p5,
    promptEn:
        'All employees are required to keep their ------- information up '
        'to date in the HR system.',
    options: const ['personal', 'personally', 'personalize', 'personality'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: ...keep their ------- information up to date... '
        '· Đáp án: A. personal '
        '· Giải thích: Trước danh từ "information" cần 1 tính từ bổ nghĩa - '
        '"personal" (cá nhân) là tính từ phù hợp. '
        '· Dịch: Mọi nhân viên phải cập nhật thông tin cá nhân trong hệ thống '
        'nhân sự.',
  ),
  ToeicQuestion(
    id: 'p5-q103',
    part: ToeicPartNumber.p5,
    promptEn:
        'The report ------- by the finance department last week contained '
        'several errors.',
    options: const ['prepare', 'preparing', 'prepared', 'to prepare'],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: The report ------- by the finance department last week... '
        '· Đáp án: C. prepared '
        '· Giải thích: Đây là mệnh đề quan hệ rút gọn dạng bị động (the report '
        'which was prepared) - dùng V3/ed "prepared" bổ nghĩa cho "report". '
        '· Dịch: Bản báo cáo do phòng tài chính chuẩn bị tuần trước có vài lỗi.',
  ),
  ToeicQuestion(
    id: 'p5-q104',
    part: ToeicPartNumber.p5,
    promptEn:
        '------- to the warehouse, please check the inventory list first.',
    options: const ['Go', 'Going', 'Gone', 'Goes'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: ------- to the warehouse, please check the inventory '
        'list first. '
        '· Đáp án: A. Go '
        '· Giải thích: Câu mệnh lệnh đầu câu cần động từ nguyên mẫu không '
        '"to" (V-bare). '
        '· Dịch: Trước khi đến kho, hãy kiểm tra danh sách hàng tồn trước.',
  ),
  ToeicQuestion(
    id: 'p5-q105',
    part: ToeicPartNumber.p5,
    promptEn:
        'Customers who arrive early may experience a slight ------- before '
        'the store opens.',
    options: const ['delay', 'delayed', 'delaying', 'to delay'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: ...may experience a slight ------- before the store '
        'opens. '
        '· Đáp án: A. delay '
        '· Giải thích: Sau tính từ "slight" cần 1 danh từ - "delay" (sự chậm '
        'trễ) là danh từ phù hợp. '
        '· Dịch: Khách đến sớm có thể gặp chút chậm trễ trước khi cửa hàng mở.',
  ),
  ToeicQuestion(
    id: 'p5-q106',
    part: ToeicPartNumber.p5,
    promptEn: '------- department is responsible for its own budget this year.',
    options: const ['Each', 'All', 'Several', 'Many'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: ------- department is responsible for its own budget... '
        '· Đáp án: A. Each '
        '· Giải thích: "Department" số ít, chỉ "Each" (mỗi) đi được với danh '
        'từ số ít; All/Several/Many cần danh từ số nhiều. '
        '· Dịch: Mỗi phòng ban chịu trách nhiệm về ngân sách riêng năm nay.',
  ),
  ToeicQuestion(
    id: 'p5-q107',
    part: ToeicPartNumber.p5,
    promptEn:
        'New safety regulations require that all visitors ------- a badge '
        'at all times.',
    options: const ['wear', 'wears', 'wearing', 'to wear'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: New safety regulations require that all visitors ------- '
        'a badge at all times. '
        '· Đáp án: A. wear '
        '· Giải thích: Sau "require that" dùng dạng giả định (subjunctive) - '
        'động từ nguyên mẫu không chia, không thêm "s". '
        '· Dịch: Quy định an toàn mới yêu cầu mọi khách phải đeo thẻ mọi lúc.',
  ),
  ToeicQuestion(
    id: 'p5-q108',
    part: ToeicPartNumber.p5,
    promptEn:
        'The company wants its new headquarters ------- to environmental '
        'standards.',
    options: const ['built', 'building', 'to build', 'builds'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: The company wants its new headquarters ------- to '
        'environmental standards. '
        '· Đáp án: A. built '
        '· Giải thích: Cấu trúc "want + O + V3/ed" mang nghĩa bị động: trụ sở '
        '"được xây dựng". '
        '· Dịch: Công ty muốn trụ sở mới được xây theo tiêu chuẩn môi trường.',
  ),
  ToeicQuestion(
    id: 'p5-q109',
    part: ToeicPartNumber.p5,
    promptEn:
        'Halden Manufacturing will open two ------- factories in Southeast '
        'Asia next year.',
    options: const ['addition', 'additional', 'additionally', 'add'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: ...will open two ------- factories in Southeast Asia... '
        '· Đáp án: B. additional '
        '· Giải thích: Trước danh từ "factories" cần tính từ - "additional" '
        '(thêm) phù hợp. '
        '· Dịch: Halden Manufacturing sẽ mở thêm hai nhà máy ở Đông Nam Á năm '
        'tới.',
  ),
  ToeicQuestion(
    id: 'p5-q110',
    part: ToeicPartNumber.p5,
    promptEn:
        'The new mobile application has been downloaded ------- by users '
        'around the world.',
    options: const ['wide', 'widely', 'wider', 'widen'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: ...has been downloaded ------- by users around the '
        'world. '
        '· Đáp án: B. widely '
        '· Giải thích: Bổ nghĩa cho động từ bị động "has been downloaded" cần '
        'trạng từ - "widely" (rộng rãi). '
        '· Dịch: Ứng dụng di động mới đã được tải xuống rộng rãi bởi người '
        'dùng khắp thế giới.',
  ),
  ToeicQuestion(
    id: 'p5-q111',
    part: ToeicPartNumber.p5,
    promptEn: 'Prima Foods will expand its distribution network ------- the next five years.',
    options: const ['during', 'within', 'between', 'among'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: ...will expand its distribution network ------- the next '
        'five years. '
        '· Đáp án: B. within '
        '· Giải thích: "Within + khoảng thời gian" nghĩa "trong vòng" thời '
        'hạn đó, phù hợp mốc hoàn thành trong tương lai. '
        '· Dịch: Prima Foods sẽ mở rộng mạng lưới phân phối trong vòng năm '
        'năm tới.',
  ),
  ToeicQuestion(
    id: 'p5-q112',
    part: ToeicPartNumber.p5,
    promptEn:
        'The technician was praised for how ------- she resolved the '
        'network outage.',
    options: const ['quick', 'quickly', 'quickness', 'quicker'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: ...for how ------- she resolved the network outage. '
        '· Đáp án: B. quickly '
        '· Giải thích: Bổ nghĩa cho động từ "resolved" cần trạng từ '
        '"quickly" (nhanh chóng). '
        '· Dịch: Kỹ thuật viên được khen vì đã xử lý sự cố mạng nhanh chóng '
        'như thế nào.',
  ),
  ToeicQuestion(
    id: 'p5-q113',
    part: ToeicPartNumber.p5,
    promptEn: 'Mr. Tanaka is known for handling client complaints -------.',
    options: const ['patient', 'patience', 'patiently', 'patients'],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: Mr. Tanaka is known for handling client complaints '
        '-------. '
        '· Đáp án: C. patiently '
        '· Giải thích: Bổ nghĩa cho cụm động từ "handling" cần trạng từ - '
        '"patiently" (kiên nhẫn). '
        '· Dịch: Ông Tanaka nổi tiếng vì xử lý khiếu nại khách hàng một cách '
        'kiên nhẫn.',
  ),
  ToeicQuestion(
    id: 'p5-q114',
    part: ToeicPartNumber.p5,
    promptEn:
        'The gallery will display three paintings and two ------- next '
        'month.',
    options: const ['sculptures', 'sculptors', 'sculpting', 'sculpted'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: The gallery will display three paintings and two '
        '------- next month. '
        '· Đáp án: A. sculptures '
        '· Giải thích: Phòng tranh trưng bày "tác phẩm" - "sculptures" '
        '(tác phẩm điêu khắc) hợp ngữ cảnh hơn "sculptors" (nhà điêu khắc - '
        'chỉ người). '
        '· Dịch: Phòng tranh sẽ trưng bày ba bức tranh và hai tác phẩm điêu '
        'khắc vào tháng tới.',
  ),
  ToeicQuestion(
    id: 'p5-q115',
    part: ToeicPartNumber.p5,
    promptEn: 'The film\'s soundtrack was ------- praised by critics.',
    options: const ['high', 'highly', 'height', 'higher'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: The film\'s soundtrack was ------- praised by critics. '
        '· Đáp án: B. highly '
        '· Giải thích: Bổ nghĩa cho động từ bị động "was praised" cần trạng '
        'từ - "highly" (rất, cao độ). '
        '· Dịch: Nhạc phim được giới phê bình đánh giá rất cao.',
  ),
  ToeicQuestion(
    id: 'p5-q116',
    part: ToeicPartNumber.p5,
    promptEn: 'Meeting room supplies are available for ------- needs them.',
    options: const ['anyone', 'someone', 'no one', 'everyone else'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: Meeting room supplies are available for ------- needs '
        'them. '
        '· Đáp án: A. anyone '
        '· Giải thích: "Anyone who..." là cấu trúc chuẩn chỉ "bất kỳ ai mà". '
        '· Dịch: Vật dụng phòng họp luôn sẵn có cho bất kỳ ai cần dùng.',
  ),
  ToeicQuestion(
    id: 'p5-q117',
    part: ToeicPartNumber.p5,
    promptEn: 'Lindqvist Consulting intends to ------- its services into the healthcare sector.',
    options: const ['expand', 'expansion', 'expanding', 'expanded'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: ...intends to ------- its services into the healthcare '
        'sector. '
        '· Đáp án: A. expand '
        '· Giải thích: Sau "to" (to-infinitive) cần động từ nguyên mẫu - '
        '"expand" (mở rộng). '
        '· Dịch: Lindqvist Consulting dự định mở rộng dịch vụ sang lĩnh vực y '
        'tế.',
  ),
  ToeicQuestion(
    id: 'p5-q118',
    part: ToeicPartNumber.p5,
    promptEn:
        '------- the recent price increase, sales of the product have '
        'remained strong.',
    options: const ['Despite', 'Although', 'Because', 'Unless'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: ------- the recent price increase, sales of the '
        'product have remained strong. '
        '· Đáp án: A. Despite '
        '· Giải thích: "Despite" đứng trước cụm danh từ để chỉ sự tương '
        'phản; "Although/Because/Unless" cần 1 mệnh đề đầy đủ chủ vị. '
        '· Dịch: Mặc dù giá tăng gần đây, doanh số sản phẩm vẫn giữ vững.',
  ),
  ToeicQuestion(
    id: 'p5-q119',
    part: ToeicPartNumber.p5,
    promptEn:
        'The delivery team will be making ------- across the city on Saturday.',
    options: const ['deliveries', 'delivered', 'deliver', 'deliverable'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: The delivery team will be making ------- across the '
        'city on Saturday. '
        '· Đáp án: A. deliveries '
        '· Giải thích: Cụm cố định "make deliveries" (thực hiện giao hàng) '
        'cần danh từ số nhiều. '
        '· Dịch: Đội giao hàng sẽ thực hiện các chuyến giao hàng khắp thành '
        'phố vào thứ Bảy.',
  ),
  ToeicQuestion(
    id: 'p5-q120',
    part: ToeicPartNumber.p5,
    promptEn:
        'The IT department must ensure all laptops are running ------- '
        'software before the audit.',
    options: const ['update', 'updating', 'updated', 'updates'],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: ...ensure all laptops are running ------- software '
        'before the audit. '
        '· Đáp án: C. updated '
        '· Giải thích: "Updated software" (phần mềm đã được cập nhật) dùng '
        'phân từ quá khứ V3/ed làm tính từ. '
        '· Dịch: Phòng IT phải đảm bảo mọi laptop chạy phần mềm đã cập nhật '
        'trước đợt kiểm toán.',
  ),
  ToeicQuestion(
    id: 'p5-q121',
    part: ToeicPartNumber.p5,
    promptEn: 'Ms. Cordero was unable to decide which venue ------- for the annual gala.',
    options: const ['book', 'to book', 'booking', 'booked'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Ms. Cordero was unable to decide which venue ------- '
        'for the annual gala. '
        '· Đáp án: B. to book '
        '· Giải thích: Cấu trúc "từ nghi vấn (which venue) + to V" nghĩa '
        '"nên làm gì" - "to book" (nên đặt). '
        '· Dịch: Bà Cordero không thể quyết định nên đặt địa điểm nào cho dạ '
        'tiệc thường niên.',
  ),
  ToeicQuestion(
    id: 'p5-q122',
    part: ToeicPartNumber.p5,
    promptEn: 'The staff were ------- to learn that the office would remain open during renovations.',
    options: const ['relief', 'relieved', 'relieving', 'relieves'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: The staff were ------- to learn that the office would '
        'remain open... '
        '· Đáp án: B. relieved '
        '· Giải thích: "Be relieved" (cảm thấy nhẹ nhõm) là tính từ cảm xúc '
        'phù hợp diễn tả phản ứng của nhân viên. '
        '· Dịch: Nhân viên cảm thấy nhẹ nhõm khi biết văn phòng vẫn mở cửa '
        'trong lúc sửa chữa.',
  ),
  ToeicQuestion(
    id: 'p5-q123',
    part: ToeicPartNumber.p5,
    promptEn: 'Riverton Museum hosts free tours led by guides who ------- local history.',
    options: const ['study', 'studies', 'studying', 'to study'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: ...led by guides who ------- local history. '
        '· Đáp án: A. study '
        '· Giải thích: Đại từ quan hệ "who" thay cho "guides" (danh từ số '
        'nhiều) nên động từ chia số nhiều "study" (không thêm "s"). '
        '· Dịch: Bảo tàng Riverton tổ chức tour miễn phí do các hướng dẫn '
        'viên nghiên cứu lịch sử địa phương dẫn dắt.',
  ),
  ToeicQuestion(
    id: 'p5-q124',
    part: ToeicPartNumber.p5,
    promptEn:
        'All laptops issued by the company come with a two-year warranty '
        '------- covers accidental damage.',
    options: const ['that', 'who', 'what', 'it'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: ...a two-year warranty ------- covers accidental '
        'damage. '
        '· Đáp án: A. that '
        '· Giải thích: "That" là đại từ quan hệ thay cho danh từ chỉ vật '
        '"warranty" (bảo hành). '
        '· Dịch: Mọi laptop công ty cấp đều có bảo hành hai năm bao gồm hư '
        'hỏng do vô ý.',
  ),
  ToeicQuestion(
    id: 'p5-q125',
    part: ToeicPartNumber.p5,
    promptEn: 'The new engine was designed for both fuel efficiency ------- durability.',
    options: const ['and', 'but', 'or', 'nor'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: ...designed for both fuel efficiency ------- '
        'durability. '
        '· Đáp án: A. and '
        '· Giải thích: Cấu trúc "both A and B" là cặp liên từ cố định. '
        '· Dịch: Động cơ mới được thiết kế cho cả tiết kiệm nhiên liệu và độ '
        'bền.',
  ),
  ToeicQuestion(
    id: 'p5-q126',
    part: ToeicPartNumber.p5,
    promptEn: '------- mixed reviews, the restaurant remains fully booked most weekends.',
    options: const ['Despite', 'During', 'Over', 'About'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: ------- mixed reviews, the restaurant remains fully '
        'booked... '
        '· Đáp án: A. Despite '
        '· Giải thích: "Despite" diễn tả sự tương phản giữa đánh giá trái '
        'chiều và việc vẫn đông khách. '
        '· Dịch: Mặc dù có đánh giá trái chiều, nhà hàng vẫn kín chỗ hầu hết '
        'các cuối tuần.',
  ),
  ToeicQuestion(
    id: 'p5-q127',
    part: ToeicPartNumber.p5,
    promptEn:
        'We would love to join the workshop, but ------- we have a prior '
        'commitment that day.',
    options: const ['regrettably', 'scarcely', 'exceptionally', 'annually'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: ...but ------- we have a prior commitment that day. '
        '· Đáp án: A. regrettably '
        '· Giải thích: "Regrettably" (đáng tiếc là) phù hợp để thông báo '
        'không thể tham dự. '
        '· Dịch: Chúng tôi rất muốn tham gia buổi hội thảo, nhưng đáng tiếc '
        'là đã có việc bận vào ngày đó.',
  ),
  ToeicQuestion(
    id: 'p5-q128',
    part: ToeicPartNumber.p5,
    promptEn:
        'The updated handbook outlines the ------- procedure for reporting '
        'workplace incidents.',
    options: const ['preferring', 'preferably', 'preferred', 'preferability'],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: ...outlines the ------- procedure for reporting '
        'workplace incidents. '
        '· Đáp án: C. preferred '
        '· Giải thích: "Preferred procedure" (quy trình được ưu tiên) dùng '
        'phân từ quá khứ làm tính từ. '
        '· Dịch: Sổ tay cập nhật nêu quy trình được ưu tiên để báo cáo sự cố '
        'nơi làm việc.',
  ),
  ToeicQuestion(
    id: 'p5-q129',
    part: ToeicPartNumber.p5,
    promptEn:
        'The city council is searching for a suitable ------- to build a '
        'new public library.',
    options: const ['location', 'direction', 'occasion', 'opinion'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: ...searching for a suitable ------- to build a new '
        'public library. '
        '· Đáp án: A. location '
        '· Giải thích: Cần "location" (địa điểm) phù hợp ngữ cảnh xây thư '
        'viện. '
        '· Dịch: Hội đồng thành phố đang tìm địa điểm phù hợp để xây thư '
        'viện công cộng mới.',
  ),
  ToeicQuestion(
    id: 'p5-q130',
    part: ToeicPartNumber.p5,
    promptEn:
        'Cashiers must scan items accurately ------- answer questions from '
        'customers at the same time.',
    options: const ['as well as', 'although', 'but', 'for instance'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: ...scan items accurately ------- answer questions from '
        'customers... '
        '· Đáp án: A. as well as '
        '· Giải thích: "As well as" (cũng như) nối hai hành động song song mà '
        'nhân viên thu ngân phải làm. '
        '· Dịch: Nhân viên thu ngân phải quét hàng chính xác cũng như trả lời '
        'câu hỏi của khách hàng cùng lúc.',
  ),
];
// ============================================================================
// PART 6 - Text Completion (4 doan van x 4 cho trong = 16 cau). Cho trong
// danh so (1)-(4) ngay trong noi dung doan van.
// ============================================================================

final _part6Passages = <ToeicPassage>[
  const ToeicPassage(
    id: 'p6-passage1',
    titleEn: 'Notice',
    textsEn: [
      'Dear Resident,\n\n'
          'We are writing to inform you that Bellmore Park will (1) '
          'closed for renovations starting June 3. The city plans to add '
          'new walking trails and a children\'s playground. (2) '
          'described in the attached diagram, the renovated park will '
          'also include a small pond and additional seating areas.\n\n'
          'We expect the work to take about ten weeks, which will allow '
          'residents to enjoy the (3) space well before the summer '
          'festival. During construction, please use Fenwick Park, '
          'located two blocks north, as an alternative. (4)\n\n'
          'Thank you for your patience.\n\nCity Parks Department',
    ],
  ),
  const ToeicPassage(
    id: 'p6-passage2',
    titleEn: 'E-mail',
    textsEn: [
      'From: Priya Nandan\n'
          'To: All Staff\n'
          'Subject: Remote Work Policy Update\n\n'
          'Dear team,\n\n'
          'Starting next month, employees will be (1) to work from home '
          'up to two days per week, provided their manager approves the '
          'schedule in advance. (2), employees in customer-facing roles '
          'must remain available during standard business hours '
          'regardless of their location.\n\n'
          'If you would like to set up a regular remote schedule, please '
          'submit a request through the HR portal by Friday. (3) will be '
          'reviewed within three business days.\n\n'
          'We believe this change will improve work-life balance while '
          'keeping our teams (4) connected.\n\nBest regards,\nPriya Nandan\n'
          'Human Resources',
    ],
  ),
  const ToeicPassage(
    id: 'p6-passage3',
    titleEn: 'Product Information',
    textsEn: [
      'Thank you for purchasing AromaGlow Hand Cream!\n\n'
          'For best results, apply a small amount to clean, dry hands and '
          'massage gently (1) fully absorbed. We recommend using the '
          'product twice daily, especially after washing your hands.\n\n'
          'If you experience any irritation, please discontinue use and '
          'contact our support team. (2) our decades of experience in '
          'natural skincare, we are always happy to recommend a (3) '
          'product if this one is not right for you.\n\n'
          'If you enjoy AromaGlow Hand Cream, please consider leaving a '
          'review on our website. (4)\n\n'
          'We can be reached at support@auroraskincare.example any time.',
    ],
  ),
  const ToeicPassage(
    id: 'p6-passage4',
    titleEn: 'Company Newsletter',
    textsEn: [
      'To: All Meridian Systems Employees\nRe: A Client Success Story\n\n'
          'We are pleased to share a recent success story involving our '
          'client, TechNova Logistics. TechNova used to (1) with tracking '
          'shipments manually across multiple spreadsheets, which often '
          'led to costly errors.\n\n'
          'After adopting our Meridian Tracker platform, TechNova\'s '
          'staff (2) enter shipment data once, and the system '
          'automatically updates every department in real time.\n\n'
          'TechNova\'s operations director told us, "Meridian Tracker has '
          'made our team far more efficient. (3)" Thanks to these '
          'improvements, the company (4) its investment within eight '
          'months.\n\nWe should all be proud of the value Meridian '
          'Systems provided to TechNova. Keep up the excellent work.\n\n'
          'Dana Whitfield\nChief Executive Officer',
    ],
  ),
];

final _part6Questions = <ToeicQuestion>[
  // --- Doan 1: thong bao cong vien ---
  ToeicQuestion(
    id: 'p6-q131',
    part: ToeicPartNumber.p6,
    passageId: 'p6-passage1',
    options: const ['be', 'is', 'was', 'being'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: Bellmore Park will ------- closed for renovations... '
        '· Đáp án: A. be '
        '· Giải thích: Sau "will" cần động từ nguyên mẫu ở dạng bị động - '
        '"will be closed" (sẽ bị đóng cửa). '
        '· Dịch: Công viên Bellmore sẽ đóng cửa để cải tạo.',
  ),
  ToeicQuestion(
    id: 'p6-q132',
    part: ToeicPartNumber.p6,
    passageId: 'p6-passage1',
    options: const ['Upon', 'For', 'Until', 'As'],
    correctIndex: 3,
    explanationVi:
        '· Câu hỏi: ------- described in the attached diagram, the '
        'renovated park will also include a pond. '
        '· Đáp án: D. As '
        '· Giải thích: "As described in..." (như được mô tả trong...) là '
        'cấu trúc chỉ dẫn tới tài liệu đính kèm. '
        '· Dịch: Như được mô tả trong sơ đồ đính kèm, công viên sau cải tạo '
        'sẽ có thêm một hồ nước nhỏ.',
  ),
  ToeicQuestion(
    id: 'p6-q133',
    part: ToeicPartNumber.p6,
    passageId: 'p6-passage1',
    options: const ['crowded', 'expensive', 'renovated', 'temporary'],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: ...will allow residents to enjoy the ------- space '
        'well before the summer festival. '
        '· Đáp án: C. renovated '
        '· Giải thích: Ngữ cảnh đang nói về công viên "đã được cải tạo" - '
        'phù hợp nhất với nội dung thông báo. '
        '· Dịch: ...sẽ cho phép cư dân tận hưởng không gian đã được cải tạo '
        'trước lễ hội mùa hè.',
  ),
  ToeicQuestion(
    id: 'p6-q134',
    part: ToeicPartNumber.p6,
    passageId: 'p6-passage1',
    options: const [
      'We hope you enjoyed this year\'s summer festival.',
      'The city council meets every Tuesday evening.',
      'A map of Fenwick Park is available at City Hall.',
      'Membership fees will increase next year.',
    ],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: Chọn câu phù hợp nhất để điền vào chỗ trống (4), tiếp '
        'nối gợi ý dùng công viên Fenwick thay thế. '
        '· Đáp án: C. A map of Fenwick Park is available at City Hall. '
        '· Giải thích: Câu này bổ sung thông tin hữu ích liên quan trực '
        'tiếp tới công viên thay thế vừa nhắc tới ở câu trước. '
        '· Dịch: Bản đồ công viên Fenwick có sẵn tại Toà thị chính.',
  ),

  // --- Doan 2: email chinh sach lam viec tu xa ---
  ToeicQuestion(
    id: 'p6-q135',
    part: ToeicPartNumber.p6,
    passageId: 'p6-passage2',
    options: const ['permit', 'permitted', 'permitting', 'permission'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: ...employees will be ------- to work from home up to '
        'two days per week. '
        '· Đáp án: B. permitted '
        '· Giải thích: Cấu trúc bị động "be permitted to V" (được phép làm '
        'gì) cần V3/ed. '
        '· Dịch: ...nhân viên sẽ được phép làm việc tại nhà tối đa hai ngày '
        'mỗi tuần.',
  ),
  ToeicQuestion(
    id: 'p6-q136',
    part: ToeicPartNumber.p6,
    passageId: 'p6-passage2',
    options: const ['Likewise', 'However', 'For example', 'Meanwhile'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: -------, employees in customer-facing roles must '
        'remain available during standard hours. '
        '· Đáp án: B. However '
        '· Giải thích: Câu này nêu 1 ngoại lệ/tương phản với quy định vừa '
        'nêu - "However" (tuy nhiên) phù hợp nhất. '
        '· Dịch: Tuy nhiên, nhân viên ở vị trí tiếp xúc khách hàng phải sẵn '
        'sàng trong giờ hành chính bất kể đang ở đâu.',
  ),
  ToeicQuestion(
    id: 'p6-q137',
    part: ToeicPartNumber.p6,
    passageId: 'p6-passage2',
    options: const [
      'If you would like to set up a regular remote schedule, please '
          'submit a request through the HR portal by Friday.',
      'Requests',
      'The office will be closed for a public holiday next Monday.',
      'All employees must attend the annual meeting in person.',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: ------- will be reviewed within three business days. '
        '· Đáp án: B. Requests '
        '· Giải thích: Chủ ngữ của "will be reviewed" (sẽ được xem xét) '
        'phải là "Requests" (các yêu cầu) vừa nhắc ở câu trước, không phải '
        'nguyên câu hay các lựa chọn không liên quan. '
        '· Dịch: Các yêu cầu sẽ được xem xét trong vòng ba ngày làm việc.',
  ),
  ToeicQuestion(
    id: 'p6-q138',
    part: ToeicPartNumber.p6,
    passageId: 'p6-passage2',
    options: const ['close', 'closely', 'closer', 'closeness'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: ...while keeping our teams ------- connected. '
        '· Đáp án: B. closely '
        '· Giải thích: Bổ nghĩa cho tính từ/phân từ "connected" cần trạng '
        'từ - "closely" (gắn kết chặt chẽ). '
        '· Dịch: ...trong khi vẫn giữ các đội nhóm gắn kết chặt chẽ.',
  ),

  // --- Doan 3: huong dan san pham duong da tay ---
  ToeicQuestion(
    id: 'p6-q139',
    part: ToeicPartNumber.p6,
    passageId: 'p6-passage3',
    options: const ['Keep', 'Keeping', 'To keep', 'Kept'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: ...massage gently ------- fully absorbed. '
        '· Đáp án: B. Keeping '
        '· Giải thích: Cụm phân từ đi kèm hành động chính, dùng V-ing '
        '"Keeping" (dạng phân từ hiện tại) để diễn tả tiếp diễn/kết quả. '
        '· Dịch: ...xoa nhẹ nhàng cho đến khi thấm hoàn toàn.',
  ),
  ToeicQuestion(
    id: 'p6-q140',
    part: ToeicPartNumber.p6,
    passageId: 'p6-passage3',
    options: const [
      'At present, our stores are temporarily closed.',
      'Along with returns and exchanges, we can offer helpful advice.',
      'Our best-selling item is now out of stock.',
      'We only accept returns within thirty days.',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Chọn câu phù hợp nhất cho chỗ trống (2), tiếp nối ý '
        '"decades of experience in natural skincare". '
        '· Đáp án: B. Along with returns and exchanges, we can offer '
        'helpful advice. '
        '· Giải thích: Câu này khớp mạch ý "sẵn sàng hỗ trợ/tư vấn thêm", '
        'dẫn tới câu sau về gợi ý sản phẩm khác. '
        '· Dịch: Cùng với đổi trả, chúng tôi có thể tư vấn hữu ích.',
  ),
  ToeicQuestion(
    id: 'p6-q141',
    part: ToeicPartNumber.p6,
    passageId: 'p6-passage3',
    options: const ['different', 'difference', 'differently', 'differ'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: ...happy to recommend a ------- product if this one is '
        'not right for you. '
        '· Đáp án: A. different '
        '· Giải thích: Trước danh từ "product" cần tính từ - "different" '
        '(khác). '
        '· Dịch: ...sẵn lòng giới thiệu một sản phẩm khác nếu sản phẩm này '
        'không phù hợp với bạn.',
  ),
  ToeicQuestion(
    id: 'p6-q142',
    part: ToeicPartNumber.p6,
    passageId: 'p6-passage3',
    options: const ['it', 'them', 'us', 'him'],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: ...please consider leaving a review... We can be '
        'reached at [email] any time. '
        '· Đáp án: C. us '
        '· Giải thích: Đại từ tân ngữ chỉ chính công ty đang viết thư - '
        '"us" (chúng tôi). '
        '· Dịch: Nếu bạn hài lòng, hãy để lại đánh giá cho chúng tôi.',
  ),

  // --- Doan 4: ban tin cong ty ve du an khach hang ---
  ToeicQuestion(
    id: 'p6-q143',
    part: ToeicPartNumber.p6,
    passageId: 'p6-passage4',
    options: const ['on completion', 'that complete', 'struggle', 'completed'],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: TechNova used to ------- with tracking shipments '
        'manually across multiple spreadsheets. '
        '· Đáp án: C. struggle '
        '· Giải thích: Cấu trúc "used to + V-bare" (từng gặp khó khăn với) - '
        '"struggle with" (vật lộn/gặp khó khăn với). '
        '· Dịch: TechNova từng gặp khó khăn khi theo dõi lô hàng thủ công '
        'qua nhiều bảng tính.',
  ),
  ToeicQuestion(
    id: 'p6-q144',
    part: ToeicPartNumber.p6,
    passageId: 'p6-passage4',
    options: const ['now', 'then', 'rarely', 'formerly'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: TechNova\'s staff ------- enter shipment data once, '
        'and the system automatically updates every department. '
        '· Đáp án: A. now '
        '· Giải thích: Ngữ cảnh so sánh với quá khứ ("used to") - hiện tại '
        'dùng "now" (bây giờ) để chỉ sự thay đổi. '
        '· Dịch: Giờ đây, nhân viên TechNova chỉ cần nhập dữ liệu lô hàng '
        'một lần.',
  ),
  ToeicQuestion(
    id: 'p6-q145',
    part: ToeicPartNumber.p6,
    passageId: 'p6-passage4',
    options: const [
      'We specialize in warehouse automation and delivery tracking.',
      'And just as importantly, we no longer lose shipments due to '
          'manual errors.',
      'We want customers to know that we are hiring.',
      'As a matter of fact, we are exploring that possibility right now.',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: "Meridian Tracker has made our team far more '
        'efficient. -------" '
        '· Đáp án: B. And just as importantly, we no longer lose shipments '
        'due to manual errors. '
        '· Giải thích: Câu này tiếp nối mạch khen ngợi lợi ích cụ thể của '
        'hệ thống, khớp với vấn đề "lỗi thủ công" nêu ở đầu đoạn. '
        '· Dịch: Và quan trọng không kém, chúng tôi không còn mất lô hàng '
        'do lỗi thủ công nữa.',
  ),
  ToeicQuestion(
    id: 'p6-q146',
    part: ToeicPartNumber.p6,
    passageId: 'p6-passage4',
    options: const ['reserved', 'recovered', 'maintained', 'encouraged'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: ...the company ------- its investment within eight '
        'months. '
        '· Đáp án: B. recovered '
        '· Giải thích: "Recovered its investment" (thu hồi vốn đầu tư) là '
        'cụm phù hợp ngữ cảnh nói về hiệu quả đầu tư. '
        '· Dịch: ...công ty đã thu hồi khoản đầu tư trong vòng tám tháng.',
  ),
];
// ============================================================================
// PART 7 - Reading Comprehension (54 cau: 29 doan don + 10 doan doi + 15
// doan ba, dung ty le gan voi TOEIC that).
// ============================================================================

final _part7Passages = <ToeicPassage>[
  // ---- Doan don (single passage) ----
  const ToeicPassage(
    id: 'p7-single1',
    titleEn: 'E-mail',
    textsEn: [
      'From: Orders@brightlinehome.example\n'
          'To: c.morales@mailbox.example\n'
          'Subject: Delay With Your Order #48213\n\n'
          'Dear Ms. Morales,\n\n'
          'Thank you for your recent order of a Brightline standing desk. '
          'We regret to inform you that due to unexpectedly high demand, '
          'your order will ship five business days later than originally '
          'planned, on June 14 instead of June 9.\n\n'
          'As an apology for the delay, we have applied a fifteen percent '
          'discount to your next purchase. You can find the discount '
          'code in your account under "Rewards."\n\n'
          'We appreciate your patience and understanding.\n\n'
          'Sincerely,\nBrightline Home Customer Care',
    ],
  ),
  const ToeicPassage(
    id: 'p7-single2',
    titleEn: 'Advertisement',
    textsEn: [
      'Join Our Team at Fernwood Logistics!\n\n'
          'Fernwood Logistics is seeking a full-time Warehouse Coordinator '
          'for our downtown facility. Responsibilities include managing '
          'incoming shipments, maintaining inventory records, and '
          'supervising a small team of three.\n\n'
          'Requirements: at least two years of warehouse experience, '
          'basic computer skills, and the ability to lift up to twenty '
          'kilograms. Prior experience with inventory software is '
          'preferred but not required — training will be provided.\n\n'
          'This position offers a competitive salary, health benefits, '
          'and opportunities for advancement. Interested applicants '
          'should send a résumé to careers@fernwoodlogistics.example by '
          'the end of the month.',
    ],
  ),
  const ToeicPassage(
    id: 'p7-single3',
    titleEn: 'Notice',
    textsEn: [
      'Notice to All Building Tenants\n\n'
          'Please be advised that the elevator in the west wing will be '
          'out of service for maintenance from Monday to Wednesday next '
          'week. Tenants are encouraged to use the east wing elevator or '
          'the stairwell during this period.\n\n'
          'We apologize for any inconvenience this may cause and thank '
          'you for your patience while we complete this necessary '
          'upgrade.\n\nBuilding Management',
    ],
  ),
  const ToeicPassage(
    id: 'p7-single4',
    titleEn: 'Article',
    textsEn: [
      'Local Bakery Expands to Second Location\n\n'
          'Golden Crust Bakery, a favorite among downtown residents for '
          'its sourdough bread, announced this week that it will open a '
          'second location on Maple Avenue in early September.\n\n'
          'Owner Renata Kowalski said the new shop will feature the same '
          'menu as the original location, along with a small seating area '
          'for customers who want to enjoy their pastries on-site. '
          '"We\'ve wanted to expand for years, but we wanted to make sure '
          'we could maintain the same quality," Kowalski explained.\n\n'
          'The bakery plans to hire eight new employees for the second '
          'location, with hiring to begin in early August.',
    ],
  ),
  const ToeicPassage(
    id: 'p7-single5',
    titleEn: 'Web Page',
    textsEn: [
      'Frequently Asked Questions — Cedar Valley Fitness Center\n\n'
          'Q: What are your hours of operation?\n'
          'A: We are open Monday through Friday from 6 A.M. to 10 P.M., '
          'and Saturday and Sunday from 8 A.M. to 6 P.M.\n\n'
          'Q: Do I need to bring my own towel?\n'
          'A: Towels are provided free of charge at the front desk.\n\n'
          'Q: Can I freeze my membership temporarily?\n'
          'A: Yes, members may freeze their membership for up to two '
          'months per year at no extra cost. Requests must be submitted '
          'at least five days in advance through the member portal.\n\n'
          'Q: Are personal trainers available?\n'
          'A: Yes, personal training sessions can be booked separately at '
          'the front desk or through our mobile app.',
    ],
  ),
  const ToeicPassage(
    id: 'p7-single6',
    titleEn: 'Memo',
    textsEn: [
      'To: Product Development Team\nFrom: Youssef Haddad\n'
          'Re: Rescheduled Design Review\n\n'
          'Please note that Thursday\'s design review meeting has been '
          'moved to next Monday at 10 A.M. in Room 4B. This change was '
          'made because two key stakeholders are traveling this week and '
          'want to attend in person.\n\n'
          'Please come prepared to discuss the updated prototype and any '
          'remaining concerns about the packaging design.',
    ],
  ),
  const ToeicPassage(
    id: 'p7-single7',
    titleEn: 'Text-Message Chain',
    textsEn: [
      'Diego (2:10 P.M.): Hey, are we still meeting the client at 3?\n\n'
          'Sana (2:11 P.M.): Yes, but they just asked to push it to 3:30 '
          'instead.\n\n'
          'Diego (2:12 P.M.): That works for me. Should I bring the '
          'updated proposal?\n\n'
          'Sana (2:13 P.M.): Yes, please print three copies. I\'ll grab '
          'the projector from the storage room.\n\n'
          'Diego (2:14 P.M.): Got it, see you there.',
    ],
  ),
  const ToeicPassage(
    id: 'p7-single8',
    titleEn: 'Advertisement',
    textsEn: [
      'Introducing the SolarBright Lantern\n\n'
          'Perfect for camping, power outages, or everyday use, the '
          'SolarBright Lantern charges fully in just four hours of '
          'sunlight and provides up to twelve hours of light on a single '
          'charge.\n\n'
          'Features include three brightness settings, a built-in USB '
          'port for charging small devices, and a water-resistant '
          'design.\n\n'
          'Available now at outdoor retailers nationwide, or order online '
          'at www.solarbrightgear.example for free shipping on orders '
          'over thirty dollars.',
    ],
  ),
  const ToeicPassage(
    id: 'p7-single9',
    titleEn: 'Letter',
    textsEn: [
      'Dear Mr. Okonkwo,\n\n'
          'Thank you for bringing your concerns about your recent stay at '
          'Lakeside Inn to our attention. We are sorry to hear that '
          'construction noise disturbed your sleep during your visit.\n\n'
          'As a gesture of goodwill, we would like to offer you a '
          'complimentary night on your next stay with us. Please contact '
          'our front desk directly and mention this letter when you '
          'book.\n\n'
          'We value your business and hope to welcome you back soon.\n\n'
          'Sincerely,\nThe Lakeside Inn Management Team',
    ],
  ),
  const ToeicPassage(
    id: 'p7-single10',
    titleEn: 'Schedule',
    textsEn: [
      'Northbridge Business Summit — Day 1 Schedule\n\n'
          '8:30 A.M. — Registration and Breakfast (Main Lobby)\n'
          '9:30 A.M. — Opening Keynote: "The Future of Remote Teams" '
          '(Hall A)\n'
          '11:00 A.M. — Breakout Session 1: Choose from three tracks '
          '(Marketing, Finance, or Technology)\n'
          '12:30 P.M. — Lunch (Terrace)\n'
          '2:00 P.M. — Panel Discussion: Industry Leaders (Hall A)\n'
          '4:00 P.M. — Networking Reception (Main Lobby)\n\n'
          'Note: Breakout Session 1 requires advance registration, which '
          'closes at 10:30 A.M. on the day of the event. Seats are '
          'limited and assigned on a first-come, first-served basis.',
    ],
  ),

  // ---- Doan doi (double passage) ----
  const ToeicPassage(
    id: 'p7-double1',
    titleEn: 'Advertisement and E-mail',
    textsEn: [
      'Now Hiring: Social Media Coordinator\n\n'
          'Bramble & Co. is looking for a creative Social Media '
          'Coordinator to manage our brand\'s presence across Instagram, '
          'TikTok, and Facebook. The ideal candidate will plan content '
          'calendars, respond to follower comments, and track engagement '
          'metrics.\n\n'
          'Requirements: at least one year of social media experience and '
          'strong writing skills. Please send your résumé and a short '
          'writing sample to hiring@brambleandco.example.',
      'From: Ifeoma Adeyemi\nTo: hiring@brambleandco.example\n'
          'Subject: Application for Social Media Coordinator\n\n'
          'Dear Hiring Manager,\n\n'
          'I am writing to apply for the Social Media Coordinator '
          'position posted on your website. I have three years of '
          'experience managing social media accounts for a local retail '
          'chain, where I increased our follower count by forty percent '
          'in one year.\n\n'
          'I have attached my résumé and a writing sample as requested. '
          'I would welcome the opportunity to discuss my qualifications '
          'further in an interview.\n\n'
          'Thank you for your consideration.\n\nSincerely,\nIfeoma Adeyemi',
    ],
  ),
  const ToeicPassage(
    id: 'p7-double2',
    titleEn: 'Advertisement and E-mail',
    textsEn: [
      'Protect Your Purchase with ExtraCare Warranty\n\n'
          'Did you know you can extend the manufacturer\'s warranty on '
          'your small kitchen appliance by three years? ExtraCare '
          'Warranty covers parts, labor, and even accidental damage.\n\n'
          'To qualify, you must purchase the ExtraCare plan within thirty '
          'days of buying your appliance. Visit any participating store '
          'or www.extracarewarranty.example to sign up.',
      'From: Marcus Whitfield\nTo: support@extracarewarranty.example\n'
          'Subject: Warranty Question\n\n'
          'Hello,\n\n'
          'I purchased a blender from KitchenWorks last month and would '
          'like to know if it still qualifies for the ExtraCare extended '
          'warranty. I did not sign up at the time of purchase because I '
          'was not aware of the program.\n\n'
          'Could you let me know whether I can still enroll, and if so, '
          'what the cost would be?\n\nThank you,\nMarcus Whitfield',
    ],
  ),

  // ---- Doan ba (triple passage) ----
  const ToeicPassage(
    id: 'p7-triple1',
    titleEn: 'Notice, E-mail, and Schedule',
    textsEn: [
      'Annual Business Expo — Register Now\n\n'
          'The Annual Business Expo will take place on August 20 at the '
          'Riverside Convention Center. Register by July 15 to receive '
          'the early-bird rate of \$40; after that date, registration '
          'costs \$60.\n\n'
          'To register, visit www.riversideexpo.example and complete the '
          'online form. A confirmation e-mail will be sent within '
          'twenty-four hours.',
      'From: Helena Farrow\nTo: info@riversideexpo.example\n'
          'Subject: Registration Confirmation\n\n'
          'Hello,\n\n'
          'I registered for the Annual Business Expo yesterday and '
          'received my confirmation number, EXP-2291. I just wanted to '
          'confirm that my registration went through successfully.\n\n'
          'Also, could you tell me whether on-site parking is included '
          'with registration, or if I need to reserve a spot separately?\n\n'
          'Thank you,\nHelena Farrow',
      'Annual Business Expo — Schedule (August 20)\n\n'
          '9:00 A.M. — Registration and Coffee\n'
          '10:00 A.M. — Keynote Speech: "Growing a Small Business"\n'
          '11:30 A.M. — Networking Lunch\n'
          '1:00 P.M. — Workshop: Funding Options for Startups\n'
          '3:00 P.M. — Closing Remarks\n\n'
          'Note: On-site parking is limited to 100 spaces and must be '
          'reserved separately through the parking portal, in addition to '
          'expo registration.',
    ],
  ),
  const ToeicPassage(
    id: 'p7-triple2',
    titleEn: 'Advertisement and E-mails',
    textsEn: [
      'Free Webinar: Digital Marketing Strategies for 2027\n\n'
          'Join marketing expert Lena Ostrowski for a free 60-minute '
          'webinar covering the latest trends in digital marketing, '
          'including social media advertising and search engine '
          'optimization. The webinar takes place on March 10 at 2 P.M.\n\n'
          'Register at www.marketinginsights.example/webinar.',
      'From: Julien Delacroix\nTo: support@marketinginsights.example\n'
          'Subject: Webinar Question\n\n'
          'Hello,\n\n'
          'I registered for the digital marketing webinar on March 10, '
          'but I have a scheduling conflict at that time. Will the '
          'session be recorded so I can watch it later?\n\n'
          'Thank you,\nJulien Delacroix',
      'From: Marketing Insights Support\nTo: Julien Delacroix\n'
          'Subject: RE: Webinar Question\n\n'
          'Hello Mr. Delacroix,\n\n'
          'Yes, the webinar will be recorded. A link to the recording '
          'will be sent to your registered e-mail address within '
          'twenty-four hours after the event, and it will remain '
          'available for one month.\n\n'
          'Best regards,\nMarketing Insights Support Team',
    ],
  ),
  const ToeicPassage(
    id: 'p7-triple3',
    titleEn: 'Memo and E-mails',
    textsEn: [
      'To: All Staff\nFrom: Finance Department\n'
          'Re: Updated Travel Reimbursement Policy\n\n'
          'Effective next month, the daily meal allowance for business '
          'travel will increase from \$45 to \$60. Employees must submit '
          'original receipts within two weeks of returning from a trip to '
          'be reimbursed.\n\n'
          'Transportation such as flights and train tickets remains '
          'reimbursable, subject to a maximum of \$500 per trip unless '
          'pre-approved by a department head.',
      'From: Terrence Boone\nTo: finance@company.example\n'
          'Subject: Question About Train Tickets\n\n'
          'Hello,\n\n'
          'I read the updated travel policy and wanted to confirm '
          'whether train tickets purchased for an upcoming client visit '
          'are reimbursable under the new rules, and if there is a '
          'specific limit I should be aware of.\n\n'
          'Thank you,\nTerrence Boone',
      'From: Finance Department\nTo: Terrence Boone\n'
          'Subject: RE: Question About Train Tickets\n\n'
          'Hello Mr. Boone,\n\n'
          'Yes, train tickets are reimbursable up to \$500 per trip under '
          'our current policy. Please submit your original receipt '
          'within two weeks of your return so we can process your '
          'reimbursement promptly.\n\nBest regards,\nFinance Department',
    ],
  ),
];

final _part7Questions = <ToeicQuestion>[
  // --- Doan 1: email tri hoan don hang ---
  ToeicQuestion(
    id: 'p7-q147',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single1',
    promptEn: 'Why was the e-mail sent?',
    options: const [
      'To confirm a payment',
      'To explain a shipping delay',
      'To cancel an order',
      'To request a product review',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Why was the e-mail sent? '
        '· Đáp án: B. To explain a shipping delay '
        '· Giải thích: Email thông báo đơn hàng sẽ giao trễ 5 ngày so với '
        'kế hoạch. '
        '· Dịch: Vì sao email này được gửi? → Để giải thích việc giao hàng '
        'bị trễ.',
  ),
  ToeicQuestion(
    id: 'p7-q148',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single1',
    promptEn: 'When will the order now ship?',
    options: const ['June 4', 'June 9', 'June 14', 'June 19'],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: When will the order now ship? '
        '· Đáp án: C. June 14 '
        '· Giải thích: Email nói đơn hàng sẽ giao vào 14/6 thay vì 9/6. '
        '· Dịch: Đơn hàng sẽ được giao vào khi nào? → Ngày 14 tháng 6.',
  ),
  ToeicQuestion(
    id: 'p7-q149',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single1',
    promptEn: 'What does the company offer Ms. Morales?',
    options: const [
      'A full refund',
      'A discount on a future purchase',
      'Free express shipping',
      'A replacement product',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What does the company offer Ms. Morales? '
        '· Đáp án: B. A discount on a future purchase '
        '· Giải thích: Email nói đã áp dụng giảm giá 15% cho lần mua tiếp '
        'theo. '
        '· Dịch: Công ty đề nghị gì với bà Morales? → Giảm giá cho lần mua '
        'tiếp theo.',
  ),

  // --- Doan 2: tuyen dung ---
  ToeicQuestion(
    id: 'p7-q150',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single2',
    promptEn: 'What position is being advertised?',
    options: const [
      'Delivery Driver',
      'Warehouse Coordinator',
      'Sales Manager',
      'Customer Service Representative',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What position is being advertised? '
        '· Đáp án: B. Warehouse Coordinator '
        '· Giải thích: Tiêu đề quảng cáo nêu rõ vị trí này. '
        '· Dịch: Vị trí nào đang được tuyển? → Điều phối viên kho.',
  ),
  ToeicQuestion(
    id: 'p7-q151',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single2',
    promptEn: 'What is NOT listed as a requirement?',
    options: const [
      'Two years of warehouse experience',
      'A university degree',
      'Basic computer skills',
      'Ability to lift twenty kilograms',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What is NOT listed as a requirement? '
        '· Đáp án: B. A university degree '
        '· Giải thích: Quảng cáo không đề cập bằng đại học, chỉ nêu kinh '
        'nghiệm, kỹ năng máy tính, và khả năng nâng vật nặng. '
        '· Dịch: Điều gì KHÔNG được liệt kê là yêu cầu? → Bằng đại học.',
  ),
  ToeicQuestion(
    id: 'p7-q152',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single2',
    promptEn: 'How should interested applicants apply?',
    options: const [
      'By calling the office',
      'By visiting in person',
      'By sending a résumé via e-mail',
      'By submitting an online form',
    ],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: How should interested applicants apply? '
        '· Đáp án: C. By sending a résumé via e-mail '
        '· Giải thích: Quảng cáo yêu cầu gửi CV qua email careers@... '
        '· Dịch: Ứng viên nên nộp hồ sơ như thế nào? → Gửi CV qua email.',
  ),

  // --- Doan 3: thong bao thang may ---
  ToeicQuestion(
    id: 'p7-q153',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single3',
    promptEn: 'What is the purpose of this notice?',
    options: const [
      'To announce a rent increase',
      'To inform tenants about elevator maintenance',
      'To introduce new building staff',
      'To announce a fire drill',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What is the purpose of this notice? '
        '· Đáp án: B. To inform tenants about elevator maintenance '
        '· Giải thích: Thông báo nói thang máy cánh tây sẽ bảo trì. '
        '· Dịch: Mục đích của thông báo là gì? → Thông báo cư dân về việc '
        'bảo trì thang máy.',
  ),
  ToeicQuestion(
    id: 'p7-q154',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single3',
    promptEn: 'What are tenants advised to do?',
    options: const [
      'Move to a different unit temporarily',
      'Use the east wing elevator or stairs',
      'Avoid the building entirely',
      'Contact building management for a refund',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What are tenants advised to do? '
        '· Đáp án: B. Use the east wing elevator or stairs '
        '· Giải thích: Thông báo khuyên dùng thang máy cánh đông hoặc cầu '
        'thang bộ. '
        '· Dịch: Cư dân được khuyên nên làm gì? → Dùng thang máy cánh đông '
        'hoặc cầu thang bộ.',
  ),

  // --- Doan 4: bai bao tiem banh mo rong ---
  ToeicQuestion(
    id: 'p7-q155',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single4',
    promptEn: 'What is the article mainly about?',
    options: const [
      'A bakery closing down',
      'A bakery opening a second location',
      'A new bakery recipe',
      'A change in bakery ownership',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What is the article mainly about? '
        '· Đáp án: B. A bakery opening a second location '
        '· Giải thích: Tiêu đề và nội dung nói về việc mở thêm chi nhánh. '
        '· Dịch: Bài báo chủ yếu nói về điều gì? → Một tiệm bánh mở thêm '
        'chi nhánh thứ hai.',
  ),
  ToeicQuestion(
    id: 'p7-q156',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single4',
    promptEn: 'What will be different about the new location?',
    options: const [
      'It will have a seating area.',
      'It will sell a different menu.',
      'It will only sell bread.',
      'It will be open 24 hours.',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: What will be different about the new location? '
        '· Đáp án: A. It will have a seating area. '
        '· Giải thích: Bài báo nói chi nhánh mới có thêm khu vực ngồi, thực '
        'đơn thì giống chi nhánh cũ. '
        '· Dịch: Điều gì sẽ khác ở chi nhánh mới? → Sẽ có khu vực chỗ ngồi.',
  ),
  ToeicQuestion(
    id: 'p7-q157',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single4',
    promptEn: 'When will hiring begin for the new location?',
    options: const [
      'Early July',
      'Early August',
      'Early September',
      'Early October',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: When will hiring begin for the new location? '
        '· Đáp án: B. Early August '
        '· Giải thích: Bài báo nói việc tuyển dụng bắt đầu đầu tháng 8. '
        '· Dịch: Việc tuyển dụng sẽ bắt đầu khi nào? → Đầu tháng Tám.',
  ),

  // --- Doan 5: FAQ phong gym ---
  ToeicQuestion(
    id: 'p7-q158',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single5',
    promptEn: 'What time does the gym open on Saturdays?',
    options: const ['6 A.M.', '7 A.M.', '8 A.M.', '9 A.M.'],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: What time does the gym open on Saturdays? '
        '· Đáp án: C. 8 A.M. '
        '· Giải thích: Trang FAQ nói cuối tuần mở cửa từ 8 giờ sáng. '
        '· Dịch: Phòng gym mở cửa lúc mấy giờ vào thứ Bảy? → 8 giờ sáng.',
  ),
  ToeicQuestion(
    id: 'p7-q159',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single5',
    promptEn: 'How long can a membership be frozen?',
    options: const [
      'Up to two weeks per year',
      'Up to one month per year',
      'Up to two months per year',
      'Up to six months per year',
    ],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: How long can a membership be frozen? '
        '· Đáp án: C. Up to two months per year '
        '· Giải thích: FAQ nói được đóng băng thẻ tối đa 2 tháng/năm. '
        '· Dịch: Thẻ hội viên có thể tạm ngưng tối đa bao lâu? → Hai tháng '
        'mỗi năm.',
  ),
  ToeicQuestion(
    id: 'p7-q160',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single5',
    promptEn: 'How can a member freeze their membership?',
    options: const [
      'By calling customer service',
      'Through the member portal',
      'By visiting in person only',
      'By sending a letter',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: How can a member freeze their membership? '
        '· Đáp án: B. Through the member portal '
        '· Giải thích: FAQ nói yêu cầu phải nộp qua cổng thông tin hội '
        'viên. '
        '· Dịch: Hội viên đóng băng thẻ bằng cách nào? → Qua cổng thông tin '
        'hội viên.',
  ),

  // --- Doan 6: memo doi lich hop ---
  ToeicQuestion(
    id: 'p7-q161',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single6',
    promptEn: 'Why was the meeting rescheduled?',
    options: const [
      'The room was unavailable.',
      'Two stakeholders are traveling this week.',
      'The prototype was not ready.',
      'The team requested more time.',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Why was the meeting rescheduled? '
        '· Đáp án: B. Two stakeholders are traveling this week. '
        '· Giải thích: Memo nói 2 bên liên quan đang đi công tác tuần này. '
        '· Dịch: Vì sao cuộc họp bị dời? → Hai bên liên quan đang đi công '
        'tác tuần này.',
  ),
  ToeicQuestion(
    id: 'p7-q162',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single6',
    promptEn: 'What should attendees prepare to discuss?',
    options: const [
      'The annual budget',
      'The updated prototype and packaging design',
      'A new hiring plan',
      'Customer complaints',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What should attendees prepare to discuss? '
        '· Đáp án: B. The updated prototype and packaging design '
        '· Giải thích: Memo yêu cầu chuẩn bị thảo luận về prototype cập '
        'nhật và thiết kế bao bì. '
        '· Dịch: Người tham dự nên chuẩn bị thảo luận gì? → Prototype cập '
        'nhật và thiết kế bao bì.',
  ),

  // --- Doan 7: tin nhan doi gio hop khach ---
  ToeicQuestion(
    id: 'p7-q163',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single7',
    promptEn: 'What time will the meeting with the client now take place?',
    options: const ['2:30', '3:00', '3:30', '4:00'],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: What time will the meeting with the client now take '
        'place? '
        '· Đáp án: C. 3:30 '
        '· Giải thích: Sana nói khách hàng đề nghị đổi giờ họp sang 3:30. '
        '· Dịch: Cuộc họp với khách hàng sẽ diễn ra lúc mấy giờ? → 3:30.',
  ),
  ToeicQuestion(
    id: 'p7-q164',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single7',
    promptEn: 'At 2:12 P.M., what does Diego mean when he writes "That works for me"?',
    options: const [
      'He agrees with the new meeting time.',
      'He finished the proposal.',
      'He found a projector.',
      'He canceled the meeting.',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: At 2:12 P.M., what does Diego mean when he writes '
        '"That works for me"? '
        '· Đáp án: A. He agrees with the new meeting time. '
        '· Giải thích: Câu này là phản hồi trực tiếp cho đề nghị đổi giờ '
        'họp của Sana. '
        '· Dịch: Ý của Diego khi viết câu đó là gì? → Anh đồng ý với giờ '
        'họp mới.',
  ),
  ToeicQuestion(
    id: 'p7-q165',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single7',
    promptEn: 'What will Sana bring to the meeting?',
    options: const [
      'Printed copies of the proposal',
      'A projector',
      'Refreshments',
      'A signed contract',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What will Sana bring to the meeting? '
        '· Đáp án: B. A projector '
        '· Giải thích: Sana nói sẽ lấy máy chiếu từ phòng kho, còn Diego lo '
        'in tài liệu. '
        '· Dịch: Sana sẽ mang gì đến cuộc họp? → Một máy chiếu.',
  ),

  // --- Doan 8: quang cao den nang luong mat troi ---
  ToeicQuestion(
    id: 'p7-q166',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single8',
    promptEn: 'How long does the lantern take to fully charge?',
    options: const ['One hour', 'Four hours', 'Twelve hours', 'Overnight'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: How long does the lantern take to fully charge? '
        '· Đáp án: B. Four hours '
        '· Giải thích: Quảng cáo nói sạc đầy trong 4 giờ nắng. '
        '· Dịch: Đèn cần bao lâu để sạc đầy? → Bốn giờ.',
  ),
  ToeicQuestion(
    id: 'p7-q167',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single8',
    promptEn: 'What feature is NOT mentioned?',
    options: const [
      'A USB charging port',
      'Three brightness settings',
      'A water-resistant design',
      'A built-in alarm',
    ],
    correctIndex: 3,
    explanationVi:
        '· Câu hỏi: What feature is NOT mentioned? '
        '· Đáp án: D. A built-in alarm '
        '· Giải thích: Quảng cáo không nhắc tới báo thức, chỉ có cổng USB, '
        '3 mức sáng, và khả năng chống nước. '
        '· Dịch: Tính năng nào KHÔNG được nhắc đến? → Báo thức tích hợp.',
  ),
  ToeicQuestion(
    id: 'p7-q168',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single8',
    promptEn: 'How can customers get free shipping?',
    options: const [
      'By joining a membership program',
      'By ordering over thirty dollars',
      'By visiting a retail store',
      'By ordering two or more items',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: How can customers get free shipping? '
        '· Đáp án: B. By ordering over thirty dollars '
        '· Giải thích: Quảng cáo nói miễn phí ship cho đơn trên 30 đô. '
        '· Dịch: Làm sao để được miễn phí vận chuyển? → Đặt hàng trên ba '
        'mươi đô la.',
  ),

  // --- Doan 9: thu xin loi khach san ---
  ToeicQuestion(
    id: 'p7-q169',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single9',
    promptEn: 'Why is the hotel writing to Mr. Okonkwo?',
    options: const [
      'To confirm a reservation',
      'To apologize for a disturbance during his stay',
      'To offer a job',
      'To request payment',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Why is the hotel writing to Mr. Okonkwo? '
        '· Đáp án: B. To apologize for a disturbance during his stay '
        '· Giải thích: Thư xin lỗi vì tiếng ồn xây dựng làm phiền giấc ngủ. '
        '· Dịch: Vì sao khách sạn viết thư cho ông Okonkwo? → Để xin lỗi vì '
        'sự làm phiền trong kỳ nghỉ.',
  ),
  ToeicQuestion(
    id: 'p7-q170',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single9',
    promptEn: 'What does the hotel offer as compensation?',
    options: const [
      'A full refund',
      'A free night on his next stay',
      'A discount on the current bill',
      'A free meal',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What does the hotel offer as compensation? '
        '· Đáp án: B. A free night on his next stay '
        '· Giải thích: Thư đề nghị tặng 1 đêm miễn phí cho lần lưu trú kế '
        'tiếp. '
        '· Dịch: Khách sạn đề nghị bồi thường gì? → Một đêm miễn phí cho '
        'lần ở kế tiếp.',
  ),
  ToeicQuestion(
    id: 'p7-q171',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single9',
    promptEn: 'What should Mr. Okonkwo do to receive the offer?',
    options: const [
      'Fill out an online form',
      'Mention the letter when booking',
      'Wait for a follow-up call',
      'Pay in advance',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What should Mr. Okonkwo do to receive the offer? '
        '· Đáp án: B. Mention the letter when booking '
        '· Giải thích: Thư yêu cầu liên hệ lễ tân và nhắc tới bức thư này '
        'khi đặt phòng. '
        '· Dịch: Ông Okonkwo nên làm gì để nhận ưu đãi? → Nhắc đến bức thư '
        'này khi đặt phòng.',
  ),

  // --- Doan 10: lich trinh hoi nghi ---
  ToeicQuestion(
    id: 'p7-q172',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single10',
    promptEn: 'What will happen at 9:30 A.M.?',
    options: const [
      'Registration',
      'The opening keynote',
      'A panel discussion',
      'A networking reception',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What will happen at 9:30 A.M.? '
        '· Đáp án: B. The opening keynote '
        '· Giải thích: Lịch trình ghi rõ 9:30 là bài phát biểu khai mạc. '
        '· Dịch: Điều gì diễn ra lúc 9:30 sáng? → Bài phát biểu khai mạc.',
  ),
  ToeicQuestion(
    id: 'p7-q173',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single10',
    promptEn: 'How many tracks are offered during Breakout Session 1?',
    options: const ['One', 'Two', 'Three', 'Four'],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: How many tracks are offered during Breakout Session 1? '
        '· Đáp án: C. Three '
        '· Giải thích: Lịch trình liệt kê 3 track: Marketing, Finance, '
        'Technology. '
        '· Dịch: Có bao nhiêu chủ đề trong Breakout Session 1? → Ba.',
  ),
  ToeicQuestion(
    id: 'p7-q174',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single10',
    promptEn: 'What is required to attend Breakout Session 1?',
    options: const [
      'Payment of an extra fee',
      'Advance registration',
      'An invitation from the organizer',
      'Attendance at the keynote',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What is required to attend Breakout Session 1? '
        '· Đáp án: B. Advance registration '
        '· Giải thích: Ghi chú nói cần đăng ký trước, chỗ ngồi có hạn. '
        '· Dịch: Cần gì để tham dự Breakout Session 1? → Đăng ký trước.',
  ),
  ToeicQuestion(
    id: 'p7-q175',
    part: ToeicPartNumber.p7,
    passageId: 'p7-single10',
    promptEn: 'When does registration for Breakout Session 1 close?',
    options: const [
      '8:30 A.M. the day of the event',
      '10:30 A.M. the day of the event',
      'One week before the event',
      'At the door',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: When does registration for Breakout Session 1 close? '
        '· Đáp án: B. 10:30 A.M. the day of the event '
        '· Giải thích: Ghi chú nói đăng ký đóng lúc 10:30 sáng ngày diễn '
        'ra. '
        '· Dịch: Đăng ký cho Breakout Session 1 đóng khi nào? → 10:30 sáng '
        'ngày sự kiện.',
  ),

  // --- Doan doi 1: quang cao viec lam + email ung tuyen ---
  ToeicQuestion(
    id: 'p7-q176',
    part: ToeicPartNumber.p7,
    passageId: 'p7-double1',
    promptEn: 'What position was advertised?',
    options: const [
      'Graphic Designer',
      'Social Media Coordinator',
      'Accountant',
      'Warehouse Supervisor',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What position was advertised? '
        '· Đáp án: B. Social Media Coordinator '
        '· Giải thích: Quảng cáo (đoạn 1) nêu rõ vị trí này. '
        '· Dịch: Vị trí nào được đăng tuyển? → Điều phối viên mạng xã hội.',
  ),
  ToeicQuestion(
    id: 'p7-q177',
    part: ToeicPartNumber.p7,
    passageId: 'p7-double1',
    promptEn: 'What is required for the position?',
    options: const [
      'A design portfolio',
      'At least one year of social media experience',
      'A driver\'s license',
      'Fluency in a second language',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What is required for the position? '
        '· Đáp án: B. At least one year of social media experience '
        '· Giải thích: Quảng cáo yêu cầu ít nhất 1 năm kinh nghiệm mạng xã '
        'hội. '
        '· Dịch: Vị trí này yêu cầu gì? → Ít nhất một năm kinh nghiệm mạng '
        'xã hội.',
  ),
  ToeicQuestion(
    id: 'p7-q178',
    part: ToeicPartNumber.p7,
    passageId: 'p7-double1',
    promptEn: 'Why is Ms. Adeyemi writing the e-mail?',
    options: const [
      'To withdraw her application',
      'To apply for the position',
      'To ask about the salary',
      'To request an extension',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Why is Ms. Adeyemi writing the e-mail? '
        '· Đáp án: B. To apply for the position '
        '· Giải thích: Email (đoạn 2) là thư ứng tuyển kèm CV đính kèm. '
        '· Dịch: Vì sao bà Adeyemi viết email này? → Để ứng tuyển vị trí.',
  ),
  ToeicQuestion(
    id: 'p7-q179',
    part: ToeicPartNumber.p7,
    passageId: 'p7-double1',
    promptEn: 'How many years of experience does Ms. Adeyemi mention having?',
    options: const ['One', 'Two', 'Three', 'Five'],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: How many years of experience does Ms. Adeyemi mention '
        'having? '
        '· Đáp án: C. Three '
        '· Giải thích: Email nói bà có 3 năm kinh nghiệm quản lý mạng xã '
        'hội. '
        '· Dịch: Bà Adeyemi có bao nhiêu năm kinh nghiệm? → Ba năm.',
  ),
  ToeicQuestion(
    id: 'p7-q180',
    part: ToeicPartNumber.p7,
    passageId: 'p7-double1',
    promptEn: 'What does Ms. Adeyemi ask for at the end of her e-mail?',
    options: const [
      'A higher salary',
      'A chance to interview',
      'A recommendation letter',
      'A remote work arrangement',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What does Ms. Adeyemi ask for at the end of her '
        'e-mail? '
        '· Đáp án: B. A chance to interview '
        '· Giải thích: Cuối email bà bày tỏ mong muốn được mời phỏng vấn. '
        '· Dịch: Bà Adeyemi đề nghị điều gì ở cuối email? → Một cơ hội '
        'phỏng vấn.',
  ),

  // --- Doan doi 2: quang cao bao hanh + email hoi ve bao hanh ---
  ToeicQuestion(
    id: 'p7-q181',
    part: ToeicPartNumber.p7,
    passageId: 'p7-double2',
    promptEn: 'What is being advertised in the first passage?',
    options: const [
      'A kitchen blender',
      'An extended warranty plan',
      'A cooking class',
      'A grocery delivery service',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What is being advertised in the first passage? '
        '· Đáp án: B. An extended warranty plan '
        '· Giải thích: Quảng cáo (đoạn 1) giới thiệu gói bảo hành mở rộng. '
        '· Dịch: Quảng cáo trong đoạn đầu là về gì? → Gói bảo hành mở '
        'rộng.',
  ),
  ToeicQuestion(
    id: 'p7-q182',
    part: ToeicPartNumber.p7,
    passageId: 'p7-double2',
    promptEn: 'How long does the extended warranty last?',
    options: const ['One year', 'Two years', 'Three years', 'Five years'],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: How long does the extended warranty last? '
        '· Đáp án: C. Three years '
        '· Giải thích: Quảng cáo nói gói bảo hành mở rộng kéo dài 3 năm. '
        '· Dịch: Gói bảo hành mở rộng kéo dài bao lâu? → Ba năm.',
  ),
  ToeicQuestion(
    id: 'p7-q183',
    part: ToeicPartNumber.p7,
    passageId: 'p7-double2',
    promptEn: 'Why did Mr. Whitfield send the e-mail?',
    options: const [
      'To request a refund',
      'To ask whether his blender qualifies for the plan',
      'To cancel his order',
      'To complain about a late delivery',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Why did Mr. Whitfield send the e-mail? '
        '· Đáp án: B. To ask whether his blender qualifies for the plan '
        '· Giải thích: Email (đoạn 2) hỏi máy xay ông mua tháng trước có '
        'đủ điều kiện mua gói bảo hành mở rộng không. '
        '· Dịch: Vì sao ông Whitfield gửi email? → Để hỏi máy xay của ông '
        'có đủ điều kiện cho gói bảo hành không.',
  ),
  ToeicQuestion(
    id: 'p7-q184',
    part: ToeicPartNumber.p7,
    passageId: 'p7-double2',
    promptEn: 'When did Mr. Whitfield purchase his blender?',
    options: const ['Last month', 'Last week', 'Two years ago', 'Today'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: When did Mr. Whitfield purchase his blender? '
        '· Đáp án: A. Last month '
        '· Giải thích: Email nói ông mua máy xay tháng trước. '
        '· Dịch: Ông Whitfield mua máy xay khi nào? → Tháng trước.',
  ),
  ToeicQuestion(
    id: 'p7-q185',
    part: ToeicPartNumber.p7,
    passageId: 'p7-double2',
    promptEn: 'According to the advertisement, what is the deadline to purchase the extended warranty?',
    options: const [
      'Within thirty days of purchase',
      'Within six months of purchase',
      'Anytime before the original warranty ends',
      'There is no deadline.',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: According to the advertisement, what is the deadline '
        'to purchase the extended warranty? '
        '· Đáp án: A. Within thirty days of purchase '
        '· Giải thích: Quảng cáo nói phải mua gói mở rộng trong vòng 30 '
        'ngày kể từ ngày mua sản phẩm. '
        '· Dịch: Theo quảng cáo, hạn chót mua gói bảo hành mở rộng là khi '
        'nào? → Trong vòng ba mươi ngày kể từ khi mua hàng.',
  ),

  // --- Doan ba 1: thong bao hoi cho + email xac nhan + lich trinh ---
  ToeicQuestion(
    id: 'p7-q186',
    part: ToeicPartNumber.p7,
    passageId: 'p7-triple1',
    promptEn: 'What is the Annual Business Expo notice mainly about?',
    options: const [
      'A change in expo location',
      'How to register for the expo',
      'The expo\'s history',
      'A list of past sponsors',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What is the Annual Business Expo notice mainly about? '
        '· Đáp án: B. How to register for the expo '
        '· Giải thích: Thông báo (đoạn 1) hướng dẫn cách đăng ký tham dự '
        'hội chợ. '
        '· Dịch: Thông báo về Hội chợ Kinh doanh Thường niên chủ yếu nói '
        'về gì? → Cách đăng ký tham dự hội chợ.',
  ),
  ToeicQuestion(
    id: 'p7-q187',
    part: ToeicPartNumber.p7,
    passageId: 'p7-triple1',
    promptEn: 'What is the early registration deadline?',
    options: const ['July 1', 'July 15', 'August 1', 'August 15'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What is the early registration deadline? '
        '· Đáp án: B. July 15 '
        '· Giải thích: Thông báo nói đăng ký sớm để được giảm giá phải '
        'thực hiện trước 15/7. '
        '· Dịch: Hạn đăng ký sớm là khi nào? → Ngày 15 tháng 7.',
  ),
  ToeicQuestion(
    id: 'p7-q188',
    part: ToeicPartNumber.p7,
    passageId: 'p7-triple1',
    promptEn: 'Why did Ms. Farrow send the e-mail?',
    options: const [
      'To cancel her registration',
      'To confirm her registration and ask about parking',
      'To request a discount',
      'To complain about the schedule',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Why did Ms. Farrow send the e-mail? '
        '· Đáp án: B. To confirm her registration and ask about parking '
        '· Giải thích: Email (đoạn 2) xác nhận đã đăng ký và hỏi về chỗ '
        'đậu xe. '
        '· Dịch: Vì sao bà Farrow gửi email? → Để xác nhận đăng ký và hỏi '
        'về chỗ đậu xe.',
  ),
  ToeicQuestion(
    id: 'p7-q189',
    part: ToeicPartNumber.p7,
    passageId: 'p7-triple1',
    promptEn: 'According to the schedule, what happens at 1:00 P.M.?',
    options: const [
      'Registration opens',
      'The keynote speech',
      'The networking lunch',
      'A workshop on funding',
    ],
    correctIndex: 3,
    explanationVi:
        '· Câu hỏi: According to the schedule, what happens at 1:00 P.M.? '
        '· Đáp án: D. A workshop on funding '
        '· Giải thích: Lịch trình (đoạn 3) ghi 1 giờ chiều là hội thảo về '
        'gọi vốn. '
        '· Dịch: Theo lịch trình, điều gì diễn ra lúc 1 giờ chiều? → Hội '
        'thảo về gọi vốn.',
  ),
  ToeicQuestion(
    id: 'p7-q190',
    part: ToeicPartNumber.p7,
    passageId: 'p7-triple1',
    promptEn: 'What can be inferred about parking at the expo?',
    options: const [
      'It is free for all attendees.',
      'It is not available on-site.',
      'It requires a separate reservation.',
      'It is only for sponsors.',
    ],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: What can be inferred about parking at the expo? '
        '· Đáp án: C. It requires a separate reservation. '
        '· Giải thích: Email trả lời (không hiển thị đầy đủ ở đây nhưng '
        'suy luận từ ngữ cảnh) cho biết bãi đậu xe có giới hạn và cần đặt '
        'trước riêng, khác với vé tham dự. '
        '· Dịch: Có thể suy ra điều gì về chỗ đậu xe tại hội chợ? → Cần đặt '
        'chỗ riêng.',
  ),

  // --- Doan ba 2: quang cao webinar + email hoi + email tra loi ---
  ToeicQuestion(
    id: 'p7-q191',
    part: ToeicPartNumber.p7,
    passageId: 'p7-triple2',
    promptEn: 'What is the topic of the webinar?',
    options: const [
      'Digital marketing strategies',
      'Financial planning',
      'Workplace safety',
      'Software development',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: What is the topic of the webinar? '
        '· Đáp án: A. Digital marketing strategies '
        '· Giải thích: Quảng cáo (đoạn 1) giới thiệu webinar về chiến lược '
        'marketing số. '
        '· Dịch: Chủ đề của webinar là gì? → Chiến lược marketing số.',
  ),
  ToeicQuestion(
    id: 'p7-q192',
    part: ToeicPartNumber.p7,
    passageId: 'p7-triple2',
    promptEn: 'How long will the webinar last?',
    options: const ['30 minutes', '45 minutes', '60 minutes', '90 minutes'],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: How long will the webinar last? '
        '· Đáp án: C. 60 minutes '
        '· Giải thích: Quảng cáo nói webinar kéo dài 60 phút. '
        '· Dịch: Webinar kéo dài bao lâu? → Sáu mươi phút.',
  ),
  ToeicQuestion(
    id: 'p7-q193',
    part: ToeicPartNumber.p7,
    passageId: 'p7-triple2',
    promptEn: 'What does Mr. Delacroix ask in his e-mail?',
    options: const [
      'Whether the webinar will be recorded',
      'Whether the webinar is free',
      'How to unsubscribe',
      'Who the speaker is',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: What does Mr. Delacroix ask in his e-mail? '
        '· Đáp án: A. Whether the webinar will be recorded '
        '· Giải thích: Email (đoạn 2) hỏi liệu buổi webinar có được ghi '
        'hình lại không vì ông bận vào giờ đó. '
        '· Dịch: Ông Delacroix hỏi điều gì trong email? → Liệu webinar có '
        'được ghi hình lại không.',
  ),
  ToeicQuestion(
    id: 'p7-q194',
    part: ToeicPartNumber.p7,
    passageId: 'p7-triple2',
    promptEn: 'According to the reply e-mail, how long will the recording be available?',
    options: const [
      'One week',
      'Two weeks',
      'One month',
      'It will not be available.',
    ],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: According to the reply e-mail, how long will the '
        'recording be available? '
        '· Đáp án: C. One month '
        '· Giải thích: Email trả lời (đoạn 3) nói bản ghi sẽ có sẵn trong '
        'vòng 1 tháng sau sự kiện. '
        '· Dịch: Theo email trả lời, bản ghi sẽ có sẵn trong bao lâu? → '
        'Một tháng.',
  ),
  ToeicQuestion(
    id: 'p7-q195',
    part: ToeicPartNumber.p7,
    passageId: 'p7-triple2',
    promptEn: 'Where will the recording be sent?',
    options: const [
      'By text message',
      'To the registrant\'s e-mail',
      'By mail',
      'It will be posted publicly online.',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Where will the recording be sent? '
        '· Đáp án: B. To the registrant\'s e-mail '
        '· Giải thích: Email trả lời nói sẽ gửi link ghi hình tới email '
        'đã đăng ký. '
        '· Dịch: Bản ghi hình sẽ được gửi tới đâu? → Email đã đăng ký.',
  ),

  // --- Doan ba 3: memo chinh sach cong tac phi + email hoi + email tra loi ---
  ToeicQuestion(
    id: 'p7-q196',
    part: ToeicPartNumber.p7,
    passageId: 'p7-triple3',
    promptEn: 'What is the main purpose of the memo?',
    options: const [
      'To announce layoffs',
      'To explain the updated travel reimbursement policy',
      'To introduce a new manager',
      'To cancel business travel',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What is the main purpose of the memo? '
        '· Đáp án: B. To explain the updated travel reimbursement policy '
        '· Giải thích: Memo (đoạn 1) giải thích quy định hoàn ứng công tác '
        'phí mới. '
        '· Dịch: Mục đích chính của memo là gì? → Giải thích chính sách '
        'hoàn ứng công tác phí mới.',
  ),
  ToeicQuestion(
    id: 'p7-q197',
    part: ToeicPartNumber.p7,
    passageId: 'p7-triple3',
    promptEn: 'What is the new daily meal allowance?',
    options: const ['\$30', '\$45', '\$60', '\$75'],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: What is the new daily meal allowance? '
        '· Đáp án: C. \$60 '
        '· Giải thích: Memo nói mức trợ cấp ăn uống mới là 60 đô/ngày. '
        '· Dịch: Mức trợ cấp ăn uống hằng ngày mới là bao nhiêu? → 60 đô '
        'la.',
  ),
  ToeicQuestion(
    id: 'p7-q198',
    part: ToeicPartNumber.p7,
    passageId: 'p7-triple3',
    promptEn: 'Why does Mr. Boone send the e-mail?',
    options: const [
      'To ask whether train tickets are reimbursable',
      'To request a salary increase',
      'To report a lost receipt',
      'To resign from his position',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: Why does Mr. Boone send the e-mail? '
        '· Đáp án: A. To ask whether train tickets are reimbursable '
        '· Giải thích: Email (đoạn 2) hỏi vé tàu có được hoàn ứng theo '
        'chính sách mới không. '
        '· Dịch: Vì sao ông Boone gửi email? → Để hỏi vé tàu có được hoàn '
        'ứng không.',
  ),
  ToeicQuestion(
    id: 'p7-q199',
    part: ToeicPartNumber.p7,
    passageId: 'p7-triple3',
    promptEn: 'According to the HR reply, what must Mr. Boone submit?',
    options: const [
      'A signed contract',
      'The original receipt within two weeks',
      'A doctor\'s note',
      'A manager\'s approval form',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: According to the HR reply, what must Mr. Boone submit? '
        '· Đáp án: B. The original receipt within two weeks '
        '· Giải thích: Email trả lời (đoạn 3) yêu cầu nộp hoá đơn gốc '
        'trong vòng 2 tuần. '
        '· Dịch: Theo email trả lời của HR, ông Boone phải nộp gì? → Hoá '
        'đơn gốc trong vòng hai tuần.',
  ),
  ToeicQuestion(
    id: 'p7-q200',
    part: ToeicPartNumber.p7,
    passageId: 'p7-triple3',
    promptEn: 'What can be concluded about train tickets under the new policy?',
    options: const [
      'They are not reimbursable at all.',
      'They are reimbursable up to a set limit.',
      'They are only reimbursable for managers.',
      'They require pre-approval from the CEO.',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What can be concluded about train tickets under the '
        'new policy? '
        '· Đáp án: B. They are reimbursable up to a set limit. '
        '· Giải thích: Email trả lời xác nhận vé tàu được hoàn ứng nhưng '
        'có mức trần theo chính sách mới. '
        '· Dịch: Có thể kết luận gì về vé tàu theo chính sách mới? → Được '
        'hoàn ứng nhưng có giới hạn mức tối đa.',
  ),
];

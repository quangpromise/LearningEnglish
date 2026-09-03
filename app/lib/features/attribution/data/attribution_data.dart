/// Ghi công cho tài sản (âm thanh/lời) cấp phép bởi bên thứ ba, hiển thị
/// TRONG app — trước đây chỉ nằm trong `ATTRIBUTION.md` (văn xuôi, trong
/// git), người dùng nhận APK chứ không nhận repo nên không bao giờ thấy
/// được. CC-BY yêu cầu ghi công đi kèm bản phân phối, xem
/// docs/architecture-multimedia-platform.md §A.7.
///
/// Tách khỏi `Song` (songs_data.dart) thay vì thêm trường vào đó — 20 bài
/// hiện có dùng chung 1 tác giả/giấy phép, chỉ khác `sourceUrl`; giữ
/// `songs_data.dart` nguyên vẹn để không đụng tới trải nghiệm nghe nhạc hiện
/// tại. Khoá theo `songTitle` (khớp `Song.title`) — xem
/// `attribution_data_test.dart` để biết bất biến "phủ đủ mọi bài trong
/// kSongs" được bảo chứng thế nào.
class Attribution {
  const Attribution({
    required this.songTitle,
    required this.creator,
    required this.creatorUrl,
    required this.licenseId,
    required this.licenseUrl,
    required this.sourceUrl,
  });

  final String songTitle;
  final String creator;
  final String creatorUrl;
  final String licenseId;
  final String licenseUrl;
  final String sourceUrl;
}

const _creator = 'Josh Woodward';
const _creatorUrl = 'https://www.joshwoodward.com/';
const _licenseId = 'CC-BY 4.0';
const _licenseUrl = 'https://creativecommons.org/licenses/by/4.0/';

/// Nguồn = ATTRIBUTION.md, đồng bộ 1-1 với `kSongs` trong songs_data.dart
/// (cùng thứ tự, cùng 20 bài) — thêm bài mới vào `kSongs` mà quên thêm dòng
/// tương ứng ở đây sẽ bị `attribution_data_test.dart` bắt lỗi ngay ở CI.
const kSongAttributions = <Attribution>[
  Attribution(
    songTitle: "Don't Close Your Eyes",
    creator: _creator,
    creatorUrl: _creatorUrl,
    licenseId: _licenseId,
    licenseUrl: _licenseUrl,
    sourceUrl: 'https://www.joshwoodward.com/song/DontCloseYourEyes',
  ),
  Attribution(
    songTitle: 'Circles',
    creator: _creator,
    creatorUrl: _creatorUrl,
    licenseId: _licenseId,
    licenseUrl: _licenseUrl,
    sourceUrl: 'https://www.joshwoodward.com/song/Circles',
  ),
  Attribution(
    songTitle: 'Same Boat',
    creator: _creator,
    creatorUrl: _creatorUrl,
    licenseId: _licenseId,
    licenseUrl: _licenseUrl,
    sourceUrl: 'https://www.joshwoodward.com/song/SameBoat',
  ),
  Attribution(
    songTitle: 'A Thousand Years',
    creator: _creator,
    creatorUrl: _creatorUrl,
    licenseId: _licenseId,
    licenseUrl: _licenseUrl,
    sourceUrl: 'https://www.joshwoodward.com/song/AThousandYears',
  ),
  Attribution(
    songTitle: 'California Lullabye',
    creator: _creator,
    creatorUrl: _creatorUrl,
    licenseId: _licenseId,
    licenseUrl: _licenseUrl,
    sourceUrl: 'https://www.joshwoodward.com/song/CaliforniaLullabye',
  ),
  Attribution(
    songTitle: 'Cherubs',
    creator: _creator,
    creatorUrl: _creatorUrl,
    licenseId: _licenseId,
    licenseUrl: _licenseUrl,
    sourceUrl: 'https://www.joshwoodward.com/song/Cherubs',
  ),
  Attribution(
    songTitle: 'Crazy Glue',
    creator: _creator,
    creatorUrl: _creatorUrl,
    licenseId: _licenseId,
    licenseUrl: _licenseUrl,
    sourceUrl: 'https://www.joshwoodward.com/song/CrazyGlue',
  ),
  Attribution(
    songTitle: 'Flickering Flame',
    creator: _creator,
    creatorUrl: _creatorUrl,
    licenseId: _licenseId,
    licenseUrl: _licenseUrl,
    sourceUrl: 'https://www.joshwoodward.com/song/FlickeringFlame',
  ),
  Attribution(
    songTitle: 'Goodbye to Spring',
    creator: _creator,
    creatorUrl: _creatorUrl,
    licenseId: _licenseId,
    licenseUrl: _licenseUrl,
    sourceUrl: 'https://www.joshwoodward.com/song/GoodbyeToSpring',
  ),
  Attribution(
    songTitle: "I'm Letting Go",
    creator: _creator,
    creatorUrl: _creatorUrl,
    licenseId: _licenseId,
    licenseUrl: _licenseUrl,
    sourceUrl: 'https://www.joshwoodward.com/song/ImLettingGo',
  ),
  Attribution(
    songTitle: 'Let It In',
    creator: _creator,
    creatorUrl: _creatorUrl,
    licenseId: _licenseId,
    licenseUrl: _licenseUrl,
    sourceUrl: 'https://www.joshwoodward.com/song/LetItIn',
  ),
  Attribution(
    songTitle: 'My Favorite Regret',
    creator: '$_creator feat. Katie Pederson',
    creatorUrl: _creatorUrl,
    licenseId: _licenseId,
    licenseUrl: _licenseUrl,
    sourceUrl: 'https://www.joshwoodward.com/song/MyFavoriteRegret',
  ),
  Attribution(
    songTitle: 'Release',
    creator: _creator,
    creatorUrl: _creatorUrl,
    licenseId: _licenseId,
    licenseUrl: _licenseUrl,
    sourceUrl: 'https://www.joshwoodward.com/song/Release',
  ),
  Attribution(
    songTitle: 'Saboteurs',
    creator: _creator,
    creatorUrl: _creatorUrl,
    licenseId: _licenseId,
    licenseUrl: _licenseUrl,
    sourceUrl: 'https://www.joshwoodward.com/song/Saboteurs',
  ),
  Attribution(
    songTitle: 'She Dreams in Blue',
    creator: _creator,
    creatorUrl: _creatorUrl,
    licenseId: _licenseId,
    licenseUrl: _licenseUrl,
    sourceUrl: 'https://www.joshwoodward.com/song/SheDreamsinBlue',
  ),
  Attribution(
    songTitle: 'Swansong',
    creator: _creator,
    creatorUrl: _creatorUrl,
    licenseId: _licenseId,
    licenseUrl: _licenseUrl,
    sourceUrl: 'https://www.joshwoodward.com/song/Swansong',
  ),
  Attribution(
    songTitle: 'The Box',
    creator: _creator,
    creatorUrl: _creatorUrl,
    licenseId: _licenseId,
    licenseUrl: _licenseUrl,
    sourceUrl: 'https://www.joshwoodward.com/song/TheBox',
  ),
  Attribution(
    songTitle: 'The Long Fade',
    creator: _creator,
    creatorUrl: _creatorUrl,
    licenseId: _licenseId,
    licenseUrl: _licenseUrl,
    sourceUrl: 'https://www.joshwoodward.com/song/TheLongFade',
  ),
  Attribution(
    songTitle: 'The Maze',
    creator: _creator,
    creatorUrl: _creatorUrl,
    licenseId: _licenseId,
    licenseUrl: _licenseUrl,
    sourceUrl: 'https://www.joshwoodward.com/song/TheMaze',
  ),
  Attribution(
    songTitle: 'The Nest',
    creator: _creator,
    creatorUrl: _creatorUrl,
    licenseId: _licenseId,
    licenseUrl: _licenseUrl,
    sourceUrl: 'https://www.joshwoodward.com/song/TheNest',
  ),
];

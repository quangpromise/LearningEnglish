/// Dinh dang ngay/thang/nam DUNG CHUNG cho toan app (ca 3 mini-app: Hoc
/// Tieng Anh/Fitness/Wealth) - CHUAN MM/dd/yyyy theo yeu cau, KHONG dung
/// package `intl` (chua co san trong pubspec.yaml, tranh them dependency
/// moi chi cho vai dong dinh dang ngay).
///
/// CHI danh cho hien thi 1 MOC NGAY CU THE (lich su giao dich, ngay het han
/// dich vu, ngay dao han khoan no...) - KHONG danh cho nhan thoi gian tuong
/// doi kieu Messenger ("5 phut truoc", "Hom qua") o core/utils/time_format.dart,
/// von la 1 UX pattern khac hoan toan.
String _two(int n) => n.toString().padLeft(2, '0');

/// "MM/dd/yyyy" - dung cho moi nen tang hien 1 ngay day du (lich su vi/giao
/// dich, ngay het han dich vu/no...).
String formatDateMdy(DateTime d) => '${_two(d.month)}/${_two(d.day)}/${d.year}';

/// "MM/dd" (khong nam) - dung khi ngu canh da ro nam (vd nhan trong cung 1
/// nam) hoac khong gian hep khong du hien ca nam.
String formatDateMd(DateTime d) => '${_two(d.month)}/${_two(d.day)}';

/// "MM/yy" - dung cho nhan truc bieu do khi xem theo THANG (moi diem = 1
/// thang, khong can hien den ngay).
String formatMonthYy(DateTime d) => '${_two(d.month)}/${_two(d.year % 100)}';

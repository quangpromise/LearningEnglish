/// Format thoi gian kieu Facebook/Messenger: trong ngay hom nay hien tuong
/// doi ("X phut truoc"/"X gio truoc"), khac ngay hien ngay/gio cu the -
/// khong dung package `intl` de tranh them dependency chi cho vai dong so.
String _two(int n) => n.toString().padLeft(2, '0');

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Dung cho danh sach hoi thoai (dong 1 dong, can ngan gon).
String formatConversationTime(DateTime dt) {
  final now = DateTime.now();
  final local = dt.toLocal();
  final diff = now.difference(local);

  if (_isSameDay(now, local)) {
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    return '${diff.inHours} giờ trước';
  }
  final yesterday = now.subtract(const Duration(days: 1));
  if (_isSameDay(yesterday, local)) return 'Hôm qua';
  if (now.year == local.year) {
    return '${_two(local.day)}/${_two(local.month)}';
  }
  return '${_two(local.day)}/${_two(local.month)}/${local.year}';
}

/// Dung cho nhan thoi gian duoi tung bubble tin nhan trong 1 cuoc hoi
/// thoai - can chi tiet hon (co gio:phut) vi nguoi dung dang xem lai lich
/// su nhan tin, khong chi luot qua danh sach.
String formatBubbleTime(DateTime dt) {
  final now = DateTime.now();
  final local = dt.toLocal();
  final time = '${_two(local.hour)}:${_two(local.minute)}';

  if (_isSameDay(now, local)) return time;
  final yesterday = now.subtract(const Duration(days: 1));
  if (_isSameDay(yesterday, local)) return 'Hôm qua $time';
  if (now.year == local.year) {
    return '${_two(local.day)}/${_two(local.month)} $time';
  }
  return '${_two(local.day)}/${_two(local.month)}/${local.year} $time';
}

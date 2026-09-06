import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/utils/date_format.dart';

void main() {
  group('formatDateMdy', () {
    test('luon co dang MM/dd/yyyy, dem thang/ngay co 0 dung dau', () {
      expect(formatDateMdy(DateTime(2026, 9, 6)), '09/06/2026');
    });

    test('khong dem 0 thua khi thang/ngay da 2 chu so', () {
      expect(formatDateMdy(DateTime(2026, 12, 25)), '12/25/2026');
    });
  });

  group('formatDateMd', () {
    test('MM/dd, khong hien nam', () {
      expect(formatDateMd(DateTime(2026, 9, 6)), '09/06');
    });
  });

  group('formatMonthYy', () {
    test('MM/yy, dem 0 dung dau ca thang lan nam', () {
      expect(formatMonthYy(DateTime(2026, 9, 6)), '09/26');
    });

    test('nam tron the ky (vd 2000) van ra 00', () {
      expect(formatMonthYy(DateTime(2000, 1, 1)), '01/00');
    });
  });
}

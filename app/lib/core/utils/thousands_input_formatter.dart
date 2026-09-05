import 'package:flutter/services.dart';

/// Tu dong chen dau `,` phan cach hang nghin khi go so tien - giup de doc
/// (vd go "1000000" hien ngay "1,000,000") trong luc go, khong doi cach luu
/// tru (parse lai bang [parseThousandsFormatted] truoc khi luu, bo dau phay).
/// Dat con tro luon o cuoi - don gian, du dung cho cac o nhap so tien 1
/// chieu (go tu trai qua phai, khong sua giua chung) nhu cac sheet trong
/// Quan ly tai san.
class ThousandsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final dotIndex = newValue.text.indexOf('.');
    var intPart = dotIndex == -1
        ? newValue.text
        : newValue.text.substring(0, dotIndex);
    final decPart = dotIndex == -1
        ? ''
        : newValue.text.substring(dotIndex).replaceAll(RegExp(r'[^0-9.]'), '');
    intPart = intPart.replaceAll(RegExp(r'[^0-9]'), '');
    if (intPart.isEmpty) {
      return TextEditingValue(
        text: decPart,
        selection: TextSelection.collapsed(offset: decPart.length),
      );
    }
    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write(',');
      buffer.write(intPart[i]);
    }
    final formatted = '$buffer$decPart';
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Bo dau `,` phan cach hang nghin do [ThousandsInputFormatter] chen vao
/// truoc khi parse ve double - dung thay cho `.replaceAll(',', '.')` cu (quy
/// uoc CU dung `,` lam dau THAP PHAN, khong con phu hop khi `,` gio la dau
/// phan cach hang nghin).
double? parseThousandsFormatted(String text) =>
    double.tryParse(text.trim().replaceAll(',', ''));

/// Dinh dang 1 so co san (vd gia tri cu khi mo sheet o CHE DO SUA) ve dang
/// co dau `,` phan cach hang nghin de GAN THANG vao `controller.text` - khac
/// [ThousandsInputFormatter] (chi ap dung khi NGUOI DUNG go, khong tu chay
/// lai khi code gan `.text` truc tiep).
String groupThousands(num value) {
  final rounded = value.round();
  final digits = rounded.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return '${rounded < 0 ? '-' : ''}$buffer';
}

/// Nhu [groupThousands] nhung giu lai phan thap phan (vd 1234.5 voi
/// decimals=2 -> "1,234.50") - dung hien thi gia USD (khac VND luon lam
/// tron so nguyen).
String groupThousandsDecimal(num value, {int decimals = 2}) {
  final isNeg = value < 0;
  final abs = value.abs();
  final whole = abs.truncate();
  if (decimals == 0) return '${isNeg ? '-' : ''}${groupThousands(whole)}';
  final scale = List.filled(decimals, 10).fold<int>(1, (a, b) => a * b);
  final fracDigits = ((abs - whole) * scale).round().toString().padLeft(
    decimals,
    '0',
  );
  return '${isNeg ? '-' : ''}${groupThousands(whole)}.$fracDigits';
}

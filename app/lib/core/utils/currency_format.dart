/// Dinh dang tien te cho khu vuc Quan ly tai san - viet tay bang regex thay
/// vi them dependency `intl` moi (dung quy uoc "khong them dep khi chua can"
/// cua du an). VND dung dau PHAY phan cach hang nghin (theo yeu cau nguoi
/// dung, dong bo voi cach go so tien co dau phay o cac o nhap - xem
/// ThousandsInputFormatter), USD cung dau phay (chuan quoc te) + dau cham
/// thap phan.
/// 1 troy ounce (31.1034768g) tinh theo don vi "luong" VN (37.5g/luong) -
/// dung de quy doi gia vang quoc te (USD/oz, vd tu XAUT) sang VND/luong,
/// cung cong thuc voi supabase/functions/wealth-vn-assets/index.ts
/// (TROY_OUNCE_TO_LUONG) de nhat quan giua backend va client.
const kTroyOunceToLuong = 31.1034768 / 37.5;

String formatVnd(num value) {
  final rounded = value.round();
  final negative = rounded < 0;
  final digits = rounded.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return '${negative ? '-' : ''}$buffer ₫';
}

String formatUsd(num value) {
  final negative = value < 0;
  final fixed = value.abs().toStringAsFixed(2);
  final parts = fixed.split('.');
  final intDigits = parts[0];
  final buffer = StringBuffer();
  for (var i = 0; i < intDigits.length; i++) {
    if (i > 0 && (intDigits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(intDigits[i]);
  }
  return '${negative ? '-' : ''}\$$buffer.${parts[1]}';
}

/// Dinh dang theo ma tien te bat ky (chi ho tro VND/USD - 2 loai duy nhat
/// dung trong tinh nang Wealth).
String formatByCurrency(num value, String currency) {
  return currency == 'USD' ? formatUsd(value) : formatVnd(value);
}

/// 1 ngan hang Viet Nam de chon khi them so du "Tien ngan hang" trong Vi -
/// lay tu VietQR (xem [VnBankRepository]). `kOtherBankCode` la 1 gia tri dac
/// biet cho phep nguoi dung tu go ten ngan hang khong co trong danh sach.
const kOtherBankCode = 'OTHER';

class VnBank {
  const VnBank({
    required this.code,
    required this.shortName,
    required this.name,
    required this.logoUrl,
  });

  final String code;
  final String shortName;
  final String name;
  final String? logoUrl;

  bool get isOther => code == kOtherBankCode;

  factory VnBank.fromJson(Map<String, dynamic> json) => VnBank(
    code: json['code'] as String,
    shortName: json['shortName'] as String,
    name: json['name'] as String,
    logoUrl: json['logoUrl'] as String?,
  );

  static const other = VnBank(
    code: kOtherBankCode,
    shortName: 'Khác',
    name: 'Ngân hàng khác (tự nhập)',
    logoUrl: null,
  );
}

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/env.dart';

class UpdateInfo {
  const UpdateInfo({required this.downloadUrl, required this.releasedAt});
  final String downloadUrl;
  final String releasedAt;
}

const _repo = 'quangpromise/LearningEnglish';

/// Kiểm tra xem GitHub Release "latest" có phải bản mới hơn bản app đang
/// chạy không, bằng cách so commit SHA đóng gói sẵn trong app (BUILD_SHA)
/// với SHA của bản build mới nhất (file version.txt đính kèm trong release —
/// xem .github/workflows/build-apk.yml).
///
/// Trả về null nếu: chưa cấu hình BUILD_SHA (build cục bộ), không có mạng,
/// hoặc app đang chạy đã là bản mới nhất.
Future<UpdateInfo?> checkForUpdate() async {
  if (Env.buildSha.isEmpty) return null;

  try {
    final releaseRes = await http
        .get(
          Uri.parse('https://api.github.com/repos/$_repo/releases/tags/latest'),
        )
        .timeout(const Duration(seconds: 8));
    if (releaseRes.statusCode != 200) return null;

    final release = jsonDecode(releaseRes.body) as Map<String, dynamic>;
    final assets = (release['assets'] as List).cast<Map<String, dynamic>>();

    final versionAsset = assets
        .where((a) => a['name'] == 'version.txt')
        .firstOrNull;
    // "app-release.apk" la ban universal (gom ca arm64-v8a/armeabi-v7a/x86_64
    // trong 1 file) - dung ban nay cho AUTO-UPDATE de cai duoc tren MOI may,
    // khong phu thuoc kien truc chip cua tung may (xem build-apk.yml va
    // docs/ci-apk-distribution.md).
    final apkAsset = assets
        .where((a) => a['name'] == 'app-release.apk')
        .firstOrNull;
    if (versionAsset == null || apkAsset == null) return null;

    final shaRes = await http
        .get(Uri.parse(versionAsset['browser_download_url'] as String))
        .timeout(const Duration(seconds: 8));
    if (shaRes.statusCode != 200) return null;

    final latestSha = shaRes.body.trim();
    if (latestSha.isEmpty || latestSha == Env.buildSha) return null;

    return UpdateInfo(
      downloadUrl: apkAsset['browser_download_url'] as String,
      releasedAt: release['published_at'] as String? ?? '',
    );
  } catch (_) {
    // Không có mạng hoặc GitHub API lỗi tạm thời — bỏ qua, không làm phiền user.
    return null;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

/// Ban chi tiet cua checkForUpdate() dung cho nut "Kiem tra cap nhat" thu
/// cong trong man Ho so - checkForUpdate() im lang tra ve null khi that bai
/// (dung cho kiem tra ngam luc mo app, khong lam phien nguoi dung), con o
/// day tra ve mo ta ro TUNG BUOC, giup tu chan doan khi khong thay thong
/// bao tu dong (vd bi GitHub rate-limit tren mang di dong - rat pho bien voi
/// API khong xac thuc tu IP dung chung nha mang, cache CDN cua Release chua
/// kip cap nhat...) thay vi phai doan mo qua lai nhieu vong nhu da xay ra.
Future<String> debugCheckForUpdate() async {
  if (Env.buildSha.isEmpty) {
    return 'Bản build cục bộ (không có BUILD_SHA đóng gói sẵn) - không kiểm tra được. Chỉ hoạt động với bản build từ CI.';
  }
  try {
    final releaseRes = await http
        .get(
          Uri.parse('https://api.github.com/repos/$_repo/releases/tags/latest'),
        )
        .timeout(const Duration(seconds: 8));
    if (releaseRes.statusCode != 200) {
      return 'GitHub API trả về lỗi HTTP ${releaseRes.statusCode}.\n'
          '${releaseRes.statusCode == 403 ? "Rất có thể do bị rate-limit (mạng của bạn gọi API GitHub không xác thực quá nhiều lần trong 1 giờ)." : releaseRes.body}';
    }

    final release = jsonDecode(releaseRes.body) as Map<String, dynamic>;
    final assets = (release['assets'] as List).cast<Map<String, dynamic>>();
    final versionAsset = assets
        .where((a) => a['name'] == 'version.txt')
        .firstOrNull;
    final apkAsset = assets
        .where((a) => a['name'] == 'app-release.apk')
        .firstOrNull;
    if (versionAsset == null || apkAsset == null) {
      return 'Release "latest" trên GitHub thiếu file version.txt hoặc APK.';
    }

    final shaRes = await http
        .get(Uri.parse(versionAsset['browser_download_url'] as String))
        .timeout(const Duration(seconds: 8));
    if (shaRes.statusCode != 200) {
      return 'Không tải được version.txt (HTTP ${shaRes.statusCode}).';
    }

    final latestSha = shaRes.body.trim();
    final runningShaShort = Env.buildSha.length > 7
        ? Env.buildSha.substring(0, 7)
        : Env.buildSha;
    final latestShaShort = latestSha.length > 7
        ? latestSha.substring(0, 7)
        : latestSha;
    return 'Bản đang chạy: $runningShaShort\n'
        'Bản mới nhất trên GitHub: $latestShaShort\n'
        '${latestSha == Env.buildSha ? "-> Đã là bản mới nhất, không có gì để thông báo." : "-> CÓ bản mới hơn - lẽ ra phải thấy popup. Thử mở lại app hoặc kiểm tra mạng."}';
  } catch (e) {
    return 'Lỗi khi kiểm tra: $e';
  }
}

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
        .get(Uri.parse('https://api.github.com/repos/$_repo/releases/tags/latest'))
        .timeout(const Duration(seconds: 8));
    if (releaseRes.statusCode != 200) return null;

    final release = jsonDecode(releaseRes.body) as Map<String, dynamic>;
    final assets = (release['assets'] as List).cast<Map<String, dynamic>>();

    final versionAsset = assets.where((a) => a['name'] == 'version.txt').firstOrNull;
    final apkAsset = assets.where((a) => a['name'] == 'app-arm64-v8a-release.apk').firstOrNull;
    if (versionAsset == null || apkAsset == null) return null;

    final shaRes = await http.get(Uri.parse(versionAsset['browser_download_url'] as String)).timeout(const Duration(seconds: 8));
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

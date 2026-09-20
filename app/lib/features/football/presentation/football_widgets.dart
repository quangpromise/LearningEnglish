import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/football_models.dart';

/// Mau nhan RIENG cua khu vuc Football - dat o day (khong them vao
/// [AppColors]) de module bong da khong cham vao file theme dung chung.
/// Nen/kinh/bo goc/font van lay tu AppColors + AppTextStyles nhu moi man
/// khac, chi rieng 3 mau chuc nang duoi la cua Football.
class FootballColors {
  FootballColors._();

  /// Do - CHI dung cho trang thai dang thi dau (nhan LIVE, phut thi dau).
  static const live = Color(0xFFFF3B4E);

  /// Xanh dien - dieu huong, nhan giai dau.
  static const electric = Color(0xFF4DA3FF);

  /// Ban thang / thang tran - tai dung [AppColors.teal] cho dong bo voi phan
  /// con lai cua app (dap an dung, hoan thanh...).
  static const goal = AppColors.teal;
}

/// Huy hieu doi bong.
///
/// QUAN TRONG - day khong phai cho tam: logo CLB/giai dau la NHAN HIEU cua
/// CLB va UEFA, khong nha cung cap du lieu nao cap quyen su dung lai (da kiem
/// tra ca 8 nguon, xem docs/research-football-standings-source.md). Vi vay:
///   * KHONG tai ve tu host - chi hotlink CDN cua nha cung cap.
///   * LUON co duong lui: anh loi/khong co quyen -> ve huy hieu chu viet tat
///     tu chinh ten doi, mau suy ra tu ten nen moi doi 1 mau on dinh.
class TeamBadge extends StatelessWidget {
  const TeamBadge({super.key, required this.team, this.size = 26, this.radius});

  final FootballTeam? team;
  final double size;
  final double? radius;

  /// Mau nen cua huy hieu chu - bam tu ten doi nen 1 doi luon ra 1 mau, va
  /// 2 doi khac nhau gan nhu chac chan khac mau.
  Color get _fallbackColor {
    final name = team?.name ?? '';
    if (name.isEmpty) return AppColors.glassFill;
    var hash = 0;
    for (final code in name.codeUnits) {
      hash = (hash * 31 + code) & 0x7fffffff;
    }
    // Giu do bao hoa/sang co dinh de moi huy hieu deu doc duoc chu trang tren nen.
    return HSLColor.fromAHSL(1, (hash % 360).toDouble(), 0.55, 0.42).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final r = radius ?? size * 0.3;
    final logo = team?.logoUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(r),
      child: SizedBox(
        width: size,
        height: size,
        child: logo == null || logo.isEmpty
            ? _initialsBadge(r)
            : Image.network(
                logo,
                fit: BoxFit.contain,
                // Dang tai: hien san huy hieu chu thay vi o trong nhay nhay.
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : _initialsBadge(r),
                errorBuilder: (_, _, _) => _initialsBadge(r),
              ),
      ),
    );
  }

  Widget _initialsBadge(double r) {
    return Container(
      decoration: BoxDecoration(
        color: _fallbackColor,
        borderRadius: BorderRadius.circular(r),
      ),
      alignment: Alignment.center,
      child: Text(
        team?.initials ?? '?',
        style: AppTextStyles.heading(
          size: size * 0.34,
        ).copyWith(color: Colors.white, fontWeight: FontWeight.w800, height: 1),
      ),
    );
  }
}

/// Nhan "LIVE" nhap nhay nhe - chi dung cho tran dang da.
class LivePill extends StatelessWidget {
  const LivePill({super.key, this.minute});

  /// Phut thi dau; null thi chi hien chu LIVE.
  final int? minute;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: FootballColors.live.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: FootballColors.live.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: FootballColors.live,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            minute == null ? 'LIVE' : "$minute'",
            style: AppTextStyles.heading(size: 10).copyWith(
              color: FootballColors.live,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dai phong do 5 tran gan nhat: W xanh / D xam / L hong.
class FormStrip extends StatelessWidget {
  const FormStrip({super.key, required this.form, this.dotSize = 15});

  /// Chuoi 'WDLWW' - tran CU NHAT dung truoc.
  final String? form;
  final double dotSize;

  @override
  Widget build(BuildContext context) {
    final value = form;
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final c in value.split(''))
          Container(
            width: dotSize,
            height: dotSize,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: switch (c) {
                'W' => AppColors.teal,
                'L' => AppColors.pink,
                _ => const Color(0xFF8B93A7),
              },
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: Text(
              c,
              style: AppTextStyles.heading(size: dotSize * 0.55).copyWith(
                color: const Color(0xFF0B1220),
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
      ],
    );
  }
}

/// Trang thai rong dung chung - KHONG bao gio hien du lieu gia khi API chua
/// tra ve (yeu cau muc 18 cua de bai).
class FootballEmptyState extends StatelessWidget {
  const FootballEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.sports_soccer_rounded,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 34,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.muted(size: 12),
          ),
        ],
      ),
    );
  }
}

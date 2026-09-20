import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/app_strings.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/program_model.dart';
import 'fitness_home_theme.dart';

/// Anh + icon dai dien cho tung giao an. Ba anh nay duoc cat ra tu chinh
/// file thiet ke cua chu du an (xem docs/design/fitness-redesign/README.md),
/// phan chu/icon in san o day the da duoc xoa de widget tu ve len tren.
/// Map theo Y NGHIA giao an chu khong theo id: anh nguoi moi tap -> giao an
/// de nhat, anh day ta nam -> giao an tang co, anh cardio -> giao an giam
/// mo. Giao an moi chua co trong bang nay dung [_fallbackArt].
class _ProgramArt {
  const _ProgramArt(this.image, this.icon);

  final String image;
  final IconData icon;
}

const _programArt = <int, _ProgramArt>{
  // 1 = Tang co toan than 8 tuan, 2 = Suc manh co ban 5x5,
  // 3 = Giam mo 30 ngay tai nha (xem assets/fitness/programs_seed.json).
  1: _ProgramArt(
    'assets/fitness/home/program_muscle.jpg',
    Icons.fitness_center_rounded,
  ),
  2: _ProgramArt(
    'assets/fitness/home/program_beginner.jpg',
    Icons.sports_gymnastics_rounded,
  ),
  3: _ProgramArt(
    'assets/fitness/home/program_fatloss.jpg',
    Icons.directions_run_rounded,
  ),
};

const _fallbackArt = _ProgramArt(
  'assets/fitness/home/program_beginner.jpg',
  Icons.fitness_center_rounded,
);

/// Hang the giao an cuon ngang o Trang chu. Doc tu [programListProvider]
/// (noi dung that trong assets/fitness/programs_seed.json), sap xep de giao
/// an de nhat dung dau - dung thu tu nhu anh thiet ke.
class FitnessProgramCarousel extends ConsumerWidget {
  const FitnessProgramCarousel({super.key, required this.onOpenProgram});

  final void Function(Program program) onOpenProgram;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programsAsync = ref.watch(programListProvider);
    final programs = programsAsync.valueOrNull;

    if (programs == null) {
      // Dang tai / loi doc file giao an: giu dung chieu cao hang de phan
      // ben duoi khong nhay len roi tut xuong.
      return const SizedBox(height: FitnessHome.programCardHeight);
    }

    final sorted = [...programs]
      ..sort(
        (a, b) =>
            (a.difficulty?.steps ?? 0).compareTo(b.difficulty?.steps ?? 0),
      );

    // Chia DEU cho vua khit be ngang thay vi cuon ngang voi be rong co
    // dinh: man Home khong cuon, nen the thu 3 ma bi cat mep la nguoi dung
    // khong con cach nao thay du no.
    const gap = 10.0;
    return SizedBox(
      height: FitnessHome.programCardHeight,
      child: Row(
        children: [
          for (var i = 0; i < sorted.length; i++) ...[
            Expanded(
              child: _ProgramCard(
                program: sorted[i],
                art: _programArt[sorted[i].id] ?? _fallbackArt,
                onTap: () => onOpenProgram(sorted[i]),
              ),
            ),
            if (i != sorted.length - 1) const SizedBox(width: gap),
          ],
        ],
      ),
    );
  }
}

class _ProgramCard extends ConsumerWidget {
  const _ProgramCard({
    required this.program,
    required this.art,
    required this.onTap,
  });

  final Program program;
  final _ProgramArt art;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FitnessPressable(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(FitnessHome.programRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(art.image, fit: BoxFit.cover),
            // Lop phu toi dan xuong duoi - chu o day the phai doc duoc
            // tren moi anh.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.6, 1],
                  colors: [
                    Color(0x00050505),
                    Color(0x26050505),
                    Color(0x8C060606),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 9,
              bottom: 9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(art.icon, size: 19, color: FitnessHome.red),
                  const SizedBox(height: 7),
                  Text(
                    // Ten giao an theo ngon ngu giao dien dang chon - de
                    // nguyen titleVi thi nguoi chon tieng Anh van thay
                    // tieng Viet ngay o man dau tien.
                    program.titleFor(ref.watch(appLanguageProvider)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(
                      size: 12,
                      weight: FontWeight.w700,
                    ).copyWith(height: 1.2),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ref.tr(program.levelLabelKey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FitnessHome.bodySecondary(size: 10),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: Color(0xFF9A9A9A),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

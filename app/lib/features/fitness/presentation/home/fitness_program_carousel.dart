import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/program_model.dart';
import 'fitness_home_theme.dart';

/// Anh + icon dai dien cho tung giao an. Dung anh bai tap DA CO SAN trong
/// app (assets/fitness/exercise_photos/) thay vi tai anh moi tu internet -
/// xem quy tac asset trong CLAUDE.md. Giao an moi chua co trong bang nay se
/// tu dong dung anh phong gym chung.
class _ProgramArt {
  const _ProgramArt(this.image, this.icon, this.alignment);

  final String image;
  final IconData icon;

  /// Diem neo khi cat anh vao o doc 116x102 - moi anh 1 khac vi chu the
  /// (nguoi dang tap) nam o vi tri khac nhau; de mac dinh can giua thi vai
  /// anh chi con thay tuong/san.
  final Alignment alignment;
}

const _programArt = <int, _ProgramArt>{
  1: _ProgramArt(
    'assets/fitness/exercise_photos/barbell_bench_press_0.jpg',
    Icons.fitness_center_rounded,
    Alignment(0.1, -0.35),
  ),
  2: _ProgramArt(
    'assets/fitness/exercise_photos/cable_hammer_curls_0.jpg',
    Icons.sports_gymnastics_rounded,
    Alignment(-0.15, -0.5),
  ),
  3: _ProgramArt(
    'assets/fitness/exercise_photos/rope_jumping_0.jpg',
    Icons.directions_run_rounded,
    Alignment(0, -0.45),
  ),
};

const _fallbackArt = _ProgramArt(
  'assets/fitness/fitness_background.jpg',
  Icons.fitness_center_rounded,
  Alignment.center,
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

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.program,
    required this.art,
    required this.onTap,
  });

  final Program program;
  final _ProgramArt art;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FitnessPressable(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(FitnessHome.programRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(art.image, fit: BoxFit.cover, alignment: art.alignment),
            // Lop phu toi dan xuong duoi - chu o day the phai doc duoc
            // tren moi anh.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.46, 1],
                  colors: [
                    Color(0x9E050505),
                    Color(0xD6050505),
                    Color(0xFF060606),
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
                    program.titleVi,
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
                          program.level,
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

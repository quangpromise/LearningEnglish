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
const _programArt = <int, (String, IconData)>{
  1: (
    'assets/fitness/exercise_photos/barbell_bench_press_0.jpg',
    Icons.fitness_center_rounded,
  ),
  2: (
    'assets/fitness/exercise_photos/cable_hammer_curls_0.jpg',
    Icons.sports_gymnastics_rounded,
  ),
  3: (
    'assets/fitness/exercise_photos/rope_jumping_0.jpg',
    Icons.directions_run_rounded,
  ),
};

const _fallbackArt = (
  'assets/fitness/fitness_background.jpg',
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

    return SizedBox(
      height: FitnessHome.programCardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        clipBehavior: Clip.none,
        itemCount: sorted.length,
        separatorBuilder: (_, _) => const SizedBox(width: 11),
        itemBuilder: (context, index) {
          final program = sorted[index];
          final art = _programArt[program.id] ?? _fallbackArt;
          return _ProgramCard(
            program: program,
            image: art.$1,
            icon: art.$2,
            onTap: () => onOpenProgram(program),
          );
        },
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.program,
    required this.image,
    required this.icon,
    required this.onTap,
  });

  final Program program;
  final String image;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FitnessPressable(
      onTap: onTap,
      child: SizedBox(
        width: FitnessHome.programCardWidth,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(FitnessHome.programRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(image, fit: BoxFit.cover),
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
                    Icon(icon, size: 19, color: FitnessHome.red),
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
      ),
    );
  }
}

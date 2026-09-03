import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import 'exercise_library_screen.dart';

/// Man hinh goc cua khu vuc Fitness - vao tu the "Fitness" trong Menu (xem
/// menu_screen.dart). Phase 1 chi co 1 man (Thu vien bai tap); cau truc rieng
/// biet voi RootShell (khong phai 1 tab moi) de sau nay de dang them cac khu
/// vuc khac (Chuong trinh tap, Dinh duong...) ben trong shell nay ma khong
/// dung cham gi den thanh dieu huong chinh cua GymTalk.
class FitnessShell extends ConsumerStatefulWidget {
  const FitnessShell({super.key});

  @override
  ConsumerState<FitnessShell> createState() => _FitnessShellState();
}

class _FitnessShellState extends ConsumerState<FitnessShell> {
  @override
  void initState() {
    super.initState();
    // Bat co "dang o Fitness" NGAY sau frame dau (khong lam trong initState
    // truc tiep - sua state cua 1 provider khac ngay luc build dang chay se
    // nem loi "Tried to modify a provider while the widget tree was building").
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(fitnessModeActiveProvider.notifier).state = true;
    });
  }

  @override
  void dispose() {
    // Doc ref truc tiep (khong qua context) vi dispose() chay sau khi
    // widget da bi go khoi cay, an toan de doc gia tri container o day.
    ref.read(fitnessModeActiveProvider.notifier).state = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const ExerciseLibraryScreen();
  }
}

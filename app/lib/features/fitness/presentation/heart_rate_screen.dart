import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/heart_rate_model.dart';
import '../data/heart_rate_service.dart';
import 'home/fitness_home_theme.dart';

/// Man do nhip tim bang camera + den flash (PPG).
///
/// Quy tac quan trong nhat cua man nay: KHONG BAO GIO hien 1 con so khi
/// phep do khong dat. Neu tin hieu nhieu (khong che kin ong kinh, rung
/// tay...) thi hien han trang thai "Khong do duoc nhip tim" kem huong dan,
/// chu khong doan bua. Xem them heart_rate_service.dart.
class HeartRateScreen extends ConsumerStatefulWidget {
  const HeartRateScreen({super.key});

  @override
  ConsumerState<HeartRateScreen> createState() => _HeartRateScreenState();
}

enum _Phase { idle, measuring, done, failed }

class _HeartRateScreenState extends ConsumerState<HeartRateScreen> {
  late final HeartRateService _service = CameraHeartRateService();

  _Phase _phase = _Phase.idle;
  HeartRateMeasurement? _result;
  HeartRateFailure? _failure;
  String? _debugInfo;

  @override
  void dispose() {
    // Bat buoc: neu roi man hinh giua chung, phai tat camera + den flash.
    _service.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _phase = _Phase.measuring;
      _result = null;
      _failure = null;
      _debugInfo = null;
    });
    final result = await _service.measure();
    if (!mounted) return;
    if (result.isSuccess) {
      await ref.read(heartRateRepositoryProvider).save(result.measurement!);
      ref.invalidate(heartRateHistoryProvider);
      if (!mounted) return;
      setState(() {
        _phase = _Phase.done;
        _result = result.measurement;
      });
      return;
    }
    setState(() {
      // Nguoi dung tu huy thi quay ve man chuan bi, khong coi la loi.
      _phase = result.failure == HeartRateFailure.cancelled
          ? _Phase.idle
          : _Phase.failed;
      _failure = result.failure;
      _debugInfo = result.debugInfo;
    });
  }

  Future<void> _cancel() async {
    await _service.cancel();
    if (!mounted) return;
    setState(() => _phase = _Phase.idle);
  }

  @override
  Widget build(BuildContext context) {
    return FitnessScreenScaffold(
      title: ref.tr('fitness_heart_rate_title'),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 8),
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: switch (_phase) {
              _Phase.idle => _IdleCard(
                key: const ValueKey('idle'),
                onStart: _start,
              ),
              _Phase.measuring => _MeasuringCard(
                key: const ValueKey('measuring'),
                service: _service,
                onCancel: _cancel,
              ),
              _Phase.done => _ResultCard(
                key: const ValueKey('done'),
                measurement: _result!,
                onRemeasure: _start,
              ),
              _Phase.failed => _FailureCard(
                key: const ValueKey('failed'),
                failure: _failure ?? HeartRateFailure.signalTooNoisy,
                debugInfo: _debugInfo,
                onRetry: _start,
              ),
            },
          ),
          const SizedBox(height: 16),
          const _TodayHistory(),
        ],
      ),
    );
  }
}

/// Truoc khi do: huong dan dat ngon tay + nut bat dau.
class _IdleCard extends ConsumerWidget {
  const _IdleCard({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FitnessCard(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      child: Column(
        children: [
          const _PulsingHeart(size: 62),
          const SizedBox(height: 16),
          Text(
            ref.tr('fitness_heart_rate_intro'),
            textAlign: TextAlign.center,
            style: AppTextStyles.heading(size: 16),
          ),
          const SizedBox(height: 14),
          for (final key in const [
            'fitness_heart_rate_step_1',
            'fitness_heart_rate_step_2',
            'fitness_heart_rate_step_3',
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: FitnessHome.red,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      ref.tr(key),
                      style: FitnessHome.bodySecondary(size: 12.5),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Text(
            ref.tr('fitness_heart_rate_disclaimer'),
            textAlign: TextAlign.center,
            style: FitnessHome.bodySecondary(size: 10.5),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: PillButton(
              label: ref.tr('fitness_heart_rate_start'),
              accentColor: FitnessHome.red,
              accentGradient: AppColors.fitnessAccentGradient,
              onTap: onStart,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dang do: vong tien do 0-100%, duong song truc tiep, nhac dat ngon tay
/// khi chua che kin ong kinh.
class _MeasuringCard extends ConsumerWidget {
  const _MeasuringCard({
    super.key,
    required this.service,
    required this.onCancel,
  });

  final HeartRateService service;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FitnessCard(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      child: Column(
        children: [
          ValueListenableBuilder<double>(
            valueListenable: service.progress,
            builder: (context, progress, _) => SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: FitnessHome.divider,
                      valueColor: const AlwaysStoppedAnimation(FitnessHome.red),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _PulsingHeart(size: 34),
                      const SizedBox(height: 6),
                      Text(
                        '${(progress * 100).round()}%',
                        style: AppTextStyles.heading(size: 24),
                      ),
                      Text(
                        ref
                            .tr('fitness_heart_rate_seconds_left')
                            .replaceFirst(
                              '{n}',
                              '${(kHeartRateMeasureSeconds * (1 - progress)).ceil()}',
                            ),
                        style: FitnessHome.bodySecondary(size: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Bao NGAY khi may bat duoc ngon tay, thay vi de nguoi dung cho
          // het 30 giay roi moi biet la dat sai cho.
          ValueListenableBuilder<bool>(
            valueListenable: service.sensorCovered,
            builder: (context, covered, _) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  covered
                      ? Icons.check_circle_rounded
                      : Icons.error_outline_rounded,
                  size: 17,
                  color: covered ? Colors.white : FitnessHome.redBright,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    ref.tr(
                      covered
                          ? 'fitness_heart_rate_signal_ok'
                          : 'fitness_heart_rate_cover_lens',
                    ),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body(
                      size: 13,
                      weight: FontWeight.w700,
                      color: covered ? Colors.white : FitnessHome.redBright,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ValueListenableBuilder<String>(
            valueListenable: service.signalInfo,
            builder: (context, info, _) => Text(
              info,
              textAlign: TextAlign.center,
              style: FitnessHome.bodySecondary(size: 10.5),
            ),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<List<double>>(
            valueListenable: service.liveWaveform,
            builder: (context, waveform, _) => SizedBox(
              height: 54,
              child: CustomPaint(
                painter: HeartRateWavePainter(waveform),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: PillButton(
              label: ref.tr('fitness_heart_rate_cancel'),
              filled: false,
              accentColor: FitnessHome.red,
              onTap: onCancel,
            ),
          ),
        ],
      ),
    );
  }
}

/// Do xong: so bpm + gio do + bieu do tin hieu 30 giay.
class _ResultCard extends ConsumerWidget {
  const _ResultCard({
    super.key,
    required this.measurement,
    required this.onRemeasure,
  });

  final HeartRateMeasurement measurement;
  final VoidCallback onRemeasure;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = measurement.timestamp;
    final time =
        '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}';
    return FitnessCard(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      child: Column(
        children: [
          Text(
            ref.tr('fitness_heart_rate_result_title'),
            style: FitnessHome.bodySecondary(size: 12.5),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            builder: (context, t, child) => Opacity(
              opacity: t,
              child: Transform.scale(scale: 0.9 + 0.1 * t, child: child),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const _PulsingHeart(size: 30),
                const SizedBox(width: 12),
                Text(
                  '${measurement.bpm}',
                  style: AppTextStyles.heading(size: 46),
                ),
                const SizedBox(width: 6),
                Text('BPM', style: FitnessHome.statUnit()),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            ref.tr('fitness_heart_rate_measured_at').replaceFirst('{t}', time),
            style: FitnessHome.bodySecondary(size: 11.5),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 70,
            child: CustomPaint(
              painter: HeartRateWavePainter(measurement.waveform),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: PillButton(
              label: ref.tr('fitness_heart_rate_remeasure'),
              filled: false,
              accentColor: FitnessHome.red,
              onTap: onRemeasure,
            ),
          ),
        ],
      ),
    );
  }
}

/// Khong do duoc - noi RO ly do va cach khac phuc thay vi tra ve 1 con so.
class _FailureCard extends ConsumerWidget {
  const _FailureCard({
    super.key,
    required this.failure,
    required this.onRetry,
    this.debugInfo,
  });

  final HeartRateFailure failure;
  final String? debugInfo;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hintKey = switch (failure) {
      HeartRateFailure.cameraUnavailable => 'fitness_heart_rate_error_camera',
      HeartRateFailure.outOfRange => 'fitness_heart_rate_error_range',
      HeartRateFailure.fingerNotDetected =>
        'fitness_heart_rate_error_no_finger',
      _ => 'fitness_heart_rate_error_noisy',
    };
    return FitnessCard(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 46,
            color: FitnessHome.red,
          ),
          const SizedBox(height: 14),
          Text(
            ref.tr('fitness_heart_rate_error_title'),
            textAlign: TextAlign.center,
            style: AppTextStyles.heading(size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            ref.tr(hintKey),
            textAlign: TextAlign.center,
            style: FitnessHome.bodySecondary(size: 12.5),
          ),
          // Vai con so tho ve tin hieu vua thu duoc. Nho va mo di, khong
          // phai thu nguoi dung can doc - nhung khi ho chup man hinh gui
          // lai thi day la thong tin duy nhat noi duoc phep do hong o dau.
          if (debugInfo case final info? when info.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              info,
              textAlign: TextAlign.center,
              style: FitnessHome.bodySecondary(size: 10),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: PillButton(
              label: ref.tr('fitness_heart_rate_retry'),
              accentColor: FitnessHome.red,
              accentGradient: AppColors.fitnessAccentGradient,
              onTap: onRetry,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cac lan do trong ngay hom nay.
class _TodayHistory extends ConsumerWidget {
  const _TodayHistory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(heartRateHistoryProvider).valueOrNull ?? const [];
    final now = DateTime.now();
    final today = history
        .where(
          (m) =>
              m.timestamp.year == now.year &&
              m.timestamp.month == now.month &&
              m.timestamp.day == now.day,
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FitnessSectionHeader(title: ref.tr('fitness_heart_rate_today')),
        const SizedBox(height: 10),
        if (today.isEmpty)
          FitnessCard(
            padding: const EdgeInsets.all(16),
            child: Text(
              ref.tr('fitness_heart_rate_empty'),
              style: FitnessHome.bodySecondary(size: 12.5),
            ),
          )
        else
          for (final m in today)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FitnessCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.favorite_rounded,
                      size: 18,
                      color: FitnessHome.red,
                    ),
                    const SizedBox(width: 12),
                    Text('${m.bpm}', style: AppTextStyles.heading(size: 18)),
                    const SizedBox(width: 4),
                    Text('bpm', style: FitnessHome.statUnit()),
                    const Spacer(),
                    Text(
                      '${m.timestamp.hour.toString().padLeft(2, '0')}:'
                      '${m.timestamp.minute.toString().padLeft(2, '0')}',
                      style: FitnessHome.bodySecondary(size: 12),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

/// Trai tim dap nhe - hieu ung duy nhat cua man nay, 900ms/nhip.
class _PulsingHeart extends StatefulWidget {
  const _PulsingHeart({required this.size});

  final double size;

  @override
  State<_PulsingHeart> createState() => _PulsingHeartState();
}

class _PulsingHeartState extends State<_PulsingHeart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.88,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Icon(
        Icons.favorite_rounded,
        size: widget.size,
        color: FitnessHome.red,
      ),
    );
  }
}

/// Ve duong tin hieu PPG (gia tri da chuan hoa ve [-1, 1]).
class HeartRateWavePainter extends CustomPainter {
  const HeartRateWavePainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    // Duong ke giua lam moc - van ve ca khi chua co du lieu de khung bieu
    // do khong "nhay" ra khi tin hieu bat dau ve.
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      Paint()..color = FitnessHome.divider,
    );
    if (values.length < 2) return;
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = size.height / 2 - values[i] * size.height * 0.42;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = FitnessHome.redBright
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant HeartRateWavePainter oldDelegate) =>
      oldDelegate.values != values;
}

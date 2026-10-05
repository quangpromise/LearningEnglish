import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_credits.dart';
import '../config/env.dart';
import '../theme/gt_haptics.dart';
import '../theme/gt_motion.dart';
import '../theme/gt_tokens.dart';
import 'launch_intro_timeline.dart';

/// Launch Intro dang phu man hinh: man Hom nay doi xong moi chay vong / chuc
/// mung (onScreen). main.dart ghi de = true luc mo app; mac dinh false (test).
final launchIntroActiveProvider = StateProvider<bool>((ref) => false);

/// Vong Daily Rings tren man Hom nay - dich bay cua vong intro.
final gtLaunchRingTarget = GlobalKey(debugLabel: 'launchRingTarget');

/// Build da xem Launch Intro gan nhat (chon ban day du / ngan).
const kLaunchIntroSeenBuildKey = 'launch_intro_seen_build';

// Mau rieng cua man khoi dong: nen navy + vien sang cam lay tu icon; khop man
// cho he thong (android/.../values/colors.xml: splash_navy).
const _navyHi = Color(0xFF12296A);
const _navy = Color(0xFF081538);
const _navyLo = Color(0xFF040A1C);
const _rim = Color(0xFFF39A3D);

/// Logo = vong tron 192dp cua man cho he thong (Android 12+).
const _kDisc = 192.0;

/// Lop phu Launch Intro (spec #135): chon ban theo build da thay, chieu 1 lan
/// moi lan mo app roi tu go khoi cay widget.
class GtLaunchIntroGate extends ConsumerStatefulWidget {
  const GtLaunchIntroGate({super.key, this.currentBuild});

  /// Build hien tai (mac dinh SHA cua CI).
  final String? currentBuild;

  @override
  ConsumerState<GtLaunchIntroGate> createState() => _GtLaunchIntroGateState();
}

class _GtLaunchIntroGateState extends ConsumerState<GtLaunchIntroGate> {
  LaunchIntroVariant? _variant;
  bool _done = false;

  /// Giu man cho he thong (chua gui khung Flutter dau) toi khi logo giai ma
  /// xong - khong thi khung dau la dia navy trong, nhay 1-3 khung (review
  /// #139). Toi da [_kHoldFirstFrame].
  bool _holding = false;
  bool _precaching = false;
  Timer? _holdTimer;

  /// Bo nho may cham / treo: sau [_kPickTimeout] chieu ban day du.
  Timer? _pickTimer;
  static const _kPickTimeout = Duration(milliseconds: 400);
  static const _kHoldFirstFrame = Duration(milliseconds: 600);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.deferFirstFrame();
    _holding = true;
    _holdTimer = Timer(_kHoldFirstFrame, _releaseFirstFrame);
    _pick();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precaching) return;
    _precaching = true;
    precacheImage(
      const AssetImage(kGtLogoAsset),
      context,
      onError: (_, _) {},
    ).whenComplete(_releaseFirstFrame);
  }

  void _releaseFirstFrame() {
    if (!_holding) return;
    _holding = false;
    _holdTimer?.cancel();
    WidgetsBinding.instance.allowFirstFrame();
  }

  @override
  void dispose() {
    _pickTimer?.cancel();
    _releaseFirstFrame();
    super.dispose();
  }

  void _pick() {
    final build = widget.currentBuild ?? Env.buildSha;
    _pickTimer = Timer(_kPickTimeout, () => _show(LaunchIntroVariant.full));
    SharedPreferences.getInstance().then(
      (prefs) {
        _show(
          launchIntroVariant(
            seenBuild: prefs.getString(kLaunchIntroSeenBuildKey),
            currentBuild: build,
          ),
        );
        // Ghi ngay khi bat dau chieu: bo qua giua chung van tinh la da xem.
        unawaited(prefs.setString(kLaunchIntroSeenBuildKey, build));
      },
      // Khong doc duoc: chieu ban day du.
      onError: (Object _) => _show(LaunchIntroVariant.full),
    );
  }

  void _show(LaunchIntroVariant variant) {
    _pickTimer?.cancel();
    if (!mounted || _variant != null) return;
    setState(() => _variant = variant);
  }

  void _finish() {
    if (_done) return;
    setState(() => _done = true);
    ref.read(launchIntroActiveProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return const SizedBox.shrink();
    return GtLaunchIntro(variant: _variant, onDone: _finish);
  }
}

/// Launch Intro (CONTEXT.md): vet sang quet qua logo, vong Tap · Hoc · Noi
/// khep lai, chu GymTalk, ten 2 tac gia, roi vong bay vao the Daily Rings.
/// Cham de bo qua. Thong so: [LaunchIntroTimeline].
class GtLaunchIntro extends StatefulWidget {
  const GtLaunchIntro({super.key, required this.variant, required this.onDone});

  /// null = dang doc ban nao: giu khung dau (logo giua man nhu man cho he
  /// thong de lai).
  final LaunchIntroVariant? variant;

  final VoidCallback onDone;

  @override
  State<GtLaunchIntro> createState() => _GtLaunchIntroState();
}

class _GtLaunchIntroState extends State<GtLaunchIntro>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final Ticker _ticker;
  final ValueNotifier<double> _t = ValueNotifier(0);
  LaunchIntroTimeline? _tl;
  int? _skipAt;
  bool _buzzed = false;
  bool _finished = false;
  bool _measured = false;

  /// Vong Daily Rings (toa do cua lop phu); null = khong bay, chi mo di.
  Rect? _target;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
    WidgetsBinding.instance.addObserver(this);
  }

  /// App vao nen giua chung: khong rung bu luc mo lai (intro xong luon vi
  /// dong ho da qua moc).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _buzzed = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeStart();
  }

  @override
  void didUpdateWidget(GtLaunchIntro old) {
    super.didUpdateWidget(old);
    _maybeStart();
  }

  void _maybeStart() {
    final variant = widget.variant;
    if (variant == null || _tl != null) return;
    _tl = LaunchIntroTimeline(variant, reduce: gtReduceMotion(context));
    _ticker.start();
  }

  void _tick(Duration elapsed) {
    final tl = _tl!;
    final t = elapsed.inMicroseconds / 1000;
    final skipAt = _skipAt;

    if (!_buzzed && skipAt == null && t >= tl.hapticAtMs) {
      _buzzed = true;
      GtHaptics.play(GtHapticEvent.launchRing);
    }
    if (!_measured && t >= tl.exitMs) {
      _measured = true;
      _target = _measureTarget();
    }
    _t.value = t;
    if (t >= (skipAt != null ? tl.skipEndMs(skipAt) : tl.endMs)) _finish();
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    _ticker.stop();
    widget.onDone();
  }

  void _skip() {
    if (_tl == null || _skipAt != null || _finished) return;
    _skipAt = _t.value.round();
  }

  /// Vong Daily Rings cua man Hom nay neu dang that su hien: tab dang chon,
  /// khong bi popup che (vd mo app tu thong bao) va nam trong man hinh.
  Rect? _measureTarget() {
    final targetContext = gtLaunchRingTarget.currentContext;
    final target = targetContext?.findRenderObject();
    final self = context.findRenderObject();
    if (targetContext == null || target is! RenderBox || self is! RenderBox) {
      return null;
    }
    if (!target.attached || !target.hasSize || !self.hasSize) return null;
    if (!(ModalRoute.isCurrentOf(targetContext) ?? true) ||
        !TickerMode.valuesOf(targetContext).enabled) {
      return null;
    }
    final global = MatrixUtils.transformRect(
      target.getTransformTo(null),
      Offset.zero & target.size,
    );
    final rect = global.shift(-self.localToGlobal(Offset.zero));
    return (Offset.zero & self.size).contains(rect.center) ? rect : null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lop phu nam tren Navigator (MaterialApp.builder): tu cap Material de chu
    // co kieu mac dinh. Dang roi man / dang bo qua: cham di xuyen xuong app.
    return ValueListenableBuilder<double>(
      valueListenable: _t,
      builder: (context, t, child) {
        final tl = _tl;
        final leaving = _skipAt != null || (tl != null && t >= tl.exitMs);
        return IgnorePointer(ignoring: leaving, child: child);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _skip,
        child: Material(
          type: MaterialType.transparency,
          child: Semantics(
            container: true,
            label: 'GymTalk',
            child: ExcludeSemantics(
              child: LayoutBuilder(
                builder: (context, box) => ValueListenableBuilder<double>(
                  valueListenable: _t,
                  builder: (context, t, _) => _frame(context, box.biggest, t),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _frame(BuildContext context, Size size, double t) {
    final tokens = context.gt;
    final tl = _tl;
    final skipAt = _skipAt;
    final w = size.width;
    final h = size.height;
    // 1dp cua man tham chieu 400 x 860dp (ban xem thu): chu theo canh han che
    // hon - man rong (may tinh bang, xoay ngang) khong lam chu to qua kho.
    final u = math.min(w / 400, h / 860);
    // Logo = man cho he thong (192dp); chi nho lai khi xoay ngang.
    final disc = w > h ? math.min(_kDisc, h * 0.3) : _kDisc;
    // Nen + vien sang hien dan tu nen navy phang cua man cho.
    final ramp = tl?.ramp(t) ?? 0;
    final overlay = tl == null
        ? 1.0
        : skipAt != null
        ? tl.skipOpacity(skipAt, t)
        : tl.overlayOpacity(t);
    final lift = tl?.lift(t) ?? 0;
    final mark = Offset(w / 2, h / 2 + (0.37 * h - h / 2) * lift);
    final push = tl?.push(t) ?? 1;
    final content = tl?.contentOpacity(t) ?? 1;
    final scale = tl?.contentScale(t) ?? 1;

    // Vong: tu quanh logo bay toi vong Daily Rings (dung kich thuoc, net dam
    // dan) - GtRingsPainter: ban kinh 64, net 14 trong khung 164.
    final fly = _target == null
        ? 0.0
        : tl!.flight(skipAt == null ? t : math.min(t, skipAt.toDouble()));
    final ringR = disc / 2 * 1.225 * push;
    final ringW = disc / 2 * 0.125 * push;
    final target = _target;
    final k = target == null ? 1.0 : target.shortestSide / 164;
    final center = target == null
        ? mark
        : Offset.lerp(mark, target.center, fly)!;
    final radius = target == null ? ringR : ui.lerpDouble(ringR, 64 * k, fly)!;
    final stroke = target == null ? ringW : ui.lerpDouble(ringW, 14 * k, fly)!;

    return Opacity(
      opacity: overlay.clamp(0.0, 1.0),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: (tl?.skyOpacity(t) ?? 1).clamp(0.0, 1.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.26),
                    radius: 1.25,
                    colors: [
                      Color.lerp(_navy, _navyHi, ramp)!,
                      _navy,
                      Color.lerp(_navy, _navyLo, ramp)!,
                    ],
                    stops: const [0, 0.46, 1],
                  ),
                ),
              ),
            ),
          ),
          if (tl != null)
            Positioned.fill(
              child: CustomPaint(
                painter: GtLaunchRingPainter(
                  center: center,
                  radius: radius,
                  stroke: stroke,
                  progress: [for (var i = 0; i < 3; i++) tl.arc(i, t)],
                  spin: tl.spinDeg(t) * math.pi / 180 * (1 - fly),
                  flash: tl.flash(t),
                  opacity: (target == null ? content : tl.ringOpacity(t)).clamp(
                    0.0,
                    1.0,
                  ),
                  colors: [tokens.red, tokens.blue, tokens.teal],
                ),
              ),
            ),
          Positioned(
            left: mark.dx - disc / 2,
            top: mark.dy - disc / 2,
            width: disc,
            height: disc,
            child: Opacity(
              opacity: content.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: push,
                child: _Logo(
                  sweep: tl?.sweep(t) ?? 0,
                  sweepOpacity: tl?.sweepOpacity(t) ?? 0,
                  rim: tl?.rim(t) ?? 0,
                  show: ramp,
                ),
              ),
            ),
          ),
          if (tl != null && tl.hasWords) ...[
            Positioned(
              left: 0,
              right: 0,
              top: 0.63 * h,
              child: Opacity(
                opacity: content.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: scale,
                  child: _Wordmark(tl: tl, t: t, u: u, tokens: tokens),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: 0.63 * h + 64 * u,
              child: Opacity(
                opacity: (tl.taglineOpacity(t) * content).clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, tl.taglineY(t) * u),
                  child: Text(
                    'Train your body. Train your English.',
                    textAlign: TextAlign.center,
                    textScaler: TextScaler.noScaling,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w500,
                      fontSize: 15.6 * u,
                      color: tokens.tx2,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0.105 * h,
              child: Opacity(
                opacity: content.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: scale,
                  child: _Credits(tl: tl, t: t, u: u, tokens: tokens),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Logo tron + vien sang cam + vet sang quet qua.
class _Logo extends StatelessWidget {
  const _Logo({
    required this.sweep,
    required this.sweepOpacity,
    required this.rim,
    required this.show,
  });

  final double sweep;
  final double sweepOpacity;
  final double rim;

  /// Vien sang hien dan (0 = nhu man cho he thong: chua co vien).
  final double show;

  @override
  Widget build(BuildContext context) {
    final a = (0.35 + 0.55 * rim) * show;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _navy,
        boxShadow: [
          BoxShadow(
            color: _rim.withValues(alpha: 0.5 * a),
            blurRadius: 6 + 22 * rim,
          ),
        ],
      ),
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _rim.withValues(alpha: a), width: 2.4),
        ),
        child: ClipOval(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                kGtLogoAsset,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
              if (sweepOpacity > 0)
                CustomPaint(
                  painter: _SweepPainter(pos: sweep, opacity: sweepOpacity),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vet sang cheo (~22 do) quet ngang qua logo, che do "screen".
class _SweepPainter extends CustomPainter {
  _SweepPainter({required this.pos, required this.opacity});

  final double pos;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    canvas
      ..save()
      ..translate(w / 2 + (-1.2 + 2.4 * pos) * w, size.height / 2)
      ..rotate(22 * math.pi / 180);
    final band = Rect.fromCenter(
      center: Offset.zero,
      width: w * 1.4,
      height: size.height * 2,
    );
    const warm = Color(0xFFFFE2BE);
    canvas.drawRect(
      band,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = LinearGradient(
          colors: [
            warm.withValues(alpha: 0),
            warm.withValues(alpha: 0),
            warm.withValues(alpha: 0.7 * opacity),
            warm.withValues(alpha: 0),
            warm.withValues(alpha: 0),
          ],
          stops: const [0, 0.41, 0.5, 0.59, 1],
        ).createShader(band),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SweepPainter old) =>
      old.pos != pos || old.opacity != opacity;
}

/// 3 cung Tap · Hoc · Noi (dung mau Daily Rings) + quang sang khi khep vong.
@visibleForTesting
class GtLaunchRingPainter extends CustomPainter {
  GtLaunchRingPainter({
    required this.center,
    required this.radius,
    required this.stroke,
    required this.progress,
    required this.spin,
    required this.flash,
    required this.opacity,
    required this.colors,
  });

  final Offset center;
  final double radius;
  final double stroke;
  final List<double> progress;
  final double spin;
  final double flash;
  final double opacity;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(spin);
    final rect = Rect.fromCircle(center: Offset.zero, radius: radius);
    final arcs = launchRingArcs(radius: radius, stroke: stroke);
    for (var i = 0; i < arcs.length; i++) {
      final sweep = arcs[i].span * progress[i];
      if (sweep <= 0) continue;
      if (flash > 0) {
        canvas.drawArc(
          rect,
          arcs[i].start,
          sweep,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = stroke * 2.4
            ..color = colors[i].withValues(alpha: 0.32 * flash * opacity),
        );
      }
      canvas.drawArc(
        rect,
        arcs[i].start,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = stroke * (1 + 0.48 * flash)
          ..color = colors[i].withValues(alpha: opacity),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(GtLaunchRingPainter old) =>
      old.center != center ||
      old.radius != radius ||
      old.stroke != stroke ||
      old.spin != spin ||
      old.flash != flash ||
      old.opacity != opacity ||
      old.colors != colors ||
      !_sameList(old.progress, progress);

  static bool _sameList(List<double> a, List<double> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// "GymTalk" troi len tung ky tu ("Talk" mau vang).
class _Wordmark extends StatelessWidget {
  const _Wordmark({
    required this.tl,
    required this.t,
    required this.u,
    required this.tokens,
  });

  final LaunchIntroTimeline tl;
  final double t;
  final double u;
  final GtTokens tokens;

  @override
  Widget build(BuildContext context) {
    const word = 'GymTalk';
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < word.length; i++)
            Transform.translate(
              offset: Offset(0, tl.letterY(i, t) * u),
              child: Opacity(
                opacity: tl.letterOpacity(i, t),
                child: Text(
                  word[i],
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontWeight: FontWeight.w700,
                    fontSize: 48 * u,
                    height: 1,
                    letterSpacing: -1.4 * u,
                    color: i < 3 ? tokens.tx : tokens.gold,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// "MADE BY" + Quang Promise × Tung Micky + net chu ky vang.
class _Credits extends StatelessWidget {
  const _Credits({
    required this.tl,
    required this.t,
    required this.u,
    required this.tokens,
  });

  final LaunchIntroTimeline tl;
  final double t;
  final double u;
  final GtTokens tokens;

  @override
  Widget build(BuildContext context) {
    final name = TextStyle(
      fontFamily: 'Manrope',
      fontWeight: FontWeight.w600,
      fontSize: 18 * u,
      color: tokens.tx,
      decoration: TextDecoration.none,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: tl.byOpacity(t),
          child: Text(
            'MADE BY',
            textScaler: TextScaler.noScaling,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
              fontSize: 10.8 * u,
              letterSpacing: 2.6 * u,
              color: tokens.tx3,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        SizedBox(height: 8 * u),
        // Ten dai / man hep: thu nho ca hang thay vi tran.
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Transform.translate(
                offset: Offset(tl.nameLX(t) * u, 0),
                child: Opacity(
                  opacity: tl.namesOpacity(t),
                  child: Text(
                    kGtAuthors.$1,
                    textScaler: TextScaler.noScaling,
                    style: name,
                  ),
                ),
              ),
              SizedBox(width: 10 * u),
              Opacity(
                opacity: tl.timesOpacity(t),
                child: Transform.scale(
                  scale: tl.timesScale(t),
                  child: Text(
                    '×',
                    textScaler: TextScaler.noScaling,
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w500,
                      fontSize: 20.8 * u,
                      color: tokens.gold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10 * u),
              Transform.translate(
                offset: Offset(tl.nameRX(t) * u, 0),
                child: Opacity(
                  opacity: tl.nameROpacity(t),
                  child: Text(
                    kGtAuthors.$2,
                    textScaler: TextScaler.noScaling,
                    style: name,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4 * u),
        CustomPaint(
          size: Size(296 * u, 18 * u),
          painter: _SignPainter(
            progress: tl.sign(t),
            color: tokens.gold,
            width: 1.6 * u,
          ),
        ),
      ],
    );
  }
}

/// Net chu ky vang hoi luon song duoi 2 ten, ve dan tu trai sang.
class _SignPainter extends CustomPainter {
  _SignPainter({
    required this.progress,
    required this.color,
    required this.width,
  });

  final double progress;
  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(0.02 * w, 0.56 * h)
      ..cubicTo(0.22 * w, 0.9 * h, 0.4 * w, 0.2 * h, 0.58 * w, 0.53 * h)
      ..cubicTo(0.72 * w, 0.75 * h, 0.88 * w, 0.8 * h, 0.98 * w, 0.37 * h);
    final metric = path.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * progress),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = width
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_SignPainter old) =>
      old.progress != progress || old.color != color || old.width != width;
}

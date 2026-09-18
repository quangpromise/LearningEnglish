import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
import '../data/wealth_investment_snapshot_repository.dart';

/// Khoang thoi gian xem cua bieu do gia tri danh muc - dat ten/thu tu giong
/// cac nut o chart coin (crypto_coin_detail_screen) cho quen tay.
enum InvestmentChartRange { h1, h4, d1, w1, m1, m3, y1 }

extension on InvestmentChartRange {
  Duration get window => switch (this) {
    InvestmentChartRange.h1 => const Duration(hours: 1),
    InvestmentChartRange.h4 => const Duration(hours: 4),
    InvestmentChartRange.d1 => const Duration(days: 1),
    InvestmentChartRange.w1 => const Duration(days: 7),
    InvestmentChartRange.m1 => const Duration(days: 30),
    InvestmentChartRange.m3 => const Duration(days: 90),
    InvestmentChartRange.y1 => const Duration(days: 365),
  };

  String get label => switch (this) {
    InvestmentChartRange.h1 => '1H',
    InvestmentChartRange.h4 => '4H',
    InvestmentChartRange.d1 => '1D',
    InvestmentChartRange.w1 => '1W',
    InvestmentChartRange.m1 => '1M',
    InvestmentChartRange.m3 => '3M',
    InvestmentChartRange.y1 => '1Y',
  };
}

/// Cac moc gia tri danh muc trong khoang [range]. autoDispose: chi song khi
/// dang mo man co bieu do.
final investmentSnapshotsProvider = FutureProvider.autoDispose
    .family<List<InvestmentSnapshot>, InvestmentChartRange>((ref, range) async {
      final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
      if (userId == null) return const [];
      return WealthInvestmentSnapshotRepository.fetch(
        userId: userId,
        since: DateTime.now().subtract(range.window),
      );
    });

const _investmentChartRangeKey = 'wealth_investment_chart_range_v1';

/// Khung thoi gian dang chon cua bieu do - LUU LAI (SharedPreferences) de mo
/// lai man khong bi reset ve mac dinh, giong cach
/// investmentDisplayCurrencyProvider giu lua chon VND/USD.
class _ChartRangeController extends StateNotifier<InvestmentChartRange> {
  _ChartRangeController() : super(InvestmentChartRange.d1) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_investmentChartRangeKey);
    if (name == null) return;
    for (final r in InvestmentChartRange.values) {
      if (r.name == name) {
        state = r;
        return;
      }
    }
  }

  Future<void> set(InvestmentChartRange range) async {
    state = range;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_investmentChartRangeKey, range.name);
  }
}

final investmentChartRangeProvider =
    StateNotifierProvider<_ChartRangeController, InvestmentChartRange>(
      (ref) => _ChartRangeController(),
    );

/// Cac diem gia tri thu thap NGAY TRONG PHIEN dang chay (bo nho, khong qua
/// server) - de bieu do co duong ve NGAY LAP TUC thay vi doi bang snapshot
/// tren Supabase co du 2 moc (moi gio 1 moc = phai cho ca tieng).
///
/// Nguon du lieu la chinh gia song: crypto chay qua WebSocket nen tong danh
/// muc nhuc nhich lien tuc, cu 10 giay lay 1 diem la du min cho duong nhin
/// muot ma khong phinh bo nho.
class InvestmentLiveSeries {
  InvestmentLiveSeries._();

  static const _sampleGap = Duration(seconds: 5);
  static const _maxPoints = 1440; // 5s * 1440 = 2 tieng gan nhat

  static final List<(DateTime, double)> points = [];

  static void add(double valueVnd) {
    if (valueVnd <= 0) return;
    final now = DateTime.now();
    if (points.isNotEmpty && now.difference(points.last.$1) < _sampleGap) {
      return;
    }
    points.add((now, valueVnd));
    if (points.length > _maxPoints) points.removeAt(0);
  }
}

/// Ghi lai gia tri danh muc hien tai (toi da 1 lan/gio) - dat o bat ky man
/// nao co hien tong dau tu. Khong ve gi ca, chi la 1 "moc" de bieu do co du
/// lieu ma ve.
///
/// TACH RIENG khoi bieu do: neu chi ghi khi nguoi dung MO bieu do thi bieu
/// do se mai mai gan nhu trong - phai ghi ngay ca khi ho chi luot qua man
/// Home.
class InvestmentSnapshotRecorder extends ConsumerStatefulWidget {
  const InvestmentSnapshotRecorder({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<InvestmentSnapshotRecorder> createState() =>
      _InvestmentSnapshotRecorderState();
}

class _InvestmentSnapshotRecorderState
    extends ConsumerState<InvestmentSnapshotRecorder> {
  @override
  Widget build(BuildContext context) {
    final total = ref.watch(totalInvestmentValueVndProvider);
    final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
    if (userId != null && total > 0) {
      // Goi NGOAI pha build (post-frame): ghi du lieu ngay trong build la
      // tac dung phu, va o day build chay lai moi lan gia song nhay.
      InvestmentLiveSeries.add(total);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WealthInvestmentSnapshotRepository.record(
          userId: userId,
          valueVnd: total,
        );
      });
    }
    return widget.child;
  }
}

/// Bieu do gia tri danh muc dau tu theo thoi gian - duong gia tri + vung to
/// mo ben duoi, mau vang theo bang mau khu Tai san.
///
/// [compact] = ban nho nhung tren the o man Home: chi con duong, khong nut
/// chon khoang thoi gian, khong truc.
class InvestmentValueChart extends ConsumerStatefulWidget {
  const InvestmentValueChart({super.key, this.compact = false});

  final bool compact;

  @override
  ConsumerState<InvestmentValueChart> createState() =>
      _InvestmentValueChartState();
}

class _InvestmentValueChartState extends ConsumerState<InvestmentValueChart> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // Nhip ve lai dinh ky. KHONG the chi dua vao gia doi: danh muc khong co
    // crypto (chi vang/BDS/co phieu) thi tong dung yen ca ngay, widget khong
    // bao gio build lai, chuoi diem khong bao gio du 2 diem va bieu do ket
    // vinh vien o trang thai "chua du du lieu".
    _tick = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final range = widget.compact
        ? InvestmentChartRange.d1
        : ref.watch(investmentChartRangeProvider);
    final snapsAsync = ref.watch(investmentSnapshotsProvider(range));
    final liveTotal = ref.watch(totalInvestmentValueVndProvider);

    final snaps = snapsAsync.valueOrNull ?? const <InvestmentSnapshot>[];
    // Ghi them diem cho chuoi song moi lan gia doi (ham tu gioi han 10s/diem)
    // de chinh man nay cung "nuoi" duoc duong bieu do khi dang mo.
    InvestmentLiveSeries.add(liveTotal);
    final since = DateTime.now().subtract(range.window);
    // 3 nguon gop lai: moc luu tren server (lich su dai han) + diem thu trong
    // phien nay (de co duong ve NGAY, khong cho database) + gia tri song hien
    // tai lam diem cuoi -> duong nhuc nhich theo tung tick nhu chart coin.
    final points = <(DateTime, double)>[
      for (final s in snaps) (s.takenAt, s.valueVnd),
      for (final p in InvestmentLiveSeries.points)
        if (p.$1.isAfter(since)) p,
      if (liveTotal > 0) (DateTime.now(), liveTotal),
    ]..sort((a, b) => a.$1.compareTo(b.$1));

    if (points.length < 2) {
      return _EmptyState(compact: widget.compact);
    }

    final first = points.first.$2;
    final last = points.last.$2;
    // So tien + % lai/lo lay DUNG tu investmentPnlProvider - cung nguon voi
    // the o man Home nen 2 man khong bao gio lech nhau. KHONG tu tinh
    // (last - first) tren khoang dang xem nua: cach do ra con so khac han the
    // o Home, nguoi dung khong biet tin cai nao.
    final (pnl, pnlPercent) = ref.watch(investmentPnlProvider);
    final up = pnl >= 0;
    // Mau DUONG van theo chieu len/xuong cua chinh doan dang xem.
    final lineColor = last >= first ? AppColors.wealthUp : AppColors.pink;
    final pnlColor = up ? AppColors.wealthUp : AppColors.pink;
    // Con mat "an" o man Tai san dau tu thi CHE luon so o day - truoc day
    // tong ben duoi da an ma so tren bieu do van hien nguyen, an nhu khong.
    final hidden = ref.watch(investmentPrivacyModeProvider);
    // Theo dung lua chon VND/USD o man Tai san dau tu - truoc day bieu do
    // luon hien VND nen doi sang USD ben duoi ma so tren bieu do van la VND.
    final currency = ref.watch(investmentDisplayCurrencyProvider);
    final usdVnd = ref.watch(wealthVnAssetsProvider).valueOrNull?.usdVnd;
    String money(num vnd) => formatInvestmentValue(vnd, currency, usdVnd);

    final minX = points.first.$1.millisecondsSinceEpoch.toDouble();
    final maxX = points.last.$1.millisecondsSinceEpoch.toDouble();
    final values = points.map((p) => p.$2);
    final rawMin = values.reduce((a, b) => a < b ? a : b);
    final rawMax = values.reduce((a, b) => a > b ? a : b);
    // Le tren/duoi chi 8% cua chinh BIEN DO dang co, KHONG con san 0.2% gia
    // tri tuyet doi nhu truoc: danh muc ~130 trieu thi san do = 260k, lon hon
    // ca bien dong thuc trong ngay, ep duong ve gan nhu mot vach thang - dung
    // hien tuong "len xuong khong ro" nguoi dung bao. Bien do bang 0 (moi do
    // duoc 2 diem y het nhau) moi can 1 epsilon nho de khong chia cho 0.
    final span = rawMax - rawMin;
    final pad = span > 0 ? span * 0.08 : (rawMax.abs() * 0.0005 + 1);

    final chart = LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX == minX ? minX + 1 : maxX,
        minY: rawMin - pad,
        maxY: rawMax + pad,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (final p in points)
                FlSpot(p.$1.millisecondsSinceEpoch.toDouble(), p.$2),
            ],
            // curveSmoothness thap: lam muot nhieu se "bao mon" cac dinh/day
            // nho - dung thu can nhin thay nhat o bieu do nay.
            isCurved: true,
            curveSmoothness: 0.08,
            color: lineColor,
            barWidth: widget.compact ? 2 : 2.4,
            // Cham sang o DIEM CUOI (gia tri hien tai) - moc mat de biet dau
            // la "bay gio", va lam bieu do bot tinh.
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, _) =>
                  spot.x == points.last.$1.millisecondsSinceEpoch.toDouble(),
              getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                radius: widget.compact ? 2.6 : 3.4,
                color: lineColor,
                strokeWidth: widget.compact ? 1.4 : 2,
                strokeColor: lineColor.withValues(alpha: 0.35),
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lineColor.withValues(alpha: 0.28),
                  lineColor.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.compact) return chart;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              hidden ? '•••••••' : money(last),
              style: AppTextStyles.heading(size: 22)
                  .copyWith(color: AppColors.wealthAmount),
            ),
            const SizedBox(width: 8),
            if (!hidden && pnl != 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  '${up ? '+' : ''}${money(pnl)}'
                  '${pnlPercent == null ? '' : ' (${up ? '+' : ''}${pnlPercent.toStringAsFixed(1)}%)'}',
                  style: AppTextStyles.body(
                    size: 12,
                    weight: FontWeight.w700,
                    color: pnlColor,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(height: 150, child: chart),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final r in InvestmentChartRange.values)
                Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: GestureDetector(
                    onTap: () =>
                        ref.read(investmentChartRangeProvider.notifier).set(r),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: range == r
                            ? AppColors.wealthAccent.withValues(alpha: 0.22)
                            : AppColors.glassFill,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: range == r
                              ? AppColors.wealthAccent
                              : AppColors.glassBorder,
                        ),
                      ),
                      child: Text(
                        r.label,
                        style: AppTextStyles.body(
                          size: 11.5,
                          weight: FontWeight.w700,
                          color: range == r
                              ? AppColors.wealthAccent
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Chua du 2 moc de ve duong - noi ro LY DO thay vi de 1 o trong, vi day la
/// trang thai BINH THUONG voi nguoi dung moi (app chi bat dau ghi moc tu lan
/// cap nhat nay, xem migration 0068).
class _EmptyState extends ConsumerWidget {
  const _EmptyState({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (compact) return const SizedBox.shrink();
    return SizedBox(
      height: 120,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            ref.tr('investment_chart_empty'),
            textAlign: TextAlign.center,
            style: AppTextStyles.muted(size: 12),
          ),
        ),
      ),
    );
  }
}

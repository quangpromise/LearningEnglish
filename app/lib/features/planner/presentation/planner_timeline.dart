import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/planner_models.dart';
import 'planner_accent.dart';
import 'planner_providers.dart';

/// Du lieu keo-tha tren timeline: 1 lan xuat hien dang co ([occurrence]) HOAC
/// 1 viec tu hang "Chua xep gio" ([inboxTask]).
class PlannerDragPayload {
  const PlannerDragPayload.occurrence(PlannerOccurrence this.occurrence)
    : inboxTask = null;
  const PlannerDragPayload.inbox(PlannerTask this.inboxTask)
    : occurrence = null;

  final PlannerOccurrence? occurrence;
  final PlannerTask? inboxTask;
}

const _gutterW = 38.0;
const _headerH = 30.0;
const _baseRowH = 60.0;
const _cardH = 50.0;
const _miniH = 22.0;
const _chipH = 20.0;
const _gap = 4.0;
const _cellPad = 5.0;
const _visibleDays = 3;

/// Moc de doi ngay <-> chi so trang cua PageView (vo han ve 2 phia trong
/// thuc te) - dung UTC de phep tru ngay khong bi lech khi doi gio mua he.
final _epoch = DateTime.utc(2000);

int _indexFor(DateTime d) =>
    DateTime.utc(d.year, d.month, d.day).difference(_epoch).inDays;

DateTime _dateFor(int index) {
  final d = _epoch.add(Duration(days: index));
  return DateTime(d.year, d.month, d.day);
}

double _cellContentHeight(int count, bool expanded) {
  if (count == 0) return 0;
  final collapsed = count > 3 && !expanded;
  final minis = collapsed ? 1 : count - 1;
  final chip = count > 3;
  return _cardH +
      minis * (_miniH + _gap) +
      (chip ? _gap + _chipH : 0) +
      2 * _cellPad;
}

/// Timeline NHIEU NGAY: cot gio co dinh ben trai + [_visibleDays] cot ngay
/// song song, vuot ngang de chuyen ngay (moi lan 1 ngay). Cot GIUA luon la
/// ngay dang chon ([plannerSelectedDateProvider]) - vuot timeline thi
/// date-strip phia tren sang theo, bam date-strip thi timeline cuon toi.
///
/// Card duoc THU GON cho vua cot hep (vong tick + gio + ten 2 dong); hang gio
/// co >3 viec thi hien 1 card + 1 dong rut gon + nut "+N" xo ra tai cho.
/// Chieu cao 1 hang gio = cao nhat trong cac ngay lan can de cac cot van
/// thang hang voi cot gio ben trai.
///
/// LUU Y: van nhom theo GIO BAT DAU (khong chia cot chong lan theo thoi
/// luong kieu Google Calendar) - cot ngay chi rong ~1/3 man hinh nen card
/// theo thoi luong se qua hep de doc (xem docs/research-planner-app-ux.md).
class PlannerTimeline extends ConsumerStatefulWidget {
  const PlannerTimeline({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    required this.gradient,
    required this.glow,
    required this.dayLabel,
    required this.onAddAt,
    required this.onEditOccurrence,
    required this.onToggleDone,
    required this.onDropOccurrence,
    required this.onDropInboxTask,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final Gradient gradient;
  final Color glow;
  final String Function(DateTime) dayLabel;
  final void Function(DateTime hourStart) onAddAt;
  final void Function(PlannerOccurrence occ) onEditOccurrence;
  final void Function(PlannerOccurrence occ) onToggleDone;
  final void Function(PlannerOccurrence occ, DateTime newStart)
  onDropOccurrence;
  final void Function(PlannerTask task, DateTime start) onDropInboxTask;

  @override
  ConsumerState<PlannerTimeline> createState() => _PlannerTimelineState();
}

class _PlannerTimelineState extends ConsumerState<PlannerTimeline> {
  late final PageController _pages;
  final _vScroll = ScrollController();
  final _expanded = <String>{};

  /// true trong luc tu cuon PageView theo date-strip - bo qua onPageChanged
  /// cua cac trang trung gian (neu khong se ghi de ngay dang chon lien tuc).
  bool _programmatic = false;

  @override
  void initState() {
    super.initState();
    _pages = PageController(
      viewportFraction: 1 / _visibleDays,
      initialPage: _indexFor(widget.selectedDate),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToFirstTask());
  }

  @override
  void didUpdateWidget(covariant PlannerTimeline old) {
    super.didUpdateWidget(old);
    if (!plannerSameDay(old.selectedDate, widget.selectedDate)) {
      _syncPageToSelected();
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    _vScroll.dispose();
    super.dispose();
  }

  void _syncPageToSelected() {
    if (!_pages.hasClients) return;
    final target = _indexFor(widget.selectedDate);
    final current = (_pages.page ?? target.toDouble()).round();
    if (current == target) return;
    _programmatic = true;
    if ((target - current).abs() <= 7) {
      _pages
          .animateToPage(
            target,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
          )
          .whenComplete(() => _programmatic = false);
    } else {
      _pages.jumpToPage(target);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _programmatic = false,
      );
    }
  }

  /// Cuon doc toi gio dau tien co viec cua ngay dang chon (hom nay: gio hien
  /// tai; khong co viec: 7h) de khong phai tu keo tu 00:00 moi lan mo man.
  void _scrollToFirstTask() {
    if (!_vScroll.hasClients) return;
    final occs = ref.read(
      plannerOccurrencesForDayProvider(widget.selectedDate),
    );
    final now = DateTime.now();
    final hour = occs.isNotEmpty
        ? occs.first.start.hour
        : plannerSameDay(now, widget.selectedDate)
        ? now.hour
        : 7;
    final offsets = _hourOffsets(_rowHeights(watch: false));
    _vScroll.jumpTo(
      offsets[(hour - 1).clamp(0, 23)].clamp(
        0,
        _vScroll.position.maxScrollExtent,
      ),
    );
  }

  /// [watch] = false khi goi ngoai build (post-frame) - chi doc 1 lan.
  List<double> _rowHeights({bool watch = true}) {
    final heights = List<double>.filled(24, _baseRowH);
    for (var i = -_visibleDays; i <= _visibleDays; i++) {
      final day = widget.selectedDate.add(Duration(days: i));
      final provider = plannerOccurrencesForDayProvider(day);
      final occs = watch ? ref.watch(provider) : ref.read(provider);
      final counts = <int, int>{};
      for (final o in occs) {
        counts[o.start.hour] = (counts[o.start.hour] ?? 0) + 1;
      }
      final key = plannerDayKey(day);
      counts.forEach((hour, count) {
        final h = _cellContentHeight(count, _expanded.contains('$key:$hour'));
        if (h > heights[hour]) heights[hour] = h;
      });
    }
    return heights;
  }

  static List<double> _hourOffsets(List<double> heights) {
    final offsets = <double>[];
    var y = 0.0;
    for (final h in heights) {
      offsets.add(y);
      y += h;
    }
    return offsets;
  }

  void _toggleExpand(DateTime day, int hour) => setState(() {
    final key = '${plannerDayKey(day)}:$hour';
    if (!_expanded.add(key)) _expanded.remove(key);
  });

  @override
  Widget build(BuildContext context) {
    final heights = _rowHeights();
    final offsets = _hourOffsets(heights);
    final total = offsets.last + heights.last;
    final now = ref.watch(plannerNowProvider).valueOrNull ?? DateTime.now();

    return LayoutBuilder(
      builder: (context, constraints) {
        final colW = (constraints.maxWidth - _gutterW) / _visibleDays;
        return Column(
          children: [
            SizedBox(
              height: _headerH,
              child: Row(
                children: [
                  const SizedBox(width: _gutterW),
                  Expanded(
                    child: _DayHeaderRow(
                      controller: _pages,
                      initialIndex: _indexFor(widget.selectedDate),
                      colW: colW,
                      gradient: widget.gradient,
                      glow: widget.glow,
                      dayLabel: widget.dayLabel,
                      today: plannerDateOnly(now),
                      onTapDay: widget.onDateChanged,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _vScroll,
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(
                  height: total,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: _gutterW,
                        child: Column(
                          children: [
                            for (var h = 0; h < 24; h++)
                              SizedBox(
                                height: heights[h],
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      '${h.toString().padLeft(2, '0')}:00',
                                      style: AppTextStyles.muted(
                                        size: 10,
                                        weight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: PageView.builder(
                          controller: _pages,
                          onPageChanged: (i) {
                            if (_programmatic) return;
                            widget.onDateChanged(_dateFor(i));
                          },
                          itemBuilder: (context, i) {
                            final day = _dateFor(i);
                            return _DayColumn(
                              day: day,
                              colW: colW,
                              heights: heights,
                              offsets: offsets,
                              now: now,
                              selected: plannerSameDay(
                                day,
                                widget.selectedDate,
                              ),
                              glow: widget.glow,
                              expandedHours: {
                                for (var h = 0; h < 24; h++)
                                  if (_expanded.contains(
                                    '${plannerDayKey(day)}:$h',
                                  ))
                                    h,
                              },
                              onToggleExpand: (h) => _toggleExpand(day, h),
                              onAddAt: widget.onAddAt,
                              onEdit: widget.onEditOccurrence,
                              onToggleDone: widget.onToggleDone,
                              onDropOccurrence: widget.onDropOccurrence,
                              onDropInboxTask: widget.onDropInboxTask,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Hang tieu de ngay phia tren cac cot - di chuyen DONG BO voi PageView
/// (doc truc tiep vi tri trang tu controller), ngay gan giua nhat sang dan.
class _DayHeaderRow extends StatelessWidget {
  const _DayHeaderRow({
    required this.controller,
    required this.initialIndex,
    required this.colW,
    required this.gradient,
    required this.glow,
    required this.dayLabel,
    required this.today,
    required this.onTapDay,
  });

  final PageController controller;
  final int initialIndex;
  final double colW;
  final Gradient gradient;
  final Color glow;
  final String Function(DateTime) dayLabel;
  final DateTime today;
  final ValueChanged<DateTime> onTapDay;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final page = controller.hasClients && controller.position.haveDimensions
            ? controller.page ?? initialIndex.toDouble()
            : initialIndex.toDouble();
        final first = page.floor() - 2;
        return ClipRect(
          child: Stack(
            children: [
              for (var i = first; i <= first + 5; i++)
                Positioned(
                  left: (i - page) * colW + colW,
                  top: 0,
                  bottom: 0,
                  width: colW,
                  child: _DayHeaderCell(
                    day: _dateFor(i),
                    focus: (1 - (i - page).abs()).clamp(0.0, 1.0),
                    gradient: gradient,
                    glow: glow,
                    label: dayLabel(_dateFor(i)),
                    isToday: plannerSameDay(_dateFor(i), today),
                    onTap: () => onTapDay(_dateFor(i)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DayHeaderCell extends StatelessWidget {
  const _DayHeaderCell({
    required this.day,
    required this.focus,
    required this.gradient,
    required this.glow,
    required this.label,
    required this.isToday,
    required this.onTap,
  });

  final DateTime day;

  /// 1 = dang o chinh giua (ngay dang chon), 0 = cot ben canh tro ra.
  final double focus;
  final Gradient gradient;
  final Color glow;
  final String label;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: focus > 0.5 ? gradient : null,
                color: focus > 0.5 ? null : AppColors.glassFill,
                boxShadow: focus > 0.5
                    ? [
                        BoxShadow(
                          color: glow.withValues(alpha: 0.35 * focus),
                          blurRadius: 12,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                '$label ${day.day}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color.lerp(AppColors.textMuted, Colors.white, focus),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            if (isToday)
              Positioned(
                bottom: -5,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: glow,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DayColumn extends ConsumerWidget {
  const _DayColumn({
    required this.day,
    required this.colW,
    required this.heights,
    required this.offsets,
    required this.now,
    required this.selected,
    required this.glow,
    required this.expandedHours,
    required this.onToggleExpand,
    required this.onAddAt,
    required this.onEdit,
    required this.onToggleDone,
    required this.onDropOccurrence,
    required this.onDropInboxTask,
  });

  final DateTime day;
  final double colW;
  final List<double> heights;
  final List<double> offsets;
  final DateTime now;
  final bool selected;
  final Color glow;
  final Set<int> expandedHours;
  final ValueChanged<int> onToggleExpand;
  final void Function(DateTime hourStart) onAddAt;
  final void Function(PlannerOccurrence occ) onEdit;
  final void Function(PlannerOccurrence occ) onToggleDone;
  final void Function(PlannerOccurrence occ, DateTime newStart)
  onDropOccurrence;
  final void Function(PlannerTask task, DateTime start) onDropInboxTask;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final occs = ref.watch(plannerOccurrencesForDayProvider(day));
    final byHour = <int, List<PlannerOccurrence>>{};
    for (final o in occs) {
      byHour.putIfAbsent(o.start.hour, () => []).add(o);
    }
    final isToday = plannerSameDay(day, now);
    return Container(
      decoration: BoxDecoration(
        color: selected ? Colors.white.withValues(alpha: 0.025) : null,
        border: const Border(left: BorderSide(color: Color(0x12FFFFFF))),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              for (var h = 0; h < 24; h++)
                _HourCell(
                  height: heights[h],
                  day: day,
                  hour: h,
                  occs: byHour[h] ?? const [],
                  colW: colW,
                  now: now,
                  expanded: expandedHours.contains(h),
                  onToggleExpand: () => onToggleExpand(h),
                  onAddAt: onAddAt,
                  onEdit: onEdit,
                  onToggleDone: onToggleDone,
                  onDropOccurrence: onDropOccurrence,
                  onDropInboxTask: onDropInboxTask,
                ),
            ],
          ),
          // Vach "bay gio" - chi o cot hom nay.
          if (isToday)
            Positioned(
              left: 0,
              right: 0,
              top:
                  offsets[now.hour] + heights[now.hour] * (now.minute / 60) - 1,
              child: IgnorePointer(
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: glow,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(child: Container(height: 1.5, color: glow)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HourCell extends StatelessWidget {
  const _HourCell({
    required this.height,
    required this.day,
    required this.hour,
    required this.occs,
    required this.colW,
    required this.now,
    required this.expanded,
    required this.onToggleExpand,
    required this.onAddAt,
    required this.onEdit,
    required this.onToggleDone,
    required this.onDropOccurrence,
    required this.onDropInboxTask,
  });

  final double height;
  final DateTime day;
  final int hour;
  final List<PlannerOccurrence> occs;
  final double colW;
  final DateTime now;
  final bool expanded;
  final VoidCallback onToggleExpand;
  final void Function(DateTime hourStart) onAddAt;
  final void Function(PlannerOccurrence occ) onEdit;
  final void Function(PlannerOccurrence occ) onToggleDone;
  final void Function(PlannerOccurrence occ, DateTime newStart)
  onDropOccurrence;
  final void Function(PlannerTask task, DateTime start) onDropInboxTask;

  DateTime get _hourStart => DateTime(day.year, day.month, day.day, hour);

  @override
  Widget build(BuildContext context) {
    return DragTarget<PlannerDragPayload>(
      onAcceptWithDetails: (details) {
        final p = details.data;
        final occ = p.occurrence;
        if (occ != null) {
          // Giu nguyen PHUT ban dau (truoc day luon lam tron ve HH:00).
          onDropOccurrence(
            occ,
            DateTime(day.year, day.month, day.day, hour, occ.start.minute),
          );
        } else if (p.inboxTask != null) {
          onDropInboxTask(p.inboxTask!, _hourStart);
        }
      },
      builder: (context, candidate, rejected) {
        return GestureDetector(
          // Bam vao phan trong cua o (ke ca o da co viec) de them viec moi
          // tai gio nay - card ben trong tu bat su kien bam cua chinh no.
          behavior: HitTestBehavior.translucent,
          onTap: () => onAddAt(_hourStart),
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(
              horizontal: 3,
              vertical: _cellPad,
            ),
            decoration: BoxDecoration(
              color: candidate.isNotEmpty
                  ? Colors.white.withValues(alpha: 0.08)
                  : null,
              border: const Border(top: BorderSide(color: Color(0x12FFFFFF))),
            ),
            child: occs.isEmpty
                ? const SizedBox.expand()
                : _CellContent(
                    occs: occs,
                    colW: colW,
                    now: now,
                    expanded: expanded,
                    onToggleExpand: onToggleExpand,
                    onEdit: onEdit,
                    onToggleDone: onToggleDone,
                  ),
          ),
        );
      },
    );
  }
}

class _CellContent extends ConsumerWidget {
  const _CellContent({
    required this.occs,
    required this.colW,
    required this.now,
    required this.expanded,
    required this.onToggleExpand,
    required this.onEdit,
    required this.onToggleDone,
  });

  final List<PlannerOccurrence> occs;
  final double colW;
  final DateTime now;
  final bool expanded;
  final VoidCallback onToggleExpand;
  final void Function(PlannerOccurrence occ) onEdit;
  final void Function(PlannerOccurrence occ) onToggleDone;

  Widget _draggable(PlannerOccurrence occ, Widget child) =>
      LongPressDraggable<PlannerDragPayload>(
        data: PlannerDragPayload.occurrence(occ),
        feedback: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: colW - 6,
            child: Opacity(
              opacity: 0.92,
              child: _OccurrenceCard(
                occ: occ,
                now: now,
                onTap: () {},
                onToggleDone: () {},
              ),
            ),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.3, child: child),
        child: child,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collapsed = occs.length > 3 && !expanded;
    final rest = occs.skip(1).take(collapsed ? 1 : occs.length - 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _draggable(
          occs.first,
          _OccurrenceCard(
            occ: occs.first,
            now: now,
            onTap: () => onEdit(occs.first),
            onToggleDone: () => onToggleDone(occs.first),
          ),
        ),
        for (final o in rest) ...[
          const SizedBox(height: _gap),
          _draggable(
            o,
            _MiniRow(
              occ: o,
              now: now,
              onTap: () => onEdit(o),
              onToggleDone: () => onToggleDone(o),
            ),
          ),
        ],
        if (occs.length > 3) ...[
          const SizedBox(height: _gap),
          GestureDetector(
            onTap: onToggleExpand,
            child: Container(
              height: _chipH,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 12,
                    color: AppColors.textMuted,
                  ),
                  Text(
                    expanded
                        ? ''
                        : '+${occs.length - 2} ${ref.tr('planner_more_tasks')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.muted(
                      size: 9,
                      weight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

String _hhmm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Vong tick 1 cham - vien mau theo trang thai hien thi; Hoan thanh = to day
/// + dau tick, Bo qua = dau X. Dung chung cho timeline + sheet viec qua han.
class PlannerTickCircle extends StatelessWidget {
  const PlannerTickCircle({
    super.key,
    required this.status,
    required this.onTap,
    this.size = 16,
  });

  final PlannerTaskStatus status;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    final done = status == PlannerTaskStatus.completed;
    final skipped = status == PlannerTaskStatus.rejected;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        // Vung bam rong hon hinh ve de de trung tren man nho.
        padding: const EdgeInsets.all(3),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? color : null,
            border: Border.all(color: color, width: 1.6),
          ),
          child: done || skipped
              ? Icon(
                  done ? Icons.check_rounded : Icons.close_rounded,
                  size: size * 0.7,
                  color: done ? const Color(0xFF0A0E1C) : color,
                )
              : null,
        ),
      ),
    );
  }
}

class _OccurrenceCard extends StatelessWidget {
  const _OccurrenceCard({
    required this.occ,
    required this.now,
    required this.onTap,
    required this.onToggleDone,
  });

  final PlannerOccurrence occ;
  final DateTime now;
  final VoidCallback onTap;
  final VoidCallback onToggleDone;

  @override
  Widget build(BuildContext context) {
    final task = occ.task;
    final status = occ.statusAt(now);
    final hasCustomIcon = task.icon != PlannerTaskIcon.none;
    final tint = hasCustomIcon
        ? task.icon.color
        : plannerSectionTint(task.appSection);
    final iconData = hasCustomIcon
        ? task.icon.iconData
        : plannerSectionIcon(task.appSection);
    final settled =
        status == PlannerTaskStatus.completed ||
        status == PlannerTaskStatus.rejected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: _cardH,
        padding: const EdgeInsets.fromLTRB(2, 4, 6, 4),
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                status == PlannerTaskStatus.running ||
                    status == PlannerTaskStatus.overdue
                ? status.color.withValues(alpha: 0.55)
                : AppColors.glassBorder,
          ),
        ),
        child: Row(
          children: [
            PlannerTickCircle(status: status, onTap: onToggleDone),
            const SizedBox(width: 2),
            Expanded(
              child: Opacity(
                opacity: settled ? 0.55 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(iconData, size: 10, color: tint),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            _hhmm(occ.start),
                            maxLines: 1,
                            style: AppTextStyles.muted(
                              size: 8.5,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (task.subtasks.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 2),
                            child: Text(
                              '${occ.checkedCount}/${task.subtasks.length}',
                              style: AppTextStyles.muted(
                                size: 8.5,
                                weight: FontWeight.w800,
                              ),
                            ),
                          ),
                        if (task.isRecurring)
                          const Icon(
                            Icons.repeat_rounded,
                            size: 9,
                            color: AppColors.textMuted,
                          ),
                        if (task.reminderEnabled)
                          const Icon(
                            Icons.notifications_rounded,
                            size: 9,
                            color: Color(0xFFFFD66B),
                          ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          AppTextStyles.body(
                            size: 10,
                            weight: FontWeight.w700,
                          ).copyWith(
                            height: 1.15,
                            decoration: status == PlannerTaskStatus.completed
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniRow extends StatelessWidget {
  const _MiniRow({
    required this.occ,
    required this.now,
    required this.onTap,
    required this.onToggleDone,
  });

  final PlannerOccurrence occ;
  final DateTime now;
  final VoidCallback onTap;
  final VoidCallback onToggleDone;

  @override
  Widget build(BuildContext context) {
    final status = occ.statusAt(now);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: _miniH,
        padding: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.035),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            PlannerTickCircle(status: status, onTap: onToggleDone, size: 11),
            Expanded(
              child: Text(
                occ.task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body(size: 9.5, weight: FontWeight.w700)
                    .copyWith(
                      decoration: status == PlannerTaskStatus.completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../planner/presentation/planner_accent.dart';

/// Mo May tinh dang bottom sheet VUA VOI NOI DUNG (khong dung openAppPopup
/// voi FractionallySizedBox 0.94 nhu cac man khac - May tinh chi can 1 phan
/// nho man hinh, de heightFactor gan full se de lai 1 khoang trong lon phia
/// tren rat "to"/lech mat, dung bug nguoi dung bao). Khong useRootNavigator
/// vi ham nay luon duoc goi voi context da nam duoi root Navigator (tu
/// AssistiveFabOverlay dung rootNavigatorKey.currentContext, hoac tu ngay
/// trong 1 popup Quan ly tai san da mo qua root Navigator).
void openCalculatorPopup(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const CalculatorScreen(),
  );
}

/// May tinh chuan (4 phep tinh + %, +/-) - tinh ngay tung buoc khi bam toan
/// tu lien tiep (giong may tinh dien thoai thong thuong), khong phai parser
/// bieu thuc day du.
class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

enum _Op { add, subtract, multiply, divide }

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  String _display = '0';
  double? _first;
  _Op? _pendingOp;
  bool _justEvaluated = false;
  bool _startFresh = false;
  // Dong chu nho phia tren ket qua chinh - hien lai phep tinh dang go/vua
  // tinh (vd "500.000 + 300.000" hoac "500.000 + 300.000 =") de nguoi dung
  // doi chieu lai truoc khi tin vao ket qua, giong may tinh dien thoai.
  String _historyText = '';

  String _opSymbol(_Op op) => switch (op) {
    _Op.add => '+',
    _Op.subtract => '−',
    _Op.multiply => '×',
    _Op.divide => '÷',
  };

  // TRA VE SO THO (khong chen dau `,`) - ham nay dung de gan vao [_display],
  // ma [_display] chi luon luu so THO (giong luc dang go tay) roi build()
  // moi goi [_groupDigits] 1 LAN DUY NHAT de hien thi (xem Text o build()).
  // Truoc day ham nay tu goi _groupDigits() roi luu thang vao _display,
  // khien build() goi _groupDigits LAN 2 tren chuoi DA CO dau `,` - dau `,`
  // cu bi hieu nham la 1 ky tu thuong trong phan nguyen, chen them dau `,`
  // sai vi tri (vd "162500" -> "162,500" -> "1,62,,500"). Noi nao can hien
  // THI so da tinh (vd _historyText) phai tu goi _groupDigits() rieng.
  String _formatNumber(double n) {
    if (n == n.roundToDouble() && n.abs() < 1e15) {
      return n.toStringAsFixed(0);
    }
    var s = n.toStringAsFixed(8);
    s = s.replaceFirst(RegExp(r'0+$'), '');
    s = s.replaceFirst(RegExp(r'\.$'), '');
    return s;
  }

  /// Chen dau `,` phan cach hang nghin vao phan nguyen cua 1 chuoi so - dung
  /// CHUNG cho ca so da tinh xong ([_formatNumber]) LAN so dang go do trong
  /// [_display] (xem noi dung [build]), giu nguyen dau `-`/phan thap phan.
  /// Cung quy uoc dau `,` nhu [ThousandsInputFormatter] o cac sheet nhap
  /// tien khac trong Quan ly tai san.
  String _groupDigits(String raw) {
    if (raw == 'Error') return raw;
    final isNeg = raw.startsWith('-');
    final unsigned = isNeg ? raw.substring(1) : raw;
    final dotIndex = unsigned.indexOf('.');
    final intPart = dotIndex == -1 ? unsigned : unsigned.substring(0, dotIndex);
    final decPart = dotIndex == -1 ? '' : unsigned.substring(dotIndex);
    if (intPart.isEmpty) return '${isNeg ? '-' : ''}$decPart';
    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write(',');
      buffer.write(intPart[i]);
    }
    return '${isNeg ? '-' : ''}$buffer$decPart';
  }

  void _inputDigit(String digit) {
    setState(() {
      if (_startFresh || _display == '0' || _justEvaluated) {
        _display = digit;
        _startFresh = false;
        _justEvaluated = false;
      } else {
        if (_display.replaceAll('-', '').replaceAll('.', '').length >= 15) {
          return;
        }
        _display += digit;
      }
      _updateHistoryWhileTyping();
    });
  }

  void _inputDot() {
    setState(() {
      if (_startFresh || _justEvaluated) {
        _display = '0.';
        _startFresh = false;
        _justEvaluated = false;
      } else if (!_display.contains('.')) {
        _display += '.';
      }
      _updateHistoryWhileTyping();
    });
  }

  /// Cap nhat [_historyText] khi dang go/sua so hang thu 2 (sau khi da co
  /// [_pendingOp]) - khong lam gi neu chua chon phep tinh nao.
  void _updateHistoryWhileTyping() {
    if (_first != null && _pendingOp != null) {
      _historyText =
          '${_groupDigits(_formatNumber(_first!))} ${_opSymbol(_pendingOp!)} '
          '${_groupDigits(_display)}';
    }
  }

  void _toggleSign() {
    setState(() {
      if (_display == '0') return;
      _display = _display.startsWith('-')
          ? _display.substring(1)
          : '-$_display';
    });
  }

  void _percent() {
    setState(() {
      final value = double.tryParse(_display) ?? 0;
      _display = _formatNumber(value / 100);
    });
  }

  void _clear() {
    setState(() {
      _display = '0';
      _first = null;
      _pendingOp = null;
      _justEvaluated = false;
      _startFresh = false;
      _historyText = '';
    });
  }

  void _backspace() {
    setState(() {
      if (_display.length <= 1 ||
          (_display.length == 2 && _display.startsWith('-'))) {
        _display = '0';
      } else {
        _display = _display.substring(0, _display.length - 1);
      }
      _updateHistoryWhileTyping();
    });
  }

  double _apply(double a, double b, _Op op) => switch (op) {
    _Op.add => a + b,
    _Op.subtract => a - b,
    _Op.multiply => a * b,
    _Op.divide => b == 0 ? double.nan : a / b,
  };

  void _pressOp(_Op op) {
    setState(() {
      final current = double.tryParse(_display) ?? 0;
      if (_first != null && _pendingOp != null && !_startFresh) {
        final result = _apply(_first!, current, _pendingOp!);
        _display = result.isNaN ? 'Error' : _formatNumber(result);
        _first = result.isNaN ? null : result;
      } else {
        _first = current;
      }
      _pendingOp = op;
      _startFresh = true;
      _justEvaluated = false;
      _historyText = '${_groupDigits(_formatNumber(_first!))} ${_opSymbol(op)}';
    });
  }

  void _equals() {
    setState(() {
      if (_first == null || _pendingOp == null) return;
      final current = double.tryParse(_display) ?? 0;
      final result = _apply(_first!, current, _pendingOp!);
      _historyText =
          '${_groupDigits(_formatNumber(_first!))} ${_opSymbol(_pendingOp!)} '
          '${_groupDigits(_formatNumber(current))} =';
      _display = result.isNaN ? 'Error' : _formatNumber(result);
      _first = null;
      _pendingOp = null;
      _justEvaluated = true;
      _startFresh = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = plannerSectionTint(ref.watch(currentAppSectionProvider));
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF12172E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PopupHeader(title: ref.tr('wealth_calculator_title')),
            const SizedBox(height: 18),
            if (_historyText.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _historyText,
                    style: AppTextStyles.muted(size: 18),
                  ),
                ),
              ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _groupDigits(_display),
                  style: AppTextStyles.heading(size: 56),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _CalcRow(
              children: [
                _CalcButton(
                  label: 'C',
                  style: _CalcButtonStyle.secondary,
                  accentColor: accent,
                  onTap: _clear,
                ),
                _CalcButton(
                  label: '±',
                  style: _CalcButtonStyle.secondary,
                  accentColor: accent,
                  onTap: _toggleSign,
                ),
                _CalcButton(
                  label: '%',
                  style: _CalcButtonStyle.secondary,
                  accentColor: accent,
                  onTap: _percent,
                ),
                _CalcButton(
                  label: '÷',
                  style: _CalcButtonStyle.accent,
                  accentColor: accent,
                  selected: _pendingOp == _Op.divide && _startFresh,
                  onTap: () => _pressOp(_Op.divide),
                ),
              ],
            ),
            _CalcRow(
              children: [
                _CalcButton(
                  label: '7',
                  accentColor: accent,
                  onTap: () => _inputDigit('7'),
                ),
                _CalcButton(
                  label: '8',
                  accentColor: accent,
                  onTap: () => _inputDigit('8'),
                ),
                _CalcButton(
                  label: '9',
                  accentColor: accent,
                  onTap: () => _inputDigit('9'),
                ),
                _CalcButton(
                  label: '×',
                  style: _CalcButtonStyle.accent,
                  accentColor: accent,
                  selected: _pendingOp == _Op.multiply && _startFresh,
                  onTap: () => _pressOp(_Op.multiply),
                ),
              ],
            ),
            _CalcRow(
              children: [
                _CalcButton(
                  label: '4',
                  accentColor: accent,
                  onTap: () => _inputDigit('4'),
                ),
                _CalcButton(
                  label: '5',
                  accentColor: accent,
                  onTap: () => _inputDigit('5'),
                ),
                _CalcButton(
                  label: '6',
                  accentColor: accent,
                  onTap: () => _inputDigit('6'),
                ),
                _CalcButton(
                  label: '−',
                  style: _CalcButtonStyle.accent,
                  accentColor: accent,
                  selected: _pendingOp == _Op.subtract && _startFresh,
                  onTap: () => _pressOp(_Op.subtract),
                ),
              ],
            ),
            _CalcRow(
              children: [
                _CalcButton(
                  label: '1',
                  accentColor: accent,
                  onTap: () => _inputDigit('1'),
                ),
                _CalcButton(
                  label: '2',
                  accentColor: accent,
                  onTap: () => _inputDigit('2'),
                ),
                _CalcButton(
                  label: '3',
                  accentColor: accent,
                  onTap: () => _inputDigit('3'),
                ),
                _CalcButton(
                  label: '+',
                  style: _CalcButtonStyle.accent,
                  accentColor: accent,
                  selected: _pendingOp == _Op.add && _startFresh,
                  onTap: () => _pressOp(_Op.add),
                ),
              ],
            ),
            _CalcRow(
              children: [
                _CalcButton(
                  label: '⌫',
                  style: _CalcButtonStyle.secondary,
                  accentColor: accent,
                  onTap: _backspace,
                ),
                _CalcButton(
                  label: '0',
                  accentColor: accent,
                  onTap: () => _inputDigit('0'),
                ),
                _CalcButton(label: '.', accentColor: accent, onTap: _inputDot),
                _CalcButton(
                  label: '=',
                  style: _CalcButtonStyle.accent,
                  accentColor: accent,
                  filled: true,
                  onTap: _equals,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CalcRow extends StatelessWidget {
  const _CalcRow({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          for (final c in children) ...[
            Expanded(child: c),
            if (c != children.last) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

enum _CalcButtonStyle { normal, secondary, accent }

class _CalcButton extends StatelessWidget {
  const _CalcButton({
    required this.label,
    required this.onTap,
    required this.accentColor,
    this.style = _CalcButtonStyle.normal,
    this.selected = false,
    this.filled = false,
  });
  final String label;
  final VoidCallback onTap;
  final Color accentColor;
  final _CalcButtonStyle style;
  final bool selected;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (style) {
      case _CalcButtonStyle.secondary:
        bg = AppColors.glassFill;
        fg = AppColors.textPrimary;
      case _CalcButtonStyle.accent:
        bg = selected
            ? Colors.white
            : (filled
                  ? accentColor.withValues(alpha: 0.9)
                  : accentColor.withValues(alpha: 0.18));
        fg = selected ? accentColor : (filled ? Colors.white : accentColor);
      case _CalcButtonStyle.normal:
        bg = AppColors.glassFill.withValues(alpha: 0.5);
        fg = AppColors.textPrimary;
    }
    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: bg,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

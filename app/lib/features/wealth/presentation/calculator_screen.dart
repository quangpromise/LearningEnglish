import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';

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

  String _formatNumber(double n) {
    if (n == n.roundToDouble() && n.abs() < 1e15) {
      return n.toStringAsFixed(0);
    }
    var s = n.toStringAsFixed(8);
    s = s.replaceFirst(RegExp(r'0+$'), '');
    s = s.replaceFirst(RegExp(r'\.$'), '');
    return s;
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
    });
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
    });
  }

  void _equals() {
    setState(() {
      if (_first == null || _pendingOp == null) return;
      final current = double.tryParse(_display) ?? 0;
      final result = _apply(_first!, current, _pendingOp!);
      _display = result.isNaN ? 'Error' : _formatNumber(result);
      _first = null;
      _pendingOp = null;
      _justEvaluated = true;
      _startFresh = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer(
              builder: (context, ref, _) => Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.glassFill,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ref.tr('wealth_calculator_title'),
                      style: AppTextStyles.heading(size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(_display, style: AppTextStyles.heading(size: 56)),
              ),
            ),
            const SizedBox(height: 20),
            _CalcRow(
              children: [
                _CalcButton(
                  label: 'C',
                  style: _CalcButtonStyle.secondary,
                  onTap: _clear,
                ),
                _CalcButton(
                  label: '±',
                  style: _CalcButtonStyle.secondary,
                  onTap: _toggleSign,
                ),
                _CalcButton(
                  label: '%',
                  style: _CalcButtonStyle.secondary,
                  onTap: _percent,
                ),
                _CalcButton(
                  label: '÷',
                  style: _CalcButtonStyle.accent,
                  selected: _pendingOp == _Op.divide && _startFresh,
                  onTap: () => _pressOp(_Op.divide),
                ),
              ],
            ),
            _CalcRow(
              children: [
                _CalcButton(label: '7', onTap: () => _inputDigit('7')),
                _CalcButton(label: '8', onTap: () => _inputDigit('8')),
                _CalcButton(label: '9', onTap: () => _inputDigit('9')),
                _CalcButton(
                  label: '×',
                  style: _CalcButtonStyle.accent,
                  selected: _pendingOp == _Op.multiply && _startFresh,
                  onTap: () => _pressOp(_Op.multiply),
                ),
              ],
            ),
            _CalcRow(
              children: [
                _CalcButton(label: '4', onTap: () => _inputDigit('4')),
                _CalcButton(label: '5', onTap: () => _inputDigit('5')),
                _CalcButton(label: '6', onTap: () => _inputDigit('6')),
                _CalcButton(
                  label: '−',
                  style: _CalcButtonStyle.accent,
                  selected: _pendingOp == _Op.subtract && _startFresh,
                  onTap: () => _pressOp(_Op.subtract),
                ),
              ],
            ),
            _CalcRow(
              children: [
                _CalcButton(label: '1', onTap: () => _inputDigit('1')),
                _CalcButton(label: '2', onTap: () => _inputDigit('2')),
                _CalcButton(label: '3', onTap: () => _inputDigit('3')),
                _CalcButton(
                  label: '+',
                  style: _CalcButtonStyle.accent,
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
                  onTap: _backspace,
                ),
                _CalcButton(label: '0', onTap: () => _inputDigit('0')),
                _CalcButton(label: '.', onTap: _inputDot),
                _CalcButton(
                  label: '=',
                  style: _CalcButtonStyle.accent,
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
    this.style = _CalcButtonStyle.normal,
    this.selected = false,
    this.filled = false,
  });
  final String label;
  final VoidCallback onTap;
  final _CalcButtonStyle style;
  final bool selected;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.wealthAccent;
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

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;

import '../../../core/theme/app_theme.dart';
import '../data/songs_data.dart';

// ---------------------------------------------------------------------------
// Mo hinh du lieu: chia moi dong lyric xuong TUNG TU kem moc thoi gian rieng
// ---------------------------------------------------------------------------

/// Mot tu trong dong lyric kem khoang thoi gian no duoc hat (giay).
class KaraokeWord {
  const KaraokeWord(this.text, this.start, this.end);

  final String text;
  final double start;
  final double end;

  /// 0 = chua hat toi, 1 = da hat xong, o giua = dang hat do (dung cho
  /// hieu ung "quet" mau tu trai sang phai ben trong 1 tu).
  double progressAt(double seconds) {
    // Tu co do dai 0 giay (du lieu loi/2 dong trung moc) phai nhay thang
    // sang "da hat xong", neu khong no se ket o trang thai mo vinh vien.
    if (end <= start) return seconds >= start ? 1 : 0;
    if (seconds <= start) return 0;
    if (seconds >= end) return 1;
    return (seconds - start) / (end - start);
  }
}

/// Mot dong lyric da duoc chia nho toi tung tu de chay hieu ung karaoke.
class KaraokeLine {
  const KaraokeLine({
    required this.start,
    required this.end,
    required this.words,
    required this.viWords,
    required this.en,
    required this.vi,
  });

  final double start;
  final double end;

  /// Tung tu tieng Anh kem moc thoi gian rieng.
  final List<KaraokeWord> words;

  /// Tung tu cua dong DICH tieng Viet, trai deu tren DUNG khoang thoi gian
  /// cua dong tieng Anh (cung [start], cung [end]).
  ///
  /// Day KHONG phai la ghep tu-doi-tu: ban dich khac thu tu tu so voi cau
  /// goc nen tu thu i tieng Viet khong ung voi tu thu i tieng Anh. No chi
  /// tra loi "cau nay da hat toi dau roi" bang tieng Viet, de nguoi hoc bam
  /// duoc nghia theo dung nhip hat.
  final List<KaraokeWord> viWords;

  final String en;
  final String vi;
}

// ---------------------------------------------------------------------------
// Uoc luong thoi diem tung tu
// ---------------------------------------------------------------------------
//
// `songs_data.dart` chi luu moc thoi gian cho DAU MOI DONG (canh bang
// forced-alignment ASR - xem scripts/realign_lyrics.py), khong co moc cap-tu.
// Thay vi chia deu do dai dong cho so tu (khien tu ngan nhu "a"/"the" chiem
// bang tu dai nhu "abandoned"), ta uoc luong theo SO AM TIET: mot ca si hat
// gan nhu deu am tiet, nen am tiet la don vi do tot hon nhieu so voi tu.
//
// Neu sau nay co du lieu cap-tu that (vd chay lai ASR va ghi timestamp tung
// tu vao songs_data.dart), chi can thay ham `buildKaraokeLines` doc thang
// tu do - toan bo phan giao dien ben duoi khong phai sua gi.

/// Do dai (giay) uoc tinh cho 1 "don vi" (1 am tiet). Gia tri nay chi dung
/// de phan chia TY LE giua cac tu trong cung 1 dong va de doan xem dong do
/// duoc hat trong bao lau khi khoang cach toi dong sau qua dai (doan nhac
/// dao/nhac nen) - thoi diem BAT DAU dong van lay tu du lieu that.
const double _kSecondsPerSyllable = 0.42;

/// Moi tu ton them 1 chut thoi gian ngoai phan am tiet (lay hoi, ngat giua
/// cac tu) - neu khong co, cau nhieu tu 1 am tiet se bi quet qua nhanh.
const double _kWordOverhead = 0.45;

const double _kMinLineSeconds = 0.6;

/// Uoc luong so am tiet cua 1 tu tieng Anh: dem cac CUM nguyen am (chuoi
/// nguyen am lien nhau tinh la 1), tru di "e" cam o cuoi tu (make, time...).
int _syllableCount(String word) {
  final w = word.toLowerCase().replaceAll(RegExp("[^a-z']"), '');
  if (w.isEmpty) return 1;
  var count = 0;
  var prevIsVowel = false;
  for (var i = 0; i < w.length; i++) {
    final isVowel = 'aeiouy'.contains(w[i]);
    if (isVowel && !prevIsVowel) count++;
    prevIsVowel = isVowel;
  }
  if (count > 1 && w.length > 2 && w.endsWith('e') && !w.endsWith('le')) {
    count--;
  }
  return count == 0 ? 1 : count;
}

/// "Trong so" thoi gian cua 1 tu. Dau cau cuoi tu duoc cong them vi ca si
/// thuong ngan/ngan hoi o do - nho vay chu dung lai dung cho ngat cau thay
/// vi chay tuot sang tu tiep theo.
double _wordWeight(String word) {
  var weight = _syllableCount(word) + _kWordOverhead;
  if (RegExp(r'[.!?]$').hasMatch(word)) {
    weight += 0.9;
  } else if (RegExp(r'[,;:–—-]$').hasMatch(word)) {
    weight += 0.55;
  }
  return weight;
}

/// "Trong so" thoi gian cua 1 tu tieng Viet. Tieng Viet la ngon ngu don am
/// tiet - moi tu cach nhau bang dau cach chinh la 1 am tiet - nen khong can
/// dem cum nguyen am nhu tieng Anh, chi can cong them cho dau cau.
double _viWordWeight(String word) {
  var weight = 1.0;
  if (RegExp(r'[.!?]$').hasMatch(word)) {
    weight += 0.9;
  } else if (RegExp(r'[,;:–—-]$').hasMatch(word)) {
    weight += 0.55;
  }
  return weight;
}

List<String> _tokenize(String text) =>
    text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

/// Chia [duration] giay cho cac [tokens] theo ty le trong so, bat dau tu
/// [start] va noi tiep nhau lien mach (het tu nay la sang tu ke tiep).
List<KaraokeWord> _distribute(
  List<String> tokens,
  double start,
  double duration,
  double Function(String) weightOf,
) {
  final weights = tokens.map(weightOf).toList();
  final totalWeight = weights.fold<double>(0, (a, b) => a + b);
  final words = <KaraokeWord>[];
  var cursor = start;
  for (var i = 0; i < tokens.length; i++) {
    final slice = totalWeight <= 0
        ? duration / tokens.length
        : duration * weights[i] / totalWeight;
    words.add(KaraokeWord(tokens[i], cursor, cursor + slice));
    cursor += slice;
  }
  return words;
}

/// Chuyen danh sach [LyricLine] (chi co moc dau dong) thanh timeline cap-tu.
List<KaraokeLine> buildKaraokeLines(List<LyricLine> lyrics) {
  final lines = <KaraokeLine>[];
  for (var i = 0; i < lyrics.length; i++) {
    final line = lyrics[i];
    final start = line.startSeconds;
    final tokens = _tokenize(line.en);

    final totalWeight = tokens
        .map(_wordWeight)
        .fold<double>(0, (a, b) => a + b);
    final natural = math.max(
      _kMinLineSeconds,
      totalWeight * _kSecondsPerSyllable,
    );

    // Khoang trong toi dong ke tiep. Dong CUOI bai khong co dong sau de do,
    // dung luon do dai uoc tinh.
    final double gap = i + 1 < lyrics.length
        ? lyrics[i + 1].startSeconds - start
        : double.infinity;

    final double duration;
    if (!gap.isFinite || gap <= 0) {
      duration = natural;
    } else if (gap <= natural) {
      // Dong duoc hat lien mach sang dong sau - quet vua het khoang trong.
      duration = gap;
    } else {
      // Sau dong nay con 1 khoang lang (nhac dao, ngan doan). KHONG keo dai
      // hieu ung quet ra ca khoang lang do (se thay chu bo rat cham so voi
      // giong hat), chi noi them 1 phan nho de bu cho truong hop cau duoc
      // hat cham hon uoc tinh.
      duration = math.min(natural * 1.6, natural + (gap - natural) * 0.35);
    }

    final words = _distribute(tokens, start, duration, _wordWeight);
    // Dong dich chay tren DUNG khoang thoi gian cua dong goc, nen 2 dong
    // luon sang toi dich cung luc.
    final viWords = _distribute(
      _tokenize(line.vi),
      start,
      duration,
      _viWordWeight,
    );

    lines.add(
      KaraokeLine(
        start: start,
        end: words.isEmpty ? start + duration : words.last.end,
        words: words,
        viWords: viWords,
        en: line.en,
        vi: line.vi,
      ),
    );
  }
  return lines;
}

// ---------------------------------------------------------------------------
// Giao dien
// ---------------------------------------------------------------------------

/// Bat/tat hieu ung lam mo (depth-of-field) cho cac dong khong phai dong
/// dang hat. Dep hon han nhung moi dong bi lam mo ton 1 lop ve rieng
/// (saveLayer) - dat `false` neu can uu tien may cau hinh thap.
const bool _kBlurInactiveLines = true;

const double _kWordSize = 19;
const Color _kSungColor = Color(0xFFFFFFFF);
const Color _kIdleColor = Color(0x4DEEF1FB);

/// Dong dich tieng Viet: chu nho hon va mau sang nhat cung diu hon dong
/// goc, de mat luon doc dong tieng Anh truoc.
const double _kViWordSize = 13;
const Color _kViSungColor = Color(0xF2EEF1FB);
const Color _kViIdleColor = Color(0x3DEEF1FB);

/// Do "nhoe" 2 ben mep vet quet trong 1 tu (0 = cat thang dung, cang lon
/// cang mem).
const double _kSweepFeather = 0.09;

/// Do nay len (pixel) cua tu ngay tai luc no dang duoc hat.
const double _kWordLift = 2.8;

/// Sau khi hat xong 1 tu, quang sang quanh no tat dan trong bao lau (giay).
/// Nho do ve dep nhin thay la mot "vet sang" chay doc theo cau theo giong
/// hat, thay vi ca cau da hat deu phat sang cung luc (roi thanh 1 mang).
const double _kAfterglowSeconds = 0.7;

const Duration _kLineTransition = Duration(milliseconds: 320);

/// Danh sach lyric chay karaoke: dong dang hat duoc to sang dan TUNG TU
/// theo giong hat, cac dong con lai lui ve sau bang do mo + lam nhoe.
class KaraokeLyricsView extends StatelessWidget {
  const KaraokeLyricsView({
    super.key,
    required this.lines,
    required this.activeIndex,
    required this.positionSeconds,
    required this.lineKeys,
    required this.bilingual,
    required this.onSeekToLine,
    required this.onWordTap,
  });

  final List<KaraokeLine> lines;
  final int activeIndex;

  /// Vi tri phat hien tai (giay). Chi RIENG dong dang hat lang nghe gia tri
  /// nay, nen viec no doi lien tuc ~60 lan/giay khong lam ca danh sach ve lai.
  final ValueListenable<double> positionSeconds;

  final List<GlobalKey> lineKeys;
  final bool bilingual;
  final void Function(int index) onSeekToLine;
  final void Function(String word) onWordTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Build san nhieu dong o ngoai vung hien thi (khong chi dong dang
      // thay) de khi bai moi mo/seek xa, dong dich da co context san cho
      // Scrollable.ensureVisible thay vi null.
      scrollCacheExtent: const ScrollCacheExtent.pixels(2000),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: lines.length,
      itemBuilder: (context, i) => _LineTile(
        key: lineKeys[i],
        line: lines[i],
        offset: i - activeIndex,
        positionSeconds: positionSeconds,
        bilingual: bilingual,
        onSeek: () => onSeekToLine(i),
        onWordTap: onWordTap,
      ),
    );
  }
}

class _LineTile extends StatelessWidget {
  const _LineTile({
    super.key,
    required this.line,
    required this.offset,
    required this.positionSeconds,
    required this.bilingual,
    required this.onSeek,
    required this.onWordTap,
  });

  final KaraokeLine line;

  /// Khoang cach co dau toi dong dang hat: 0 = chinh no, am = da hat qua,
  /// duong = chua hat toi.
  final int offset;

  final ValueListenable<double> positionSeconds;
  final bool bilingual;
  final VoidCallback onSeek;
  final void Function(String word) onWordTap;

  @override
  Widget build(BuildContext context) {
    final isActive = offset == 0;
    final distance = offset.abs();

    final opacity = switch (distance) {
      0 => 1.0,
      1 => 0.44,
      2 => 0.3,
      _ => 0.2,
    };
    final blur = !_kBlurInactiveLines || distance < 2
        ? 0.0
        : (distance == 2 ? 1.0 : 1.8);

    // Ca dong goc lan dong dich deu chay tren cung 1 moc thoi gian, nen
    // dung CHUNG 1 listener - neu tach 2 ValueListenableBuilder thi moi
    // khung hinh phai danh thuc 2 lan cho cung 1 gia tri.
    Widget rowsAt(double seconds) => Column(
      children: [
        _WordsRow(
          words: line.words,
          seconds: seconds,
          style: _RowStyle.lyric,
          onWordTap: isActive ? onWordTap : null,
        ),
        if (bilingual && line.viWords.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: _WordsRow(
              words: line.viWords,
              seconds: seconds,
              style: _RowStyle.translation,
              onWordTap: null,
            ),
          ),
      ],
    );

    final Widget rows = isActive
        ? ValueListenableBuilder<double>(
            valueListenable: positionSeconds,
            builder: (_, seconds, _) => rowsAt(seconds),
          )
        // Dong da hat qua giu mau sang (da thuoc), dong chua toi de mau mo -
        // nho vay nguoi hoc luon thay ro minh dang o dau trong bai.
        : rowsAt(offset < 0 ? line.end + 1 : line.start - 1);

    Widget content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 2),
      child: rows,
    );

    if (_kBlurInactiveLines) {
      content = TweenAnimationBuilder<double>(
        tween: Tween<double>(end: blur),
        duration: _kLineTransition,
        curve: Curves.easeOut,
        child: content,
        builder: (_, sigma, child) => sigma < 0.05
            ? child!
            : ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                child: child,
              ),
      );
    }

    return GestureDetector(
      onTap: onSeek,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        // Phong to bang Transform (khong doi font size) - doi font size se
        // lam danh sach tinh lai chieu cao va giat vi tri cuon moi lan sang
        // dong moi.
        scale: isActive ? 1.05 : 0.97,
        duration: _kLineTransition,
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: opacity,
          duration: _kLineTransition,
          curve: Curves.easeOut,
          child: content,
        ),
      ),
    );
  }
}

/// Bo tham so ve cho 1 hang chu. Dong goc tieng Anh la nhan vat chinh (chu
/// to, trang han, co nhun + quang sang manh); dong dich tieng Viet dung
/// cung hieu ung nhung diu hon han de khong tranh mat voi dong goc.
class _RowStyle {
  const _RowStyle({
    required this.textStyle,
    required this.sungColor,
    required this.idleColor,
    required this.glowStrength,
    required this.lift,
    required this.gap,
  });

  /// Khoi tao 1 lan roi dung lai: `rowsAt()` chay lai moi khung hinh cho
  /// dong dang hat nen khong nen dung lai TextStyle moi mieng.
  static final _RowStyle lyric = _RowStyle(
    textStyle: AppTextStyles.heading(size: _kWordSize).copyWith(height: 1.4),
    sungColor: _kSungColor,
    idleColor: _kIdleColor,
    glowStrength: 1,
    lift: _kWordLift,
    gap: 3,
  );

  static final _RowStyle translation = _RowStyle(
    textStyle: AppTextStyles.muted(size: _kViWordSize).copyWith(height: 1.35),
    sungColor: _kViSungColor,
    idleColor: _kViIdleColor,
    glowStrength: 0.35,
    lift: 0,
    gap: 2,
  );

  final TextStyle textStyle;
  final Color sungColor;
  final Color idleColor;

  /// He so nhan len do dam cua quang sang (0 = tat han).
  final double glowStrength;

  final double lift;
  final double gap;
}

class _WordsRow extends StatelessWidget {
  const _WordsRow({
    required this.words,
    required this.seconds,
    required this.style,
    required this.onWordTap,
  });

  final List<KaraokeWord> words;
  final double seconds;
  final _RowStyle style;
  final void Function(String word)? onWordTap;

  @override
  Widget build(BuildContext context) {
    final n = words.length;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < n; i++)
          _WordChip(
            word: words[i],
            progress: words[i].progressAt(seconds),
            afterglow: _afterglowAt(words[i], seconds),
            // Quang sang chay dan tu xanh sang tim doc theo cau - tao cam
            // giac anh sang "troi" theo giong hat thay vi 1 mau chet.
            glow: Color.lerp(
              AppColors.blue,
              AppColors.purple,
              n <= 1 ? 0.5 : i / (n - 1),
            )!,
            style: style,
            onTap: _tapHandlerFor(words[i].text),
          ),
      ],
    );
  }

  VoidCallback? _tapHandlerFor(String text) {
    final onTap = onWordTap;
    if (onTap == null) return null;
    final word = text.replaceAll(RegExp('[^a-zA-Z]'), '');
    // Token chi gom dau cau (vd "-") khong tra tu dien duoc.
    if (word.isEmpty) return null;
    return () => onTap(word);
  }
}

/// 1 ngay khi tu dang duoc hat, roi giam ve 0 trong [_kAfterglowSeconds]
/// giay sau khi hat xong.
double _afterglowAt(KaraokeWord word, double seconds) {
  if (seconds < word.end) return 1;
  final fade = 1 - (seconds - word.end) / _kAfterglowSeconds;
  return fade.clamp(0.0, 1.0);
}

class _WordChip extends StatelessWidget {
  const _WordChip({
    required this.word,
    required this.progress,
    required this.afterglow,
    required this.glow,
    required this.style,
    required this.onTap,
  });

  final KaraokeWord word;
  final double progress;

  /// Cuong do quang sang con lai (1 = dang hat, 0 = da hat xong tu lau).
  final double afterglow;

  final Color glow;
  final _RowStyle style;
  final VoidCallback? onTap;

  List<Shadow>? _glowShadows(double strength) {
    final alpha = strength * style.glowStrength;
    if (alpha <= 0.01) return null;
    return [
      Shadow(color: glow.withValues(alpha: alpha), blurRadius: 18),
      Shadow(color: glow.withValues(alpha: alpha * 0.5), blurRadius: 38),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final p = progress;
    final base = style.textStyle;

    final Widget text;
    if (p <= 0) {
      text = Text(word.text, style: base.copyWith(color: style.idleColor));
    } else if (p >= 1) {
      text = Text(
        word.text,
        style: base.copyWith(
          color: style.sungColor,
          shadows: _glowShadows(0.8 * afterglow),
        ),
      );
    } else {
      // Tu DANG duoc hat: to sang dan tu trai sang phai ngay ben trong 1 tu
      // (dung vet quet karaoke that, khong phai bat sang ca tu cung luc).
      //
      // Quang sang phai ve THANH LOP RIENG o duoi, KHONG duoc de trong
      // child cua ShaderMask: ShaderMask to lai moi diem anh nam trong o
      // chu bang mau cua gradient, nen phan bong mo nam trong o do se bi
      // to trang theo va hien ra thanh mot mang sang hinh chu nhat quanh tu.
      final glowShadows = _glowShadows(0.95);
      text = Stack(
        alignment: Alignment.center,
        children: [
          if (glowShadows != null)
            Text(
              word.text,
              style: base.copyWith(
                color: Colors.transparent,
                shadows: glowShadows,
              ),
            ),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (rect) => LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                style.sungColor,
                style.sungColor,
                style.idleColor,
                style.idleColor,
              ],
              stops: [
                0,
                (p - _kSweepFeather).clamp(0.0, 1.0),
                (p + _kSweepFeather).clamp(0.0, 1.0),
                1,
              ],
            ).createShader(rect),
            child: Text(word.text, style: base.copyWith(color: Colors.white)),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        // Nhun nhe len roi ha xuong dung luc tu do duoc hat - tao "con song"
        // chay doc theo cau.
        offset: Offset(0, -style.lift * math.sin(p * math.pi)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: style.gap, vertical: 1),
          child: text,
        ),
      ),
    );
  }
}

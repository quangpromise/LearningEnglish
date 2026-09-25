import 'dart:math';

import 'exercise_model.dart';

/// Diem 2D (toa do anh) cua 1 khop tu pose detection.
class PosePoint {
  const PosePoint(this.x, this.y);
  final double x;
  final double y;
}

/// Goc (do, 0-180) tai [b] tao boi 3 diem a-b-c, vd hong-goi-co chan =
/// goc goi.
double jointAngle(PosePoint a, PosePoint b, PosePoint c) {
  final abx = a.x - b.x, aby = a.y - b.y;
  final cbx = c.x - b.x, cby = c.y - b.y;
  final dot = abx * cbx + aby * cby;
  final mag = sqrt(abx * abx + aby * aby) * sqrt(cbx * cbx + cby * cby);
  if (mag == 0) return 180;
  final cos = (dot / mag).clamp(-1.0, 1.0);
  return acos(cos) * 180 / pi;
}

/// Khop dung de dem rep.
enum RepJoint { knee, elbow, hip }

/// Mau chuyen dong 1 rep: khop gap xuong duoi [downBelow] do roi duoi len
/// tren [upAbove] do = 1 rep. [targetDepth] = goc can dat o day de tinh la
/// "du sau" (vd squat dui song song mat san ~ 100 do goc goi).
class RepPattern {
  const RepPattern({
    required this.joint,
    required this.downBelow,
    required this.upAbove,
    required this.targetDepth,
    required this.depthCue,
  });

  final RepJoint joint;
  final double downBelow;
  final double upAbove;
  final double targetDepth;

  /// Cau nhac tieng Anh khi rep chua du sau.
  final String depthCue;

  static const squat = RepPattern(
    joint: RepJoint.knee,
    downBelow: 130,
    upAbove: 160,
    targetDepth: 100,
    depthCue: 'Go a little lower!',
  );

  static const push = RepPattern(
    joint: RepJoint.elbow,
    downBelow: 110,
    upAbove: 155,
    targetDepth: 90,
    depthCue: 'Lower your chest more!',
  );

  static const curl = RepPattern(
    joint: RepJoint.elbow,
    downBelow: 70,
    upAbove: 140,
    targetDepth: 55,
    depthCue: 'Squeeze all the way up!',
  );

  static const hinge = RepPattern(
    joint: RepJoint.hip,
    downBelow: 120,
    upAbove: 160,
    targetDepth: 100,
    depthCue: 'Push your hips back more!',
  );

  /// Chon mau theo ten tieng Anh cua bai (null = bai nay chua ho tro dem
  /// bang camera, vd plank, cardio).
  static RepPattern? forExercise(Exercise exercise) {
    final name = exercise.nameEn.toLowerCase();
    bool has(String k) => name.contains(k);
    if (has('curl')) return curl;
    if (has('squat') || has('lunge') || has('leg press') || has('step')) {
      return squat;
    }
    if (has('deadlift') ||
        has('hip thrust') ||
        has('good morning') ||
        has('swing') ||
        has('bridge')) {
      return hinge;
    }
    if (has('push') || has('press') || has('dip') || has('bench')) {
      return push;
    }
    return null;
  }
}

/// Su kien sau moi khung hinh.
enum RepEvent { none, rep, shallowRep }

/// May trang thai dem rep co "tre" (hysteresis): phai xuong duoi
/// [RepPattern.downBelow] roi len lai tren [RepPattern.upAbove] moi tinh 1
/// rep - rung/nhieu goc quanh 1 nguong khong dem nham. Goc duoc lam muot
/// bang trung binh truot [smoothing] khung.
class RepCounter {
  RepCounter(this.pattern, {this.smoothing = 3});

  final RepPattern pattern;
  final int smoothing;

  final List<double> _window = [];
  bool _down = false;
  double _minAngleThisRep = 180;

  int reps = 0;
  int shallowReps = 0;

  /// Goc da lam muot gan nhat (null khi chua co du lieu).
  double? angle;

  /// Dua 1 goc moi (do). Tra ve [RepEvent.rep] khi vua xong 1 rep du sau,
  /// [RepEvent.shallowRep] khi xong 1 rep nhung chua du sau.
  RepEvent addAngle(double raw) {
    _window.add(raw);
    if (_window.length > smoothing) _window.removeAt(0);
    final a = _window.reduce((x, y) => x + y) / _window.length;
    angle = a;

    if (!_down) {
      if (a < pattern.downBelow) {
        _down = true;
        _minAngleThisRep = a;
      }
      return RepEvent.none;
    }
    _minAngleThisRep = min(_minAngleThisRep, a);
    if (a > pattern.upAbove) {
      _down = false;
      reps++;
      if (_minAngleThisRep > pattern.targetDepth) {
        shallowReps++;
        return RepEvent.shallowRep;
      }
      return RepEvent.rep;
    }
    return RepEvent.none;
  }

  void reset() {
    _window.clear();
    _down = false;
    _minAngleThisRep = 180;
    reps = 0;
    shallowReps = 0;
    angle = null;
  }
}

/// So dem bang tieng Anh cho giong HLV ("one", "two"...), > 20 doc so.
String repWord(int n) {
  const words = [
    'zero',
    'one',
    'two',
    'three',
    'four',
    'five',
    'six',
    'seven',
    'eight',
    'nine',
    'ten',
    'eleven',
    'twelve',
    'thirteen',
    'fourteen',
    'fifteen',
    'sixteen',
    'seventeen',
    'eighteen',
    'nineteen',
    'twenty',
  ];
  return n >= 0 && n < words.length ? words[n] : '$n';
}

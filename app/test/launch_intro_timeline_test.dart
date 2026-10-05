import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/widgets/launch_intro_timeline.dart';

void main() {
  const full = LaunchIntroVariant.full;
  const short = LaunchIntroVariant.short;

  group('which version plays (#137)', () {
    test('first launch after install or an update: the full version', () {
      expect(launchIntroVariant(seenBuild: null, currentBuild: 'abc'), full);
      expect(launchIntroVariant(seenBuild: 'old', currentBuild: 'abc'), full);
    });

    test('same build as last time: the short version', () {
      expect(launchIntroVariant(seenBuild: 'abc', currentBuild: 'abc'), short);
      // Build tai cho (khong co SHA): lan dau day du, sau do ngan.
      expect(launchIntroVariant(seenBuild: null, currentBuild: ''), full);
      expect(launchIntroVariant(seenBuild: '', currentBuild: ''), short);
    });
  });

  group('timeline (spec #135)', () {
    test('lengths: full ~2.4 s, short ~0.9 s; reduced motion is shorter', () {
      expect(LaunchIntroTimeline(full).endMs, inInclusiveRange(2400, 2500));
      expect(LaunchIntroTimeline(short).endMs, inInclusiveRange(880, 960));
      expect(LaunchIntroTimeline(full, reduce: true).endMs, 920);
      expect(LaunchIntroTimeline(short, reduce: true).endMs, 920);
    });

    test('starts as the system splash left it: the logo alone', () {
      final tl = LaunchIntroTimeline(full);
      expect([for (var i = 0; i < 3; i++) tl.arc(i, 0)], [0, 0, 0]);
      expect(tl.lift(0), 0);
      expect(tl.letterOpacity(0, 0), 0);
      expect(tl.namesOpacity(0), 0);
      expect(tl.skyOpacity(0), 1);
      // Nen phang + chua co vien sang, nhu man cho he thong.
      expect(tl.ramp(0), 0);
      expect(tl.ramp(400), greaterThan(0.99));
    });

    test('the arcs swirl in one after another, then the ring closes', () {
      final tl = LaunchIntroTimeline(full);
      const t = 520.0;
      expect(tl.arc(0, t), greaterThan(tl.arc(1, t)));
      expect(tl.arc(1, t), greaterThan(tl.arc(2, t)));
      // Khep vong luc cung cuoi cham dich: 400 + 2*90 + 214 ms.
      expect(tl.closeAtMs, 794);
      expect(tl.arc(2, tl.closeAtMs.toDouble()), closeTo(1, 0.002));
      expect(tl.flash(tl.closeAtMs + 90), greaterThan(0.5));
      expect(tl.flash(tl.closeAtMs + 600), lessThan(0.05));
    });

    test('one light haptic: when the ring closes, or early when reduced', () {
      expect(LaunchIntroTimeline(full).hapticAtMs, 794);
      expect(LaunchIntroTimeline(short).hapticAtMs, 368);
      expect(LaunchIntroTimeline(full, reduce: true).hapticAtMs, 320);
      expect(LaunchIntroTimeline(short, reduce: true).hapticAtMs, 320);
    });

    test('the full version brings GymTalk, then the authors, then leaves', () {
      final tl = LaunchIntroTimeline(full);
      expect(tl.letterOpacity(0, 1200), greaterThan(0.9));
      expect(tl.letterOpacity(6, 920), lessThan(tl.letterOpacity(0, 920)));
      expect(tl.namesOpacity(1300), 0);
      expect(tl.namesOpacity(2050), greaterThan(0.95));
      expect(tl.sign(2050), greaterThan(0.9));
      expect(tl.contentOpacity(2050), 1);
      expect(tl.contentOpacity(tl.endMs.toDouble()), lessThan(0.01));
      expect(tl.flight(tl.endMs.toDouble()), closeTo(1, 0.01));
    });

    test('the short version has no words and leaves after the ring', () {
      final tl = LaunchIntroTimeline(short);
      expect(tl.hasWords, isFalse);
      expect(tl.lift(400), 0);
      expect(tl.flight(500), 0);
      expect(tl.flight(tl.endMs.toDouble()), closeTo(1, 0.01));
    });

    test('reduced motion: a still frame for 0.8 s, then a 120 ms fade', () {
      final tl = LaunchIntroTimeline(full, reduce: true);
      expect(tl.arc(2, 0), 1);
      expect(tl.namesOpacity(0), 1);
      expect(tl.lift(0), 1);
      expect(tl.overlayOpacity(790), 1);
      expect(tl.overlayOpacity(860), closeTo(0.5, 0.01));
      expect(tl.overlayOpacity(920), 0);
      expect(tl.flight(900), 0);
    });

    test('a tap skips: gone about 170 ms later', () {
      final tl = LaunchIntroTimeline(full);
      expect(tl.skipEndMs(1000), 1170);
      expect(tl.skipOpacity(1000, 1000), 1);
      expect(tl.skipOpacity(1000, 1170), lessThan(0.02));
    });
  });
}

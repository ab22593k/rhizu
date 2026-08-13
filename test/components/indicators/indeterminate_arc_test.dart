import 'dart:math' as math;

import 'package:flutter/animation.dart' show Curves;
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/ui/components/indicators/animation/indeterminate_arc_motion.dart';

void main() {
  group('IndeterminateArcMotion', () {
    test('sweep is at minimum near cycle start', () {
      final (_, sweep) = IndeterminateArcMotion.compute(0.0);

      // Sweep at the start should be near the minimum (~15° = π/12)
      expect(sweep, closeTo(IndeterminateArcMotion.minSweep, 0.01));
    });

    test('sweep reaches maximum near mid-cycle', () {
      final (_, sweep) = IndeterminateArcMotion.compute(0.5);

      // At mid-cycle the head has fully expanded and the tail hasn't moved yet
      // Sweep should be near maximum (~270° = 3π/2)
      expect(sweep, greaterThan(math.pi)); // > 180°
      expect(sweep, closeTo(IndeterminateArcMotion.maxSweep, 0.1));
    });

    test('sweep returns to minimum near cycle end', () {
      final (_, sweep) = IndeterminateArcMotion.compute(0.99);

      // Near the end of the cycle, the tail has caught up to the head
      expect(sweep, lessThan(math.pi / 3)); // < 60°
    });

    test('head expands with the M3 standard easing curve (fastOutSlowIn)', () {
      // In the first half, the head advances with the M3 standard easing
      // curve (`md.sys.motion.easing-standard`, i.e. fastOutSlowIn) while
      // the tail stays stationary. Both curves are the reference
      // implementation's curves for the indeterminate arc.
      final (_, sweepAt0) = IndeterminateArcMotion.compute(0.0);
      final (_, sweepAt10) = IndeterminateArcMotion.compute(0.1);
      final (_, sweepAt50) = IndeterminateArcMotion.compute(0.5);
      final (_, sweepAt60) = IndeterminateArcMotion.compute(0.6);

      // Growth rate in first 10% of expansion, driven by the head curve.
      final growthRate = sweepAt10 - sweepAt0;
      // Shrink rate in first 10% of contraction, driven by the tail curve.
      final shrinkRate = sweepAt50 - sweepAt60;

      // Both endpoints use the same standard easing curve, so the growth
      // rate in the first half equals the shrink rate in the second half.
      // This is the reference behavior: the sweep is asymmetric in *time*
      // (head leads, tail catches up) but not in easing.
      final expected =
          Curves.fastOutSlowIn.transform(0.2) *
          (IndeterminateArcMotion.maxSweep - IndeterminateArcMotion.minSweep);
      expect(growthRate, closeTo(expected, 0.001));
      expect(shrinkRate, closeTo(expected, 0.001));
    });

    test('duration constants match the M3 motion reference', () {
      // md.comp.progress-indicator.circular.indeterminate: the arc length
      // completes one cycle every 1333ms and the indicator rotates 360°
      // every 2222ms. The combined LCM keeps both integer-aligned.
      expect(
        IndeterminateArcMotion.arcCycleDuration,
        const Duration(milliseconds: 1333),
      );
      expect(
        IndeterminateArcMotion.rotationCycleDuration,
        const Duration(milliseconds: 2222),
      );
      expect(
        IndeterminateArcMotion.combinedCycleDuration,
        const Duration(milliseconds: 1333 * 2222),
      );
    });

    test('start angle shifts as tail advances in second half', () {
      final (startAt0, _) = IndeterminateArcMotion.compute(0.0);
      final (startAtMid, _) = IndeterminateArcMotion.compute(0.5);
      final (startAtEnd, _) = IndeterminateArcMotion.compute(0.99);

      // In the first half (0→0.5), the tail stays put, so start angle
      // should be roughly the same
      expect(startAt0, closeTo(startAtMid, 0.1));

      // In the second half (0.5→1.0), the tail advances, so the start
      // angle should shift forward significantly
      expect((startAtEnd - startAtMid).abs(), greaterThan(math.pi / 4));
    });

    test('sweep is always positive', () {
      for (var t = 0.0; t <= 1.0; t += 0.01) {
        final (_, sweep) = IndeterminateArcMotion.compute(t);
        expect(sweep, greaterThan(0), reason: 'sweep must be positive at t=$t');
      }
    });

    test('minSweep constant matches M3 spec (~15 degrees)', () {
      // M3 specifies minimum stroke angle of approximately 15°
      const degrees15 = 15 * math.pi / 180;
      expect(
        IndeterminateArcMotion.minSweep,
        closeTo(degrees15, 1 * math.pi / 180), // ±1°
      );
    });

    test('maxSweep constant matches M3 spec (~270 degrees)', () {
      // M3 specifies maximum stroke angle of approximately 270°
      const degrees270 = 270 * math.pi / 180;
      expect(
        IndeterminateArcMotion.maxSweep,
        closeTo(degrees270, 5 * math.pi / 180), // ±5°
      );
    });
  });
}

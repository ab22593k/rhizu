import 'dart:math' as math;

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

    test('head expands faster than tail contracts (asymmetric easing)', () {
      // In the first half, the head uses ease-out (fast start, slow end).
      // In the second half, the tail uses ease-in (slow start, fast end).
      //
      // So the sweep should grow rapidly near t=0 → 0.1 (head ease-out)
      // but shrink slowly near t=0.5 → 0.6 (tail ease-in).
      final (_, sweepAt0) = IndeterminateArcMotion.compute(0.0);
      final (_, sweepAt10) = IndeterminateArcMotion.compute(0.1);
      final (_, sweepAt50) = IndeterminateArcMotion.compute(0.5);
      final (_, sweepAt60) = IndeterminateArcMotion.compute(0.6);

      // Growth rate in first 10% of expansion
      final growthRate = sweepAt10 - sweepAt0;
      // Shrink rate in first 10% of contraction
      final shrinkRate = sweepAt50 - sweepAt60;

      // Head expands faster (ease-out) than tail contracts (ease-in)
      expect(growthRate, greaterThan(shrinkRate));
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

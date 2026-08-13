import 'dart:math' as math;

import 'package:flutter/animation.dart' show Cubic, Interval;
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/ui/components/indicators/animation/linear_indeterminate_motion.dart';

void main() {
  group('LinearIndeterminateMotion', () {
    test('cycle duration matches the M3 reference (2000ms)', () {
      expect(
        LinearIndeterminateMotion.cycleDuration,
        const Duration(milliseconds: 2000),
      );
    });

    test('both lines collapse at the cycle start (t = 0)', () {
      final (line1Start, line1End, line2Start, line2End) =
          LinearIndeterminateMotion.compute(0.0);
      expect(line1Start, closeTo(0.0, 1e-9));
      expect(line1End, closeTo(0.0, 1e-9));
      expect(line2Start, closeTo(0.0, 1e-9));
      expect(line2End, closeTo(0.0, 1e-9));
    });

    test('line 1 leads a growing segment in the first quarter', () {
      // line1Head is active from 0 → 750/2000 of the cycle; line1Tail joins
      // from 333/2000. At t = 0.25 the head has swept well past the tail.
      final (line1Start, line1End, line2Start, line2End) =
          LinearIndeterminateMotion.compute(0.25);
      expect(line1End, greaterThan(line1Start));
      expect(line1Start, greaterThan(0.0)); // tail has started chasing
      expect(line2Start, closeTo(0.0, 1e-9)); // line 2 not started yet
      expect(line2End, closeTo(0.0, 1e-9));
    });

    test('line 1 head completes its sweep before mid-cycle', () {
      // line1Head interval ends at 750/2000 = 0.375 → head reaches the end.
      final (_, line1End, _, _) = LinearIndeterminateMotion.compute(0.375);
      expect(line1End, closeTo(1.0, 1e-9));
    });

    test('line 2 starts before line 1 fully collapses (no empty track)', () {
      // At t = 0.52, line 1's tail is nearly caught up while line 2's head
      // has begun sweeping, so at least one segment is always visible.
      final (line1Start, line1End, line2Start, line2End) =
          LinearIndeterminateMotion.compute(0.52);
      expect(line1End, closeTo(1.0, 1e-9));
      expect(line2End, greaterThan(line2Start));
    });

    test('line 2 completes the cycle at the reference times', () {
      // line2Head ends at 1567/2000; line2Tail ends at 1800/2000.
      final (_, _, line2StartAt9, line2EndAt9) =
          LinearIndeterminateMotion.compute(0.9);
      expect(line2EndAt9, closeTo(1.0, 1e-9));
      expect(line2StartAt9, closeTo(1.0, 1e-9)); // tail caught the head
    });

    test('endpoints always stay within the track bounds', () {
      for (var t = 0.0; t <= 1.0; t += 0.01) {
        final (line1Start, line1End, line2Start, line2End) =
            LinearIndeterminateMotion.compute(t);
        for (final v in [line1Start, line1End, line2Start, line2End]) {
          expect(v, inInclusiveRange(0.0, 1.0), reason: 'at t=$t');
        }
      }
    });

    test('static phase renders a visible active segment (reduced motion)', () {
      // 25% of the cycle → line 1 head ~0.66, tail ~0.12.
      const t = LinearIndeterminateMotion.staticPhase / (2 * math.pi);
      final (line1Start, line1End, _, _) = LinearIndeterminateMotion.compute(t);
      expect(line1End, greaterThan(line1Start));
      expect(line1End, lessThan(1.0));
      expect(line1Start, greaterThan(0.0));
    });

    test('curves match the reference interval/cubic definitions', () {
      // The constants mirror the reference implementation's exact curves.
      const head = Interval(0.0, 0.375, curve: Cubic(0.2, 0.0, 0.8, 1.0));
      const tail = Interval(
        333.0 / 2000.0,
        (333.0 + 750.0) / 2000.0,
        curve: Cubic(0.4, 0.0, 1.0, 1.0),
      );
      expect(
        LinearIndeterminateMotion.line1Head.transform(0.2),
        closeTo(head.transform(0.2), 1e-9),
      );
      expect(
        LinearIndeterminateMotion.line1Tail.transform(0.3),
        closeTo(tail.transform(0.3), 1e-9),
      );
    });
  });
}

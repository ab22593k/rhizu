import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/ui/components/indicators/animation/indeterminate_arc_motion.dart';
import 'package:rhizu/src/ui/components/indicators/painter/circular_arc.dart';

void main() {
  group('CircularArc', () {
    group('determinate', () {
      test('starts at the top and sweeps with progress', () {
        final arc = CircularArc.forProgress(
          value: 0.25,
          rotation: 0,
          baseSpin: 0,
        );
        expect(arc.start, -math.pi / 2);
        expect(arc.sweep, closeTo(math.pi / 2, 1e-9));
        expect(arc.end, closeTo(0, 1e-9));
      });

      test('adds the rotation offset', () {
        final arc = CircularArc.forProgress(
          value: 0.5,
          rotation: 0.4,
          baseSpin: 1,
        );
        expect(arc.start, closeTo(-math.pi / 2 + 0.4, 1e-9));
        expect(arc.sweep, closeTo(math.pi, 1e-9));
      });

      test('clamps progress to the 0..1 range', () {
        expect(
          CircularArc.forProgress(
            value: 1.5,
            rotation: 0,
            baseSpin: 0,
          ).sweep,
          closeTo(math.pi * 2, 1e-9),
        );
        expect(
          CircularArc.forProgress(
            value: -0.5,
            rotation: 0,
            baseSpin: 0,
          ).sweep,
          0,
        );
      });

      test('reports a full circle at completion', () {
        expect(
          CircularArc.forProgress(
            value: 1,
            rotation: 0,
            baseSpin: 0,
          ).isFullCircle,
          isTrue,
        );
        expect(
          CircularArc.forProgress(
            value: 0.5,
            rotation: 0,
            baseSpin: 0,
          ).isFullCircle,
          isFalse,
        );
      });
    });

    group('indeterminate', () {
      test('uses the shared indeterminate arc motion', () {
        final (start, sweep) = IndeterminateArcMotion.compute(0.7);
        final arc = CircularArc.forProgress(
          value: null,
          rotation: 0.7,
          baseSpin: 0,
        );
        expect(arc.start, start);
        expect(arc.sweep, sweep);
      });

      test('adds the base spin offset', () {
        final (start, sweep) = IndeterminateArcMotion.compute(0.7);
        final arc = CircularArc.forProgress(
          value: null,
          rotation: 0.7,
          baseSpin: 1.2,
        );
        expect(arc.start, closeTo(start + 1.2, 1e-9));
        expect(arc.sweep, sweep);
      });
    });

    group('gap geometry', () {
      test('gap angle is stroke plus gap over radius', () {
        const arc = CircularArc(start: 0, sweep: 1);
        expect(
          arc.gapAngle(stroke: 4, gap: 4, radius: 20),
          closeTo(0.4, 1e-9),
        );
      });

      test('track sweep removes both gaps from the remaining arc', () {
        const arc = CircularArc(start: 0, sweep: math.pi);
        expect(
          arc.trackSweep(0.1),
          closeTo(math.pi - 0.2, 1e-9),
        );
      });

      test('track sweep wraps around the circle', () {
        const arc = CircularArc(start: math.pi, sweep: math.pi);
        expect(
          arc.trackSweep(0),
          closeTo(math.pi, 1e-9),
        );
      });

      test('a tiny active sweep leaves almost the whole track', () {
        const arc = CircularArc(start: 0, sweep: 0.1);
        expect(
          arc.trackSweep(0.2),
          closeTo(math.pi * 2 - 0.5, 1e-9),
        );
      });
    });
  });
}

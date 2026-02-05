import 'dart:math';
import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/rhizu.dart';

void main() {
  group('MotionTokens (Springs)', () {
    // Helper to calculate expected damping
    double calculateDamping(double ratio, double stiffness) {
      return ratio * 2 * sqrt(1.0 * stiffness);
    }

    test('Expressive Fast Spatial', () {
      final spring = MotionTokens.expressiveFastSpatial;
      expect(spring.mass, 1.0);
      expect(spring.stiffness, 1400.0);
      expect(spring.damping, closeTo(calculateDamping(0.9, 1400.0), 0.0001));
    });

    test('Expressive Fast Effects', () {
      final spring = MotionTokens.expressiveFastEffects;
      expect(spring.mass, 1.0);
      expect(spring.stiffness, 3800.0);
      expect(spring.damping, closeTo(calculateDamping(1.0, 3800.0), 0.0001));
    });

    test('Expressive Default Spatial', () {
      final spring = MotionTokens.expressiveDefaultSpatial;
      expect(spring.mass, 1.0);
      expect(spring.stiffness, 700.0);
      expect(spring.damping, closeTo(calculateDamping(0.9, 700.0), 0.0001));
    });

    test('Expressive Default Effects', () {
      final spring = MotionTokens.expressiveDefaultEffects;
      expect(spring.mass, 1.0);
      expect(spring.stiffness, 1600.0);
      expect(spring.damping, closeTo(calculateDamping(1.0, 1600.0), 0.0001));
    });

    test('Expressive Slow Spatial', () {
      final spring = MotionTokens.expressiveSlowSpatial;
      expect(spring.mass, 1.0);
      expect(spring.stiffness, 300.0);
      expect(spring.damping, closeTo(calculateDamping(0.9, 300.0), 0.0001));
    });

    test('Expressive Slow Effects', () {
      final spring = MotionTokens.expressiveSlowEffects;
      expect(spring.mass, 1.0);
      expect(spring.stiffness, 800.0);
      expect(spring.damping, closeTo(calculateDamping(1.0, 800.0), 0.0001));
    });
  });

  group('MotionFallbacks (Cubic & Duration)', () {
    // Helper to check Cubic string representation
    void expectCubic(Cubic curve, String expected) {
      expect(curve.toString(), contains(expected));
    }

    test('Expressive Fast Spatial', () {
      expectCubic(
        MotionFallbacks.expressiveFastSpatial,
        'Cubic(0.42, 1.67, 0.21, 0.9',
      );
      expect(
        MotionFallbacks.expressiveFastSpatialDuration,
        const Duration(milliseconds: 350),
      );
    });

    test('Expressive Default Spatial', () {
      expectCubic(
        MotionFallbacks.expressiveDefaultSpatial,
        'Cubic(0.38, 1.21, 0.22, 1.0',
      );
      expect(
        MotionFallbacks.expressiveDefaultSpatialDuration,
        const Duration(milliseconds: 500),
      );
    });

    test('Expressive Slow Spatial', () {
      expectCubic(
        MotionFallbacks.expressiveSlowSpatial,
        'Cubic(0.39, 1.29, 0.35, 0.98',
      );
      expect(
        MotionFallbacks.expressiveSlowSpatialDuration,
        const Duration(milliseconds: 650),
      );
    });

    test('Expressive Fast Effects', () {
      expectCubic(
        MotionFallbacks.expressiveFastEffects,
        'Cubic(0.31, 0.94, 0.34, 1.0',
      );
      expect(
        MotionFallbacks.expressiveFastEffectsDuration,
        const Duration(milliseconds: 150),
      );
    });

    test('Expressive Default Effects', () {
      // Corrected expectation based on actual output 'Cubic(0.34, 0.80, 0.34, 1.00)'
      expectCubic(
        MotionFallbacks.expressiveDefaultEffects,
        'Cubic(0.34, 0.80, 0.34, 1.00)',
      );
      expect(
        MotionFallbacks.expressiveDefaultEffectsDuration,
        const Duration(milliseconds: 200),
      );
    });

    test('Expressive Slow Effects', () {
      expectCubic(
        MotionFallbacks.expressiveSlowEffects,
        'Cubic(0.34, 0.88, 0.34, 1.0',
      );
      expect(
        MotionFallbacks.expressiveSlowEffectsDuration,
        const Duration(milliseconds: 300),
      );
    });

    test('Standard Fast Spatial', () {
      expectCubic(
        MotionFallbacks.standardFastSpatial,
        'Cubic(0.27, 1.06, 0.18, 1.0',
      );
      expect(
        MotionFallbacks.standardFastSpatialDuration,
        const Duration(milliseconds: 350),
      );
    });

    test('Standard Default Spatial', () {
      expectCubic(
        MotionFallbacks.standardDefaultSpatial,
        'Cubic(0.27, 1.06, 0.18, 1.0',
      );
      expect(
        MotionFallbacks.standardDefaultSpatialDuration,
        const Duration(milliseconds: 500),
      );
    });

    test('Standard Slow Spatial', () {
      expectCubic(
        MotionFallbacks.standardSlowSpatial,
        'Cubic(0.27, 1.06, 0.18, 1.0',
      );
      expect(
        MotionFallbacks.standardSlowSpatialDuration,
        const Duration(milliseconds: 750),
      );
    });

    test('Standard Fast Effects', () {
      expectCubic(
        MotionFallbacks.standardFastEffects,
        'Cubic(0.31, 0.94, 0.34, 1.0',
      );
      expect(
        MotionFallbacks.standardFastEffectsDuration,
        const Duration(milliseconds: 150),
      );
    });

    test('Standard Default Effects', () {
      // Corrected expectation based on actual output 'Cubic(0.34, 0.80, 0.34, 1.00)'
      expectCubic(
        MotionFallbacks.standardDefaultEffects,
        'Cubic(0.34, 0.80, 0.34, 1.00)',
      );
      expect(
        MotionFallbacks.standardDefaultEffectsDuration,
        const Duration(milliseconds: 200),
      );
    });

    test('Standard Slow Effects', () {
      expectCubic(
        MotionFallbacks.standardSlowEffects,
        'Cubic(0.34, 0.88, 0.34, 1.0',
      );
      expect(
        MotionFallbacks.standardSlowEffectsDuration,
        const Duration(milliseconds: 300),
      );
    });
  });
}

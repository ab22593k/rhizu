import 'package:flutter/animation.dart';

/// Material 3 Motion Physics Web Fallbacks (Cubic Bezier Curves).
///
/// These curves mimic the spring behavior for platforms/contexts where physics
/// simulations are not feasible.
///
/// See: https://m3.material.io/styles/motion/overview/specs
class MotionFallbacks {
  const MotionFallbacks._();

  /// Expressive Fast Spatial (350ms)
  static const Cubic expressiveFastSpatial = Cubic(0.42, 1.67, 0.21, 0.90);
  static const Duration expressiveFastSpatialDuration = Duration(
    milliseconds: 350,
  );

  /// Expressive Default Spatial (500ms)
  static const Cubic expressiveDefaultSpatial = Cubic(0.38, 1.21, 0.22, 1.00);
  static const Duration expressiveDefaultSpatialDuration = Duration(
    milliseconds: 500,
  );

  /// Expressive Slow Spatial (650ms)
  static const Cubic expressiveSlowSpatial = Cubic(0.39, 1.29, 0.35, 0.98);
  static const Duration expressiveSlowSpatialDuration = Duration(
    milliseconds: 650,
  );

  /// Expressive Fast Effects (150ms)
  static const Cubic expressiveFastEffects = Cubic(0.31, 0.94, 0.34, 1.00);
  static const Duration expressiveFastEffectsDuration = Duration(
    milliseconds: 150,
  );

  /// Expressive Default Effects (200ms)
  static const Cubic expressiveDefaultEffects = Cubic(0.34, 0.80, 0.34, 1.00);
  static const Duration expressiveDefaultEffectsDuration = Duration(
    milliseconds: 200,
  );

  /// Expressive Slow Effects (300ms)
  static const Cubic expressiveSlowEffects = Cubic(0.34, 0.88, 0.34, 1.00);
  static const Duration expressiveSlowEffectsDuration = Duration(
    milliseconds: 300,
  );

  /// Standard Fast Spatial (350ms)
  static const Cubic standardFastSpatial = Cubic(0.27, 1.06, 0.18, 1.00);
  static const Duration standardFastSpatialDuration = Duration(
    milliseconds: 350,
  );

  /// Standard Default Spatial (500ms)
  static const Cubic standardDefaultSpatial = Cubic(0.27, 1.06, 0.18, 1.00);
  static const Duration standardDefaultSpatialDuration = Duration(
    milliseconds: 500,
  );

  /// Standard Slow Spatial (750ms)
  static const Cubic standardSlowSpatial = Cubic(0.27, 1.06, 0.18, 1.00);
  static const Duration standardSlowSpatialDuration = Duration(
    milliseconds: 750,
  );

  /// Standard Fast Effects (150ms)
  static const Cubic standardFastEffects = Cubic(0.31, 0.94, 0.34, 1.00);
  static const Duration standardFastEffectsDuration = Duration(
    milliseconds: 150,
  );

  /// Standard Default Effects (200ms)
  static const Cubic standardDefaultEffects = Cubic(0.34, 0.80, 0.34, 1.00);
  static const Duration standardDefaultEffectsDuration = Duration(
    milliseconds: 200,
  );

  /// Standard Slow Effects (300ms)
  static const Cubic standardSlowEffects = Cubic(0.34, 0.88, 0.34, 1.00);
  static const Duration standardSlowEffectsDuration = Duration(
    milliseconds: 300,
  );
}

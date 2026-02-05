import 'dart:math';
import 'package:flutter/physics.dart';

/// Material 3 Motion Physics Spring Tokens.
///
/// See: https://m3.material.io/styles/motion/overview/specs
class MotionTokens {
  const MotionTokens._();

  /// Helper to calculate absolute damping from damping ratio.
  /// Assumes mass = 1.0.
  static double _damping(double dampingRatio, double stiffness) {
    return dampingRatio * 2 * sqrt(stiffness);
  }

  // --- Expressive Motion Scheme (Default) ---

  /// Expressive Fast Spatial
  /// Damping Ratio: 0.9, Stiffness: 1400
  static final SpringDescription expressiveFastSpatial = SpringDescription(
    mass: 1.0,
    stiffness: 1400.0,
    damping: _damping(0.9, 1400.0),
  );

  /// Expressive Fast Effects
  /// Damping Ratio: 1.0, Stiffness: 3800
  static final SpringDescription expressiveFastEffects = SpringDescription(
    mass: 1.0,
    stiffness: 3800.0,
    damping: _damping(1.0, 3800.0),
  );

  /// Expressive Default Spatial
  /// Damping Ratio: 0.9, Stiffness: 700
  static final SpringDescription expressiveDefaultSpatial = SpringDescription(
    mass: 1.0,
    stiffness: 700.0,
    damping: _damping(0.9, 700.0),
  );

  /// Expressive Default Effects
  /// Damping Ratio: 1.0, Stiffness: 1600
  static final SpringDescription expressiveDefaultEffects = SpringDescription(
    mass: 1.0,
    stiffness: 1600.0,
    damping: _damping(1.0, 1600.0),
  );

  /// Expressive Slow Spatial
  /// Damping Ratio: 0.9, Stiffness: 300
  static final SpringDescription expressiveSlowSpatial = SpringDescription(
    mass: 1.0,
    stiffness: 300.0,
    damping: _damping(0.9, 300.0),
  );

  /// Expressive Slow Effects
  /// Damping Ratio: 1.0, Stiffness: 800
  static final SpringDescription expressiveSlowEffects = SpringDescription(
    mass: 1.0,
    stiffness: 800.0,
    damping: _damping(1.0, 800.0),
  );
}

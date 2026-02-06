/// Material 3 Motion Physics with Flutter Animate.
///
/// This package provides [SpringDescription] tokens and examples matching
/// the Material 3 Expressive Motion specifications, now powered by `flutter_animate`.
library;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// A Curve that runs a [SpringSimulation].
///
/// This allows using physics-based springs within timeline-based animation
/// frameworks like `flutter_animate`.
///
/// The curve maps t=0..1 to the simulation position.
/// Note: You must ensure the animation duration is long enough for the
/// spring to settle, otherwise the animation will clip.
class SpringCurve extends Curve {

  SpringCurve(this.description)
    : estimatedDuration = _estimateDuration(description);
  final SpringDescription description;
  final double estimatedDuration;

  static double _estimateDuration(SpringDescription desc) {
    // Rough estimate of settling time.
    // In a real system we might solve for amplitude < epsilon.
    // For M3 springs, 2-3 seconds is usually safe for the tail.
    return 2;
  }

  @override
  double transformInternal(double t) {
    // Map normalized time 't' (0..1) to actual seconds
    final time = t * estimatedDuration;

    final simulation = SpringSimulation(description, 0, 1, 0);

    // If t is 1.0, force final position to avoid floating point errors
    if (t >= 1.0) return 1;

    return simulation.x(time);
  }
}

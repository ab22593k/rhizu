import 'package:flutter/animation.dart';
import 'package:flutter/physics.dart';

/// A spring-based animation curve for expressive loading indicator animations.
///
/// This curve uses a physics-based spring simulation to create a natural,
/// bouncy animation feel that matches the design specifications:
/// - Stiffness: 200
/// - Damping: 0.6 (normalized to 15 for Flutter's SpringSimulation)
///
/// The curve transforms linear progress [0, 1] into spring-based motion,
/// creating an "expressive" feel where the animation overshoots and settles.
class SpringCurve extends Curve {
  /// Creates a SpringCurve with the default spring parameters.
  ///
  /// The default configuration matches the design specification:
  /// - Mass: 1.0
  /// - Stiffness: 200
  /// - Damping: 15 (normalized from 0.6)
  const SpringCurve();

  @override
  double transformInternal(double t) {
    // Standard critically damped spring approximation
    // The spring description is tuned to match the design spec
    final simulation = SpringSimulation(
      const SpringDescription(
        mass: 1,
        stiffness: 200,
        damping: 15, // Normalized from damping ratio 0.6
      ),
      0, // Start position
      1, // End position
      0, // Initial velocity
    );

    // Combine the spring simulation with linear progression
    // This creates a spring effect that doesn't overshoot too much
    return simulation.x(t * 0.650) + t * (1 - simulation.x(0.650));
  }
}

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
///
/// Optimized with a pre-computed lookup table for O(1) evaluation,
/// avoiding expensive physics simulation on every frame.
class SpringCurve extends Curve {
  /// Creates a SpringCurve with the default spring parameters.
  ///
  /// The default configuration matches the design specification:
  /// - Mass: 1.0
  /// - Stiffness: 200
  /// - Damping: 15 (normalized from 0.6)
  const SpringCurve();

  /// Number of samples in the lookup table.
  /// Higher values provide smoother interpolation at the cost of memory.
  static const int _lookupTableSize = 100;

  /// Pre-computed lookup table for spring values.
  /// Computed once on first access to avoid static initialization overhead.
  static final List<double> _lookupTable = _computeLookupTable();

  /// Computes the lookup table values using the spring simulation.
  static List<double> _computeLookupTable() {
    const springTime = 0.650;
    final simulation = SpringSimulation(
      const SpringDescription(
        mass: 1,
        stiffness: 200,
        damping: 15,
      ),
      0,
      1,
      0,
    );

    return List.generate(_lookupTableSize, (i) {
      final t = i / (_lookupTableSize - 1);
      return simulation.x(t * springTime) + t * (1 - simulation.x(springTime));
    });
  }

  @override
  double transformInternal(double t) {
    // Use lookup table for O(1) evaluation instead of physics simulation
    final index = (t * (_lookupTableSize - 1)).round().clamp(
      0,
      _lookupTableSize - 1,
    );
    return _lookupTable[index];
  }
}

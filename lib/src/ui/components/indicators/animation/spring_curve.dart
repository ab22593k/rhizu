import 'package:flutter/animation.dart';
import 'package:flutter/physics.dart';
import 'package:rhizu/src/ui/styles/motion/tokens.dart';

/// A spring-based animation curve for expressive loading indicator animations.
///
/// This curve uses a physics-based spring simulation to create a natural,
/// bouncy animation feel. The spring parameters are taken from the Material
/// Expressive motion tokens ([MotionTokens]) so that indicator motion stays
/// consistent with the rest of the design system.
///
/// The curve transforms linear progress [0, 1] into spring-based motion,
/// creating an "expressive" feel where the animation overshoots and settles.
///
/// Optimized with a pre-computed lookup table for O(1) evaluation,
/// avoiding expensive physics simulation on every frame. The table is cached
/// per [SpringDescription] so custom springs remain allocation-free per frame.
class SpringCurve extends Curve {
  /// Creates a SpringCurve driven by the given [description].
  ///
  /// The default configuration uses the Material Expressive "slow spatial"
  /// spring token (`md.sys.motion.spring.expressive-slow-spatial`).
  SpringCurve({
    SpringDescription? description,
  }) : description = description ?? MotionTokens.expressiveSlowSpatial;

  /// The spring simulation parameters driving this curve.
  final SpringDescription description;

  /// Number of samples in the lookup table.
  /// Higher values provide smoother interpolation at the cost of memory.
  static const int _lookupTableSize = 100;

  /// Cached lookup tables keyed by spring description, so per-frame
  /// evaluation stays O(1) and allocation-free.
  static final Map<SpringDescription, List<double>> _tableCache = {};

  /// Computes the lookup table values using the spring simulation.
  static List<double> _computeLookupTable(SpringDescription description) {
    const springTime = 0.650;
    final simulation = SpringSimulation(description, 0, 1, 0);

    return List.generate(_lookupTableSize, (i) {
      final t = i / (_lookupTableSize - 1);
      return simulation.x(t * springTime) + t * (1 - simulation.x(springTime));
    });
  }

  /// Returns (and lazily builds) the lookup table for [description].
  static List<double> _tableFor(SpringDescription description) {
    return _tableCache.putIfAbsent(
      description,
      () => _computeLookupTable(description),
    );
  }

  @override
  double transformInternal(double t) {
    // Use lookup table for O(1) evaluation instead of physics simulation
    final table = _tableFor(description);
    final index = (t * (_lookupTableSize - 1)).round().clamp(
      0,
      _lookupTableSize - 1,
    );
    return table[index];
  }
}

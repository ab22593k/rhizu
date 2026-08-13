import 'dart:math' as math;

import 'package:flutter/animation.dart';

/// Computes M3-spec indeterminate linear indicator segment positions.
///
/// The M3 linear indeterminate indicator animates two active segments (lines)
/// that grow and shrink along the track repeatedly. Line 1 leads, sweeping
/// from the left edge; line 2 follows half a cycle later so the track never
/// sits empty while the animation wraps.
///
/// Endpoint curves mirror the reference implementation
/// (`LinearProgressIndicator` in Flutter), one cycle being 2000ms:
///
/// | Curve      | Interval        | Easing cubic                |
/// |------------|-----------------|-----------------------------|
/// | Line 1 head| 0 → 750ms       | `Cubic(0.2, 0.0, 0.8, 1.0)` |
/// | Line 1 tail| 333 → 1083ms    | `Cubic(0.4, 0.0, 1.0, 1.0)` |
/// | Line 2 head| 1000 → 1567ms   | `Cubic(0.0, 0.0, 0.65, 1.0)`|
/// | Line 2 tail| 1267 → 1800ms   | `Cubic(0.1, 0.0, 0.45, 1.0)` |
///
/// Segments whose `end <= start` are collapsed and should not be painted.
class LinearIndeterminateMotion {
  LinearIndeterminateMotion._();

  /// Duration of one full indeterminate cycle.
  ///
  /// Reference: `md.comp.progress-indicator.linear` indeterminate motion —
  /// one cycle completes every 2000ms.
  static const Duration cycleDuration = Duration(milliseconds: 2000);

  /// Phase (radians) that renders a representative active segment when
  /// animations are disabled (reduced motion).
  ///
  /// Maps to 25% of the cycle, where line 1 is clearly visible sweeping
  /// across the track.
  static const double staticPhase = 0.25 * 2 * math.pi;

  /// Line 1 head endpoint curve (leads the first sweep).
  static const Curve line1Head = Interval(
    0.0,
    750.0 / 2000.0,
    curve: Cubic(0.2, 0.0, 0.8, 1.0),
  );

  /// Line 1 tail endpoint curve (chases the head).
  static const Curve line1Tail = Interval(
    333.0 / 2000.0,
    (333.0 + 750.0) / 2000.0,
    curve: Cubic(0.4, 0.0, 1.0, 1.0),
  );

  /// Line 2 head endpoint curve (leads the second sweep).
  static const Curve line2Head = Interval(
    1000.0 / 2000.0,
    (1000.0 + 567.0) / 2000.0,
    curve: Cubic(0.0, 0.0, 0.65, 1.0),
  );

  /// Line 2 tail endpoint curve (chases line 2's head).
  static const Curve line2Tail = Interval(
    1267.0 / 2000.0,
    (1267.0 + 533.0) / 2000.0,
    curve: Cubic(0.10, 0.0, 0.45, 1.0),
  );

  /// Computes `(line1Start, line1End, line2Start, line2End)` for a normalized
  /// cycle progress (0.0 – 1.0).
  ///
  /// All four values are fractions of the track width. A segment with
  /// `end <= start` is collapsed and must not be painted.
  static (double, double, double, double) compute(double t) {
    final line1Start = line1Tail.transform(t);
    final line1End = line1Head.transform(t);
    final line2Start = line2Tail.transform(t);
    final line2End = line2Head.transform(t);
    return (line1Start, line1End, line2Start, line2End);
  }
}

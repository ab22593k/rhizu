import 'dart:math' as math;

import 'package:flutter/animation.dart';

/// Computes M3-spec indeterminate circular arc positions using two-arc
/// asymmetric motion.
///
/// The M3 circular indeterminate indicator animates in cycles:
///
/// **First half (0 → 0.5):** The *head* of the arc expands with ease-out
/// (fast start, slow finish) while the *tail* stays stationary. The arc
/// grows from [minSweep] toward [maxSweep].
///
/// **Second half (0.5 → 1.0):** The *head* holds its position while the
/// *tail* catches up with ease-in (slow start, fast finish). The arc
/// contracts from [maxSweep] back to [minSweep].
///
/// This asymmetry creates the characteristic "stretch and snap" feel of the
/// Material Design circular spinner, as opposed to a symmetric sine-based
/// oscillation.
class IndeterminateArcMotion {
  IndeterminateArcMotion._();

  /// Minimum arc sweep in radians (~15°).
  ///
  /// M3 spec: the arc never shrinks below approximately 15 degrees.
  static const double minSweep = 15 * math.pi / 180;

  /// Maximum arc sweep in radians (~270°).
  ///
  /// M3 spec: the arc expands to approximately 270 degrees at peak.
  static const double maxSweep = 270 * math.pi / 180;

  /// Full sweep range between min and max.
  static const double _sweepRange = maxSweep - minSweep;

  /// Computes (startAngle, sweepAngle) for a given normalized cycle
  /// progress (0.0 – 1.0).
  ///
  /// Both angles are in radians. The `startAngle` begins at the top of the
  /// circle (−π/2) and shifts forward as the tail advances.
  ///
  /// The caller should add any base rotation offset to `startAngle` to
  /// cycle counts.
  static (double startAngle, double sweepAngle) compute(double cycles) {
    final cycleCount = cycles.floor();
    final cycleT = cycles - cycleCount;

    // --- Head and Tail offsets (Asymmetric motion) ---
    // First half (0→0.5): head expands rapidly (ease-out), tail stationary.
    // Second half (0.5→1.0): head holds, tail catches up rapidly (ease-in).
    final (headRaw, tailRaw) = switch (cycleT) {
      < 0.5 => (cycleT * 2.0, 0.0),
      _ => (1.0, (cycleT - 0.5) * 2.0),
    };

    final headT = Curves.easeOut.transform(headRaw);
    final tailT = Curves.easeIn.transform(tailRaw);

    // Compute head and tail angular offsets from the cycle start.
    final headAngle = headT * _sweepRange;
    final tailAngle = tailT * _sweepRange;

    // Sweep is the difference + minimum guaranteed arc.
    final sweep = minSweep + headAngle - tailAngle;

    // Add accumulated offset from previous full cycles so the animation never snaps.
    // Each cycle spins the start angle forward exactly by _sweepRange.
    final baseOffset = cycleCount * _sweepRange;

    // Start angle: begins at top (−π/2), advances as the tail moves.
    final startAngle = -math.pi / 2 + baseOffset + tailAngle;

    return (startAngle, sweep);
  }
}

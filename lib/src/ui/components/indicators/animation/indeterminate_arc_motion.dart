import 'dart:math' as math;

import 'package:flutter/animation.dart';

/// Computes M3-spec indeterminate circular arc positions using two-arc
/// asymmetric motion.
///
/// The M3 circular indeterminate indicator animates in cycles:
///
/// **First half (0 → 0.5):** The *head* of the arc expands with the M3
/// standard easing curve ([Curves.fastOutSlowIn]) while the *tail* stays
/// stationary. The arc grows from [minSweep] toward [maxSweep].
///
/// **Second half (0.5 → 1.0):** The *head* holds its position while the
/// *tail* catches up with the same standard easing curve. The arc contracts
/// from [maxSweep] back to [minSweep].
///
/// Both endpoints share the M3 standard easing curve
/// (`md.sys.motion.easing-standard`, the same `fastOutSlowIn` curve used by
/// the reference implementation), which creates the characteristic "stretch
/// and snap" feel of the Material Design circular spinner as opposed to a
/// symmetric sine-based oscillation.
class IndeterminateArcMotion {
  IndeterminateArcMotion._();

  /// Duration of one arc grow/shrink cycle.
  ///
  /// Reference: `md.comp.progress-indicator.circular` indeterminate motion —
  /// the arc length completes one full cycle every 1333ms.
  static const Duration arcCycleDuration = Duration(milliseconds: 1333);

  /// Duration of one full rotation.
  ///
  /// Reference: `md.comp.progress-indicator.circular` indeterminate motion —
  /// the indicator rotates 360° every 2222ms.
  static const Duration rotationCycleDuration = Duration(milliseconds: 2222);

  /// Combined cycle duration (LCM of [arcCycleDuration] and
  /// [rotationCycleDuration]).
  ///
  /// Both sub-cycles complete an integer number of repetitions within this
  /// period (2222 arc cycles, 1333 rotations), so the repeating animation
  /// wraps seamlessly without a visible jump.
  static const Duration combinedCycleDuration = Duration(
    milliseconds: 1333 * 2222,
  );

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
    // First half (0→0.5): head expands rapidly, tail stationary.
    // Second half (0.5→1.0): head holds, tail catches up.
    final (headRaw, tailRaw) = switch (cycleT) {
      < 0.5 => (cycleT * 2.0, 0.0),
      _ => (1.0, (cycleT - 0.5) * 2.0),
    };

    // M3 standard easing (md.sys.motion.easing-standard / fastOutSlowIn) is
    // applied to both the head and the tail, matching the reference
    // implementation.
    final headT = Curves.fastOutSlowIn.transform(headRaw);
    final tailT = Curves.fastOutSlowIn.transform(tailRaw);

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

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:rhizu/src/ui/components/indicators/animation/indeterminate_arc_motion.dart';

/// The start angle and sweep of a circular progress arc.
///
/// Shared by the flat and wavy circular painters so both derive their active
/// arc and the surrounding track gap from the same math.
@immutable
class CircularArc {
  const CircularArc({required this.start, required this.sweep});

  /// Resolves the active arc for determinate or indeterminate progress.
  factory CircularArc.forProgress({
    required double? value,
    required double rotation,
    required double baseSpin,
  }) {
    if (value == null) {
      final (arcStart, arcSweep) = IndeterminateArcMotion.compute(rotation);
      return CircularArc(start: arcStart + baseSpin, sweep: arcSweep);
    }
    return CircularArc(
      start: -math.pi / 2 + rotation,
      sweep: value.clamp(0.0, 1.0) * math.pi * 2,
    );
  }

  /// A full turn in radians.
  static const double fullCircle = math.pi * 2;

  final double start;
  final double sweep;

  double get end => start + sweep;

  /// Whether the active arc covers (almost) the full circle.
  bool get isFullCircle => sweep >= fullCircle * 0.999;

  /// The stroke-inclusive gap between the active and track arcs.
  ///
  /// Both arcs use round caps that extend `stroke / 2` past their endpoints,
  /// so the endpoints must be `gap + stroke` apart for a real [gap]-sized
  /// visible space to remain.
  double gapAngle({
    required double stroke,
    required double gap,
    required double radius,
  }) {
    return (stroke + gap) / radius;
  }

  /// The sweep of the track arc left around the active arc and its gaps.
  double trackSweep(double gapAngle) {
    final a1 = end + gapAngle;
    final a2 = start - gapAngle;
    var sweep = a2 - a1;
    while (sweep <= 0) {
      sweep += fullCircle;
    }
    return sweep;
  }

  /// Paints the track arc around the active arc.
  void paintTrack(
    Canvas canvas,
    Rect rect,
    Paint paint,
    double gapAngle,
  ) {
    canvas.drawArc(rect, end + gapAngle, trackSweep(gapAngle), false, paint);
  }
}

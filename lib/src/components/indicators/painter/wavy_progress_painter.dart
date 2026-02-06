import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:rhizu/src/components/indicators/constants.dart';

/// A custom painter that renders a wavy circular progress indicator.
///
/// This painter supports both determinate (with progress value) and
/// indeterminate (spinning) modes. The active indicator is rendered as
/// a wavy line while the track can be rendered as either a flat circle
/// (indeterminate) or an arc (determinate).
class WavyProgressPainter extends CustomPainter {

  /// Creates a wavy progress painter.
  ///
  /// All parameters are required and define the visual appearance
  /// and behavior of the progress indicator.
  const WavyProgressPainter({
    required this.progress,
    required this.rotation,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
    required this.waves,
    required this.amplitude,
    required this.trackGap,
  });
  /// The current progress value (0.0 to 1.0) or null for indeterminate mode.
  final double? progress;

  /// The current rotation angle in radians (for indeterminate mode).
  final double rotation;

  /// The color of the active progress indicator.
  final Color color;

  /// The color of the track (background) arc.
  final Color trackColor;

  /// The width of the stroke lines in logical pixels.
  final double strokeWidth;

  /// The number of waves (frequency) around the circle.
  final int waves;

  /// The amplitude (height) of the wave in logical pixels.
  final double amplitude;

  /// The gap between the active indicator and track in logical pixels.
  final double trackGap;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Base radius for the Active Wave (center of the wave oscillation)
    // Calculated to ensure the wave stays within the widget bounds (radius)
    final baseRadius = (size.width / 2) - amplitude - (strokeWidth / 2);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // 1. Draw Track (Flat)
    if (progress != null) {
      // Determinate: Track collapses as active grows, with a gap
      final gapAngle = trackGap / baseRadius;
      final activeSweep = 2 * math.pi * progress!.clamp(0.0, 1.0);

      final trackStartAngle =
          WavyProgressConstants.startAngleOffset + activeSweep + gapAngle;
      final trackSweepAngle = (2 * math.pi) - activeSweep - gapAngle;

      if (trackSweepAngle > 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: baseRadius),
          trackStartAngle,
          trackSweepAngle,
          false,
          trackPaint,
        );
      }
    } else {
      // Indeterminate: Full flat track
      canvas.drawCircle(center, baseRadius, trackPaint);
    }

    // 2. Draw Active Indicator (Wavy)
    if (progress != null) {
      // DETERMINATE MODE
      final activePath = createWavyPath(
        center: center,
        baseRadius: baseRadius,
        startAngle: WavyProgressConstants.startAngleOffset,
        sweepAngle: 2 * math.pi * progress!.clamp(0.0, 1.0),
        globalRotation: 0,
      );
      canvas.drawPath(activePath, activePaint);
    } else {
      // INDETERMINATE MODE (Spinner)
      // Create a sub-segment of the wave that rotates
      const tailLength =
          (2 * math.pi) * WavyProgressConstants.indeterminateTailLength;
      final activePath = createWavyPath(
        center: center,
        baseRadius: baseRadius,
        startAngle: 0,
        sweepAngle: tailLength,
        globalRotation: rotation,
      );
      canvas.drawPath(activePath, activePaint);
    }
  }

  /// Creates a wavy path segment.
  ///
  /// [center] The center point of the circle.
  /// [baseRadius] The base radius (center of wave oscillation).
  /// [startAngle] The starting angle in radians.
  /// [sweepAngle] The angle span in radians.
  /// [globalRotation] Additional rotation applied to the entire path.
  Path createWavyPath({
    required Offset center,
    required double baseRadius,
    required double startAngle,
    required double sweepAngle,
    required double globalRotation,
  }) {
    final path = Path();
    const step = WavyProgressConstants.pathStep;
    var first = true;

    // Iterate through the angles to create the vertices
    for (double t = 0; t <= sweepAngle; t += step) {
      final currentAngle = startAngle + t + globalRotation;

      // Calculate Wave Offset based on angle relative to the circle (not rotation)
      // This ensures the wave shape stays static if globalRotation is 0
      final wavePhase = currentAngle * waves;
      final currentRadius =
          baseRadius + (amplitude * math.sin(wavePhase));

      final x = center.dx + currentRadius * math.cos(currentAngle);
      final y = center.dy + currentRadius * math.sin(currentAngle);

      if (first) {
        path.moveTo(x, y);
        first = false;
      } else {
        path.lineTo(x, y);
      }
    }

    // Ensure the end connects smoothly if full circle
    if (sweepAngle >= 2 * math.pi) {
      path.close();
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant WavyProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.rotation != rotation ||
        oldDelegate.color != color ||
        oldDelegate.trackGap != trackGap ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.waves != waves ||
        oldDelegate.amplitude != amplitude;
  }
}

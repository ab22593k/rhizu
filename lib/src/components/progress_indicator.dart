import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

class WavyCircularProgressIndicator extends StatefulWidget {
  final double? value; // Null for indeterminate
  final Color color;
  final Color trackColor;
  final double radius;
  final double strokeWidth;
  final int waves; // Frequency of the wave
  final double amplitude; // Height of the wave
  final double trackGap; // Gap between Active indicator and track

  const WavyCircularProgressIndicator({
    super.key,
    this.value,
    required this.color,
    required this.trackColor,
    this.radius = 24.0,
    this.strokeWidth = 4.0,
    this.waves = 12,
    this.amplitude = 2.0,
    this.trackGap = 4.0,
  });

  @override
  State<WavyCircularProgressIndicator> createState() =>
      _WavyCircularProgressIndicatorState();
}

class _WavyCircularProgressIndicatorState
    extends State<WavyCircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.radius * 2,
      height: widget.radius * 2,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _WavyProgressPainter(
              progress: widget.value,
              rotation: _controller.value * 2 * math.pi,
              color: widget.color,
              trackColor: widget.trackColor,
              strokeWidth: widget.strokeWidth,
              waves: widget.waves,
              amplitude: widget.amplitude,
              trackGap: widget.trackGap,
            ),
          );
        },
      ),
    );
  }
}

class _WavyProgressPainter extends CustomPainter {
  final double? progress;
  final double rotation;
  final Color color;
  final Color trackColor;
  final double strokeWidth;
  final int waves;
  final double amplitude;
  final double trackGap;

  _WavyProgressPainter({
    required this.progress,
    required this.rotation,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
    required this.waves,
    required this.amplitude,
    required this.trackGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Base radius for the Active Wave (center of the wave oscillation)
    // Calculated to ensure the wave stays within the widget bounds (radius)
    final baseRadius = (size.width / 2) - amplitude - (strokeWidth / 2);

    final Paint trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Paint activePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // 1. Draw Track (Flat)
    if (progress != null) {
      // Determinate: Track collapses as active grows, with a gap
      final double gap = 4.0; // 4dp gap
      final double gapAngle = gap / baseRadius;
      final double activeSweep = 2 * math.pi * progress!.clamp(0.0, 1.0);

      final double trackStartAngle = -math.pi / 2 + activeSweep + gapAngle;
      final double trackSweepAngle = (2 * math.pi) - activeSweep - gapAngle;

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
      final Path activePath = _createWavyPath(
        center: center,
        baseRadius: baseRadius,
        startAngle: -math.pi / 2, // Start from top
        sweepAngle: 2 * math.pi * progress!.clamp(0.0, 1.0),
        globalRotation: 0,
      );
      canvas.drawPath(activePath, activePaint);
    } else {
      // INDETERMINATE MODE (Spinner)
      // We create a sub-segment of the wave that rotates
      const tailLength = (2 * math.pi) * 0.75;
      final Path activePath = _createWavyPath(
        center: center,
        baseRadius: baseRadius,
        startAngle: 0,
        sweepAngle: tailLength,
        globalRotation: rotation,
      );
      canvas.drawPath(activePath, activePaint);
    }
  }

  Path _createWavyPath({
    required Offset center,
    required double baseRadius,
    required double startAngle,
    required double sweepAngle,
    required double globalRotation,
  }) {
    final path = Path();
    const step = 0.01; // Resolution of the curve
    bool first = true;

    // Iterate through the angles to create the vertices
    for (double t = 0; t <= sweepAngle; t += step) {
      final double currentAngle = startAngle + t + globalRotation;

      // Calculate Wave Offset based on angle relative to the circle (not rotation)
      // This ensures the wave shape stays static if globalRotation is 0
      final double wavePhase = currentAngle * waves;
      final double currentRadius =
          baseRadius + (amplitude * math.sin(wavePhase));

      final double x = center.dx + currentRadius * math.cos(currentAngle);
      final double y = center.dy + currentRadius * math.sin(currentAngle);

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
  bool shouldRepaint(covariant _WavyProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.rotation != rotation ||
        oldDelegate.color != color ||
        oldDelegate.trackGap != trackGap;
  }
}

@Preview(name: 'Expressive Loader (Contained)')
Widget previewExpressiveLoaderContained() => MaterialApp(
  home: Scaffold(
    body: Builder(
      builder: (context) => Center(
        child: Row(
          mainAxisAlignment: .center,
          spacing: 40.0,
          children: [
            WavyCircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              trackColor: Theme.of(context).colorScheme.secondaryContainer,
              radius: 26,
              strokeWidth: 8,
              waves: 8,
              amplitude: 2.5,
            ),
          ],
        ),
      ),
    ),
  ),
);

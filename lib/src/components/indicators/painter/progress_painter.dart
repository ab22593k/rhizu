import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rhizu/rhizu.dart';

class CircularFlatPainter extends CustomPainter {
  CircularFlatPainter({
    required this.value,
    required this.active,
    required this.track,
    required this.rotation,
    required this.size,
  });

  final double? value;
  final Color active;
  final Color track;
  final double rotation;
  final CircularProgressIndicatorSize size;

  @override
  void paint(Canvas canvas, Size s) {
    const stroke = 4.0;
    final center = s.center(Offset.zero);
    final radius = (math.min(s.width, s.height) - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // gap before active in dp -> angle
    const gapDp = 8.0;
    final gapAngle = gapDp / radius; // s = r * angle

    // active sweep
    final sweep = value == null
        ? math.pi * 1.5
        : (value!.clamp(0.0, 1.0) * math.pi * 2);

    final start = -math.pi / 2 + rotation;
    final activeStart = start;
    final activeEnd = start + sweep;

    // TRACK: draw the rest of the ring, leaving a gap ahead of the active arc and no overlap.
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = track;

    const total = math.pi * 2;
    final a1 = activeEnd + gapAngle;
    final a2 = activeStart - gapAngle;
    var sweep1 = a2 - a1;
    while (sweep1 <= 0) {
      sweep1 += total;
    }
    canvas.drawArc(rect, a1, sweep1, false, trackPaint);

    // ACTIVE arc
    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = active;
    canvas.drawArc(rect, activeStart, sweep, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant CircularFlatPainter old) =>
      value != old.value ||
      active != old.active ||
      track != old.track ||
      rotation != old.rotation ||
      size != old.size;
}

class CircularWavyPainter extends CustomPainter {
  CircularWavyPainter({
    required this.value,
    required this.active,
    required this.track,
    required this.rotation,
  });

  final double? value;
  final Color active;
  final Color track;
  final double rotation;

  @override
  void paint(Canvas canvas, Size s) {
    const stroke = 4.0;
    final center = s.center(Offset.zero);
    final baseRadius = (math.min(s.width, s.height) - stroke) / 2;

    const amp = 2.0; // radial amplitude of squiggle
    const scallopLen = 18.0; // along-arc wavelength proxy (dp)
    // Taper length to fade the wave amplitude to zero near the end so the line ends "closed".
    const taperLen = scallopLen / 2;

    // Active sweep
    final activeSweep = value == null
        ? math.pi * 2
        : (value!.clamp(0.0, 1.0) * math.pi * 2);
    final start = -math.pi / 2 + rotation;
    final end = start + activeSweep;

    // Track ring with gap around active (skip when wave-only: indeterminate or 100%)
    final waveOnly = value == null || (value != null && value! >= 1.0);
    if (!waveOnly) {
      final trackPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true
        ..color = track;

      final gapAngle = 2.0 / baseRadius;
      final rect = Rect.fromCircle(center: center, radius: baseRadius);
      const total = math.pi * 2;
      final a1 = end + gapAngle;
      final a2 = start - gapAngle;
      var sweep1 = a2 - a1;
      while (sweep1 <= 0) {
        sweep1 += total;
      }
      canvas.drawArc(rect, a1, sweep1, false, trackPaint);
    }

    // Active squiggle path
    final steps = math.max(48, (s.width * 1.2).round());
    final path = Path();
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      final ang = start + (end - start) * t;
      final arcLen = baseRadius * (ang - start);
      // Fade amplitude to 0 near the end so the path ends on the base radius (closed look).
      final arcToEnd = baseRadius * (end - ang);
      var taperFactor = 1.0;
      if (arcToEnd < taperLen) {
        final tEnd = (arcToEnd / taperLen).clamp(0.0, 1.0);
        // Ease-out to 0 at the very end.
        taperFactor = math.sin(tEnd * math.pi / 2);
      }
      final r =
          baseRadius +
          (amp * taperFactor) * math.sin(arcLen / scallopLen * 2 * math.pi);
      final p = Offset(
        center.dx + r * math.cos(ang),
        center.dy + r * math.sin(ang),
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = active;
    canvas.drawPath(path, activePaint);
  }

  @override
  bool shouldRepaint(covariant CircularWavyPainter old) =>
      value != old.value ||
      active != old.active ||
      track != old.track ||
      rotation != old.rotation;
}

class LinearPainter extends CustomPainter {
  LinearPainter({
    required this.value,
    required this.spec,
    required this.active,
    required this.track,
    required this.phase,
    required this.inset,
  });

  final double? value;
  final LinearSpecs spec;
  final Color active;
  final Color track;
  final double phase;
  final double inset;

  @override
  void paint(Canvas canvas, Size size) {
    final left = inset;
    final right = size.width - spec.trailingMargin;
    final width = math.max(0.0, right - left);

    // both strokes share the same baseline (centerline)
    final cy = size.height / 2;
    final trackCy = cy;
    final activeCy = cy;

    // --- Draw track lane (flat pill) ---
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = spec.trackHeight
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // compute progress fraction early for both lanes
    final p = (value ?? 0).clamp(0.0, 1.0);

    // Wave-only mode: in wavy shape, when indeterminate or full (100%),
    // hide the track and end-dot; show only the wave which is animated via phase.
    final waveOnly = spec.isWavy && (value == null || p >= 1.0);

    // Track occupies the remaining segment to the right of the active,
    // leaving a fixed inter-stroke gap. For indeterminate, fill full width.
    final activeEndX = value == null ? right : (left + width * p);
    final trackStartX = value == null
        ? left
        : math.min(right, activeEndX + spec.gap);

    if (!waveOnly) {
      canvas.drawLine(
        Offset(trackStartX, trackCy),
        Offset(right, trackCy),
        base..color = track,
      );
    }

    // --- Active lane ---
    if (spec.isWavy) {
      // wavy centerline
      final start = left;
      final end = value == null ? right : (left + width * p);
      final path = Path();
      const step = 1.5;
      final k = 2 * math.pi / spec.wavePeriod;

      var x = start;
      var y = activeCy + spec.waveAmplitude * math.sin(phase + (x - start) * k);
      path.moveTo(x, y);
      for (x = start + step; x <= end; x += step) {
        y = activeCy + spec.waveAmplitude * math.sin(phase + (x - start) * k);
        path.lineTo(x, y);
      }
      // precise end point
      y = activeCy + spec.waveAmplitude * math.sin(phase + (end - start) * k);
      path.lineTo(end, y);

      canvas.drawPath(
        path,
        base
          ..color = active
          ..strokeWidth = spec.trackHeight,
      );

      // end dot: accent at far right end of the track (shared baseline)
      if (!waveOnly) {
        final dotCenterX = math.max(left, right - spec.dotOffset);
        canvas.drawCircle(
          Offset(dotCenterX, trackCy),
          spec.dotDiameter / 2,
          Paint()..color = active,
        );
      }
    } else {
      // flat active pill + end dot
      final start = left;
      final end = value == null ? right : (left + width * p);
      canvas.drawLine(
        Offset(start, activeCy),
        Offset(end, activeCy),
        base
          ..color = active
          ..strokeWidth = spec.trackHeight,
      );
      final dotCenterX = math.max(left, right - spec.dotOffset);
      canvas.drawCircle(
        Offset(dotCenterX, trackCy),
        spec.dotDiameter / 2,
        Paint()..color = active,
      );
    }
  }

  @override
  bool shouldRepaint(covariant LinearPainter old) =>
      value != old.value ||
      spec != old.spec ||
      active != old.active ||
      track != old.track ||
      phase != old.phase ||
      inset != old.inset;
}

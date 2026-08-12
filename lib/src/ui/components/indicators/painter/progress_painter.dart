import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rhizu/rhizu.dart';
import 'package:rhizu/src/ui/components/indicators/animation/indeterminate_arc_motion.dart';
import 'package:rhizu/src/ui/components/indicators/constants.dart';

/// Paints a flat (non-wavy) circular progress indicator.
///
/// Spec measurements (merged M3 token set `md.comp.progress-indicator.circular`):
///
/// | Variant      | Container ⌀ | Stroke | Gap | Stop ⌀ |
/// |--------------|-------------|--------|-----|--------|
/// | Flat  small  | 40          | 4      | 4   | 4      |
/// | Flat  medium | 52          | 8      | 4   | 4      |
class CircularFlatPainter extends CustomPainter {
  CircularFlatPainter({
    required this.value,
    required this.active,
    required this.track,
    required this.rotation,
    required this.size,
    this.baseSpin = 0.0,
  });

  final double? value;
  final Color active;
  final Color track;
  final double rotation;
  final ProgressIndicatorSize size;
  final double baseSpin;

  @override
  void paint(Canvas canvas, Size s) {
    final stroke = size.thickness;
    final center = s.center(Offset.zero);
    final radius = (math.min(s.width, s.height) - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Spec: gap between active arc and track arc = 4dp.
    const gapDp = 4.0;
    final gapAngle = gapDp / radius;

    final isIndeterminate = value == null;

    late final double activeStart;
    late final double sweep;

    if (isIndeterminate) {
      // M3-spec two-arc asymmetric motion:
      // rotation here represents the continuous count of elapsed arc cycles.
      final (arcStart, arcSweep) = IndeterminateArcMotion.compute(rotation);
      // Add baseSpin rotation as the continuous spinning offset.
      activeStart = arcStart + baseSpin;
      sweep = arcSweep;
    } else {
      sweep = value!.clamp(0.0, 1.0) * math.pi * 2;
      activeStart = -math.pi / 2 + rotation;
    }

    final activeEnd = activeStart + sweep;

    // TRACK: gapped arc (hidden when active covers full circle).
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = track;

    const total = math.pi * 2;
    if (sweep < total * 0.999) {
      final a1 = activeEnd + gapAngle;
      final a2 = activeStart - gapAngle;
      var sweep1 = a2 - a1;
      while (sweep1 <= 0) {
        sweep1 += total;
      }
      canvas.drawArc(rect, a1, sweep1, false, trackPaint);
    }

    // ACTIVE arc.
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
      baseSpin != old.baseSpin ||
      size != old.size;
}

/// Paints a wavy (squiggle) circular progress indicator.
///
/// Spec measurements (merged M3 token set `md.comp.progress-indicator.circular`):
///
/// | Variant      | Container ⌀ | Stroke | Gap | Amplitude | Scallop λ | Stop ⌀ |
/// |--------------|-------------|--------|-----|-----------|-----------|--------|
/// | Wavy  small  | 48          | 4      | 4   | 1.6       | 15        | 4      |
/// | Wavy  medium | 60*         | 8      | 4   | 1.6       | 15        | 4      |
///
/// *Derived from `circular.thick.size` (52dp) + the baseline wavy container
/// offset (48 − 40 = 8dp).
class CircularWavyPainter extends CustomPainter {
  CircularWavyPainter({
    required this.value,
    required this.active,
    required this.track,
    required this.rotation,
    required this.size,
    required this._path,
    this.baseSpin = 0.0,
    this.wavePhase = 0.0,
  });

  final double? value;
  final Color active;
  final Color track;
  final double rotation;
  final double baseSpin;
  final ProgressIndicatorSize size;
  final Path _path;

  /// Phase offset applied to the wave sin function.
  ///
  /// Animating this value makes the wave *travel* along the arc without
  /// changing the arc's position. Used for determinate wavy mode.
  final double wavePhase;

  @override
  void paint(Canvas canvas, Size s) {
    final stroke = size.thickness;
    final center = s.center(Offset.zero);

    // Spec: wave amplitude = 1.6dp (radial deviation from base circle).
    const amp = WavyProgressConstants.circularWaveAmplitude;

    // Base radius: account for wave amplitude + stroke so the
    // outermost wave peak + half-stroke stays within the container.
    //   outer_edge = baseRadius + amp + stroke/2
    //   container/2 = baseRadius + amp + stroke/2
    //   baseRadius  = (container − stroke)/2 − amp
    final baseRadius = (math.min(s.width, s.height) - stroke) / 2 - amp;

    // Spec: scallop arc-length wavelength = 15dp.
    const scallopLen = WavyProgressConstants.circularWavePeriod;
    // Taper length to fade the wave to zero near the tip (gives a closed look).
    const taperLen = scallopLen / 2;

    // Spec: gap between active and track = 4dp.
    const gapDp = 4.0;

    final isIndeterminate = value == null;

    late final double start;
    late final double end;
    late final double activeSweep;

    if (isIndeterminate) {
      // M3-spec two-arc asymmetric motion.
      final (arcStart, arcSweep) = IndeterminateArcMotion.compute(rotation);
      start = arcStart + baseSpin;
      activeSweep = arcSweep;
      end = start + activeSweep;
    } else {
      activeSweep = value!.clamp(0.0, 1.0) * math.pi * 2;
      start = -math.pi / 2 + rotation;
      end = start + activeSweep;
    }

    const total = math.pi * 2;
    if (activeSweep < total * 0.999) {
      final trackPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true
        ..color = track;
      final gapAngle = gapDp / baseRadius;
      final rect = Rect.fromCircle(center: center, radius: baseRadius);
      final a1 = end + gapAngle;
      final a2 = start - gapAngle;
      var sweep1 = a2 - a1;
      while (sweep1 <= 0) {
        sweep1 += total;
      }
      canvas.drawArc(rect, a1, sweep1, false, trackPaint);
    }

    final pEnd = isIndeterminate ? 0.0 : value!.clamp(0.0, 1.0);
    // Taper amplitude to 0 as progress hits 100% (from 95% -> 100%)
    final ampFade = isIndeterminate
        ? 1.0
        : (1.0 - pEnd).clamp(0.0, 0.05) / 0.05;
    final currentAmp = amp * ampFade;

    // Active squiggle path.
    final steps = math.max(48, (s.width * 1.2).round());
    _path.reset();
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      final ang = start + (end - start) * t;
      final arcLen = baseRadius * (ang - start);

      // Taper amplitude to 0 near the end for a closed appearance.
      final arcToEnd = baseRadius * (end - ang);
      var taperFactor = 1.0;
      if (arcToEnd < taperLen) {
        final tEnd = (arcToEnd / taperLen).clamp(0.0, 1.0);
        taperFactor = math.sin(tEnd * math.pi / 2);
      }

      final r =
          baseRadius +
          (currentAmp * taperFactor) *
              math.sin(arcLen / scallopLen * 2 * math.pi + wavePhase);
      final p = Offset(
        center.dx + r * math.cos(ang),
        center.dy + r * math.sin(ang),
      );
      if (i == 0) {
        _path.moveTo(p.dx, p.dy);
      } else {
        _path.lineTo(p.dx, p.dy);
      }
    }

    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = active;
    canvas.drawPath(_path, activePaint);
  }

  @override
  bool shouldRepaint(covariant CircularWavyPainter old) =>
      value != old.value ||
      active != old.active ||
      track != old.track ||
      rotation != old.rotation ||
      baseSpin != old.baseSpin ||
      size != old.size ||
      wavePhase != old.wavePhase;
}

/// Paints a linear progress indicator (flat or wavy).
class LinearPainter extends CustomPainter {
  LinearPainter({
    required this.value,
    required this.spec,
    required this.active,
    required this.track,
    required this.phase,
    required this.inset,
    required this._path,
  });

  final double? value;
  final LinearSpecs spec;
  final Color active;
  final Color track;
  final double phase;
  final double inset;
  final Path _path;

  @override
  void paint(Canvas canvas, Size size) {
    final left = inset;
    final right = size.width - spec.trailingMargin;

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

    // compute progress fraction early
    final isIndeterminate = value == null;
    final pEnd = isIndeterminate ? 0.0 : value!.clamp(0.0, 1.0);

    var activeStartX = left;
    var activeEndX = left;

    // Total physical bound of the indicator (including gap + dot)
    final trackEnd = isIndeterminate
        ? size.width
        : right + spec.gap + spec.dotDiameter;
    final fullActiveWidth = trackEnd - left;

    if (isIndeterminate) {
      // Indeterminate: slide center back and forth, while width grows and shrinks.
      final width = trackEnd - left;
      final centerT = (math.sin(phase - math.pi / 2) + 1.0) / 2.0;
      final widthT = (math.sin(phase * 2) + 1.0) / 2.0;
      final w = 0.2 + 0.5 * widthT;
      final sT = (centerT - w / 2).clamp(0.0, 1.0);
      final eT = (centerT + w / 2).clamp(0.0, 1.0);
      activeStartX = left + width * sT;
      activeEndX = left + width * eT;
    } else {
      activeStartX = left;
      activeEndX = left + fullActiveWidth * pEnd;
    }

    // --- Draw track lane ---
    if (isIndeterminate) {
      canvas.drawLine(
        Offset(left, trackCy),
        Offset(trackEnd, trackCy),
        base..color = track,
      );
    } else {
      // Determinate fixed inter-stroke gap
      final trackStartX = math.min(trackEnd, activeEndX + spec.gap);
      if (trackStartX < trackEnd) {
        canvas.drawLine(
          Offset(trackStartX, trackCy),
          Offset(trackEnd, trackCy),
          base..color = track,
        );
      }

      // Stop dot at the end
      // Spec: stop-indicator.color = md.sys.color.primary. The dot is drawn
      // beneath the active layer, so when activeEndX sweeps past it at 100%,
      // it is cleanly absorbed into the flat line.
      final dotCenterX = right + spec.gap + spec.dotDiameter / 2;
      final dotCenterY = trackCy + spec.dotVerticalOffset;
      canvas.drawCircle(
        Offset(dotCenterX, dotCenterY),
        spec.dotDiameter / 2,
        Paint()..color = active, // Spec: stop-indicator.color = primary
      );
    }

    // --- Active lane ---
    // Fade wave amplitude to 0 as progress hits 100%
    final ampFade = isIndeterminate
        ? 1.0
        : (1.0 - pEnd).clamp(0.0, 0.05) / 0.05;
    final currentAmp = spec.waveAmplitude * ampFade;

    if (spec.isWavy && currentAmp > 0.01) {
      // wavy centerline
      final start = activeStartX;
      final end = activeEndX;

      if (end > start) {
        _path.reset();
        const step = 1.5;
        // Spec: indeterminate wavelength = 20dp; determinate = 40dp.
        final period = isIndeterminate
            ? spec.indeterminateWavePeriod
            : spec.wavePeriod;
        final k = 2 * math.pi / period;

        var x = start;
        var y = activeCy + currentAmp * math.sin(phase + (x - left) * k);
        _path.moveTo(x, y);
        for (x = start + step; x <= end; x += step) {
          y = activeCy + currentAmp * math.sin(phase + (x - left) * k);
          _path.lineTo(x, y);
        }
        y = activeCy + currentAmp * math.sin(phase + (end - left) * k);
        _path.lineTo(end, y);

        canvas.drawPath(
          _path,
          base
            ..color = active
            ..strokeWidth = spec.trackHeight,
        );
      }
    } else {
      // flat active pill
      final start = activeStartX;
      final end = activeEndX;
      if (end > start) {
        canvas.drawLine(
          Offset(start, activeCy),
          Offset(end, activeCy),
          base
            ..color = active
            ..strokeWidth = spec.trackHeight,
        );
      }
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

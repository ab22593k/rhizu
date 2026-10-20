import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:rhizu/src/ui/components/indicators/animation/indeterminate_arc_motion.dart';
import 'package:rhizu/src/ui/components/indicators/constants.dart';
import 'package:rhizu/src/ui/components/indicators/painter/progress_painter.dart';
import 'package:rhizu/src/ui/components/indicators/progress_tokens.dart';

/// The circular progress painter host.
class ProgressCircularIndicator extends StatefulWidget {
  const ProgressCircularIndicator({
    required this.size,
    required this.shape,
    required this.rotation,
    super.key,
    this.value,
    this.activeColor,
    this.trackColor,
    this.amplitude,
    this.wavelength,
  });

  final double? value;
  final ProgressIndicatorSize size;
  final ProgressIndicatorShape shape;
  final Color? activeColor;
  final Color? trackColor;
  final double rotation;
  final double? amplitude;
  final double? wavelength;

  @override
  State<ProgressCircularIndicator> createState() =>
      _ProgressCircularIndicatorState();
}

class _ProgressCircularIndicatorState extends State<ProgressCircularIndicator> {
  late final Path _path;

  @override
  void initState() {
    super.initState();
    _path = Path();
  }

  bool get _shouldAnimate {
    if (MediaQuery.disableAnimationsOf(context)) return false;
    if (widget.rotation != 0.0) return false;
    final v = widget.value;
    if (v == null) return true;
    if (widget.shape != ProgressIndicatorShape.wavy) return false;
    // The reference only runs the wave animation while the wave amplitude is
    // positive: the determinate amplitude ramp keeps the wave flat below 10%
    // and above 95% progress, so there is nothing to animate there.
    return WavyProgressConstants.determinateWaveAmplitudeFactor(v) > 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final active = widget.activeColor ?? cs.primary;
    final track = widget.trackColor ?? cs.secondaryContainer;
    final wantsWavy = widget.shape == ProgressIndicatorShape.wavy;
    final diameter = wantsWavy
        ? widget.size.diameterWavy
        : widget.size.diameterFlat;

    return RepaintBoundary(
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: _shouldAnimate
            ? RepeatingAnimationBuilder<double>(
                // M3 motion spec (md.comp.progress-indicator.circular indeterminate):
                // the arc length completes one cycle every
                // 1333ms and the indicator rotates 360° every 2222ms. The
                // combined LCM (1333 * 2222) keeps both sub-cycles
                // integer-aligned so the animation wraps seamlessly.
                duration: IndeterminateArcMotion.combinedCycleDuration,
                animatable: Tween(
                  begin: 0.0,
                  end: IndeterminateArcMotion
                      .combinedCycleDuration
                      .inMilliseconds
                      .toDouble(),
                ),
                builder: (context, totalMs, child) {
                  final isIndeterminate = widget.value == null;

                  final arcCycles =
                      totalMs /
                      IndeterminateArcMotion.arcCycleDuration.inMilliseconds;
                  final spinAngle =
                      (totalMs /
                          IndeterminateArcMotion
                              .rotationCycleDuration
                              .inMilliseconds) *
                      2 *
                      math.pi;

                  return CustomPaint(
                    painter: wantsWavy
                        ? CircularWavyPainter(
                            value: widget.value,
                            active: active,
                            track: track,
                            rotation: isIndeterminate
                                ? arcCycles
                                : widget.rotation,
                            baseSpin: isIndeterminate ? spinAngle : 0.0,
                            size: widget.size,
                            path: _path,
                            amplitude: widget.amplitude,
                            wavelength: widget.wavelength,
                            // The wave travels with the arc cycle (one
                            // wavelength per 1333ms cycle) so it stays
                            // integer-aligned with the combined LCM and never
                            // jumps at the wrap boundary.
                            wavePhase: arcCycles * 2 * math.pi,
                          )
                        : CircularFlatPainter(
                            value: widget.value,
                            active: active,
                            track: track,
                            rotation: isIndeterminate
                                ? arcCycles
                                : widget.rotation,
                            baseSpin: isIndeterminate ? spinAngle : 0.0,
                            size: widget.size,
                          ),
                  );
                },
              )
            : CustomPaint(
                painter: wantsWavy
                    ? CircularWavyPainter(
                        value: widget.value,
                        active: active,
                        track: track,
                        rotation: widget.rotation,
                        size: widget.size,
                        path: _path,
                        amplitude: widget.amplitude,
                        wavelength: widget.wavelength,
                      )
                    : CircularFlatPainter(
                        value: widget.value,
                        active: active,
                        track: track,
                        rotation: widget.rotation,
                        size: widget.size,
                      ),
              ),
      ),
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:rhizu/src/ui/components/indicators/animation/linear_indeterminate_motion.dart';
import 'package:rhizu/src/ui/components/indicators/constants.dart';
import 'package:rhizu/src/ui/components/indicators/painter/progress_painter.dart';
import 'package:rhizu/src/ui/components/indicators/progress_linear_specs.dart';
import 'package:rhizu/src/ui/components/indicators/progress_tokens.dart';

/// The linear progress painter host.
class ProgressLinearIndicator extends StatefulWidget {
  const ProgressLinearIndicator({
    required this.size,
    required this.shape,
    required this.phase,
    required this.inset,
    super.key,
    this.value,
    this.activeColor,
    this.trackColor,
    this.amplitude,
    this.wavelength,
    this.showInlineLabel = false,
    this.textStyle,
  });

  final double? value;
  final ProgressIndicatorSize size;
  final ProgressIndicatorShape shape;
  final Color? activeColor;
  final Color? trackColor;
  final double phase;
  final double? amplitude;
  final double? wavelength;
  final double inset;
  final bool showInlineLabel;
  final TextStyle? textStyle;

  @override
  State<ProgressLinearIndicator> createState() =>
      _ProgressLinearIndicatorState();
}

class _ProgressLinearIndicatorState extends State<ProgressLinearIndicator> {
  late final Path _path;

  @override
  void initState() {
    super.initState();
    _path = Path();
  }

  bool get _shouldAnimate {
    if (MediaQuery.disableAnimationsOf(context)) return false;
    if (widget.phase != 0.0) return false;
    final v = widget.value;
    if (v == null) return true;
    if (widget.shape != ProgressIndicatorShape.wavy) return false;
    // Mirror the circular indicator: animate the wave only where the reference
    // amplitude ramp keeps it visible (10%–95% determinate progress).
    return WavyProgressConstants.determinateWaveAmplitudeFactor(v) > 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = widget.activeColor ?? theme.colorScheme.primary;
    final track = widget.trackColor ?? theme.colorScheme.secondaryContainer;
    final textDirection = Directionality.of(context);

    final spec = specForLinear(
      size: widget.size,
      shape: widget.shape,
      amplitude: widget.amplitude,
      wavelength: widget.wavelength,
    );

    final activeHeight = spec.isWavy
        ? (spec.trackHeight + 2 * spec.waveAmplitude)
        : spec.trackHeight;
    final totalHeight = activeHeight;

    final trackWidget = SizedBox(
      height: totalHeight,
      width: double.infinity,
      child: _shouldAnimate
          ? RepeatingAnimationBuilder<double>(
              // M3 motion spec (md.comp.progress-indicator.linear
              // indeterminate): one full two-line cycle every 2000ms.
              duration: LinearIndeterminateMotion.cycleDuration,
              animatable: Tween(begin: 0.0, end: 1.0),
              builder: (context, animValue, child) {
                final phaseValue = animValue * 2 * math.pi;
                return CustomPaint(
                  painter: LinearPainter(
                    value: widget.value,
                    spec: spec,
                    active: active,
                    track: track,
                    phase: phaseValue,
                    inset: widget.inset,
                    textDirection: textDirection,
                    path: _path,
                  ),
                );
              },
            )
          : CustomPaint(
              painter: LinearPainter(
                value: widget.value,
                spec: spec,
                active: active,
                track: track,
                // Reduced motion: freeze at a representative cycle position so
                // an active segment stays visible (not an empty track), but
                // honor an explicitly supplied phase when provided.
                phase: widget.value == null
                    ? (widget.phase != 0.0
                          ? widget.phase
                          : LinearIndeterminateMotion.staticPhase)
                    : widget.phase,
                inset: widget.inset,
                textDirection: textDirection,
                path: _path,
              ),
            ),
    );

    // Only show inline label for determinate mode
    if (!widget.showInlineLabel || widget.value == null) {
      return RepaintBoundary(child: trackWidget);
    }

    final pct = (widget.value!.clamp(0.0, 1.0) * 100).round();
    final labelStyle =
        widget.textStyle ?? theme.textTheme.labelSmall ?? const TextStyle();
    final progress = widget.value!.clamp(0.0, 1.0);

    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Position the label pill centered over the progress endpoint.
          LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              // Offset to center the label over the active endpoint.
              final targetX = totalWidth * progress;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Invisible spacer to give the Stack height
                  const SizedBox(height: 20),
                  Positioned(
                    left: targetX,
                    top: 0,
                    child: FractionalTranslation(
                      translation: const Offset(-0.5, 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: active,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$pct%',
                          style: labelStyle.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 4),
          trackWidget,
        ],
      ),
    );
  }
}

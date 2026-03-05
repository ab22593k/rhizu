import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:rhizu/rhizu.dart';
import 'package:rhizu/src/components/indicators/constants.dart';

/// Re-exports the painters used by the progress indicator widgets.
///
/// The actual painter implementations live in `painter/progress_painter.dart`.
export 'painter/progress_painter.dart';

/// Sizes available for the progress indicators.
@immutable
class ProgressIndicatorSize {
  const ProgressIndicatorSize({
    required this.thickness,
    required this.diameterFlat,
    required this.diameterWavy,
  });

  /// Configurable fixed size variant.
  factory ProgressIndicatorSize.from({
    double? thickness,
    double? diameter,
  }) {
    final t = thickness ?? 4.0;
    final d = diameter ?? 40.0;
    return ProgressIndicatorSize(
      thickness: t,
      diameterFlat: d,
      diameterWavy: d + 8.0,
    );
  }

  /// The thickness for linear indicators.
  final double thickness;

  /// The diameter for circular indicators (flat shape).
  final double diameterFlat;

  /// The diameter for circular indicators (wavy shape).
  final double diameterWavy;

  /// Alias for backward compatibility with the user's test code.
  static const ProgressIndicatorSize fixed = ProgressIndicatorSize(
    thickness: 4.0,
    diameterFlat: 40.0,
    diameterWavy: 48.0,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressIndicatorSize &&
          runtimeType == other.runtimeType &&
          thickness == other.thickness &&
          diameterFlat == other.diameterFlat &&
          diameterWavy == other.diameterWavy;

  @override
  int get hashCode => Object.hash(thickness, diameterFlat, diameterWavy);
}

/// Visual shape of the progress indicator.
///
/// - flat: a simple flat stroke for the progress.
/// - wavy: a wavy/stroked appearance with optional animation (used for
///   indeterminate / completed animations).
enum ProgressIndicatorShape { flat, wavy }

/// Variant of the progress indicator.
enum ProgressIndicatorVariant { linear, circular }

/// A unified configurable progress indicator.
///
/// Use `variant` to choose between a [ProgressIndicatorVariant.linear] and
/// [ProgressIndicatorVariant.circular] presentation.
class ProgressIndicator extends StatelessWidget {
  const ProgressIndicator({
    super.key,
    this.value,
    this.variant = ProgressIndicatorVariant.circular,
    this.size = ProgressIndicatorSize.fixed,
    this.shape = ProgressIndicatorShape.wavy,
    this.activeColor,
    this.trackColor,
    this.rotation = 0.0,
    this.phase = 0.0,
    this.inset = 4.0,
    this.showLabel = false,
    this.textStyle,
  });

  /// Determinate progress value between 0.0 and 1.0, or null for indeterminate.
  final double? value;

  /// Variant of the progress indicator (linear or circular).
  final ProgressIndicatorVariant variant;

  /// Visual size variant.
  final ProgressIndicatorSize size;

  /// Shape variant: flat or wavy.
  final ProgressIndicatorShape shape;

  /// Color used for the active/filled portion. If null, the theme's primary
  /// color is used.
  final Color? activeColor;

  /// Color used for the track/background stroke. If null a theme-derived
  /// translucent color is used.
  final Color? trackColor;

  /// Optional rotation (in radians) applied to the circular painter.
  final double rotation;

  /// Phase (radians) offset applied to the linear wave.
  final double phase;

  /// Horizontal inset/padding for the linear active area.
  final double inset;

  /// Whether to show the percentage label in the center (only applies when `variant == circular`).
  final bool showLabel;

  /// Optional style for the percentage text shown in the center.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    if (variant == ProgressIndicatorVariant.linear) {
      return _LinearProgressIndicator(
        value: value,
        size: size,
        shape: shape,
        activeColor: activeColor,
        trackColor: trackColor,
        phase: phase,
        inset: inset,
      );
    }

    final circular = _CircularProgressIndicator(
      value: value,
      size: size,
      shape: shape,
      activeColor: activeColor,
      trackColor: trackColor,
      rotation: rotation,
    );

    if (!showLabel || value == null) return circular;

    final d = size.diameterWavy;
    return SizedBox(
      width: d,
      height: d,
      child: Stack(
        alignment: Alignment.center,
        children: [
          circular,
          Text(
            '${(value! * 100).round()}%',
            style: textStyle ?? Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class _CircularProgressIndicator extends StatelessWidget {
  const _CircularProgressIndicator({
    required this.size,
    required this.shape,
    required this.rotation,
    this.value,
    this.activeColor,
    this.trackColor,
  });

  final double? value;
  final ProgressIndicatorSize size;
  final ProgressIndicatorShape shape;
  final Color? activeColor;
  final Color? trackColor;
  final double rotation;

  bool get _shouldAnimate {
    final v = value;
    return shape == ProgressIndicatorShape.wavy &&
        (v == null || (v >= 1.0)) &&
        rotation == 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final active = activeColor ?? cs.primary;
    final track = trackColor ?? cs.onSurfaceVariant.withValues(alpha: 0.24);
    final wantsWavy = shape == ProgressIndicatorShape.wavy;
    final diameter = wantsWavy ? size.diameterWavy : size.diameterFlat;

    return RepaintBoundary(
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: _shouldAnimate
            ? RepeatingAnimationBuilder<double>(
                duration: const Duration(milliseconds: 3600),
                animatable: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  final rot = value * 2 * math.pi;
                  return CustomPaint(
                    painter: CircularWavyPainter(
                      value: this.value,
                      active: active,
                      track: track,
                      rotation: rot,
                    ),
                  );
                },
              )
            : CustomPaint(
                painter: wantsWavy
                    ? CircularWavyPainter(
                        value: value,
                        active: active,
                        track: track,
                        rotation: rotation,
                      )
                    : CircularFlatPainter(
                        value: value,
                        active: active,
                        track: track,
                        rotation: rotation,
                        size: size,
                      ),
              ),
      ),
    );
  }
}

class _LinearProgressIndicator extends StatelessWidget {
  const _LinearProgressIndicator({
    required this.size,
    required this.shape,
    required this.phase,
    required this.inset,
    this.value,
    this.activeColor,
    this.trackColor,
  });

  final double? value;
  final ProgressIndicatorSize size;
  final ProgressIndicatorShape shape;
  final Color? activeColor;
  final Color? trackColor;
  final double phase;
  final double inset;

  bool get _shouldAnimate {
    final v = value;
    return shape == ProgressIndicatorShape.wavy &&
        (v == null || (v >= 1.0)) &&
        phase == 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final active = ColorScheme.of(context).primary;
    final track = ColorScheme.of(context).surfaceContainerHighest;

    final spec = specForLinear(size: size, shape: shape);

    final activeHeight = spec.isWavy
        ? (spec.trackHeight + 2 * spec.waveAmplitude)
        : spec.trackHeight;
    final totalHeight = activeHeight;

    return RepaintBoundary(
      child: SizedBox(
        height: totalHeight,
        width: double.infinity,
        child: _shouldAnimate
            ? RepeatingAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1000),
                animatable: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  final phaseValue = value * 2 * math.pi;
                  return CustomPaint(
                    painter: LinearPainter(
                      value: this.value,
                      spec: spec,
                      active: activeColor ?? active,
                      track: trackColor ?? track,
                      phase: phaseValue,
                      inset: inset,
                    ),
                  );
                },
              )
            : CustomPaint(
                painter: LinearPainter(
                  value: value,
                  spec: spec,
                  active: activeColor ?? active,
                  track: trackColor ?? track,
                  phase: phase,
                  inset: inset,
                ),
              ),
      ),
    );
  }
}

@immutable
class LinearSpecs {
  const LinearSpecs({
    required this.trackHeight,
    required this.gap,
    required this.dotDiameter,
    required this.dotOffset,
    required this.trailingMargin,
    required this.isWavy,
    this.waveAmplitude = 0,
    this.wavePeriod = WavyProgressConstants.defaultWavePeriod,
  });

  final double trackHeight;
  final double gap;
  final double dotDiameter;
  final double dotOffset;
  final double trailingMargin;
  final bool isWavy;
  final double waveAmplitude;
  final double wavePeriod;
}

LinearSpecs specForLinear({
  required ProgressIndicatorSize size,
  required ProgressIndicatorShape shape,
}) {
  final thickness = size.thickness;
  switch (shape) {
    case ProgressIndicatorShape.flat:
      return LinearSpecs(
        trackHeight: thickness,
        gap: 4,
        dotDiameter: 4,
        dotOffset: 0,
        trailingMargin: thickness / 2,
        isWavy: false,
      );
    case ProgressIndicatorShape.wavy:
      return LinearSpecs(
        trackHeight: thickness,
        gap: 4,
        dotDiameter: 4,
        dotOffset: 2,
        trailingMargin: thickness + 6,
        isWavy: true,
        waveAmplitude: 3,
        wavePeriod: 40,
      );
  }
}

@Preview(name: 'Progress Indicators', size: Size.fromHeight(180))
Widget previewProgressCircular() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: .spaceEvenly,
          children: [
            ProgressIndicator(
              value: 0.3,
            ),
            ProgressIndicator(
              value: 0.5,
              shape: ProgressIndicatorShape.flat,
            ),
            SizedBox(
              width: 120,
              child: ProgressIndicator(
                value: 0.3,
                variant: ProgressIndicatorVariant.linear,
              ),
            ),
            SizedBox(
              width: 120,
              child: ProgressIndicator(
                value: 0.5,
                shape: ProgressIndicatorShape.flat,
                variant: .linear,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

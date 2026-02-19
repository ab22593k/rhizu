import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:rhizu/rhizu.dart';
import 'package:rhizu/src/components/indicators/constants.dart';

/// Re-exports the painters used by the progress indicator widgets.
///
/// The actual painter implementations live in `painter/progress_painter.dart`.
export 'painter/progress_painter.dart';

/// Sizes available for the linear progress indicator.
///
/// - s: small
/// - m: medium
enum LinearProgressIndicatorSize { s, m }

/// Sizes available for the circular progress indicator.
///
/// - s: small
/// - m: medium
enum CircularProgressIndicatorSize { s, m }

/// Visual shape of the progress indicator.
///
/// - flat: a simple flat stroke for the progress.
/// - wavy: a wavy/stroked appearance with optional animation (used for
///   indeterminate / completed animations).
enum ProgressIndicatorShape { flat, wavy }

/// Utility extension to provide diameter values for the circular indicator
/// depending on size and shape variant.
extension CircularProgressIndicatorExt on CircularProgressIndicatorSize {
  /// Diameter to use when rendering the "wavy" variant of the circular
  /// progress indicator for this size.
  double get diameterWavy {
    switch (this) {
      case CircularProgressIndicatorSize.s:
        return 48.0;
      case CircularProgressIndicatorSize.m:
        return 52.0;
    }
  }

  /// Diameter to use when rendering the "flat" variant of the circular
  /// progress indicator for this size.
  double get diameterFlat {
    switch (this) {
      case CircularProgressIndicatorSize.s:
        return 40.0;
      case CircularProgressIndicatorSize.m:
        return 44.0;
    }
  }
}

/// A compact circular progress indicator with a percentage label centered.
///
/// This widget composes [CircularProgressIndicator] (custom implementation in
/// this library) with a centered [Text] showing the rounded percentage for a
/// provided [value].
///
/// Example:
/// ```dart
/// ProgressIndicator(value: 0.42);
/// ```
///
/// - [value] is required and expected to be between 0.0 and 1.0.
/// - [size] controls the visual size (small/medium).
/// - [textStyle] can be provided to override the label text style.
class ProgressIndicator extends StatelessWidget {
  const ProgressIndicator({
    required this.value,
    super.key,
    this.size = CircularProgressIndicatorSize.m,
    this.textStyle,
  });

  /// Progress value in the range 0.0 - 1.0 used to render the circle and the
  /// percentage label.
  final double value;

  /// Visual size of the circular indicator.
  final CircularProgressIndicatorSize size;

  /// Optional style for the percentage text shown in the center. If omitted
  /// the theme's `labelMedium` text style is used.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final d = size.diameterWavy;
    return SizedBox(
      width: d,
      height: d,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(value: value, size: size),
          Text(
            '${(value * 100).round()}%',
            style: textStyle ?? Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

/// A customizable circular progress indicator.
///
/// This implementation supports two visual shapes:
/// - [ProgressIndicatorShape.wavy]: draws a wavy stroke and can animate when
///   indeterminate (value == null) or when value >= 1.0 (shows a looping
///   flourish).
/// - [ProgressIndicatorShape.flat]: draws a simple flat circular stroke.
///
/// Parameters:
/// - [value]: if non-null, renders a determinate progress (0.0 - 1.0). If
///   null the indicator is indeterminate and may animate.
/// - [size]: small or medium variant.
/// - [shape]: visual style, defaults to [ProgressIndicatorShape.wavy].
/// - [activeColor]: color for the filled/active portion; defaults to the
///   theme primary color.
/// - [trackColor]: color for the track/background stroke; defaults to a
///   translucent onSurfaceVariant from the theme.
/// - [rotation]: explicit rotation (radians) to apply to the painter when not
///   using the built-in repeating animation. Defaults to 0.0.
class CircularProgressIndicator extends StatelessWidget {
  const CircularProgressIndicator({
    super.key,
    this.value,
    this.size = CircularProgressIndicatorSize.m,
    this.shape = ProgressIndicatorShape.wavy,
    this.activeColor,
    this.trackColor,
    this.rotation = 0.0,
  });

  /// Determinate progress value between 0.0 and 1.0, or null for indeterminate.
  final double? value;

  /// Size variant for the circular indicator.
  final CircularProgressIndicatorSize size;

  /// Shape variant: flat or wavy.
  final ProgressIndicatorShape shape;

  /// Color used for the active/filled portion. If null, the theme's primary
  /// color is used.
  final Color? activeColor;

  /// Color used for the track/background stroke. If null a theme-derived
  /// translucent color is used.
  final Color? trackColor;

  /// Optional rotation (in radians) applied to the painter. When left at the
  /// default (0.0) and the indicator is in a wavy indeterminate/completed
  /// state, an internal repeating animation rotates the decoration instead.
  final double rotation;

  /// Whether the widget should run its internal repeating animation.
  ///
  /// The wavy shape will animate when [value] is null (indeterminate) or when
  /// [value] >= 1.0 (complete flourish). The animation is not used when an
  /// explicit [rotation] is provided.
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

/// A customizable linear progress indicator.
///
/// This widget supports both flat and wavy appearances and can render
/// determinate (value in 0.0..1.0) or indeterminate (value == null)
/// states. When in a wavy indeterminate or complete state the widget can run
/// a repeating animation unless an explicit [phase] is provided.
///
/// Parameters:
/// - [value]: determinate progress value (0.0 - 1.0) or null for indeterminate.
/// - [size]: small or medium visual size.
/// - [shape]: visual style, flat or wavy.
/// - [activeColor]: color for the active/filled portion. Falls back to the
///   theme's primary color if null.
/// - [trackColor]: color for the track/background stroke. Falls back to a
///   theme-derived surface color if null.
/// - [phase]: phase offset in radians applied to the wave; when left at 0.0
///   and the indicator is indeterminate/completed a repeating animation will
///   supply a dynamic phase.
/// - [inset]: horizontal inset for the active area from the edges.
class LinearProgressIndicator extends StatelessWidget {
  const LinearProgressIndicator({
    super.key,
    this.value,
    this.size = LinearProgressIndicatorSize.m,
    this.shape = ProgressIndicatorShape.wavy,
    this.activeColor,
    this.trackColor,
    this.phase = 0.0,
    this.inset = 4.0,
  });

  /// Determinate progress value between 0.0 and 1.0, or null for indeterminate.
  final double? value;

  /// Visual size variant.
  final LinearProgressIndicatorSize size;

  /// Shape variant: flat or wavy.
  final ProgressIndicatorShape shape;

  /// Color for the active/filled portion.
  final Color? activeColor;

  /// Color for the track/background.
  final Color? trackColor;

  /// Phase (radians) used when drawing the wave. If left at 0.0 and the
  /// indicator is in a wavy indeterminate/completed state, an internal
  /// repeating animation will provide a phase value.
  final double phase;

  /// Horizontal inset/padding for the active area.
  final double inset;

  /// Whether the widget should run its internal repeating animation.
  bool get _shouldAnimate {
    final v = value;
    return shape == ProgressIndicatorShape.wavy &&
        (v == null || (v >= 1.0)) &&
        phase == 0.0;
  }

  @override
  Widget build(BuildContext context) {
    // Farben aus m3e_design beziehen (überschreibbar per Props)
    final active = ColorScheme.of(context).primary;
    final track = ColorScheme.of(context).surfaceContainerHighest;

    final spec = specForLinear(size: size, shape: shape);

    // Total height equals the taller of the two strokes sharing the same baseline.
    // For wavy, add vertical amplitude; for flat, it's just the trackHeight.
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
  required LinearProgressIndicatorSize size,
  required ProgressIndicatorShape shape,
}) => switch ((shape, size)) {
  (ProgressIndicatorShape.flat, LinearProgressIndicatorSize.s) =>
    const LinearSpecs(
      trackHeight: 4,
      gap: 4,
      dotDiameter: 4,
      dotOffset: 0,
      trailingMargin: 2,
      isWavy: false,
    ),
  (ProgressIndicatorShape.flat, LinearProgressIndicatorSize.m) =>
    const LinearSpecs(
      trackHeight: 8,
      gap: 4,
      dotDiameter: 8,
      dotOffset: 0,
      trailingMargin: 4,
      isWavy: false,
    ),
  (ProgressIndicatorShape.wavy, LinearProgressIndicatorSize.s) =>
    const LinearSpecs(
      trackHeight: 4,
      gap: 4,
      dotDiameter: 4,
      dotOffset: 2,
      trailingMargin: 10,
      isWavy: true,
    ),
  (ProgressIndicatorShape.wavy, LinearProgressIndicatorSize.m) =>
    const LinearSpecs(
      trackHeight: 8,
      gap: 4,
      dotDiameter: 4,
      dotOffset: 2,
      trailingMargin: 14,
      isWavy: true,
    ),
};

@Preview(name: 'Progress circular', size: Size.fromHeight(150))
Widget previewProgressCircular() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: .spaceEvenly,
          children: [
            ProgressIndicator(
              value: 0.25,
              size: CircularProgressIndicatorSize.s,
            ),
            CircularProgressIndicator(
              value: 0.5,
              shape: ProgressIndicatorShape.flat,
            ),
          ],
        ),
      ),
    ),
  );
}

@Preview(name: 'Progress Linear', size: Size.fromHeight(200))
Widget previewProgressLinear() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: .spaceEvenly,
          children: [
            SizedBox(
              width: 400,
              child: LinearProgressIndicator(
                value: 0.6,
              ),
            ),
            SizedBox(
              width: 400,
              child: LinearProgressIndicator(
                value: 0.9,
                shape: ProgressIndicatorShape.flat,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

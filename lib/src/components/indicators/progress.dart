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

  /// Small size — 4dp linear thickness, 40dp circular flat diameter.
  static const ProgressIndicatorSize s = ProgressIndicatorSize(
    thickness: 4.0,
    diameterFlat: 40.0,
    diameterWavy: 48.0,
  );

  /// Medium size — 8dp linear thickness, 44dp circular flat diameter.
  static const ProgressIndicatorSize m = ProgressIndicatorSize(
    thickness: 8.0,
    diameterFlat: 44.0,
    diameterWavy: 52.0,
  );

  /// Alias for backward compatibility (equivalent to [s]).
  static const ProgressIndicatorSize fixed = s;

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
/// - [flat]: a simple flat stroke for the progress.
/// - [wavy]: a wavy/squiggle appearance with continuous animation when
///   indeterminate or progress is complete.
enum ProgressIndicatorShape { flat, wavy }

/// Variant of the progress indicator.
enum ProgressIndicatorVariant { linear, circular }

/// A unified, configurable progress indicator.
///
/// Progress indicators behave differently based on the type of progress
/// being tracked:
///
/// **Determinate** — Known progress and wait time.
/// Set [value] to a number between `0.0` and `1.0`. The indicator will
/// accurately represent the progress of the task it is measuring.
///
/// ```dart
/// ProgressIndicator(value: 0.65) // 65 % complete
/// ```
///
/// **Indeterminate** — Unknown progress and wait time.
/// Leave [value] as `null` (the default). The indicator will show a
/// continuous animation to communicate that a process is happening, even
/// though the wait time is unknown.
///
/// ```dart
/// ProgressIndicator() // spins / slides continuously
/// ```
///
/// Use [variant] to choose between [ProgressIndicatorVariant.linear] and
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

  /// Progress value between 0.0 and 1.0 (determinate), or `null` for
  /// indeterminate mode.
  ///
  /// When non-null the indicator accurately represents the given progress.
  /// When `null` an animated loop communicates that a process is active but
  /// the remaining wait time is unknown.
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
    if (value == null) {
      return _buildVariant(context, null);
    }

    // We animate the determinate value implicitly with motion physics.
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: value),
      // Note: SpringCurve overrides standard translation, so this duration simply guarantees the animation lives long enough for the spring to settle.
      duration: const Duration(milliseconds: 1500),
      curve: SpringCurve(MotionTokens.expressiveSlowSpatial),
      builder: (context, animValue, child) => _buildVariant(context, animValue),
    );
  }

  Widget _buildVariant(BuildContext context, double? animatedValue) {
    if (variant == ProgressIndicatorVariant.linear) {
      return _LinearProgressIndicator(
        value: animatedValue,
        size: size,
        shape: shape,
        activeColor: activeColor,
        trackColor: trackColor,
        phase: phase,
        inset: inset,
      );
    }

    final circular = _CircularProgressIndicator(
      value: animatedValue,
      size: size,
      shape: shape,
      activeColor: activeColor,
      trackColor: trackColor,
      rotation: rotation,
    );

    if (!showLabel || animatedValue == null) return circular;

    final d = size.diameterWavy;
    return SizedBox(
      width: d,
      height: d,
      child: Stack(
        alignment: Alignment.center,
        children: [
          circular,
          Text(
            '${(animatedValue * 100).round()}%',
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

  /// Whether the indicator should run a continuous animation.
  ///
  /// Returns `true` when:
  ///  • **Indeterminate** (`value == null`) — regardless of shape.
  ///  • **Wavy shape** — the wave always travels, even for determinate.
  ///
  /// An explicit non-zero [rotation] overrides animation (the caller is
  /// driving it manually).
  bool get _shouldAnimate {
    if (rotation != 0.0) return false;
    final v = value;
    if (v == null) return true;
    // Wavy always animates (traveling wave for determinate + completed).
    return shape == ProgressIndicatorShape.wavy;
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
                duration: wantsWavy
                    ? const Duration(milliseconds: 2800)
                    : const Duration(milliseconds: 2400),
                animatable: Tween(begin: 0.0, end: 1.0),
                builder: (context, animValue, child) {
                  final animRad = animValue * 2 * math.pi;
                  // Indeterminate: spin the whole arc + traveling wave.
                  // Determinate wavy: keep arc fixed, animate wave phase.
                  final isIndeterminate = value == null;
                  return CustomPaint(
                    painter: wantsWavy
                        ? CircularWavyPainter(
                            value: value,
                            active: active,
                            track: track,
                            rotation: isIndeterminate ? animRad : 0.0,
                            size: size,
                            wavePhase: animRad,
                          )
                        : CircularFlatPainter(
                            value: value,
                            active: active,
                            track: track,
                            rotation: animRad,
                            size: size,
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
                        size: size,
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

  /// Whether the indicator should run a continuous animation.
  ///
  /// Returns `true` when:
  ///  • **Indeterminate** (`value == null`) — regardless of shape.
  ///  • **Wavy shape** — the wave always travels, even for determinate.
  ///
  /// An explicit non-zero [phase] overrides animation.
  bool get _shouldAnimate {
    if (phase != 0.0) return false;
    final v = value;
    if (v == null) return true;
    return shape == ProgressIndicatorShape.wavy;
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
                duration: spec.isWavy
                    ? const Duration(milliseconds: 1800)
                    : const Duration(milliseconds: 2600),
                animatable: Tween(begin: 0.0, end: 1.0),
                builder: (context, animValue, child) {
                  final phaseValue = animValue * 2 * math.pi;
                  return CustomPaint(
                    painter: LinearPainter(
                      value: value,
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
    required this.dotVerticalOffset,
    required this.trailingMargin,
    required this.isWavy,
    this.waveAmplitude = 0,
    this.wavePeriod = WavyProgressConstants.defaultWavePeriod,
  });

  /// Stroke height of active / track lines.
  final double trackHeight;

  /// Horizontal gap between active track end and inactive track start.
  /// Spec: gap = thickness (4dp small, 8dp medium).
  final double gap;

  /// Diameter of the stop indicator dot (always 4dp).
  final double dotDiameter;

  /// Vertical offset of the stop dot from the track centerline.
  /// Spec: 0dp for small (4dp), 2dp for medium (8dp).
  final double dotVerticalOffset;

  /// Right-side margin reserving space for the stop dot region.
  final double trailingMargin;

  /// Whether the active track uses a wavy path.
  final bool isWavy;

  /// Peak-to-center amplitude of the wave (spec: 3dp).
  final double waveAmplitude;

  /// Wavelength of the wave (spec: 40dp).
  final double wavePeriod;
}

/// Builds [LinearSpecs] from the unified [ProgressIndicatorSize] and shape.
///
/// Measurements taken from the M3 linear progress indicator spec:
///
/// | Variant       | trackHeight | gap | dot⌀ | dotVOff | amp | λ  | H   |
/// |---------------|-------------|-----|------|---------|-----|----|-----|
/// | Flat  small   | 4           | 4   | 4    | 0       | —   | —  | 4   |
/// | Flat  medium  | 8           | 8   | 4    | 2       | —   | —  | 8   |
/// | Wavy  small   | 4           | 4   | 4    | 0       | 3   | 40 | 10  |
/// | Wavy  medium  | 8           | 8   | 4    | 2       | 3   | 40 | 14  |
LinearSpecs specForLinear({
  required ProgressIndicatorSize size,
  required ProgressIndicatorShape shape,
}) {
  final thickness = size.thickness;
  // Shared derived measurements.
  const dotDiameter = 4.0;
  final gap = thickness; // spec: gap equals track height
  final dotVerticalOffset =
      (thickness - dotDiameter) / 2; // 0 for 4dp, 2 for 8dp

  switch (shape) {
    case ProgressIndicatorShape.flat:
      return LinearSpecs(
        trackHeight: thickness,
        gap: gap,
        dotDiameter: dotDiameter,
        dotVerticalOffset: dotVerticalOffset,
        trailingMargin: gap + dotDiameter,
        isWavy: false,
      );
    case ProgressIndicatorShape.wavy:
      return LinearSpecs(
        trackHeight: thickness,
        gap: gap,
        dotDiameter: dotDiameter,
        dotVerticalOffset: dotVerticalOffset,
        trailingMargin: gap + dotDiameter,
        isWavy: true,
        waveAmplitude: 3,
        wavePeriod: 40,
      );
  }
}

@Preview(name: 'Progress — Determinate', size: Size.fromHeight(180))
Widget previewProgressDeterminate() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: .spaceEvenly,
          children: [
            // Circular wavy 30 %
            ProgressIndicator(value: 0.3),
            // Circular flat 50 %
            ProgressIndicator(
              value: 0.5,
              shape: ProgressIndicatorShape.flat,
            ),
            // Linear wavy 30 %
            SizedBox(
              width: 120,
              child: ProgressIndicator(
                value: 0.3,
                variant: ProgressIndicatorVariant.linear,
              ),
            ),
            // Linear flat 50 %
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

@Preview(name: 'Progress — Indeterminate', size: Size.fromHeight(180))
Widget previewProgressIndeterminate() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: .spaceEvenly,
          children: [
            // Circular wavy — spinning wave
            ProgressIndicator(),
            // Circular flat — rotating arc
            ProgressIndicator(shape: ProgressIndicatorShape.flat),
            // Linear wavy — travelling wave
            SizedBox(
              width: 120,
              child: ProgressIndicator(
                variant: ProgressIndicatorVariant.linear,
              ),
            ),
            // Linear flat — sliding bar
            SizedBox(
              width: 120,
              child: ProgressIndicator(
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

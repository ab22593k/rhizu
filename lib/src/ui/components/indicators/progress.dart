import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'package:rhizu/rhizu.dart';
import 'package:rhizu/src/ui/components/indicators/constants.dart';

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

  /// Medium size — 8dp linear thickness, 52dp circular flat diameter.
  ///
  /// Matches the spec's "thick" sample configuration
  /// (`md.comp.progress-indicator.circular.thick.size` = 52dp). The wavy
  /// container is derived from the baseline +8dp offset (48 = 40 + 8), so
  /// thick wavy = 52 + 8 = 60dp.
  static const ProgressIndicatorSize m = ProgressIndicatorSize(
    thickness: 8.0,
    diameterFlat: 52.0,
    diameterWavy: 60.0,
  );

  /// Alias for backward compatibility (equivalent to [s]).
  static const ProgressIndicatorSize fixed = s;

  /// Returns a scaled copy of this size.
  ProgressIndicatorSize scaled(double scale) {
    if (scale == 1.0) return this;
    return ProgressIndicatorSize(
      thickness: thickness * scale,
      diameterFlat: diameterFlat * scale,
      diameterWavy: diameterWavy * scale,
    );
  }

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
class ProgressIndicator extends StatefulWidget {
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
    this.showInlineLabel = false,
    this.textStyle,
    this.onComplete,
    this.enableHapticFeedback = false,
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

  /// Whether to show a floating inline percentage label above the linear
  /// indicator's active endpoint.
  ///
  /// Only applies when [variant] is [ProgressIndicatorVariant.linear] and
  /// [value] is non-null (determinate mode). The label slides along the
  /// track as the progress animates.
  final bool showInlineLabel;

  /// Optional style for the percentage text shown in the center.
  final TextStyle? textStyle;

  /// Called when the animated progress value reaches 1.0 (completion).
  ///
  /// This is triggered once per completion event. If the value drops below
  /// 1.0 and reaches it again, the callback fires again.
  final VoidCallback? onComplete;

  /// Whether to trigger a haptic feedback buzz on completion.
  ///
  /// Defaults to `false`. When `true`, [HapticFeedback.mediumImpact] is
  /// triggered alongside [onComplete] when the value reaches 1.0.
  final bool enableHapticFeedback;

  @override
  State<ProgressIndicator> createState() => _ProgressIndicatorState();
}

class _ProgressIndicatorState extends State<ProgressIndicator> {
  bool _hasCompleted = false;

  void _checkCompletion(double animatedValue) {
    if (animatedValue >= 1.0 && !_hasCompleted) {
      _hasCompleted = true;
      widget.onComplete?.call();
      if (widget.enableHapticFeedback) {
        HapticFeedback.mediumImpact();
      }
    } else if (animatedValue < 1.0) {
      _hasCompleted = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1.0);
    final scaledSize = widget.size.scaled(scale);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    if (widget.value == null) {
      return _buildVariant(context, null, scaledSize, scale);
    }

    // Respect the user's reduced-motion preference: render the final value
    // directly instead of running the expressive spring.
    if (disableAnimations) {
      _checkCompletion(widget.value!);
      return _buildVariant(context, widget.value, scaledSize, scale);
    }

    // We animate the determinate value implicitly with motion physics.
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: widget.value),
      // Note: SpringCurve overrides standard translation, so this duration simply guarantees the animation lives long enough for the spring to settle.
      duration: const Duration(milliseconds: 1500),
      curve: SpringCurve(MotionTokens.expressiveSlowSpatial),
      builder: (context, animValue, child) {
        _checkCompletion(animValue);
        return _buildVariant(context, animValue, scaledSize, scale);
      },
    );
  }

  Widget _buildVariant(
    BuildContext context,
    double? animatedValue,
    ProgressIndicatorSize scaledSize,
    double scale,
  ) {
    if (widget.variant == ProgressIndicatorVariant.linear) {
      return _LinearProgressIndicator(
        value: animatedValue,
        size: scaledSize,
        shape: widget.shape,
        activeColor: widget.activeColor,
        trackColor: widget.trackColor,
        phase: widget.phase,
        inset: widget.inset,
        scale: scale,
        showInlineLabel: widget.showInlineLabel,
        textStyle: widget.textStyle,
      );
    }

    final circular = _CircularProgressIndicator(
      value: animatedValue,
      size: scaledSize,
      shape: widget.shape,
      activeColor: widget.activeColor,
      trackColor: widget.trackColor,
      rotation: widget.rotation,
    );

    if (!widget.showLabel || animatedValue == null) return circular;

    final d = scaledSize.diameterWavy;
    return SizedBox(
      width: d,
      height: d,
      child: Stack(
        alignment: Alignment.center,
        children: [
          circular,
          Text(
            '${(animatedValue * 100).round()}%',
            style: widget.textStyle ?? Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class _CircularProgressIndicator extends StatefulWidget {
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

  @override
  State<_CircularProgressIndicator> createState() =>
      _CircularProgressIndicatorState();
}

class _CircularProgressIndicatorState
    extends State<_CircularProgressIndicator> {
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
    return widget.shape == ProgressIndicatorShape.wavy;
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
                // 1333ms per arc cycle, 2222ms per rotation cycle.
                // The LCM (1333 * 2222 = 2961926ms) ensures seamless wrapping.
                duration: wantsWavy
                    ? const Duration(
                        milliseconds: 1333 * 2222,
                      ) // keep simple, same LCM for wavy? Or maybe standard 1333 is fine? Wavy actually usually isn't M3, but we can standardize.
                    : const Duration(milliseconds: 1333 * 2222),
                animatable: Tween(begin: 0.0, end: 1333.0 * 2222.0),
                builder: (context, totalMs, child) {
                  final isIndeterminate = widget.value == null;

                  final arcCycles = totalMs / 1333.0;
                  final spinAngle = (totalMs / 2222.0) * 2 * math.pi;

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
                            wavePhase: (totalMs / 1000.0) * 2 * math.pi,
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

class _LinearProgressIndicator extends StatefulWidget {
  const _LinearProgressIndicator({
    required this.size,
    required this.shape,
    required this.phase,
    required this.inset,
    required this.scale,
    this.value,
    this.activeColor,
    this.trackColor,
    this.showInlineLabel = false,
    this.textStyle,
  });

  final double? value;
  final ProgressIndicatorSize size;
  final ProgressIndicatorShape shape;
  final Color? activeColor;
  final Color? trackColor;
  final double phase;
  final double inset;
  final double scale;
  final bool showInlineLabel;
  final TextStyle? textStyle;

  @override
  State<_LinearProgressIndicator> createState() =>
      _LinearProgressIndicatorState();
}

class _LinearProgressIndicatorState extends State<_LinearProgressIndicator> {
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
    return widget.shape == ProgressIndicatorShape.wavy;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = widget.activeColor ?? theme.colorScheme.primary;
    final track = widget.trackColor ?? theme.colorScheme.secondaryContainer;

    final spec = specForLinear(
      size: widget.size,
      shape: widget.shape,
      scale: widget.scale,
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
              duration: const Duration(milliseconds: 2000),
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
                phase: widget.phase,
                inset: widget.inset,
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
    this.indeterminateWavePeriod =
        WavyProgressConstants.indeterminateWavePeriod,
  });

  /// Stroke height of active / track lines.
  final double trackHeight;

  /// Horizontal gap between active track end and inactive track start.
  /// Spec: track-active-indicator-space = 4dp (fixed).
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

  /// Wavelength of the wave in indeterminate mode (spec: 20dp).
  final double indeterminateWavePeriod;
}

/// Builds [LinearSpecs] from the unified [ProgressIndicatorSize] and shape.
///
/// Measurements from the merged M3 progress indicator token set
/// (`md.comp.progress-indicator.linear`):
///
/// | Variant      | Height | Gap | dot⌀ | dotVOff | amp | λ    | λ(indet) |
/// |--------------|--------|-----|------|---------|-----|------|----------|
/// | Flat  small  | 4      | 4   | 4    | 0       | —   | —    | —        |
/// | Flat  medium | 8      | 4   | 4    | 2       | —   | —    | —        |
/// | Wavy  small  | 10     | 4   | 4    | 0       | 3   | 40   | 20       |
/// | Wavy  medium | 14     | 4   | 4    | 2       | 3   | 40   | 20       |
LinearSpecs specForLinear({
  required ProgressIndicatorSize size,
  required ProgressIndicatorShape shape,
  double scale = 1.0,
}) {
  final thickness = size.thickness;
  // Shared derived measurements.
  final dotDiameter = 4.0 * scale;
  final gap = 4.0 * scale; // spec: track-active-indicator-space = 4dp (fixed)
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
        waveAmplitude: WavyProgressConstants.defaultAmplitude * scale,
        wavePeriod: WavyProgressConstants.defaultWavePeriod * scale,
        indeterminateWavePeriod:
            WavyProgressConstants.indeterminateWavePeriod * scale,
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
                showInlineLabel: true,
                showLabel: true,
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

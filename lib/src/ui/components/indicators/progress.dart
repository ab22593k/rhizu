import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import 'package:rhizu/src/ui/components/indicators/progress_circular.dart';
import 'package:rhizu/src/ui/components/indicators/progress_linear.dart';
import 'package:rhizu/src/ui/components/indicators/progress_tokens.dart';
import 'package:rhizu/src/ui/styles/motion/physics.dart';
import 'package:rhizu/src/ui/styles/motion/tokens.dart';

/// Re-exports the painters used by the progress indicator widgets.
///
/// The actual painter implementations live in `painter/progress_painter.dart`.
export 'painter/progress_painter.dart';
export 'progress_linear_specs.dart';
export 'progress_tokens.dart';

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
    this.amplitude,
    this.wavelength,
    this.inset = 4.0,
    this.showLabel = false,
    this.showInlineLabel = false,
    this.textStyle,
    this.semanticsLabel,
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
  ///
  /// The size is independent of the ambient text scale factor; typography
  /// settings do not resize the indicator.
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

  /// Wave amplitude (in logical pixels) for the wavy shape.
  ///
  /// When `null` the M3 Expressive spec defaults apply
  /// (`md.comp.progress-indicator.linear.active-indicator.wave.amplitude` = 3dp
  /// for linear, `md.comp.progress-indicator.circular.active-indicator.wave.amplitude`
  /// = 1.6dp for circular).
  ///
  /// The amplitude measures from the center of the resting position to the
  /// center of the peak. For the linear variant the wave's peak-to-trough
  /// extent (`thickness + 2 × amplitude`) is the overall container height.
  final double? amplitude;

  /// Wave wavelength (in logical pixels) for the wavy shape.
  ///
  /// When `null` the M3 Expressive spec defaults apply
  /// (`md.comp.progress-indicator.linear.active-indicator.wave.wavelength` =
  /// 40dp determinate / 20dp indeterminate for linear,
  /// `md.comp.progress-indicator.circular.active-indicator.wave.wavelength` =
  /// 15dp for circular).
  ///
  /// Supplying a value overrides the wavelength in every wavy mode. The
  /// wavelength measures the distance between two adjacent wave peaks.
  final double? wavelength;

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

  /// Accessible label for the progress indicator.
  ///
  /// When null, no label is announced. The determinate indicator is exposed
  /// to assistive technologies as a progress bar with `minValue = 0`,
  /// `maxValue = 100` and `value = <percentage>`, mirroring the reference
  /// implementation's semantics.
  final String? semanticsLabel;

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
    // Indicator dimensions are fixed in logical pixels and deliberately
    // ignore the ambient text scale factor: typography settings are an
    // accessibility preference, not a layout breakpoint.
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    final Widget indicator;
    if (widget.value == null) {
      indicator = _buildVariant(context, null, widget.size);
    } else if (disableAnimations) {
      // Respect the user's reduced-motion preference: render the final value
      // directly instead of running the expressive spring.
      _checkCompletion(widget.value!);
      indicator = _buildVariant(context, widget.value, widget.size);
    } else {
      // We animate the determinate value implicitly with motion physics.
      indicator = TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: widget.value),
        // Note: SpringCurve overrides standard translation, so this duration simply guarantees the animation lives long enough for the spring to settle.
        duration: const Duration(milliseconds: 1500),
        curve: SpringCurve(MotionTokens.expressiveSlowSpatial),
        builder: (context, animValue, child) {
          _checkCompletion(animValue);
          return _buildVariant(context, animValue, widget.size);
        },
      );
    }

    // Accessibility: expose determinate indicators as progress bars with a
    // percentage value, and indeterminate ones as loading spinners
    // (reference implementation semantics).
    final isProgressBar = widget.value != null;
    return Semantics(
      label: widget.semanticsLabel,
      role: isProgressBar
          ? SemanticsRole.progressBar
          : SemanticsRole.loadingSpinner,
      minValue: isProgressBar ? '0' : null,
      maxValue: isProgressBar ? '100' : null,
      value: isProgressBar ? '${(widget.value! * 100).round()}' : null,
      child: indicator,
    );
  }

  Widget _buildVariant(
    BuildContext context,
    double? animatedValue,
    ProgressIndicatorSize size,
  ) {
    if (widget.variant == ProgressIndicatorVariant.linear) {
      return ProgressLinearIndicator(
        value: animatedValue,
        size: size,
        shape: widget.shape,
        activeColor: widget.activeColor,
        trackColor: widget.trackColor,
        phase: widget.phase,
        amplitude: widget.amplitude,
        wavelength: widget.wavelength,
        inset: widget.inset,
        showInlineLabel: widget.showInlineLabel,
        textStyle: widget.textStyle,
      );
    }

    final circular = ProgressCircularIndicator(
      value: animatedValue,
      size: size,
      shape: widget.shape,
      activeColor: widget.activeColor,
      trackColor: widget.trackColor,
      rotation: widget.rotation,
      amplitude: widget.amplitude,
      wavelength: widget.wavelength,
    );

    if (!widget.showLabel || animatedValue == null) return circular;

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
            style: widget.textStyle ?? Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

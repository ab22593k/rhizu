import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'package:rhizu/src/components/indicators/animation/progress_animation_controller.dart';
import 'package:rhizu/src/components/indicators/constants.dart';
import 'package:rhizu/src/components/indicators/painter/wavy_progress_painter.dart';

/// A wavy circular progress indicator widget.
///
/// This widget displays a circular progress indicator with a wavy active
/// portion and a flat track. It supports both determinate (with progress value)
/// and indeterminate (spinning) modes.
///
/// The wavy effect is created by modulating the radius based on a sine wave
/// function, creating an organic, flowing appearance.
///
/// Example usage:
/// ```dart
/// // Indeterminate (spinning) mode
/// WavyCircularProgressIndicator(
///   color: Theme.of(context).colorScheme.primary,
///   trackColor: Theme.of(context).colorScheme.secondaryContainer,
/// )
///
/// // Determinate mode (50% progress)
/// WavyCircularProgressIndicator(
///   value: 0.5,
///   color: Theme.of(context).colorScheme.primary,
///   trackColor: Theme.of(context).colorScheme.secondaryContainer,
/// )
/// ```
class CircularPI extends StatefulWidget {

  /// Creates a wavy circular progress indicator.
  ///
  /// [color] and [trackColor] are required. All other parameters have defaults.
  const CircularPI({
    required this.color, required this.trackColor, super.key,
    this.value,
    this.radius = WavyProgressConstants.defaultRadius,
    this.strokeWidth = WavyProgressConstants.defaultStrokeWidth,
    this.waves = WavyProgressConstants.defaultWaves,
    this.amplitude = WavyProgressConstants.defaultAmplitude,
    this.trackGap = WavyProgressConstants.defaultTrackGap,
  });
  /// The current progress value (0.0 to 1.0) or null for indeterminate mode.
  ///
  /// When null, the indicator spins continuously.
  /// When provided, the indicator shows a static arc representing the progress.
  final double? value;

  /// The color of the active progress indicator.
  final Color color;

  /// The color of the track (background) arc.
  final Color trackColor;

  /// The radius of the indicator in logical pixels.
  ///
  /// The widget size will be radius * 2.
  /// Defaults to [WavyProgressConstants.defaultRadius].
  final double radius;

  /// The width of the stroke lines in logical pixels.
  ///
  /// Defaults to [WavyProgressConstants.defaultStrokeWidth].
  final double strokeWidth;

  /// The number of waves (frequency) around the circle.
  ///
  /// Higher values create more peaks and troughs.
  /// Defaults to [WavyProgressConstants.defaultWaves].
  final int waves;

  /// The amplitude (height) of the wave in logical pixels.
  ///
  /// Determines how far the wave deviates from the base radius.
  /// Defaults to [WavyProgressConstants.defaultAmplitude].
  final double amplitude;

  /// The gap between the active indicator and track in logical pixels.
  ///
  /// Only applies in determinate mode.
  /// Defaults to [WavyProgressConstants.defaultTrackGap].
  final double trackGap;

  @override
  State<CircularPI> createState() => _CircularPIState();
}

class _CircularPIState extends State<CircularPI>
    with SingleTickerProviderStateMixin {
  late final WavyProgressAnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WavyProgressAnimationController(vsync: this);
    // Only animate in indeterminate mode
    if (widget.value != null) {
      _controller.stop();
    }
  }

  @override
  void didUpdateWidget(CircularPI oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Start/stop animation based on mode
    final wasIndeterminate = oldWidget.value == null;
    final isIndeterminate = widget.value == null;

    if (wasIndeterminate != isIndeterminate) {
      if (isIndeterminate) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
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
        animation: _controller.animation,
        builder: (context, child) {
          return CustomPaint(
            painter: WavyProgressPainter(
              progress: widget.value,
              rotation: _controller.rotation,
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

@Preview(name: 'Expressive Progress')
Widget previewWavyProgressIndicator() => Scaffold(
  body: Builder(
    builder: (context) => Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 40,
        children: [
          CircularPI(
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
);

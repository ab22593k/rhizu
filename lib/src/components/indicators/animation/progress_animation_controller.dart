import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:rhizu/src/components/indicators/constants.dart';

/// Controller for the wavy circular progress indicator animation.
///
/// This class manages the rotation animation used in indeterminate mode.
/// In determinate mode (when progress is provided), the animation may be
/// disabled or used for visual effects.
class WavyProgressAnimationController {
  /// Creates a new animation controller for the wavy progress indicator.
  ///
  /// [vsync] provides the ticker for the animation controller.
  /// [duration] overrides the default rotation duration (optional).
  WavyProgressAnimationController({
    required TickerProvider vsync,
    Duration? duration,
  }) {
    _controller = AnimationController(
      vsync: vsync,
      duration: duration ?? WavyProgressConstants.rotationDuration,
    )..repeat();
  }
  late final AnimationController _controller;
  bool _isDisposed = false;

  /// The current rotation value [0, 1] representing 0 to 360 degrees.
  double get value => _controller.value;

  /// Whether this controller has been disposed.
  bool get isDisposed => _isDisposed;

  /// The animation controller for listening to animation updates.
  Animation<double> get animation => _controller;

  /// Gets the current rotation angle in radians.
  ///
  /// Returns the controller value multiplied by 2*pi for a full circle.
  double get rotation => _controller.value * 2 * math.pi;

  /// Stops the animation.
  ///
  /// Useful when switching between determinate and indeterminate modes.
  void stop() {
    if (!_isDisposed) {
      _controller.stop();
    }
  }

  /// Starts/restarts the animation.
  ///
  /// Used to resume animation in indeterminate mode.
  void repeat() {
    if (!_isDisposed) {
      _controller.repeat();
    }
  }

  /// Disposes of the animation controller.
  ///
  /// Must be called when the controller is no longer needed to prevent memory leaks.
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
  }
}
